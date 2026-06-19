# GarudaESE / EV60Y51A — Hardware Designer Confirmation Sheet

**Purpose:** Everything below was read from the `EV60Y51A-V1.0` schematic by the firmware side. Please **confirm or correct each row** before we freeze `port_config` and the ADC map. Pins drive PPS, ADC channel allocation, and the ATA6847 bring-up, so a wrong pin = a non-booting build.

**Legend (Source column):**
✅ read directly off the MCU symbol (high confidence) · ⚠ from checklist/earlier read (verify) · ❓ not yet readable — please fill in.

Device on silk reads **"MC505"**; device-ID/pin-count indicate **dsPIC33AK256MC506-E/M7, 64-pin VQFN**.
**Q0. Confirm exact MCU orderable part number** (…MC505 vs …MC506, temp grade, package). ☐

---

## A. Connectors — verified pinout

### J1 — combined Programming / Debug / Control (BM12B-GHS-TBT, 13-pos incl. pin 0)
| J1 pin | net | dsPIC pin | schematic pin-function string | Source | Confirm |
|---|---|---|---|---|---|
| 0 | **NC** (marked ✗) | — | — | ✅ | ☐ |
| 1 | GND | — | — | ✅ | ☐ |
| 2 | DEBUG_RX | RD8 (63) | `CVDTX18/RP57/ASDA2/IOMAF3/RD8` | ✅ | ☐ |
| 3 | DEBUG_TX | RD7 (62) | `CVDTX17/RP56/ASCL2/IOMAF4/RD7` | ✅ | ☐ |
| 4 | GND | — | — | ✅ | ☐ |
| 5 | TELE_RX | RD4 (61) | `CVDTX16/RP53/IOMBF6/RD4` | ✅ | ☐ |
| 6 | TELE_TX | RD6 (60) | `RP55/PWM5L/ASDA1/IOMBD0/RD6` | ✅ | ☐ |
| 7 | DShot | RD5 (59) | `RP54/PWM5H/ASCL1/IOMBD1/RD5` | ✅ | ☐ |
| 8 | PGC | **RC2 (41)** | `PGC3/RP35/PWM4H/IOMAD7/RC2` | ✅ | ☐ |
| 9 | PGD | **RC5 (42)** | `PGD3/RP38/PWM4L/IOMAD6/RC5` | ✅ | ☐ |
| 10 | GND | — | — | ✅ | ☐ |
| 11 | +3.3 VDC | — | — | ✅ | ☐ |
| 12 | MCLR | MCLR | (PWRGD-gated: R16 0R + R17 470R + C38) | ✅ | ☐ |

### J2 — CAN (SM04B-GHS)
| J2 pin | net | Confirm |
|---|---|---|
| 1 | GND | ☐ |
| 2 | CAN_L | ☐ |
| 3 | CAN_H | ☐ |
| 4 | +5 V | ☐ |

**Q-A1 (the big one — speed pot + arm).** No ADC pin is on J1/J2 (all digital). BUT re-verification found a **reserved analog net `Speed` on MCU pin 16 (RA6 / AD3AN2)**.
- **(a) ⭐ Where does the `Speed` net go?** Is it routed to a connector / pad / test-point (i.e. usable for an external pot), or fed by an on-board divider, or is it an **unrouted reserved stub**? This is the single most useful answer for our bench control. ☐
- **(b)** If `Speed` is not usable, can a future rev route an ADC pin to J1 — e.g. the free no-connects **RB3 (pin 27, AD4AN3)** or **RB6 (pin 29, AD4AN1)**? ☐
- **(c)** **Arm switch:** OK to use a J1 digital pin as a GPIO input (internal pull-up, switch→GND)? Preferred — **DShot RD5**, or a DEBUG/TELE pin? Any external pull-ups already fitted? ☐

---

