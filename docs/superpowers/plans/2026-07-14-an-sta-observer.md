# FEATURE_AN_STA Super-Twisting Observer — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a super-twisting sliding-mode observer as a compile-time
alternative (`FEATURE_AN_STA`) to the shipped AN1078 boundary-layer SMO, for a
bench A/B race on the GarudaESE U3 KV700 drive.

**Architecture:** New self-contained observer body `an_sta_step()` (pure float
math, no hardware includes) + a live-tune wrapper `AN_STA_Position_Estimation()`,
both in `foc/an1078_sta.c`. Reuses the existing `AN_SMC_T` struct and the
`pll_estimator` back-end. The shipped `AN_SMC_Position_Estimation()` path is
untouched; a single `#if FEATURE_AN_STA` at the call site selects the observer.
Every STA addition is guarded by the flag (default `0`), so the shipped binary is
byte-identical until the flag is flipped.

**Tech Stack:** C (C99), Microchip XC-DSC v3.30, dsPIC33AK256MC506, single-
precision FPU. Host unit test in C compiled with system `gcc`.

## Global Constraints

- Firmware source spec: `docs/superpowers/specs/2026-07-14-an-sta-observer-design.md` (read it first).
- **No EEMF term** — SPM predictor only (U3 is Ld≈Lq). Disturbance-bound math uses **`Ls`** (`AN_MOTOR_LS`), never `Ld`.
- **Every STA addition guarded by `#if FEATURE_AN_STA`** (default `0` in `garuda_config.h`). Default build must stay byte-identical to baseline commit `438841e` (code state == `d257e51`).
- Sample period `AN_TS = 1/45000 ≈ 22.2 µs` (`AN_FS_HZ = 45000.0f`). Geometric sample→apply latency is already compensated downstream (`AN_DELAYCOMP_FRAC = 1.5`, `an1078_motor.c:1077`) — **do not** re-add it in the observer.
- `sgn(0) = 0` (never ±1) in the STA law.
- Angle offset is a pair: `thetaBaseSTA` (const, seed 0) + `thetaKlatSTA·|ω|` (slope, seed 2.22e-5). Not a single constant.
- Anti-windup clamp computed per tick: `wClamp = max(wClampFloorSTA, 1.3·|ω|·λ)`, `λ = focKeUvSRad·1e-6` (V·s/rad).
- GSP live-tune params are RAM-only (not in `GSP_CONFIG_PERSIST_*` structs), matching the existing `an1078*` params.
- Build command (from repo root): `make 2>&1 | tail -30` → artifact `dist/default/production/garuda-ese-pristine.production.hex`. Success = hex regenerated, no `Error 1` line.
- To build the STA variant: edit `garuda_config.h` `FEATURE_AN_STA` to `1`, `make clean && make`, then **revert to `0`** before committing (default ships off).
- objdump for byte-identity: `/media/bhanu1234/Development/MPLABX/v3.30/bin/bin/elf-objdump -d -mdfp=/media/bhanu1234/Development/MPLABX/v6.30/packs/Microchip/dsPIC33AK-MC_DFP/1.4.172/xc16 <elf>`. Whole-hex md5 is INVALID (non-deterministic build stamp in `gsp_commands.c:125`); compare disassembly.

---

## File Structure

| File | Responsibility | Task |
|---|---|---|
| `garuda_config.h` | `#define FEATURE_AN_STA 0` flag | 1 |
| `foc/an1078_smc.h` | `AN_SMC_T` STA fields (guarded) + config include | 1 |
| `foc/an1078_smc.c` | `AN_SMCReset` zeroes STA integrator state (guarded) | 1 |
| `gsp/gsp_params.h` | 7 STA live-tune fields + PARAM_IDs (guarded) + config include | 2 |
| `gsp/gsp_params.c` | 7 descriptor rows (guarded) | 2 |
| `foc/an1078_params.h` | STA gain-seed `#define`s | 2 |
| `foc/an1078_sta.h` | Public: `AN_STA_Position_Estimation()` | 3 |
| `foc/an1078_sta.c` | Pure core `an_sta_step()` + wrapper + `an_tune_sta_*` + telemetry overlay | 3 |
| `foc/an1078_motor.c` | Call-site `#if FEATURE_AN_STA` selector | 4 |
| `nbproject/*` (MPLAB) | Add `an1078_sta.c` to the build | 4 |
| `test/host/test_an_sta_core.c` | Host unit test of `an_sta_step` (convergence + sign) | 5 |

