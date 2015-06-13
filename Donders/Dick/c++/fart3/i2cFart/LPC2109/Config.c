/*************************************************************************
						Config.c

Project		 	Controller		DJH MBFYS UMCN
--------------------------------------------------------------------------
Configuration Micro Controller

Versie 1.00		19-05-2005		Dick Heeren
**************************************************************************/

#include "Config.h"
#include <lpc21xx.h> 

static T_LPC2119 lpc2119;

void LPCinit(void)
{
	lpc2119.crystal        = 10000000;
	lpc2119.PLL_Multiplier = 5;
	lpc2119.PLL_Divider    = 2;
	lpc2119.UART0_Baudrate = 0;

	VICIntSelect = 0;
}

T_LPC2119 *LPCconfig(void)
{
	return &lpc2119;
}

