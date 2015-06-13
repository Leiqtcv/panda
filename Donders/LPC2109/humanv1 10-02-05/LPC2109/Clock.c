/*************************************************************************
						clock.c

Project		 	Trainen aap		DJH CNS UMCN
--------------------------------------------------------------------------
Versie 1.00		02-02-2006		Dick Heeren
**************************************************************************/
#include <lpc21xx.h> 
#include "Clock.h" 

unsigned int Ticks;
unsigned int Seconds;
unsigned int Count;

// Setup timer
void Clock_Init(void)
{
	Seconds = 0;
	Count   = 0;
	Ticks = 0;
	T0PR  = 0;		// prescale register
	T0PC  = 0;		// prescale counter = max T0PR
	T0MR0 = 50000; 	// clock 1 mSec -> 50000 
	T0MCR = 3;
	T0TCR = 1;
	VICVectAddr0 = (unsigned long) timer0;
	VICVectCntl0 = 0x20 | 4;
	VICIntEnable = 1 << 4; 
}

// Timer
void timer0(void) __irq
{
	Ticks++;

	if (++Count == 1000)	// clock 1 mSec 
	{
		Seconds++;
		Count = 0;
	}

	T0IR = 1;
	VICVectAddr = 0;
}

unsigned int Clock_GetTicks(void)
{
	return Ticks;
}

unsigned int Clock_GetSeconds(void)
{
	return Seconds;
}

void Clock_Reset(void)
{
	Ticks   = 0;
}