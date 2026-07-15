/**
 * @file  an1078_params.h
 * @brief AN1078 float port — motor + control constants.
 *
 * One-to-one float translation of Microchip AN1078 `userparms.h`,
 * tuned for PRODRONE 2810 1350KV @ 24V on the AK board.
 *
 * Naming convention:
 *   AN_*  = direct port of an AN1078 constant (same role, float units)
 *
 * Units throughout: SI (volts, amps, seconds, radians, rad/s electrical).
 * No Q15 normalization.
 */
#ifndef AN1078_PARAMS_H
#define AN1078_PARAMS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

/* ── Hardware references (mirror of garuda_foc_params.h, kept local
 *    to AN1078 module so it can be tuned independently) ─────────── */

/** ═══════════════════════════════════════════════════════════════════════
 *  GAIN-16 CURRENT-SCALE FIX (2026-07-14) — schematic-verified, production.
 *
 *  The dsPIC OA1/OA2 current-sense amps are NON-INVERTING with gain
 *  1 + Rf/Rin = 1 + 12k/(330+470) = 1 + 12k/800 = 16.0  (EV60Y51A sheet
 *  "BRIDGE & SENSING": R43=330R + R49=470R in series, R54=12k feedback;
 *  phase V identical R44/R45/R52/R53/R55). The ATA6847 CSA (Iw, Ibus) is
 *  internal gain 16 (CSCR=0x03, hal_ata6847.c), shunt direct to pins.
 *  Shunt = 2 mOhm (sheet note). ALL four channels: 16 × 2mOhm = 32 mV/A ->
 *  A/cnt = 3.3/(4095·16·0.002) = 0.025183 (39.7 cnt/A), rails ±51.6 A.
 *
 *  The old 0.011078 assumed gain 36.36 (= 12k/330, dropping the 470R and
 *  the non-inverting +1) -> every current read 2.2732× LOW. Bench-confirmed
 *  uniformly (OL+CL, no-load+load) vs PSU. This fix moves the WHOLE control
 *  chain into real amps; all coupled constants below are rescaled by
 *      k = 36.3636 / 16 = 2.27325
 *  (×k for amp thresholds/refs, ÷k for the V/A current-PI gains) so the
 *  drive is behaviourally identical while every value now reads true amps.
 *  Two physics points (observer input, decoupling ff) were formerly gated by
 *  staging knobs AN_OBS_CURRENT_COMPAT and AN_DECOUPLE_FRAC; both were retired
 *  to their final 1.0 on 2026-07-14 (full physical consistency, bench-verified)
 *  and remain only as revert knobs. See the per-constant notes. ═══════════ */
#define AN_CUR_SCALE_FIX_K          2.27325f   /* 36.3636/16 — doc/reference only */
#define AN_CURRENT_A_PER_COUNT      0.025183f  /* dsPIC OA1/OA2, gain 16, 2 mOhm ->
                                             * 32 mV/A; A/cnt = 3.3/(4095*16*0.002).
                                             * Rails +/-51.6 A. Was 0.011078 (bad
                                             * gain 36.36). Schematic-verified. */
#define AN_CURRENT_INVERT           1                /* GarudaESE 2026-07-10: ROOT CAUSE of the
                                             * FOC ISR hang. Bench: cmd +vd / meas -id at
                                             * standstill. Physics (Vd=Rs*id) says +vd MUST
                                             * give +id, so the feedback is INVERTED -> the
                                             * current PI (err=ref-meas) becomes POSITIVE
                                             * feedback -> vd runs to the clamp -> HW OC trip
                                             * -> ISR dies. Earlier note read the same "cmd+/
                                             * meas-" evidence but wrongly set 0. Flipping to 1
                                             * makes +vd->+id_meas -> negative feedback ->
                                             * stable loop (matches the working AN1078 ref). */
#define AN_ADC_MIDPOINT             2048

/** ── A1: W-phase current (ATA6847 op-amp, AD3CH3) ─────────────────
 *  The W leg is measured through the ATA CSA, NOT the dsPIC OA1/OA2, so it
 *  has its OWN gain/sign/offset. Bench calibration (2026-07-14, telemetry-only
 *  A2 build: regress iw_ref = -(focIa+focIb) vs raw Iw over a 34.6k CL run,
 *  robust LS, R^2 = 0.992 over 511 pts): gain = 0.010233 A/count (0.924x the
 *  dsPIC scale — must NOT be shared), INVERTED like the dsPIC legs, rest offset
 *  ~2072 counts. The W leg stayed linear (R^2 >= 0.99) through 84% duty, i.e.
 *  it is trustworthy exactly where the two-shunt (Iu/Iv) window collapses. */
#define AN_CURRENT_W_A_PER_COUNT    0.023263f  /* was 0.010233 ×k. ATA gain 16;
                                             * keeps the bench-regressed 0.924× ratio
                                             * to the dsPIC legs (R^2=0.992). */
#define AN_CURRENT_W_INVERT         1
#define AN_CURRENT_W_MIDPOINT       2072     /* fallback until IDLE auto-zero */

/** ── DC-bus current reconstruction gain ───────────────────────────
 *  Ibus is RECONSTRUCTED from dq power: Idc = 1.5*(vd*id+vq*iq)/Vbus. Now that
 *  the phase-current scale is correct at source (gain-16 fix), id/iq are true
 *  amps, so this is 1.0. (Was 2.0 as a display-only compensation for the 2.27×
 *  under-scale, before that scale was fixed globally.) */
#define AN_IBUS_RECON_GAIN          1.0f

/** ── DC-bus current display IIR (single-pole low-pass) ─────────────
 *  The instantaneous reconstruction 1.5*(vd*id+vq*iq)/Vbus jitters per ISR
 *  (two-shunt sense noise, amplified at high duty), so the raw focIbus reads
 *  ±1-2A of ripple around its mean. A one-pole filter y += COEF*(x - y) run at
 *  the 45 kHz ISR rate smooths it to a steady average for display, with no
 *  effect on control (focIbus is telemetry-only; the real SW-OC watches the
 *  calibrated phase currents, not this).
 *    tau = AN_TS / COEF = 22.2us / 0.002 = 11.1 ms  (-3 dB ~ 14 Hz).
 *  Fast enough to follow a throttle step in <50 ms, slow enough to average out
 *  the per-cycle ripple. Raise COEF for a snappier/noisier reading, lower it
 *  for a smoother/laggier one. */
#define AN_IBUS_FILT_COEF           0.002f

/** ── Observer current-input compat (retired staging knob → 1.0) ────
 *  The sliding-mode observer's plant model (Gsmopos = Ts/Ls) natively works in
 *  TRUE amps, but it was tuned/validated (Kslide, MaxSMCError) against the old
 *  fake-scale currents. Feeding it the true (k×-larger) currents changes its
 *  operating regime. Formerly (flash-1) the observer input was scaled back to
 *  the old units by 1/k with MaxSMCError=1.0 to hold behaviour byte-identical.
 *  That staging is RETIRED (2026-07-14): the observer now runs on TRUE amps —
 *  this is 1.0, PAIRED with AN_SMC_MAX_LINEAR_ERR 1.0 -> 2.27325 (×k) so Z's
 *  linear region spans the same physical current-error range. It ONLY scales
 *  what the observer sees — drive currents/telemetry stay true. Revert this
 *  pair to 0.43991/1.0 if bench observer lock ever degrades. */
#define AN_OBS_CURRENT_COMPAT       1.0f   /* was 0.43991 (=1/k); retired to true-amp observer (paired w/ MaxLinearErr×k) */

/** ── A1: best-2-of-3 Clarke ───────────────────────────────────────
 *  At high duty the driven leg's low-side shunt conducts only briefly -> its
 *  sample window collapses -> its dsPIC current reading goes noisy -> the SMO's
 *  reconstructed BEMF (hence observer confidence) droops (bench: conf 0.65->0.33
 *  above ~56k). We now measure ALL three phases, so each tick we DROP whichever
 *  leg has the largest (most high-side-on) duty and reconstruct it from the
 *  other two via Kirchhoff (iu+iv+iw=0). The Clarke then only ever consumes
 *  legs whose shunt window was open.
 *
 *  GATED by AN_CLARKE_DUTY_TH: below the threshold every shunt window is wide
 *  so we keep the PROVEN 2-shunt path (Iu,Iv) byte-for-byte; reconstruction
 *  engages ONLY on legs above the threshold = exactly the high-duty regime that
 *  was rough. So low/mid-speed behaviour is unchanged from the 56k build and
 *  the fix is isolated to where the problem lives. Revert with AN_CLARKE_BEST2OF3 0. */
#define AN_CLARKE_BEST2OF3          1
#define AN_CLARKE_DUTY_TH           0.80f    /* engage reconstruction above 80% leg duty */

/** Bus voltage scale (V per ADC count).  V_per_count = Vref·divider/full_scale
 *  = 3.3 × 23.2 / 4095 ≈ 0.01870 V/count. */
