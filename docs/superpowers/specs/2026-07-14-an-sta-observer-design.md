# FEATURE_AN_STA — Super-Twisting Sliding-Mode Observer (design spec)

Date: 2026-07-14
Board: GarudaESE / EV60Y51A (dsPIC33AK256MC506 + ATA6847T-5033)
Motor: T-Motor U3 KV700 (surface-PM outrunner, Ld ≈ Lq), 16 V bench
Status: DESIGN APPROVED — implementation not started

---

## 1. Purpose & thesis

Add a **second-order (super-twisting) sliding-mode observer** as a compile-time
alternative to the shipped AN1078 boundary-layer SMO, for a bench A/B race on the
U3 drive. The shipped observer stays the default; `FEATURE_AN_STA` selects STA at
build time.

This is **not** a top-speed upgrade — we are already pinned at the U3's physical
voltage ceiling (~76.5 k eRPM @ 16 V), so the observer is not the speed limiter.
The expected wins are **robustness and tuning simplicity**:

- Kill the >45 k eRPM period-2 limit cycle *structurally* instead of via the
  feedforward-taper hacks currently used.
- Remove the thermally-drifting lag-compensation (`ThetaBase` / `ThetaK`), which
  was hand-tuned to null ~−35° of LPF group delay.
- Fewer, better-posed knobs (`k1`/`k2` with a real gain-selection recipe) vs. the
  current `Kslide` + `Kslf*` + `ThetaBase` + `ThetaK` stack.

### Scope decisions (explicit YAGNI)

- **No extended-EMF (EEMF) model.** U3 is a surface-PM outrunner (Ld ≈ Lq); the
  EEMF cross-coupling term collapses to the SPM model here and delivers nothing.
  Omitted. (Would be revisited only if a salient/saturating motor joins the
  roadmap.)
- **No runtime toggle.** Observer selection is compile-time (`FEATURE_AN_STA`);
  two hexes are compared by reflash. Cleaner single-path binary, zero runtime
  risk.
- **Predictor params are already validated.** STA reuses the exact same predictor
  as the boundary SMO (`Fsmopos = 1 − Rs·Ts/Ls`, `Gsmopos = Ts/Ls`). Because the
  shipped boundary observer works with these values, STA needs no additional
  Rs/Ls characterization.

---

## 2. Current observer (baseline being raced against)

`foc/an1078_smc.c :: AN_SMC_Position_Estimation()` is a 3-step per-tick pipeline:

1. `CalcEstI` — predictor `EstIα = F·EstIα + G·(Vα − Eα − Zα)`, then **boundary
   switching** `Zα = Kslide·err/MaxSMCError` (saturating at ±Kslide).
2. `CalcBEMF` — **two cascaded IIR LPFs** on Z → `EalphaFinal/EbetaFinal`, with a
   **speed-scheduled corner** `Kslf = |ω|·KslfScale` (floored at `KslfMin`).
3. `pll_update(&pll, EalphaFinal, EbetaFinal, Ts)` (AN1292-style PLL back-end),
   then `Theta = pll.theta_est − PLL_ANGLE_OFFSET + (ThetaBase + ThetaK·|ω|)`.

Relative to Fable's comparison table, this baseline is essentially the **"eSMO"
column minus the extended-EMF model**: first-order boundary switching + LPF + PLL
back-end. The PLL half of the upgrade is already done.

---

## 3. Architecture & file layout

The shipped path is left untouched; STA is a self-contained alternate body.

| File | Change |
|---|---|
| `foc/an1078_sta.c` / `.h` (**new**) | `void AN_STA_Position_Estimation(AN_SMC_T *s)` — alternate per-tick body. Reuses the **same `AN_SMC_T` struct** and the **same `pll_estimator`** back-end. |
| `foc/an1078_smc.h` | Add STA-only fields to `AN_SMC_T` (see §5). Inert when STA off → boundary path binary-unchanged. `AN_SMCReset` zeros the new integrator state. |
| `foc/an1078_motor.c` (~line 986) | `#if FEATURE_AN_STA` call `AN_STA_Position_Estimation` else `AN_SMC_Position_Estimation`. Everything downstream (`smc.Theta`, `smc.OmegaFltred`, `smc.pll`) is identical. |
| `garuda_config.h` | `#define FEATURE_AN_STA 0` (default off). Sole binary-changing switch. |

Pattern mirrors the existing `FEATURE_FOC_V2/V3` dual-engine gating. STA lives in
its own file (one purpose, independently testable).

---

## 4. The STA algorithm (per ISR tick)

SPM predictor (no EEMF cross-term). `z` is the continuous EMF estimate — there is
no separate filtered-`E` state and no LPF.

