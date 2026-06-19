# GarudaESE (EV60Y51A V1.0) — Pin Map & Passive Reference

Source: `EV60Y51A-V1.0.pdf` schematic + `ESC_BringUp_Checklist_16_june_2026.xlsx`.
Read off the schematic sheets (MCU I/Os, Power & Gate Driver, Bridge & Sensing).
MCU = **dsPIC33AK256MC506-E/M7, 64-pin VQFN** ("MC505" silk is a stale label; device-ID confirms 506).
Bus: **25 V (6S) hard ceiling**; all dividers scaled for 42 V max. Shunts = **2 mΩ**.

Items flagged **(confirm)** were below schematic-render resolution or ambiguous — verify on the symbol/silk at integration.

> **✅ Re-verified (2 passes)** against the schematic at 600 DPI — every MCU pin string read directly, plus the ATA chip and bridge traced end-to-end. Resolved this round: **SPI = SPI2** (RB10/RB11/RC9/RC8/RC6); **`ATA_BEMF_U/V/W` = ATA6847 comparator DIGITAL outputs** (GPIO ZC, not analog); **PWM1=U, PWM2=V, PWM3=W** (traced to the bridge); ATA part = **ATA6847T-5033**, NRES pull-up / LH NC (SPI-only control); gate net **22R + 10R/PMEG3020EJ + 1000pF + 120k**; LED = **RC0(39)**; MOSFET **BSC028N06NS·SC**; `Speed` (RA6/16) is a **reserved unrouted** net; full analog port+core map. Open: exact ATA L-suffix, 506 ADC-core architecture (need 506 datasheet), whether designer routes `Speed`.

---

## 1. MCU pin map (dsPIC33AK256MC506, 64-VQFN)

### Motor PWM → ATA6847 (read directly from page 4)
| dsPIC pin | port | PWM fn | → ATA6847 input | role |
|---|---|---|---|---|
| 51 | RD2 | PWM1H | NBH1 (pin 36) | phase-1 high (active-LOW) |
| 52 | RD3 | PWM1L | IL1  (pin 35) | phase-1 low  |
| 49 | RD0 | PWM2H | NBH2 | phase-2 high (active-LOW) |
| 50 | RD1 | PWM2L | IL2  (pin 37) | phase-2 low |
| 43 | RC3 | PWM3H | NBH3 (pin 40) | phase-3 high (active-LOW) |
| 44 | RC4 | PWM3L | IL3  (pin 39) | phase-3 low |

- PWM gen→phase order (1=U,2=V,3=W) is the conventional mapping — **(confirm)** against GH/SH routing.
- **High-side inputs (NBH1-3) are ACTIVE-LOW.** Low-side (IL1-3) active-high.
- **Dead-time is internal to the ATA6847** (CCEN / tCC) — set MCU PWM dead-time = 0 so it isn't double-applied.
- Spare PWM pins exist (PWM4H/L = RC2/RC5 pins 41/42; PWM5H/L = RD5/RD6 pins 59/60) but RD5/RD6 are used for DShot/telemetry below.

### SPI2 ↔ ATA6847 (gate-driver config — gates are SPI-GATED) — **VERIFIED, uses SPI2 (not SPI1)**
| net | ATA6847 pin | dsPIC pin | port / function |
|---|---|---|---|
| SPI_SCK | SCK 47 | **31** | RB10 = **SCK2** (RP27) |
| SPI_SDI (ATA→MCU) | SDO 45 | **32** | RB11 = **SDI2** (RP28) |
| SPI_SDO (MCU→ATA) | SDI 46 | **34** | RC9 = **SDO2** (RP42) |
| SPI_NCS (GPIO) | NCS 44 | **33** | RC8 (RP41 / APWM1L) |
| SPI_NIRQ (GPIO in) | NIRQ 41 | **35** | RC6 (RP39 / SCL3) |

