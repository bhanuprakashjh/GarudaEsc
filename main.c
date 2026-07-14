/**
 * @file main.c
 *
 * @brief Project Garuda ESC firmware entry point.
 *
 * Initialization sequence:
 *   1. InitOscillator() — 200MHz system clock, 400MHz PWM, 100MHz ADC
 *   2. SetupGPIOPorts() — PWM, BEMF, LED, button, UART, DShot pins
 *   3. HAL_InitPeripherals() — ADC, PWM, Timer1
 *   4. (GSP) GSP_ParamsInitDefaults + LoadFromConfig + RecomputeDerived
 *   5. GARUDA_ServiceInit() — state machine data, enable ADC ISR
 *   6. Main loop — button polling, GSP intents, heartbeat, board service
 *
 * Component: MAIN
 */

#include <xc.h>
#include <stdint.h>
#include <stdbool.h>

#include "garuda_types.h"
#include "garuda_config.h"
#include "garuda_service.h"
#include "hal/clock.h"
#include "hal/port_config.h"
#include "hal/board_service.h"
#include "hal/hal_pwm.h"
#include "hal/hal_ata6847.h"
#include "hal/uart1.h"        /* boot banner: UART1_DataWrite/BufferFull inlines */   /* GarudaESE: nIRQ fault poll (HAL_ATA6847_ReadDiag, g_ataReady) */
#include "motor/startup.h"
#include "motor/commutation.h"
#if FEATURE_ADC_CMP_ZC
#include "motor/hwzc.h"
#endif

#if FEATURE_LEARN_MODULES
#include "learn/learn_service.h"
#endif

#include "x2cscope/diagnostics.h"
#if FEATURE_GSP
#include "gsp/gsp.h"
#include "gsp/gsp_params.h"
#endif
#if FEATURE_EEPROM_V2
#include "hal/eeprom.h"
#endif
#if FEATURE_COMMISSION
#include "learn/commission.h"
#endif
#if FEATURE_ADAPTATION
#include "learn/adaptation.h"
#endif
#if (FEATURE_RX_PWM || FEATURE_RX_DSHOT || FEATURE_RX_AUTO)
#include "input/rx_decode.h"
#include "hal/hal_input_capture.h"
#endif
#if FEATURE_BURST_SCOPE
#include "scope/scope_burst.h"
#endif

#define GSP_HEARTBEAT_TIMEOUT_MS 500


#if FEATURE_GSP
/* Bring-up boot banner: the board otherwise transmits NOTHING unsolicited
 * (GSP is request/response), which makes UART bring-up blind. Repeats every
 * ~2 s until the first CRC-valid GSP frame arrives (gspLinkSeen), then goes
 * silent forever so it never interleaves with a live GSP session. */
extern volatile bool gspLinkSeen;
static void GSP_BootBanner(void)
{
    static const char s_banner[] =
        "\r\nGarudaESE garuda-ese-pristine: GSP up on DEBUG UART\r\n";
    const char *pb;
    for (pb = s_banner; *pb != '\0'; ++pb) {
        while (UART1_StatusBufferFullTransmitGet()) { }
        UART1_DataWrite((uint8_t)*pb);
    }
}
#endif

/* BRING-UP: reset-cause captured at entry, exported via snapshot probe.
 * RCON bits (dsPIC33AK): POR/BOR/EXTR/SWR/WDTO/TRAPR/IOPUWR... — tells us
 * whether the silent mid-session reboot is a trap, WDT, or brownout. */
volatile uint32_t g_bootRcon;

