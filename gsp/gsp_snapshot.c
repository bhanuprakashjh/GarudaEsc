/**
 * @file gsp_snapshot.c
 *
 * @brief Tear-safe snapshot capture from garudaData.
 *
 * Strategy:
 * - Most fields are 8-bit or 16-bit (atomic on dsPIC33AK)
 * - 32-bit fields (duty, systemTick, trip counters) may tear but
 *   this is acceptable for telemetry — worst case is off by 1
 * - Prio-7 ISR fields (HWZC counters, stepPeriodHR) use:
 *   - Seqlock for stepPeriodHR (existing hwzc.writeSeq)
 *   - Double-read with bounded retry for 32-bit counters
 * - Feature-gated fields are zeroed when feature is disabled
 *
 * Component: GSP
 */

#include "garuda_config.h"

#if FEATURE_GSP

#include <xc.h>
#include <string.h>
#include "gsp_snapshot.h"
#include "garuda_calc_params.h"
#include "garuda_types.h"
#include "garuda_service.h"

#define SNAPSHOT_RETRY_MAX  4

/* Read a volatile uint32_t with double-read consistency check.
 * Returns v1 if all retries torn (acceptable for telemetry). */
static uint32_t ReadU32Consistent(volatile uint32_t *src)
{
    uint32_t v1, v2;
    uint8_t retry = SNAPSHOT_RETRY_MAX;
    do {
        v1 = *src;
        v2 = *src;
        if (v1 == v2)
            return v1;
    } while (--retry);
    return v1;
}

