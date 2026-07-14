/**
 * @file  an1078_sta.c
 * @brief Super-twisting SMO — pure core + live-tune wrapper.
 *
 * an_sta_step()  : pure float math, NO gsp/hardware includes (host-testable).
 * AN_STA_Position_Estimation() : reads gspParams, computes gains, calls core.
 */
#include "an1078_sta.h"
#include "pll_estimator.h"
#include <math.h>

#ifndef AN_STA_HOST_TEST
#include "an1078_params.h"          /* AN_TS, AN_OMEGA_FILT_COEF, AN_MOTOR_LS */
#include "../garuda_foc_params.h"   /* PLL_ANGLE_OFFSET */
#include "../gsp/gsp_params.h"      /* gspParams — live tuning */
#endif

#define STA_TWO_PI  6.28318530717958647692f
#define STA_PI      3.14159265358979323846f

/* ── file-local math helpers (mirror an1078_smc.c) ─────────────── */
static inline float sta_abs(float x) { return (x >= 0.0f) ? x : -x; }
static inline float sta_sgn(float x) { return (x > 0.0f) ? 1.0f : ((x < 0.0f) ? -1.0f : 0.0f); }
static inline float sta_wrap_2pi(float th)
{
    while (th >= STA_TWO_PI) th -= STA_TWO_PI;
    while (th <  0.0f)       th += STA_TWO_PI;
    return th;
}
static inline float sta_wrap_delta(float d)
{
    if (d >  STA_PI) d -= STA_TWO_PI;
    if (d < -STA_PI) d += STA_TWO_PI;
    return d;
}

/* ── Pure per-tick core (host-testable) ────────────────────────── */
void an_sta_step(AN_SMC_T *s, float k1, float k2, float wClamp,
                 float thetaBase, float thetaKlat, float Ts)
{
    /* 1. SPM predictor — z (held in Zalpha/Zbeta from the previous tick)
     *    IS the EMF estimate, so there is no separate E term to subtract. */
    s->EstIalpha = s->Fsmopos * s->EstIalpha + s->Gsmopos * (s->Valpha - s->Zalpha);
    s->EstIbeta  = s->Fsmopos * s->EstIbeta  + s->Gsmopos * (s->Vbeta  - s->Zbeta);

    /* 2. Sliding surfaces */
    float sa = s->EstIalpha - s->Ialpha;
    float sb = s->EstIbeta  - s->Ibeta;
    s->IalphaError = sa;
    s->IbetaError  = sb;

    /* 3. Super-twisting law (z continuous by construction) */
    float za = k1 * sqrtf(sta_abs(sa)) * sta_sgn(sa) + s->wIntA;
    float zb = k1 * sqrtf(sta_abs(sb)) * sta_sgn(sb) + s->wIntB;
    s->wIntA += Ts * k2 * sta_sgn(sa);
    s->wIntB += Ts * k2 * sta_sgn(sb);

    /* 4. Anti-windup clamp on the integral term */
    if (s->wIntA >  wClamp) s->wIntA =  wClamp;
    if (s->wIntA < -wClamp) s->wIntA = -wClamp;
    if (s->wIntB >  wClamp) s->wIntB =  wClamp;
    if (s->wIntB < -wClamp) s->wIntB = -wClamp;

    /* 5. z = extended EMF (unfiltered). Persist for next predictor tick and
     *    overlay the existing telemetry slots (readers pick z up unchanged). */
    s->Zalpha = za;  s->Zbeta = zb;
    s->Ealpha = za;  s->Ebeta = zb;
    s->EalphaFinal = za;  s->EbetaFinal = zb;

    /* 6. PLL back-end — z fed straight in (no LPF) */
    pll_update(&s->pll, za, zb, Ts);

    /* 7. Angle: subtract π/2 (BEMF→rotor) + residual offset pair.
     *    Geometric sample→apply latency is compensated downstream. */
    float dyn = thetaBase + thetaKlat * sta_abs(s->pll.omega_est);
    s->Theta = sta_wrap_2pi(s->pll.theta_est - PLL_ANGLE_OFFSET + dyn);

    /* 8. Diagnostic copies for telemetry/debug */
    s->k1 = k1;  s->k2 = k2;
    s->wClampFloorSTA = wClamp;
    s->thetaBaseSTA = thetaBase;
    s->thetaKlatSTA = thetaKlat;

    /* 9. Speed: LPF the PLL speed (same as boundary path) */
    s->OmegaFltred += AN_OMEGA_FILT_COEF * (s->pll.omega_est - s->OmegaFltred);

    /* 10. Keep the IRP-averaged Omega telemetry field running */
    {
        float dth = sta_wrap_delta(s->Theta - s->PrevTheta);
        s->AccumTheta += dth;
        s->PrevTheta = s->Theta;
    }
    s->AccumThetaCnt++;
    if (s->AccumThetaCnt >= AN_IRP_PERCALC) {
        s->Omega = s->AccumTheta / ((float)AN_IRP_PERCALC * Ts);
        s->AccumTheta = 0.0f;
        s->AccumThetaCnt = 0;
    }
}

#ifndef AN_STA_HOST_TEST
/* ── Live-tune helpers (read gspParams; 0 → compile-time default) ── */
static inline float an_tune_sta_k1b(void)
{ uint16_t v = gspParams.staK1bMilli; return (v != 0) ? (float)v * 0.001f : AN_STA_K1B_DEFAULT; }
static inline float an_tune_sta_k1a(void)
{ return (float)gspParams.staK1aE6 * 1.0e-6f; }
static inline float an_tune_sta_k2b(void)
{ uint16_t v = gspParams.staK2b; return (v != 0) ? (float)v : AN_STA_K2B_DEFAULT; }
static inline float an_tune_sta_k2a(void)
{ return (float)gspParams.staK2aE6 * 1.0e-6f; }
static inline float an_tune_sta_wclamp_floor(void)
{ uint16_t v = gspParams.staWClampFloorMv; return (v != 0) ? (float)v * 0.001f : AN_STA_WCLAMP_FLOOR_DEFAULT; }
static inline float an_tune_sta_theta_base(void)
{ return (float)gspParams.staThetaBaseDegX10 * 0.1f * (STA_PI / 180.0f); }
static inline float an_tune_sta_theta_klat(void)
{ uint16_t v = gspParams.staThetaKlatE7; return (v != 0) ? (float)v * 1.0e-7f : AN_STA_THETAKLAT_DEFAULT; }

/* ── Wrapper: compute live gains + speed-exact clamp, call the core ── */
void AN_STA_Position_Estimation(AN_SMC_T *s)
{
    float w = sta_abs(s->pll.omega_est);

    float k1 = an_tune_sta_k1b() + an_tune_sta_k1a() * w;
    float k2 = an_tune_sta_k2b() + an_tune_sta_k2a() * w * w;

    /* λ from active profile (µV·s/rad → V·s/rad); floor covers λ==0. */
    float lambda = (float)gspParams.focKeUvSRad * 1.0e-6f;
    float wClamp = 1.3f * w * lambda;
    float floor  = an_tune_sta_wclamp_floor();
    if (wClamp < floor) wClamp = floor;

    an_sta_step(s, k1, k2, wClamp,
                an_tune_sta_theta_base(), an_tune_sta_theta_klat(), AN_TS);
}
#endif /* !AN_STA_HOST_TEST */
