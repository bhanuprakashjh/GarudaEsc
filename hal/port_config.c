/**
 * @file port_config.c
 * @brief GPIO + PPS init for the GarudaESE / EV60Y51A board.
 *
 * Target: dsPIC33AK256MC506-E/M7 (64-VQFN) + ATA6847T-5033.
 * Schematic-verified pin map (see garuda_board.h). Ported from the AK512
 * dspic33AKESC 6-step tree; board layer rewritten for GarudaESE.
 *
 * Key board facts baked in here:
 *   - PWM PG1=U/PG2=V/PG3=W on RD2/RD3, RD0/RD1, RC3/RC4 (same pins as MCLV).
 *   - U/V phase current via internal op-amps OA1/OA2 (RA2/3/4, RB0/1/2).
 *   - W + DC-bus current via ATA6847 CSA → analog inputs RA5 / RB4 (NOT OA3).
 *   - BEMF: resistor-divider analog on RB5/RB8/RA1 + neutral RA11 (ADC ZC),
 *           AND ATA6847 comparator DIGITAL outputs on RA9/RA10/RB9 (GPIO ZC).
 *   - SPI2 (not SPI1) to the ATA6847.
 */

#include <xc.h>
#include "port_config.h"
#include "../garuda_config.h"

void SetupGPIOPorts(void)
{
    /* All pins → digital input, low. */
    #ifdef TRISA
        TRISA = 0xFFFF; LATA = 0x0000;
    #endif
    #ifdef ANSELA
        ANSELA = 0x0000;
    #endif
    #ifdef TRISB
        TRISB = 0xFFFF; LATB = 0x0000;
    #endif
    #ifdef ANSELB
        ANSELB = 0x0000;
    #endif
    #ifdef TRISC
        TRISC = 0xFFFF; LATC = 0x0000;
    #endif
    #ifdef ANSELC
        ANSELC = 0x0000;
    #endif
    #ifdef TRISD
        TRISD = 0xFFFF; LATD = 0x0000;
    #endif
    #ifdef ANSELD
        ANSELD = 0x0000;
    #endif

    MapGPIOHWFunction();
}

