/**
 * @file  motors.h
 * @brief Single per-motor source of truth — physical + envelope primitives.
 *
 * One `#if MOTOR_PROFILE == N` block per motor selects the motor's PHYSICAL
 * constants (pole pairs, phase Rs/Ls, flux linkage λ) plus a few envelope
 * anchors (KV, nominal Vbus, current/speed caps). Every consumer that needs a
 * motor's electrical model reads the `M_*` macros from here instead of
 * re-declaring its own copy — this is what keeps the AN1078 observer model,
 * the 6-step FOC model, and the host tooling agreed on what each profile IS.
 *
 * WHY THIS FILE EXISTS: profile 2 used to be declared twice with DIFFERENT
 * numbers — `an1078_params.h` had it as the U3 KV700 (the live bench motor)
 * while `garuda_foc_params.h` still had the legacy 2810 1350KV. `motors.h`
 * collapses that to one authoritative block per motor.
 *
 * λ CONVENTION: M_FLUX_LINKAGE is the per-phase peak flux linkage in
 * V·s/rad_electrical, λ = 60 / (√3·2π·KV·PP). Same quantity the AN1078 port
 * calls AN_MOTOR_LAMBDA and the 6-step path calls MOTOR_KE_VPEAK.
 *
 * VALIDATION STATUS: only profile 2 (U3 KV700) is BENCH-VALIDATED for the
 * sensorless-FOC/observer path (holds ~76k eRPM no-load @16V, 2026-07-15).
 * The other six blocks are PHYSICS-DERIVED SEEDS (datasheet KV/PP, measured
 * or estimated Rs/Ls, λ from the formula above). They will let a build for
 * that profile come up, but the observer gains and startup envelope still
 * want a bench sweep before the profile is trusted — each is stamped below.
 *
 * Units: SI (ohms, henries, volts, amps, V·s/rad_elec, rad/s electrical).
 */
#ifndef GARUDA_MOTORS_H
#define GARUDA_MOTORS_H

#include "garuda_config.h"   /* MOTOR_PROFILE */

#ifndef MOTOR_PROFILE
#  error "motors.h: MOTOR_PROFILE is undefined — include garuda_config.h first"
#endif

/* ═══════════════════════════════════════════════════════════════════════════
 * Per-motor primitive blocks. Add a motor by adding an #elif with its M_*.
 * Keep the names identical across every block — consumers depend on all of
 * them being present for whichever profile is selected.
 * ═══════════════════════════════════════════════════════════════════════════ */

#if   MOTOR_PROFILE == 0
/* ── Hurst DMB2424B10002 — 10-pole gearmotor, 24 V bench. PHYSICS SEED. ── */
#  define M_NAME              "Hurst"
#  define M_POLE_PAIRS        5
#  define M_KV                150.0f       /* ≈ 60/(√3·2π·λ·PP) from λ=0.00742 */
#  define M_VBUS_NOM_V        24.0f
#  define M_RS_OHM            0.534f
#  define M_LS_H              0.000471f    /* 471 µH — high-inductance Hurst */
#  define M_FLUX_LINKAGE      0.00742f
#  define M_MAX_CURRENT_A     10.0f
#  define M_MAX_ELEC_RAD_S    2000.0f
#  define M_PLL_MAX_ELEC_RAD_S M_MAX_ELEC_RAD_S
/* FOC UNVALIDATED — bench the observer/startup before trusting. */

#elif MOTOR_PROFILE == 1
/* ── A2212 1400KV — 14-pole drone motor, 12 V. PHYSICS SEED (6-step proven,
 *    FOC observer path not bench-tuned). ── */
#  define M_NAME              "A2212-1400KV"
#  define M_POLE_PAIRS        7
#  define M_KV                1400.0f
#  define M_VBUS_NOM_V        12.0f
#  define M_RS_OHM            0.065f
#  define M_LS_H              30e-6f
#  define M_FLUX_LINKAGE      0.000563f    /* 60/(√3·2π·1400·7) */
#  define M_MAX_CURRENT_A     15.0f
#  define M_MAX_ELEC_RAD_S    6000.0f
#  define M_PLL_MAX_ELEC_RAD_S M_MAX_ELEC_RAD_S
/* FOC UNVALIDATED — bench the observer/startup before trusting. */

#elif MOTOR_PROFILE == 2
/* ── T-Motor U3 KV700 — 14-pole (7PP), 16 V bench. BENCH-VALIDATED. ──
 *  Sensorless AN1078 FOC holds ~76k eRPM no-load @16V (2026-07-15). These
 *  are the authoritative U3 values; they REPLACE the legacy 2810 numbers
 *  that garuda_foc_params.h profile-2 still carries for the inactive 6-step
 *  path. Ceiling @16V ≈ 700·16·7 = 78.4k eRPM. */
