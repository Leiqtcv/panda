/*************************************************************************
						Monkey.h
**************************************************************************/
#include "../include/global.h"

void ADC_irq(void) __irq;
int  AdcNext(int AdcActive);

void 		ADC_Init		(void);
//adc_buffer 	ADC_GetSamples	(void);
//void       *ADC_FitData		(void);
void		ADC_SetFitDataFlag(void);
void		ADC_ClrFitDataFlag(void);

/*************************************************************************
						General
**************************************************************************/
void Delay (unsigned long a);
int  InitAll();
void splitInput(void);					
void getWord(void);
int  getVal(void);
/*************************************************************************
						Commands
**************************************************************************/
void execStim();	// cmdStim		- Uitvoeren van een stimulus
void Init();		// cmdInit		- Initialiseren micro
void GetInfo();		// cmdInfo		- geeft de string LPC2119 terug
void GetClock(); 	// cmdClock 	- geeft de tijd in seconden na het resetten micro
void ResetClock(); 	// cmdResClock	- seconde clock wordt op nul gezet
void ClearSky();	// cmdClrSky    - alle leds uit

void GetTime();		// cmdTime		- geeft de tijd in msec na het starten van een nieuwe trial
void ResetTime(); 	// cmdClrTime	- trial clock wordt op nul gezet
void SetSky();   	// cmdSetSky    - alle leds met intensiteit 100
void ResetSky();	// cmdClrSky    - alle leds uit

void ClearArc(void);
void ClearSky(void);
void LedOnOff(int index, int level, int OnOff);
void SkyOnOff(int spaak, int led, int level, int OnOff);

void getPIO(void);
void SetBitsPar(int i);
void ClrBitsPar(int i);
void ClrAllBitsPar(void);
int  GetBitsPar(void);
int  TstBitPar(int bit);
void WaitForEnter(void);


void execInit();

void execResults();

void execEvent(int index);
int  execBarFlank(int index);
int  execBarLevel(int index);
int  execBarCheck(int index);
int  execBar(int index);
int  execSky(int index);
int  execLed(int index);
int  execRec(int index);
int  execRew(int index);
int  execLas(int index);
int  execSnd(int index);
int	 execFixWnd(int index);
int  execSpeed(int index);
void calculateSpeed(void);
void execError(void);

void execInit();
void getInfo();
void getState();
void getStateTrial();
void getClock();
void getTime();
void clrTime();
void execReset();
void execAbort();
void execNextTrial();
void execStartTrial();
void execSaveTrial();
void getBarState();
void getADC();
void getSpeed();
void selectADC();
int  softReset();
void setSpeaker();

void readAndSplit();
void loadNNMod();
double tansig(double d);
double simulateNN(int mode);
void setFixWindow();
int testFixWnd(int index);