#define AN_VBUS_V_PER_COUNT         0.0104762f /* GarudaESE: 13:1 divider (24k/2k),
                                             * 42.9 V FS -> 42.9/4095. (MCLV was
                                             * 0.01870189 @23.2:1.) Ref-FW verified. */

/* ── Loop timing ────────────────────────────────────────────────── */

/** ADC ISR runs at PWM rate.  PWMFREQUENCY_HZ in garuda_config.h.
 *  Currently 45 kHz (production-friendly compromise from 60 kHz).
 *  AN_FS_HZ MUST match PWMFREQUENCY_HZ — F_PLANT/G_PLANT/KSLF_SCALE
 *  all derive from AN_TS, and a mismatch causes the SMC current model
 *  to be wrong by FS_real/FS_assumed.  Earlier 24kHz value with 40-60
 *  kHz hardware caused G_PLANT 67% over-aggressive → observer
 *  destabilized at ~85k eRPM. */
#define AN_FS_HZ                    45000.0f
#define AN_TS                       (1.0f / AN_FS_HZ)

/** Speed loop / observer averaging period in fast-loop ticks.
 *  AN1078: SPEEDLOOPFREQ = 1000 Hz.  At 45 kHz: 45 ticks → 1 kHz. */
#define AN_IRP_PERCALC              45

/** Theta-error transition pacing: AN1078 uses TRANSITION_STEPS = IRP_PERCALC/4. */
#define AN_TRANSITION_STEPS         (AN_IRP_PERCALC / 4)

/** Speed-feedback LPF coefficient (2026-07-11 MCLV-port), used for OmegaFltred
 *  in an1078_smc.c: OmegaFltred += COEF*(pll.omega_est - OmegaFltred). 0.05 ~=
 *  a 20-tick time constant; kills the +/-2000 eRPM handoff speed noise that
 *  otherwise winds the speed PI to an OC current spike. Larger = less
 *  filtering/less lag. This is what makes observer-angle drive stable on MCLV. */
#define AN_OMEGA_FILT_COEF          0.05f

/* ── Motor (PRODRONE 2810 1350KV @ 24V) ─────────────────────────
 *
 * Switched back from A2212@12V on 2026-04-27.
 *
 * 2810 specs:
 *   KV = 1350 RPM/V, 7 PP, Rs ≈ 22 mΩ, Ls ≈ 10 µH
 *   λ = 60 / (√3·2π·1350·7) = 0.000583 V·s/rad
 *   No-load max @ 24V = 24 / 0.000583 = 41200 rad/s elec ≈ 393k eRPM
 *   Practical max with FW + observer headroom: ~210k eRPM (validated
 *   2026-04-25, see an1078_200k_milestone memory note). */

#define AN_NOPOLESPAIRS             7                /* 7 PP (14 magnets) */

/** Phase-to-neutral resistance (Ω).  Measured ~22 mΩ. */
#define AN_MOTOR_RS                 0.025f   /* 2026-07-09 U3 KV700: datasheet Rm=50mΩ (phase-phase) /2 = 25mΩ per-phase. Was 0.022 (2810). */

/** Phase-to-neutral inductance (H).  Measured ~10 µH. */
#define AN_MOTOR_LS                 18e-6f   /* 2026-07-09 U3 KV700: datasheet omits L; 18µH from the 5055 ~580KV sibling (profile 3, same 12N14P/7PP class). Was 10e-6 (2810). Feeds AN_F_PLANT/AN_G_PLANT below. */

/** Per-phase peak flux linkage λ (V·s/rad_electrical).  λ = 60 / (√3·2π·KV·PP)
 *  for 1350 KV @ 7PP gives 0.000583. */
#define AN_MOTOR_LAMBDA             0.001125f

/** Discrete plant pole F = 1 - Rs·Ts/Ls.
 *  2810: 1 - 0.022 × 41.67e-6 / 10e-6 = 0.908.  Stable (must be 0..1). */
#define AN_F_PLANT                  (1.0f - AN_MOTOR_RS * AN_TS / AN_MOTOR_LS)

/** Discrete plant gain G = Ts/Ls. */
#define AN_G_PLANT                  (AN_TS / AN_MOTOR_LS)

/* ── Operating speed envelope ──────────────────────────────────── */

/** Open-loop ramp-up end value, mechanical RPM.  Two roles:
 *  (1) OL→CL handoff speed: motor must reach this before observer
 *      gating can transition to closed loop.
 *  (2) Idle CL speed when throttle is below deadband.
 *
 *  500 RPM mech (= 3500 eRPM, BEMF 0.21V) was a bench-friendly low
 *  value but too slow for prop operation: prop drag at 500 RPM is
 *  significant and BEMF SNR is marginal.
 *
 *  1500 RPM mech (= 10500 eRPM, BEMF 0.64V) is prop-friendly:
 *    - Prop spins at a clean idle, ready to ramp on throttle
 *    - BEMF triple — observer locks more reliably
 *    - OL ramp at 1000 rad/s² takes 1.1s to reach this from rest
 *  Bumped 500→1500 on 2026-04-26 for prop testing. */
#define AN_END_SPEED_RPM_MECH       2000.0f  /* 2026-07-11 MCLV-port 200->2000: hand off
                                              * at 14000 eRPM where BEMF SNR is strong (like
                                              * MCLV), NOT 1400 where the observer is blindest.
                                              * Requires the OmegaFltred LPF + angle gate + the
                                              * ramp-rate bump to 1000. Prior history:
                                              * 2026-07-10: 2000->600->300->900->200.
                                              * 900 (6300 eRPM) was the smooth OPEN-LOOP
                                              * endpoint, but that made the OL->CL handoff
                                              * fire at 6300 eRPM where the observer read
                                              * ~20% below the forced rate -> field/rotor
                                              * desync -> OC -> PWM off -> coast/blink.
                                              * conf=1.0 by ~106 eRPM, so hand off LOW:
                                              * 200 mech = 1400 eRPM, well inside the
                                              * observer's confident zone, where a small
                                              * angle error is recoverable and the speed
                                              * PI can pull it in (AN1078 hands off low).
                                              * OL leg is rougher/shorter now -- fine, CL
                                              * damps it immediately after. Also = CL idle
                                              * target at throttle 0. */

/** End-speed in electrical rad/s.  Used as min closed-loop speed
 *  floor and as the LPF Kslf clamp floor. */
#define AN_END_SPEED_ELEC_RS        \
    (AN_END_SPEED_RPM_MECH * (float)AN_NOPOLESPAIRS * 6.28318530718f / 60.0f)

/** Nominal motor speed (mech RPM) — full-throttle target speed.
 *  CL throttle range maps 0→full to AN_END_SPEED → AN_NOMINAL_SPEED.
 *
 *  2810 @ 24V: theoretical no-load = 24 × 1350 = 32400 RPM mech
 *  (= 227k eRPM at 7PP).  Practical with FW + observer margin: 30000
 *  RPM mech (= 210k eRPM) — past the 196k 6-step benchmark target. */
#define AN_NOMINAL_SPEED_RPM_MECH   30000.0f     /* = 210k eRPM */

/** Maximum mechanical RPM. */
#define AN_MAX_SPEED_RPM_MECH       3500.0f

/** Maximum electrical rad/s — protection clamp on speed reference. */
#define AN_MAX_SPEED_ELEC_RS        \
    (AN_MAX_SPEED_RPM_MECH * (float)AN_NOPOLESPAIRS * 6.28318530718f / 60.0f)

#define AN_NOMINAL_SPEED_ELEC_RS    \
    (AN_NOMINAL_SPEED_RPM_MECH * (float)AN_NOPOLESPAIRS * 6.28318530718f / 60.0f)

/* ── Open-loop startup ────────────────────────────────────────── */

/** Lock time (ticks): total duration before OL ramp begins.  Includes:
 *    - Warmup (50 ms, gate drivers settle, no PI activity)
 *    - Iq soft-ramp (200 ms, 0 → ramp_iq linearly through PI)
 *    - Steady alignment (150 ms, full Iq holds rotor at θ=0)
 *  Total: 400 ms = 9600 ticks at 24 kHz. */
#define AN_LOCK_TIME                9600

/** Open-loop ramp acceleration in electrical rad/s².  Used ONLY for
 *  the OL startup ramp (0→AN_END_SPEED = 366 rad/s).  Slower is safer
 *  with load — prop inertia needs time to come up to speed.  At
 *  1000 rad/s² OL ramp completes in ~366 ms — gentle but BEMF-gate
 *  still fires before any handoff timeout. */
