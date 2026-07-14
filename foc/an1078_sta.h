/**
 * @file  an1078_sta.h
 * @brief Super-twisting sliding-mode observer (FEATURE_AN_STA).
 *
 * Compile-time alternative to AN_SMC_Position_Estimation(). SPM predictor
 * (no EEMF), continuous z = super-twisting output fed straight into the
 * shared AN1292 PLL back-end — no LPF, no ThetaBase/ThetaK lag-comp.
 * See docs/superpowers/specs/2026-07-14-an-sta-observer-design.md.
 */
#ifndef AN1078_STA_H
#define AN1078_STA_H

#include "an1078_smc.h"   /* AN_SMC_T (pulls garuda_config.h → FEATURE_AN_STA) */

#ifdef __cplusplus
extern "C" {
#endif

/* Run one super-twisting observer step (drop-in for AN_SMC_Position_Estimation). */
void AN_STA_Position_Estimation(AN_SMC_T *s);

#ifdef __cplusplus
}
#endif

#endif /* AN1078_STA_H */
