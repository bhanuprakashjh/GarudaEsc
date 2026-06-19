/**
 * @file hal_adc.c
 * @brief ADC configuration for the GarudaESE / EV60Y51A board.
 *
 * dsPIC33AK256MC506 — ADC cores AD1/AD2/AD3/AD5 used. The three BEMF phases
 * sit on three different cores (the board pins dictate the core), so they are
 * sampled SIMULTANEOUSLY every PG1TRIGA trigger — there is NO Phase-A/C mux
 * and no settle penalty (unlike the MCLV base this was ported from).
 *
 * Channel map (see hal_adc.h for the table):
 *   AD1CH0=Iu, AD2CH0=Iv, AD2CH1=BEMF_V, AD3CH0=BEMF_U, AD3CH1=TEMP,
 *   AD3CH2=Speed, AD5CH0=BEMF_W, AD5CH1=BEMF_N, AD5CH2=VBUS.
 *
 * Register model CONFIRMED against the dsPIC33AK256MC506 data sheet (DS70005591,
 * dsPIC33AK512MPS512 family — the part's actual DS): FIVE 12-bit ADC cores
 * (ADC1..ADC5), 16 settings channels each, per-channel digital comparator.
 *   - Channel config  = ADnCHxCON1 : PINSEL[3:0], SAMC[4:0], TRG1SRC[5:0],
 *                       DIFF, FRAC (left-align), MODE[1:0], TRG2SRC, NINSEL.
 *   - Channel comparator = ADnCHxCON2 (+ ADnCHxCMPLO/CMPHI).
 *   - Per-core control = ADnCON : ON, ADRDY, MODE, CAL*, RPTCNT, STNDBY.
 * All channels trigger on PG1TRIGA (TRG1SRC=4, 24 kHz, set by hal_pwm).
 * (PINSEL value = the ANn index within that core, e.g. BEMF_U=AD3AN1 -> PINSEL 1.)
 */

#include <xc.h>
#include <stdint.h>
#include <stdbool.h>

#include "hal_adc.h"
#include "../garuda_config.h"

void InitializeADCs(void)
{
    /* ---- ADC1 : Iu (OA1OUT = RA2 = AD1AN0) ---- */
    AD1CH0CON1bits.PINSEL = 0;
    AD1CH0CON1bits.SAMC = 3;            /* low-Z op-amp output */
    AD1CH0CON1bits.FRAC = 0;
    AD1CH0CON1bits.DIFF = 0;
    AD1CH0CON1bits.TRG1SRC = 4;         /* PG1TRIGA */

    /* ---- ADC2 : Iv (CH0, OA2OUT = RB0 = AD2AN0) + BEMF_V (CH1, RB8 = AD2AN4) ---- */
    AD2CH0CON1bits.PINSEL = 0;
    AD2CH0CON1bits.SAMC = 3;
    AD2CH0CON1bits.FRAC = 0;
    AD2CH0CON1bits.DIFF = 0;
    AD2CH0CON1bits.TRG1SRC = 4;

    AD2CH1CON1bits.PINSEL = 4;          /* BEMF_V divider */
    AD2CH1CON1bits.SAMC = 5;            /* higher Z divider */
    AD2CH1CON1bits.FRAC = 0;
    AD2CH1CON1bits.DIFF = 0;
    AD2CH1CON1bits.TRG1SRC = 4;

    /* ---- ADC3 : BEMF_U (CH0, RB5=AD3AN1) + TEMP (CH1, RA0=AD3AN5) + Speed (CH2, RA6=AD3AN2) ---- */
    AD3CH0CON1bits.PINSEL = 1;          /* BEMF_U divider */
    AD3CH0CON1bits.SAMC = 5;
    AD3CH0CON1bits.FRAC = 0;
    AD3CH0CON1bits.DIFF = 0;
    AD3CH0CON1bits.TRG1SRC = 4;

    AD3CH1CON1bits.PINSEL = 5;          /* TEMP (NTC) */
    AD3CH1CON1bits.SAMC = 5;
    AD3CH1CON1bits.FRAC = 0;
    AD3CH1CON1bits.DIFF = 0;
    AD3CH1CON1bits.TRG1SRC = 4;

    AD3CH2CON1bits.PINSEL = 2;          /* Speed (reserved/unrouted) */
    AD3CH2CON1bits.SAMC = 5;
    AD3CH2CON1bits.FRAC = 0;
    AD3CH2CON1bits.DIFF = 0;
    AD3CH2CON1bits.TRG1SRC = 4;

    /* ---- ADC5 : BEMF_W (CH0, RA1=AD5AN1) + BEMF_N (CH1, RA11=AD5AN2) + VBUS (CH2, RA7=AD5AN0) ---- */
    AD5CH0CON1bits.PINSEL = 1;          /* BEMF_W divider */
    AD5CH0CON1bits.SAMC = 5;
    AD5CH0CON1bits.FRAC = 0;
    AD5CH0CON1bits.DIFF = 0;
    AD5CH0CON1bits.TRG1SRC = 4;

    AD5CH1CON1bits.PINSEL = 2;          /* BEMF_N virtual neutral */
    AD5CH1CON1bits.SAMC = 5;
    AD5CH1CON1bits.FRAC = 0;
    AD5CH1CON1bits.DIFF = 0;
    AD5CH1CON1bits.TRG1SRC = 4;

    AD5CH2CON1bits.PINSEL = 0;          /* VBUS divider */
    AD5CH2CON1bits.SAMC = 5;
    AD5CH2CON1bits.FRAC = 0;
    AD5CH2CON1bits.DIFF = 0;
    AD5CH2CON1bits.TRG1SRC = 4;

    /* ---- Power up the cores ---- */
    AD1CONbits.ON = 1; while (AD1CONbits.ADRDY == 0);
    AD2CONbits.ON = 1; while (AD2CONbits.ADRDY == 0);
    AD3CONbits.ON = 1; while (AD3CONbits.ADRDY == 0);
    AD5CONbits.ON = 1; while (AD5CONbits.ADRDY == 0);

    /* ADC interrupt on Iu completion (AD1CH0) — always sampled, the ISR
     * anchor. Disabled until the service layer enables it. */
    _AD1CH0IP = 7;
    _AD1CH0IF = 0;
    _AD1CH0IE = 0;
}