**Canonical interface (all tasks must match these names/types exactly):**

```c
/* Pure per-tick core — no gsp/hardware includes; host-testable.
 * Reads s->{Fsmopos,Gsmopos,Valpha,Vbeta,Ialpha,Ibeta,Zalpha,Zbeta,
 *          EstIalpha,EstIbeta,wIntA,wIntB,pll,OmegaFltred};
 * writes  s->{EstI*,Ialpha/betaError,Zalpha/beta(=z),Ealpha/beta,
 *          Ealpha/betaFinal(=z),wIntA/B,pll,Theta,OmegaFltred}. */
void an_sta_step(AN_SMC_T *s, float k1, float k2, float wClamp,
                 float thetaBase, float thetaKlat, float Ts);

/* Live-tune wrapper — reads gspParams, computes gains + wClamp + λ, calls core. */
void AN_STA_Position_Estimation(AN_SMC_T *s);
```

**Canonical STA struct fields (appended to `AN_SMC_T`, guarded):**

```c
float wIntA, wIntB;    /* STA integral state (→ EMF)             [V]    */
float k1, k2;          /* STA gains this tick (diagnostic copy)         */
float wClampFloorSTA;  /* (unused placeholder; floor read from gsp)     */
float thetaBaseSTA;    /* (diagnostic copy)                      [rad]  */
float thetaKlatSTA;    /* (diagnostic copy)                      [rad·s]*/
```

Note: gains/floor/offsets are recomputed each tick by the wrapper from `gspParams`
and passed into `an_sta_step` as parameters; the struct copies exist only so the
telemetry/forensics layer and a debugger can observe them. Only `wIntA/wIntB` are
true persistent integrator state that `AN_SMCReset` must zero.

**Canonical GSP param set (7 fields, IDs 0x94–0x9A):**

| Field (`GSP_PARAMS_T`) | PARAM_ID | scale → value | seed(v) | range | helper |
|---|---|---|---|---|---|
| `staK1bMilli` | 0x94 | v/1000 → k1b | 2000 (2.0) | 0–60000 | `an_tune_sta_k1b()` |
| `staK1aE6` | 0x95 | v/1e6 → k1a | 0 | 0–60000 | `an_tune_sta_k1a()` |
| `staK2b` | 0x96 | v → k2b | 4000 | 0–60000 | `an_tune_sta_k2b()` |
| `staK2aE6` | 0x97 | v/1e6 → k2a | 0 | 0–60000 | `an_tune_sta_k2a()` |
| `staWClampFloorMv` | 0x98 | v/1000 → floor [V] | 2000 (2.0) | 0–30000 | `an_tune_sta_wclamp_floor()` |
| `staThetaBaseDegX10` | 0x99 | v·0.1·π/180 → rad | 0 | 0–3600 | `an_tune_sta_theta_base()` |
| `staThetaKlatE7` | 0x9A | v/1e7 → rad·s | 222 (2.22e-5) | 0–2000 | `an_tune_sta_theta_klat()` |

Seeds are fixed-gain bring-up values from spec §5.4 (U3: λ=1.125e-3 V·s/rad,
E_max≈9 V at 8000 rad/s; k2·Ts=4000·22.2e-6=0.089 < 0.05·E_max=0.45 ✓). Tune on
the bench. Helpers with a `0→#define default` fallback: k1b, k2b, wClampFloor,
thetaKlat. Helpers where 0 is a valid value (no fallback): k1a, k2a, thetaBase.

---

### Task 1: Flag + `AN_SMC_T` STA fields + reset