#define AN_OL_RAMP_RATE_RPS2        400.0f    /* 2026-07-13 PROP-START 1000->400: phantom-OL fix.
                                              * Current-mode I/f (q-axis on forced angle) slips
                                              * under prop load when the forced field outruns the
                                              * heavy rotor -> commanded eRPM marches to 14k while
                                              * the prop lags/stalls -> handoff commits garbage ->
                                              * FASTOC 252. Slower ramp lets the prop track. Pairs
                                              * with AN_Q_CURRENT_REF_OPENLOOP 5->8A for torque.
                                              * REVERT to 1000 for no-load. History follows:
                                              * 2026-07-11 MCLV-port 100->1000: match MCLV
                                              * so the 10x-higher END_SPEED (2000 mech) ramps
                                              * in ~1.5s, not ~15s. Prior history:
                                              * 2026-07-10: 1000->200->100 for
                                              * open-loop V/f. idM oscillation
                                              * grew with speed (rotor slipped as
                                              * field outran it). Halve the ramp
                                              * again to widen the torque margin
                                              * from the demand side while boost
                                              * supplies more drag torque. */

/* ── OPEN-LOOP V/f MODE (2026-07-10 bring-up) ─────────────────────
 * First-spin path that IGNORES current feedback entirely. The dsPIC
 * OA1/OA2 phase-current sense reads ~0 on this board (unproven path),
 * which winds up the current PI. In V/f mode the open-loop branch
 * commands voltage DIRECTLY (bypassing pi_q/pi_d) and the OL->CL
 * handoff is disabled (the SMC observer needs current it can't see).
 * Forced commutation: LOCK aligns at AN_OL_VF_BOOST_V, then the angle
 * ramps to AN_END_SPEED and HOLDS there open-loop. Proves the power
 * stage + commutation without any current dependency.
 * Set to 0 to restore normal closed-loop FOC. */
#define AN_OPENLOOP_VF              0   /* 2026-07-10: BISECTION (0) + AN_FOC_
                                         * BISECT_VF=1 = CL build but V/f drive,
                                         * to isolate current-PI vs compile-time
                                         * as the ISR-hang cause. Set back to 1
                                         * for the proven open-loop.
                                         * Former FOC note follows: 1->0 GO TO FOC. Current
                                         * feedback proven in open-loop (idM/iqM
                                         * track, scaling verified). Re-enables
                                         * I/f current-regulated align/ramp +
                                         * SMC observer + OL->CL handoff. Align
                                         * clamp raised 0.15->2.5 to let the 4A
                                         * current PI push through the dead-band.
                                         * Open-loop bring-up path (1) is kept
                                         * intact as a fallback. */

/* I/f-ONLY FOC STAGE (2026-07-10). With AN_OPENLOOP_VF=0, setting this to 1
 * runs the CURRENT-regulated align/ramp (current PI drives iq to
 * AN_Q_CURRENT_REF_OPENLOOP on the forced angle) but SKIPS the SMC observer
 * and the OL->CL handoff. Rationale: first FOC attempt (observer ON) wedged
 * the ADC ISR at ~tick 700 during warmup -- the observer diverges on this
 * board (documented). This decouples the two risks: prove the CURRENT LOOP
 * closes (iqM tracks 4A, motor spins current-controlled via forced
 * commutation) WITHOUT depending on the unproven observer. Set to 0 (with
 * AN_OPENLOOP_VF=0) to attempt full sensorless handoff once the observer is
 * fixed. Ignored when AN_OPENLOOP_VF=1. */
#define AN_FOC_IF_ONLY              0

/** BISECTION (2026-07-10): with AN_OPENLOOP_VF=0 + AN_FOC_IF_ONLY=1, replace
 *  the current-PI drive with direct V/f in the CL (#else) branch. This is a
 *  CL-compiled build (AN_OPENLOOP_VF=0) that DRIVES exactly like the proven
 *  open-loop build. Purpose: the ISR hangs mid-warmup (lk~700) BEFORE the
 *  current-PI ever executes (post-warmup, lk>=1200), so this isolates whether
 *  the mere PRESENCE/compilation of the current-PI path (vs V/f) triggers the
 *  hang. Spins -> current-PI code presence implicated (layout/linkage). Still
 *  hangs mid-warmup -> definitively compile-time/timing of AN_OPENLOOP_VF=0
 *  itself -> debugger is the only next step. Set 0 for real I/f current drive.
 *  2026-07-10 RESULT: bisect SPINS + execute-discard (AN_FOC_BISECT_EXEC) SPINS
 *  => ROOT CAUSE = APPLYING the PI output voltage trips a HW OC fault (di/dt).
 *  Now 0 = real I/f drive, guarded by the AN_V_SLEW_PER_TICK slew limiter. */
#define AN_FOC_BISECT_VF            0

/** BISECTION STEP 2 (2026-07-10): with AN_FOC_BISECT_VF=1, ALSO execute the
 *  current-PI (an_pi_run for both axes, integrators evolving exactly as in the
 *  hanging I/f build) but DISCARD its output and still drive V/f. Separates the
 *  two remaining causes: if it HANGS, the mere EXECUTION of an_pi_run wedges the
 *  ISR (CPU/FPU/timing). If it SPINS, execution is harmless and the hang comes
 *  from APPLYING the PI's output voltage (current/di-dt -> hardware PWM fault),
 *  which is a tuning problem, not a code problem. Set 0 for the pure-V/f bisect. */
#define AN_FOC_BISECT_EXEC          1

/** V/f voltage floor at zero speed (volts). Sets align/low-speed
 *  current ~= AN_OL_VF_BOOST_V / AN_MOTOR_RS (0.15V / 0.025ohm ~= 6A).
 *  Total command V = AN_OL_VF_BOOST_V + AN_MOTOR_LAMBDA*omega, so
 *  V-BEMF stays ~= boost -> current stays bounded as speed rises.
 *  Keep it low for first spins; raise for more starting torque. */
#define AN_OL_VF_BOOST_V            1.40f   /* 2026-07-10: 0.25->0.80->1.60->1.40.
                                             * POLISH: 1.60 broke away + synced but
                                             * over-excites (~7A winding at ALL
                                             * speeds incl the long align -> heat).
                                             * Since V-BEMF~=boost, current~=boost/
                                             * Rs(eff): trim boost -> less current,
                                             * ripple, heat. Conservative step; if
                                             * breakaway/sync is lost at low speed,
                                             * go back up toward 1.60. Prior note:
                                             * 0.25->0.80->1.60.
                                             * TELEMETRY PROOF: at boost 0.80 the
                                             * winding drew only ~3A (Vbus rock-
                                             * steady 16.0 at a 3A PSU limit), yet
                                             * 0.80V/25mOhm predicts 32A. So the
                                             * EFFECTIVE phase voltage is ~0.075V
                                             * (3A*25mOhm) = ~1/10 of commanded:
                                             * the ATA dead-band is still eating
                                             * most of the pulse at mod=0.09-0.14.
                                             * Torque-starved, not ramp-limited
                                             * (idM slip oscillation grew with
                                             * speed). Double boost to punch above
                                             * the dead-band. HYPOTHESIS TEST: if
                                             * current rises ~proportionally ->
                                             * dead-band confirmed, real drag
                                             * torque appears. If current stays
                                             * pinned ~3A -> 45kHz Fsw is the wall,
                                             * lower Fsw next. Effective V still
                                             * modest (~0.15V -> ~6A) so bench-safe,
                                             * but WATCH Vbus + KEEP RUNS SHORT. */

/** Closed-loop velRef slew rate (rad/s²).  Used to slew the speed
 *  setpoint toward throttle target — sets throttle response feel.
 *  Independent of OL ramp so high-throttle response is snappy without
 *  destabilizing OL→CL handoff.  12000 rad/s² → full sweep
 *  (366→22000 rad/s) in ~1.8 s. */
/* 2026-07-13: 12000->4000. Bench proved the ramp reaches 18,750 eRPM when the
 * throttle is stepped GENTLY (pauses at each level) but desyncs on a hard jump
 * (thr 456->518: iqM 4->11.9 -> FASTOC). The trigger is the setpoint STEP, not
 * the speed. At the top the observer margin is thin (conf ~0.45, Kslf floored)
 * so a fast velRef ramp is the disturbance that tips it. Slowing the slew makes
 * every throttle push ramp gently automatically -> no need to baby the stick.
 * 4000 rad/s^2 => full 366->22000 sweep in ~5.4s; a 500 rad/s step in ~125ms. */
#define AN_CL_VELREF_SLEW_RPS2      4000.0f

/** Open-loop q-current reference (A peak).
 *  Must overcome cogging + prop inertia + steady prop drag at OL end speed.
 *  Sizing: prop drag at 1500 RPM mech ≈ 30-40 mN·m on small motors → need
 *  > 50 mN·m of motor torque margin to follow synth angle.
 *
 *  Per motor:
 *    A2212 (Kt=0.0059 N·m/A): 12A → 71 mN·m  ← good for prop tests
 *    2810  (Kt=0.0061 N·m/A): 12A → 73 mN·m  ← also fine, was 8A before
 *
 *  Voltage drop @ 12A:
 *    A2212 (Rs=65mΩ): 0.78V (~6% of 12V)
 *    2810  (Rs=22mΩ): 0.26V
 *  Both well under bus voltage. */
