/**
 * @file hal_spi.c
 * @brief SPI2 master driver for the GarudaESE board — ATA6847 link.
 *
 * GarudaESE routes the gate-driver SPI to the **SPI2-native pins**
 * (schematic-verified): SCK2=RB10(31), SDI2=RB11(32), SDO2=RC9(34),
 * nCS=RC8(33, GPIO), nIRQ=RC6(35, GPIO). PPS is set in port_config.c.
 *
 * Ported from the garuda-ak-ata-esc SPI1 driver — only the peripheral
 * instance (SPI1->SPI2) and chip-select macros changed. The SPI **mode**
 * is unchanged and hard-won:
 *   16-bit, master, CKP=0 (idle low), CKE=0, SMP=1 (sample end), ENHBUF.
 *   CKP=1/CKE=1 phase-shifted the word so DSR1 read back 0x21 not 0x05.
 *
 * BRG=14 at the SPI peripheral clock -> ~3.33 MHz (ATA6847 max 10 MHz).
 * Drop BRG toward 4 (->10 MHz) once signal integrity is verified.
 *
 * nCS is managed by the caller via ATA_nCS_Enable/Disable (port_config.h).
 */

#include <xc.h>
#include "hal_spi.h"
#include "port_config.h"

void HAL_SPI_Init(void)
{
    SPI2CON2 = 0x00000000;
    SPI2STAT = 0x00000000;
    SPI2BRG  = 14;                 /* ~3.33 MHz */
    SPI2IMSK = 0x00000000;
    SPI2URDT = 0x00000000;

    SPI2CON1bits.MODE16 = 1;       /* 16-bit transfer */
    SPI2CON1bits.MSTEN  = 1;       /* host (master) */
    SPI2CON1bits.CKP    = 0;       /* clock idle LOW (ATA6847) */
    SPI2CON1bits.CKE    = 0;       /* output on idle->active edge */
    SPI2CON1bits.SMP    = 1;       /* sample at end */
    SPI2CON1bits.ENHBUF = 1;       /* enhanced (FIFO) buffer */
    SPI2CON1bits.ON     = 1;
}

uint16_t HAL_SPI_Exchange16(uint16_t data)
{
    volatile uint16_t timeout;

    timeout = 10000;
    while (SPI2STATbits.SPITBF && --timeout);
    if (!timeout) return 0xFFFF;

    ATA_nCS_Enable();
    SPI2BUF = data;

    timeout = 10000;
    while (SPI2STATbits.SPIRBE && --timeout);
    ATA_nCS_Disable();

    if (!timeout) return 0xFFFF;
    return (uint16_t)SPI2BUF;
}