**Files:**
- Modify: `garuda_config.h` (near `FEATURE_FOC_AN1078`, line ~247)
- Modify: `foc/an1078_smc.h` (add config include after guard; append fields to `AN_SMC_T` before `#endif` of struct)
- Modify: `foc/an1078_smc.c` (`AN_SMCReset`, ~line 130 before `pll_reset`)

**Interfaces:**
- Produces: `FEATURE_AN_STA` macro; `AN_SMC_T` fields `wIntA, wIntB, k1, k2, wClampFloorSTA, thetaBaseSTA, thetaKlatSTA`.

- [ ] **Step 1: Add the flag.** In `garuda_config.h`, immediately after the `FEATURE_FOC_AN1078` line (~247), add:

```c
#define FEATURE_AN_STA           0  /* 2026-07-14 Super-twisting SMO A/B (spec docs/superpowers/specs/2026-07-14-an-sta-observer-design.md). Compile-time; default 0 = shipped boundary AN1078 observer. Flip to 1 to build the STA race variant; all STA code is #if-guarded so 0 is byte-identical. */
```

- [ ] **Step 2: Make the flag visible to the struct header.** `an1078_smc.c` includes `an1078_smc.h` (line 24) BEFORE `an1078_params.h` (line 25, which pulls `garuda_config.h`), so the struct guard would not see the flag. Add the config include to `an1078_smc.h` directly after `#define AN1078_SMC_H` (line 13):

```c
#ifndef AN1078_SMC_H
#define AN1078_SMC_H

#include "../garuda_config.h"   /* FEATURE_AN_STA (guard for STA fields below) */
```

- [ ] **Step 3: Append STA fields to `AN_SMC_T`.** In `foc/an1078_smc.h`, insert immediately after `PLL_t pll;` (line 81) and before the closing `} AN_SMC_T;`:

```c
    PLL_t pll;

#if FEATURE_AN_STA
    /* ── Super-twisting observer state (FEATURE_AN_STA) ──────────────
     * Alternate switching law; see foc/an1078_sta.c and
     * docs/superpowers/specs/2026-07-14-an-sta-observer-design.md.
     * Only wIntA/wIntB are persistent integrator state (reset each
     * handoff); the rest are per-tick diagnostic copies of the
     * live-tuned gains the wrapper passes into an_sta_step(). */
    float wIntA, wIntB;    /* STA integral state (converges to EMF)  [V]   */
    float k1, k2;          /* STA gains this tick (diagnostic)              */
    float wClampFloorSTA;  /* anti-windup floor this tick (diagnostic)[V]  */
    float thetaBaseSTA;    /* residual const angle offset (diagnostic)[rad]*/
    float thetaKlatSTA;    /* residual ω-slope (diagnostic)          [rad·s]*/
#endif
} AN_SMC_T;
```

- [ ] **Step 4: Zero the integrator state in `AN_SMCReset`.** In `foc/an1078_smc.c`, immediately before `pll_reset(&s->pll);` (line 130):

```c
#if FEATURE_AN_STA
    s->wIntA = 0.0f;
    s->wIntB = 0.0f;
#endif
    pll_reset(&s->pll);
```

- [ ] **Step 5: Verify default build compiles and is byte-identical.** Confirm `FEATURE_AN_STA` is `0`, then:

Run: `cd /media/bhanu1234/Development/ProjectGaruda-ak512/garuda-ese-pristine && make clean >/dev/null && make 2>&1 | tail -20`
Expected: no `Error 1`; `dist/default/production/garuda-ese-pristine.production.hex` regenerated.

Then confirm every addition is guarded (no unconditional code change):
Run: `git diff foc/an1078_smc.c | grep -E '^\+' | grep -vE 'FEATURE_AN_STA|wIntA|wIntB|^\+\+\+|^\+#if|^\+#endif'`
Expected: empty (the only added lines are the guard and the two guarded assignments).

- [ ] **Step 6: Verify the STA-on build compiles (struct fields valid).** Edit `garuda_config.h` `FEATURE_AN_STA` to `1`:

