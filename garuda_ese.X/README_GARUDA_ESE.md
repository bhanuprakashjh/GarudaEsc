# GarudaESE firmware — `garuda_ese.X`

6-step sensorless BLDC ESC firmware for the **GarudaESE / EV60Y51A** board:
**dsPIC33AK256MC506-E/M7** (64-VQFN) + **ATA6847T-5033** SPI-gated gate driver
+ **BSC028N06** MOSFETs, 25 V / 6S.

This project is a **port**, assembled from two proven code bases:

| Subsystem | Source | Notes |
|---|---|---|
| GSP protocol + v3 snapshot | **AK512 `dspic33AKESC`** | latest GSP (PROTOCOL_VERSION 3) — broker/Studio/MCP compatible |
| BEMF / ZC engine (`motor/hwzc.c`, `bemf_zc.c`, `commutation.c`, `startup.c`, `pi.c`, `speed_pi.c`) | **AK512 `dspic33AKESC`** | the bench-proven PLL ZC engine |
| ATA6847 driver + SPI | **garuda-ak-ata-esc** | `hal_ata6847.c/.h`, `hal_spi.c` — retargeted to **SPI2** |
| Board layer (`port_config`, `garuda_board.h`, clock, device) | **NEW** | schematic-verified GarudaESE pin map |
| FOC (`foc/`) | dormant | present for coherence; **not** built into the 6-step path |

## Architecture decisions (board-specific)

- **SPI2, not SPI1** — gate driver on SPI2-native pins SCK2=RB10 / SDI2=RB11 / SDO2=RC9, nCS=RC8, nIRQ=RC6 (`hal_spi.c`, PPS in `port_config.c`).
- **ATA6847 op-amps configured as BEMF comparators** (GDUCR1.BEMFEN=1). This is **mutually exclusive** with the ATA current-sense amplifiers, so:
  - **ZC** uses the 3 ATA comparator digital outputs `ATA_BEMF_U/V/W` → RA9/RA10/RB9 (GPIO), **and/or** the resistor-divider analog BEMF on RB5/RB8/RA1 + neutral RA11 (ADC). Selectable — see `BEMF_ZC_SOURCE` in the porting plan.
  - **Current sense is ALL on the dsPIC internal op-amps**: **Iu = OA1** (RA2/3/4), **Iv = OA2** (RB0/1/2), **Iw = −(Iu+Iv)**. There is **no** ATA current sense and **no** dsPIC OA3 current channel in this build (OA3 pins carry W-readback/Speed/BEMF_U as ADC). Bus overcurrent → phase currents + ATA **SCPCR/ILIM**; `FEATURE_HW_OVERCURRENT` (512 OA3/CMP3 path) stays **OFF**.
- **PWM PG1=U, PG2=V, PG3=W** on RD2/RD3, RD0/RD1, RC3/RC4 (same pins as the MCLV base). **High-side is active-LOW** (ATA NBH); **dead-time is internal to the ATA** → set MCU dead-time ≈ 0.
- **Clock**: internal 8 MHz FRC → PLL → 200 MHz (works without the external MEMS; switch to POSC/CLKI on RC1 if precision is needed).
- **Control**: no analog pot on the connectors → throttle over **GSP / DEBUG UART (RD7/RD8)**; **arm switch** = digital GPIO on **RD5** (DShot pin).

## What is done in this port
- Rebased on the 512 tree (GSP + ZC engine intact).
- Real ATA6847 + **SPI2** driver grafted and wired into `HAL_InitPeripherals` (SPI+ATA init, GDU→Normal after PWM gens up) — `hal/board_service.c`.
- GarudaESE `port_config.c/.h` + `garuda_board.h` (schematic-verified pin map, PPS).
- Device retargeted to dsPIC33AK256MC506 in `nbproject/configurations.xml`.
- UART debug from the ATA driver stubbed (no second UART1 driver; GSP owns UART1).

## Build
Toolchain: **XC-DSC** (dsPIC33A family), DFP `dsPIC33AK-MC_DFP`. Open in MPLAB X.
> The `nbproject` file list still reflects the ata-esc skeleton — on first open, use *Add Existing Items* to add the `gsp/ motor/ hal/ learn/ input/ scope/ x2cscope/` sources, or regenerate the project around this source tree. See **INTEGRATION_TODO.md** for the remaining board-bring-up work (the ADC channel remap is the main one).