```
predictor:  EstIα = Fsmopos·EstIα + Gsmopos·(Vα − zα)     // z from prev tick
            EstIβ = Fsmopos·EstIβ + Gsmopos·(Vβ − zβ)
surface:    sα = EstIα − Iα ;   sβ = EstIβ − Iβ
gains:      k1 = k1b + k1a·|ω| ;   k2 = k2b + k2a·ω²        // ω = pll.omega_est
clamp:      wClamp = max(wClampFloorSTA, 1.3·|ω|·λ)         // λ = focKeUvSRad·1e-6
STA:        zα = k1·√|sα|·sgn(sα) + wα ;   wα += Ts·k2·sgn(sα)
            zβ = k1·√|sβ|·sgn(sβ) + wβ ;   wβ += Ts·k2·sgn(sβ)
anti-windup: wα = clamp(wα, ±wClamp) ;     wβ = clamp(wβ, ±wClamp)
angle:      pll_update(&pll, zα, zβ, Ts)                   // z fed straight in
            Theta = pll.theta_est − PLL_ANGLE_OFFSET
                    + thetaBaseSTA + thetaKlatSTA·|ω|      // see latency note below
```

Conventions / correctness:
- `zα/zβ` carry the same αβ polarity the LPF output `EalphaFinal/EbetaFinal` did,
  so they feed `pll_update` unchanged (same discriminator sign).
- `sgnf(0) = 0` (not ±1) — avoids integrator dither at standstill.
- `wClamp` is computed **per tick** (`1.3·|ω|·λ`, floored at `wClampFloorSTA`) so
  the anti-windup bound is speed-exact — tight at low speed where a desync-driven
  windup hurts most, not a single loose scalar sized for top speed. λ is the
  already-configured `focKeUvSRad` (µV·s/rad → ×1e-6 for SI).

### Latency decomposition (why the STA angle offset is a `thetaBaseSTA` + `thetaKlatSTA·|ω|` pair, not a constant≈0)

The baseline's `ThetaBase + ThetaK·|ω|` was absorbing **two physically distinct
delays**, only one of which STA deletes:

1. **LPF group delay** — deleted by STA (no filter). This was the constant part
   and part of the ω-slope.
2. **Sample→apply pipeline + PLL discretization** — **not** deleted. STA keeps a
   PLL and the same ADC→PWM pipeline.

The *geometric* sample→apply latency is **already compensated downstream and
observer-agnostically**: `an1078_motor.c:1077` advances the output angle by
`AN_DELAYCOMP_FRAC · ω · Ts` (`AN_DELAYCOMP_FRAC = 1.5`) before the inverse Park,
in CL only. That term is unchanged by this work and stays.

Numeric check at the 76.5 k ceiling (~8000 rad/s elec, `AN_TS ≈ 22.2 µs` @ 45 kHz):
downstream geometric comp = `1.5·ω·Ts ≈ 15°`; baseline observer term
`ThetaK·ω = 8.0e-5·8000 ≈ 37°`. The observer term is larger than the geometric
comp — confirming `ThetaK` was **LPF-lag + PLL-discretization residual**, not pure
geometric latency. Under STA the LPF-lag component vanishes, leaving only the
PLL's ~1-tick discretization residual.

Therefore the STA angle offset is a **pair**:
- `thetaBaseSTA` — constant; expected **≈ 0** (LPF-DC-lag and Rs/Ls-model bias gone).
- `thetaKlatSTA·|ω|` — ω-proportional residual; expected **small, slope ≲ 1·Ts**
  (PLL one-tick discretization; the geometric part is already covered by
  `AN_DELAYCOMP`), i.e. `thetaKlatSTA ≈ 0.5–1·Ts ≈ 1.1e-5…2.2e-5`, well below the
  baseline `ThetaK = 8.0e-5`. Speed-exact by construction.

Deleted vs baseline: both LPFs, `Kslf`/`KslfScale`/`KslfMin` scheduling, and the
`ThetaBase`/`ThetaK` LPF-lag compensation. **Not** deleted: the downstream
`AN_DELAYCOMP` geometric advance (observer-agnostic).

---

## 5. Struct additions to `AN_SMC_T`

```c
float wIntA, wIntB;    /* STA integral state (converges to EMF)   [V]  */
float k1, k2;          /* STA gains (recomputed per tick from schedule)*/
float wClampFloorSTA;  /* anti-windup floor; clamp=max(floor,1.3|ω|λ)[V]*/
float thetaBaseSTA;    /* residual const angle offset, expected ≈0 [rad]*/
float thetaKlatSTA;    /* residual ω-slope (PLL discretization) [rad·s] */
```

`AN_SMCReset` additionally sets `wIntA = wIntB = 0`. **Reset timing (verified):**
`AN_SMCReset` is called from `an_do_control()`'s open-loop `changeMode` first-tick
block (`an1078_motor.c:322`) — i.e. at **motor start / OL-ramp begin, not at the
CL switch**. STA therefore converges in shadow through the whole open-loop ramp,
so `wInt` already holds the EMF at the handover instant (no re-acquire transient).
Existing fields (`Fsmopos`, `Gsmopos`, `pll`, speed accumulators) are shared
unchanged.

---

## 6. Gains — one build covers fixed and adaptive

