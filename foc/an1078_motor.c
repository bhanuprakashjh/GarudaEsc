/**
 * @file  an1078_motor.c
 * @brief AN1078 motor controller — float port (implementation).
 *
 * Direct float translation of the relevant parts of AN1078 `pmsm.c`:
 *   - InitControlParameters()         → AN_MotorInit() helpers
 *   - ResetParmeters()                → AN_MotorStop() / reset block
 *   - DoControl()                     → an_do_control()
 *   - CalculateParkAngle()            → an_calc_park_angle()
 *   - _ADCInterrupt body              → AN_MotorFastTick()
 *
 * Algorithm preserved exactly.  Where the original used assembly
 * primitives (MC_TransformClarke_Assembly, MC_TransformPark_Assembly,
 * MC_CalculateSpaceVectorPhaseShifted_Assembly), this file inlines
 * float versions.
 *
 * NOT ported (deliberately omitted):
 *   - Field weakening (FieldWeakening / fdweak.c)
 *   - Single-shunt reconstruction
 *   - TUNING / TORQUE_MODE conditional builds
 *   - PWM/ADC peripheral setup (handled by garuda_service.c)
 */

#include "an1078_motor.h"
#include "an1078_params.h"
#include "../gsp/gsp_params.h"   /* gspParams — live FW tuning */
#include <math.h>
#include <stddef.h>

#if FEATURE_AN_STA
#include "an1078_sta.h"
#endif

/* ── Local constants ──────────────────────────────────────────── */

#define AN_TWO_PI          6.28318530717958647692f
#define AN_PI              3.14159265358979323846f
#define AN_INV_SQRT3       0.57735026918962576451f
#define AN_SQRT3_OVER_2    0.86602540378443864676f
#define AN_TWO_OVER_THREE  0.66666666666666666667f
#define AN_ONE_OVER_THREE  0.33333333333333333333f

/* Calibration sample count (1024 → 10-bit shift average). */
#define AN_CAL_SAMPLES     1024U

/* ── PI controller (port of MC_ControllerPIUpdate_Assembly) ─────
 *
 * Q15 reference behavior:
 *   err = ref - meas
 *   integrator += ki × err - kc × prev_excess
 *   pre_sat = integrator + kp × err
 *   out = clamp(pre_sat, outMin, outMax)
 *   prev_excess = pre_sat - out   (anti-windup back-calculation)
 *
 * Float port: identical.  ki and kp are both per-tick gains
 * (not continuous), matching AN1078 convention. */
static inline float an_pi_run(AN_PI_T *pi, float ref, float meas, float dt)
{
    float err = ref - meas;
    /* Integrator update: ki has units of (output / input) per second, so
     * multiply by dt for the per-tick step. */
    pi->integrator += pi->ki * err * dt;

    float pre_sat = pi->integrator + pi->kp * err;
    float out = pre_sat;
    if (out > pi->outMax) out = pi->outMax;
    if (out < pi->outMin) out = pi->outMin;

    /* Anti-windup back-calc: subtract excess from integrator, scaled by kc.
     * AN1078 kc ≈ 0.999 → near-disabled.  We implement the same form. */
    float excess = pre_sat - out;
    pi->integrator -= (1.0f - pi->kc) * excess;

    return out;
}

static inline void an_pi_preload(AN_PI_T *pi, float v) { pi->integrator = v; }

static void an_pi_init(AN_PI_T *pi, float kp, float ki, float outMin, float outMax)
{
    pi->kp = kp;
    pi->ki = ki;
    pi->kc = AN_PI_KC;
    pi->outMin = outMin;
    pi->outMax = outMax;
    pi->integrator = 0.0f;
}

/* ── Clarke / Park transforms (float, 1:1 with mcb library) ──── */

/* Clarke: 3-phase → α-β (assumes ia + ib + ic = 0).
 *   α = ia
 *   β = (ia + 2·ib) / √3 */
static inline void an_clarke(float ia, float ib,
                             float *out_alpha, float *out_beta)
{
    *out_alpha = ia;
    *out_beta  = (ia + 2.0f * ib) * AN_INV_SQRT3;
}

/* Park: α-β → d-q at angle θ. */
static inline void an_park(float a, float b, float sin_t, float cos_t,
                           float *d, float *q)
{
    *d =  a * cos_t + b * sin_t;
    *q = -a * sin_t + b * cos_t;
}

/* Inverse Park: d-q → α-β at angle θ. */
static inline void an_inv_park(float d, float q, float sin_t, float cos_t,
                               float *a, float *b)
{
    *a = d * cos_t - q * sin_t;
    *b = d * sin_t + q * cos_t;
}

/* ── SVPWM (port of MC_CalculateSpaceVectorPhaseShifted_Assembly) ─
 *
 * Inputs Vα, Vβ in volts (0 = midpoint).  Outputs duty [0..1] for 3
 * phases, 0.5 = zero net voltage.  Standard min-max centering.  */
static void an_svpwm(float v_alpha, float v_beta, float vbus,
                     float *da, float *db, float *dc)
{
    /* Convert to phase voltages (inverse Clarke for 3-phase output) */
    float va = v_alpha;
    float vb = -0.5f * v_alpha + AN_SQRT3_OVER_2 * v_beta;
    float vc = -0.5f * v_alpha - AN_SQRT3_OVER_2 * v_beta;

    /* Common-mode shift (min-max) for SVM; centers output to use full bus */
    float vmin = va, vmax = va;
    if (vb < vmin) vmin = vb;
    if (vb > vmax) vmax = vb;
    if (vc < vmin) vmin = vc;
    if (vc > vmax) vmax = vc;
    float vcm = 0.5f * (vmin + vmax);

    /* Convert to [0..1] duty centred at 0.5; voltage / Vbus is the gain */
    float inv_vbus = (vbus > 1.0f) ? (1.0f / vbus) : 1.0f;
    *da = 0.5f + (va - vcm) * inv_vbus;
    *db = 0.5f + (vb - vcm) * inv_vbus;
    *dc = 0.5f + (vc - vcm) * inv_vbus;

    /* Clamp to [0..1] */
    if (*da < 0.0f) *da = 0.0f; if (*da > 1.0f) *da = 1.0f;
    if (*db < 0.0f) *db = 0.0f; if (*db > 1.0f) *db = 1.0f;
    if (*dc < 0.0f) *dc = 0.0f; if (*dc > 1.0f) *dc = 1.0f;
}

/* ── ADC helpers (signed amps from raw counts about a calibrated offset) */

static inline float an_raw_to_amps(uint16_t raw, float offset)
{
#if AN_CURRENT_INVERT
    return -(((float)raw - offset) * AN_CURRENT_A_PER_COUNT);
#else
    return  (((float)raw - offset) * AN_CURRENT_A_PER_COUNT);
#endif
}

/* W leg has its own ATA-op-amp scale/sign (see AN_CURRENT_W_* in params). */
static inline float an_raw_to_amps_w(uint16_t raw, float offset)
{
#if AN_CURRENT_W_INVERT
    return -(((float)raw - offset) * AN_CURRENT_W_A_PER_COUNT);
#else
    return  (((float)raw - offset) * AN_CURRENT_W_A_PER_COUNT);
#endif
}

static inline float an_raw_to_vbus(uint16_t raw)
{
    return (float)raw * AN_VBUS_V_PER_COUNT;
}