#define AN_Q_CURRENT_REF_OPENLOOP   15.0f  /* 2026-07-14 STARTUP-CURRENT TRIM 18.186->12->10->15 (true A).
                                            * BENCH: 12.0 gives a rock-solid OL RAMP (0 fault, ~1.8A bus) but
                                            * the OL->CL HANDOFF then becomes an intermittent coin-flip: ~half
                                            * the starts, one tick after handoff the observer angle is wrong,
                                            * speed collapses, speed-PI winds iqRef up, phase I hits the 27.3A
                                            * FASTOC -> FAULT 252. Mechanism: lower OL current = larger load
                                            * angle delta = bigger drive-angle step at handoff. 18.186 (the
                                            * pre-fix "8A") was the last value with a reliable handoff. 15.0 is
                                            * a probe between 12 (flaky) and 18 (ok): bus ~2.25A, ~25% below the
                                            * original 3A, testing whether the handoff goes reliable again.
                                            * If 15 still faults intermittently -> the handoff itself needs
                                            * hardening (angle-blend kb / preload / handoff gate), decoupled
                                            * from startup current, and we can then push OL current back down.
                                            * Original note (still applies):
                                            * The 18.186 was the pre-fix "8 A" ×k, behaviour-preserved.
                                            * Now that the scale is TRUE, align+OL genuinely draw ~18A
                                            * phase / ~3A bus flat across the whole ramp, while the SAME
                                            * prop holds at only ~5A once in CL (14k) -> the 18A is forced
                                            * sync margin, not load demand, and it's doubly-margined by the
                                            * slow 400 rad/s^2 ramp. 12.0 (~pre-prop 5A×k=11.4) cuts bus
                                            * to ~2A. FLOOR: forced I/f load angle must stay <90deg under
                                            * inertia+cogging+prop or the rotor slips a pole (desync). If
                                            * it slips/stalls on the OL ramp WITH the prop, step back up
                                            * (13/14/15); if it holds, try lower (10/9). Keep ramp at 400.
                                            * PROP-START 5->8A (=18.186 true) history:
                                            * 2026-07-13: torque to drag the prop
                                            * up the OL ramp so the rotor tracks the forced angle
                                            * (no phantom OL). SAFE: FASTOC(12A) is CL-only, OL
                                            * regulates this ref. Pairs with OL ramp 1000->400.
                                            * REVERT to 5 for no-load. History follows:
                                            * 2026-07-11 MCLV-port 4->5A: calm the OL hunt
                                            * (the angle gate now catches residual slip). Prior:
                                            * 2026-07-09 12->4A for 700KV no-prop bench.
                                            * 12A was sized to drag a PROP up on the 2810; with
                                            * the corrected current scale align now drives REAL
                                            * 12A, which folds a current-limited PSU at 16V -> UV
                                            * trip (bench-confirmed: PSU sags during align). 4A
                                            * locks the rotor + rampable no-prop. Raise if it
                                            * won't overcome cogging; lower if PSU still sags. */

/** PWM warmup phase (ticks).  When motor first starts, hold Vd=Vq=0
 *  (50% duty everywhere = zero net motor voltage) for this many ticks
 *  before engaging PI control.  Allows gate drivers to settle and
 *  bootstrap caps to top off after override-release transient.
 *  50 ms = 1200 ticks at 24 kHz. */
#define AN_WARMUP_TICKS             1200U

/** Handoff dwell — BEMF must hold above gate threshold for this many
 *  consecutive fast-loop ticks before OL→CL transitions.  100 ms is
 *  enough to filter noise; observer is already locked at this point so
 *  short dwell is fine.  100 ms = 2400 ticks at 24 kHz. */
#define AN_HANDOFF_DWELL_TICKS      2400U

/** STA handoff speed-gate LPF coefficient (2026-07-15, FEATURE_AN_STA only).
 *  The super-twisting z is unfiltered, so pll.omega_est = d(theta)/dt jitters
 *  ~+-12% at the plateau even though its MEAN tracks the forced speed and the
 *  angle is stable (bench lk= readout). That derivative noise perpetually
 *  resets the 5%/53ms speed dwell. LPF pll.omega_est before the gate compares
 *  it: coef 0.02 ~= 50-tick (1.1 ms) time constant smooths +-12% -> ~+-2%,
 *  inside the 5% band, while settling far faster than the 53 ms dwell. The
 *  boundary observer's z is already LPF'd, so this is STA-only. */
#define AN_HANDOFF_OMEGA_FILT_COEF  0.02f

/** Handoff SPEED-CONVERGENCE gate (2026-07-10). The BEMF-magnitude gate only
 *  proves BEMF is PRESENT (conf=1.0), NOT that the observer's speed/angle has
 *  converged to the real rotor. Bench: at handoff the observer OmegaFltred read
 *  105-472 eRPM while the forced rate was 1401 (and 5113 vs 6338 at the higher
 *  handoff) -- the speed filter is slow and lags the true speed. Handing off on
 *  that stale estimate drives CL on a wrong angle -> field/rotor desync -> big
 *  current spike -> bench PSU sags -> brownout. So ALSO require the observer
 *  speed to be within this fraction of the known forced speed (startupRamp)
 *  before handoff. If it never converges, the ESC safely HOLDS in OL (no
 *  handoff, no brownout) -- which itself diagnoses a mis-parameterized observer
 *  (e.g. profile=2810 vs the real U3 motor: wrong Ke/Rs/Ls). */
#define AN_HANDOFF_SPEED_TOL_FRAC   0.05f  /* 2026-07-12 0.30->0.05: bumpless handoff
                                            * removed the entry V-collapse, but pure-observer
                                            * CL then swung the current to idM -8.3A (vector
                                            * grew+rotated ~180deg = observer angle runaway)
                                            * -> fast-OC. At 0.30 the commit allowed up to 30%
                                            * omega error (~440 rad/s @1472) which drifts the
                                            * angle many turns per sample. 0.05 only commits
                                            * when omega_est is within 5% of forced. If it
                                            * never converges the ESC HOLDS in OL at 14k (no
                                            * fault) -> that itself proves the observer omega
                                            * is >5% off = fundamentally the problem. */

/** Handoff ANGLE-tolerance gate (2026-07-11 MCLV-port). The speed/BEMF dwell
 *  proves the observer TRACKS but not that the commit tick is a good rotor
 *  phase. Bench (MCLV): |thetaError| at commit ~30-42deg HOLDS, ~68-77deg
 *  DESYNCS -> OC. So only COMMIT OL->CL on a tick where
 *  |wrap(thetaOpenLoop - smc.Theta)| is inside this band; else hold at
 *  end-speed and retry next good-phase tick.
 *  2026-07-11 BENCH: at 0.87 (50 deg) the U3+prop handoff was a coin-flip --
 *  some commits held CL 7.5s steady (iqM ~0.8A), others committed marginal
 *  (iqM entered 6-7A, climbed past 8A -> fast-OC). 50deg is ABOVE the proven
 *  ~30-42deg hold band, so tightened 0.87 -> 0.60 (~34deg) to commit only on
 *  a well-aligned tick. REVERT to 0.87f if handoff never fires. */
#define AN_HANDOFF_ANGLE_TOL_RAD    0.60f

/** OBSERVER DEAD-TIME COMPENSATION (2026-07-11, bench-CONFIRMED root cause).
 *  No-prop parks thetaError (st=) rock-steady at -36 deg, 2 deg outside the
 *  +-34 deg gate -> never hands off; the prop's load angle drags it inside ->
 *  hands off. Root cause: the ATA6847 dead-time (dominated by the ~700ns fixed
 *  GDUCR1.CCPT) is UNCOMPENSATED in this build (observer eats raw commanded V;
 *  the FOC duty path adds nothing). MCLV compensates at the duty level and so
 *  hands off no-load. Fix: feed the observer the TRUE applied voltage =
 *  v_cmd - dt_comp_v*softsign(i), dt_comp_v = Vbus*AN_DT_COMP_FRAC. Affects ONLY
 *  the observer's voltage input -- drive/torque unchanged.
 *  TUNING (watch st= at no-load, keep runs SHORT):
 *    - 0.063 ~= 700ns @ 45kHz is the physics starting point.
 *    - if st= moves toward 0 -> right sign; trim magnitude until st= ~0 and it
 *      hands off. If st= moves the WRONG way (more negative / toward -50) ->
 *      FLIP the sign of AN_DT_COMP_FRAC, then trim.
 *    - AN_DT_COMP_FRAC = 0.0f disables (reverts to raw observer voltage). */