void MapGPIOHWFunction(void)
{
    /* ── Motor PWM outputs (PG1=U, PG2=V, PG3=W) ─────────────────────
     * PWM1H=RD2, PWM1L=RD3, PWM2H=RD0, PWM2L=RD1, PWM3H=RC3, PWM3L=RC4.
     * Polarity / dead-time set in hal_pwm.c (HS active-LOW for ATA NBH;
     * MCU dead-time ~0, ATA applies internal tCC). */
    TRISDbits.TRISD2 = 0; TRISDbits.TRISD3 = 0;
    TRISDbits.TRISD0 = 0; TRISDbits.TRISD1 = 0;
    TRISCbits.TRISC3 = 0; TRISCbits.TRISC4 = 0;

    /* ── U/V phase-current internal op-amps (OA1/OA2) ────────────────
     * OA1IN+ RA4, OA1IN- RA3, OA1OUT RA2 (AD1AN0 = U current)
     * OA2IN+ RB2, OA2IN- RB1, OA2OUT RB0 (AD2AN0 = V current) */
    ANSELAbits.ANSELA4 = 1; TRISAbits.TRISA4 = 1;   /* OA1IN+ */
    ANSELAbits.ANSELA3 = 1; TRISAbits.TRISA3 = 1;   /* OA1IN- */
    ANSELAbits.ANSELA2 = 1; TRISAbits.TRISA2 = 1;   /* OA1OUT */
    ANSELBbits.ANSELB2 = 1; TRISBbits.TRISB2 = 1;   /* OA2IN+ */
    ANSELBbits.ANSELB1 = 1; TRISBbits.TRISB1 = 1;   /* OA2IN- */
    ANSELBbits.ANSELB0 = 1; TRISBbits.TRISB0 = 1;   /* OA2OUT */

    /* ── Current sense: 4× 2 mΩ shunts, mixed amplification (schematic pg5) ──
     * Iu = dsPIC OA1 (RA2 out → AD1AN0), Iv = dsPIC OA2 (RB0 out → AD2AN0).
     * Iw = ATA6847 CSA2 (W_OPP2/W_OPN2) → W_OA3_OUT → RA5 = AD3AN0.
     * Ibus = ATA6847 CSA3 (IBUS_OPP3/OPN3) → IBUS_OA_OUT → RB4 = AD4AN0.
     * All FOUR currents are real and read by the dsPIC ADC (Iw is NOT computed).
     * Per the ATA6847 datasheet, BEMF comparators conflict ONLY with CSA1; CSA2
     * and CSA3 run alongside BEMF — so W/bus current sense + BEMF coexist (we
     * enable CSA2|CSA3, leave CSA1 off — see hal_ata6847.c). RA5/RB4 are analog
     * inputs (the ATA op-amp outputs), NOT dsPIC op-amp pins (dsPIC OA3 unused). */
    ANSELAbits.ANSELA5 = 1; TRISAbits.TRISA5 = 1;   /* RA5 = AD3AN0  ← ATA CSA2 (Iw)  */
    ANSELBbits.ANSELB4 = 1; TRISBbits.TRISB4 = 1;   /* RB4 = AD4AN0  ← ATA CSA3 (Ibus) */

    /* ── BEMF resistor-divider analog inputs (ADC ZC: options Z2/Z3) ─
     * BEMF_U RB5 (AD3AN1), BEMF_V RB8 (AD2AN4), BEMF_W RA1 (AD5AN1),
     * BEMF_N RA11 (AD5AN2, virtual neutral). */
    ANSELBbits.ANSELB5  = 1; TRISBbits.TRISB5  = 1;  /* BEMF_U */
    ANSELBbits.ANSELB8  = 1; TRISBbits.TRISB8  = 1;  /* BEMF_V */
    ANSELAbits.ANSELA1  = 1; TRISAbits.TRISA1  = 1;  /* BEMF_W */
    ANSELAbits.ANSELA11 = 1; TRISAbits.TRISA11 = 1;  /* BEMF_N */

    /* ── ATA6847 BEMF comparator DIGITAL outputs (GPIO ZC: option Z1) ─
     * BEMF1/2/3 from the ATA (GDUCR1.BEMFEN=1) on RA9/RA10/RB9.
     * Force DIGITAL: ANSEL=0 (these pins are also AD1AN3/AD1AN4/AD2AN3). */
    ANSELAbits.ANSELA9  = 0; TRISAbits.TRISA9  = 1;  /* ATA_BEMF_U */
    ANSELAbits.ANSELA10 = 0; TRISAbits.TRISA10 = 1;  /* ATA_BEMF_V */
    ANSELBbits.ANSELB9  = 0; TRISBbits.TRISB9  = 1;  /* ATA_BEMF_W */

    /* ── VBUS / TEMP / Speed analog inputs ──────────────────────────
     * VBUS RA7 (AD5AN0), TEMP RA0 (AD3AN5), Speed RA6 (AD3AN2, reserved). */
    ANSELAbits.ANSELA7 = 1; TRISAbits.TRISA7 = 1;    /* VBUS */
    ANSELAbits.ANSELA0 = 1; TRISAbits.TRISA0 = 1;    /* TEMP */
    ANSELAbits.ANSELA6 = 1; TRISAbits.TRISA6 = 1;    /* Speed/POT throttle = TP5 (AD3AN2) */
    /* UREF RA8 is a DAC output (DACOUT2) — leave to the DAC peripheral. */

    /* ── SPI2 ↔ ATA6847 (PPS) ───────────────────────────────────────
     * Direction follows the BOARD net routing (EV60Y51A schematic, traced):
     *   net SPI_SCK : RB10(RP27)  ──> ATA SCK (pin47)        master clock OUT
     *   net SPI_SDI : RB11(RP28)  ──> ATA SDI (pin46)        data INTO ATA → dsPIC OUT (SDO2)
     *   net SPI_SDO : RC9 (RP42)  <── ATA SDO (pin45)        data FROM ATA → dsPIC IN  (SDI2)
     * => dsPIC pin32(RB11)=SPI data OUT, pin34(RC9)=SPI data IN.
     * NOTE the board author named the nets after the dsPIC pins' DEFAULT
     * functions (RB11=SDI2, RC9=SDO2) but wired SDI↔SDI / SDO↔SDO — backwards
     * for SPI. PPS lets any RPn be SDO2-out or SDI2-in, so we follow the
     * routing, not the pin name. (Earlier rev had these two swapped → the
     * dsPIC never drove the ATA's SDI, gates stayed dead.)
     * nCS = RC8 GPIO (idle high); nIRQ = RC6 GPIO input. */
    _RP27R = 29;            /* RB10 (RP27) -> SCK2OUT (MC506 code 29; ref-FW proven, AK128 table said 17) -> ATA SCK (pin47) */
    _RP28R = 28;            /* RB11 (RP28, pin32) -> SDO2 (MC506 code 28; ref-FW proven) -> ATA SDI (pin46) */
    _SDI2R = 42;            /* SDI2 (data IN) ← RP42 (RC9, pin34) ← ATA SDO (pin45) */
    TRISBbits.TRISB11 = 0;  /* RB11 = SDO2 output */
    TRISCbits.TRISC9  = 1;  /* RC9  = SDI2 input  */
    TRISCbits.TRISC8 = 0; LATCbits.LATC8 = 1;        /* nCS idle high */
    TRISCbits.TRISC6 = 1;                            /* nIRQ input */

    /* ── UART1 = GSP on the DEBUG pins (RD7 TX / RD8 RX) ─────────────
     * Same UART the board bring-up uses (confirm instance, HW sheet Q-D4). */
    _RP56R  = 19;            /* RD7 -> U1TX (MC506 code 19; ref-FW proven, AK128 table said 9) */
    _U1RXR  = 57;           /* U1RX ← RP57 (RD8) */

    /* ── CAN (ATA6561) ──────────────────────────────────────────────
     * CAN_TX RC10, CAN_RX RC11, CAN_STBY RB7. PPS for CAN1 TX/RX is set
     * by the CAN driver if enabled; STBY is a plain GPIO output. */
    TRISBbits.TRISB7 = 0; LATBbits.LATB7 = 1;        /* CAN_STBY high = standby until CAN init */

    /* ── Status LED (RC0) ───────────────────────────────────────────── */
    TRISCbits.TRISC0 = 0; LATCbits.LATC0 = 0;

    /* ── Bench ARM switch on DShot pin (RD5) ────────────────────────── */
    TRISDbits.TRISD5 = 1;                            /* input (use internal pull-up via CNPU if needed) */

    /* ── Dedicated ARM toggle switch on RD4 (J1 TELE_RX, free) ────────
     * Active-low: switch→GND closes = armed; internal pull-up = open/disarmed.
     * See FEATURE_ARM_SWITCH (main.c). */
    TRISDbits.TRISD4 = 1;                            /* input */
    CNPUDbits.CNPUD4 = 1;                            /* internal pull-up (open reads high = disarmed) */
}

