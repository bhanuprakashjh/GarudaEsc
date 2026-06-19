# GarudaEsc

6-step sensorless BLDC ESC firmware for the **GarudaESE / EV60Y51A** board:
**dsPIC33AK256MC506-E/M7** (64-VQFN) + **ATA6847T-5033** SPI-gated gate driver
+ **BSC028N06** MOSFETs, 25 V / 6S.

## Contents
- **`garuda_ese.X/`** — MPLAB X project (XC-DSC toolchain). Buildable firmware.
  - `hal/` — board layer: `port_config`, `garuda_board.h`, `hal_spi` (SPI2), `hal_ata6847`, `hal_adc` (5-core ADC), `hal_pwm`, clock, device config.
  - `motor/` — 6-step engine: `bemf_zc` (software ZC), `commutation`, `startup`, `hwzc` (HW-comparator ZC, off by default), `pi`, `speed_pi`.
  - `gsp/` — Garuda Serial Protocol (v3 snapshot) for the broker / Studio / MCP tooling.
  - `learn/`, `input/`, `scope/`, `x2cscope/`, `foc/` (FOC dormant).
  - `README_GARUDA_ESE.md`, `INTEGRATION_TODO.md` — port notes + remaining work.
- **`GarudaESE_PinMap`** (md/pdf/xlsx) — schematic-verified pin map + passives.
- **`GarudaESE_Porting_Plan_A`** (md/pdf) — the 6-step porting plan.
- **`GarudaESE_HW_Confirmation_Sheet`** (md/pdf/xlsx) — open questions for the hardware designer.

## Build
Toolchain: **MPLAB XC-DSC v3.30**, DFP `dsPIC33AK-MC_DFP` 1.4.172, MPLAB X.
Open `garuda_ese.X` in MPLAB X (it regenerates makefiles), or build with `xc-dsc-gcc`.
**Status: compiles + links clean** for the dsPIC33AK256MC506 — see `BUILD_STATUS.md`.

## Provenance
Assembled from two Project Garuda code bases: the AK512 `dspic33AKESC` tree
(GSP + BEMF/ZC engine) and `garuda-ak-ata-esc` (ATA6847 + SPI driver), with a new
GarudaESE board layer. See `garuda_ese.X/README_GARUDA_ESE.md`.
