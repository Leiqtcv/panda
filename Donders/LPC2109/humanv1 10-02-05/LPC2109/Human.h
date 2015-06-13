/*************************************************************************
						Human.h

Project		 	Controller		DJH MBFYS CNS UMCN
--------------------------------------------------
1.00			30-03-2006		Dick Heeren
**************************************************************************/
#include "global.h"

int	InitAll(void);
void LedOnOff(int led, int level, int OnOff, int parallel);
void SkyOnOff(int spaak, int led, int level, int OnOff);
void ClearSky(void);
void ClearArc(void);

void getWord(void);
int  getVal(void);
void splitInput(void);

void ReturnInfo(void);
void ChannelOn(void);
void ChannelOff(void);
void GetPIO(void);

void Trigger(int bit, int Up);
void ReturnDataMicro(void);
void SpeakersOff(void);

int ExecLed(int index);
int ExecLeds(int index);
int ExecBlink(int index);
int ExecSky(int index);
int ExecSnd(int index);
void ExecEvent(int event);
int ExecTrg0(int index);
int ExecAcq(int index);
int ExecLas(int index);


void ClrBitsPar(int i);
void SetBitsPar(int i);
int  GetBitsPar(void);
int  TstBitPar(int bit);

void GetTime(void);


