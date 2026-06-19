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

    /* ── Current sense = dsPIC OA1/OA2 ONLY (see note) ──────────────
     * The ATA6847 op-amp block is configured for BEMF (3 comparators,
     * GDUCR1.BEMFEN=1) — this is MUTUALLY EXCLUSIVE with the ATA current-
     * sense amplifiers. So the schematic's ATA-CSA paths for W (OPA2→RA5,
     * net W_OA3_OUT) and DC-bus (OPA3→RB4, net IBUS_OA_OUT) are INACTIVE.
     *   Iu = dsPIC OA1 (RA2 out), Iv = dsPIC OA2 (RB0 out);  Iw = -(Iu+Iv).
     * RA5/RB4 are left as inputs but carry no valid signal in BEMF mode;
     * overcurrent uses phase currents + ATA SCPCR/ILIM (FEATURE_HW_OVERCURRENT
     * stays OFF — the 512 OA3/CMP3 bus-OC path does not exist here). */
    ANSELAbits.ANSELA5 = 1; TRISAbits.TRISA5 = 1;   /* RA5 (ATA W out — inactive in BEMF mode) */
    ANSELBbits.ANSELB4 = 1; TRISBbits.TRISB4 = 1;   /* RB4 (ATA bus out — inactive in BEMF mode) */

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
    ANSELAbits.ANSELA6 = 1; TRISAbits.TRISA6 = 1;    /* Speed (reserved/unrouted) */
    /* UREF RA8 is a DAC output (DACOUT2) — leave to the DAC peripheral. */

    /* ── SPI2 ↔ ATA6847 (PPS) ───────────────────────────────────────
     * SCK2OUT(17) → RP27(RB10); SDO2(16) → RP42(RC9); SDI2 ← RP28(RB11).
     * nCS = RC8 GPIO (idle high); nIRQ = RC6 GPIO input. */
    _RP27R = 17;            /* RB10 → SCK2OUT */
    _RP42R = 16;            /* RC9  → SDO2    */
    _SDI2R = 28;            /* SDI2 ← RP28 (RB11) */
    TRISCbits.TRISC8 = 0; LATCbits.LATC8 = 1;        /* nCS idle high */
    TRISCbits.TRISC6 = 1;                            /* nIRQ input */

    /* ── UART1 = GSP on the DEBUG pins (RD7 TX / RD8 RX) ─────────────
     * Same UART the board bring-up uses (confirm instance, HW sheet Q-D4). */
    _RP56R  = 9;            /* RD7 → U1TX */
    _U1RXR  = 57;           /* U1RX ← RP57 (RD8) */

    /* ── CAN (ATA6561) ──────────────────────────────────────────────
     * CAN_TX RC10, CAN_RX RC11, CAN_STBY RB7. PPS for CAN1 TX/RX is set
     * by the CAN driver if enabled; STBY is a plain GPIO output. */
    TRISBbits.TRISB7 = 0; LATBbits.LATB7 = 1;        /* CAN_STBY high = standby until CAN init */

    /* ── Status LED (RC0) ───────────────────────────────────────────── */
    TRISCbits.TRISC0 = 0; LATCbits.LATC0 = 0;

    /* ── Bench ARM switch on DShot pin (RD5) ────────────────────────── */
    TRISDbits.TRISD5 = 1;                            /* input (use internal pull-up via CNPU if needed) */
}

/**
 * @brief Initialize OA1/OA2 internal op-amps — U/V phase-current sense.
 * External gain network on the GarudaESE board (R54/R43 etc., ~×36 → 73 mV/A).
 * OA1OUT (RA2) → AD1AN0 (Iu), OA2OUT (RB0) → AD2AN0 (Iv).
 *
 * OMONEN kept = 1 on the AK512 bench board (datasheet "one instance" note did
 * not match observed behaviour there). On GarudaESE only OA1/OA2 are used
 * (OA3 free) so the shared-monitor-bus concern is moot — verify on bring-up.
 */
void HAL_OA12_Init(void)
{
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
