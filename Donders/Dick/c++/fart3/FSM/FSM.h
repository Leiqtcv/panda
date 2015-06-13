/*
	FSM.h
*/
	#include "tools.h"

    char recvbuf[DEFAULT_BUFLEN];
    int recvbuflen = DEFAULT_BUFLEN;

	void extract(int nStim);
	int execLed(int index);
//=====================================================================//

	#define cRed    1
	#define cGreen  0

	void initAll(void);
	void getStimRecord(int index);
	int  execBit(int index);
	int  execBar(int index);
	int  execBarLevel(int index);
	int  execBarCheck(int index);
	int  execBarFlank(int index);
	int  execRew(int index);
	void execError(void);
	void execEvent(int event);

	void execSetPIO(int value);
	int  execGetPIO(void);
	void execSetBit(int value);
	void execClrBit(int value);

	void LedOnOff(int ring, int spoke, int color, int intensity, bool OnOff);
	void updateLedDriver(int numberIC, int color, int intensity);
	void clearSky(void);