Run: `make clean >/dev/null && make 2>&1 | tail -20`
Expected: compiles (an1078_sta.c does not exist yet, so no link of the new symbols — the struct fields alone must compile). If a link error about `AN_STA_Position_Estimation` appears, that is expected only after Task 4 wiring; at Task 1 nothing references it, so build succeeds.
Then revert: edit `FEATURE_AN_STA` back to `0`, `make clean >/dev/null && make 2>&1 | tail -5` → succeeds.

- [ ] **Step 7: Commit.**

```bash
git add garuda_config.h foc/an1078_smc.h foc/an1078_smc.c
git commit -m "AN_STA task1: FEATURE_AN_STA flag + guarded AN_SMC_T state + reset

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: GSP live-tune params + gain-seed defines

**Files:**
- Modify: `gsp/gsp_params.h` (add config include; 7 fields in `GSP_PARAMS_T` ~line 181; 7 PARAM_ID defines ~line 94)
- Modify: `gsp/gsp_params.c` (7 descriptor rows ~line 595)
- Modify: `foc/an1078_params.h` (gain-seed `#define`s)

**Interfaces:**
- Consumes: `FEATURE_AN_STA` (Task 1).
- Produces: `gspParams` fields `staK1bMilli, staK1aE6, staK2b, staK2aE6, staWClampFloorMv, staThetaBaseDegX10, staThetaKlatE7`; macros `AN_STA_K1B_DEFAULT, AN_STA_K2B_DEFAULT, AN_STA_WCLAMP_FLOOR_DEFAULT, AN_STA_THETAKLAT_DEFAULT`; `PARAM_ID_STA_*` (0x94–0x9A).

- [ ] **Step 1: Make the flag visible to `gsp_params.h`.** After `#define GSP_PARAMS_H` (near top), add if not already present:

```c
#include "../garuda_config.h"   /* FEATURE_AN_STA (guards the STA param block) */
```

- [ ] **Step 2: Add the 7 struct fields.** In `gsp/gsp_params.h`, immediately after `an1078IdFwMaxDecia;` (line 181) inside `GSP_PARAMS_T`:

```c
#if FEATURE_AN_STA
    uint16_t staK1bMilli;        /* STA k1 base × 1000            — 0-60000 */
    uint16_t staK1aE6;           /* STA k1 speed-slope × 1e6      — 0-60000 */
    uint16_t staK2b;             /* STA k2 base (1:1)             — 0-60000 */
    uint16_t staK2aE6;           /* STA k2 ω²-slope × 1e6         — 0-60000 */
    uint16_t staWClampFloorMv;   /* STA anti-windup floor × 1000 (mV)-0-30000*/
    uint16_t staThetaBaseDegX10; /* STA residual const offset ×10 (deg)-0-3600*/
    uint16_t staThetaKlatE7;     /* STA residual ω-slope × 1e7    — 0-2000  */
#endif
```

- [ ] **Step 3: Add the PARAM_ID defines.** In `gsp/gsp_params.h`, after `#define PARAM_ID_AN1078_ID_FW_MAX_DECIA 0x93` (line 94):

```c
#define PARAM_ID_STA_K1B_MILLI          0x94
#define PARAM_ID_STA_K1A_E6             0x95
#define PARAM_ID_STA_K2B                0x96
#define PARAM_ID_STA_K2A_E6             0x97
#define PARAM_ID_STA_WCLAMP_FLOOR_MV    0x98
#define PARAM_ID_STA_THETA_BASE_DEGX10  0x99
#define PARAM_ID_STA_THETA_KLAT_E7      0x9A
```

(IDs unconditional — pure numeric macros, no binary impact; the descriptor rows that reference them are guarded.)

- [ ] **Step 4: Verify the descriptor table count is `sizeof`-derived.** The guarded rows only work if the table length is computed, not hardcoded.

Run: `grep -nE 'sizeof\(.*paramTable|NUM_PARAMS|PARAM_COUNT|paramTable\[\] *=|/ *sizeof' gsp/gsp_params.c gsp/gsp_params.h`
Expected: the count is `sizeof(paramTable)/sizeof(paramTable[0])` (or similar). If instead a hardcoded count constant exists, wrap it too: add `#if FEATURE_AN_STA` `+7` to that constant. (Record which case applies in the commit message.)