/* Wrap angle into [0, 2π). */
static inline float an_wrap_2pi(float th)
{
    /* Guard non-finite: on +Inf the first while spins forever, and NaN
     * never satisfies either test. A blown-up angle just resets to 0.
     * (NaN fails the range test -> returns 0; Inf likewise.) */
    if (!(th > -1.0e6f && th < 1.0e6f)) return 0.0f;
    while (th >= AN_TWO_PI) th -= AN_TWO_PI;
    while (th <  0.0f)      th += AN_TWO_PI;
    return th;
}

/* Wrap angle into (-π, π]. */
static inline float an_wrap_delta(float dth)
{
    if (dth >  AN_PI) dth -= AN_TWO_PI;
    if (dth < -AN_PI) dth += AN_TWO_PI;
    return dth;
}

static inline float an_abs(float x) { return (x >= 0.0f) ? x : -x; }

/* ── PI initialization helper ────────────────────────────────── */

static void an_init_pi_controllers(AN_Motor_T *m)
{
    /* AN1078 InitControlParameters: per-tick Q15 gains.
     * Our floats: kp/ki are continuous-time gains, an_pi_run multiplies
     * by dt where appropriate.  Voltage clamps based on Vbus computed
     * each tick during ISR (we set a wide initial clamp here). */
    float vmax_init = 24.0f * AN_INV_SQRT3 * AN_MAX_VOLTAGE_VECTOR_FRAC;

    an_pi_init(&m->pi_d, AN_KP_DQ, AN_KI_DQ, -vmax_init, vmax_init);
    an_pi_init(&m->pi_q, AN_KP_DQ, AN_KI_DQ, -vmax_init, vmax_init);

#if AN_OVERMOD_EN
    /* Full back-calculation anti-windup on the inner current PIs (overrides the
     * shared AN_PI_KC=0.5) so their integrators unwind completely when the vector
     * saturates against the overmodulation ceiling.  Speed PI keeps AN_PI_KC. */
    m->pi_d.kc = AN_PI_KC_CURRENT;
    m->pi_q.kc = AN_PI_KC_CURRENT;
#endif

    /* Speed PI: output = Iq reference, so clamp in amps. */
    an_pi_init(&m->pi_spd, AN_KP_SPD, AN_KI_SPD,
               -AN_OVER_CURRENT_LIMIT, AN_OVER_CURRENT_LIMIT);
}

/* ── ResetParmeters (port of pmsm.c:228) ─────────────────────── */

static void an_reset_parameters(AN_Motor_T *m)
{
    /* Stop motor */
    m->runMotor = false;
    /* Speed reference 0 */
    m->velRef_rad_s = 0.0f;
    m->id_ref_fw   = 0.0f;
    /* Restart in open loop */
    m->openLoop = true;
    /* Mode change pending (for DoControl init block) */
    m->changeMode = true;

    /* Re-init PI controllers */
    an_init_pi_controllers(m);

    /* Re-init estimator */
    AN_SMCInit(&m->smc);

    /* Reset startup state */
    m->startupLock = 0;
    m->startupRamp = 0.0f;
    m->thetaOpenLoop = 0.0f;
    m->thetaError = 0.0f;
    m->transCounter = 0;
    m->handoff_dwell = 0;

    /* Reset speed-ramp pacing */
    m->speedRampCount = AN_SPEEDREFRAMP_COUNT;
    m->speedRefRamp = AN_SPEEDREF_RAMP_RAD_S;
    m->targetSpeed_rad_s = 0.0f;
    m->vqRef = 0.0f;
    m->vdRef = 0.0f;

    /* Reset commanded voltages so SVPWM outputs 50% on first tick */
    m->vd = 0.0f;
    m->vq = 0.0f;
    m->v_alpha = 0.0f;
    m->v_beta = 0.0f;
    m->theta_drive = 0.0f;
}

/* ── Public API ───────────────────────────────────────────────── */

void AN_MotorInit(AN_Motor_T *m)
{
    /* Zero the entire struct first */
    AN_Motor_T zero = {0};
    *m = zero;

    m->mode = AN_MODE_STOPPED;
    m->faultCode = 0;
    m->ia_offset = (float)AN_ADC_MIDPOINT;
    m->ib_offset = (float)AN_ADC_MIDPOINT;
    m->iw_offset = (float)AN_CURRENT_W_MIDPOINT;   /* A1: own ATA-channel rest */
    m->cal_done = false;

    an_reset_parameters(m);
}

void AN_MotorStart(AN_Motor_T *m)
{
    if (m->mode == AN_MODE_FAULT) return;
    an_reset_parameters(m);
    m->runMotor = true;
    m->mode = AN_MODE_LOCK;
}

void AN_MotorStop(AN_Motor_T *m)
{
    an_reset_parameters(m);
    m->mode = AN_MODE_STOPPED;
}

void AN_MotorFault(AN_Motor_T *m, uint16_t code)
{
    m->mode = AN_MODE_FAULT;
    m->faultCode = code;
    m->runMotor = false;
}

/* ── DoControl (port of pmsm.c:301) ─────────────────────────────
 *
 * Runs after observer.  In open loop:
 *   - Vq follows velRef directly (q-current PI driven to fixed Iq ref)
 *   - Vd via Id PI to zero
 * In closed loop:
 *   - Speed PI: ref = velRef, meas = SMC OmegaFltred → Iq ref
 *   - Iq PI:    ref = Iq_ref, meas = idq.q          → Vq
 *   - Id PI:    ref = 0,      meas = idq.d          → Vd
 *
 * AN1078 also implements field weakening (qVdRef from FieldWeakening()),
 * we hardcode Id_ref = 0 (no FW). */
