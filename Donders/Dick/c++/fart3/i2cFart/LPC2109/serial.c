/*************************************************************************
						Serial.c

Project		 	Controller		DJH MBFYS UMCN
----------------------------------------------
Versie 1.00		17-11-2005		Dick Heeren
**************************************************************************/

/*
	Serial receive (Rx) and transmit (Tx) data.
	Default settings: 8 bits, no parity, 1 stop bit and baudrate = 9600
	  
	The length of the receive and transmit buffer must be a power of 2.
	Each buffer has a next_in and a next_out index.
	(next_in - next_out) = the number of characters in the buffer.
	If next_in = next_out, the buffer is empty.
	If next_in = next_out, then next_in is the total number of characters sent or received.
*/

#include <lpc21xx.h> 
#include "Serial.h"
#include "Config.h"

#define BufferSize 256

typedef struct 
{
	unsigned int	nextIn;
	unsigned int	nextOut;
	char			Buffer[BufferSize];
} buffer_struct;

static buffer_struct RxBuffer;
static buffer_struct TxBuffer;

// Number of characters in the Rx and TX buffer
#define RxBufLength ((unsigned short) (RxBuffer.nextIn-RxBuffer.nextOut))
#define TxBufLength ((unsigned short) (TxBuffer.nextIn-TxBuffer.nextOut))

static unsigned int tx_restart = 1;	// Non zero if TX restart is required
unsigned long UART0_Baudrate;

void UART0_Init(void)
{
	// Clear com buffers indexes
	RxBuffer.nextIn = 0; RxBuffer.nextOut = 0;
	TxBuffer.nextIn = 0; TxBuffer.nextOut = 0;
	tx_restart = 1;

	// Setup serial port registers
	PINSEL0 = PINSEL0 & 0xFFFFFFF0;
	PINSEL0 = PINSEL0 | 0x00000005;	// Eanable TxD0 and RxD0

	U0IER = 0x00;					// Disable UART0 interrupts

	U0LCR = 0x03;					// 8 bits, no parity, 1 stop bit

	UART0_SetBaud(115200);			// Baudrate = 115200

	VICVectAddr2 = (unsigned long)UART0_irq;
	VICVectCntl2 = 0x20 | 6;		// UART0 interrupt (irq enable + interrupt number)
	VICIntEnable = 1 << 6;			// Enable UART0 interrupt

	U0IER = 0x07;					// Enable RBR, THRE, Rx line status interrupts

	U0FCR = 0x01;					// Enable and clear FIFO's
}

void UART0_Stop(void)
{
	U0IER = 0x00;					// Disable UART0 interrupts
	U0FCR = 0x00;					// Disable FIFO's
}

void UART0_SetBaud(unsigned int rate)
{
	unsigned long newRate;

	UART0_Baudrate = rate; 
	newRate = ((LPCconfig()->PLL_Multiplier*LPCconfig()->crystal) / rate) / 16;

	U0LCR |= 0x80;	 				// enable access to divisor latch (LSB, MSB) register

	U0DLL = newRate & 0x00FF;
	U0DLM = (newRate & 0xFF00)>>8;

	U0LCR &= ~0x80;					// enable access to U0RBR and U0THR
}

void UART0_irq(void) __irq
{
	volatile char dummy;
	volatile char IIR;
	buffer_struct *pnt;

	while (((IIR = U0IIR) & 0x01) == 0)		// At least one interrupt is pending
	{
		switch (IIR & 0x0E)
		{
		case 0x06:							// Receive line status
			dummy = U0LSR;					// Clear interrupt source
			break;
		case 0x04:							// Receive data available
		case 0x0C:							// Character timeout
			pnt = &RxBuffer;
			if (((pnt->nextIn - pnt->nextOut) & ~(BufferSize-1)) == 0) // Room ?
			{
				pnt->Buffer[pnt->nextIn++ & (BufferSize-1)] = U0RBR;
			}
			break;
		case 0x02:							// THRE interrupt
			pnt = &TxBuffer;
			if (pnt->nextIn != pnt->nextOut)
			{
				U0THR = pnt->Buffer[pnt->nextOut++ & (BufferSize-1)];
				tx_restart = 0;
			}
			else
			{
				tx_restart = 1;
			}
			break;
		default:
			break;
		}
	}
  	VICVectAddr = 2;						// Acknowledge interrupt
}
unsigned short UART0_RxNumber(void)
{
	return RxBufLength;
}

unsigned short UART0_TxEmpty(void)
{
	return TxBufLength;
}

char UART0_Get(void)
{
	buffer_struct *pnt = &RxBuffer;

	if (RxBufLength == 0)
		return (-1);

	return (pnt->Buffer[(pnt->nextOut++) & (BufferSize - 1)]);
}

int UART0_Put(char data) //?
{
	buffer_struct *pnt = &TxBuffer;

	if (TxBufLength >= BufferSize)
		return (-1);						// Buffer full, return error

	if (tx_restart)
	{
		tx_restart = 0;
		U0THR = data;
	}
	else
	{
		pnt->Buffer[pnt->nextIn++ & (BufferSize - 1)] = data;
	}

	return (0);
}

int UART0_Str(char data[128],int n)
{
	int i;
	for (i=0; i<n; i++)
	{ 
		if (UART0_Put(data[i]) == -1) return -1;
	}
	return 0;
}