## B. Motor PWM → ATA6847 (fixed-function pins)
| net | dsPIC pin | schematic pin-function string | Source | Confirm |
|---|---|---|---|---|
| PWM1H | RD2 (51) | (PG1H) | ⚠ | ☐ |
| PWM1L | RD3 (52) | (PG1L) | ⚠ | ☐ |
| PWM2H | RD0 (49) | `RP49/PWM2H/IOMAD3/RD0` | ✅ | ☐ |
| PWM2L | RD1 (50) | (PG2L) | ⚠ | ☐ |
| PWM3H | RC3 (43) | `RP36/PWM3H/IOMAD5/RC3` | ✅ | ☐ |
| PWM3L | RC4 (44) | `RP37/PWM3L/IOMAD4/RC4` | ✅ | ☐ |

**Q-B1 (resolved — sanity-check).** PWM→phase mapping traced on the bridge: **PWM1→GH1/GL1→Q1/Q4→PHASE_U, PWM2→PHASE_V, PWM3→PHASE_W** (TP11/12/13). Confirm. ☐
**Q-B2.** Confirm **PWM1H/L = RD2/RD3, PWM2L = RD1** (only PWM2H/PWM3H/L were directly readable). ☐
**Q-B3.** Confirm ATA6847 input mapping & polarity: PWMxH → NBHx (**active-LOW** high-side), PWMxL → ILx (active-high). ☐
**Q-B4.** Confirm **dead-time is internal to the ATA6847** (so MCU dead-time ≈ 0); give the configured tCC / dead-time value. ☐

---

## C. SPI2 ↔ ATA6847 — **now READ (was blocker); please confirm**
Resolved on re-verification: the bus is on the **SPI2-native pins**.
| net | ATA6847 pin | dsPIC pin | port / function | Confirm |
|---|---|---|---|---|
| SPI_SCK | SCK 47 | 31 | RB10 = SCK2 (RP27) | ☐ |
| SPI_SDI (ATA→MCU) | SDO 45 | 32 | RB11 = SDI2 (RP28) | ☐ |
| SPI_SDO (MCU→ATA) | SDI 46 | 34 | RC9 = SDO2 (RP42) | ☐ |
| SPI_NCS (GPIO) | NCS 44 | 33 | RC8 (RP41) | ☐ |
| SPI_NIRQ (GPIO in) | NIRQ 41 | 35 | RC6 (RP39) | ☐ |

**Q-C1.** Confirm firmware should use **SPI2** (board routes SCK2/SDI2/SDO2), nCS/NIRQ as GPIO. ☐
**Q-C2.** Any SPI clock-rate constraint? (we plan BRG=14 → 3.33 MHz, ATA max 10 MHz). ☐

---

## D. Comms / status (PPS / GPIO)
| net | dsPIC pin | Source | Confirm |
|---|---|---|---|
| CAN_TX | RC10 (45) | ⚠ | ☐ |
| CAN_RX | RC11 (46) | ⚠ | ☐ |
| CAN_STBY | RB7 (30) | ⚠ | ☐ |
| Status LED (D4 orange) | RC0 (39) | ⚠ | ☐ |

**Q-D1.** Confirm CAN_TX/RX/STBY pins and the transceiver (ATA6561). ☐
**Q-D2.** CAN bus termination R15 = 120 Ω fitted — is this board an **end node** or **mid-bus**? ☐
**Q-D3.** Confirm LED pin/colour (D4 orange = RC0); is the red LED (D5) populated? ☐

**Q-D4 (GSP ↔ UART alignment — important for firmware).** Our host protocol **GSP** (broker / MCP / GUI) talks over a UART, and it **must bind to the same physical UART/pins the board bring-up doc uses.** The board exposes two UARTs on J1:
- **DEBUG** = DEBUG_TX **RD7 (62)** / DEBUG_RX **RD8 (63)** — the bring-up checklist references this one.
- **TELEMETRY** = TELE_TX **RD6 (60)** / TELE_RX **RD4 (61)**.