- [ ] **Step 5: Add the 7 descriptor rows.** In `gsp/gsp_params.c`, immediately after the `PARAM_ID_AN1078_KSLIDE_MV` row (line 595):

```c
#if FEATURE_AN_STA
    { PARAM_ID_STA_K1B_MILLI,         PARAM_TYPE_U16, PARAM_GROUP_AN1078,    0, 60000, offsetof(GSP_PARAMS_T, staK1bMilli),        2 },
    { PARAM_ID_STA_K1A_E6,            PARAM_TYPE_U16, PARAM_GROUP_AN1078,    0, 60000, offsetof(GSP_PARAMS_T, staK1aE6),           2 },
    { PARAM_ID_STA_K2B,               PARAM_TYPE_U16, PARAM_GROUP_AN1078,    0, 60000, offsetof(GSP_PARAMS_T, staK2b),             2 },
    { PARAM_ID_STA_K2A_E6,            PARAM_TYPE_U16, PARAM_GROUP_AN1078,    0, 60000, offsetof(GSP_PARAMS_T, staK2aE6),           2 },
    { PARAM_ID_STA_WCLAMP_FLOOR_MV,   PARAM_TYPE_U16, PARAM_GROUP_AN1078,    0, 30000, offsetof(GSP_PARAMS_T, staWClampFloorMv),   2 },
    { PARAM_ID_STA_THETA_BASE_DEGX10, PARAM_TYPE_U16, PARAM_GROUP_AN1078,    0, 3600,  offsetof(GSP_PARAMS_T, staThetaBaseDegX10), 2 },
    { PARAM_ID_STA_THETA_KLAT_E7,     PARAM_TYPE_U16, PARAM_GROUP_AN1078,    0, 2000,  offsetof(GSP_PARAMS_T, staThetaKlatE7),     2 },
#endif
```

(The trailing `2` matches the schema-version column used by the neighboring rows; copy whatever value the `an1078` rows use if it differs.)

- [ ] **Step 6: Add the gain-seed defines.** In `foc/an1078_params.h`, near the other `AN_SMC_*` defines (search `AN_SMC_KSLIDE`), add:

```c
/* ── Super-twisting observer seeds (FEATURE_AN_STA) — spec §5.4 ──────
 * Fixed-gain bring-up values for U3 (λ=1.125e-3 V·s/rad, E_max≈9 V @
 * 8000 rad/s). k2·Ts=4000·22.2µs=0.089 < 0.05·E_max=0.45 (discretization
 * safe). Tune on the bench; these are the 0→default fallbacks for the
 * live GSP params. */
#define AN_STA_K1B_DEFAULT           2.0f      /* z = k1·√|s| damping   */
#define AN_STA_K2B_DEFAULT           4000.0f   /* w ramp rate (V/s)     */
#define AN_STA_WCLAMP_FLOOR_DEFAULT  2.0f      /* anti-windup floor (V) */
#define AN_STA_THETAKLAT_DEFAULT     2.22e-5f  /* PLL discretization ≈1·Ts */
```

- [ ] **Step 7: Verify both builds.** With `FEATURE_AN_STA=0`:

Run: `make clean >/dev/null && make 2>&1 | tail -20`
Expected: no `Error 1`. Guarded-only change — default param table unchanged.
Run: `git diff gsp/gsp_params.c | grep -E '^\+' | grep -vE 'FEATURE_AN_STA|PARAM_ID_STA|^\+\+\+|^\+#if|^\+#endif'`
Expected: empty (all added rows are guarded).

Then edit `FEATURE_AN_STA=1`:
Run: `make clean >/dev/null && make 2>&1 | tail -20`
Expected: compiles (fields + descriptor rows valid). Revert to `0`, rebuild, succeeds.

- [ ] **Step 8: Commit.**