- Implement the adaptive-law **structure** `k1 = k1b + k1a·|ω|`,
  `k2 = k2b + k2a·ω²`, but **default the slope terms `k1a = k2a = 0`** → boots as
  a plain fixed-gain STA (simplest bring-up).
- The seven knobs — `k1b, k1a, k2b, k2a, wClampFloorSTA, thetaBaseSTA,
  thetaKlatSTA` — are **live GSP params**, reusing the same live-tune plumbing as
  `an1078KslideMv`/`ThetaBase` (`an_tune_*()` helpers reading `gspParams` each
  tick). Tune on the bench with no reflash.
- Initial seeds from the STA gain recipe (Levant-type sufficient conditions) at
  the U3 worst corner: `C ≥ max|dE/dt|/Ls` (**Ls**, the same `AN_MOTOR_LS`
  already in `Fsmopos/Gsmopos` — this is a no-EEMF build, do not write Ld) at
  76 k eRPM + max electrical acceleration + any FW `|i_d|`; `k2 = 1.2·C`; back out
  `k1` from `k1² > 4·C·(k2+C)/(k2−C)`. Discretization sanity: keep
  `k2·Ts < 0.05·E_max` where `E_max = ω·λ` (SPM, λ = `focKeUvSRad`).
- `wClamp` is computed per tick as `max(wClampFloorSTA, 1.3·|ω|·λ)` — speed-exact
  anti-windup, one extra multiply, tight at low speed.

---

## 7. Handover & reset

Reuse the **existing OL→CL handover unchanged** — it is observer-agnostic
(compares `thetaOpenLoop` vs `smc.Theta`, gates on `omega`). STA runs in shadow
during the open-loop ramp exactly as the boundary SMO does today. The only added
requirement is `wIntA/wIntB` reset in `AN_SMCReset` (§5) so integrators start
clean at handoff.

---

## 8. Telemetry (free under the compile-time flag)

Only one observer is compiled in, so STA **overlays the existing observer
telemetry slots** — no new snapshot bytes (the snapshot is at the 254 B protocol
ceiling):

- `EalphaFinal/EbetaFinal` slots → carry `zα/zβ`.
- Debug-forensic slots → carry `sα/sβ` and `|z|`.
- `st` (angle-error metric), `conf`, `Theta`, `OmegaFltred` keep their meaning.

The GUI decodes these under their existing names; the telemetry field guide is
annotated to note that **in an STA build** those columns mean z / s.

---

## 9. Bench validation plan

1. Flash STA hex, low-throttle spin → confirm handover + lock; `sα/sβ` a tight
   zero-mean band.
2. Sweep to the 76 k ceiling. **Acceptance tests:** (a) the >45 k period-2 limit
   cycle is gone *without* ff-taper hacks; (b) lock holds with **`thetaBaseSTA ≈ 0`
   and a small `thetaKlatSTA` (slope ≲ 1·Ts, well under the baseline `ThetaK`)** —
   the constant + Rs/Ls-model lag are proven gone; only the speed-exact PLL
   discretization residual remains. (This is the corrected claim — *not*
   "offset ≈ 0"; expecting a pure zero at top would fail spuriously since the
   ω-proportional PLL/pipeline residual is real.)
3. Load-reject + thermal run → compare directly against the boundary baseline
   CSVs captured on 2026-07-14 (session `gui_auto_20260714_205852`).
4. Failure diagnostics: limit cycle at top ⇒ `k2` too small **OR** `k2·Ts` grown
   too large under the ω² adaptive law (a discrete STA can self-oscillate) —
   **verify the `k2·Ts < 0.05·E_max` bound at the 76 k corner with the adaptive
   slopes engaged, not just at the fixed-gain bring-up values**; broadband θ noise
   at low speed ⇒ gains too large (shrink `k1a`/`k2a`).

Success = STA holds the full idle→76 k envelope at least as cleanly as the
boundary baseline, with the >45 k roughness reduced, `thetaBaseSTA ≈ 0`, and
`thetaKlatSTA` a small speed-exact slope.
If STA wins the bench race, a later change may promote it to default; that
promotion is out of scope for this spec.

---

## 10. Out of scope

- EEMF cross-coupling term (salient-motor support).
- Runtime observer toggle.
- Promoting STA to the shipped default (separate decision after the race).
- Flux-observer (Ortega/Mxlemming) comparison — a possible future third
  contender, not part of this spec.

---

## 11. References

- Levant, "Sliding order and sliding accuracy in sliding mode control,"
  Int. J. Control, 1993 (super-twisting foundations).
- Microchip AN1078 (boundary-SMO baseline); AN1292 (PLL angle tracker).
- Chen/Morimoto extended-EMF model, IEEE TIE 2003 (EEMF — noted, not used).
- Fable research doc "Super-Twisting SMO, TI eSMO, and the Combined Extended-EMF
  STA Observer" (source of this design; §5.2 discrete algorithm, §5.4 gains).