Confirm: **GSP runs on the DEBUG UART (RD7/RD8)** — same pins the bring-up uses — and that DEBUG is a **full bidirectional** UART (not TX-only). State which **UART instance** (UART1/2/3) the bring-up firmware assigns to DEBUG so GSP uses the identical peripheral + PPS. If GSP should instead live on the TELEMETRY UART, say so. ☐

---

## E. Analog / ADC map — **needs full confirmation (critical for the 3-channel BEMF design)**
Some analog nets were readable, others not. Please confirm **pin AND which ADC module (ADC1 / ADC2)** each lands on — we want the three BEMF phases on **independent channels** (no mux), so the ADC1/ADC2 split matters.

Re-verification read all of these directly. Please confirm **which ADC module (ADC1 / ADC2)** each ANx belongs to — we want the 3 BEMF phases on **independent channels** (no mux).
| signal | net | dsPIC pin | port / ADC ANx | Confirm ADC# |
|---|---|---|---|---|
| Temperature (NTC) | TEMP | 1 | RA0 / AD3AN5 | ☐ ADC___ |
| Bus voltage | VBUS | 2 | RA7 / AD5AN0 | ☐ ADC___ |
| BEMF_W (divider) | BEMF_W | 3 | RA1 / AD5AN1 | ☐ ADC___ |
| BEMF_N (neutral) | BEMF_N | 6 | RA11 / AD5AN2 | ☐ ADC___ |
| Op-amp ref (DAC) | UREF | 7 | RA8 / DACOUT2 | ☐ |
| ATA_BEMF_U | ATA_BEMF_U | 8 | RA9 / AD1AN3 | ☐ ADC___ |
| ATA_BEMF_V | ATA_BEMF_V | 9 | RA10 / AD1AN4 | ☐ ADC___ |
| ATA_BEMF_W | ATA_BEMF_W | 24 | RB9 / AD2AN3 | ☐ ADC___ |
| BEMF_U (divider) | BEMF_U | 17 | RB5 / AD3AN1 | ☐ ADC___ |
| BEMF_V (divider) | BEMF_V | 23 | RB8 / AD2AN4 | ☐ ADC___ |
| **`Speed` (reserved)** | Speed | **16** | RA6 / AD3AN2 | ☐ — see Q-A1(a) |
| W-phase current (ATA CSA) | W_OA3_OUT | 15 | RA5 / AD3AN0 | ☐ ADC___ |
| DC-bus current (ATA CSA) | IBUS_OA_OUT | 28 | RB4 / AD4AN0 | ☐ ADC___ |
| U-phase current — OA1 OUT/IN−/IN+ | U_OA1_* | 12/13/14 | RA2/RA3/RA4 | ☐ |
| V-phase current — OA2 OUT/IN−/IN+ | V_OA2_* | 20/21/22 | RB0/RB1/RB2 | ☐ |
| (free, no-connect) | — | 27 / 29 | RB3/AD4AN3 · RB6/AD4AN1 | n/a |

**Q-E1.** Confirm the ADC1/ADC2 split for the BEMF phases — can BEMF_U/V/W (or ATA_BEMF_U/V/W) sample **simultaneously on independent channels**? ☐
**Q-E1b.** Confirm `Speed` (pin 16) is an intended analog throttle input and where it connects (ties to Q-A1a). ☐
**Q-E2.** Can the three phase BEMF inputs each be sampled on an **independent ADC channel simultaneously** (not muxed)? Confirm their ADC1/ADC2 distribution supports it. ☐

---