```bash
git add gsp/gsp_params.h gsp/gsp_params.c foc/an1078_params.h
git commit -m "AN_STA task2: 7 live-tune GSP params (0x94-0x9A) + gain seeds

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 3: `an1078_sta.c` / `.h` — core + wrapper

**Files:**
- Create: `foc/an1078_sta.h`
- Create: `foc/an1078_sta.c`

**Interfaces:**
- Consumes: `AN_SMC_T` + fields (Task 1); `gspParams` STA fields + `AN_STA_*_DEFAULT` (Task 2); `pll_update`/`pll_reset` (`pll_estimator.h`); `PLL_ANGLE_OFFSET` (`garuda_foc_params.h`); `AN_TS`, `AN_OMEGA_FILT_COEF`, `AN_MOTOR_LS` (`an1078_params.h`).
- Produces: `void AN_STA_Position_Estimation(AN_SMC_T *s)`; `void an_sta_step(AN_SMC_T *s, float k1, float k2, float wClamp, float thetaBase, float thetaKlat, float Ts)`.

- [ ] **Step 1: Create the header.** `foc/an1078_sta.h`:

```c
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
```

- [ ] **Step 2: Create the implementation.** `foc/an1078_sta.c`:

```c
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
```

- [ ] **Step 3: Verify the STA build compiles.** The file is not yet in the MPLAB build (Task 4 adds it), so compile it standalone against the DFP to catch errors early:

Run: `make clean >/dev/null && sed -i 's/#define FEATURE_AN_STA           0/#define FEATURE_AN_STA           1/' garuda_config.h && make 2>&1 | tail -20 ; sed -i 's/#define FEATURE_AN_STA           1/#define FEATURE_AN_STA           0/' garuda_config.h`
Expected: build succeeds (an1078_sta.c not yet linked, so its symbols are simply unused — this step only proves Tasks 1–2 still build with the flag on and the header parses). The authoritative compile of `an1078_sta.c` happens in Task 4 once it is added to the project.

- [ ] **Step 4: Confirm `AN_IRP_PERCALC` and `AN_OMEGA_FILT_COEF` exist** (the core references them):

Run: `grep -nE 'define +AN_IRP_PERCALC|define +AN_OMEGA_FILT_COEF' foc/an1078_params.h`
Expected: both defined. (If `AN_IRP_PERCALC` is named differently, match the name used in `an1078_smc.c`'s Omega block, lines 264–268.)

- [ ] **Step 5: Commit.**

```bash
git add foc/an1078_sta.h foc/an1078_sta.c
git commit -m "AN_STA task3: super-twisting core an_sta_step + live-tune wrapper

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 4: Call-site wiring + MPLAB project + byte-identity proof

**Files:**
- Modify: `foc/an1078_motor.c` (observer call, line ~986; add include)
- Modify: `nbproject/configurations.xml` (add `an1078_sta.c` to the source file list)

**Interfaces:**
- Consumes: `AN_STA_Position_Estimation` (Task 3); `FEATURE_AN_STA` (Task 1).

- [ ] **Step 1: Confirm the flag reaches `an1078_motor.c`.**

Run: `grep -nE '#include .*an1078_params.h|#include .*garuda_config' foc/an1078_motor.c`
Expected: it includes `an1078_params.h` (which pulls `garuda_config.h`) → `FEATURE_AN_STA` is visible. If neither include is present, add `#include "an1078_params.h"` near the top of `an1078_motor.c`.

- [ ] **Step 2: Add the STA include.** Near the top of `foc/an1078_motor.c`, after the existing `#include` block, add:

```c
#if FEATURE_AN_STA
#include "an1078_sta.h"
#endif
```

- [ ] **Step 3: Wire the call site.** In `foc/an1078_motor.c`, replace the single line at ~986:

```c
    AN_SMC_Position_Estimation(&m->smc);
```

with:

```c
#if FEATURE_AN_STA
    AN_STA_Position_Estimation(&m->smc);
#else
    AN_SMC_Position_Estimation(&m->smc);
#endif
```

- [ ] **Step 4: Add `an1078_sta.c` to the MPLAB build.** Open `nbproject/configurations.xml`, find the `<itemPath>foc/an1078_smc.c</itemPath>` entry, and add an adjacent entry:

```xml
<itemPath>foc/an1078_sta.c</itemPath>
```