> ⚠ **CORRECTION (verified off the MCU symbol): the bus is on the SPI2-native pins** (SCK2/SDI2/SDO2 on RB10/RB11/RC9) — firmware must use **SPI2**, not SPI1. The ata-esc SPI1 driver retargets to SPI2 (SPI2CONx SFRs; native pins so PPS minimal). Mode unchanged: `MODE16, MSTEN, CKP=0, CKE=0, SMP=1, ENHBUF`. nCS/NIRQ are GPIO. The DIM-board "don't use SPI2 (SDI2 clashes nIRQ on RB11)" caveat does **not** apply here — nIRQ is on RC6, and RB11/SDI2 is deliberately the SPI input.

### Comms / debug / LED
| dsPIC pin | port | function | net | notes |
|---|---|---|---|---|
| 59 | RD5 (RP54) | DShot (bidir) | DSHOT | J1.7 |
| 60 | RD6 (RP55) | UART TELE_TX | TELE_TX | J1.6 |
| 61 | RD4 | UART TELE_RX | TELE_RX | J1.5 |
| 62 | RD7 | UART DEBUG_TX | DEBUG_TX | J1.3 |
| 63 | RD8 | UART DEBUG_RX | DEBUG_RX | J1.2 |
| 45 | RC10 | CAN_TX | → ATA6561 | |
| 46 | RC11 | CAN_RX | ← ATA6561 | |
| 30 | RB7 | CAN_STBY | STBY (low=normal) | |
| 39 | RC0 | Status LED | D4 (orange) | OSCO/CLKO pin (free, MEMS clk) — net confirm |

### Analog — **VERIFIED off the MCU symbol** (pin · port · ADC ANx)
| dsPIC pin | port | function | net | ADC ANx | scaling |
|---|---|---|---|---|---|
| 1 | RA0 | TEMP (NTC) | TEMP | AD3AN5 | ~1.055 V @25 °C |
| 2 | RA7 | VBUS | VBUS | AD5AN0 | 0.0769 → 1.92 V @25 V (42 V FS) |
| 3 | RA1 | BEMF_W (divider) | BEMF_W | AD5AN1 | 0.0769 |
| 6 | RA11 | BEMF_N (virtual neutral) | BEMF_N | AD5AN2 | 3×24k star |
| 7 | RA8 | UREF (op-amp ref) | UREF | DACOUT2/AD5AN3 | **DAC-generated** |
| 8 | RA9 | ATA_BEMF_U (ATA comparator) | ATA_BEMF_U | (AD1AN3) | **DIGITAL ZC (GPIO)** |
| 9 | RA10 | ATA_BEMF_V (ATA comparator) | ATA_BEMF_V | (AD1AN4) | **DIGITAL ZC (GPIO)** |
| 24 | RB9 | ATA_BEMF_W (ATA comparator) | ATA_BEMF_W | (AD2AN3) | **DIGITAL ZC (GPIO)** |
| 17 | RB5 | BEMF_U (divider) | BEMF_U | AD3AN1/AD4AN5 | 0.0769 |
| 23 | RB8 | BEMF_V (divider) | BEMF_V | AD2AN4 | 0.0769 |
| **16** | **RA6** | **`Speed` — reserved analog input** | **Speed** | **AD3AN2** | **throttle/pot? (see note)** |
| 15 | RA5 | W-phase current (ATA CSA out) | W_OA3_OUT | AD3AN0 | 32 mV/A (ATA ×16) |
| 28 | RB4 | DC-bus current (ATA CSA out) | IBUS_OA_OUT | AD4AN0 | 32 mV/A (ATA ×16) |
| 12 | RA2 | U-phase current — OA1 **OUT** | U_OA1_OUT | AD1AN0 | 73 mV/A @2 mΩ |
| 13 | RA3 | OA1 IN− | U_OA1_IN- | — | |
| 14 | RA4 | OA1 IN+ | U_OA1_IN+ | — | |
| 20 | RB0 | V-phase current — OA2 **OUT** | V_OA2_OUT | AD2AN0 | 73 mV/A |
| 21 | RB1 | OA2 IN− | V_OA2_IN- | — | |
| 22 | RB2 | OA2 IN+ | V_OA2_IN+ | — | |
| 27 | RB3 | (no-connect) | — | AD4AN3 | **free ADC pad (rework)** |
| 29 | RB6 | (no-connect) | — | AD4AN1 | **free ADC pad (rework)** |