## F. BEMF sensing architecture — **RESOLVED on re-verification; please sanity-check**
Two independent BEMF paths to the MCU, both wired:
- (i) **`BEMF_U/V/W` + `BEMF_N`** = resistor-divider analog (24k/2k + 1000pF + BAT54; 3×24k star neutral) → MCU **RB5(17)/RB8(23)/RA1(3)/RA11(6)** ADC.
- (ii) **`ATA_BEMF_U/V/W`** = ATA6847 **BEMF comparator DIGITAL outputs** (BEMF1/2/3, GDUCR1.BEMFEN=1) → MCU **RA9(8)/RA10(9)/RB9(24)** GPIO + TP8/7/6.
**Q-F1.** Confirm both paths are populated and the pin assignment above. ☐
**Q-F2 (was open — now resolved).** Confirm `ATA_BEMF_U/V/W` are **digital comparator outputs** read as GPIO (matching the garuda-ak-ata-esc firmware), **not** analog. ☐
**Q-F3.** Virtual neutral `BEMF_N`: confirm 3×24k star → R68 680R + C63 6800pF. Was the heavier neutral filter (τ≈4.26 µs vs phase τ≈1.85 µs) intentional? ☐
**Q-F4.** Per-phase BEMF divider: confirm V & W mirror U (R61 24k / R69 2k / C64 1000pF / D13 BAT54) and the 0.0769 ratio / 42 V max. ☐

---

## G. Current sense & shunts
| signal | sense element | amp | nominal | Confirm |
|---|---|---|---|---|
| U phase | shunt (2 mΩ?) | dsPIC OA1 (≈×36.4) | 73 mV/A | ☐ |
| V phase | shunt (2 mΩ?) | dsPIC OA2 (≈×36.4) | 73 mV/A | ☐ |
| W phase | shunt (2 mΩ?) | ATA6847 CSA (×16) | 32 mV/A | ☐ |
| DC bus | shunt (2 mΩ?, SL→GND) | ATA6847 CSA (×16) | 32 mV/A | ☐ |

**Q-G1.** Confirm all four shunt values (2 mΩ each?). ☐
**Q-G2.** Confirm which **ATA6847 CSA channel = W** vs **= DC-bus** (OPA2 vs OPA3), the CSA gain (×16), offset (~VBO2 ≈ 1.65 V), and **polarity** (inverted vs the dsPIC op-amps?). ☐
**Q-G3.** DC-bus shunt location — low-side bus return (SL→GND)? Sign convention for motoring current? ☐

---

## H. Gate driver / power / clock / misc
**Q-H1.** Gate driver labelled **ATA6847T-5033** (note references a "5033L" variant). Confirm exact orderable suffix (the "**L**" affects VDH/VDDIO OV-shutdown bits). ☐
**Q-H2 (resolved — confirm).** Verified: **NRES pulled to VVIO via R3 10k** (not MCU-driven); **LH/RXD/TXD/LIN/WAKE = no-connect** → ATA configured **purely over SPI**. Confirm no MCU reset line is expected. ☐
**Q-H3.** Is **NIRQ** expected to be serviced (interrupt) or polled? Is the ATA watchdog required to be kicked in normal run? ☐
**Q-H4.** Charge pump: confirm the ATA uses its internal charge pump for the high-side (VG/VCP/VDH) — i.e., **no external bootstrap-cap pre-charge step** needed at start? ☐
**Q-H5 (resolved — confirm values).** MOSFET = **BSC028N06NS** (schematic suffix **`NSSC`** — confirm NSSC vs NSSG), 60 V ~2.8 mΩ. Gate net (verified): series **22 Ω** (R18/19/20), turn-off **10 Ω + PMEG3020EJ** (R24-26/D6-8), gate cap **1000 pF** (C42-44), pulldown **120 kΩ** (R21-23), source/LS series **3.3 Ω** (R27-32). Confirm. ☐
**Q-H6.** Bus: 6S, 25 V nominal — confirm **absolute-max bus voltage** and that VBUS divider (24k/2k, 0.0769) + D12 BAT54 clamp suit it. Input bulk C1/C2 = 330 µF/100 V, TVS D1 = SMAJ26A — confirm. ☐
**Q-H7.** Clock: Y1 = **8 MHz MEMS (DSA6001JA3B)** on OSC1/CLKI (pin 40) — confirm, and the intended **FCY / PLL** (system + peripheral clock targets). ☐
**Q-H8.** NTC: TH1 = 10 kΩ — provide **part / β value** (and R65 = 4.7 kΩ) for the temperature curve. ☐
**Q-H9.** Power rails: MCP16367 → 5 V, MCP1755 → 3.3 V, internal buck → VDDCORE ~1.1 V (L2). Confirm PWRGD→MCLR gating does **not** block ICSP, and the power-up sequencing. ☐
**Q-H10.** Spare PWM pins **PWM4H/L = RC2/RC5 (=PGC/PGD)** and **PWM5H/L = RD5/RD6 (=DShot/TELE_TX)** are shared with connector functions — confirm they are **not** independently used for braking / sync-rect, i.e. free for our use. ☐

