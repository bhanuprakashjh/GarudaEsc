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

## 3. PWM polarity / dead-time — `hal/hal_pwm.c`
- Set high-side **active-LOW** for the ATA NBH inputs: `PGxIOCONbits.POLH = 1`
  (low-side POLL=0). Verify in `InitPWMGenerators`.
- **Dead-time → ~0** (ATA applies internal tCC). Zero/​minimize `PGxDTH/PGxDTL`.
- Pins are unchanged (RD2/RD3, RD0/RD1, RC3/RC4 = PG1/2/3) — already in `port_config.c`.
- Verify `ChargeBootstrapCapacitors()` is still appropriate (ATA uses an internal
  charge pump for the high side — bootstrap pre-charge may be unnecessary).

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
`garuda_ese`. Stale auto-generated `Makefile-*.mk` were removed — **MPLAB X regenerates
them from configurations.xml on first open** (open the project, then Build).

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