static void an_do_control(AN_Motor_T *m, float dt)
{
    if (m->openLoop) {
        /* OPEN LOOP — first-tick init block (changeMode==true) */
        if (m->changeMode) {
            m->changeMode = false;

            m->vqRef = 0.0f;
            m->vdRef = 0.0f;

            AN_SMCReset(&m->smc);

            m->startupLock = 0;
            m->startupRamp = 0.0f;
        }

        /* PWM warmup phase: first AN_WARMUP_TICKS hold Vd=Vq=0 (zero net
         * motor voltage = balanced 50% duty) so gate drivers settle and
         * bootstrap caps top off without inrush.  Skip PI entirely so
         * its integrator stays at 0 — no wind-up during warmup. */
        if (m->startupLock < AN_WARMUP_TICKS) {
            m->vq = 0.0f;
            m->vd = 0.0f;
            /* Force PI integrators to zero so they don't drift on noise */
            m->pi_q.integrator = 0.0f;
            m->pi_d.integrator = 0.0f;
        }
#if AN_OPENLOOP_VF
        else {
            /* OPEN-LOOP V/f: command voltage directly, no current PI.
             * V = boost + lambda*omega (omega = commanded OL speed in
             * startupRamp; 0 during LOCK). Keeps V-BEMF ~= boost so the
             * current self-limits. Vd=0 (all drive on the q-axis of the
             * forced angle). PIs parked so they don't drift. */
            float w = (m->startupRamp >= 0.0f) ? m->startupRamp : -m->startupRamp;
            float v_ol = AN_OL_VF_BOOST_V + AN_MOTOR_LAMBDA * w;
            float vmax = m->vbus * AN_INV_SQRT3 * AN_MAX_VOLTAGE_VECTOR_FRAC;
            if (vmax > 0.1f && v_ol > vmax) v_ol = vmax;
            /* D-AXIS DRAG (2026-07-10): put the drive voltage on the d-axis of
             * the forced frame so the stator field points AT thetaOpenLoop. The
             * rotor magnet locks to that field and follows it as the angle ramps
             * (like microstepping a stepper) -- robust open-loop. q-axis drive
             * points the field 90deg off and the rotor slips out of sync the
             * instant it rotates (observed: locks at align, then silent). */
            m->vd = v_ol;
            m->vq = 0.0f;
            m->pi_q.integrator = 0.0f;
            m->pi_d.integrator = 0.0f;
        }
#else
        else {
            /* Soft-start: ramp iq_ref from 0 to AN_Q_CURRENT_REF_OPENLOOP
             * over AN_IQ_SOFT_START_TICKS counted from end of warmup. */
            uint32_t ramp_tick = m->startupLock - AN_WARMUP_TICKS;
            float iq_ref;
            if (ramp_tick < AN_IQ_SOFT_START_TICKS) {
                float frac = (float)ramp_tick / (float)AN_IQ_SOFT_START_TICKS;
                iq_ref = AN_Q_CURRENT_REF_OPENLOOP * frac;
            } else {
                iq_ref = AN_Q_CURRENT_REF_OPENLOOP;
            }
            float id_ref = 0.0f;

            /* Vbus-aware clamp for ALIGN/OL too (2026-07-10, GarudaESE bench):
             * the init clamp assumes a 24 V nominal bus (~12.6 V). On a 16 V
             * bench that is mod ~1.4 -> duty rails to 100%, the low-side
             * shunts stop conducting, and current feedback goes blind while
             * the PIs stay wound up. Same per-tick clamp as the CL branch. */
            float vmax_ol = m->vbus * AN_INV_SQRT3 * AN_MAX_VOLTAGE_VECTOR_FRAC;
            /* BRING-UP 2026-07-10: during standstill LOCK (rotor not yet
             * turning, no BEMF) cap the voltage hard so a blind/wrong-signed
             * current loop can't wind the q-PI into a near-short and brown
             * out the MCU. Once the OL ramp starts (startupLock>=AN_LOCK_TIME)
             * BEMF exists and the normal clamp applies. See AN_ALIGN_VOLT_CLAMP. */
            if (m->startupLock < AN_LOCK_TIME && vmax_ol > AN_ALIGN_VOLT_CLAMP) {
                vmax_ol = AN_ALIGN_VOLT_CLAMP;
            }
            if (vmax_ol > 0.1f) {
                m->pi_q.outMax =  vmax_ol; m->pi_q.outMin = -vmax_ol;
                m->pi_d.outMax =  vmax_ol; m->pi_d.outMin = -vmax_ol;
            }

#if AN_FOC_BISECT_VF
            /* BISECTION: CL-compiled build, but DRIVE like the proven
             * open-loop V/f (d-axis drag), NOT the current PI. Isolates
             * whether the current-PI code's mere presence (vs its execution)
             * is what wedges the ISR at ~lk700. Mirrors the #if AN_OPENLOOP_VF
             * branch above exactly. iq_ref/id_ref computed but unused here. */
            (void)iq_ref; (void)id_ref;
#if AN_FOC_BISECT_EXEC
            /* STEP 2: EXECUTE the current-PI exactly as the hanging build does
             * (integrators evolve, same FPU work), but DISCARD the result.
             * Isolates execution-of-an_pi_run from application-of-its-voltage. */
            {
                volatile float dq_dump;
                dq_dump = an_pi_run(&m->pi_q, iq_ref, m->iq_meas, dt);
                dq_dump = an_pi_run(&m->pi_d, id_ref, m->id_meas, dt);
                (void)dq_dump;
            }
#endif
            {
                float w = (m->startupRamp >= 0.0f) ? m->startupRamp : -m->startupRamp;
                float v_ol = AN_OL_VF_BOOST_V + AN_MOTOR_LAMBDA * w;
                if (vmax_ol > 0.1f && v_ol > vmax_ol) v_ol = vmax_ol;
                m->vd = v_ol;
                m->vq = 0.0f;
#if !AN_FOC_BISECT_EXEC
                m->pi_q.integrator = 0.0f;
                m->pi_d.integrator = 0.0f;
#endif
            }
#else
            m->vq = an_pi_run(&m->pi_q, iq_ref, m->iq_meas, dt);
            m->vd = an_pi_run(&m->pi_d, id_ref, m->id_meas, dt);
#endif /* AN_FOC_BISECT_VF */
        }
#endif /* AN_OPENLOOP_VF */
    } else {
        /* CLOSED LOOP — proper speed PI with observer feedback.
         *
         * Speed control:
         *   throttle → setpoint (rad/s)
         *   speed PI: ref=setpoint, meas=observer.OmegaFltred → iq_ref
         *   iq_ref clamped at ±AN_OVER_CURRENT_LIMIT
         *
         * Current PI inner loop runs at AN_TS rate (24kHz).
         * Speed PI on top: also runs every tick (same dt, same kp/ki
         * tuning gives same closed-loop behavior). */

        /* Throttle-mapped speed setpoint.  Max speed comes from
         * gspParams.focMaxElecRadS (per-profile, GUI-editable) so the
         * pot range matches what the actual motor can physically reach.
         * Without this, switching profiles in the GUI worked for the
         * motor model but the pot still mapped 0-100% to the previous
         * motor's max — second half of pot had no effect on speed. */
        float max_speed_target = (gspParams.focMaxElecRadS > 0)
                               ? (float)gspParams.focMaxElecRadS
                               : AN_NOMINAL_SPEED_ELEC_RS;
        float speed_target;
        if (m->throttle <= AN_THROTTLE_DEADBAND) {
            speed_target = AN_END_SPEED_ELEC_RS;
        } else {
            float frac = (float)(m->throttle - AN_THROTTLE_DEADBAND)
                       / (4095.0f - (float)AN_THROTTLE_DEADBAND);
            speed_target = AN_END_SPEED_ELEC_RS
                         + frac * (max_speed_target - AN_END_SPEED_ELEC_RS);
        }

        /* Slew velRef toward target — uses CL-specific rate, faster
         * than OL ramp so throttle feels snappy without destabilizing
         * the OL→CL handoff. */
        {
            float diff = speed_target - m->velRef_rad_s;
            float max_step = AN_CL_VELREF_SLEW_RPS2 * AN_TS;
            if (diff >  max_step) m->velRef_rad_s += max_step;
            else if (diff < -max_step) m->velRef_rad_s -= max_step;
            else m->velRef_rad_s = speed_target;
        }
        /* Keep startupRamp synced for SMC LPF (used in OL bootstrap path
         * AND as the fallback Kslf source in step 4b). */
        m->startupRamp = m->velRef_rad_s;

        /* Decoupling feedforward is computed further down, AFTER the current
         * references (iq_ref/id_ref) are known -- it is driven by the
         * REFERENCES, not the measured currents (2026-07-13; see the ff block
         * below and AN_DECOUPLE_EN in an1078_params.h). Capture the OL->CL
         * handoff flag here so the deferred current-PI preload (which must use
         * the same ff that gets applied) can still fire on the first CL tick. */
        bool firstCLtick = m->changeMode;

        /* First-tick CL init: preload speed PI with the OL Iq to be
         * bumpless, AND reset the current PIs and FW integrator.
         *
         * Why reset pi_d/pi_q: during ALIGN+OL the q-PI integrator can
         * wind up significantly (rotor at θ=0 may not accept the
         * commanded Iq, integrator pumps Vq toward the rail).  At CL
         * handoff this stale integrator drives Vq strongly → Vd then
         * rails to compensate → vq_lim drops to zero → motor stuck in
         * rail state until BOARD_PCI fires (observed 2026-04-25 with
         * AN_Q_CURRENT_REF_OPENLOOP=8A and prop load).
         *
         * Why reset id_ref_fw: stale FW from any prior CL session must
         * not leak into a fresh start. */
        if (m->changeMode) {
            m->changeMode = false;
            /* Bumpless OL→CL transition.  Without this the speed PI sees
             * velRef=0 vs measured=ω_handoff (~1099 rad/s) at first CL
             * tick, computes a huge negative error, demands -12A Iq,
             * motor brakes hard immediately, observer can't keep up,
             * desync within 100 ms.  Setting velRef=measured makes the
             * initial error ~0 so Iq stays smooth across the boundary. */
            m->velRef_rad_s = m->smc.OmegaFltred;
            /* 2026-07-11 BENCH: preload LOW (not the 5A OL current) so the CL
             * current loop pulls DOWN toward steady state at handoff instead
             * of holding 5A into the 8A fast-OC. See AN_HANDOFF_IQ_PRELOAD. */
            an_pi_preload(&m->pi_spd, AN_HANDOFF_IQ_PRELOAD);
            /* 2026-07-12 BUMPLESS VOLTAGE HANDOFF. Zeroing the current-PI
             * integrators collapsed Vq from its OL steady-state (~BEMF = lambda*omega,
             * ~2.5V @14k eRPM holding the 5A OL q-current) to ~0 on the first CL
             * tick. With the motor's BEMF then UNOPPOSED, the phase current
             * surged >8A -> AN_FAULTCODE_FASTOC (252) at EVERY OL->CL commit,
             * independent of the observer angle (persisted after the DT-comp
             * fix nulled the bias to st +8deg; idM flipped -0.3 -> +1.5 at trip).
             * Preload the integrators with the last OL Vd/Vq so the applied
             * voltage vector is CONTINUOUS across the boundary; the speed PI
             * then bleeds iq from 5A toward the CL setpoint smoothly. Safe: no
             * load, OL Vq is a real ~BEMF value (mod 0.29), NOT a railed
             * integrator, and pi_q outMax/outMin (vq_lim) clamps it each tick.
             * (The old reset-to-0 guarded the OPPOSITE case -- a stale-HIGH
             * integrator railing under 8A+prop, 2026-04-25 -- which does not
             * apply at no-load.) */
            /* The bumpless current-PI preload (pi_q/pi_d) is DEFERRED to the
             * ff block below, where the reference-based vd_ff/vq_ff exist and
             * can be subtracted to keep the applied vector continuous. */
            m->id_ref_fw       = 0.0f;
        }

        /* Speed PI → Iq ref.  Feedback from observer's REAL Omega. */
        float iq_ref = an_pi_run(&m->pi_spd,
                                 m->velRef_rad_s,
                                 m->smc.OmegaFltred,
                                 dt);
        m->vqRef = iq_ref;

#if AN_OVERMOD_EN
        /* CL runs into the hexagon (overmodulation) for extra top-speed
         * voltage headroom; OL/ALIGN stay linear (AN_MAX_VOLTAGE_VECTOR_FRAC). */
        float vmax = m->vbus * AN_INV_SQRT3 * AN_OVERMOD_FRAC;
#else
        float vmax = m->vbus * AN_INV_SQRT3 * AN_MAX_VOLTAGE_VECTOR_FRAC;
#endif

        /* ── Field weakening ─────────────────────────────────────
         *
         * At ~180k eRPM on this motor, |V| saturates at vmax.  Speed
         * PI keeps demanding more Iq but voltage limiter clamps Vq →
         * speed stops increasing → no path to motor's electrical max.
         *
         * Push Id negative: in rotor frame Vq = R·Iq + ω·L·Id + ω·λ,
         * so Id<0 reduces required Vq, freeing voltage headroom for
         * higher speed.  Field is "weakened" (rotor flux partially
         * cancelled by stator d-axis MMF).
         *
         * Simple integrator: when last tick's |V| exceeded threshold,
         * accumulate id_ref_fw negative.  Decay back to zero when |V|
         * is comfortably below threshold.  Clamped to ID_FW_MAX_NEG. */
        {
            const float FW_TRIGGER = 0.91f;   /* engage just below clamp */
            const float FW_RELEASE = 0.86f;   /* hysteresis — release lower than trigger */
            const float FW_KP_INT  = 341.0f;  /* GAIN-16 FIX ×k (was 150). Produces id_ref_fw
                                                 * (true A) from (mod-thresh)·dt. The FW-loop
                                                 * plant gain Δmod/Δi_true is 1/k of the old
                                                 * Δmod/Δi_fake, so ×k keeps loop gain — hence
                                                 * settling time AND stability margin — identical
                                                 * (NOT a step toward the old 400 limit cycle).
                                                 * Original note: 400 caused a ~30 Hz limit cycle
                                                 * near voltage saturation on A2212. */
            const float FW_DECAY   = 0.995f;
            /* Live-tunable: |Id_FW_max| × 10 from gspParams (deci-amps).
             *   value 0   → ID_FW_MAX_NEG = 0 → FW truly DISABLED (id_ref_fw
             *               clamps to 0, no field weakening current commanded).
             *   value 120 → ID_FW_MAX_NEG = -12 A → standard 2810 setup.
             *   value 200 → ID_FW_MAX_NEG = -20 A → max range; usually limited
             *               by bench supply or AN_OVER_CURRENT_LIMIT before
             *               this is actually reached.
             * NOTE: more FW does NOT always mean more top speed.  Past a
             * point, the supply current limit + Iq-clamp interaction causes
             * top speed to plateau or drop (observed 2026-04-26 with 2810). */
            float id_fw_max_user = (float)gspParams.an1078IdFwMaxDecia * 0.1f;
            float ID_FW_MAX_NEG = -id_fw_max_user;   /* 0 = disabled */
            /* Gate: FW only when motor is actively accelerating forward
             * (iq_ref > some threshold).  Without this, FW pumps in
             * negative Id during stale-integrator startup or coasting,
             * which causes runaway: high Vd → vq_lim collapses → motor
             * stuck in rail (observed 2026-04-25).  Only engage when
             * the speed PI is genuinely demanding forward torque. */
            const float FW_IQ_GATE = 2.27325f;   /* GAIN-16 FIX ×k (was 1.0). iq_ref gate, true amps */

            float v_last = sqrtf(m->vd * m->vd + m->vq * m->vq);
            float mod_now = (vmax > 0.001f) ? v_last / vmax : 0.0f;

            /* Hysteresis: engage above FW_TRIGGER, hold integrated value
             * down to FW_RELEASE, only decay below RELEASE.  Eliminates
             * the limit cycle where mod hovers near 0.91 and FW pumps
             * up/decays each tick.  When in CL operating regime with
             * voltage saturated, FW stays engaged steadily. */
            if (mod_now > FW_TRIGGER && iq_ref > FW_IQ_GATE) {
                m->id_ref_fw -= FW_KP_INT * (mod_now - FW_TRIGGER) * dt;
                if (m->id_ref_fw < ID_FW_MAX_NEG) m->id_ref_fw = ID_FW_MAX_NEG;
            } else if (mod_now < FW_RELEASE) {
                /* Below release threshold → decay.  Between RELEASE and
                 * TRIGGER → hold (no integration, no decay). */
                m->id_ref_fw *= FW_DECAY;
                if (m->id_ref_fw > -0.005f) m->id_ref_fw = 0.0f;
            }
        }
        float id_ref = m->id_ref_fw;

        /* Low-load observer excitation (2026-07-13, see AN_ID_INJECT_MAX_A):
         * near zero torque the SMC loses lock; inject positive d-axis current
         * (no torque) so |I| stays out of the zero-current dead zone. Fade with
         * both load (iq demand) and speed; skip when field weakening is active. */
        if (AN_ID_INJECT_MAX_A > 0.0f && m->id_ref_fw > -0.01f) {
            float iq_abs = an_abs(iq_ref);
            if (iq_abs < AN_ID_INJECT_IQ_KNEE_A) {
                float load_f  = 1.0f - iq_abs / AN_ID_INJECT_IQ_KNEE_A;
                float w       = an_abs(m->smc.OmegaFltred);
                float speed_f = (w >= AN_ID_INJECT_FADE_RADS) ? 0.0f
                              : (1.0f - w / AN_ID_INJECT_FADE_RADS);
                id_ref += AN_ID_INJECT_MAX_A * load_f * speed_f;
            }
        }

        /* ── Dynamic d/q decoupling feedforward (ref-driven, 2026-07-13) ──
         * Cancel the PMSM cross-coupling + BEMF so the current PIs only trim
         * the residual. Driven by the current REFERENCES (iq_ref/id_ref), NOT
         * the measured currents: feeding measured i_dq through the wL cross-gain
         * turned the one-sample delay into positive feedback and formed a
         * period-2 limit cycle at high speed (f_elec -> current-loop BW), which
         * pumped the bus via regen and tripped FASTOC ~64k (bench 2026-07-13).
         * The references are smooth (slew-limited) and add no measurement
         * noise, so the ff keeps its full benefit without the instability. */
        float vd_ff = 0.0f, vq_ff = 0.0f;
#if AN_DECOUPLE_EN
        {
            float w   = m->smc.OmegaFltred;                 /* elec rad/s */
            float Ls  = (gspParams.focLsMicroH  > 0)
                      ?  gspParams.focLsMicroH  * 1.0e-6f : AN_MOTOR_LS;
            float lam = (gspParams.focKeUvSRad > 0)
                      ?  gspParams.focKeUvSRad * 1.0e-6f : AN_MOTOR_LAMBDA;
            vd_ff = AN_DECOUPLE_FRAC * ( -(w * Ls * iq_ref) );
            vq_ff = AN_DECOUPLE_FRAC * (  (w * Ls * id_ref) + (w * lam) );
        }
#endif

        /* Bumpless OL->CL current-PI preload, deferred to here so it uses the
         * ref-based ff. Preloading with (last OL v - ff) makes the applied
         * vector (pi_out + ff) continuous across the handoff. See the changeMode
         * block above for the full rationale. */
        if (firstCLtick) {
            an_pi_preload(&m->pi_q, m->vq - vq_ff);
            an_pi_preload(&m->pi_d, m->vd - vd_ff);
        }

        /* d-axis: reserve budget for the ff so PI+ff stays within +-vmax and
         * the PI anti-windup clamp reflects the real remaining headroom. */
        m->pi_d.outMax =  vmax - vd_ff;
        m->pi_d.outMin = -vmax - vd_ff;
        m->vd = an_pi_run(&m->pi_d, id_ref, m->id_meas, dt) + vd_ff;

        float vd_sq = m->vd * m->vd;
        float vmax_sq = vmax * vmax;
        float vq_lim_sq = vmax_sq - vd_sq;
        float vq_lim = (vq_lim_sq > 0.0f) ? sqrtf(vq_lim_sq) : 0.0f;
        /* q-axis: same budget reservation for the (w*lambda + w*L*id) ff. */
        m->pi_q.outMax =  vq_lim - vq_ff;
        m->pi_q.outMin = -vq_lim - vq_ff;
        m->vq = an_pi_run(&m->pi_q, iq_ref, m->iq_meas, dt) + vq_ff;
    }
}