---

## I. Test points
**Q-I1.** List populated test points (TP1/2 = bus?, TP3 = 5 V, TP4 = 3.3 V, TP6/TP7 = ATA_BEMF?) and whether any expose an ADC-usable node we could borrow for the bench pot. ☐

---

## J. Passive values — **please confirm every value/designator**
These were read from the schematic (0402 1% unless noted). They set ADC scaling, filter bandwidths, and ZC timing in firmware, so each needs confirmation. Where a designator is uncertain it is marked **(desig?)**.

### J.1 BEMF sense — per phase (divider + filter + clamp)
| node | top R | bottom R | filter C | clamp diode | ratio / τ | Confirm |
|---|---|---|---|---|---|---|
| BEMF_U | R61 = 24 k | R69 = 2 k | C64 = 1000 pF/50 V | D13 = BAT54XV2T1G → 3.3 V | 0.0769 / τ≈1.85 µs | ☐ |
| BEMF_V | R?? = 24 k **(desig?)** | R?? = 2 k | C?? = 1000 pF | D14 = BAT54 | same | ☐ |
| BEMF_W | R?? = 24 k **(desig?)** | R?? = 2 k | C?? = 1000 pF | D15 = BAT54 | same | ☐ |

**Q-J1.** Confirm V/W mirror U exactly (values + that each phase has its own 1000 pF + BAT54). Confirm the **42 V** full-scale assumption behind 0.0769. ☐

### J.2 Virtual neutral (BEMF_N)
| element | value | Confirm |
|---|---|---|
| Star resistors (PHASE_U/V/W → node) | R60 / R64 / R67 = **24 k each** | ☐ |
| Series R to node | R68 = **680 Ω** | ☐ |
| Filter C to GND | C63 = **6800 pF/50 V** | ☐ |

**Q-J2.** Confirm; note τ_N ≈ 4.26 µs (≈2.3× the per-phase 1.85 µs). Intentional? ☐

### J.3 Phase current sense — dsPIC op-amps (U = OA1, V = OA2)
| element (U / OA1) | value | mirror (V / OA2) | Confirm |
|---|---|---|---|
| Series in (IN+ / IN−) | R43 / R51 = **330 Ω** | R40 / R42 = 330 Ω **(desig?)** | ☐ |
| To op-amp | R41 / R49 = **470 Ω** | R44 / R45 = 470 Ω **(desig?)** | ☐ |
| Feedback R ∥ C | R54 = **12 k** ∥ C54 = **22 pF** | R52 = 12 k ∥ C55 = 22 pF **(desig?)** | ☐ |
| UREF bias R | R39 = **12 k** | (mirror) | ☐ |
| Filter caps | C48 = 1500 pF (IN+→GND), **C51 = 2200 pF (diff)**, C56 = 1500 pF (IN−→GND) | C49 / C52 / C57 = 1500/2200/1500 pF | ☐ |
| Gain | R54/R43 = **36.4** → 73 mV/A @ 2 mΩ | same | ☐ |

**Q-J3.** Confirm U-chain values and that V mirrors it (V designators are inferred). ☐