> **🔎 `Speed` net (pin 16 / RA6 / AD3AN2):** a **named analog input "Speed"** exists on the MCU — clearly a reserved throttle/pot input. **But it appears on no other schematic sheet and reaches no connector/test-point** — it is an **unrouted reserved stub** (usable only by rework to RA6). So it does *not* give a bench pot a home as-drawn; designer to confirm intent / add a pad (HW sheet Q-A1a/E1b).
> **BEMF — two independent paths to the MCU:** (1) **`ATA_BEMF_U/V/W` = ATA6847 comparator DIGITAL outputs** on RA9/RA10/RB9 → GPIO ZC (option Z1); (2) **`BEMF_U/V/W` + `BEMF_N` = resistor-divider analog** on RB5/RB8/RA1/RA11 → ADC ZC (options Z2/Z3). Both are wired — firmware picks.
> **Current sense — ⚠ depends on the ATA op-amp mode (corrected):** the ATA6847 op-amp block is **either** current-sense amplifiers **or** BEMF comparators — **mutually exclusive**. Since this design uses the ATA for **BEMF** (GDUCR1.BEMFEN=1 → `ATA_BEMF_U/V/W` ZC), the **ATA current-sense amps are unavailable**. So the W (OPA2→RA5) and DC-bus (OPA3→RB4) "Current Sensed @ ATA6847" paths on the schematic are **inactive in BEMF mode**. **All usable current sense is on the dsPIC internal op-amps: Iu = OA1 (RA2), Iv = OA2 (RB0); Iw = −(Iu+Iv).** Bus current is not separately sensed in BEMF mode — overcurrent uses phase currents + ATA SCPCR/ILIM. (RA5/RB4 remain wired to the ATA outputs but carry no valid signal while BEMF is on.)

### Clock / reset / power
| pin | function | detail |
|---|---|---|
| 40 | OSC1 / CLKI = **RC1** | Y1 = DSA6001 **8 MHz** MEMS osc |
| **64** | MCLR | J1.12, gated by PWRGD: R16 0R + R17 470R + C38; held in reset until 3.3 V good |
| 5,19,26,38,48,58 | VDD (3.3 V) | C22 1µF + C23–C28 0.1µF (verify pin list) |
| 11 | AVDD (3.3 V) | via FB3 120R; C29 1µF + C30 0.1µF |
| 53 | SWVDD (→ internal buck in) | C31 10µF + C32 0.1µF |
| 56 | VDDCORE (~1.1 V, internal buck out) | **L2 = SRN2012T-100K (10µH)** + C34 10µF + C33 0.1µF — **do not drive** |
| 54 | LX (internal buck switch ~3 MHz) | via L2; scope only |
| 55 | SWVSS | = 0 V |
| 4,18,25,37,47,57 | VSS | grounds (verified) |
| 10 | AVSS | analog gnd |
| 65 | EP | exposed pad → GND |

---

## 2. Power tree
- **VBAT 25 V** (6S; 25 V hard ceiling) → **MCP16367** buck → **5 V** (FB 52.3k/10k → 4.98 V; fsw 2.2 MHz; PG @93%, D3 green/orange LED). TP3.
- **5 V → MCP1755** LDO → **3.3 V** (±2 %). TP4.
- dsPIC internal buck → **VDDCORE ~1.1 V** (L2, ~3 MHz).
- ATA6847 internal LDOs: **VDD1 = 5.0 V** (C7 2.2µF), **VDD2/VVIO = 3.3 V** (C8 2.2µF) — both on at power-up.
- Input: C1/C2 = 330µF/100 V bulk; D1 = SMAJ26A TVS; TP1/TP2.

---