/* ── CalculateParkAngle (port of pmsm.c:712) ────────────────────
 *
 * Open loop: lock then ramp; capture Theta_error at handoff.
 * Closed loop: bleed Theta_error toward zero at 0.05° per tick
 * subject to (transCounter == 0). */
static void an_calc_park_angle(AN_Motor_T *m)
{
    if (m->openLoop) {
        /* LOCK: align rotor.  startupRamp held at zero.
         *
         * IMPORTANT: AN1078 applies Iq (not Id) during alignment with
         * synth=0.  Iq at synth=0 means current is on stator β-axis →
         * rotor d-axis pulls to β = stator angle π/2.  After alignment,
         * rotor d sits at stator β, NOT stator α.
         *
         * To make OL ramp start with rotor d aligned to synth d (so the
         * Iq-q current generates maximum forward torque), the synth
         * angle must be set to π/2 at the LOCK→RAMP transition.  Then
         * synth d at stator angle π/2 = rotor d position → aligned.
         *
         * Without this offset, OL starts at synth=0 with rotor d at
         * synth q (90° offset).  Current is parallel to rotor d → ZERO
         * initial torque.  With prop drag, prop friction nudges rotor
         * out of this dead zone and motor catches up.  Without prop, low
         * inertia rotor stays stuck and OL ramp doesn't follow.  Fixed
         * 2026-04-26 after observing A2212 stuck-in-OL with no prop. */
        if (m->startupLock < AN_LOCK_TIME) {
            m->startupLock++;
#if !AN_OPENLOOP_VF
            if (m->startupLock == AN_LOCK_TIME) {
                /* End of alignment — offset synth angle to match where
                 * rotor actually settled (stator β-axis). */
                m->thetaOpenLoop = AN_PI * 0.5f;
            }
#else
            /* D-axis drag: align locks rotor d AT thetaOpenLoop (0), so the
             * ramp continues from the same angle — NO 90deg jump. */
#endif
        }
        /* RAMP: accelerate forced angle until END_SPEED reached. */
        else if (m->startupRamp < AN_END_SPEED_ELEC_RS) {
            m->startupRamp += AN_OL_RAMP_RATE_RPS2 * AN_TS;
            if (m->startupRamp > AN_END_SPEED_ELEC_RS)
                m->startupRamp = AN_END_SPEED_ELEC_RS;
            m->mode = AN_MODE_OPEN_LOOP;
        }
        /* OL→CL handoff with proper observer gate.
         *
         * After tuning Kslide=2.5V + MaxSMCError=1A + KslfScale=3*Ts +
         * KslfMin=0.05, observer locks on 2810 in OL.  BEMF magnitude
         * matches λ·ω theory (~0.25 V at 366 rad/s).  Confidence stays
         * at 1.0 reliably during OL.
         *
         * Gate: BEMF magnitude must be ≥ 80% of theoretical (λ·ω) for
         * AN_HANDOFF_DWELL_TICKS consecutive ticks.  This filters brief
         * noise spikes and ensures observer is actually tracking before
         * we trust its angle. */
        else {
#if AN_OPENLOOP_VF || AN_FOC_IF_ONLY
            /* OPEN-LOOP V/f, or I/f-ONLY FOC stage: the SMC observer is not
             * run (blind in V/f; skipped in I/f-only), so NEVER hand off to
             * closed loop. Hold at END_SPEED in forced commutation.
             * (startupRamp is pinned at END_SPEED by the RAMP branch above.) */
            (void)0;
#else
            /* Handoff gate: SMC's BEMF magnitude must be ≥ threshold pct of
             * theoretical (λ·ω) and sustained for AN_HANDOFF_DWELL_TICKS.
             *
             * Threshold relaxed 80% → 50% on 2026-04-26 to handle the
             * prop-load case at higher idle (1500 RPM mech).  At low motor
             * freq the LPF still has significant attenuation, so observed
             * BEMF magnitude can dip below 0.8·λω even when motor tracks
             * the synth angle correctly.  50% is enough margin to confirm
             * observer lock without missing handoff under prop drag.
             *
             * Dwell counter still enforces the minimum sustained time —
             * a brief 50% dip during OL ramp won't trigger handoff. */
            float bemf_mag = sqrtf(m->smc.EalphaFinal * m->smc.EalphaFinal
                                 + m->smc.EbetaFinal  * m->smc.EbetaFinal);
            /* λ from gspParams (per-profile, GUI-editable) with fallback
             * to compile-time default if EEPROM not yet loaded. */
            float lambda = (gspParams.focKeUvSRad > 0)
                         ? gspParams.focKeUvSRad * 1.0e-6f
                         : AN_MOTOR_LAMBDA;
            float bemf_expected = lambda * m->startupRamp;
            /* Relaxed 50%→30% on 2026-04-26 for A2212.  Higher-Rs motors
             * have less OL torque margin → rotor slips synth angle under
             * prop drag → real BEMF lower than λ·ω_command.  Plus LPF
             * cascade attenuates ~20% at low motor freq.  30% still
             * rejects "no signal at all" while accepting partial slip. */
            /* Threshold lowered 0.30 → 0.20 on 2026-04-26 after observing
             * that conf naturally sits at 0.33-0.36 during OL even when
             * motor is properly tracking — so 30% is right at the edge
             * and handoff fires only by chance.  Working morning test
             * (foc_20260426_160120.csv) had conf bouncing 0.29-0.44 with
             * occasional crossings above 0.30 → handoff sometimes fires.
             * Failed evening test had conf pinned at 0.34 → never
             * sustained 53ms above 0.30 → stuck.  20% is well below the
             * natural noise floor → handoff fires reliably. */
            float bemf_min = bemf_expected * 0.2f;

            /* SPEED-CONVERGENCE gate: the observer's filtered speed must agree
             * with the known forced speed before we trust its angle for CL.
             * Without this, handoff fires on a lagging speed estimate (bench:
             * OmegaFltred 105-472 vs forced 1401) -> CL desync -> current spike
             * -> bus sag -> brownout. If never converges -> hold in OL safely.
             *
             * 2026-07-10 BUG FIX: this gate previously read m->smc.OmegaFltred,
             * but that field is CLOBBERED with m->startupRamp every tick in OL
             * (section 4b, ~line 810) BEFORE an_do_control() runs -> omega_err
             * was ALWAYS 0 -> speed_converged ALWAYS true -> the gate was a
             * structural no-op and never blocked a bad handoff.  Read the
             * observer's NATIVE, un-clobbered PLL speed instead. */
            float omega_err = m->smc.pll.omega_est - m->startupRamp;
            if (omega_err < 0.0f) omega_err = -omega_err;
            int speed_converged = (m->startupRamp > 1.0f)
                && (omega_err < AN_HANDOFF_SPEED_TOL_FRAC * m->startupRamp);

            if (bemf_mag >= bemf_min && speed_converged) {
                m->handoff_dwell++;
            } else {
                m->handoff_dwell = 0;
            }

            if (m->handoff_dwell >= AN_HANDOFF_DWELL_TICKS) {
                /* ANGLE gate (2026-07-11 MCLV-port): the dwell above only
                 * proves the observer is TRACKING (BEMF present, speed
                 * matched) -- it does NOT pick a good phase to commit. Bench
                 * (MCLV): committing at |thetaError| ~30-42deg HOLDS, ~68-77deg
                 * DESYNCS -> OC. So only COMMIT on a tick where the captured
                 * offset is inside AN_HANDOFF_ANGLE_TOL_RAD; if the rotor is
                 * mid-hunt, HOLD at end-speed and retry next good-phase tick. */
                float theta_err =
                    an_wrap_delta(m->thetaOpenLoop - m->smc.Theta);
                if (an_abs(theta_err) < AN_HANDOFF_ANGLE_TOL_RAD) {
                    m->changeMode = true;
                    m->openLoop = false;
                    m->thetaError = theta_err;
                    m->mode = AN_MODE_CLOSED_LOOP;
                    m->handoff_dwell = 0;
                }
                /* else: observer tracking but rotor mid-hunt -- hold at
                 * end-speed, keep dwell latched, retry next tick. */
            }
            /* else: stay in OL, hold at end-speed. */
#endif /* AN_OPENLOOP_VF */
        }

        /* Advance forced angle */
        m->thetaOpenLoop += m->startupRamp * AN_TS;
        m->thetaOpenLoop = an_wrap_2pi(m->thetaOpenLoop);
    } else {
#if AN_CL_FORCED_ANGLE || AN_CL_ANGLE_BLEND
        /* Keep the forced angle rotating at the CL commanded speed (velRef,
         * mirrored into startupRamp at line ~454). Under AN_CL_FORCED_ANGLE it
         * is the drive angle; under AN_CL_ANGLE_BLEND it is the k=0 anchor of
         * the forced->observer crossfade. */
        m->thetaOpenLoop += m->startupRamp * AN_TS;
        m->thetaOpenLoop = an_wrap_2pi(m->thetaOpenLoop);
#endif
        /* CL: bleed Theta_error, paced by transCounter (mod TRANS_STEPS) */
        if (m->transCounter == 0) {
            if (an_abs(m->thetaError) > AN_THETA_ERROR_BLEED_RAD) {
                if (m->thetaError < 0.0f) {
                    m->thetaError += AN_THETA_ERROR_BLEED_RAD;
                } else {
                    m->thetaError -= AN_THETA_ERROR_BLEED_RAD;
                }
            } else {
                m->thetaError = 0.0f;
            }
        }
    }

    /* transCounter wraps every TRANSITION_STEPS ticks */
    m->transCounter++;
    if (m->transCounter >= AN_TRANSITION_STEPS) m->transCounter = 0;
}

