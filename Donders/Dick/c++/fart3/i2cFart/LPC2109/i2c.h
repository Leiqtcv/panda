/*************************************************************************
						I2C.h

Project		 	Controller		DJH MBFYS UMCN
--------------------------------------------------------------------------
I2C Interface using Philips LPC internal hardware

LPC2119 user manual page 166-177
80C51 overview      page  23- 26
--------------------------------------------------------------------------
Versie 1.00		19-05-2005		Dick Heeren
**************************************************************************/

extern void I2C_Init(void);
extern int I2C_SendByte(unsigned char address, int num, int data[4]);

void I2C_irq(void) __irq;
void I2C_SetBitrate(void);
int  I2C_Start(void);