#define AN_DT_COMP_FRAC             0.0f    /* 2026-07-13 DIAGNOSTIC — comp DISABLED.
                                             * conf-unclamp run (build 0xB7741BC6) proved
                                             * the -0.20 comp = +0.20*Vbus (~3.18V) applied
                                             * in the WRONG (alpha-beta) frame, ~6x the
                                             * physical 700ns CCPT dead-time (0.063), was
                                             * inflating |E_obs| to a near-constant ~2V that
                                             * SWAMPS the true BEMF (0.6V@5k .. 1.66V@14k) ->
                                             * conf 7-9 at idle decaying to 1.2 at 14k. That
                                             * fixed rotating term is the prime suspect for
                                             * the observer-drive CL instability. Set to 0 to
                                             * read the NAKED observer: watch conf@14k (expect
                                             * toward ~1.0) + st across the ramp (expect the
                                             * true uncompensated bias, ~-36deg was claimed).
                                             * If observer is now clean the self-gating
                                             * (0.05 speed gate) will hand off on its own.
                                             * NEXT if this helps: proper abc-frame comp at
                                             * FRAC=0.063 (dead-time built per-phase, Clarked),
                                             * NOT this alpha-beta softsign. Old note kept:
                                             * -0.11 left OL bias st -20..-31 mid-ramp
                                             * (only -7..-9 at handoff top). Pure-observer CL bleeds
                                             * onto that biased angle -> 8A fast-OC (252) at
                                             * every OL->CL commit. Step toward nulling st=;
                                             * NONLINEAR (dtc=Vbus*FRAC is fixed volts, angle
                                             * effect shrinks with speed) -> trim by watching
                                             * st= across the WHOLE ramp, don't jump big. */
/** Soft-sign deadband (amps): |i| below this ramps the sign linearly instead of
 *  hard +-1, killing chatter at phase-current zero crossings. Must be > 0. */
#define AN_DT_COMP_IBAND            2.27325f /* GAIN-16 FIX ×k (was 1.0). Sign deadband on true-amp i_alpha */

/** OUTPUT-side (duty-level) dead-time compensation — 2026-07-13.
 *
 *  DISTINCT from AN_DT_COMP_FRAC above.  That one corrects the voltage the
 *  OBSERVER sees (fixes conf/angle); THIS one corrects the voltage the MOTOR
 *  actually gets (fixes CURRENT distortion = commutation roughness).  The
 *  ATA6847 inserts ~700ns dead-time each PWM edge; over the 22.2us (45kHz)
 *  period that is ~3.15% of volt-seconds LOST in the leg, in the direction
 *  opposing phase current.  Add it back per leg after SVPWM:
 *      d_x += FRAC * softsign(i_x)      (i>0 leg loses -> add duty)
 *  MCLV does exactly this at the duty level; GarudaESE did NOT -> its no-load
 *  current ripples ~+-0.6A (rough vs MCLV with identical fw/motor).
 *
 *  BENCH TUNING (needs iteration — a WRONG SIGN makes roughness WORSE via
 *  positive current-error feedback):
 *    1. Enable: set FRAC = 0.03 (~full 700ns dead-time ratio).  Rebuild+flash.
 *    2. Watch no-load iqM ripple.  Smoother -> sign is right; rougher -> FLIP
 *       the sign (negate FRAC) and retry.
 *    3. Trim magnitude: too little = still rough, too much = over-comp adds a
 *       reverse ripple.  Sweep ~0.015..0.035.
 *    FRAC = 0.0f disables (default OFF so the Kslf ceiling fix is tested clean
 *    first, then enable this separately — one variable at a time). */
#define AN_OUT_DT_COMP_EN           0       /* 1 to enable (the #if gate — the
                                             * preprocessor can't test the float
                                             * FRAC directly). Set to 1 AND set a
                                             * nonzero FRAC to turn the comp on. */
#define AN_OUT_DT_COMP_FRAC         0.03f
/** Deadband (amps) for the output DT-comp softsign — same role as
 *  AN_DT_COMP_IBAND: below |i| this the sign ramps linearly to kill ZC chatter. */
#define AN_OUT_DT_COMP_IBAND        2.27325f /* GAIN-16 FIX ×k (was 1.0). Sign deadband on true-amp ia/ib */

/** LOW-LOAD OBSERVER EXCITATION (d-axis current injection) — 2026-07-13.
 *
 *  Bench finding (build 0xB783C0CB, ThetaBase nulled, DT comp=0): observer-
 *  driven CL now HANDS OFF and holds ~0.4s, but at NO LOAD the speed PI winds
 *  Iq -> 0, the SMC loses lock (dead-time distortion dominates and phase-
 *  current signs get noisy when |I|~0) and it faults 8A. Applying HAND LOAD
 *  (forcing real Iq) keeps CL running indefinitely; releasing it re-faults.
 *
 *  Fix: inject POSITIVE d-axis current at low load so |I| stays out of the
 *  zero-current dead zone. Id makes NO torque, so the motor holds its speed
 *  (a min-Iq floor would instead accelerate away). Tapers to 0 as Iq demand
 *  rises (load self-excites) and as speed rises (observer self-excites clean
 *  at high speed). Only active when field weakening is NOT engaged.
 *  Set AN_ID_INJECT_MAX_A = 0 to disable. Start ~3A ≈ the current that OL and
 *  hand-load ran at. */
#define AN_ID_INJECT_MAX_A          6.820f   /* GAIN-16 FIX ×k (was 3.0). peak d-axis excitation, A (0 disables) */
#define AN_ID_INJECT_IQ_KNEE_A      6.820f   /* GAIN-16 FIX ×k (was 3.0). |iq_ref| (A) at which injection fades to 0 */
#define AN_ID_INJECT_FADE_RADS      5000.0f  /* elec speed (rad/s) at which injection fades to 0 (~48k eRPM) */

/** DYNAMIC d/q DECOUPLING FEEDFORWARD — 2026-07-13.
 *
 *  The PMSM dq voltage equations carry cross-coupling and BEMF terms that the
 *  current PIs otherwise have to INTEGRATE out:
 *      vd = R*id + L*did/dt - w*L*iq
 *      vq = R*iq + L*diq/dt + w*L*id + w*lambda
 *  The w*lambda BEMF term dominates and grows with speed (~1.66 V @14k eRPM,
 *  ~7.6 V @60k). With no feedforward the q-PI must wind its integrator up to the
 *  full BEMF on every speed change -> slow, lag-prone, and near the voltage
 *  ceiling it can't keep up -> speed sags and the loop winds to OC (the exact
 *  "throttle push -> sag -> iq winds -> 8A" pattern seen 2026-07-13). Feed the
 *  disturbance forward so the PI only trims the residual (standard FOC):
 *      vd_ff = -w*L*iq_meas
 *      vq_ff = +w*L*id_meas + w*lambda
 *  w = observer electrical speed (OmegaFltred); L, lambda from the active
 *  profile (gspParams, #define fallback). The current-PI clamp is reduced by the
 *  ff so PI+ff stays inside the circular voltage budget and anti-windup stays
 *  valid; the OL->CL handoff preload subtracts the ff so the voltage handoff is
 *  still bumpless.
 *
 *  Default ON. Revert with AN_DECOUPLE_EN 0. BENCH: watch idM at the first spin
 *  -- correct sign leaves idM ~0 across the ramp; a WRONG sign shows as idM
 *  diverging as speed rises (the 12 A fast-OC latch still protects). Trim
 *  AN_DECOUPLE_FRAC down (e.g. 0.5) if the ff over-drives; it scales both terms. */
#define AN_DECOUPLE_EN              1
/* GAIN-16 FIX (retired, revert-only knob): the decoupling ff (w·Ls·i) uses the current REFS,
 * which are now true amps (k× the old fake). With real Ls that makes the ff its
 * full physical strength — but the drive was validated with the ff effectively
 * 1/k as strong (fake currents). RETIRED 2026-07-14 to production end-state:
 * 0.43991 -> 1.0 = full, physically-correct decoupling ff (w·Ls·i in true amps
 * with real Ls). BENCH: watch idM (correct sign holds it near 0 across the ramp)
 * and Vbus for regen bus-pump at high speed; trim toward 0.5 if the ff over-drives. */
#define AN_DECOUPLE_FRAC           1.0f

/** ── D1: one-sample delay compensation (complex-vector) ───────────
 *  The vector we compute this tick is not applied until the next PWM update
 *  (~1-1.5 Ts later: ISR compute + PWM double-buffer). By then the rotor has
 *  advanced w*dt. Below the current-loop BW (~780 Hz) that lag is negligible,
 *  but above ~56k eRPM (f_elec > 937 Hz) it becomes real phase error that,
 *  together with the 0.95 vector clamp, drives a period-2 limit cycle (bench
 *  2026-07-14: alternate ticks mod 0.6<->0.95, Vbus 16<->21 V, idM +/-6 A).
 *  Fix: advance the angle used for the inverse Park (i.e. rotate the commanded
 *  voltage vector forward) by AN_DELAYCOMP_FRAC * w * Ts, so the vector the
 *  inverter APPLIES lands where the rotor WILL be. FRAC ~1.5 = compute + PWM
 *  latency in Ts. Scales with w -> zero effect at low speed (proven band
 *  untouched), grows exactly where the limit cycle lives. Revert with EN 0. */
#define AN_DELAYCOMP_EN             1
#define AN_DELAYCOMP_FRAC           1.5f

