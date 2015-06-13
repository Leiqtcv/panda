/*************************************************************************
						Config.h

Project		 	Controller		DJH MBFYS UMCN
--------------------------------------------------------------------------
Configuration Micro Controller

Versie 1.00		19-05-2005		Dick Heeren
**************************************************************************/


#ifndef __TLPC21xx__
#define __TLPC21xx__

/* LPC2119 */
typedef struct
{
	unsigned int	crystal;			// see start.s
	unsigned char  	PLL_Multiplier;				
	unsigned char  	PLL_Divider;
	unsigned int 	UART0_Baudrate;
}T_LPC2119; 	

#endif		

extern	void 		LPCinit		(void);

extern 	T_LPC2119 	*LPCconfig	(void);
