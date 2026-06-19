/**
 * @file hal_uart.h
 * @brief No-op UART debug stubs for GarudaESE.
 *
 * The real UART (GSP) is the 512 tree's uart1.c on UART1. The grafted
 * ATA6847 driver emits optional bring-up debug via HAL_UART_*; on GarudaESE
 * those are stubbed out so there is no second UART1 driver. To get ATA
 * bring-up chatter, route these to uart1.c TX instead.
 */
#ifndef HAL_UART_H
#define HAL_UART_H
#include <stdint.h>
static inline void HAL_UART_WriteString(const char *s) { (void)s; }
static inline void HAL_UART_WriteHex8(uint8_t v)       { (void)v; }
static inline void HAL_UART_WriteByte(char c)          { (void)c; }
static inline void HAL_UART_NewLine(void)              { }
#endif