/** BISECTION 2026-07-10: isolate the OL->CL wedge cause.
 *
 *  Bench (build 0x920BC468, native observer speed now exposed as "st="):
 *  the observer MEAN-tracks the forced speed (st centered ~1400 at the top of
 *  the 1401 ramp) so it is NOT mis-parameterized -- but it is very NOISY
 *  (st swings +-600 eRPM tick-to-tick). At EVERY handoff the ISR freezes on
 *  the first CL tick, and in the frozen CL frame iqM is far below iqRef~
 *  (2.3 vs 3.8) = the commanded q-current is NOT being realized = the DRIVE
 *  ANGLE is misaligned with the rotor -> current PI winds Vq to the rail ->
 *  hardware OC/PCI trip -> PWM off -> ADC/ISR stops. Happens at both 6338 and
 *  1401 eRPM handoff, so it is the CL ANGLE/DRIVE path, not the handoff speed.
 *
 *  This flag keeps CL fully active (speed PI + current PI + integrator reset +
 *  FW) but DRIVES THE FORCED/RAMPED ANGLE (thetaOpenLoop, kept advancing at the
 *  CL commanded speed) instead of the observer angle. It is the clean
 *  discriminator:
 *    CL HOLDS (iqM tracks iqRef, no wedge, motor holds ~1400 closed-loop-speed)
 *        -> the OBSERVER ANGLE is the culprit (too noisy/offset to drive) ->
 *           fix = smooth the observer / hand off higher / blend angle in.
 *    CL STILL WEDGES -> the CL speed/current MACHINERY trips OC regardless of
 *        angle -> the bug is in the CL drive path, not the observer.
 *  Set 0 for real sensorless CL (observer angle); 1 for this bisection.
 *
 *  2026-07-10 FLIP TO 0: build 0x01417C47 (forced-angle + 6000 eRPM cap) ran
 *  clean idle->4285 eRPM->idle, conf=1.0, no desync, and the native observer
 *  "st" tracked the period-tracker eRPM to within a few counts at EVERY speed
 *  INCLUDING 1400 idle (2153/2150, 4285/4267, 1851/1851). The old "observer
 *  reads 20% low / too noisy at idle" justification for forcing the angle is
 *  disproven by that data -> the observer angle is healthy enough to drive.
 *  Forced angle was I/f: iqRef railed at 4.0 and duty flat ~57% across the whole
 *  range = 4A forced even at no-load idle (the roughness) and CANNOT hold load
 *  (pull-out). Observer angle makes the speed PI well-posed: iq drops to the load
 *  demand, idle current falls, and it holds torque under load.
 *
 *  2026-07-10 BENCH RESULT (build 0x01A60F44): FORCED_ANGLE=0 WEDGED the ISR
 *  instantly at handoff, both runs. First CL tick: iqM=+0.1 vs iqRef~=+4.0
 *  (commanded q-current NOT realized = drive angle misaligned) -> current PI
 *  rails Vq -> OC/PCI trip -> PWM off -> isr counter FROZEN (487619 / 334902,
 *  never advanced). Observer SPEED tracks but observer ANGLE is wrong at handoff.
 *  This is the recurring core defect and it is upstream of firmware angle tuning:
 *  the phase-current sense path (OA1/OA2) that feeds the observer angle is
 *  UNVERIFIED on this board. This block is the rationale for the old value 1
 *  (working I/f build + 6000 eRPM cap); the live value is now 0 (observer-drive,
 *  re-enabled 2026-07-11 — see inline note below). See memory blocker. */
#define AN_CL_FORCED_ANGLE          0   /* 2026-07-11 RE-ENABLED observer-drive (0) for the ILIM-off diag run; REVERT to 1 if it wedges. History: observer-drive WEDGES
                                         * at handoff on EVERY start, even right after a
                                         * power-cycle (iqM slams 10-12A, isr freezes on the
                                         * first CL tick). NOT a degraded-state issue -> the
                                         * observer angle is not viable on THIS board yet
                                         * (hardware/OA1-OA2 channel match -> bench, or sim).
                                         * Forced I/f angle in CL = RELIABLE (idle ~4-5A, holds
                                         * no-load full range, cannot hold heavy load). Keep the
                                         * rest of the MCLV port (LPF/KI/angle-gate/END_SPEED)
                                         * -- they smooth the forced-angle handoff too.
                                         * Prior note: MCLV-port 1->0: drive the OBSERVER
                                         * angle in CL (real sensorless), like the working
                                         * MCLV build -- NOT the forced I/f angle. This is the
                                         * enabling change: with it 0, the OmegaFltred-LPF +
                                         * KI-cut + thetaError-gate transplant is what makes
                                         * observer-angle drive stable (was inert while 1). If
                                         * CL still wedges at handoff after this, the residual
                                         * difference vs MCLV is HARDWARE (OA1/OA2 channel
                                         * match) -> bench, not firmware. */

/** LOAD-ROBUST SENSORLESS 2026-07-10: speed-scheduled angle blend.
 *
 *  The AN_CL_FORCED_ANGLE=1 bisection PROVED (build 0x92246863, ~93s, idle->
 *  75000 eRPM, no wedge) that the CL speed+current machinery is sound and the
 *  ONLY thing that wedged CL was driving the observer's angle -- which is too
 *  NOISY at idle (tiny BEMF at 1400 eRPM) but ROCK-STEADY at speed (eRPM read
 *  dead-constant at 64000/75000). Forced-angle CL is fine at NO-LOAD but is
 *  I/f, not sensorless: under prop load the rotor slips the forced angle
 *  (pull-out) and desyncs. Load-holding needs the OBSERVER (true rotor) angle.
 *
 *  This blend crossfades the drive angle from the forced angle to the observer
 *  angle as commanded speed rises: pure forced below LO (idle stays exactly as
 *  the proven build), pure observer above HI (true rotor angle -> holds torque
 *  angle under load), linear in between. Scheduled on startupRamp (commanded
 *  elec speed -- clean & monotonic with throttle) so the blend factor itself
 *  never chatters on observer noise. Blends the shortest-arc delta, never a raw
 *  angle lerp across the 2pi seam.
 *
 *  Precedence: AN_CL_ANGLE_BLEND=1 -> blend. Set 0 to fall back to the proven
 *  AN_CL_FORCED_ANGLE=1 build (pure forced angle in CL) unchanged.
 *
 *  LO/HI are STARTING GUESSES to bench-tune: we have no observer-quality data
 *  between 1400 (noisy) and 64000 (clean) eRPM. Watch iqM-vs-iqRef across the
 *  sweep -- if iqM falls below iqRef as k rises, the observer angle is failing
 *  at that speed; raise LO/HI. LO is kept above the 1400 idle so idle runs pure
 *  forced (proven stable). */
#define AN_CL_ANGLE_BLEND           0  /* 2026-07-10 REVERTED: blend to observer
                                         * angle COLLAPSES the drive at ~8000 eRPM
                                         * (bench 0x9224...blend build). See note
                                         * below. 0 = proven forced-angle build. */
#define AN_BLEND_LO_ERPM            3000.0f  /* below this: pure forced angle */
#define AN_BLEND_HI_ERPM            8000.0f  /* above this: pure observer angle */
#define AN_ERPM_TO_ELEC_RS          0.10471975512f  /* 2*pi/60 */
#define AN_BLEND_LO_ELEC_RS         (AN_BLEND_LO_ERPM * AN_ERPM_TO_ELEC_RS)
#define AN_BLEND_HI_ELEC_RS         (AN_BLEND_HI_ERPM * AN_ERPM_TO_ELEC_RS)

/** Iq soft-start ramp duration (ticks), AFTER warmup.  Linearly ramps
 *  iq_ref from 0 to AN_Q_CURRENT_REF_OPENLOOP over this many ticks.
 *  200 ms = 4800 ticks at 24 kHz. */
#define AN_IQ_SOFT_START_TICKS      4800U

/** Speed PI Iq-output saturation (A peak).  Iq commanded by speed PI
 *  is clamped to ±this.  Bumped 9→12 to give the speed loop headroom
 *  alongside aggressive field weakening at high speed (Id can reach
 *  −12A; total |I|=√(Id²+Iq²) up to ~17A which is within MCLV-48V-300W
 *  inverter rating). */
#define AN_OVER_CURRENT_LIMIT       45.465f /* GAIN-16 FIX ×k (was 20.0 fake = 45.5A real).
                                             * dq speed-PI iq_ref clamp, now TRUE amps. Analog
                                             * chain rails at +/-51.6A real (gain 16 / 2mOhm),
                                             * so this stays in the linear range. This is the
                                             * SAME physical clamp the drive was validated with;
                                             * a real 45A is generous — trim to a sane design
                                             * value (e.g. 25-30A) as a deliberate change. */

/** Fast per-phase over-current latch at CL entry (2026-07-11 hardening).
 *  A bad observer handoff slams the phase current to ~8-12A within a tick or
 *  two; without a fast latch the tick drives a huge vector -> ISR wedge / bus
 *  brownout that needs a power-cycle. This trips the engine to a safe zero-V
 *  FAULT the instant |ia| or |ib| exceeds this while in CL. Normal align/OL/CL
 *  peaks ~5-6A, so 8A trips only the desync slam. Per-phase amps (not the dq
 *  speed-PI clamp above). */
