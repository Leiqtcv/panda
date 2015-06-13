/*************************************************************************
						ADC.c

Project		 	Controller		DJH MBFYS UMCN
----------------------------------------------
Versie 1.00		14-09-2005		Dick Heeren
**************************************************************************/
#include <lpc21xx.h> 
#include "ADC.h"
#include "Config.h"
#include "Clock.h"

static adc_buffer 	AdcBuffer;
static fit_buffer	FitBuffer;
static int 			AdcActive;

void ADC_SetFitDataFlag(void)
{
	FitBuffer.flag = 1;
}

void ADC_ClrFitDataFlag(void)
{
	FitBuffer.flag = 0;
}

void ADC_Init(void)
{	// Clock AD converter has to be less than 4.5 MHz.	 (50 Mhz / (CLKDIV+1))	
	// Channels 0..3			 7:0  -> 0F
	// Clock divided by 		15:8  -> FF 	(0D = 3.5714 MHz)	 (FF = 0.19607 mHz)
	// Burst mode off 			16    ->  0
	// CLKS 11 clocks			19:17 ->  0
	// Power down PDN=1			21	  ->  1
	// No start					26:24 ->  0
	int i,n,channel;

	for(i=0; i<8; i++)
	{
		AdcBuffer.select[i] = 1;
	}

	for(i=0; i<8; i++)
	{
		for (n=0; n<11; n++)
		{
			AdcBuffer.data[i][n] = 0;
		}
	}

	AdcActive = 0;
	channel = (1 << AdcActive);
	PINSEL1 |= 0x55 << 22;				// channels 0,1,2,3
	ADCR = channel;
	ADCR |= ((0xFF << 8) | (1 << 21)); 

	VICVectAddr3 = (unsigned long)ADC_irq;
	VICVectCntl3 = 0x20 | 18;		// ADC interrupt (irq enable + number of interrupt)
	VICIntEnable = 1 << 18;			// Enable ADC interrupt

	ADCR |= (0x001 << 24);
	FitBuffer.flag = 1;
	FitBuffer.pnt  = 0;
}

void ADC_irq(void) __irq
{
	int i, val, chan;
	double dVal;

	val  = ((ADDR >>  6) & 0x03FF); 	// Get result
	chan = ((ADDR >> 24) & 0x0003);		// and channel
	if (FitBuffer.flag == 1)
	{
		chan = chan | (AdcActive & 0x04);	// add group (multiplexer)
		dVal = val;
		dVal = (dVal-512.0)/36.5;
		for (i=1; i<10; i++)
		{
			AdcBuffer.data[chan][i] = AdcBuffer.data[chan][i+1];
		}
		AdcBuffer.data[chan][10] = dVal;

		dVal = 0;
		for (i=1; i<11; i++)
		{
			dVal += AdcBuffer.data[chan][i];	
		}

		AdcBuffer.data[chan][0] = dVal/10.0;

		if (chan == 3) 
		{
			FitBuffer.data[chan][FitBuffer.pnt] = dVal/10.0;

			FitBuffer.pnt++;
			FitBuffer.pnt = (FitBuffer.pnt % 50);
		}
 
 		AdcActive = AdcNext(AdcActive);
		if ((AdcActive & 0x04) > 0)			// select group
			IOCLR0 = 0x8000;
		else
			IOSET0 = 0x8000;
		chan = (1 << (AdcActive & 0x03));	// remove group select
	}
  	VICVectAddr = 3;						// Acknowledge interrupt

	ADCR &= ~0xF;
	ADCR |= chan;
	ADCR |= (0x001 << 24);

}

void ADC_Select(int sel)
{
	int i;
	for (i = 0;i < 8;i++)
	{
		AdcBuffer.select[i] = 1;// (sel >> i) & 0x01;
	}
}

int AdcNext(int current)
{
	int next;
	next = current;
	if (++next == 8) next = 0;
	while ((AdcBuffer.select[next] == 0) && (next != current))
	{
		if (++next == 8) next = 0;
	}
	return next;
}

adc_buffer ADC_GetSamples()
{
	return AdcBuffer;
}

void *ADC_FitData()
{
	fit_buffer *ptr;
	ptr = &FitBuffer;
	return ptr;
}

double simulateNN(int netw)
{
	int i, n, nn, nh, lp;
	double temp, test[6], val;
	double inp[6];
//	adc_buffer AdcBuffer;

//	AdcBuffer = ADC_GetSamples();
	val = 0;

	lp=netw;
	for (nn=0;nn<NNs[lp].nInput;nn++)
	{
		inp[nn]  =  AdcBuffer.data[NNs[lp].channels[nn]-1][0];
		test[nn] =  NNs[lp].scaleInput[nn][0]*inp[nn]+NNs[lp].scaleInput[nn][1];
	}

	val = 0;
	for (nh=0;nh<NNs[lp].nHidden;nh++)
	{
		temp = 0;
		for (nn=0;nn<NNs[lp].nInput;nn++)
		{
    		temp = temp + test[nn]*NNs[lp].weightsHidden[nn][nh];
		}
	    val = val + NNs[lp].weightsOutput[nh]*tansig(temp+NNs[lp].biasHidden[nh]);
	}
	val = val + NNs[lp].biasOutput;
	val = NNs[lp].scaleOutput[0]*val+NNs[lp].scaleOutput[1];
	return val;
}
