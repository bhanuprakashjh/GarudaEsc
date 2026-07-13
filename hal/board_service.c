/**
 * @file board_service.c
 *
 * @brief Board service routines — button scanning, peripheral initialization,
 * PWM output enable/disable, heartbeat, trap handler.
 * Adapted from AN1292 reference for Project Garuda ESC.
 *   - Removes: Op-amp init, FOC-specific duty cycle functions,
 *              motor input read (MCAPP_MEASURE_T)
 *   - Keeps: Button debounce, Timer1 setup, PWM enable/disable
 *   - Changes: Init sequence calls our new HAL functions
 *
 * Component: BOARD SERVICE
 */

#include <xc.h>
#include <stdint.h>
#include <stdbool.h>

#include "board_service.h"
#include "../garuda_config.h"
#include "../garuda_types.h"    /* GARUDA_DATA_T, FAULT_TRAP_* for trap handlers */
/* GarudaESE: SPI2 + ATA6847 + phase op-amp bring-up are CORE to this board
 * (HAL_InitPeripherals calls them unconditionally), so these includes must be
 * unconditional — not gated behind FEATURE_HW_OVERCURRENT/FOC like the 512
 * tree did. Without this, HAL_SPI_Init/HAL_ATA6847_* compiled with implicit
 * (int) prototypes — wrong on a 16-bit target. */
#include "port_config.h"      /* HAL_OA12_Init (phase op-amps), HAL_OA3_Init (HW_OC) */
#include "hal_spi.h"          /* SPI2 to ATA6847 */
#include "hal_ata6847.h"      /* SPI-gated gate driver */
#if FEATURE_HW_OVERCURRENT
#include "hal_comparator.h"
#endif

BUTTON_T buttonStartStop;
BUTTON_T buttonDirectionChange;

uint16_t boardServiceISRCounter = 0;

/* GarudaESE: ATA6847 gate-driver readiness. Set from HAL_ATA6847_EnterGduNormal()
 * in HAL_InitPeripherals — the state machine refuses to drive (ARM→ALIGN) unless
 * this is true, so a failed SPI/GDU handshake can never drive PWM into a
 * non-Normal driver. g_ataDiag holds the last nIRQ-fault diagnostic snapshot. */
volatile bool g_ataReady = false;
uint8_t       g_ataDiag[8] = {0};

static void ButtonGroupInitialize(void);
static void ButtonScan(BUTTON_T *, bool);

/**
 * @brief Check if start/stop button was pressed.
 */
bool IsPressed_Button1(void)
{
    if (buttonStartStop.status)
    {
        buttonStartStop.status = false;
        return true;
    }
    return false;
}

/**
 * @brief Check if direction change button was pressed.
 */
bool IsPressed_Button2(void)
{
    if (buttonDirectionChange.status)
    {
        buttonDirectionChange.status = false;
        return true;
    }
    return false;
}

/**
 * @brief Increment board service counter (called from Timer1 ISR).
 */
void BoardServiceStepIsr(void)
{
    if (boardServiceISRCounter < BOARD_SERVICE_TICK_COUNT)
    {
        boardServiceISRCounter += 1;
    }
}

/**
 * @brief Board service tick — scans buttons at 1ms rate.
 */
void BoardService(void)
{
    if (boardServiceISRCounter == BOARD_SERVICE_TICK_COUNT)
    {
        ButtonScan(&buttonStartStop, BUTTON_START_STOP);
        ButtonScan(&buttonDirectionChange, BUTTON_DIRECTION_CHANGE);
        boardServiceISRCounter = 0;
    }
}

/**
 * @brief Initialize board service state.
 */
void BoardServiceInit(void)
{
    ButtonGroupInitialize();
    boardServiceISRCounter = BOARD_SERVICE_TICK_COUNT;
}

/**
 * @brief Scan a button with debounce logic.
 */
static void ButtonScan(BUTTON_T *pButton, bool button)
{
    if (button == true)
    {
        if (pButton->debounceCount < BUTTON_DEBOUNCE_COUNT)
        {
            pButton->debounceCount++;
            pButton->state = BUTTON_DEBOUNCE;
        }
    }
    else
    {
        if (pButton->debounceCount < BUTTON_DEBOUNCE_COUNT)
        {
            pButton->state = BUTTON_NOT_PRESSED;
        }
        else
        {
            pButton->state = BUTTON_PRESSED;
            pButton->status = true;
        }
        pButton->debounceCount = 0;
    }
}

/**
 * @brief Initialize button group state.
 */