#define AN_FASTCHK_OC_LIM_A         27.279f /* GAIN-16 FIX ×k (was 12.0 fake = 27.3A real), same physical trip. 2026-07-13: 8->12. The observer-driven
                                             * CL ramp works to ~16.7k eRPM then a throttle
                                             * push made speed SAG + speed-PI wind iq up ->
                                             * phase peaked 8A -> instant latch, blocking the
                                             * ramp. 12A gives the acceleration transient room
                                             * (steady CL peaks ~3.6A; BSC028N06 >100A, dq
                                             * clamp 20A) yet still latches a hard desync
                                             * slam. DIAGNOSTIC: if the ramp now climbs past
                                             * 16.7k it was transient margin; if it still
                                             * collapses there it's a hard observer ceiling
                                             * (Kslf pinned at its 0.05 floor -> LPF phase lag
                                             * + BEMF attenuation both grow with speed, conf
                                             * falls 0.58->0.50 across 14->16.7k). */
#define AN_FAULTCODE_FASTOC         0xFCu   /* engine faultCode for the fast-OC latch */

/** Speed reference ramp limit: AN1078 = Q15(0.00003) per IRP_PERCALC tick.
 *  In their RPM-Q15 form that's tiny.  We treat as rad/s electrical per tick. */
#define AN_SPEEDREF_RAMP_RAD_S      1.0f

/** Number of IRP_PERCALC ticks between speed-PI updates. */
#define AN_SPEEDREFRAMP_COUNT       3

/* ── PI gains (continuous form) ───────────────────────────────────
 *
 * AN1078 uses Q15 PI:
 *   D_CURRCNTR_PTERM = 0.02 (Q15)   — proportional gain
 *   D_CURRCNTR_ITERM = 0.001 (Q15)  — applied once per tick
 *   D_CURRCNTR_CTERM = 0.999 (Q15)  — anti-windup back-calc
 *
 * Q15 PI dimensional analysis:
 *   In Q15, voltage and current are both [-1..1) of full-scale.
 *   For our motor: V_FS = Vbus = 24 V, I_FS = 22 A_peak.
 *   So Q15-Kp = 0.02 means: 0.02 × (V_FS / I_FS) = 0.02 × 24/22 = 0.022 V/A
 *   And Q15-Ki = 0.001 per tick at 20 kHz = 20 V/A·s continuous.
 *
 * For 2810 (Rs=22 mΩ, Ls=10 µH), pole-cancellation gives:
 *   Kp = bw × Ls,  Ki = bw × Rs
 * For bw = 2π·1000 = 6283 rad/s:  Kp = 0.063 V/A,  Ki = 138 V/A·s.
 *
 * Use those values — they came from v2 detection on this same motor. */

/* 2026-07-09 U3 KV700 retune: Kp = bw·Ls, Ki = bw·Rs (pole-cancellation).
 * bw ≈ 4900 rad/s; Ls=18µH → Kp=0.088, Rs=25mΩ → Ki=122. Was 0.063/138
 * (2810, 10µH/22mΩ): those gains on the U3's ~2× inductance mis-scaled the
 * current loop and it overshot the 4A align command into the 15A phase-OC. */
/* GAIN-16 FIX: ÷k (0.088/2.27325, 122/2.27325). err is now true amps (k× the
 * old fake), so ÷k keeps the current loop byte-identical to the validated drive
 * — effective bw ≈ 2160 rad/s. (Full designed bw·Ls would be 0.088 again = 4900
 * rad/s; raise toward that as a deliberate, separately-verified bandwidth bump.) */
#define AN_KP_DQ                    0.038712f
#define AN_KI_DQ                    53.668f

/* Speed PI:
 *   AN1078: SPEEDCNTR_PTERM = 0.5 Q15, SPEEDCNTR_ITERM = 0.005 Q15.
 *   Kp dim: A_FS/ω_FS = 22 A / (3500 RPM × 5 PP × 2π/60) = 22/1833 = 0.012 A·s/rad
 *   Q15 Kp = 0.5 → 0.5 × 0.012 = 0.006 A·s/rad (units: amps per rad/s).
 *
 * For 2810 use modest values; we'll tune from bench. */

/* Speed PI: bumped 2026-04-26 after OL→CL integrator-reset fix made it
 * safe to run aggressive gains without handoff overshoot.  Original
 * 0.006/0.10 was too sluggish (4 seconds for +15k eRPM under throttle).
 * Tracking speed comes from BOTH AN_CL_VELREF_SLEW_RPS2 (slewing the
 * setpoint) AND the speed PI (closing the loop on it).  Need decent
 * KP for the latter to actually track. */
/* GAIN-16 FIX: ×k (0.015·2.27325, 0.08·2.27325). Speed-PI output IS iq_ref (A),
 * so ×k makes it command the same PHYSICAL current now expressed in true amps. */
#define AN_KP_SPD                   0.034099f
#define AN_KI_SPD                   0.181860f /* 2026-07-11 MCLV-port 0.30->0.08 (×k): P-dominant speed
                                             * loop. A high Ki turns residual OmegaFltred noise
                                             * into a handoff OC windup; pairs with the OmegaFltred
                                             * LPF (like MCLV / stock AN1078).
                                             * 0.08->0.02 TRIED 2026-07-11 (with DT-comp angle fix
                                             * in, st~-9deg): no-prop STILL OC'd at handoff
                                             * (iqM->9A), UNCHANGED by the 4x Ki cut. => the OC is
                                             * NOT speed-PI windup; it's a fast ~1-tick commit
                                             * transient. Reverted 0.02->0.08 (cut did nothing).
                                             * Handoff OC needs INSTRUMENTATION, not gain guesses. */

/** OL->CL speed-PI Iq PRELOAD (2026-07-11 BENCH, U3+prop @16V). Was preloaded
 *  to AN_Q_CURRENT_REF_OPENLOOP (5A) at an1078_motor.c:478. Bench: every HELD
 *  handoff entered CL at iqM<=5.5A and iqRef wound DOWN to the ~0.8A steady
 *  state; every FAILED handoff entered >=6.1A and iqRef wound UP to the 8A
 *  fast-OC. The 5A preload is pure transient headroom feeding the trip. Lower
 *  it so at handoff the current loop is commanded DOWN toward steady state
 *  (away from 8A), even on a marginal-angle commit. velRef=OmegaFltred already
 *  gives bumpless speed, so we don't need 5A of torque headroom here. Keep OL
 *  ramp at 5A (unchanged) for ramp authority. REVERT: set = AN_Q_CURRENT_REF_OPENLOOP. */
#define AN_HANDOFF_IQ_PRELOAD       4.5465f /* GAIN-16 FIX ×k (was 2.0). OL->CL iq preload, true amps */

/* Anti-windup back-calculation gain (1.0 = no anti-windup, 0 = full).
 * 2026-07-09: 0.999 (disabled) -> 0.5. Bench proof: when iq_ref hit its
 * clamp under load, the speed-PI integrator wound to -17 (telemetry
 * iqRef~), so on unload torque returned only after a long crawl-back =
 * the deep sag-and-slow-recover. 0.5 enables real back-calc so the clamp
 * is a graceful ceiling. Shared by pi_spd/pi_d/pi_q (also stops q-current
 * integrator windup at the voltage clamp). Tunable 0.0..0.999. */
#define AN_PI_KC                    0.5f

/* ── Voltage clamps ───────────────────────────────────────────── */

/** Maximum voltage vector magnitude as fraction of Vbus.  AN1078: 0.98. */
#define AN_MAX_VOLTAGE_VECTOR_FRAC  0.95f

/* ── Overmodulation + inner-loop anti-windup (2026-07-14, GarudaESE bench) ──
 * Above ~56k the U3 drive is voltage-limited: the CL vector is capped at
 * FRAC * Vbus/sqrt(3), i.e. FRAC of the *linear-region* SVPWM inscribed circle.
 * D1 (one-sample delay comp) broke the period-2 bounce and reached 64k, but the
 * duty is now pinned against this ceiling with headroom still wanted toward the
 * 78.4k physical ceiling (KV700 * 16V * 7pp).  Overmodulation lets the CL vector
 * reach into the hexagon (six-step edge at FRAC ~= 1.103 = (2/pi)/(1/sqrt(3))),
 * buying real voltage headroom.  The min-max centered SVPWM + [0,1] duty clamp
 * already produce the overmodulation flat-top waveform, so ONLY the CL vmax frac
 * changes; OL/ALIGN keep the linear AN_MAX_VOLTAGE_VECTOR_FRAC (0.95).
 * Paired with full back-calculation anti-windup on the d/q current PIs so their
 * integrators don't wind up when the vector saturates against the (now higher)
 * ceiling on a bus sag -- kills the residual clamp-bounce the user saw at max pot.
 * Both behind AN_OVERMOD_EN so the proven <=56k behavior is one flag away. */