(Match the exact XML shape of the neighboring `<itemPath>` / `<logicalFolder>` entries. If the project lists files under a `<logicalFolder name="foc">`, add it there next to `an1078_smc.c`.)

- [ ] **Step 5: Build the STA variant — authoritative compile+link of the new file.**

Run: `sed -i 's/#define FEATURE_AN_STA           0/#define FEATURE_AN_STA           1/' garuda_config.h && make clean >/dev/null && make 2>&1 | tail -25`
Expected: `an1078_sta.c` compiles AND links; `AN_STA_Position_Estimation` resolves; hex regenerated, no `Error 1`. If "undefined reference to `AN_STA_Position_Estimation`", the file was not added to the project (revisit Step 4).

- [ ] **Step 6: Save the STA ELF, then build the default variant.**

Run: `cp dist/default/production/garuda-ese-pristine.production.elf /tmp/sta_on.elf ; sed -i 's/#define FEATURE_AN_STA           1/#define FEATURE_AN_STA           0/' garuda_config.h && make clean >/dev/null && make 2>&1 | tail -10 ; cp dist/default/production/garuda-ese-pristine.production.elf /tmp/sta_off.elf`
Expected: default build succeeds.

- [ ] **Step 7: Prove the default build is byte-identical to baseline.** Build the baseline commit and disassemble-diff (whole-hex md5 is invalid — non-deterministic build stamp).

```bash
OBJD="/media/bhanu1234/Development/MPLABX/v3.30/bin/bin/elf-objdump -d -mdfp=/media/bhanu1234/Development/MPLABX/v6.30/packs/Microchip/dsPIC33AK-MC_DFP/1.4.172/xc16"
git stash --include-untracked -q   # park the STA work
git checkout -q d257e51 -- .       # baseline code state
make clean >/dev/null && make 2>&1 | tail -3
$OBJD dist/default/production/garuda-ese-pristine.production.elf > /tmp/base.dis
git checkout -q HEAD -- . && git stash pop -q   # restore STA work (flag=0)
make clean >/dev/null && make 2>&1 | tail -3
$OBJD /tmp/sta_off.elf > /tmp/off.dis 2>/dev/null || $OBJD dist/default/production/garuda-ese-pristine.production.elf > /tmp/off.dis
diff <(grep -vE '__TIME__|\.text\.[0-9]|file format' /tmp/base.dis) <(grep -vE '__TIME__|\.text\.[0-9]|file format' /tmp/off.dis) | head -40
```

Expected: no diffs except random temp-section names / the build-time string (the known non-determinism). Any real instruction-level diff means an STA addition leaked outside a guard — fix it.

- [ ] **Step 8: Commit** (with `FEATURE_AN_STA` reverted to `0`).

```bash
grep -n 'FEATURE_AN_STA' garuda_config.h   # confirm it reads 0
git add foc/an1078_motor.c nbproject/configurations.xml
git commit -m "AN_STA task4: call-site selector + MPLAB project; default byte-identical

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 5: Host unit test — core convergence + sign

**Files:**
- Create: `test/host/test_an_sta_core.c`

**Interfaces:**
- Consumes: `an_sta_step` (Task 3), `AN_SMC_T` (Task 1).

Rationale: `an_sta_step` is pure float math with no hardware dependency. This test
compiles it (and the PLL) with system `gcc` and drives it with a synthetic
constant-speed back-EMF, asserting the observer converges to the true angle **with
the correct sign** (catches the "observer runs backwards" bug the spec warns of)
and that `|z|` reaches the EMF magnitude. This runs in <1 s and de-risks the sign
conventions before spending a bench session.

- [ ] **Step 1: Write the failing test.** Create `test/host/test_an_sta_core.c`:

```c
/* Host unit test for an_sta_step() — no hardware.
 * Build:  see Step 2 command (defines AN_STA_HOST_TEST to drop the gsp wrapper,
 *         and supplies PLL_* + AN_* macros the core references). */