#if FEATURE_ADC_CMP_ZC
/* ---------------------------------------------------------------------------
 * High-speed ADC-comparator ZC helpers.
 *
 * PORTED-AS-IS from the MCLV base and NOT yet remapped for GarudaESE. On this
 * board the hardware ZC option (Z1) uses the ATA6847 BEMF comparators read as
 * GPIO; the ADC-comparator option (Z2) would arm digital comparators on the
 * dedicated BEMF channels (AD3CH0/AD2CH1/AD5CH0). Keep FEATURE_ADC_CMP_ZC OFF
 * until these are retargeted — see INTEGRATION_TODO.md.
 * ------------------------------------------------------------------------- */
void HAL_ADC_InitHighSpeedBEMF(void)
{
    _AD1CMP5IF = 0; _AD1CMP5IE = 0;
    _AD2CMP1IF = 0; _AD2CMP1IE = 0;
}

void HAL_ADC_ConfigComparator(uint8_t adcCore, uint16_t threshold, bool risingZc)
{
    if (adcCore == 1) { AD1CH5CON1bits.CMPMOD = risingZc ? 0b011 : 0b100; AD1CH5CMPLO = threshold; }
    else              { AD2CH1CON1bits.CMPMOD = risingZc ? 0b011 : 0b100; AD2CH1CMPLO = threshold; }
}

void HAL_ADC_UpdateComparatorThreshold(uint8_t adcCore, uint16_t threshold)
{
    if (adcCore == 1) AD1CH5CMPLO = threshold; else AD2CH1CMPLO = threshold;
}

void HAL_ADC_EnableComparatorIE(uint8_t adcCore)
{
    if (adcCore == 1) { _AD1CMP5IF = 0; _AD1CMP5IE = 1; }
    else              { _AD2CMP1IF = 0; _AD2CMP1IE = 1; }
}

void HAL_ADC_DisableComparatorIE(uint8_t adcCore)
{
    if (adcCore == 1) _AD1CMP5IE = 0; else _AD2CMP1IE = 0;
}

void HAL_ADC_ClearComparatorFlag(uint8_t adcCore)
{
    if (adcCore == 1) { AD1CMPSTATbits.CH5CMP = 0; _AD1CMP5IF = 0; }
    else              { AD2CMPSTATbits.CH1CMP = 0; _AD2CMP1IF = 0; }
}

void HAL_ADC_SetHighSpeedPinsel(uint8_t pinsel)
{
    AD2CH1CON1bits.PINSEL = pinsel;
}
#endif /* FEATURE_ADC_CMP_ZC */
