/*************************************************************************
						Serial.h

Project		 	Controller		DJH MBFYS UMCN
--------------------------------------------------------------------------
Universal Asynchronous Receiver Transmitter 0 (UART0)
RS232 Interface using Philips LPC internal hardware 

LPC2119 user manual page 140-151
--------------------------------------------------------------------------
Versie 1.00		17-11-2005		Dick Heeren
**************************************************************************/

/**************************************************************************
U0RBR	Receiver Buffer Register
U0THR	Transmit Holding Register
U0IER	Interrupt Enable Register
U0IIR	Interrupt Identification Register
U0FCR	FIFO Control Register
U0LCR	Line Control Register
U0LSR	Line Status Register Bit
U0SCR	Scratch Pad Register
U0DLL	Divisor Latch LSB Register
U0DLM	Divisor Latch MSB Register
**************************************************************************/
#include "../include/global.h"

void UART0_irq(void) __irq;

extern void UART0_Init(void);
extern void UART0_SetBaud(unsigned int rate);
extern unsigned short UART0_RxNumber(void);
extern unsigned short UART0_TxEmpty(void);
extern int UART0_Get(void);
extern int UART0_Put(char data);
extern int UART0_Str(char data[128],int n);
extern void UART0_Test(int n);