/* ── ADC offset calibration ────────────────────────────────── */

static void an_offset_cal(AN_Motor_T *m, uint16_t ia_raw, uint16_t ib_raw,
                          uint16_t iw_raw)
{
    if (m->cal_done) return;
    m->cal_accum_a += ia_raw;
    m->cal_accum_b += ib_raw;
    m->cal_accum_w += iw_raw;   /* A1: auto-zero the W leg too */
    m->cal_count++;
    if (m->cal_count >= AN_CAL_SAMPLES) {
        m->ia_offset = (float)(m->cal_accum_a >> 10);  /* /1024 */
        m->ib_offset = (float)(m->cal_accum_b >> 10);
        m->iw_offset = (float)(m->cal_accum_w >> 10);
        m->cal_done = true;
    }
}

/* ── Fast-loop tick (port of _ADCInterrupt body, dual-shunt path) ─ */

void AN_MotorFastTick(AN_Motor_T *m,
                      uint16_t ia_raw, uint16_t ib_raw, uint16_t iw_raw,
                      uint16_t vbus_raw, uint16_t throttle,
                      float *da, float *db, float *dc)
{
    /* Default: 50% duty (zero net voltage). */
    *da = 0.5f;
    *db = 0.5f;
    *dc = 0.5f;

    /* Stash inputs */
    m->throttle = throttle;
    m->vbus = an_raw_to_vbus(vbus_raw);

    /* When stopped, run offset cal and return idle. */
    if (!m->runMotor) {
        an_offset_cal(m, ia_raw, ib_raw, iw_raw);
        return;
    }

    if (m->mode == AN_MODE_FAULT) {
        return;  /* outputs at 50% (zero V) — caller may override to disable */
    }

    /* ── 1. Phase currents (ADC → amps) ──────────────────── */
    m->ia = an_raw_to_amps(ia_raw, m->ia_offset);      /* U (dsPIC OA1) */
    m->ib = an_raw_to_amps(ib_raw, m->ib_offset);      /* V (dsPIC OA2) */
    m->iw = an_raw_to_amps_w(iw_raw, m->iw_offset);    /* W (ATA CSA) — A1 */

    /* ── 1b. A1 best-2-of-3 leg selection ─────────────────
     * The leg with the largest (most high-side-on) duty had the shortest
     * low-side shunt window this tick, so its reading is the least trustworthy.
     * If it exceeds AN_CLARKE_DUTY_TH, reconstruct it from the other two via
     * Kirchhoff (iu+iv+iw=0). Only U or V matter to the downstream Clarke —
     * if W is the offender, the Clarke already consumes the reliable U,V pair.
     * Uses the PREVIOUS tick's duty (the window that produced these samples).
     * Overwriting m->ia/m->ib here means the OC latch, Clarke and DT-comp all
     * consume the trusted currents with no further change. */
    m->clarke_drop = 0;
#if AN_CLARKE_BEST2OF3
    if (!m->openLoop && m->cal_done) {
        float du = m->da_prev, dv = m->db_prev, dw = m->dc_prev;
        if (du >= dv && du >= dw && du > AN_CLARKE_DUTY_TH) {
            m->ia = -(m->ib + m->iw);   /* U window collapsed → from V,W */
            m->clarke_drop = 1;
        } else if (dv >= du && dv >= dw && dv > AN_CLARKE_DUTY_TH) {
            m->ib = -(m->ia + m->iw);   /* V window collapsed → from U,W */
            m->clarke_drop = 2;
        } else if (dw >= du && dw >= dv && dw > AN_CLARKE_DUTY_TH) {
            m->clarke_drop = 3;         /* W dropped; U,V already the trusted pair */
        }
    }
#endif

    /* HARDENING (2026-07-11): fast per-phase OC latch in CL. A bad observer
     * handoff slams the phase current; without this the tick drives a huge
     * vector -> ISR wedge / bus brownout (needs power-cycle). Trip to a safe
     * zero-V FAULT; every subsequent tick then returns 50% duty via the
     * AN_MODE_FAULT check above. Only active in CL (OL/align regulate to ~5A). */
    if (!m->openLoop) {
        float ia_abs = (m->ia < 0.0f) ? -m->ia : m->ia;
        float ib_abs = (m->ib < 0.0f) ? -m->ib : m->ib;
        if (ia_abs > AN_FASTCHK_OC_LIM_A || ib_abs > AN_FASTCHK_OC_LIM_A) {
            m->mode      = AN_MODE_FAULT;
            m->runMotor  = false;
            m->faultCode = AN_FAULTCODE_FASTOC;
            return;   /* da/db/dc remain 0.5 = zero net voltage */
        }
    }

    /* ── 2. Clarke ───────────────────────────────────────── */
    an_clarke(m->ia, m->ib, &m->i_alpha, &m->i_beta);

    /* ── 3. Park (using PREVIOUS tick's commutation angle) ─
     * AN1078 uses sincosTheta computed at the END of the previous
     * tick (line 620), so id/iq here is "what we measured given
     * the angle we WERE driving."  We replicate by carrying the
     * previous theta_drive in m->theta_drive. */
    {
        float sin_t = sinf(m->theta_drive);
        float cos_t = cosf(m->theta_drive);
        an_park(m->i_alpha, m->i_beta, sin_t, cos_t,
                &m->id_meas, &m->iq_meas);
    }

    /* ── 4. Feed observer ────────────────────────────────── */
#if !AN_OPENLOOP_VF && !AN_FOC_IF_ONLY
    /* GAIN-16 FIX: the observer plant (Gsmopos=Ts/Ls) + its tuning (Kslide,
     * MaxSMCError) were validated against the OLD fake-scale currents. i_alpha/
     * i_beta are now TRUE amps (k× larger). AN_OBS_CURRENT_COMPAT was retired to
     * 1.0 (2026-07-14, paired with MaxSMCError×k) so the observer runs on true
     * amps — the multiply below is now a no-op revert knob (set 0.43991 to
     * restore the old validated units). Drive/telemetry stay true. */
    m->smc.Ialpha = m->i_alpha * AN_OBS_CURRENT_COMPAT;
    m->smc.Ibeta  = m->i_beta  * AN_OBS_CURRENT_COMPAT;
    /* 2026-07-11 DEAD-TIME COMP (bench-confirmed -36deg no-load observer angle
     * bias = uncompensated ATA6847 dead-time; MCLV compensates at the duty
     * level, we did not). Feed the observer the TRUE applied voltage = commanded
     * - dead-time loss in the direction of phase current. This corrects ONLY the
     * voltage the observer sees; drive/torque is unchanged. Tune AN_DT_COMP_FRAC
     * to null st= (thetaError) at no-load; flip its sign if st= moves the wrong
     * way; 0 disables. See AN_DT_COMP_FRAC. */
    {
        float dtc = m->vbus * AN_DT_COMP_FRAC;
        float sa = (m->i_alpha >  AN_DT_COMP_IBAND) ?  1.0f
                 : (m->i_alpha < -AN_DT_COMP_IBAND) ? -1.0f
                 :  m->i_alpha / AN_DT_COMP_IBAND;
        float sb = (m->i_beta  >  AN_DT_COMP_IBAND) ?  1.0f
                 : (m->i_beta  < -AN_DT_COMP_IBAND) ? -1.0f
                 :  m->i_beta  / AN_DT_COMP_IBAND;
        m->smc.Valpha = m->v_alpha - dtc * sa;   /* from prev tick's inv Park */
        m->smc.Vbeta  = m->v_beta  - dtc * sb;
    }
#if FEATURE_AN_STA
    AN_STA_Position_Estimation(&m->smc);
#else
    AN_SMC_Position_Estimation(&m->smc);
#endif
    /* HARDENING (2026-07-11): if the observer diverged (non-finite), zero its
     * outputs so the drive angle and speed PI never see NaN/Inf. */
    if (!(m->smc.Theta > -1.0e6f && m->smc.Theta < 1.0e6f))
        m->smc.Theta = 0.0f;
    if (!(m->smc.OmegaFltred > -1.0e9f && m->smc.OmegaFltred < 1.0e9f))
        m->smc.OmegaFltred = 0.0f;
#else
    /* OPEN-LOOP V/f: the SMC observer is unused (commutation is the
     * forced angle) AND diverges on blind current -> in prior runs it
     * went non-finite ~171 ms in and wedged the ISR. Skip it entirely. */
    (void)0;
#endif

    /* ── 4b. SMC LPF tuning — pin Kslf to commanded speed (startupRamp).
     *
     * startupRamp tracks velRef (the slewed speed setpoint from
     * throttle).  Using it for Kslf gives a stable, predictable LPF
     * cutoff that scales with intended operating speed.
     *
     * Why not use observer's own OmegaFltred for Kslf?  Tested — caused
     * positive feedback at high speed: motor accelerates → observer
     * reports higher → Kslf grows → LPF lets through more BEMF →
     * observer angle improves → motor accelerates more → no control.
     *
     * OmegaFltred is also overridden in OL (bootstrap), but in CL we
     * leave the observer's native value alone for telemetry/PI
     * feedback. */
    if (m->openLoop) {
        m->smc.OmegaFltred = m->startupRamp;   /* OL bootstrap */
    }
    {
        float k = m->startupRamp * m->smc.KslfScale;
        if (k < m->smc.KslfMin)      k = m->smc.KslfMin;
        if (k > AN_SMC_KSLF_MAX)     k = AN_SMC_KSLF_MAX;
        m->smc.Kslf      = k;
        m->smc.KslfFinal = k;
    }

    /* ── 5. Run control (PI loops) ──────────────────────── */
    an_do_control(m, AN_TS);

    /* ── 6. Compute commutation angle (OL ramp or CL bleed) ─ */
    an_calc_park_angle(m);

    /* ── 7. Choose theta_drive: OL angle or (SMC + Theta_error) ─ */
    if (m->openLoop) {
        m->theta_drive = m->thetaOpenLoop;
    } else {
#if AN_CL_ANGLE_BLEND
        /* LOAD-ROBUST SENSORLESS: speed-scheduled crossfade forced->observer.
         * k = 0 below LO (pure forced, stable at idle where BEMF SNR is poor),
         *     1 above HI (pure observer = true rotor angle -> holds under load),
         * linear between. Scheduled on startupRamp (commanded elec speed --
         * clean & monotonic) so k never chatters on observer noise.
         *
         * thetaObs already folds in thetaError, the handoff offset that bleeds
         * to 0 (section ~line 717); so at handoff thetaObs == thetaOpenLoop and
         * the crossfade starts seamless regardless of k.
         *
         * Blend the SHORTEST-ARC delta (an_wrap_delta), never a raw angle lerp:
         * lerping 350deg and 10deg would sweep through 180deg. */
        float thetaObs = an_wrap_2pi(m->smc.Theta + m->thetaError);
        float kb;
        if (m->startupRamp <= AN_BLEND_LO_ELEC_RS) {
            kb = 0.0f;
        } else if (m->startupRamp >= AN_BLEND_HI_ELEC_RS) {
            kb = 1.0f;
        } else {
            kb = (m->startupRamp - AN_BLEND_LO_ELEC_RS)
               / (AN_BLEND_HI_ELEC_RS - AN_BLEND_LO_ELEC_RS);
        }
        float dth = an_wrap_delta(thetaObs - m->thetaOpenLoop);
        m->theta_drive = an_wrap_2pi(m->thetaOpenLoop + kb * dth);
#elif AN_CL_FORCED_ANGLE
        /* BISECTION: drive the forced/ramped angle even in CL. */
        m->theta_drive = m->thetaOpenLoop;
#else
        m->theta_drive = an_wrap_2pi(m->smc.Theta + m->thetaError);
#endif
    }

    /* ── 8. Inverse Park: (vd, vq) → (vα, vβ) ──────────── */
    {
        float theta_out = m->theta_drive;
#if AN_DELAYCOMP_EN
        /* D1: advance the OUTPUT angle by w*Ts*frac so the vector the inverter
         * applies next PWM update lands on the rotor's future position, not its
         * past one. w = observer speed; scales with speed so low-speed is
         * untouched. Only in CL (OL drives its own forced angle). */
        if (!m->openLoop) {
            theta_out = an_wrap_2pi(theta_out +
                        AN_DELAYCOMP_FRAC * m->smc.OmegaFltred * AN_TS);
        }
#endif
        float sin_t = sinf(theta_out);
        float cos_t = cosf(theta_out);
        an_inv_park(m->vd, m->vq, sin_t, cos_t, &m->v_alpha, &m->v_beta);
    }

    /* ── 9. SVPWM → duty cycles ─────────────────────────── */
    an_svpwm(m->v_alpha, m->v_beta, m->vbus, da, db, dc);

#if AN_OUT_DT_COMP_EN
    /* ── 9b. Output-side dead-time compensation (ATA6847 ~700ns) ──
     * Add back the volt-seconds each leg loses to dead-time, in the
     * direction opposing its phase current.  MCLV does this at the duty
     * level; GarudaESE did not -> rougher no-load current.  ic = -(ia+ib)
     * (Kirchhoff).  softsign over a deadband kills sign chatter at the
     * phase-current zero crossings.  See AN_OUT_DT_COMP_FRAC for tuning. */
    {
        float ic   = -(m->ia + m->ib);
        float band = AN_OUT_DT_COMP_IBAND;
        float sa = (m->ia >  band) ?  1.0f : (m->ia < -band) ? -1.0f : m->ia / band;
        float sb = (m->ib >  band) ?  1.0f : (m->ib < -band) ? -1.0f : m->ib / band;
        float sc = (ic    >  band) ?  1.0f : (ic    < -band) ? -1.0f : ic    / band;
        *da += AN_OUT_DT_COMP_FRAC * sa;
        *db += AN_OUT_DT_COMP_FRAC * sb;
        *dc += AN_OUT_DT_COMP_FRAC * sc;
        if (*da < 0.0f) *da = 0.0f; if (*da > 1.0f) *da = 1.0f;
        if (*db < 0.0f) *db = 0.0f; if (*db > 1.0f) *db = 1.0f;
        if (*dc < 0.0f) *dc = 0.0f; if (*dc > 1.0f) *dc = 1.0f;
    }
#endif

    /* A1: remember this tick's FINAL commanded duty — it is the low-side
     * window that will produce NEXT tick's current samples, so the best-2-of-3
     * selector reads it from here. */
    m->da_prev = *da;
    m->db_prev = *db;
    m->dc_prev = *dc;
}
