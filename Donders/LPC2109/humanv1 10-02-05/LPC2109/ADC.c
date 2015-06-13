/*************************************************************************
						ADC.c

Project		 	Controller		DJH MBFYS UMCN
----------------------------------------------
Versie 1.00		14-09-2005		Dick Heeren
**************************************************************************/
#include <lpc21xx.h> 
#include "ADC.h"
#include "Config.h"

static adc_buffer 	AdcBuffer;
static int 			AdcActive;

void ADC_Init(void)
{	// Clock AD converter has to be less than 4.5 MHz.	 (50 Mhz / (CLKDIV+1))	
	// Channels 0..3			 7:0  -> 0F
	// Clock divided by 		15:8  -> FF 	(0D = 3.5714 MHz)	 (FF = 0.19607 mHz)
	// Burst mode off 			16    ->  0
	// CLKS 11 clocks			19:17 ->  0
	// Power down PDN=1			21	  ->  1
	// No start					26:24 ->  0
	int channel;

	AdcBuffer.select[0] = 1;
	AdcBuffer.select[1] = 1;
	AdcBuffer.select[2] = 1;
	AdcBuffer.select[3] = 1;

	AdcActive = 0;
	channel = (1 << AdcActive);
	PINSEL1 |= 0x55 << 22;				// channels 0,1,2,3
	ADCR = channel;
	ADCR |= ((0xFF << 8) | (1 << 21)); 

	VICVectAddr3 = (unsigned long)ADC_irq;
	VICVectCntl3 = 0x20 | 18;		// ADC interrupt (irq enable + number of interrupt)
	VICIntEnable = 1 << 18;			// Enable ADC interrupt

	ADCR |= (0x001 << 24);
}

void ADC_irq(void) __irq
{
	int val, chan;

	val  = ((ADDR >>  6) & 0x03FF); 	// Get result
	chan = ((ADDR >> 24) & 0x0007);		// and channel

	AdcBuffer.data[chan] = (int) val;
 
 	AdcActive = AdcNext(AdcActive);
	chan = (1 << AdcActive);

  	VICVectAddr = 3;					// Acknowledge interrupt

	ADCR &= ~0xF;
	ADCR |= chan;
	ADCR |= (0x001 << 24);
}

void ADC_Select(int sel)
{
	if (sel > 0) AdcBuffer.select[sel-1] = 1; else AdcBuffer.select[-1*(sel+1)] = 0;
}

int AdcNext(int current)
{
	int next;
	next = current;
	if (++next == 4) next = 0;
	while ((AdcBuffer.select[next] == 0) && (next != current))
	{
		if (++next == 4) next = 0;
	}

	return next;
}

adc_buffer ADC_GetSamples()
{
	return AdcBuffer;
}


