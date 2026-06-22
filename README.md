# GarudaEsc — EV60Y51A 6-step Sensorless BLDC ESC Firmware

Firmware for the **EV60Y51A V1.0** drone-ESC board:
**dsPIC33AK256MC506-E/M7** (64-VQFN, 200 MHz) + **ATA6847T-5033** SPI-gated gate
driver + **BSC028N06** MOSFETs, **25 V / 6S**. Clean 6-step sensorless control
(software BEMF zero-crossing), GSP telemetry/control protocol, ATA6847 over SPI2.

> **Build:** ✅ compiles + links clean (MPLAB XC-DSC v3.30, DFP 1.4.172) — program ≈ 26 %, data ≈ 10 %.
> **Hardware status:** ⚠ verified at register-encoding / compile / flash + schematic level. **NOT yet validated on a spinning motor** — follow the bring-up plan, current-limited, before powering a motor.

---

## 📖 Documentation

| Document | Markdown | PDF |
|---|---|---|
| **Port Reference** — features, verified pin map, current-sense/BEMF architecture, ZC options, protection, caveats | [md](docs/GarudaESE_Port_Reference.md) | [pdf](docs/GarudaESE_Port_Reference.pdf) |
| **Bring-Up Plan** — staged S0–S7 procedure for developers (PSU-current-limit first), calibration, fault triage | [md](docs/GarudaESE_BringUp_Plan.md) | [pdf](docs/GarudaESE_BringUp_Plan.pdf) |
| **Build status** | [BUILD_STATUS.md](BUILD_STATUS.md) | — |
| **Remaining integration work** | [INTEGRATION_TODO.md](garuda_ese.X/INTEGRATION_TODO.md) | — |

---

## What this codebase is

A **clean 6-step sensorless** ESC. The rotor position is found by sampling the
floating phase's back-EMF on the dsPIC ADC and detecting the zero-crossing in
software; commutation is scheduled 30° (minus timing advance) after each
confirmed crossing. There is **no FOC in the active build** (the `foc/` tree is
present but dormant). Throttle/telemetry run over the **GSP** protocol on the
debug UART; the gate driver is brought up and monitored over **SPI2**.

### Key features
- **6-step engine** with software BEMF ZC (`motor/bemf_zc.c`), selectable neutral
  model (`ZC_NEUTRAL_MODEL`: duty-proportional / Vbus·½ / computed (Vu+Vv+Vw)/3 /
  external neutral pin) + optional RC-filter-lag compensation.
- **Full current sensing** — Iu/Iv via the dsPIC internal op-amps, Iw + DC-bus via
  the ATA6847 op-amps, all four on the dsPIC ADC (4 × 2 mΩ shunts).
- **Protection** — Vbus OV/UV, software over-current on all 3 phases + bus, ATA
  cycle-by-cycle ILIM, ATA VDS short-circuit (SCPCR), ATA nIRQ fault poll, and a
  GDU-ready gate that refuses to drive until the gate driver is confirmed up.
- **Throttle** — pot on test point TP5, **or** GUI/GSP (arm + ramp with no pot),
  **or** RX/DShot (compiled in).
- **Arming** — hardware ARM toggle switch (J1/RD4, kill-on-open) **or** GUI
  `START_MOTOR`; both compose safely.
- **GSP v3** telemetry/command protocol for the broker / Garuda Studio / MCP tools.

### Architecture at a glance
```
 throttle (pot / GSP / RX) ─┐
 arm (switch / GSP) ────────┤→ state machine: IDLE→ARMED→ALIGN→RAMP→[MORPH]→CLOSED_LOOP
                            │      │                                    │
                            │      └─ PWM 6-step commutation (PG1/2/3, POLH=1 active-low)
                            │                                          │
 ADC ISR @45 kHz ───────────┴─ BEMF ZC detect ── current/Vbus sense ── protections
        │
        └─ SPI2 ⇄ ATA6847 gate driver (DOPM/GDU, CSA, BEMF cmp, ILIM/SCPCR, nIRQ)
```

---

## Verified pin map (summary)

| Function | Pins |
|---|---|
| PWM U/V/W (H,L) | RD2/RD3, RD0/RD1, RC3/RC4 (HS active-low for ATA) |
| Phase current Iu/Iv | dsPIC OA1 (RA2/AD1AN0), OA2 (RB0/AD2AN0) |
| Phase Iw / DC bus | ATA6847 op-amps → RA5/AD3AN0, RB4/AD4AN0 |
| BEMF U/V/W / neutral | RB5, RB8, RA1 / RA11 (dedicated ADC cores, no mux) |
| VBUS / TEMP | RA7 / RA0 |
| SPI2 ↔ ATA6847 | SCK RB10, **SDO2 RB11**, **SDI2 RC9**, nCS RC8, nIRQ RC6 |
| GSP UART | RD7 (TX) / RD8 (RX) |
| Pot (TP5) / ARM switch | RA6 / RD4 (J1) |

Full table + caveats in the [Port Reference](docs/GarudaESE_Port_Reference.md).
Cross-checked against the authoritative `dsPIC33AK256MC506.xlsx`.

> ⚠ **SPI direction gotcha:** the board wires the dsPIC SPI data lines opposite to
> the pins' native function names — RB11 is driven as **SDO2 (out)** and RC9 read
> as **SDI2 (in)**, following the board net routing, not the pin labels.

---

## Build

```sh
cd garuda_ese.X
make CONF=default            # MPLAB XC-DSC v3.30 on PATH
```
…or open `garuda_ese.X` in **MPLAB X** and Build. The root `Makefile` +
portable `nbproject/Makefile-*.mk` are committed; machine-specific generated
files are git-ignored.

## Repository layout
```
garuda_ese.X/        MPLAB X project (buildable firmware)
  hal/               board layer: port_config, garuda_board.h, hal_spi (SPI2),
                     hal_ata6847, hal_adc (5-core ADC), hal_pwm, clock
  motor/             6-step engine: bemf_zc, commutation, startup, hwzc, pi
  gsp/               Garuda Serial Protocol (v3 snapshot)
  foc/               FOC (dormant)
docs/                Port Reference + Bring-Up Plan (md + pdf)
```

## Provenance
Assembled from two Project Garuda code bases — the AK512 `dspic33AKESC` tree
(GSP + BEMF/ZC engine) and `garuda-ak-ata-esc` (ATA6847 + SPI driver) — with a
new EV60Y51A board layer.

---

## ⚠ Safety
This is unproven hardware/firmware. Always bring up on a **current-limited bench
supply**, start at low Vbus, and keep **no propeller** until the final staged
test. The active motor profile carries bench-motor values — set your real motor
profile and calibrate the current-sense / protection thresholds before running
on a battery. See the [Bring-Up Plan](docs/GarudaESE_BringUp_Plan.md).