static void ButtonGroupInitialize(void)
{
    buttonStartStop.state = BUTTON_NOT_PRESSED;
    buttonStartStop.debounceCount = 0;
    buttonStartStop.status = false;

    buttonDirectionChange.state = BUTTON_NOT_PRESSED;
    buttonDirectionChange.debounceCount = 0;
    buttonDirectionChange.status = false;
}

/**
 * @brief Initialize all peripherals (ADC, PWM, Timer1).
 * When FEATURE_HW_OVERCURRENT: OA3→CMP3→CLPCI armed BEFORE PWM outputs exist.
 */
void HAL_InitPeripherals(void)
{
    /* GarudaESE: bring up the SPI2 link + ATA6847 gate driver FIRST.
     * Gates are SPI-gated — nothing switches until DOPM/GDU are set. */
    HAL_SPI_Init();
    HAL_ATA6847_Init();             /* config regs (incl. GDUCR1.BEMFEN=1 for ZC); GDU still OFF */

    HAL_OA12_Init();                /* OA1=Iu, OA2=Iv phase-current op-amps (dsPIC).
                                     * Iw = -(Iu+Iv). ATA op-amps are BEMF comparators,
                                     * so there is NO ATA current sense in this build. */
#if FEATURE_HW_OVERCURRENT
    HAL_OA3_Init();                 /* 1. Op-amp on (~10us settling) */
    InitializeCMPs();               /* 2. CMP3 + DAC3 threshold configured */
    HAL_CMP3_EnableOvercurrent();   /* 3. CMP3 enabled — analog protection armed */
#endif

    InitializeADCs();

    /* Make sure ADC does not generate interrupt while initializing */
    GARUDA_DisableADCInterrupt();

    InitPWMGenerators();

    /* Enable PWM fault interrupt (only when FPCI is configured) */
#ifdef ENABLE_PWM_FAULT_PCI
    ClearPWMIF();
    EnablePWMIF();
#endif

    /* Timer1 initialization — 100us tick */
    TIMER1_Initialize();
    TIMER1_InputClockSet();
    TIMER1_PeriodSet(TIMER1_PERIOD_COUNT);
    TIMER1_InterruptPrioritySet(5);
    TIMER1_InterruptFlagClear();
    TIMER1_InterruptEnable();
    TIMER1_ModuleStart();

    /* GarudaESE: PWM generators now drive overridden-LOW (safe). Power the
     * ATA6847 gate-drive unit to Normal so the gates respond once the state
     * machine removes the overrides. (Kept Normal for the session; the PWM
     * OVRENx overrides gate the actual switching. A full safe-stop/fault may
     * call HAL_ATA6847_EnterGduStandby() — see hal_ata6847.h.) */
    HAL_ATA6847_ClearFaults();
    /* Gate driving on GDU success: HAL_ATA6847_EnterGduNormal() verifies the
     * SPI handshake + GDU-status poll. If it fails, g_ataReady stays false and
     * the ARM→ALIGN transition is blocked (faults instead of driving). */
    g_ataReady = HAL_ATA6847_EnterGduNormal();
}

/**
 * @brief Reset peripherals — clear ADC interrupt, disable PWM outputs.
 */
void HAL_ResetPeripherals(void)
{
    GARUDA_ClearADCIF();
    GARUDA_EnableADCInterrupt();
    HAL_MC1PWMDisableOutputs();
}

/**
 * @brief Enable PWM outputs — remove overrides, PWM generators drive pins.
 */
void HAL_MC1PWMEnableOutputs(void)
{
    PWM_PDC3 = 0;
    PWM_PDC2 = 0;
    PWM_PDC1 = 0;

    PG3IOCON2bits.OVRENH = 0;
    PG3IOCON2bits.OVRENL = 0;
    PG2IOCON2bits.OVRENH = 0;
    PG2IOCON2bits.OVRENL = 0;
    PG1IOCON2bits.OVRENH = 0;
    PG1IOCON2bits.OVRENL = 0;
}

/**
 * @brief Disable PWM outputs — override all to LOW.
 */
void HAL_MC1PWMDisableOutputs(void)
{
#if FEATURE_CL_DIFF_IDLE
    /* Any output kill exits differential-low CL mode, so the next drive
     * (align/ramp/restart) gets conventional waveforms. */
    extern volatile uint8_t g_pwmDiffLow;
    g_pwmDiffLow = 0;
#endif
    PWM_PDC3 = 0;
    PWM_PDC2 = 0;
    PWM_PDC1 = 0;

    PG3IOCON2bits.OVRDAT = 0;
    PG2IOCON2bits.OVRDAT = 0;
    PG1IOCON2bits.OVRDAT = 0;

    PG3IOCON2bits.OVRENH = 1;
    PG3IOCON2bits.OVRENL = 1;
    PG2IOCON2bits.OVRENH = 1;
    PG2IOCON2bits.OVRENL = 1;
    PG1IOCON2bits.OVRENH = 1;
    PG1IOCON2bits.OVRENL = 1;
}

