# GarudaESE port — remaining integration work

Status: project foundation assembled (512 GSP + ZC engine, ATA6847+SPI2 driver,
GarudaESE board layer). The items below need device-level detail and/or bench
iteration with the XC-DSC toolchain. Ordered by priority.

## 1. ADC channel remap — `hal/hal_adc.c`  ✅ DONE (software-ZC path)
Done this pass: `InitializeADCs()` rewritten for cores **AD1/AD2/AD3/AD5** with
**dedicated** BEMF channels (no Phase-A/C mux); `hal_adc.h` `ADCBUF_*` macros
remapped; the `garuda_service.c` ADC ISR reads the 3 BEMF channels and selects by
floating phase (all valid, no settle); `HAL_ADC_SelectBEMFChannel` is now a no-op.
Flags set for a coherent first build: `FEATURE_ADC_CMP_ZC=0` (software bemf_zc ZC),
`FEATURE_HW_OVERCURRENT=0` (no OA3/CMP3 bus path here).
**Register model CONFIRMED** against the AK256MC506 data sheet (DS70005591,
dsPIC33AK512MPS512 family — the part's actual DS): 5 ADC cores, channel config in
**`ADnCHxCON1`** (PINSEL/SAMC/TRG1SRC/DIFF/FRAC/MODE), per-core enable **`ADnCON`**
(ON/ADRDY). Code updated to `ADnCHxCON1` + `FRAC`. Only left to confirm at build:
`TRG1SRC=4`=PG1TRIGA on the 506, and the channel ISR vector name (`_AD1CH0Interrupt`).

Channel map now in `hal_adc.h`:

| Signal | GarudaESE pin / ADC ch | Into |
|---|---|---|
| Iu | RA2 / **AD1AN0** (OA1 out) | phase current u |
| Iv | RB0 / **AD2AN0** (OA2 out) | phase current v; `Iw = -(Iu+Iv)` |
| BEMF_U | RB5 / **AD3AN1** | floating-phase ADC ZC |
| BEMF_V | RB8 / **AD2AN4** | floating-phase ADC ZC |
| BEMF_W | RA1 / **AD5AN1** | floating-phase ADC ZC |
| BEMF_N | RA11 / **AD5AN2** | virtual-neutral reference |
| VBUS | RA7 / **AD5AN0** | bus voltage |
| TEMP | RA0 / **AD3AN5** | temperature |
| Speed | RA6 / **AD3AN2** | throttle (reserved/unrouted — see HW sheet) |

- GarudaESE has **dedicated** channels for the 3 BEMF phases (AD3/AD2/AD5 = distinct
  cores) → **drop the A/C mux** (`HAL_ADC_SelectBEMFChannel`, `bemfSampleValid`,
  `ZC_AD2_SETTLE_SAMPLES`) and sample all three simultaneously. This also makes the
  computed neutral `(Vu+Vv+Vw)/3` valid (was impossible on the muxed base).
- Keep the PG1 ADC trigger; keep both the mid-ON and OFF-center sample windows that
  `hwzc`/`bemf_zc` expect (falling-SW path).
- Confirm the AK256MC506 ADC-core architecture (the family datasheet I have is the
  AK128MC106 — 2 ADCs; the 506 pin names show AD1–AD5).

## 2. ZC source selection — additional back-ends
The **software ADC ZC (Z3)** is wired (item 1) — `bemf_zc.c` reads the dedicated
BEMF channels. Remaining options to add behind `BEMF_ZC_SOURCE` (porting plan §4):
- **Z2 (ADC comparators):** re-enable `FEATURE_ADC_CMP_ZC` and arm per-channel digital
  comparators on AD3CH0/AD2CH1/AD5CH0 (remap the MCLV AD1CH5/AD2CH1 high-speed path in
  `hal_adc.c` + `hwzc.c`). Pushes the speed ceiling past the 24 kHz software limit.
- **Z1 (ATA comparators):** read digital `ATA_BEMF_U/V/W` on RA9/RA10/RB9 (already set
  as digital inputs in `port_config.c`; ATA BEMFEN=1 in `hal_ata6847.c`) — port the
  garuda-ak-ata-esc capture/commutation hook.
- Neutral model for Z2/Z3: N1 `(Vu+Vv+Vw)/3` (now valid — simultaneous sample) /
  N2 Vbus·duty / N3 external `BEMF_N` (AD5CH1).

## 3. PWM polarity / dead-time — `hal/hal_pwm.c`  ✅ DONE (POLH + IOCON2 override re-encode)
- **POLH = 1** set on PG1/PG2/PG3 in `InitPWMGenerator1/2/3` → high-side **active-LOW**
  for the ATA6847 INH inputs (POLL = 0, LS active-high). POLH inverts only the final H
  pin, **after** the override mux, so the override DATA encoding is unchanged from a
  non-inverted board — verified against the bench-proven `garuda-ak-ata-esc` ATA6847
  driver (same active-low-H gate driver).
- **IOCON1/IOCON2 split re-encoded.** The AK256MC506 splits the old combined `PGxIOCON`
  into `PGxIOCON1` (PENH/PENL/POLH/POLL/PMOD — set once at init) and `PGxIOCON2`
  (override/fault data — written every commutation). The precomputed `PG_IOCON_*` words
  + `pgIoconWord()` were re-mapped to the **IOCON2** field positions
  (`OVRENH=bit21`, `OVRENL=bit20`, `OVRDAT=bits[13:12]`); PENH/PENL are no longer in the
  per-commutation word (they live in IOCON1). This was the "writes IOCON2 to compile"
  TODO — the bit pattern is now correct, not just link-clean.
- **Dead-time kept** (NOT zeroed). The proven ATA reference runs a small MCU dead-time
  (~100 ns) **alongside** the ATA's internal dead-time, and `MIN_DUTY = 2×DEADTIME_COUNTS`
  depends on it — zeroing it would collapse `MIN_DUTY`. Per-profile `DEADTIME_NS`
  (300–750 ns) stays; this is a tuning value, not a correctness bug.
- Pins are unchanged (RD2/RD3, RD0/RD1, RC3/RC4 = PG1/2/3) — already in `port_config.c`.
- **Bring-up still to verify on silicon:** scope the H/L pins per sector against the
  commutation table; confirm `ChargeBootstrapCapacitors()` behaviour (ATA may use an
  internal charge pump for the high side, making bootstrap pre-charge unnecessary).

## 4. Overcurrent / protection
- `FEATURE_HW_OVERCURRENT` OFF (the 512 OA3/CMP3 bus path doesn't exist here).
- Use phase-current limits (Iu/Iv) for software OC, and the ATA **SCPCR** (VDS short)
  + optional **ILIM** (cycle-by-cycle, `ILIM_DAC` in `garuda_board.h`) for hardware.

## 5. GDU lifecycle refinement (optional)
Currently GDU is set Normal once in `HAL_InitPeripherals` and stays on; PWM OVRENx
overrides gate the switching. If a full safe-stop/disarm is wanted, call
`HAL_ATA6847_EnterGduStandby()` there (do NOT tie it to per-coast output toggling,
which would break the CL_DIFF_IDLE feature).

## 6. Clean-6-step / FOC pruning
`foc/` is present but not in the 6-step build path. If `garuda_service.c` references
`foc_v2_detect` (ESC_DETECT), compile that out for a pure 6-step image. The motor
constants 6-step needs (λ/Ke, pole-pairs) live in the profile, not the FOC algos.

## 7. MPLAB X project  ✅ DONE
`nbproject/configurations.xml` regenerated for the real tree — **53 source + 65 header
files** across all folders (incl. foc/, dormant), device **dsPIC33AK256MC506**, toolchain
XCDSC, include dirs `hal;motor;gsp;learn;input;scope;x2cscope;foc;.`, project name
`garuda_ese`. The root `Makefile` + `nbproject/Makefile-*.mk` are now committed so the
project builds headless (`make CONF=default`) **and** opens/builds in MPLAB X (which
regenerates them from `configurations.xml`). Verified: full `make` → `.elf` → `.hex`
with **0 errors, 0 implicit-declaration warnings**, program **67,844 B (25%)**, data
**6,602 B (10%)** on XC-DSC v3.30 / DFP 1.4.172.

Fixed this pass: `hal/board_service.c` included `hal_spi.h` / `hal_ata6847.h` /
`port_config.h` only under `#if (FEATURE_HW_OVERCURRENT || FOC...)`, but
`HAL_InitPeripherals()` calls `HAL_SPI_Init`/`HAL_ATA6847_*` **unconditionally** — so in
the 6-step build they compiled with implicit `int` prototypes (wrong on a 16-bit target).
Those includes are now unconditional (they are core to this board).

### Build-config verification (this pass)
- `FEATURE_ADC_CMP_ZC=0`, `FEATURE_HW_OVERCURRENT=0` — verified **consistent**: every
  `HWZC_*` call (main.c, garuda_service.c, motor/*) is inside a `FEATURE_ADC_CMP_ZC`
  guard, so the whole hardware-comparator engine + callers compile out together; the
  `bemf_zc` **software ZC stays active** (8 live `BEMF_ZC_*` calls). `ADCBUF_IBUS` refs
  are all inside `FEATURE_HW_OVERCURRENT`.
- Only `hwzc.c` uses the single-`CON` channel register (vs the 506's `CON1`), and it is
  entirely inside `#if FEATURE_ADC_CMP_ZC` — so it is NOT compiled in this config. When
  re-enabling Z2, those must move to `ADnCHxCON1`/`ADnCHxCON2` (and remap AD1CH5/AD2CH1
  to the GarudaESE BEMF cores).
- foc/ does not touch ADC channel CON registers, so it is unaffected by CON→CON1.

## 8. Pending hardware confirmations (gate firmware choices)
See `../GarudaESE_HW_Confirmation_Sheet`: GSP UART instance, `Speed` net routing,
exact ATA 5033 L-suffix, ADC-core split, dead-time value.

---

# 2026-07-09 — PRISTINE ENGINE MERGED (P0 of the pristine port) ✅

This tree is now **garuda-ese-pristine**: the `garuda-ak512-pristine` engine
(July 2026 state: AN1078 FOC with corrected 24.95x current scale + valley
sampling + vbusFilt + burst-scope forensics + per-phase-comparator hwzc +
248-byte snapshot w/ ibusAvg + FOC telemetry fields) transplanted onto the
GarudaESE board layer from the original garuda_ese.X port.

**Build: clean** — 0 errors, 8 benign warnings (XC-DSC v3.30, DFP 1.4.172,
`make CONF=default`). Merge method: 3-way (base = pristine initial commit)
for garuda_service.c / garuda_config.h — zero conflicts, seams reviewed
(ADC ISR = GARUDA_ADC_INTERRUPT/_AD1CH0, ESE neutral-model selector + ATA
hooks + arm switch retained; pristine FOC/vbusFilt/scope/OC blocks intact).
ESE hunks re-applied by hand: gsp_params vbusOvAdc=2730 (0.0769 divider),
gsp_commands FEATURE_LIVE_TUNE (+cap bit 25), startup.c ramp-gate guard,
types ibus fields un-gated. Kept ESE main.c (nIRQ poll + ARM switch) as-is.

**P1 next (bench, PSU-limited): first spin, 6-step software ZC** per
docs/GarudaESE_BringUp_Plan.md S0-S7. Config as built: FEATURE_ADC_CMP_ZC=0,
FEATURE_HW_OVERCURRENT=0, FEATURE_FOC_AN1078=0, ZC_NEUTRAL_MODEL=DUTY,
MOTOR_PROFILE=2.

**P2 (HWZC/sector-PI):** implement per-phase comparator HAL for MC506
(AD3CH0=U/AD2CH1=V/AD5CH0=W — crib SimplifiedGarudaESE/src/adc.c encodings);
remap _AD1CMP5/_AD2CMP1 vectors to the ESE cores; pristine hwzc.c is already
per-phase-comparator shaped (GARUDA_TARGET_AK512 branches evaluate 0 here —
add ESE branches when porting).

**P3 (AN1078 FOC) — board constants BEFORE first FOC run:**
- AN_CURRENT_A_PER_COUNT = 0.01107 (36.4x gain, 2 mOhm, 73 mV/A) — NOT the
  MCLV 0.010766.
- AN_VBUS_V_PER_COUNT = 0.010478 (0.0769 divider) — NOT the MCLV 0.018702.
- Verify OA1/OA2 + UREF DAC (DACOUT2 1.65 V bias) init in hal before enabling.
- FOC valley sampling: ADC trigger vs low-side conduction window on this
  PWM/ADC config (ADC_SAMPLING_POINT=0 here; re-derive like the MCLV audit).
- Apply the 5 audit fixes from
  garuda-ak512-pristine/docs/AN1078_FOC_IMPROVEMENTS.md (speed ceiling,
  duty cap 0.90, OC-below-rail, FW vector limit, regen limit).

---

# 2026-07-09 — REGISTER CROSS-CHECK vs Microchip reference FW ✅ (4 DOA bugs fixed)

Reference: `../atomberg-ESC_Ref_Board` (microchip-mcu16-support/atomberg-drone-support-2026
branch ESC_Ref_Board) — Microchip's trapezoidal engine, RAN CLOSED-LOOP on this
exact board (sparrow motor). Every register below is bench-proven there.

## Fixed (each would have been dead-on-arrival at first flash)
1. **hal_adc.c: TRG1SRC 4 -> 5, all 11 channels.** The MC506's "PG1 ADC
   Trigger 1" encoding is 5; 4 was the MC510 value carried over — the control
   ISR would NEVER fire (boots, no state machine).
2. **port_config.c: _RP27R 17->29 (SCK2), _RP28R 16->28 (SDO2).** PPS output
   codes were from the AK128 table — SPI2 never reaches the pins -> ATA6847
   unconfigurable -> gates permanently dead.
3. **port_config.c: _RP56R 9->19 (U1TX).** Same AK128-table error — GSP UART
   TX dead, no banner, no comms.
4. **UREF was MISSING: added DAC2 1.65 V static output** (DACOUT2/RA8) in
   HAL_OA12_Init, ported from the reference's DAC2_InitFixedOutput_1V65
   (SSTIME=0x8A, DACDAT=0x800, UPDTRG=3, DACOEN=1). Without it the OA1/OA2
   bias network floats -> Iu/Iv garbage.

## Verified identical (no action)
SPI2 mode (MODE16/CKP=0/CKE=0/SMP=1/BRG=14); full ATA6847 sequence (unlock,
ILIMCR, ILIMTH=120, SCPCR 2000mV/8000ns/shutdown, GDUCR1 BEMFEN=1+CCEN+CCPT=7,
GDUCR2 EGBLT=15, SIECER 0xC7/0x1E, DOPM Normal w/ verify, GDU OFF->StBy->Normal,
**CSA2+CSA3 enabled AFTER GDU Normal**); PWM POLH=1/POLL=0, ADTR1EN1 on
PG1TRIGA, TRIGA=0 (valley), nonzero MCU dead-time (ref 0.3 us); AMPxCON1
op-amp config; ADC pin/PINSEL/core map; clock 8 MHz -> 200 MHz PLL; nIRQ CNPU.

## Resolved design questions
- **BEMFEN=1 coexists with CSA2/CSA3** (reference runs both): only the ATA's
  first op-amp block is consumed by the BEMF comparators. Real Iw (AD3AN0) and
  real Ibus (AD4AN0) ARE available — the pin-map's "mutually exclusive" warning
  applies to CSA1 only. Our SW_PHASE_OC reading Iw/Ibus is legitimate.
- MCU dead-time: keep nonzero alongside the ATA's internal DT (ref: 0.3 us).

## Bring-up notes
- Ours runs PWM at 45 kHz; the reference proved the board at **40 kHz**. If
  anything is marginal at 45 k, drop to 40 k before deeper debugging.
- The reference's UART is PHYSICALLY on the TELE pins (RD6 TX / RD4 RX —
  its comments say RD7/RD8 but the PPS pin numbers 55/53 = RD6/RD4). Ours is
  on DEBUG (RD7/RD8) per plan. **If no GSP banner at S0, move the adapter to
  J1 TELE pins (5/6) before suspecting firmware.** Note RD4 is also our ARM
  switch — if TELE pins end up used for UART, move ARM.
- Reference triggers phase currents on PG1 Trigger 2 (TRG1SRC=7, TRIGB) as a
  second sample point — an option for the FOC phase (valley currents on
  trigger 1 vs mid-window on trigger 2).

## Cross-check round 2 (hardware deltas checked and deliberately KEPT)
- **Config fuses: functionally identical** to the reference (1:1 pragma match;
  no ICSP pin-pair fuse exists on this family). PWM clock identical (400 MHz,
  x16 fine resolution). Clock PLL identical (8 MHz -> 200 MHz).
- **MODSEL: ours 4 (center-aligned) vs ref 0 (edge)** — deliberate. The whole
  pristine ZC/trigger scheme (valley trigger, mid-ON/off-center windows,
  LOOPTIME math) assumes center-aligned; also what ata-esc proved against an
  ATA6847L. The reference's edge mode is internally consistent with ITS
  sampling scheme (ADC point near period end) — do not mix the two.
- **PMOD: ours 0 (complementary + dead-time + overrides) vs ref 1
  (independent)** — deliberate; complementary/override 6-step is the proven
  garuda commutation scheme (ata-esc bench, same gate-driver family).
  Note: complementary = synchronous rectification during freewheel.
- **SAMC: ours 5 on divider/high-Z channels vs ref 3** — ours more
  conservative; keep.
- **ADC_SAMPLING_POINT: ours 0 (valley of center-aligned) vs ref period-end
  (edge)** — each correct for its own PWM mode.

Conclusion: the four fixes in round 1 (TRG1SRC=5, SCK2/SDO2 PPS, U1TX PPS,
UREF DAC2) were the COMPLETE set of genuine hardware-config defects. All other
deltas are method differences, each separately bench-proven.

## 2026-07-09 — Board analog gains APPLIED (was listed under P3; done early)
Cross-checked against the Microchip ref (MC1_PEAK_VOLTAGE=42.9, OA 12k/330):
- AN_CURRENT_A_PER_COUNT 0.01076636 -> **0.011078** (OA 36.36x, 2 mOhm, 72.7 mV/A;
  analog rail +/-22.69 A). AN_OVER_CURRENT_LIMIT=20 A still below the rail. OK.
- AN_VBUS_V_PER_COUNT 0.0187 -> **0.0104762** (13:1, 42.9 V FS).
- garuda_foc_params.h: SHUNT 0.002, OPAMP_GAIN 36.3636, VBUS_DIVIDER_RATIO 13.0
  (all derived scales self-correct from these).
- garuda_service.c IF_CURRENT_SCALE -> 2 mOhm/36.36x.
- garuda_config.h compile-time OV fallback 3600 -> 2730 (3600 = 37.7 V on this
  divider — above the 26 V bus TVS; runtime gspParams default was already 2730).
Rebuilt clean.

## ⚠ REMAINING scaling gap: the HOST GUI (tools/garuda_debug)
The GSP snapshot ships RAW ADC counts; the GUI converts using MCLV constants
(0.0187 V/cnt, 24.95x/3m current). Against this board the DISPLAY will be wrong
(e.g. 12 V bench PSU would show ~21 V). Firmware-side thresholds are all in
counts and correct. Fix when the bench connects: add a GarudaESE board mode to
garuda_gsp scaling (keyed off GSP INFO — e.g. capability bit 25 / a board id).