int main(void)
{
    g_bootRcon = RCON;
    RCON = 0;              /* clear so the NEXT reset's cause is unambiguous */

    /* Initialize oscillator / PLL */
    InitOscillator();

    /* Configure GPIO pins */
    SetupGPIOPorts();

    /* Initialize all peripherals */
    HAL_InitPeripherals();

    /* Initialize board service (buttons, counters) */
    BoardServiceInit();

    /* GSP runtime params — BEFORE GARUDA_ServiceInit so RT_* reads are valid
     * from the first ISR tick. */
#if FEATURE_GSP
    GSP_ParamsInitDefaults();       /* compile-time defaults */
#if FEATURE_EEPROM_V2
#if FEATURE_PARAMS_FORCE_DEFAULTS
    /* Bring-up: code values always win — skip the EEPROM overlay entirely so
     * edits to profileDefaults[]/.h take effect on reflash without an NVM reset.
     * Save path still compiles; nothing is loaded. */
#else
    {
        EEPROM_IMAGE_T eepromImage;
        EEPROM_Init(&eepromImage);
        GARUDA_CONFIG_T cfg;
        EEPROM_LoadConfig(&cfg);
        GSP_ParamsLoadFromConfig(&cfg);  /* overlay persisted values */
    }
#endif
#endif
    GSP_RecomputeDerived();         /* precompute ISR values */
#endif

    /* Initialize ESC state machine and enable ADC interrupt */
    GARUDA_ServiceInit();

#if FEATURE_BURST_SCOPE
    Scope_Init();
#endif

    /* Initialize RX input capture (Phase H) */
#if (FEATURE_RX_PWM || FEATURE_RX_DSHOT || FEATURE_RX_AUTO)
    RX_Init();
#endif

    /* Initialize UART1-based diagnostics (mutually exclusive) */
#ifdef ENABLE_DIAGNOSTICS
    DiagnosticsInit();
#endif
#if FEATURE_GSP
    GSP_Init();
    /* Bring-up boot banner (2026-07-10): the board otherwise transmits NOTHING
     * unsolicited (GSP is request/response and HAL_UART_WriteString is a stub),
     * which makes UART bring-up blind. Emit one line at 115.2k right after the
     * UART is up so a bare serial terminal proves the whole TX path
     * (PPS -> pin -> adapter) on every power-up. Blocking, boot-time only. */
    GSP_BootBanner();
#endif

    /* Bring-up BUILD SIGNATURE (2026-07-10): five fast LED blinks at boot,
     * BEFORE the heartbeat starts. Lets the bench distinguish this firmware
     * from any older build with no UART needed — old builds go straight to
     * the heartbeat. Permanent build-signature blink. */
    {
        uint8_t i;
        for (i = 0; i < 10; i++) {          /* 5 on/off cycles */
            LED1 ^= 1;
            {   volatile uint32_t d;
                for (d = 0; d < 2000000UL; d++) { }   /* ~100 ms @200 MHz */
            }
        }
        LED1 = 0;
    }

    /* Main loop — all real work happens in ISRs */
    while (1)
    {
        /* --- CPU-load diagnostic (main-loop only, zero hot-ISR cost) ---
         * Count loop spins; once per second compare the spin rate to the
         * highest rate seen while the motor is NOT commutating (idle
         * baseline). load‰ = 1000·(1 - rate/baseline). Rises as ISR + GSP
         * work steals cycles from this loop. Relative to the motor-off
         * baseline, so it answers "how much bandwidth is running the motor
         * eating", not an absolute kernel %. */
        static uint32_t cpuSpins = 0, cpuLastSpins = 0, cpuLastTick = 0;
        static uint32_t cpuBaselineRate = 1;  /* spins/ms, !=0 to avoid div0 */
        cpuSpins++;
        {
            uint32_t nowTick = garudaData.systemTick;
            uint32_t dt = nowTick - cpuLastTick;
            if (dt >= 1000u)            /* ~1 s window */
            {
                uint32_t rate = (cpuSpins - cpuLastSpins) / dt;   /* spins/ms */
                if (garudaData.state <= ESC_ARMED && rate > cpuBaselineRate)
                    cpuBaselineRate = rate;   /* auto-calibrate idle baseline */
                if (rate >= cpuBaselineRate)
                    garudaData.cpuLoadPermille = 0;
                else
                    garudaData.cpuLoadPermille =
                        (uint16_t)(1000UL - (1000UL * rate) / cpuBaselineRate);
                cpuLastSpins = cpuSpins;
                cpuLastTick  = nowTick;
            }
        }

#ifdef ENABLE_DIAGNOSTICS
        DiagnosticsStepMain();  /* X2CScope serial communication */
#endif
#if FEATURE_GSP
        GSP_Service();
        /* Bring-up: repeat the banner every ~2 s until a valid GSP frame is
         * seen, so a plain terminal shows life without power-cycle timing. */
        {
            static uint32_t s_lastBanner = 0;
            if (!gspLinkSeen
                && (uint32_t)(garudaData.systemTick - s_lastBanner) >= 2000u) {
                s_lastBanner = garudaData.systemTick;
                GSP_BootBanner();
            }
        }
        /* Process detect intent immediately after GSP — minimize ISR window */
        if (garudaData.gspDetectIntent)
        {
            garudaData.gspDetectIntent = false;
            if (garudaData.state == ESC_IDLE)
            {
                garudaData.state = ESC_DETECT;
            }
        }
#endif

#if (FEATURE_RX_PWM || FEATURE_RX_DSHOT || FEATURE_RX_AUTO)
        RX_Service();

        /* Auto-arm from RX input: when RX link is locked and throttle is
         * zero, arm the motor.  The ESC_ARMED handler (Timer1 ISR or FOC
         * slow loop) verifies throttle stays at zero for ARM_TIME_MS
         * before transitioning to ALIGN — this is the safety gate.
         * Every real RC ESC auto-arms this way. */
        if (garudaData.state == ESC_IDLE
            /* GarudaESE: only auto-arm when an RX source is actually selected —
             * otherwise a stray locked RX link could arm during GSP bring-up. */
            && (garudaData.throttleSource == THROTTLE_SRC_AUTO
                || garudaData.throttleSource == THROTTLE_SRC_PWM
                || garudaData.throttleSource == THROTTLE_SRC_DSHOT)
            && garudaData.rxLinkState == RX_LINK_LOCKED
            && rxCachedLocked
            && rxCachedThrottleAdc == 0)
        {
            garudaData.runCommandActive = true;
            garudaData.desyncRestartAttempts = 0;
            garudaData.armCounter = 0;
            garudaData.state = ESC_ARMED;
        }
#endif

#if FEATURE_FOC || FEATURE_FOC_V2 || FEATURE_FOC_V3 || FEATURE_FOC_AN1078
        /* FOC LED2 state encoding:
         *   IDLE: OFF, ARMED: 5Hz blink, CLOSED_LOOP: solid ON, FAULT: fast blink */
        {
            static uint16_t focLedCtr = 0;
            ESC_STATE_T st = garudaData.state;
            if (st == ESC_ARMED) {
                /* 5 Hz blink using systemTick (1ms) — toggle every 100ms */
                if (++focLedCtr >= 100) {
                    focLedCtr = 0;
                    LED2 ^= 1;
                }
            } else if (st == ESC_FAULT) {
                /* Fast blink (~10 Hz) */
                if (++focLedCtr >= 50) {
                    focLedCtr = 0;
                    LED2 ^= 1;
                }
            } else {
                focLedCtr = 0;
                /* CLOSED_LOOP: LED2 set by ADC ISR slow loop
                 * IDLE: LED2 cleared by stop handler */
            }
        }
#endif

        /* Board service — button debounce at 1ms rate */
        BoardService();

        /* GarudaESE: poll the ATA6847 fault line. nIRQ (RC6) is active-LOW; the
         * dsPIC has no fault-PCI on this MCU, so without this poll the firmware
         * never learns of an ATA self-protection event (UV/OT/VDS short). ILIM
         * chop is masked from nIRQ, so an assertion here is a real latched fault
         * → kill the bridge and latch ESC_FAULT. Capture the diag for debug. */
        if (garudaData.state >= ESC_ALIGN && garudaData.state <= ESC_CLOSED_LOOP
            && ATA_nIRQ_GetValue() == 0)
        {
            HAL_MC1PWMDisableOutputs();
            HAL_ATA6847_ReadDiag(g_ataDiag);        /* snapshot the fault cause */
            garudaData.state = ESC_FAULT;
            garudaData.faultCode = FAULT_BOARD_PCI; /* gate-driver-reported fault */
            garudaData.runCommandActive = false;
            LED2 = 0;
        }

#if FEATURE_ARM_SWITCH
        /* Dedicated hardware ARM toggle on RD4 (J1/TELE_RX), active-low
         * (closed→GND = armed). Edge-triggered + debounced via systemTick so it
         * COMPOSES with the GUI/GSP arm: closing arms (if idle), opening kills
         * the bridge. Acts only on its own transitions — an unfitted/open switch
         * (held high by the pull-up) never interferes with GUI control. The
         * initial level is latched without action, so a switch left closed at
         * power-up does NOT auto-arm. */
        {
            static bool s_armStable = false, s_armCand = false, s_armInit = false;
            static uint32_t s_armCandSince = 0;
            bool armRaw = (ARM_SWITCH_GetValue() == 0);   /* closed = low = armed */
            uint32_t nowMs = garudaData.systemTick;
            if (armRaw != s_armCand) { s_armCand = armRaw; s_armCandSince = nowMs; }
            if (!s_armInit) { s_armStable = s_armCand; s_armInit = true; }
            else if (s_armCand != s_armStable
                     && (uint32_t)(nowMs - s_armCandSince) >= ARM_SWITCH_DEBOUNCE_MS)
            {
                s_armStable = s_armCand;
                if (s_armStable)
                {
                    /* open→closed: ARM (only from IDLE; ESC_ARMED then waits for
                     * throttle=0 before ALIGN, same gate as every other path). */
                    if (garudaData.state == ESC_IDLE)
                    {
                        garudaData.runCommandActive = true;
                        garudaData.desyncRestartAttempts = 0;
                        garudaData.armCounter = 0;
                        garudaData.state = ESC_ARMED;
                    }
                }
                else
                {
                    /* closed→open: KILL — disarm + drop the bridge immediately. */
                    if (garudaData.state != ESC_IDLE && garudaData.state != ESC_FAULT)
                    {
                        HAL_MC1PWMDisableOutputs();
                        garudaData.state = ESC_IDLE;
                        garudaData.runCommandActive = false;
                        garudaData.desyncRestartAttempts = 0;
                        LED2 = 0;
                    }
                }
            }
        }
#endif /* FEATURE_ARM_SWITCH */

        /* Button 1 (SW1) — Start/Stop motor */
        if (IsPressed_Button1())
        {
            if (garudaData.state == ESC_IDLE)
            {
                /* Enter arming — Timer1 ESC_ARMED handler verifies throttle=0
                 * for ARM_TIME_MS, then transitions to ESC_ALIGN.
                 * Init before state change: Timer1 ISR (prio 5) can
                 * preempt main between writes. */
                garudaData.runCommandActive = true;
                garudaData.desyncRestartAttempts = 0;
                garudaData.armCounter = 0;
                garudaData.state = ESC_ARMED;
#if FEATURE_ADAPTATION
                if (ADAPT_IsSafeBoundary(ESC_ARMED, garudaData.throttle))
                {
                    /* Adaptation params already evaluated; applied here */
                }
#endif
            }
            else if (garudaData.state == ESC_FAULT)
            {
                /* Clear fault and return to idle.
                 * State first: ADC ISR (prio 6) sees IDLE immediately,
                 * skips CL case, so HWZC_Disable's fallbackPending=true
                 * is never consumed by the fallback re-seed path. */
                garudaData.state = ESC_IDLE;
                garudaData.runCommandActive = false;
                garudaData.desyncRestartAttempts = 0;
                garudaData.faultCode = FAULT_NONE;
#if FEATURE_ADC_CMP_ZC
                if (garudaData.hwzc.enabled)
                    HWZC_Disable(&garudaData);
                garudaData.hwzc.fallbackPending = false;
#endif
                HAL_MC1ClearPWMPCIFault();
                HAL_MC1PWMDisableOutputs();
                LED2 = 0;
            }
            else
            {
                /* Stop motor (any running state including ESC_RECOVERY).
                 * State first: same preemption safety as fault-clear. */
                garudaData.state = ESC_IDLE;
                garudaData.runCommandActive = false;
                garudaData.desyncRestartAttempts = 0;
#if FEATURE_ADC_CMP_ZC
                if (garudaData.hwzc.enabled)
                    HWZC_Disable(&garudaData);
                garudaData.hwzc.fallbackPending = false;
#endif
                HAL_MC1PWMDisableOutputs();
                LED2 = 0;
            }
        }

#if DIAGNOSTIC_MANUAL_STEP
        /* DIAGNOSTIC: SW2 manually advances one commutation step.
         * Only active when motor is running (ALIGN/OL_RAMP/CLOSED_LOOP). */
        if (IsPressed_Button2())
        {
            if (garudaData.state == ESC_OL_RAMP ||
                garudaData.state == ESC_CLOSED_LOOP)
            {
                COMMUTATION_AdvanceStep(&garudaData);
                HAL_PWM_SetDutyCycle(garudaData.duty);
                LED2 ^= 1;  /* Toggle LED2 as visual step indicator */
            }
        }
#else
        /* Button 2 (SW2) — Change direction (IDLE only — safe) */
        if (IsPressed_Button2())
        {
            if (garudaData.state == ESC_IDLE)
            {
                garudaData.direction ^= 1;
            }
        }
#endif

#if FEATURE_GSP
        /* GSP intent flags — process in main loop (not ISR).
         * Same logic as SW1 button but triggered by GSP commands. */
        if (garudaData.gspStartIntent)
        {
            garudaData.gspStartIntent = false;
            if (garudaData.state == ESC_IDLE)
            {
                garudaData.runCommandActive = true;
                garudaData.desyncRestartAttempts = 0;
                garudaData.armCounter = 0;
                garudaData.state = ESC_ARMED;
            }
        }
        if (garudaData.gspStopIntent)
        {
            garudaData.gspStopIntent = false;
            /* Stop must reach a safe IDLE from ANY state. Previously this
             * excluded ESC_FAULT, so after a fault the GUI Stop button did
             * nothing (only Start recovered, since it clears-then-arms) —
             * bench-reported 2026-07-13. Treat Stop as "kill + reset": if
             * latched in fault, clear it to IDLE; otherwise stop a run. */
            if (garudaData.state == ESC_FAULT)
            {
                garudaData.state = ESC_IDLE;
                garudaData.runCommandActive = false;
                garudaData.desyncRestartAttempts = 0;
                garudaData.faultCode = FAULT_NONE;
#if FEATURE_ADC_CMP_ZC
                if (garudaData.hwzc.enabled)
                    HWZC_Disable(&garudaData);
                garudaData.hwzc.fallbackPending = false;
#endif
                HAL_MC1ClearPWMPCIFault();
                HAL_MC1PWMDisableOutputs();
                LED2 = 0;
            }
            else if (garudaData.state != ESC_IDLE)
            {
                garudaData.state = ESC_IDLE;
                garudaData.runCommandActive = false;
                garudaData.desyncRestartAttempts = 0;
#if FEATURE_ADC_CMP_ZC
                if (garudaData.hwzc.enabled)
                    HWZC_Disable(&garudaData);
                garudaData.hwzc.fallbackPending = false;
#endif
                HAL_MC1PWMDisableOutputs();
                LED2 = 0;
            }
        }
        if (garudaData.gspFaultClearIntent)
        {
            garudaData.gspFaultClearIntent = false;
            if (garudaData.state == ESC_FAULT)
            {
                garudaData.state = ESC_IDLE;
                garudaData.runCommandActive = false;
                garudaData.desyncRestartAttempts = 0;
                garudaData.faultCode = FAULT_NONE;
#if FEATURE_ADC_CMP_ZC
                if (garudaData.hwzc.enabled)
                    HWZC_Disable(&garudaData);
                garudaData.hwzc.fallbackPending = false;
#endif
                HAL_MC1ClearPWMPCIFault();
                HAL_MC1PWMDisableOutputs();
                LED2 = 0;
            }
        }

        /* Heartbeat watchdog — only when GSP throttle + motor active */
        if (garudaData.throttleSource == THROTTLE_SRC_GSP
            && garudaData.runCommandActive)
        {
            uint32_t elapsed = garudaData.systemTick - garudaData.lastGspPacketTick;
            if (elapsed > GSP_HEARTBEAT_TIMEOUT_MS)
            {
                /* Lost connection — safe stop via zero throttle + stop intent.
                 * Do NOT switch throttleSource (Finding 43): with FEATURE_ADC_POT=0,
                 * ADC source is invalid. Motor stops via zero throttle + gspStopIntent. */
                garudaData.gspThrottle = 0;
                garudaData.gspStopIntent = true;
            }
        }
#endif /* FEATURE_GSP */

#if FEATURE_LEARN_MODULES
        /* Learning modules dispatcher (quality/health/adaptation) */
        LEARN_Service(&garudaData, garudaData.systemTick);
#endif

#if FEATURE_COMMISSION
        /* Self-commissioning state machine (when active) */
        if (garudaData.commission.state > COMM_IDLE &&
            garudaData.commission.state < COMM_COMPLETE)
        {
            COMMISSION_Update(&garudaData.commission, &garudaData,
                              &telemRing, garudaData.systemTick);
        }
#endif
    }

    return 0;
}