/**
 * @brief Clear PWM PCI fault via software termination.
 */
void HAL_MC1ClearPWMPCIFault(void)
{
    PG1SPCI1bits.SWTERM = 1;
    PG2SPCI1bits.SWTERM = 1;
    PG3SPCI1bits.SWTERM = 1;
}

/**
 * @brief Trap handler — disables all outputs, sets fault code, blinks LED2.
 * Blink pattern encodes trap type: N fast blinks then pause.
 * Read garudaData.faultCode via GSP to identify the exact trap.
 */
void HAL_TrapHandler(void)
{
    HAL_MC1PWMDisableOutputs();

    /* Set ESC state to FAULT — visible via GSP GET_STATUS */
    extern volatile GARUDA_DATA_T garudaData;
    garudaData.state = ESC_FAULT;
    garudaData.runCommandActive = false;

    /* Blink LED2 with trap-specific pattern:
     * FAULT_TRAP_BUS(12)→2 blinks, ILLEGAL(13)→3, ADDRESS(14)→4,
     * STACK(15)→5, MATH(16)→6, GENERAL(17)→7, DEFAULT(18)→8 */
    uint8_t blinks = (uint8_t)(garudaData.faultCode - FAULT_TRAP_BUS + 2);
    if (blinks < 2 || blinks > 10) blinks = 1;  /* safety fallback */

    while (1)
    {
        /* N fast blinks */
        for (uint8_t i = 0; i < blinks; i++)
        {
            LED2 = 1;
            for (volatile uint32_t d = 0; d < 200000UL; d++) Nop();
            LED2 = 0;
            for (volatile uint32_t d = 0; d < 200000UL; d++) Nop();
        }
        /* Long pause between groups */
        for (volatile uint32_t d = 0; d < 1200000UL; d++) Nop();
    }
}

/* ── CPU Trap Handlers (dsPIC33AK) ────────────────────────────────────
 * Without these, any CPU trap resets the processor — appearing as a
 * mysterious "board hard fault" with no diagnostic information.
 * Each handler sets a unique fault code, disables outputs, and blinks
 * LED2 with a count pattern: 2 blinks=bus, 3=illegal, 4=address,
 * 5=stack, 6=math, 7=general, 8=unhandled interrupt.
 * Read faultCode via GSP GET_STATUS for exact identification.
 * ──────────────────────────────────────────────────────────────────── */

void __attribute__((__interrupt__, no_auto_psv)) _BusErrorTrap(void)
{
    extern volatile GARUDA_DATA_T garudaData;
    garudaData.faultCode = FAULT_TRAP_BUS;
    HAL_TrapHandler();
}

void __attribute__((__interrupt__, no_auto_psv)) _IllegalInstructionTrap(void)
{
    extern volatile GARUDA_DATA_T garudaData;
    garudaData.faultCode = FAULT_TRAP_ILLEGAL;
    HAL_TrapHandler();
}

void __attribute__((__interrupt__, no_auto_psv)) _AddressErrorTrap(void)
{
    INTCON1bits.ADDRERR = 0;
    extern volatile GARUDA_DATA_T garudaData;
    garudaData.faultCode = FAULT_TRAP_ADDRESS;
    HAL_TrapHandler();
}

void __attribute__((__interrupt__, no_auto_psv)) _StackErrorTrap(void)
{
    INTCON1bits.STKERR = 0;
    extern volatile GARUDA_DATA_T garudaData;
    garudaData.faultCode = FAULT_TRAP_STACK;
    HAL_TrapHandler();
}

void __attribute__((__interrupt__, no_auto_psv)) _MathErrorTrap(void)
{
    extern volatile GARUDA_DATA_T garudaData;
    garudaData.faultCode = FAULT_TRAP_MATH;
    HAL_TrapHandler();
}

void __attribute__((__interrupt__, no_auto_psv)) _GeneralTrap(void)
{
    extern volatile GARUDA_DATA_T garudaData;
    garudaData.faultCode = FAULT_TRAP_GENERAL;
    HAL_TrapHandler();
}

void __attribute__((__interrupt__, no_auto_psv)) _DefaultInterrupt(void)
{
    extern volatile GARUDA_DATA_T garudaData;
    garudaData.faultCode = FAULT_TRAP_DEFAULT;
    HAL_TrapHandler();
}
