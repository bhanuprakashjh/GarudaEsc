/**
 * @file garuda_board.h
 * @brief GarudaESE / EV60Y51A board pin map — single source of truth.
 *
 * dsPIC33AK256MC506-E/M7 (64-VQFN) + ATA6847T-5033 + BSC028N06 MOSFETs.
 * Every pin below was read directly off the EV60Y51A-V1.0 schematic
 * (2 verification passes). Items still pending the hardware designer are
 * marked CONFIRM — see GarudaESE_HW_Confirmation_Sheet.
 *
 * PPS output-source codes (AK family, DS70005539 Table 11-13):
 *   U1TX=9  SDO1=13 SCK1OUT=14  SDO2=16 SCK2OUT=17 SS2OUT=18
 */
#ifndef GARUDA_BOARD_H
#define GARUDA_BOARD_H

/* ── Motor PWM → ATA6847 (PG1=U, PG2=V, PG3=W; HS active-LOW; DT internal) ── */
#define PIN_PWM1H_RD2   /* pin51 → ATA NBH1 */
#define PIN_PWM1L_RD3   /* pin52 → ATA IL1  */
#define PIN_PWM2H_RD0   /* pin49 → ATA NBH2 */
#define PIN_PWM2L_RD1   /* pin50 → ATA IL2  */
#define PIN_PWM3H_RC3   /* pin43 → ATA NBH3 */
#define PIN_PWM3L_RC4   /* pin44 → ATA IL3  */

/* ── SPI2 ↔ ATA6847 (verified: SPI2-native pins) ────────────────── */
#define SPI2_SCK_RB10   /* pin31  RP27, code SCK2OUT=17 */
#define SPI2_SDI_RB11   /* pin32  RP28 (ATA SDO→MCU)    */
#define SPI2_SDO_RC9    /* pin34  RP42, code SDO2=16 (MCU→ATA SDI) */
#define SPI2_NCS_RC8    /* pin33  RP41, GPIO out idle-high */
#define SPI2_NIRQ_RC6   /* pin35  RP39, GPIO in */

/* ── Comms / status ──────────────────────────────────────────────── */
#define PIN_DSHOT_RD5   /* pin59 RP54 — also bench ARM switch */
#define PIN_TELE_TX_RD6 /* pin60 RP55 */
#define PIN_TELE_RX_RD4 /* pin61 RP53 */
#define PIN_DEBUG_TX_RD7/* pin62 RP56 — GSP UART TX */
#define PIN_DEBUG_RX_RD8/* pin63 RP57 — GSP UART RX */
#define PIN_CAN_TX_RC10 /* pin45 */
#define PIN_CAN_RX_RC11 /* pin46 */
#define PIN_CAN_STBY_RB7/* pin30 */
#define PIN_LED_RC0     /* pin39 D4 orange (via R11 2.2k) */

/* ── Analog (ADC) — pin · ADC channel ────────────────────────────── */
#define AN_TEMP_RA0          /* pin1  AD3AN5  10k NTC / 4.7k */
#define AN_VBUS_RA7          /* pin2  AD5AN0  div 0.0769, 42V FS */
#define AN_BEMF_W_RA1        /* pin3  AD5AN1  divider */
#define AN_BEMF_N_RA11       /* pin6  AD5AN2  virtual neutral */
#define AN_UREF_RA8          /* pin7  DACOUT2 (op-amp ref, DAC-driven) */
#define AN_BEMF_U_RB5        /* pin17 AD3AN1  divider */
#define AN_BEMF_V_RB8        /* pin23 AD2AN4  divider */
#define AN_SPEED_RA6         /* pin16 AD3AN2  RESERVED throttle (unrouted) */
#define AN_IW_RA5            /* pin15 AD3AN0  W-phase current (ATA CSA out) */
#define AN_IBUS_RB4          /* pin28 AD4AN0  DC-bus current (ATA CSA out) */
/* U/V phase current via internal op-amps OA1/OA2: */
#define OA1_OUT_RA2          /* pin12 AD1AN0  U current out */
#define OA1_INM_RA3          /* pin13 */
#define OA1_INP_RA4          /* pin14 */
#define OA2_OUT_RB0          /* pin20 AD2AN0  V current out */
#define OA2_INM_RB1          /* pin21 */
#define OA2_INP_RB2          /* pin22 */

/* ── ATA6847 BEMF comparator DIGITAL outputs (GPIO ZC, option Z1) ── */
#define DIG_ATA_BEMF_U_RA9   /* pin8  BEMF1 (read as GPIO) */
#define DIG_ATA_BEMF_V_RA10  /* pin9  BEMF2 */
#define DIG_ATA_BEMF_W_RB9   /* pin24 BEMF3 */

/* ── Clock / reset ───────────────────────────────────────────────── */
#define PIN_OSC1_RC1         /* pin40 Y1 8MHz MEMS (or internal FRC) */
/* MCLR = pin64 (PWRGD-gated) */

/* ── Build constants needed by the ATA driver / libpic30 delays ────── */
#ifndef FCY
#define FCY                 200000000UL   /* 200 MHz (8MHz FRC × PLL) */
#endif

/* ATA6847 startup current-limit DAC (ILIMTH). Threshold counts, not amps —
 * tune on bench. The ata-esc tree mostly DISABLED ILIM (chop capped eRPM with
 * props); here we keep it available for a current-limited start.
 * 2026-07-11: TRIED 120->40 to catch the ~9A handoff spike; DAC=40 chopped
 * BELOW the 5A align -> firmware BUSY, would not start (survived power-cycle).
 * Reverted 40->120 + disabled ILIM (hal_ata6847.c). Bracket for any future
 * retry: DAC=40 -> chop <5A, DAC=120 -> ~15-25A; ~7A target is around DAC 55. */
#ifndef ILIM_DAC
#define ILIM_DAC            120U
#endif

#endif /* GARUDA_BOARD_H */