#define AN_OVERMOD_EN        1
#define AN_OVERMOD_FRAC      1.05f   /* CL-only vector frac; 1.0 = linear edge, 1.103 = six-step */
#define AN_PI_KC_CURRENT     0.0f    /* d/q PI back-calc coeff: 0.0 = full anti-windup */

/** Hard voltage ceiling during standstill LOCK (safety ceiling only).
 *  FOC 2026-07-10: raised 0.15 -> 2.5 now that the current-feedback path is
 *  PROVEN on this board (open-loop runs read believable idM/iqM; the scale then
 *  was 0.011078 A/count, since corrected to 0.025183 by the gain-16 fix). The
 *  old 0.1 V "align needs only 4*0.025"
 *  estimate ignored the ATA6847 dead-band, which eats ~90% of the commanded
 *  voltage at low modulation -> 0.15 V reached almost zero current and the
 *  current PI could never hit its 4 A target. The PI now SEES current so it
 *  self-limits at whatever voltage gives 4 A (~1.2 V through the dead-band);
 *  this clamp is just a worst-case ceiling: 2.5 V / 0.025 ohm bounded by the
 *  ~10x dead-band loss -> ~10 A worst case, bench-safe with the PSU limit.
 *  If a brownout (rc=0082) ever returns, the current loop went blind again
 *  -> drop this back to 0.15 and scope RA2/RB0. */
#define AN_ALIGN_VOLT_CLAMP         2.5f

/* ── SMC observer ─────────────────────────────────────────────── */

/** Slide-mode controller gain (V).  Z signal feeds the current-model
 *  alongside V and E.  AN1078's 0.85·Vbus = 20.4V is way too aggressive
 *  for low-impedance motors like 2810 (Rs=22mΩ).  Z saturates on any
 *  small model error → LPF averages near zero → BEMF buried.
 *
 *  Empirical: keep Z in linear range relative to actual V swings.
 *  Steady-state V is ~0.5V — set Kslide ~5x bigger to allow fast
 *  correction without saturating.  Bumping above this breaks
 *  low-speed handoff (Z dominates over weak BEMF, observer can't lock). */
#define AN_SMC_KSLIDE               2.5f

/** Maximum linear-region current error (A).  Below this, Z = K·err/MaxErr;
 *  above, Z saturates at ±K.  Bigger boundary keeps Z in linear range
 *  for 4A-class operating currents on low-impedance motors.
 *  GAIN-16 FIX / RETIRED 2026-07-14: now that AN_OBS_CURRENT_COMPAT=1.0 feeds the
 *  observer TRUE amps, this boundary is ×k (1.0 -> 2.27325) so Z's linear region
 *  spans the same PHYSICAL current-error range as before the rescale. This pair
 *  moves together with AN_OBS_CURRENT_COMPAT; revert both if observer lock
 *  degrades on the bench. */
#define AN_SMC_MAX_LINEAR_ERR       2.27325f

/** Phase shift applied to atan2 output (radians).
 *
 * theta_offset = AN_SMC_THETA_OFFSET_BASE + AN_SMC_THETA_OFFSET_K × ω
 *
 * BASE: calibrated at 366 rad/s → 20° (0.349 rad).
 * K:    speed coefficient.  At higher speeds the SMC's LPF phase
 *       relationship to fundamental shifts; observer angle drifts.
 *       Tune K so Id stays near zero across the operating range.
 *
 * Tuning: run motor at low and high speed, read Id at each:
 *   - Low speed (366 rad/s):  set BASE so Id ≈ 0 there
 *   - Medium speed (~5000 rad/s): observe Id; if positive, K negative
 *     (subtract more from offset at higher ω); if negative, K positive
 *   - K_initial = 0 (constant offset).  Step in -1e-5 increments.
 *
 * AN1078 reference uses BASE=π/2, K=0.  Our 2810 needed BASE=20°.
 * K=0 worked clean up to ~80k eRPM, then observer started losing it. */
#define AN_SMC_THETA_OFFSET_BASE    0.349f         /* 20° at zero speed */
#define AN_SMC_THETA_OFFSET_K       1.0e-4f        /* rad per (rad/s elec) — post FS_HZ fix: observer leads 29° at 115k with K=1.5e-4 → trim */

/* Backwards-compat alias for code that hardcodes a single constant. */
#define AN_SMC_THETA_OFFSET         AN_SMC_THETA_OFFSET_BASE

/* ── Super-twisting observer seeds (FEATURE_AN_STA) — spec §5.4 ──────
 * Fixed-gain bring-up values for U3 (λ=1.125e-3 V·s/rad, E_max≈9 V @
 * 8000 rad/s). k2·Ts=4000·22.2µs=0.089 < 0.05·E_max=0.45 (discretization
 * safe). Tune on the bench; these are the 0→default fallbacks for the
 * live GSP params. */
#define AN_STA_K1B_DEFAULT           2.0f      /* z = k1·√|s| damping   */
#define AN_STA_K2B_DEFAULT           4000.0f   /* w ramp rate (V/s)     */
#define AN_STA_WCLAMP_FLOOR_DEFAULT  2.0f      /* anti-windup floor (V) */
#define AN_STA_THETAKLAT_DEFAULT     2.22e-5f  /* PLL discretization ≈1·Ts */

/** BEMF LPF coefficient scale factor (per |ω| in rad/s electrical).
 *
 * AN1078 default: AN_TS (1·Ts).  Earlier 3·Ts gave better low-speed
 * bootstrap on 2810 but Kslf saturated at high speed (Kslf=1 means
 * LPF passes Z directly, observer breaks down past ~8000 rad/s elec).
 *
 * Use 1·Ts (AN1078 default) — Kslf saturates only above 24000 rad/s
 * elec (~230k eRPM at 7PP).  Low-speed bootstrap relies on
 * AN_SMC_KSLF_MIN floor instead. */
/* 2026-07-13: AN_TS -> 2*AN_TS.  Bench proof the ceiling is filter-limited,
 * not correction-gain-limited: raising Kslide (2500->4000) AND ThetaK
 * (800->1000) LIVE did NOT move the ~18,750 eRPM ceiling at all -- and
 * neither of those touches Kslf.  Root cause: k = velRef*SCALE, and with
 * SCALE=AN_TS the whole operating band sits BELOW the KslfMin=0.05 floor
 * (floor releases only at velRef > 0.05/AN_TS = 2250 rad/s = ~21.5k eRPM,
 * which is ABOVE where it desyncs).  So the BEMF-LPF cutoff is pinned at a
 * fixed 2250 rad/s -> attenuation+lag climb with speed -> conf slides
 * 0.58->0.44 -> observer cliff.  Doubling SCALE lifts k off the floor at
 * ~10.7k eRPM so the cutoff tracks speed (const attenuation instead of
 * worsening).  New KslfMax=0.85 saturation now at 0.85/(2*AN_TS)=19125 rad/s
 * = ~182k eRPM, well clear.  RE-NULL ThetaBase (0x90) after flashing -- less
 * lag means less offset needed; st negative -> lower 0x90, positive -> raise. */
#define AN_SMC_KSLF_SCALE           (2.0f * AN_TS)

/** Minimum Kslf — bootstrap floor at low speeds.  0.05 gives cutoff
 *  191 Hz, enough headroom for our 366 rad/s end-speed (58 Hz fund). */
#define AN_SMC_KSLF_MIN             0.05f

/** Maximum Kslf — cap below 1.0 so LPF retains filtering action even
 *  at very high speeds.  Each tick: y += Kslf·(x - y).  Kslf=0.5 →
 *  saturation at ω = 0.5 / Ts·SCALE = 12000 rad/s (114k eRPM at 7PP).
 *  Above that, the LPF cutoff stops scaling with speed and observer
 *  phase response degrades.
 *
 *  Bumped to 0.85 → saturation at ~204k eRPM, gives headroom for
 *  full-speed runs.  Above 0.85 LPF approaches passthrough; observer
 *  noise rejection collapses, so don't push higher. */
#define AN_SMC_KSLF_MAX             0.85f

/* ── Theta_error bleed (CL transition) ───────────────────────────
 *
 * AN1078 pmsm.c bleeds 0.05° each tick subject to (trans_counter==0)
 * which is true 1 of every TRANSITION_STEPS ticks.
 * Effective rate = 0.05° / (TRANSITION_STEPS × Ts) ≈ 200°/s.
 *
 * For 2810 (low Ke), observer angle has small drift — slow bleed gives
 * observer time to settle and avoids accumulated angle error in CL.
 * Smaller bleed step = slower migration from OL angle to observer angle. */
#define AN_THETA_ERROR_BLEED_RAD    (0.005f * 3.14159265f / 180.0f) /* 10x slower */

/* ── Throttle deadband (ADC counts) ───────────────────────────── */
#define AN_THROTTLE_DEADBAND        50

#ifdef __cplusplus
}
#endif

#endif /* AN1078_PARAMS_H */
