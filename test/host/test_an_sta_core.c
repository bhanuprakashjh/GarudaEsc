/* Host unit test for an_sta_step() — no hardware.
 * Build:  see the compile command in the task report (defines AN_STA_HOST_TEST
 *         to drop the gsp wrapper, and supplies PLL_* + AN_* macros the core
 *         references, plus two harness pre-trip macros — see below). */

/* --- harness pre-trip: an1078_sta.c -> an1078_sta.h -> an1078_smc.h ->
 * "../garuda_config.h" for FEATURE_AN_STA. The real garuda_config.h hard-
 * defines FEATURE_AN_STA 0 (shipped default), which would compile
 * an_sta_step() out entirely (it's wrapped in #if FEATURE_AN_STA) and drop
 * the AN_SMC_T STA fields (wIntA/k1/thetaBaseSTA/...) from the struct. Skip
 * the real header by pre-tripping its include guard and force the flag on
 * ourselves, BEFORE any #include. */
#define GARUDA_CONFIG_H   /* pre-trip: skip real garuda_config.h so our flag wins */
#define FEATURE_AN_STA 1

#include <stdio.h>
#include <math.h>
#include <stdint.h>
#include <string.h>   /* memset — needed by AN_SMC_T zero-init below */

/* --- macros the core + PLL reference (host stand-ins for the real headers) --- */
#define GARUDA_FOC_PARAMS_H            /* pre-trip: skip the real garuda_foc_params.h */
#define PLL_ANGLE_OFFSET   1.5707963f
#define PLL_KP             628.0f
#define PLL_KI             98600.0f
#define PLL_SPEED_CLAMP    12000.0f
#define AN_OMEGA_FILT_COEF 0.05f
#define AN_IRP_PERCALC     10

#include "../../foc/pll_estimator.c"   /* pure PLL math */
#include "../../foc/an1078_sta.c"      /* AN_STA_HOST_TEST set on cmdline → core only */

int main(void)
{
    /* Synthetic SPM at constant electrical speed, Rs=0 so applied V == back-EMF,
     * measured current held at 0 (the correct steady estimate is EstI=0, z=E). */
    const float Ts     = 1.0f / 45000.0f;
    const float w_true = 4000.0f;          /* rad/s elec (+ve rotation)          */
    const float Ls     = 18e-6f;
    const float lambda = 1.125e-3f;        /* V·s/rad (U3)                        */
    const float E_max  = w_true * lambda;  /* ≈ 4.5 V                             */

    AN_SMC_T s; memset(&s, 0, sizeof s);
    s.Fsmopos = 1.0f - 0.0f * Ts / Ls;     /* Rs=0 → 1.0 */
    s.Gsmopos = Ts / Ls;
    pll_reset(&s.pll);

    float theta = 0.0f;
    const float k1 = 2.0f, k2 = 4000.0f, wClamp = 8.0f;
    for (int n = 0; n < 20000; n++) {      /* ~0.44 s */
        theta += w_true * Ts;
        if (theta >= 6.2831853f) theta -= 6.2831853f;
        /* back-EMF vector (PMSM αβ convention): eα=-Emax sinθ, eβ=+Emax cosθ */
        s.Valpha = -E_max * sinf(theta);
        s.Vbeta  =  E_max * cosf(theta);
        s.Ialpha = 0.0f;  s.Ibeta = 0.0f;  /* Rs=0, ideal steady */
        an_sta_step(&s, k1, k2, wClamp, 0.0f, 0.0f, Ts);
    }

    float z_mag  = sqrtf(s.EalphaFinal*s.EalphaFinal + s.EbetaFinal*s.EbetaFinal);
    float w_est  = s.pll.omega_est;
    /* Rotor angle reference: `theta` IS the rotor electrical angle used above to
     * synthesize eα=-Emax sinθ, eβ=Emax cosθ. Algebraically that vector's own
     * angle is (θ+π/2) (cos(θ+π/2)=-sinθ, sin(θ+π/2)=cosθ) — i.e. the BEMF
     * vector LEADS the rotor by π/2. an_sta_step() step 7 does
     * Theta = pll.theta_est(≈θ+π/2) - PLL_ANGLE_OFFSET(π/2) = θ, so the
     * correct convergence target is `theta` itself, not `theta - π/2` (that
     * would double-subtract the same π/2 offset the core already removes). */
    float th_ref = theta; if (th_ref < 0) th_ref += 6.2831853f;
    float th_err = fabsf(s.Theta - th_ref);
    if (th_err > 3.14159f) th_err = 6.2831853f - th_err;

    printf("z_mag=%.3f (E_max=%.3f)  w_est=%.1f (w_true=%.1f)  th_err=%.3f rad\n",
           z_mag, E_max, w_est, w_true, th_err);

    int ok = 1;
    if (fabsf(z_mag - E_max) > 0.15f * E_max) { printf("FAIL: |z| off\n"); ok = 0; }
    if (w_est < 0.0f)                          { printf("FAIL: speed sign inverted (runs backwards)\n"); ok = 0; }
    if (fabsf(w_est - w_true) > 0.10f * w_true){ printf("FAIL: speed magnitude off\n"); ok = 0; }
    if (th_err > 0.15f)                        { printf("FAIL: angle not locked\n"); ok = 0; }
    printf(ok ? "PASS\n" : "FAIL\n");
    return ok ? 0 : 1;
}
