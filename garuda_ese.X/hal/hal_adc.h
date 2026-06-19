/**
 * @file hal_adc.h
 *
 * @brief ADC module definitions for phase voltage sensing, Vbus, and potentiometer.
 * Adapted from AN1292 reference:
 *   - Keeps: Vbus (AD1CH4), Pot (AD1CH1), PWM trigger source
 *   - Removes: Current sense channels (IA, IB, IBUS)
 *   - Adds: Phase B on AD1CH0 (RB8), Phase A/C on AD2CH0 (RB9/RA10, muxed)
 *
 * Definitions in this file are for dsPIC33AK128MC106
 *
 * Component: ADC
 */

#ifndef _HAL_ADC_H
#define _HAL_ADC_H

#include <xc.h>
#include <stdint.h>
#include <stdbool.h>
#include "../garuda_config.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Maximum count in 12-bit ADC */
#define MAX_ADC_COUNT       4096.0f
#define HALF_ADC_COUNT      2048

/* ===================================================================
 * GarudaESE / EV60Y51A ADC buffer map — dedicated channels, NO mux.
 *
 * The 3 BEMF phases sit on three different ADC cores (the board pins
 * dictate the core), so they are sampled SIMULTANEOUSLY every PG1TRIGA
 * trigger — no Phase-A/C mux, no settle penalty (unlike the MCLV base).
 *
 *   core.chan   signal            pin   ADCxANn
 *   AD1 CH0     Iu  (OA1OUT)      RA2   AD1AN0
 *   AD2 CH0     Iv  (OA2OUT)      RB0   AD2AN0
 *   AD2 CH1     BEMF_V (divider)  RB8   AD2AN4  (PINSEL 4)
 *   AD3 CH0     BEMF_U (divider)  RB5   AD3AN1  (PINSEL 1)
 *   AD3 CH1     TEMP  (NTC)       RA0   AD3AN5  (PINSEL 5)
 *   AD3 CH2     Speed (pot/rsvd)  RA6   AD3AN2  (PINSEL 2)
 *   AD5 CH0     BEMF_W (divider)  RA1   AD5AN1  (PINSEL 1)
 *   AD5 CH1     BEMF_N (neutral)  RA11  AD5AN2  (PINSEL 2)
 *   AD5 CH2     VBUS              RA7   AD5AN0  (PINSEL 0)
 *
 * Iw = -(Iu+Iv). Bus current is NOT sensed (ATA op-amps are BEMF
 * comparators). ATA_BEMF_U/V/W (digital ZC) are read as GPIO, not ADC.
 * ===================================================================*/

/* Phase-current op-amp outputs (also the 6-step monitor channels) */
#define ADCBUF_IA           (uint16_t)AD1CH0DATA   /* Iu */
#define ADCBUF_IB           (uint16_t)AD2CH0DATA   /* Iv */
#define ADCBUF_IA_MON       (uint16_t)AD1CH0DATA
#define ADCBUF_IB_MON       (uint16_t)AD2CH0DATA

/* Dedicated BEMF channels (divider analog ZC: options Z2/Z3) */
#define ADCBUF_BEMF_U       (uint16_t)AD3CH0DATA
#define ADCBUF_BEMF_V       (uint16_t)AD2CH1DATA
#define ADCBUF_BEMF_W       (uint16_t)AD5CH0DATA
#define ADCBUF_BEMF_N       (uint16_t)AD5CH1DATA

#define ADCBUF_VBUS         (uint16_t)AD5CH2DATA
#define ADCBUF_POT          (uint16_t)AD3CH2DATA   /* Speed (reserved/unrouted) */
#define ADCBUF_TEMP         (uint16_t)AD3CH1DATA

/* Phase B completion (AD1CH0) is the ADC interrupt source */
#define GARUDA_EnableADCInterrupt()     _AD1CH0IE = 1
#define GARUDA_DisableADCInterrupt()    _AD1CH0IE = 0
#define GARUDA_ADC_INTERRUPT            _AD1CH0Interrupt
#define GARUDA_ClearADCIF()             _AD1CH0IF = 0

/* Floating phase identifiers for BEMF mux selection */
#define FLOATING_PHASE_A    0
#define FLOATING_PHASE_B    1
#define FLOATING_PHASE_C    2

void InitializeADCs(void);

/* GarudaESE: BEMF phases are on dedicated channels (no shared mux), so the
 * per-commutation channel-select is a no-op. Kept because commutation.c
 * references the symbol. The floating phase is selected at the data-read
 * site in the ADC ISR (garuda_service.c) by reading the right ADCBUF_BEMF_*. */
static inline bool HAL_ADC_SelectBEMFChannel(uint8_t floatingPhase)
{ (void)floatingPhase; return false; }

#if FEATURE_ADC_CMP_ZC
void HAL_ADC_InitHighSpeedBEMF(void);
void HAL_ADC_ConfigComparator(uint8_t adcCore, uint16_t threshold, bool risingZc);
void HAL_ADC_EnableComparatorIE(uint8_t adcCore);
void HAL_ADC_DisableComparatorIE(uint8_t adcCore);
void HAL_ADC_ClearComparatorFlag(uint8_t adcCore);
void HAL_ADC_SetHighSpeedPinsel(uint8_t pinsel);
/* Live CMPLO update (no CMPMOD change) — safe to call from ADC ISR
 * while the comparator is armed. Atomic SFR write. Takes effect on
 * the next ADC conversion (~1 µs at SCCP3 1 MHz, or ~4 µs at 4×
 * oversample). */
void HAL_ADC_UpdateComparatorThreshold(uint8_t adcCore, uint16_t threshold);
#endif

#ifdef __cplusplus
}
#endif

#endif /* _HAL_ADC_H */