## 3. Gate driver — ATA6847T-5033 (U1, 48-VQFN)
**SPI-gated: gates stay OFF until FW sets DOPM=Normal + GDU Normal over SPI.**

| pin | name | net / passive |
|---|---|---|
| 3 | VS (battery) | +25 V via **FB1 600R**, C4 10µF/50V, C5 0.1µF |
| 48 | VDD1 (5 V LDO) | C7 2.2µF/16V |
| 1 | VDD2 / VVIO (3.3 V LDO) | C8 2.2µF/16V; SPI/IO ref |
| 15 | VDH (HS supply) | C3 0.1µF + C6 1µF (to 25 V) |
| 18 | VCP (charge-pump) | — |
| 17/16 | CPP2 / CPN2 | C9 0.22µF/50V (0603) |
| 9 | VG (gate supply) | C10 3.3µF/25V (0805) |
| 13/14 | CPP1 / CPN1 | C12 0.22µF/50V (0603) |
| 20/22/24 | GH1 / GH2 / GH3 | high-side gate drives |
| 19/21/23 | SH1 / SH2 / SH3 | phase nodes (HS source) |
| 10/11/12 | GL1 / GL2 / GL3 | low-side gate drives |
| 8 | SL | common low-side source (→ shunts) |
| 36/35/40 | NBH1/2/3 | ← PWM1H/2H/3H (active-LOW) |
| 35/37/39 | IL1/2/3 | ← PWM1L/2L/3L |
| 44/45/46/47 | NCS/SDO/SDI/SCK | SPI |
| 41 | NIRQ | fault IRQ (pull-up 10k VVIO) |
| 2 | LH | R3 10k → VVIO |
| — | NRES | reset |
| 5/6 | GNDLIN / LIN | LIN (R7 10k, R8 240k, C20) — likely unused |
| 42/43 | RXD / TXD | UART (likely unused) |
| 49 | EP / GND | |

**Internal current-sense amps** (gain ×16, offset = VBO2 ~1.65 V, PWM=30 kHz, cutoff ≈650 kHz):
- W phase: OPP2/OPN2/OPO2 (29/30/…) → **R6 360R + C18 680pF** → `W_OA_OUT` (fc ≈650 kHz) → dsPIC ADC pin 15.
- DC bus: OPP3/OPN3/OPO3 (26/25/27) → **R5 360R + C17 680pF** → `IBUS_OA_OUT` → dsPIC ADC pin 28.
- **ATA pins 31/32/33 = BEMF1/BEMF2/BEMF3 = the ATA6847's internal BEMF *comparator* outputs** (GDUCR1.BEMFEN=1), → `ATA_BEMF_U/V/W` → TP8/TP7/TP6 **and** MCU pins **RA9(8)/RA10(9)/RB9(24)**. **These are DIGITAL comparator outputs, read as GPIO** for 6-step ZC (= ZC option Z1, same as the proven garuda-ak-ata-esc firmware). The MCU pins happen to be ADC-capable, but the signal is digital. (OPN1/BEMF1→ATA_BEMF_U, OPP1/BEMF2→ATA_BEMF_V, OPO1/BEMF3→ATA_BEMF_W.)
- ATA control pins: **NRES** pulled to VVIO via **R3 10k** (not MCU-driven); **LH, RXD, TXD, LIN, WAKE = no-connect** → the gate driver is configured **purely over SPI** (DOPM/GDU). NIRQ internally pulled up to VVIO.

### Gate drive (per leg, ×3 — verified on the bridge sheet)
- **PWM→phase mapping (traced): PWM1→NBH1/IL1→GH1/GL1→Q1/Q4→PHASE_U; PWM2→…→PHASE_V; PWM3→…→PHASE_W.** (TP11=U, TP12=V, TP13=W.)
- High-side gate net: series **R18/R19/R20 = 22 Ω** (turn-on) ∥ turn-off path **R24/R25/R26 = 10 Ω + D6/D7/D8 = PMEG3020EJ**; gate cap **C42/C43/C44 = 1000 pF/50 V**; gate-source pulldown **R21/R22/R23 = 120 kΩ**. Source/low-side series **R27–R32 = 3.3 Ω**.
- Per-leg bus decoupling **C39/C40/C41 = 10 µF/75 V (1210)**.
- MOSFETs: **BSC028N06NS (suffix `NSSC` on schematic; confirm NSSC vs NSSG)**, 60 V ~2.8 mΩ. Q1/Q2/Q3 = HS (U/V/W), Q4/Q5/Q6 = LS.

