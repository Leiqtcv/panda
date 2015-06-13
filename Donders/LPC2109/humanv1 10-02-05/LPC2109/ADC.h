/*************************************************************************
						ADC.h

Project		 	Controller		DJH MBFYS UMCN
--------------------------------------------------------------------------
ADC using Philips LPC internal hardware
LPC2119 user manual page 238-240
--------------------------------------------------------------------------
Versie 1.00		14-09-2005		Dick Heeren
**************************************************************************/

typedef struct 
{
	int	data[4];
	int select[4];    // 0 = not selected, else selected
} adc_buffer;

void ADC_irq(void) __irq;
int  AdcNext(int AdcActive);

extern	void 		ADC_Init		(void);
extern	void		ADC_Select		(int sel); // bit 0..3 -> channels 1..4
extern	adc_buffer 	ADC_GetSamples	(void);

											  