/**
 * @brief Initialize OA1/OA2 internal op-amps — U/V phase-current sense.
 * External gain network on the GarudaESE board (R54/R43 etc., ~×36 → 73 mV/A).
 * OA1OUT (RA2) → AD1AN0 (Iu), OA2OUT (RB0) → AD2AN0 (Iv).
 *
 * NOTE: the AK256MC506 op-amp has no OMONEN bit (unlike the AK512); AMPEN=1
 * drives OAxOUT to its dedicated pin and the ADC samples that pin directly.
 */
void HAL_OA12_Init(void)
{
    /* UREF first: the board biases the OA1/OA2 diff networks from DACOUT2
     * (RA8) via R39 12k — a DAC-generated 1.65 V mid-rail, NOT a resistor
     * divider. Without this the bias pin floats and Iu/Iv read garbage.
     * Ported from the Microchip EV60Y51A reference (DAC2_InitFixedOutput_1V65,
     * bench-proven on this board). */
    TRISAbits.TRISA8 = 0;              /* DACOUT2 pin */
    DACCTRL1bits.ON = 0;
    DACCTRL2bits.TMODTIME = 0x00;      /* no transition mode — static output */
    DACCTRL2bits.SSTIME   = 0x8A;      /* steady-state filter timing (ref value) */
    DAC2DATbits.DACDAT = 0x800;        /* 1.65 V = 2048/4095 * 3.3 V */
    DAC2SLPCONbits.SLOPEN = 0;         /* no slope/hysteretic/triangle modes */
    DAC2SLPCONbits.HME    = 0;
    DAC2SLPCONbits.TWME   = 0;
    DAC2CONbits.UPDTRG   = 0b11;       /* immediate update on DACxDAT write */
    DAC2CONbits.UPDTMDIS = 1;
    DAC2CONbits.DACOEN   = 1;          /* drive DACOUT2 pin */
    DAC2CONbits.DACEN    = 1;
    DACCTRL1bits.ON = 1;               /* global DAC enable */

    AMP1CON1 = 0x0000;
    AMP1CON1bits.HPEN    = 1;     /* high-bandwidth */
    AMP1CON1bits.UGE     = 0;     /* external-resistor gain */
    AMP1CON1bits.DIFFCON = 0;

    AMP2CON1 = 0x0000;
    AMP2CON1bits.HPEN    = 1;
    AMP2CON1bits.UGE     = 0;
    AMP2CON1bits.DIFFCON = 0;

    AMP1CON1bits.AMPEN = 1;
    AMP2CON1bits.AMPEN = 1;

    /* Op-amp outputs need ~10 us to settle before the ADC samples them
     * (reference does the same). ~200 nop/us at FCY -> 4000 nop ~= 20 us. */
    for (uint16_t i = 0; i < 4000U; i++) { __builtin_nop(); }
}

#if FEATURE_HW_OVERCURRENT
/**
 * @brief NOT used on GarudaESE — W and DC-bus current come from the ATA6847
 * CSA (analog inputs RA5/RB4), not the dsPIC OA3. Bus overcurrent should use
 * the ATA6847 ILIM/SCPCR, or a comparator on the RB4 (IBUS) ADC pin.
 * Kept as a no-op so FEATURE_HW_OVERCURRENT builds; leave the feature OFF
 * for initial bring-up.
 */
void HAL_OA3_Init(void)
{
    /* intentionally empty for GarudaESE */
}
#endif