#  define M_NAME              "U3-KV700"
#  define M_POLE_PAIRS        7
#  define M_KV                700.0f
#  define M_VBUS_NOM_V        16.0f
#  define M_RS_OHM            0.025f       /* U3 datasheet Rm=50mΩ pp / 2 */
#  define M_LS_H              18e-6f       /* from 5055 sibling class */
#  define M_FLUX_LINKAGE      0.001125f    /* 60/(√3·2π·700·7) */
#  define M_MAX_CURRENT_A     10.0f
#  define M_MAX_ELEC_RAD_S    8000.0f      /* ~76k eRPM bench ceiling @16V */
#  define M_PLL_MAX_ELEC_RAD_S 10000.0f    /* phantom-runaway clamp (~95.5k) */

#elif MOTOR_PROFILE == 3
/* ── 5055 ~580KV — 14-pole, 4S/14.8 V. PHYSICS SEED. ── */
#  define M_NAME              "5055-580KV"
#  define M_POLE_PAIRS        7
#  define M_KV                580.0f
#  define M_VBUS_NOM_V        14.8f
#  define M_RS_OHM            0.050f
#  define M_LS_H              17.5e-6f
#  define M_FLUX_LINKAGE      0.001355f    /* 60/(√3·2π·580·7) */
#  define M_MAX_CURRENT_A     25.0f
#  define M_MAX_ELEC_RAD_S    7000.0f
#  define M_PLL_MAX_ELEC_RAD_S M_MAX_ELEC_RAD_S
/* FOC UNVALIDATED — bench the observer/startup before trusting. */

#elif MOTOR_PROFILE == 4
/* ── Cobra CM-2814/36 470KV — 14-pole, high-R/heavy, 24 V. PHYSICS SEED. ── */
#  define M_NAME              "Cobra-2814"
#  define M_POLE_PAIRS        7
#  define M_KV                470.0f
#  define M_VBUS_NOM_V        24.0f
#  define M_RS_OHM            0.094f
#  define M_LS_H              30.0e-6f      /* ESTIMATE — measure */
#  define M_FLUX_LINKAGE      0.001674f    /* 60/(√3·2π·470·7) */
#  define M_MAX_CURRENT_A     17.0f
#  define M_MAX_ELEC_RAD_S    9000.0f
#  define M_PLL_MAX_ELEC_RAD_S M_MAX_ELEC_RAD_S
/* FOC UNVALIDATED — bench the observer/startup before trusting. */

#elif MOTOR_PROFILE == 5
/* ── Hobbywing XRotor 3110 1150KV — 14-pole, low-R/high-KV, 24 V. SEED. ── */
#  define M_NAME              "XRotor-3110"
#  define M_POLE_PAIRS        7
#  define M_KV                1150.0f
#  define M_VBUS_NOM_V        24.0f
#  define M_RS_OHM            0.022f
#  define M_LS_H              10.0e-6f      /* ESTIMATE — measure */
#  define M_FLUX_LINKAGE      0.000685f    /* 60/(√3·2π·1150·7) */
#  define M_MAX_CURRENT_A     10.0f
#  define M_MAX_ELEC_RAD_S    22000.0f
#  define M_PLL_MAX_ELEC_RAD_S M_MAX_ELEC_RAD_S
/* FOC UNVALIDATED — bench the observer/startup before trusting. */

#elif MOTOR_PROFILE == 6
/* ── VEX 14mm 4000KV micro — 12-pole (6PP), 10 V max. PHYSICS SEED
 *    (6-step proven on AK512, FOC observer path not bench-tuned). ── */
#  define M_NAME              "VEX-4000KV"
#  define M_POLE_PAIRS        6
#  define M_KV                4000.0f
#  define M_VBUS_NOM_V        10.0f
#  define M_RS_OHM            0.22f
#  define M_LS_H              9.2e-6f
#  define M_FLUX_LINKAGE      0.000230f    /* 60/(√3·2π·4000·6) */
#  define M_MAX_CURRENT_A     7.2f
#  define M_MAX_ELEC_RAD_S    25000.0f
#  define M_PLL_MAX_ELEC_RAD_S M_MAX_ELEC_RAD_S
/* FOC UNVALIDATED — bench the observer/startup before trusting. */

#else
#  error "motors.h: unknown MOTOR_PROFILE — add an #elif block for it"
#endif

#endif /* GARUDA_MOTORS_H */