### J.4 W-phase & DC-bus current — ATA6847 CSA path
| element | value | Confirm |
|---|---|---|
| Shunts (W, DC-bus) | **2 mΩ** each | ☐ |
| CSA input anti-alias | R56 / R58 = **4.7 Ω** + C59 / C60 / C61 = **0.022 µF** | ☐ |
| DC-bus CSA output RC | R5 = **360 Ω** + C17 = **680 pF** → IBUS_OA_OUT (fc≈650 kHz) | ☐ |
| W CSA output RC | R6 = **360 Ω** + C18 = **680 pF** → W_OA_OUT | ☐ |
| CSA gain / offset | ×16 / offset ≈ VBO2 (~1.65 V) | ☐ |

**Q-J4.** Confirm shunt values and the 360 Ω/680 pF output filters; confirm which CSA (R5/C17 vs R6/C18) is DC-bus vs W. ☐

### J.5 VBUS & TEMP
| node | elements | Confirm |
|---|---|---|
| VBUS | R59 = **24 k** / R66 = **2 k** (0.0769), C62 = **1000 pF/50 V**, D12 = BAT54XV → 3.3 V | ☐ |
| TEMP | TH1 = **10 k NTC** (β = ? ), R65 = **4.7 kΩ** (3.3 V→TH1→TEMP→R65→GND) | ☐ |

**Q-J5.** Confirm VBUS divider/clamp and the NTC part + **β value** (needed for the temp curve). ☐

### J.6 ATA6847 supply & charge-pump passives
| node | value | Confirm |
|---|---|---|
| VS (pin 3) | FB1 = **600 Ω** + C4 = **10 µF/50 V** + C5 = **0.1 µF** | ☐ |
| VDD1 (pin 48, 5 V LDO) | C7 = **2.2 µF/16 V** | ☐ |
| VDD2 / VVIO (pin 1, 3.3 V LDO) | C8 = **2.2 µF/16 V** | ☐ |
| VDH (pin 15) | C3 = **0.1 µF** + C6 = **1 µF** | ☐ |
| CPP2/CPN2 (17/16) | C9 = **0.22 µF/50 V** (0603) | ☐ |
| VG (pin 9) | C10 = **3.3 µF/25 V** (0805) | ☐ |
| CPP1/CPN1 (13/14) | C12 = **0.22 µF/50 V** (0603) | ☐ |
| LH (pin 2) | R3 = **10 kΩ** → VVIO | ☐ |

**Q-J6.** Confirm charge-pump + supply decoupling values. ☐

### J.7 Power input & reset
| node | value | Confirm |
|---|---|---|
| Bus bulk | C1 / C2 = **330 µF/100 V** | ☐ |
| Bus TVS | D1 = **SMAJ26A** | ☐ |
| AVDD filter | FB3 = **120 Ω** + C29 1 µF + C30 0.1 µF | ☐ |
| VDDCORE (pin 56) | C34 = 10 µF + C33 0.1 µF (internal buck, L2) | ☐ |
| MCLR / PWRGD gate | R14, R16 = **0 Ω**, R17 = **470 Ω**, C38 | ☐ |

**Q-J7.** Confirm bulk/TVS, AVDD ferrite, VDDCORE buck inductor L2 value, and the MCLR gating network. ☐

### J.8 Gate drive
| element | value | Confirm |
|---|---|---|
| Gate series R (HS/LS) | R?? = **(value?)** | ☐ |
| Gate turn-off diodes | D6–D11 = **PMEG3020EJ** | ☐ |
| Gate-source pulldown (if any) | **(value?)** | ☐ |

**Q-J8 (resolved — confirm).** Gate net read off the bridge: series **R18/19/20 = 22 Ω**, turn-off **R24-26 = 10 Ω + D6-8 = PMEG3020EJ**, gate cap **C42-44 = 1000 pF/50 V**, pulldown **R21-23 = 120 kΩ**, source/LS series **R27-32 = 3.3 Ω**, per-leg bus decoupling **C39-41 = 10 µF/75 V**. Confirm. ☐

---

*Reply inline in the Confirm column (✓ / correction). Anything in ❓ / (desig?) / (value?) rows is something we need from you. Pair with `GarudaESE_PinMap.md`.*