void GSP_CaptureSnapshot(GSP_SNAPSHOT_T *dst)
{
    volatile GARUDA_DATA_T *src = &garudaData;

    /* Zero the entire struct first (handles disabled-feature fields) */
    memset(dst, 0, sizeof(GSP_SNAPSHOT_T));

    /* Core state (all 8/16-bit: atomic on dsPIC33AK) */
    dst->state       = (uint8_t)src->state;
    dst->faultCode   = (uint8_t)src->faultCode;
    dst->currentStep = src->currentStep;
    dst->direction   = src->direction;
    dst->throttle    = src->throttle;
    dst->dutyPct     = (uint8_t)((uint64_t)src->duty * 100 / LOOPTIME_TCY);

    /* Bus */
    dst->vbusRaw     = src->vbusRaw;
#if FEATURE_HW_OVERCURRENT
    dst->ibusRaw     = src->ibusRaw;
    dst->ibusMax     = src->ibusMax;
    dst->ibusAvg     = src->ibusAvg;
#endif

    /* BEMF/ZC */
    dst->bemfRaw     = src->bemf.bemfRaw;
    dst->zcThreshold = src->bemf.zcThreshold;
    dst->stepPeriod  = src->timing.stepPeriod;
#if FEATURE_SINE_STARTUP
    /* The SW timing.stepPeriod is stale during open-loop spin-up (it holds a
     * frozen init value), so the host mislabels idle/OL eRPM as a constant
     * ~5k. Report the TRUE state-appropriate speed instead, so the OL->CL
     * hand-off speed is actually visible for tuning. Encoding matches the host
     * (displayed eRPM = 450000 / stepPeriod). The CL path is untouched — in
     * ESC_CLOSED_LOOP the host reads eRPM from the HWZC HR period, not this. */
    if (src->state == ESC_OL_RAMP || src->state == ESC_MORPH) {
        uint32_t olErpm = (uint32_t)(src->sine.erpmFrac >> 16);  /* commanded eRPM */
        dst->stepPeriod = (olErpm >= 1u) ? (uint16_t)(450000UL / olErpm) : 0u;
    } else if (src->state < ESC_OL_RAMP) {
        dst->stepPeriod = 0u;   /* IDLE/ARMED/DETECT/ALIGN: not yet spinning */
    }
#endif
#if FEATURE_IBUS_PROBE
    /* DIRECT CMP3-output probe: surface the CMP3 rising-edge fire-RATE (latched
     * via _CMP3IF in the ADC ISR) in the eRPM column (host shows eRPM =
     * 450000/stepPeriod). This is the comparator itself, NOT the CLPCI chop:
     *   eRPM non-zero as pot rises  -> CMP3 sees the current (INPSEL/OA3 OK)
     *   eRPM stays 0 at full pot    -> CMP3 blind (DAC forced below rest, so
     *                                  this means the input mux/routing is wrong)
     * Pair with Ibus: eRPM up + Ibus collapsing = the chop itself also works. */
    {
        extern volatile uint32_t g_cmp3FireCount;   /* live CMP3 CMPSTAT level */
        dst->stepPeriod = (g_cmp3FireCount != 0u) ? 45u : 0u;  /* eRPM 10000 / 0 */
    }
#endif
#if FEATURE_FOC_AN1078
    /* FOC has no 6-step stepPeriod, so the host's eRPM column (text row /
     * TimeChart use eRPM = PWMFREQUENCY_HZ*10 / stepPeriod) reads 0 even while
     * the motor spins. Synthesize stepPeriod from the SMO electrical speed:
     * eRPM_elec = |omega| * 60/(2π); stepPeriod = (PWMFREQUENCY_HZ*10)/eRPM.
     * Placed last so it overrides any sine/probe assignment above. The gauge
     * already reads focOmega directly; this fixes the log/chart. 2026-07-09. */
    {
        float omega_abs = (src->focOmega < 0.0f) ? -src->focOmega : src->focOmega;
        float erpm = omega_abs * 9.54929659f;   /* elec rad/s → electrical RPM */
        dst->stepPeriod = (erpm >= 1.0f)
            ? (uint16_t)((float)(PWMFREQUENCY_HZ * 10UL) / erpm)
            : 0u;
    }
#endif
    dst->goodZcCount = src->timing.goodZcCount;

    /* ZC flags */
    dst->risingZcWorks  = src->timing.risingZcWorks  ? 1 : 0;
    dst->fallingZcWorks = src->timing.fallingZcWorks ? 1 : 0;
    dst->zcSynced       = src->timing.zcSynced       ? 1 : 0;

    /* ZC diagnostics */
#if FEATURE_BEMF_CLOSED_LOOP
    dst->zcConfirmedCount    = src->zcDiag.zcConfirmedCount;
    dst->zcTimeoutForceCount = src->zcDiag.zcTimeoutForceCount;
#endif

    /* HWZC — non-prio-7 fields (8/16-bit: atomic) */
#if FEATURE_ADC_CMP_ZC
    dst->hwzcEnabled         = src->hwzc.enabled ? 1 : 0;
    dst->hwzcPhase           = (uint8_t)src->hwzc.phase;
    dst->hwzcDbgLatchDisable = src->hwzc.dbgLatchDisable ? 1 : 0;
#endif

    /* Morph */
#if FEATURE_SINE_STARTUP
    dst->morphSubPhase = (uint8_t)src->morph.subPhase;
    dst->morphStep     = src->morph.morphStep;
    dst->morphZcCount  = src->morph.morphZcCount;
    dst->morphAlpha    = src->morph.alpha;
#endif

    /* Overcurrent (32-bit counters: may tear, acceptable for telemetry) */
#if FEATURE_HW_OVERCURRENT
    dst->clpciTripCount = src->clpciTripCount;
    dst->fpciTripCount  = src->fpciTripCount;
#endif

    /* System (32-bit: may tear by 1ms, acceptable) */
    dst->systemTick = src->systemTick;
    dst->uptimeSec  = src->systemTick / 1000;

    /* FOC telemetry (float fields: may tear, acceptable for telemetry) */
#if FEATURE_FOC_V2 || FEATURE_FOC_V3 || FEATURE_FOC_AN1078
    dst->focIdMeas   = src->focIdMeas;
    dst->focIqMeas   = src->focIqMeas;
    dst->focTheta    = src->focTheta;
    dst->focOmega    = src->focOmega;
    dst->focVbus     = src->focVbus;
    dst->focIa       = src->focIa;
    dst->focIb       = src->focIb;
    dst->focThetaObs = src->focThetaObs;
    dst->focVd       = src->focVd;
    dst->focVq       = src->focVq;
    dst->focFluxAlpha   = src->focFluxAlpha;
    dst->focFluxBeta    = src->focFluxBeta;
    dst->focLambdaEst   = src->focLambdaEst;
    dst->focObsGain     = src->focObsGain;
    dst->focPidDInteg   = src->focPidDInteg;
    dst->focPidQInteg   = src->focPidQInteg;
    dst->focPidSpdInteg = src->focPidSpdInteg;
    dst->focModIndex    = src->focModIndex;
    dst->focObsConfidence = src->focObsConfidence;
    dst->focSubState = src->focSubState;
    dst->focOffsetIa = src->focOffsetIa;
    dst->focOffsetIb = src->focOffsetIb;
    /* 2026-07-14: real 3rd-phase Iw + real DC-bus Ibus as centi-amps, raw NTC
     * temp. Compact int16 so the snapshot stays within the GSP frame LEN. */
  #if FEATURE_FOC_V3 || FEATURE_FOC_AN1078
    dst->focIwCa   = (int16_t)(src->focIw   * 100.0f);
    dst->focIbusCa = (int16_t)(src->focIbus * 100.0f);
  #endif
    dst->tempRaw   = src->tempRaw;
  #if FEATURE_FOC_V3   /* probe block moved out of FOC guard (see below) */

    /* v3-only: SMO + PLL observer fields — GARUDA_DATA_T doesn't include
     * these under v2 (which uses MXLEMMING flux observer instead). */
    dst->smoResidual    = src->smoResidual;
    dst->pllInnovation  = src->pllInnovation;
    dst->pllOmega       = src->pllOmega;
    dst->omegaOl        = src->omegaOl;
    dst->handoffCtr     = src->handoffCtr;
    dst->smoObservable  = src->smoObservable;
  #endif
#elif FEATURE_FOC
    dst->focTheta    = src->focTheta;
    dst->focOmega    = src->focOmega;
    dst->focVbus     = src->focVbus;
    dst->focIa       = src->focIa;
    dst->focIb       = src->focIb;
    dst->focSubState = src->focSubState;
    dst->focOffsetIa = src->focOffsetIa;
    dst->focOffsetIb = src->focOffsetIb;
#endif

    /* BRING-UP (remove after first spin): repurpose the v3-only observer
     * slots for ISR/trigger liveness — read LIVE here in main-loop context,
     * so they stay truthful even when the ADC ISR is dead.
     *   smoResidual   = ADC-ISR entry count
     *   pllInnovation = flag word: IE | IF<<1 | AD1.ON<<2 | AD1.ADRDY<<3
     *                   | PG1.ON<<4
     *   pllOmega      = PG1STAT activity over ~1 PWM period (0 = HALTED)
     *   omegaOl       = RCON captured at boot (reset cause) */
    {
        extern volatile uint32_t g_adcIsrCount;
        extern volatile uint32_t g_bootRcon;
        dst->smoResidual    = (float)g_adcIsrCount;
        dst->pllInnovation  = (float)(uint16_t)((_AD1CH0IE ? 1u : 0u)
                            | ((_AD1CH0IF ? 1u : 0u) << 1)
                            | ((AD1CONbits.ON ? 1u : 0u) << 2)
                            | ((AD1CONbits.ADRDY ? 1u : 0u) << 3)
                            | ((PG1CONbits.ON ? 1u : 0u) << 4));
        {
            /* No readable PGxTMR on MC506 — watch PG1STAT's cycle bits
             * (CAHALF/SEVT/...) change over ~one 45 kHz period instead. */
            uint16_t toggles = 0;
            uint32_t prev = PG1STAT;
            uint16_t i;
            for (i = 0; i < 500u; i++) {
                uint32_t now = PG1STAT;
                if (now != prev) toggles++;
                prev = now;
            }
            dst->pllOmega = (float)toggles;   /* 0 = time base halted */
        }
        dst->omegaOl        = (float)(g_bootRcon & 0xFFFFu);
        /* PWM ground truth: actual duty register + override state, live.
         *   handoffCtr    = PG1DC >> 4 (~50% of LOOPTIME_TCY -> ~2200)
         *   smoObservable = OVRENH<<3|OVRENL<<2|OVRDAT (0x0 = full PWM) */
        dst->handoffCtr     = (uint16_t)(PG1DC >> 4);
        dst->smoObservable  = (uint8_t)(((PG1IOCON2 >> 18) & 0x0Cu)
                                      | ((PG1IOCON2 >> 12) & 0x03u));
    }

    /* Prio-7 fields: use consistency techniques */
#if FEATURE_ADC_CMP_ZC
    /* stepPeriodHR: seqlock */
    {
        uint16_t s1, s2;
        uint32_t val;
        uint8_t retry = SNAPSHOT_RETRY_MAX;
        do {
            s1  = src->hwzc.writeSeq;
            val = src->hwzc.stepPeriodHR;
            s2  = src->hwzc.writeSeq;
        } while ((s1 != s2 || (s1 & 1)) && --retry);
        dst->hwzcStepPeriodHR = val;
    }

    /* 32-bit counters: double-read */
    dst->hwzcTotalZcCount   = ReadU32Consistent(&src->hwzc.totalZcCount);
    dst->hwzcTotalMissCount = ReadU32Consistent(&src->hwzc.totalMissCount);
    dst->hwzcNoiseReject    = ReadU32Consistent(&src->hwzc.noiseRejectCount);

    /* Per-sector "guess" tally — low 16 bits (host diffs consecutive frames,
     * per-frame delta << 65536 so truncation is delta-safe). Shows WHERE the
     * misses fall across the 6 commutation sectors. */
    {
        int i;
        for (i = 0; i < 6; i++)
            dst->hwzcMissBySector[i] =
                (uint16_t)ReadU32Consistent(&src->hwzc.dbgPiMissBySector[i]);
    }
#endif

    /* Main-loop CPU load (‰) — computed in main()'s while(1). Plain 16-bit
     * read is atomic on dsPIC33AK. */
    dst->cpuLoadPermille = src->cpuLoadPermille;

    /* Falling-sector OFF-center BEMF envelope — read then reset the window so
     * each snapshot reports the swing over the most recent ~20 ms. */
    dst->fallOffBemfMin = src->bemf.fallOffBemfMin;
    dst->fallOffBemfMax = src->bemf.fallOffBemfMax;
    src->bemf.fallOffBemfMin = 0xFFFF;
    src->bemf.fallOffBemfMax = 0;
#if FEATURE_FOC_AN1078
    /* A2 Iw-calibration telemetry: the 6-step BEMF-envelope slots are dormant
     * under AN1078, so repurpose fallOffBemfMax to stream the raw Iw sample,
     * tick-aligned (same PG1TRIGA) with focIa/focIb. Offline: regress
     * iw_ref = -(focIa + focIb) against this raw to recover the Iw gain,
     * sign, and offset. Decoded to CSV column `fall_off_max`; no snapshot-
     * format change, no decoder change. Remove after A1 lands. */
    {
        extern volatile uint16_t g_iwRawCal;
        /* fallOffBemfMin doubles as the decoder's "has-samples" guard: it
         * discards fall_off_max when min == 0xFFFF (the 6-step no-sample
         * sentinel, which is what AN1078 leaves it at). Clear it to 0 so the
         * host emits fall_off_max = raw Iw into the CSV. */
        /* A1: fallOffBemfMin now carries clarke_drop (0=none,1=U,2=V,3=W) so the
         * bench can see the best-2-of-3 reconstruction engage. Still != 0xFFFF
         * so the decoder's has-samples guard passes and fall_off_max streams. */
        extern volatile uint8_t g_clarkeDropCal;
        dst->fallOffBemfMin = g_clarkeDropCal;
        dst->fallOffBemfMax = g_iwRawCal;
    }
#endif

#if !FEATURE_FOC && !FEATURE_FOC_V2 && !FEATURE_FOC_V3 && !FEATURE_FOC_AN1078
    /* Phase-current monitor (16-bit fields are atomic on dsPIC33AK).
     * Read the window max/min, then reset them in one block so the ADC ISR
     * starts a fresh window. Small race here: if the ADC ISR fires between
     * the read and the reset, we lose at most one sample per phase — OK
     * for diagnostic purposes. */
    dst->iaRaw = src->phaseCurrent.iaRaw;
    dst->ibRaw = src->phaseCurrent.ibRaw;
    dst->iaMax = src->phaseCurrent.iaMax;
    dst->iaMin = src->phaseCurrent.iaMin;
    dst->ibMax = src->phaseCurrent.ibMax;
    dst->ibMin = src->phaseCurrent.ibMin;
    dst->ibusWinMax = src->phaseCurrent.ibusWinMax;
    dst->ibusWinMin = src->phaseCurrent.ibusWinMin;
    src->phaseCurrent.iaMax = 0;
    src->phaseCurrent.iaMin = 0xFFFF;
    src->phaseCurrent.ibMax = 0;
    src->phaseCurrent.ibMin = 0xFFFF;
    src->phaseCurrent.ibusWinMax = 0;
    src->phaseCurrent.ibusWinMin = 0xFFFF;
    /* Frozen-at-fault snapshot — static after fault, so no reset. */
    dst->iaAtFault    = src->phaseCurrent.iaAtFault;
    dst->ibAtFault    = src->phaseCurrent.ibAtFault;
    dst->iaMaxAtFault = src->phaseCurrent.iaMaxAtFault;
    dst->iaMinAtFault = src->phaseCurrent.iaMinAtFault;
    dst->ibMaxAtFault = src->phaseCurrent.ibMaxAtFault;
    dst->ibMinAtFault = src->phaseCurrent.ibMinAtFault;
    dst->ibusAtFault    = src->phaseCurrent.ibusAtFault;
    dst->ibusMaxAtFault = src->phaseCurrent.ibusMaxAtFault;
    dst->ibusMinAtFault = src->phaseCurrent.ibusMinAtFault;
#endif

    /* Speed PI telemetry (zero unless FEATURE_SPEED_PI=1; the struct
     * fields exist either way, sourced from GARUDA_DATA_T.speedPi). */
#if GARUDA_TARGET_AK512 && defined(AK512_BRINGUP_DIAG)
    /* TEMPORARY bring-up diagnostics riding the idle speed-PI telemetry:
     *   spiTarget  = AD1CH3DATA  (VB pwm-synced raw — the 45kHz ISR channel)
     *   spiError   = AD2CH1DATA  (POT raw)
     *   spiOutput  = flag word: [13:8]=AD1CH3 TRG1SRC, bit5=PG1 ON,
     *                bit4..2=AD3/AD2/AD1 ADRDY, bit1=_AD1CH3IE, bit0=_AD1CH3IF
     *   spiInteg   = AD3CH2DATA  (VBUS raw)
     * Remove before merge. */
    dst->speedPiEnabled        = 0xDDu;   /* marker: diagnostics active */
    dst->speedPiZcsSinceEnable = src->hwzc.dbgPiNoCap;        /* silent PI events */
    dst->speedPiTarget         = (int32_t)src->hwzc.dbgLastCapPm; /* cap pos ‰ of T */
    dst->speedPiLastError      = (int32_t)src->hwzc.dbgPiCrossSector;
    dst->speedPiOutputDuty     = (uint16_t)(
                                 ((uint16_t)PG1STATbits.SEVT    << 12)
                               | ((uint16_t)PG1STATbits.FFEVT   << 11)
                               | ((uint16_t)PG1STATbits.CLEVT   << 10)
                               | ((uint16_t)PG1STATbits.FLT1EVT << 9)
                               | ((uint16_t)PG1STATbits.SACT    << 8)
                               | ((uint16_t)PG1STATbits.FFACT   << 7)
                               | ((uint16_t)PG1STATbits.CLACT   << 6)
                               | ((uint16_t)PG1STATbits.FLT1ACT << 5)
                               | ((uint16_t)AD3CONbits.ADRDY << 4)
                               | ((uint16_t)AD2CONbits.ADRDY << 3)
                               | ((uint16_t)AD1CONbits.ADRDY << 2)
                               | ((uint16_t)_AD1CH3IE << 1)
                               | (uint16_t)_AD1CH3IF);
    dst->speedPiIntegratorF    = (float)(uint32_t)AD3CH2DATA;
#else
    dst->speedPiEnabled        = src->speedPi.enabled ? 1u : 0u;
    dst->speedPiZcsSinceEnable = src->speedPi.zcsSinceEnable;
    dst->speedPiTarget         = src->speedPi.lastTarget;
    dst->speedPiLastError      = src->speedPi.lastError;
    dst->speedPiOutputDuty     = src->speedPi.outputDuty;
    dst->speedPiIntegratorF    = src->speedPi.integratorF;
#endif
}

#endif /* FEATURE_GSP */
