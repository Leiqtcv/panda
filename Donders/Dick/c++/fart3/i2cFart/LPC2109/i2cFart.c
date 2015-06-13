/***************************************************************************
						    i2cFart
****************************************************************************/
#include <lpc21xx.h>
#include <stdio.h>
#include <inttypes.h>

#include "i2cFart.h"
#include "Config.h"
#include "serial.h"
#include "i2c.h"



int main (void)
{
	char inBuf[82];	
	char err[2];	
	char ans[2];	
	int Buf[4];
	int pnt; 
	int inChar;
	int address = 0;
	int num   = 0;
	InitAll();
	ans[0] = '*';
	ans[1] = 13;
	err[0] = 'E';
	err[1] = 13;
	pnt = 0;
	ClrBitsPar(0x01);
	for (;;)
	{
		while (UART0_RxNumber() > 0)
		{
			inChar = UART0_Get();
 			if (inChar == ENTER)
			{
				SetBitsPar(0x01);
				inBuf[pnt] = 0;
				pnt = 0;
				sscanf(inBuf,"%d %d %d %d %d %d",&address,&num,&Buf[0],&Buf[1],&Buf[2],&Buf[3]);
				if (I2C_SendByte(address,num,Buf) == 0)
					UART0_Str(err,2);
				else
					UART0_Str(ans,2);
			}
			else
				inBuf[pnt++] = (char) inChar;
		}
	}
	return 0;
}
/* *********************************************************************************** */
int InitAll()
{
	LPCinit();
	IODIR0  = 0x00000FF0;	// P0.4-P0.11 as output bit 0..7
							// PO.18-P0.25 as input bit 0..7
  	IOSET0 |= 0x00000FF0;	// LED off 


//	Clock_Init();			// interrupt 0						   
	I2C_Init();				// interrupt 1
	UART0_Init();			// interrupt 2

	return(0);
}

void SetBitsPar(int i)
{
	IOSET0 = (i & 0xFF) << 4;		   
}


void ClrBitsPar(int i)
{
	IOCLR0 = (i & 0xFF) << 4;
}
/*
int GetBitsPar(void)
{
	int i;
	i = (IOPIN0 >> 17) & 0x00FF;
	return i;
}

int TstBitPar(int bit)
{
	int i;
	i = GetBitsPar();
	i = (i & bit);

	return i;
}
*/