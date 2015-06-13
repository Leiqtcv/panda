/*************************************************************************
						ADC.h

Project		 	Controller		DJH MBFYS UMCN
--------------------------------------------------------------------------
ADC using Philips LPC internal hardware
LPC2119 user manual page 238-240
--------------------------------------------------------------------------
Versie 1.00		14-09-2005		Dick Heeren
       1.01		27-08-2009		Dick Heeren
	   Hardware is uitgebreid met multiplexer (nu 8 kanalen)
**************************************************************************/

typedef struct 
{
	double	data[8][11];
	int     select[8];    // 0 = not selected, else selected
} adc_buffer;

typedef struct
{
	int    flag;
	int	   pnt;
	double data[2][50];    // [NN 0..1][sample]
}fit_buffer;

void ADC_irq(void) __irq;
int  AdcNext(int AdcActive);

extern	void 		ADC_Init		(void);
extern	void		ADC_Select		(int sel); // bit = 1 active
extern	adc_buffer 	ADC_GetSamples	(void);
extern  void       *ADC_FitData		(void);
extern  void		ADC_SetFitDataFlag(void);
extern  void		ADC_ClrFitDataFlag(void);

extern  double 		simulateNN(int netw);


											  