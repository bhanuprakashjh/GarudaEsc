/**
 * @file port_config.h
 *
 * @brief GPIO pin definitions + interface for the **GarudaESE / EV60Y51A** board.
 *
 * Target: dsPIC33AK256MC506-E/M7 (64-VQFN) + ATA6847T-5033 gate driver.
 * Pin map is schematic-verified — see `garuda_board.h` and the
 * `GarudaESE_PinMap` reference for the full table and confirmation status.
 *
 * Ported from the AK512 `dspic33AKESC` 6-step tree; board layer rewritten
 * for GarudaESE. Function/macro names are preserved so the rest of the
 * tree (board_service, garuda_service, hal_*) links unchanged.
 */

#ifndef _PORTCONFIG_H
#define _PORTCONFIG_H

#include <xc.h>
#include "../garuda_config.h"
#include "garuda_board.h"

#ifdef __cplusplus
extern "C" {
#endif

/* ── Control inputs ───────────────────────────────────────────────
 * GarudaESE has NO on-board buttons. The bench ARM switch is a digital
 * GPIO on the DShot pin (RD5/J1.7, internal pull-up, switch→GND).
 * There is no direction button — direction is fixed / GSP-controlled,
 * so SW2 aliases SW1 to keep board_service code compiling. */
#define SW1                     PORTDbits.RD5     /* ARM switch (J1.7) */
#define SW2                     PORTDbits.RD5     /* no direction btn — alias */
#define BUTTON_START_STOP       SW1
#define BUTTON_DIRECTION_CHANGE SW2

/* ── Status LED (D4 orange, RC0/pin39) ────────────────────────────
 * Single LED on GarudaESE; LED2 aliases LED1 so existing code links. */
#define LED1                    LATCbits.LATC0
#define LED2                    LATCbits.LATC0

/* ── ATA6847 nCS (SPI2 chip-select, GPIO RC8) ─────────────────────── */
#define ATA_nCS                 LATCbits.LATC8
#define ATA_nCS_Enable()        (ATA_nCS = 0)
#define ATA_nCS_Disable()       (ATA_nCS = 1)
/* ATA6847 nIRQ (GPIO in, RC6) */
#define ATA_nIRQ_GetValue()     (PORTCbits.RC6)

void SetupGPIOPorts(void);
void MapGPIOHWFunction(void);

void HAL_OA12_Init(void);          /* U/V phase-current internal op-amps (OA1/OA2) */

#if FEATURE_HW_OVERCURRENT
void HAL_OA3_Init(void);           /* NOT used on GarudaESE (bus I via ATA CSA) */
#endif

#ifdef __cplusplus
}
#endif

#endif /* _PORTCONFIG_H */