---

## 4. BEMF sense (resistor dividers → dsPIC ADC)
Each phase: `PHASE_x → 24k → BEMF_x → 2k → GND`, + 1000pF filter + BAT54 clamp to 3.3 V.
Ratio = 2k/(24k+2k) = **0.0769** (scaled for 42 V → 3.23 V max). Filter τ = (24k∥2k)·1000pF = **1.85 µs (~86 kHz)**.

| phase | top R (24k) | bottom R (2k) | filt C (1000pF/50V) | clamp | ADC pin |
|---|---|---|---|---|---|
| U | R61 | R69 | C64 | D13 BAT54XV2T1G | 17 (RB5) |
| V | R62 ✓ | R70 ✓ | C65 ✓ | D14 BAT54XV2T1G | 23 (RB8) |
| W | R63 ✓ | R71 ✓ | C66 ✓ | D15 BAT54XV2T1G | 3 (RA1) |

*(V/W designators verified off the BEMF sheet — no longer "confirm".)*

### Virtual neutral (BEMF_N)
`PHASE_U→R60 24k`, `PHASE_V→R64 24k`, `PHASE_W→R67 24k` all summed at **BEMF_N**, then **R68 680R + C63 6800pF → GND**. ADC pin 6.
- Thévenin ≈ (24k/3)∥680 ≈ 627 Ω; τ = 627·6800pF = **4.26 µs (~37 kHz)**.
- ⚠ Neutral filter τ (4.3 µs) ≈ **2.3× the per-phase BEMF τ (1.85 µs)** — the neutral lags the phase node; account for it in ZC timing if comparing phase-vs-neutral.

---

## 5. Phase current sense — dsPIC op-amps (U, V)
Differential amp around each dsPIC internal op-amp. Shunts R46 (U), R47 (V) = 2 mΩ (low-side leg → common SL); R57 = SL→GND bus shunt.

**U phase (OA1):**
- Series in: R43 = 330R (IN+), R51 = 330R (IN-)
- To op-amp: R41 = 470R, R49 = 470R
- Feedback: **R54 = 12k ∥ C54 = 22pF**
- UREF bias: R39 = 12k (from UREF)
- Filter: C48 = 1500pF (IN+→GND), **C51 = 2200pF (differential)**, C56 = 1500pF (IN-→GND)
- **Gain = R54/R43 = 12k/330 = 36.4 → 73 mV/A @2 mΩ.** Diff anti-alias τ ≈ (R41+R49)·C51 ≈ 2.1 µs (~77 kHz).
- Output `U_OA1_OUT` → ADC.

**V phase (OA2):** identical topology/values, designators R40/R44/R45/R50/R52/R53, C49 1500pF / C52 2200pF / C57 1500pF / C55 22pF. 73 mV/A.

## 5b. Phase-W & DC-bus current — ATA6847 internal amps (gain ×16) — **INACTIVE in BEMF mode**
> ⚠ These ATA CSA paths only work if the ATA op-amps are configured as amplifiers. This design configures them as **BEMF comparators** (BEMFEN=1), which **disables the CSA** — so W and DC-bus current are **not** sensed by the ATA here. Documented for completeness / for a non-BEMF build option. See §5/§8.
- W phase: shunt R48 (2 mΩ) → ATA OPA2 (×16) → R6 360R + C18 680pF → `W_OA_OUT` → ADC pin 15. **32 mV/A.**
- DC bus: shunt R57 (2 mΩ, SL→GND) → ATA OPA3 (×16) → R5 360R + C17 680pF → `IBUS_OA_OUT` → ADC pin 28. **32 mV/A.** Input anti-alias: R56/R58 = 4.7R + C59/C60/C61 = 0.022µF.
- Offset ≈ VBO2 ≈ 1.65 V (mid-rail); polarity inverted vs the dsPIC op-amps.