#include <stdio.h>
#include <math.h>
#include <stdint.h>

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
    /* Rotor angle: BEMF leads rotor by π/2, so Theta should track (theta - π/2). */
    float th_ref = theta - 1.5707963f; if (th_ref < 0) th_ref += 6.2831853f;
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
```

- [ ] **Step 2: Run it to verify it fails first** (before Task 3's core exists this whole plan can't compile; run this only after Task 3). Compile & run:

Run:
```bash
cd /media/bhanu1234/Development/ProjectGaruda-ak512/garuda-ese-pristine && \
gcc -std=c99 -DAN_STA_HOST_TEST -I. -o /tmp/test_an_sta test/host/test_an_sta_core.c -lm 2>&1 | tail -20 && \
/tmp/test_an_sta
```
Expected on a correct core: prints `z_mag≈4.5`, `w_est≈+4000`, `th_err<0.15`, `PASS`, exit 0.
If the sign convention in `an_sta_step` is wrong, expect `FAIL: speed sign inverted`. That is the failing case this test exists to catch — if it fails, fix the sign in the core (swap the `pll_update` argument polarity or the EMF sign), rebuild, rerun until `PASS`.

- [ ] **Step 3: Commit.**

```bash
git add test/host/test_an_sta_core.c
git commit -m "AN_STA task5: host unit test — core convergence + sign correctness

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Post-implementation: bench A/B (manual, user-run)

Not a code task — the acceptance protocol is spec §9. Summary: flash the STA hex
(`FEATURE_AN_STA=1` build), low-throttle spin → confirm handover + lock (`sα/sβ`
tight zero-mean); sweep to 76 k → acceptance is (a) the >45 k period-2 limit cycle
gone without ff-taper hacks and (b) lock held with `staThetaBaseDegX10≈0` and a
small `staThetaKlatE7`; load/thermal run → compare against the boundary baseline
CSV (`sessions/gui_auto_20260714_205852`). Diagnostics: top-end limit cycle ⇒ `k2`
too small OR `k2·Ts` too large under the ω² slope (check at 76 k with slopes
engaged); low-speed θ noise ⇒ gains too large.

---

## Self-Review

**Spec coverage:**
- §3 file layout → Tasks 1,3,4 (files created/modified as specified). ✓
- §4 STA algorithm (predictor, surfaces, STA law, per-tick clamp, PLL, angle pair) → Task 3 `an_sta_step`. ✓
- §4 latency: geometric comp stays downstream (untouched), offset pair `thetaBase`+`thetaKlat·|ω|` → Task 3 step 7. ✓
- §5 struct fields + `AN_SMCReset` zeroing at OL-ramp begin → Task 1 (reset call site already at `an_do_control` line 322, unchanged). ✓
- §6 seven live GSP params, fixed-first (`k1a=k2a=0`), Ls-not-Ld, per-tick clamp → Tasks 2,3. ✓
- §7 handover unchanged, `wInt` reset → Task 1 step 4. ✓
- §8 telemetry overlay (z→EalphaFinal/EbetaFinal, s→forensic via IalphaError/IbetaError) → Task 3 step 2 (core writes overlays). ✓
- §9 bench plan → post-implementation section. ✓
- §10 out-of-scope (EEMF, runtime toggle, default promotion) → none implemented. ✓

**Placeholder scan:** No TBD/TODO; every code step shows complete code; build/test commands are concrete with expected output. ✓

**Type consistency:** `an_sta_step(AN_SMC_T*, float k1, float k2, float wClamp, float thetaBase, float thetaKlat, float Ts)` and `AN_STA_Position_Estimation(AN_SMC_T*)` identical across File Structure, Task 3, Task 4 call site, Task 5 test. GSP field names (`staK1bMilli`…`staThetaKlatE7`) identical across Task 2 struct/descriptor and Task 3 helpers. PARAM_IDs 0x94–0x9A consistent. ✓

**One assumption to verify during execution** (flagged inline, not a placeholder): Task 2 Step 4 checks the descriptor-table count is `sizeof`-derived; Task 3 Step 4 checks `AN_IRP_PERCALC`/`AN_OMEGA_FILT_COEF` names. Both have concrete fallback instructions if the assumption is wrong.