---

## 6. VBUS & TEMP
- **VBUS:** R59 24k / R66 2k → VBUS (pin 2); C62 1000pF; D12 BAT54XV clamp to 3.3 V. Ratio 0.0769 → 1.92 V @25 V (3.23 V @42 V).
- **TEMP:** +3.3 V → **TH1 10k NTC** (0402, 1 %) → TEMP (pin 1) → **R65 4.7k** → GND. ~1.055 V @25 °C (rises... falls with temp per NTC).

---

## 7. Connectors (verified off the MCU symbol)
**J1 (BM12B-GHS-TBT, 13-pos incl. pin 0):** 0-NC(✗), 1-GND, 2-DEBUG_RX(RD8/63), 3-DEBUG_TX(RD7/62), 4-GND, 5-TELE_RX(RD4/61), 6-TELE_TX(RD6/60), 7-DShot(RD5/59), 8-PGC(**RC2/41**), 9-PGD(**RC5/42**), 10-GND, 11-+3.3V, 12-MCLR.
**J2 (4-pos SM04B-GHS):** GND, CAN_L, CAN_H, +5 V. (CAN term R15 = 120 Ω fitted; end-node vs mid-bus TBD.)

> **⚠ No analog/ADC pin reaches any connector.** Every J1 signal pin is digital-only: RD4/5/6/7/8 are RP/PWM/IOM (no `ADxANy`); **PGC/PGD = PGC3/PGD3 = RC2/RC5** (also PWM4H/L), no ADC. So: an **arm switch** can use any J1 digital pin (recommend **DShot RD5**, internal pull-up, switch→GND), but an **analog speed pot has no home** — drive throttle over the GSP UART instead. The only free ADC-capable pad is **RB3 (pin 27, `PGD1/AD4AN3`), currently no-connect** — reachable by rework only, not on a connector.

---

## 8. Firmware-relevant deltas vs the MCLV bench rig
1. **Gate driver is SPI-gated (ATA6847)** — biggest new HAL piece. Boot sequence: rails → SPI init → read status/ID → DOPM=Normal + GDU Normal → only then gates can switch. PWM **high-side active-LOW**; **dead-time internal** (zero the MCU dead-time; set CCEN/tCC for BSC028N06).
2. **Real dedicated BEMF + true virtual neutral** (3×24k star) — the VA/VB-share-AD1 problem on MCLV is gone; 6-step ZC + a real neutral are available in hardware. Mind the neutral-vs-phase filter τ asymmetry (§4).
3. **Current sense = dsPIC op-amps only (ATA in BEMF mode):** Iu=OA1, Iv=OA2 (73 mV/A); Iw=−(Iu+Iv). The ATA op-amps are BEMF comparators (mutually exclusive with CSA), so W/DC-bus ATA current paths are inactive. Bus OC via phase currents + ATA SCPCR/ILIM.
4. **64-pin AK256MC506 pin map** (this doc) — PWM RD2/RD3/RD0/RD1/RC3/RC4, LED RC0, CAN RC10/RC11/RB7, UARTs RD4/6/7/8, DShot RD5, **SPI2**→ATA6847 (RB10/RB11/RC9/RC8/RC6).
5. Comms: DShot (bidir) + CAN (ATA6561) + dual UART.
6. **Control inputs:** no analog pot pin on the board → **throttle commanded over GSP on the DEBUG UART (RD7/RD8)**, the same UART the board bring-up uses (confirm UART instance — HW sheet Q-D4). **Arm via a digital switch** on a J1 pin (default **DShot RD5**); pot via rework to RB3 (pin 27) only if a physical knob is required.
