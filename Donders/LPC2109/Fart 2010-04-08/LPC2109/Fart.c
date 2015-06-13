/*********************************************************************************************
						    Fart.c
	05-Sep-2008 	Fart is a new micro controller program for human and monkey
					experiments, replacing Human and Monkey.
	22-Sep-2008		Finite state machine
	17-Apr-2009 	3.00 New design
	04-May-2009 	3.10 stimBar has improved (fix, tar and dim are removed)
					in case of an error T_trial is negative and the record 
					is cleared.
					3.11 Bar, Sky, rew and rec are tested with a script of Tom
	02-Jun-2009		3.20 Sound-
					3.21 Selection speakers + volume
					3.22 playing sound
	21-Jul-2009  	Max stimuli is now 50
				 	GetStateBar returns a new line
	02-Sep-2009	 	stimRec extended with stop time
	             	new stimulus las 
	24-Sep-2009	 	Abort function implemented for testing timeouts
	05-Oct-2009	 	Init sets nStim to 0.
	04-Nov-2009	 	3.41 Reading results with mex functions and data to Matlab.
				 	Input en output buffer has increased from 80 to 128
	07-Jan-2010  	cmdNNMod en cmdNNSim for testing neural networks
	03-Feb-2010	 	3.60 Windowing
----------------------------------------------------------------------------------------------
	04-Feb-2010	 	1.00 From now on one program, Fart: replacing C++ for both arches
					Windowing cpmpleted.
    12-Feb-2010	 	1.00 Velocity tested with Matlab, input tone generator.
	16-Feb-2010		1.01 Velocity, input NN's. Head, eye velocity calculated
					towards a goal.
	01-Mar-2010		1.02 Implementation triggering by velocity, tested with Tom
*********************************************************************************************/
#include <lpc21xx.h>
#include <stdio.h>
#include <inttypes.h>
#include <math.h>

#include "Fart.h"
#include "Config.h"
#include "Clock.h"
#include "Serial.h"
#include "i2c.h"

//=> Check output (Fart1/Fart2) in "Project->Options for Target Fart"
//=> and global.h for contional compiling 
#ifdef Fart1
char version[] = "LPC2119->Fart1 1.11 08-Apr-2010\n";				   
#endif
#ifdef Fart2
char version[] = "LPC2119->Fart2 1.11 08-Apr-2010\n";				   
#endif
//========================================= A D C ==========================================//
adc_buffer 	AdcBuffer;			// 8 channels adc buffer
int 		AdcActive;			// Active adc channel (1..8)
//======================================= M A I N =========================================//
char 		inBuf[128];		   	// used for RS232 communication
char 		outBuf[128];
int  		inpPnt, outPnt;   	// de bijbehorende pointers
int32_t 	nBuffer[25];		// commands and parameters
double		rBuffer[25];		// commands and parameters for NN
char 		wrd[10];			// memory, 1 word from inBuf


uint32_t 	startTime;		    // start after ITI	= reference time
uint32_t 	curTime;			// crrent time
int 		ITI       = 0;		// Inter Trial Interval
int 		errFlag   = false;	// Flag used within some functions
int 		errTime   = 0;		// Time error was occured
recStim 	stim[40];			// Buffer with stim records
int 		nStim     = 0;		// Index stim buffer

NNMOD 		NNs[4];				// Buffer for 4 NN
int			NetNum;				// Temporary index for loading NN model
FIXWND 		fixWindows[10];		// Buffer for 10 Fixation windows
double 		speed[2];			// 0=slope, 1=offset
int 		pntNN;
int 		seconds = 0;		// clock, seconds
uint32_t 	ticks   = 0;		// closk, ticks
int 		MCS     = 1;		// Micro Controller Status

//=================================== H A R D  W A R E =====================================//
recLedIC Leds[2][2][4];		// [front/back] [internal selection PCA 9532 LS0..LS3]
recLedIC Sky[13];       	// 5,9,14,20,27,35,44,54,65 degrees

int boards[8]   = {0xF7,0xFB,0xFD,0xFE,0x7F,0xBF,0xDF,0xEF};  // pre selection speaker
int speakers[8] = {0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01};
int gain1[8]    = {0x7F,0xDF,0xF7,0xFD,0x7F,0xDF,0xF7,0xFD};  // snd1
int gain2[8]    = {0xBF,0xEF,0xFB,0xFE,0xBF,0xEF,0xFB,0xFE};  // snd2
// signal: bit=0->signal2, bit=1->signal1
int statusBoards[8][3];  // [board][signal, gain1..4, gain5..8]
                         // 0x4E=board, 0x40=signal, 0x44 gain1..4, 0x42 gain5..8  

int 		parInp  = 0;		// digital I/O, input
int 		parOutp = 0;		// digital I/O, output

int 		recBit  = 0;		// Trigger record (TDT)
int 		rewBit  = 0;		// Trigger reward
int 		sndBit  = 0;		// Trigger sound
int 		lasBit	= 0;		// Trigger Laser

char 		state[80];			// State of each seperate stimulus
unsigned int T_trial = 0;		// Trial elapsed time
unsigned int T_ITI   = 0;		// ITI elapsed time
unsigned int T_start = 0;		// Trial begin time
unsigned int T_done  = 0;		// Trial end time

/************************************** A D C ***********************************************/
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
}

void ADC_irq(void) __irq
{
	int i, val, chan;
	double dVal;

	val  = ((ADDR >>  6) & 0x03FF); 	// Get result
	chan = ((ADDR >> 24) & 0x0003);		// and channel
	chan = chan | (AdcActive & 0x04);	// add group (multiplexer)
	dVal = val;
#ifdef Fart1
		dVal = (dVal-523.0)/375;
#endif
#ifdef Fart2
		dVal = (dVal-559.0)/447;
#endif

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
	AdcActive = AdcNext(AdcActive);
	if ((AdcActive & 0x04) > 0)				// select group
		IOCLR0 = 0x8000;
	else
		IOSET0 = 0x8000;
	chan = (1 << (AdcActive & 0x03));		// remove group select

  	VICVectAddr = 3;						// Acknowledge interrupt

	ADCR &= ~0xF;
	ADCR |= chan;
	ADCR |= (0x001 << 24);
}

int AdcNext(int current)
{
	int next;
	next = current;
	if (++next == 8) next = 0;
	return next;
}

/**************************************** M A I N *******************************************/
int main (void)
{
	int i, n, m;
	int inChar;
	int num     = 0;
	int ITI     = 0;
	int done  = false;
	int EOL   = false;
	int abort = false;
	int flag  = false;
	char CR[] = "\n";
	char SP[] = " ";
	char NUMBERS[] = "0123456789";
	softReset();
 	/********************************************************************/
	for (;;)
	{
		while ((UART0_RxNumber() > 0) && (EOL == false))
		{
			inChar = UART0_Get();
			if (inChar == ESCAPE) abort = true;
 			if ((inChar == LF))
			{
				EOL        = true; 			// new command
				inBuf[num] = 0;
				splitInput(); 				// command plus parameters
			}
			if (EOL == false) inBuf[num++] = (char) inChar;
		}
		/********************************************************************/
 		curTime = Clock_GetTicks();
		seconds = Clock_GetSeconds();
		ticks   = curTime;
		parInp  = GetBitsPar();

		/********************************************************************/
		if ((MCS == statInit) && (EOL == true))
		{
			switch(nBuffer[1])
			{
			case cmdSaveTrial:	execSaveTrial();break;
			case cmdStim:		execStim();		break;
			case cmdInit:		execInit();		break;
			case cmdInfo: 		getInfo();		break;
			case cmdState: 		getState();		break;
			case cmdStateTrial: getStateTrial();break;
			case cmdClock:		getClock();		break;
			case cmdTime: 		getTime();		break;
			case cmdClrTime: 	clrTime();		break;
			case cmdReset:	 	execReset();	break;
			case cmdAbort:	 	execAbort();	break;
			case cmdNextTrial:	execNextTrial();break;
			case cmdBar:		getBarState();	break;
			case cmdADC:		getADC();		break;
			case cmdSelADC:		selectADC();	break;
			case cmdPin:		getPIO();		break;
			case cmdSpeaker:	setSpeaker();	break;
			case cmdNNMod:		loadNNMod();	break;
			case cmdNNSim:		simulateNN(-1);	break;
			case cmdFixWnd:		setFixWindow(); break;
			case cmdSpeed:		getSpeed();		break;
			}
			EOL = false;
			num = 0;
		}
		/********************************************************************/
		if ((MCS == statNextTrial) && (EOL == true))
		{
			flag = true;
			switch(nBuffer[1])
			{
			case cmdStartTrial:	execStartTrial(); flag = false;   break;
			case cmdState:	    getState();       flag = false;   break;
			case cmdStateTrial:	getStateTrial();  flag = false;   break;
			case cmdPin:		getPIO();		  flag = false;   break;
			case cmdAbort:	 	execAbort();	  flag = false;   break;
			}

			switch(nBuffer[1])
			{
			case stimBar:	
				stim[nStim].status    = statInit;
				stim[nStim].kind	  = stimBar;
				stim[nStim].mode      = nBuffer[2];
				stim[nStim].edge      = nBuffer[3];
				stim[nStim].bitNo     = nBuffer[4];
				stim[nStim].startRef  = nBuffer[5];
				stim[nStim].startTime = nBuffer[6];
				stim[nStim].stopRef   = nBuffer[7];
				stim[nStim].stopTime  = nBuffer[8];
				stim[nStim].event     = nBuffer[9];
				nStim++;
				break;
			case stimRec:
				stim[nStim].status    = statInit;
				stim[nStim].kind	  = stimRec;
				stim[nStim].bitNo     = nBuffer[2];
				stim[nStim].startRef  = nBuffer[3];
				stim[nStim].startTime = nBuffer[4];
				stim[nStim].stopRef   = nBuffer[5];
				stim[nStim].stopTime  = nBuffer[6];
				stim[nStim].event     = nBuffer[7];
				recBit = (1 << (stim[nStim].bitNo-1));
				nStim++;
				break;
			case stimRew:
				stim[nStim].status    = statInit;
				stim[nStim].kind	  = stimRew;
				stim[nStim].bitNo     = nBuffer[2];
				stim[nStim].startRef  = nBuffer[3];
				stim[nStim].startTime = nBuffer[4];
				stim[nStim].stopRef   = nBuffer[5];
				stim[nStim].stopTime  = nBuffer[6];
				stim[nStim].event     = nBuffer[7];
				rewBit = (1 << (stim[nStim].bitNo-1));
				nStim++;
				break;
			case stimLas:
				stim[nStim].status    = statInit;
				stim[nStim].kind	  = stimLas;
				stim[nStim].bitNo     = nBuffer[2];
				stim[nStim].startRef  = nBuffer[3];
				stim[nStim].startTime = nBuffer[4];
				stim[nStim].stopRef   = nBuffer[5];
				stim[nStim].stopTime  = nBuffer[6];
				stim[nStim].event     = nBuffer[7];
				lasBit = (1 << (stim[nStim].bitNo-1));
				nStim++;
				break;
			case stimSky:
				stim[nStim].status    = statInit;
				stim[nStim].kind	  = stimSky;
				stim[nStim].posX      = nBuffer[2];
				stim[nStim].posY      = nBuffer[3];
				stim[nStim].level     = nBuffer[4];
				stim[nStim].startRef  = nBuffer[5];
				stim[nStim].startTime = nBuffer[6];
				stim[nStim].stopRef   = nBuffer[7];
				stim[nStim].stopTime  = nBuffer[8];
				stim[nStim].event     = nBuffer[9];
				nStim++;
				break;													   
			case stimLed:
				stim[nStim].status    = statInit;
				stim[nStim].kind	  = stimLed;
				stim[nStim].posX      = nBuffer[2];
				stim[nStim].posY      = nBuffer[3];
				stim[nStim].level     = nBuffer[4];
				stim[nStim].startRef  = nBuffer[5];
				stim[nStim].startTime = nBuffer[6];
				stim[nStim].stopRef   = nBuffer[7];
				stim[nStim].stopTime  = nBuffer[8];
				stim[nStim].event     = nBuffer[9];
				nStim++;
				break;
			case stimSnd1:	
				stim[nStim].status    = statInit;
				stim[nStim].kind      = stimSnd1;
				stim[nStim].bitNo     = nBuffer[2];
				stim[nStim].startRef  = nBuffer[3];
				stim[nStim].startTime = nBuffer[4];
				stim[nStim].stopRef   = nBuffer[5];
				stim[nStim].stopTime  = nBuffer[6];
				stim[nStim].event     = nBuffer[7];
				sndBit = (1 << (stim[nStim].bitNo-1));
				nStim++;
				break;
			case stimSnd2:	
				stim[nStim].status    = statInit;
				stim[nStim].kind      = stimSnd1;
				stim[nStim].bitNo     = nBuffer[2];
				stim[nStim].startRef  = nBuffer[3];
				stim[nStim].startTime = nBuffer[4];
				stim[nStim].stopRef   = nBuffer[5];
				stim[nStim].stopTime  = nBuffer[6];
				stim[nStim].event     = nBuffer[7];
				sndBit = (1 << (stim[nStim].bitNo-1));
				nStim++;
				break;
			case stimFixWnd:
				stim[nStim].status    = statInit;
				stim[nStim].kind      = stimFixWnd;
				stim[nStim].index     = nBuffer[ 2];
				stim[nStim].posX      = nBuffer[ 3];
				stim[nStim].posY      = nBuffer[ 4];		
				stim[nStim].winX      = nBuffer[ 5];
				stim[nStim].winY      = nBuffer[ 6];		
				stim[nStim].startRef  = nBuffer[ 7];
				stim[nStim].startTime = nBuffer[ 8];
				stim[nStim].stopRef   = nBuffer[ 9];
				stim[nStim].stopTime  = nBuffer[10];
				stim[nStim].delay     = nBuffer[11];
				stim[nStim].event     = nBuffer[12]; 
				nStim++;							
				break;
			case stimSpeed:
				stim[nStim].status    = statInit;
				stim[nStim].kind      = stimSpeed;
				stim[nStim].mode      = nBuffer[ 2];  // matlab numbering
													  // xxx321-X, 654xxx-Y
													  // bit 3xx = 1 Yes
													  // bit x21 = id NN
				stim[nStim].posX      = nBuffer[ 3];  // target 
				stim[nStim].posY      = nBuffer[ 4];		
				stim[nStim].startRef  = nBuffer[ 5];
				stim[nStim].startTime = nBuffer[ 6];
				stim[nStim].stopRef   = nBuffer[ 7];
				stim[nStim].stopTime  = nBuffer[ 8];
				stim[nStim].level     = nBuffer[ 9];  // velocity
				stim[nStim].event     = nBuffer[10];
				nStim++;							 
				break;
			}

			if (flag == true)
			{
            	n = sprintf(outBuf,"%d\n",curTime);
				i = UART0_Str(outBuf, n);
				nBuffer[1] = 0;
			}
			EOL = false;
			num = 0;
		}
		/********************************************************************/
		curTime = Clock_GetTicks();
		seconds = Clock_GetSeconds();
		ticks   = curTime;
		parInp  = GetBitsPar();
		/********************************************************************/
		if (MCS == statRunTrial)
		{
			if (EOL == true)
			{
				switch(nBuffer[1])
				{
				case cmdBar:	getBarState();	break;
				case cmdState:	getState();		break;
				case cmdStateTrial:	getStateTrial(); break;
				case cmdClock:	getClock();		break;
				case cmdADC:	getADC();		break;
				case cmdReset: 	execReset();	break;
				case cmdPin:	getPIO();		break;
			    case cmdAbort:	execAbort();	break;
				case cmdSpeed:	getSpeed();		break;
				case cmdNNSim:	simulateNN(-1);	break;
				}
				EOL = false;
				num = 0;
			}
			done = 0;
			n = 0;
			state[n] = CR[0];
			curTime = Clock_GetTicks() - T_start;
			for (i = 0; i < nStim; i++)
			{
				switch(stim[i].kind)
				{
					case stimBar:    m = execBar(i);    state[n++] = NUMBERS[m]; done += m; break;
					case stimSky:    m = execSky(i);    state[n++] = NUMBERS[m]; done += m; break;
					case stimLed:    m = execLed(i);    state[n++] = NUMBERS[m]; done += m; break;
					case stimRec:    m = execRec(i);    state[n++] = NUMBERS[m]; done += m; break;
					case stimRew:    m = execRew(i);    state[n++] = NUMBERS[m]; done += m; break; 
					case stimLas:    m = execLas(i);    state[n++] = NUMBERS[m]; done += m; break; 
					case stimSnd1:   m = execSnd(i);    state[n++] = NUMBERS[m]; done += m; break; 
					case stimSnd2:   m = execSnd(i);    state[n++] = NUMBERS[m]; done += m; break; 
					case stimFixWnd: m = execFixWnd(i); state[n++] = NUMBERS[m]; done += m; break; 
					case stimSpeed:  m = execSpeed(i);  state[n++] = NUMBERS[m]; done += m; break; 
				}
				state[n++] = SP[0];
			}
			state[n++] = CR[0]; 
			state[n] = 0;
			if (done == 0)
			{
				if (errFlag == false)
				{
					MCS = statDoneTrial;
					T_done  = Clock_GetTicks();
					T_trial = T_done - T_start;
				}
				else
				{
					MCS = statDoneTrial;
					T_done  = Clock_GetTicks();
					T_trial = -1*(T_done - T_start);
				 }
			}

		}
		/********************************************************************/
		if (MCS == statDoneTrial)
		{
			if (EOL == true)
			{
				switch(nBuffer[1])
				{
				case cmdInit:	execInit();		break;
				case cmdState:	getState();		break;
				case cmdStateTrial:	getStateTrial();break;
				case cmdBar:	getBarState();	break;
				case cmdClock:	getClock();		break;
				case cmdSaveTrial:	execSaveTrial();break;
				case cmdADC:	getADC();		break;		
				case cmdReset:	execReset();	break;
				case cmdPin:	getPIO();		break;
			    case cmdAbort: 	execAbort();	break;
				}
				EOL = false;
				num = 0;
			}
		}
		/********************************************************************/
		if ((seconds & 0x01) > 0) ClrBitsPar(0x01); else SetBitsPar(0x01);
	}

	return 0;
}

void getPIO(void)
{
  	int i, n, val;

	val = GetBitsPar();
	val = ((parOutp << 8) | val);
	n = sprintf(outBuf,"%d\n",val);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}

void SetBitsPar(int i)
{
	IOSET0 = (i & 0xFF) << 4;		   
}


void ClrBitsPar(int i)
{
	IOCLR0 = (i & 0xFF) << 4;
}

void ClrAllBitsPar(void)
{
	IOCLR0 = 0xFF << 4;
}

int GetBitsPar(void)
{
	int i;
#ifdef Fart1
	i = (IOPIN0 >> 17) & 0x00FF;  // big arche
#endif

#ifdef Fart2
	i = (IOPIN0 >> 18) & 0x00FF;  // small arche
#endif
	return i;
}

int TstBitPar(int bit)
{
	int i;
	i = GetBitsPar();
	i = (i & bit);

	return i;
}


void execResults()
{
	int n,i;
	n = sprintf(outBuf,"%d;%d\n",startTime, nStim);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
	MCS = statInit;
}

void execTime()
{
	int n,i;

	n = sprintf(outBuf,"%d\n",Clock_GetTicks());
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}

void execError(void)
{
	int i;
	for (i = 0; i < nStim; i++)
	{
		if (stim[i].status != statDone)
			stim[i].status = statError;
	}
	if (sndBit > 0)
	{
		ClrBitsPar(sndBit);
		parOutp &= ~sndBit;
	}
	if (rewBit > 0)
	{
		ClrBitsPar(rewBit);
		parOutp &= ~rewBit;
	}
	if (recBit > 0)
	{
		ClrBitsPar(recBit);
		parOutp &= ~recBit;
	}
	if (lasBit > 0)
	{
		ClrBitsPar(lasBit);
		parOutp &= ~lasBit;
	}
	ClearSky();
	errFlag = true;
	errTime = Clock_GetTicks();
}

void WaitForEnter(void)
{
	int inChar;
	inChar = -1;
	
	Clock_ClrCountWait();

	while (inChar != LF)
	{
		if (UART0_RxNumber() > 0)
		{
			inChar = UART0_Get();
		}
		else
		{
			if (Clock_GetCountWait() == 100) inChar = LF;
		}
	}
}

void setSpeaker(void)
{
	int n, i, tmp, board, address, speaker;
	unsigned char buffer[2];
	int OnOff   = nBuffer[4];
	int channel = nBuffer[3];
	// Select board	and speaker
#ifdef Fart1
	n = nBuffer[2] + 2;
	if (n == 32) n = 1;
	if (n == 33) n = 2;
#endif

#ifdef Fart2
	n = nBuffer[2] - 1;
#endif
	// < 100 front- else back
	if (n < 100) board = n / 8; else board = ((n - 100) / 8) + 4;
	if (n >= 100) n = n - 100 + 32;  // correction front/back and board 4=board 0
	speaker = n - 8*board;
	address   = 0x4E;

	buffer[0] = boards[board]; 
	I2C_SendByte(address, 1, buffer);
 	// Set signal 1 or 2
	if (OnOff == 1)
	{
		tmp = statusBoards[board][0];
		if (channel == stimSnd1) 
			tmp |= speakers[speaker];	    // set speakerbit
		else
			tmp &= ~speakers[speaker]; 	    // clr speakerbit 

		statusBoards[board][0] = tmp;
		buffer[0] = tmp;
		address   = 0x40;
		I2C_SendByte(address, 1, buffer);
	}

	if (OnOff == 1)
	{
		if (speaker < 4)
		{
			address  = 0x44;
			tmp = statusBoards[board][1];
			if (channel == stimSnd1)
				tmp &= gain1[speaker];
			else
				tmp &= gain2[speaker];
			statusBoards[board][1] = tmp;
		}
		else
		{
			address  = 0x42;
			tmp = statusBoards[board][2];
			if (channel == stimSnd1)
				tmp &= gain1[speaker];
			else
				tmp &= gain2[speaker];
			statusBoards[board][2] = tmp;
		}
	}
	else
	{
		if (speaker < 4)
		{
			address  = 0x44;
			tmp = statusBoards[board][1];
			if (channel == stimSnd1)
				tmp |= ~gain1[speaker];
			else
				tmp |= ~gain2[speaker];
			statusBoards[board][1] = tmp;
		}
		else
		{
			address  = 0x42;
			tmp = statusBoards[board][2];
			if (channel == stimSnd1)
				tmp |= ~gain1[speaker];
			else
				tmp |= ~gain2[speaker];
			statusBoards[board][2] = tmp;
		}
	}
	buffer[0] = tmp;
	I2C_SendByte(address, 1, buffer);

	n = sprintf(outBuf,"%d\n",tmp);
	i = UART0_Str(outBuf, n);

	nBuffer[1] = 0;
}

void setFixWindow()
{
	int i,n;
	int id = nBuffer[2];
	fixWindows[id].fix  = 0;
	fixWindows[id].Xnet = nBuffer[3];
	fixWindows[id].Ynet = nBuffer[4];
	fixWindows[id].Xh   = nBuffer[5]; ///10.0;
	fixWindows[id].Yh   = nBuffer[6]; ///10.0;
	fixWindows[id].time = 0;

	n=sprintf(outBuf,"%d %d %d %d\n",
		fixWindows[id].Xnet,
		fixWindows[id].Ynet,
		(int) fixWindows[id].Xh,
		(int) fixWindows[id].Yh);
	i = UART0_Str(outBuf, n);

	nBuffer[1] = 0;
}

/***************************************************************************************/
void execInit()
{
	int n, i;
	MCS   = statInit;
	nStim = 0;
	n = sprintf(outBuf,"%d\n",curTime);
	i = UART0_Str(outBuf, n);

	nBuffer[1] = 0;
}
/***************************************************************************************/
void getTime()
{
	int val;
	int n, i;
	val = Clock_GetTicks();
	n = sprintf(outBuf,"%d\n",val);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}
/***************************************************************************************/
void clrTime()
{
	Clock_Reset();
	getTime();
	nBuffer[1] = 0;
}
/***************************************************************************************/
void execReset()
{
	int n,i;

//	Clock_Reset();
    softReset();
	n = sprintf(outBuf,"%d\n",curTime);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}
/***************************************************************************************/
void execAbort()
{
	int n,i;
	
	execError();
	n = sprintf(outBuf,"-998\n");
	i = UART0_Str(outBuf, n);
	MCS   = statInit;
	nStim = 0;
	nBuffer[1] = 0;
}
/***************************************************************************************/
void execSaveTrial()
{
	int i,n,lp;

	n = sprintf(outBuf,"%d %d %d\n",nStim, T_ITI, T_trial);
	i = UART0_Str(outBuf, n);
	for (lp = 0; lp < nStim; lp++)
	{
		WaitForEnter();
		n = sprintf(outBuf,"%d %d %d %d\n",
		    stim[lp].kind,stim[lp].status,stim[lp].startTime,stim[lp].stopTime);
		i = UART0_Str(outBuf, n);
	}
	MCS = statInit;
	nBuffer[1] = 0;
}
/***************************************************************************************/
int execRew(int index)
{
	int newTime = Clock_GetTicks() - T_start;

	if (stim[index].status == statInit)
	{
		if ((stim[index].startRef == 0) && (curTime >= stim[index].startTime))
		{
			stim[index].startTime = newTime;
			stim[index].status    = statRun;
			SetBitsPar(rewBit);	  // Trigger high
			parOutp |= rewBit;
			return 1;
		}
		return 2;
	}
	
	if (stim[index].status == statRun)
	{
		if ((stim[index].stopRef == 0) && (curTime >= stim[index].stopTime))
		{
			ClrBitsPar(rewBit);
			stim[index].stopTime = newTime;
			stim[index].status   = statDone;
			execEvent(stim[index].event);
			return 0;
		}
		return 1;
	}
	return 0;
}
/***************************************************************************************/
int execLas(int index)
{
	int newTime = Clock_GetTicks() - T_start;

	if (stim[index].status == statInit)
	{
		if ((stim[index].startRef == 0) && (curTime >= stim[index].startTime))
		{
			stim[index].startTime = newTime;
			stim[index].status    = statRun;
			SetBitsPar(lasBit);	  // Trigger high
			parOutp |= lasBit;
			return 1;
		}
		return 2;
	}
	
	if (stim[index].status == statRun)
	{
		if ((stim[index].stopRef == 0) && (curTime >= stim[index].stopTime))
		{
			ClrBitsPar(lasBit);
			stim[index].stopTime = newTime;
			stim[index].status   = statDone;
			execEvent(stim[index].event);
			return 0;
		}
		return 1;
	}
	return 0;
}
/***************************************************************************************/
void getBarState()
{
	int i, n;
	n = sprintf(outBuf,"%d\n",curTime);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}
/***************************************************************************************/
void getADC()
{
	int n, i;
	double val0, val1, val2, val3, val4, val5, val6, val7;
//	adc_buffer AdcBuffer;

//	AdcBuffer = ADC_GetSamples();
	val0 = AdcBuffer.data[0][0];
	val1 = AdcBuffer.data[1][0];
	val2 = AdcBuffer.data[2][0];
	val3 = AdcBuffer.data[3][0];
	val4 = AdcBuffer.data[4][0];
	val5 = AdcBuffer.data[5][0];
	val6 = AdcBuffer.data[6][0];
	val7 = AdcBuffer.data[7][0];

	n = sprintf(outBuf,"%d %f %f %f %f %f %f %f %f\n",Clock_GetTicks(),val0,val1,val2,val3,val4,val5,val6,val7);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}
void selectADC()
{
	int n, i;
//	ADC_Select(nBuffer[2]); 

	n = sprintf(outBuf,"%d\n",curTime);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}
int softReset()
{
	if (InitAll()  != 0)
		return -1;
	ClrAllBitsPar();
	Clock_Reset();
					  
	MCS = statInit;
	nStim = 0;
	return 0;
}
/* =================================================================================== */
/* =							Algemeen gebruikte functies							 = */
/* = ------------------------------------------------------------------------------- = */
/* = Delay		-> Simple delay function 											 = */
/* = getWord    -> Get one word from the input buffer								 = */
/* = getVal     -> Returns the value of a word (getWord)							 = */
/* = splitInput -> Splits het input buffer in een array             				 = */
/* = InitAll	-> Initialize the controller, ledsky ed								 = */
/* =================================================================================== */
void Delay (unsigned long a)
{
    while (--a != 0);
}
/* *********************************************************************************** */
void getWord(void) 
{
	int pnt = 0;
	while ((inBuf[inpPnt] != ';') && (inBuf[inpPnt] != '\0'))
	{
		wrd[pnt++] = inBuf[inpPnt++];
	}
	wrd[pnt] = '\0';
	if (inBuf[inpPnt] == '\0') inpPnt = -1; else inpPnt++;
}
/* *********************************************************************************** */
int getVal(void) 
{
	int val = 0;
	int pnt = 0;
	if (wrd[0] == '-')
	{
		val = -1*(wrd[1] - '0');
		pnt = 2;
		while (wrd[pnt] != '\0')
		{
			val *= 10;
			val -= wrd[pnt++] - '0';
		}
	}
	else
	{
		val = (wrd[0]- '0');
		pnt = 1;
		while (wrd[pnt] != '\0')
		{
			val *= 10;
			val += wrd[pnt++] - '0';
		}
	}
	return val;
}
/* *********************************************************************************** */
void splitInput(void)					
{
	int i;
	outPnt = 0;
	if (inBuf[0] == '$')
	{
		for (i=0; i < 128; i++)
		{
			if (inBuf[i] == ';') inBuf[i] = ' ';
			if (inBuf[i] == '$') inBuf[i] = ' ';
		}
		sscanf(inBuf,"%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f",
		&rBuffer[0],&rBuffer[1],&rBuffer[2],&rBuffer[3],&rBuffer[4],&rBuffer[5],&rBuffer[6],&rBuffer[7],
		&rBuffer[8],&rBuffer[9],&rBuffer[10],&rBuffer[11],&rBuffer[12],&rBuffer[13],&rBuffer[14],
		&rBuffer[15],&rBuffer[16],&rBuffer[17],&rBuffer[18],&rBuffer[19],&rBuffer[20],&rBuffer[21],
		&rBuffer[22],&rBuffer[23],&rBuffer[24]);
		nBuffer[1] = (int) rBuffer[0];
		if (nBuffer[1] != cmdNNMod)
		{
			outPnt = 2;
			for (i=1; i<24; i++) nBuffer[outPnt++] = (int) rBuffer[i];
		}
	}
	nBuffer[0] = outPnt-1;
}
/* *********************************************************************************** */
int InitAll()
{
	unsigned char buffer[4];
	int n, i;
	
	LPCinit();
	IODIR0  = 0x00008FF0;	// P0.4-P0.11 as output bit 0..7
							// PO.15 as switch for multiplexer
							// PO.18-P0.25 as input bit 0..7
  	IOSET0 |= 0x00000FF0;	// LED off 

	Clock_Init();			// interrupt 0						   
	I2C_Init();				// interrupt 1
	UART0_Init();			// interrupt 2
   	ADC_Init();				// interrupt 3, channel 0

	for (n=0; n<4; n++) NNs[n].active = 0;
//	ne: front-low, front-high, back-low, back-high.
	for (n=0; n < 2; n++)
	{
		for (i=0; i < 4; i++)
		{
			Leds[n][0][i].data    = 0; 
			Leds[n][0][i].level   = 0;
			Leds[n][1][i].data    = 0; 
			Leds[n][1][i].level   = 0;
		}
	}
	for (i=0; i < 4; i++)
	{
		Leds[0][0][i].address = 0xF7; // Front 1-15
		Leds[0][1][i].address = 0xFB; // Front 16-31
		Leds[1][0][i].address = 0xFD; // Back 101-115
		Leds[1][1][i].address = 0xFE; // Back 116-129
	}

	Sky[ 0].address  = 0x76;  Sky[ 0].data 	 = 0; Sky[ 0].level   = 0x00;
	Sky[ 1].address  = 0x74;  Sky[ 1].data 	 = 0; Sky[ 1].level   = 0x00;
	Sky[ 2].address  = 0x74;  Sky[ 2].data 	 = 0; Sky[ 2].level   = 0x00;
	Sky[ 3].address  = 0x74;  Sky[ 3].data 	 = 0; Sky[ 3].level   = 0x00;
	Sky[ 4].address  = 0x74;  Sky[ 4].data 	 = 0; Sky[ 4].level   = 0x00;
	Sky[ 5].address  = 0x74;  Sky[ 5].data 	 = 0; Sky[ 5].level   = 0x00;
	Sky[ 6].address  = 0x74;  Sky[ 6].data 	 = 0; Sky[ 6].level   = 0x00;
	Sky[ 7].address  = 0x74;  Sky[ 7].data 	 = 0; Sky[ 7].level   = 0x00;
	Sky[ 8].address  = 0x74;  Sky[ 8].data 	 = 0; Sky[ 8].level   = 0x00;
	Sky[ 9].address  = 0x76;  Sky[ 9].data 	 = 0; Sky[ 9].level   = 0x00;
	Sky[10].address  = 0x76;  Sky[10].data 	 = 0; Sky[10].level   = 0x00;
	Sky[11].address  = 0x76;  Sky[11].data 	 = 0; Sky[11].level   = 0x00;
	Sky[12].address  = 0x76;  Sky[12].data 	 = 0; Sky[12].level   = 0x00;
	ClearSky();
	ClearArc();

	buffer[0] = 0x00;
	buffer[1] = 0x76;
	buffer[2] = 0x00;														   
	buffer[3] = 0x00;
	I2C_SendByte(0x70, 4, buffer);

	for (i=0; i < 8; i++)
	{
		buffer[0] = boards[i];
		I2C_SendByte(0x4E, 1, buffer);
		buffer[0] = 0xFF;
		I2C_SendByte(0x42, 1, buffer);
		I2C_SendByte(0x44, 1, buffer);
		statusBoards[i][0] = 0xFF;	
		statusBoards[i][1] = 0xFF;	
		statusBoards[i][2] = 0xFF;	
	}

	return(0);
}
/* =================================================================================== */
/* =							Driver functions									 = */
/* = ------------------------------------------------------------------------------- = */
/* = PCA 9532 IC's are used for arche and ledsky leds.								 = */
/* = De PCA 9532 is a 15-bit I2C led dimmer											 = */
/* = ------------------------------------------------------------------------------- = */
/* = clrArc		-> All leds Arche off												 = */
/* = clrSky		-> All leds sky off													 = */
/* = LedOnOff	-> 1 Led at the arche on/off										 = */
/* = SkyOnOff	-> 1 Led at the sky on/off											 = */
/* =================================================================================== */
void ClearArc(void)
{
	int index;
	for (index = 1; index <= 31; index++)
		LedOnOff(index, 0, OFF);
	for (index = 101; index <=129; index++)
		LedOnOff(index, 0, OFF);
}
/* *********************************************************************************** */
void ClearSky(void)
{
	int spaak, led;
	SkyOnOff(0, 1, 0, OFF);
	SkyOnOff(0, 2, 0, OFF);
	for (spaak = 1; spaak <= 12; spaak++)
	{
		for (led = 0; led <= 7; led++)
		{
			SkyOnOff(spaak, led, 0, OFF);
		}
	}
}
/* *********************************************************************************** */
void LedOnOff(int index, int level, int OnOff)
{
	int n, ic, led, ls, tmp;
	unsigned char buffer[4];
	int PWM1 = 0x14;	// (autoincrement (16) + register
	int LS0  = 0x06;	
	int LS1  = 0x07;	
	int LS2  = 0x08;	
	int LS3  = 0x09;
	                //   1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32}
#ifdef Fart1
	int ledsIndex[] = { 13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,15,14};
#endif

#ifdef Fart2
	int ledsIndex[] = { 16,15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17};
#endif

	// Leds at the front are numbered from 1..32
	// Leds at the back are numbered from 101..132
	if (index > 100) led = index - 100; else led = index; // Range now 1..32 
	led = ledsIndex[led-1];								  // for the electronincs
	if (led <= 16) ic = 0; else ic = 1;					  // IC 1..2
    led = led - ic*16;									  // led 1..16
	ls = (led-1)/4;										  // led selector 1..4

	if (index < 100) n = 0; else n = 1;
	buffer[0] = Leds[n][ic][ls].address;				  // address led-IC
 	I2C_SendByte(0x72, 1, buffer);   					  // load pre-selection with address

	// set level
	buffer[0] = PWM1;				// subaddress
	buffer[1] = 0;					// PSC1
	buffer[2] = level & 0xFF;
	I2C_SendByte(0xC0, 3, buffer);	// preselection determines the address of C0

	// update data
    led = (led-1) % 4;
	tmp = (0x03 << (2*(led)));  	// 11 = blink at PWM1 rate
	if (OnOff == ON)
		Leds[n][ic][ls].data |= tmp;
	else 
		Leds[n][ic][ls].data &= ~tmp;

	switch(ls)
	{
	case 0:	buffer[0] = LS0; break;
	case 1:	buffer[0] = LS1; break;
	case 2:	buffer[0] = LS2; break;
	case 3:	buffer[0] = LS3; break;
	}
	buffer[1] = Leds[n][ic][ls].data & 0xFF;
	I2C_SendByte(0xC0, 2, buffer);

	buffer[0] = 0xFF;
	I2C_SendByte(0x72,1,buffer);
		
}
/* *********************************************************************************** */
void SkyOnOff(int spaak, int led, int level, int OnOff)
{
	int tmp;
	unsigned char buffer[4];
	int PWM1 = 0x14;	// (autoincrement (16) + register
	int LS0  = 0x06;	
	int LS1  = 0x07;	

	if (spaak == 0)
	{
		buffer[0] = 0xEF;
	}
	else
	{
		if (spaak < 9)
			buffer[0] = ~(1 << (spaak-1)); 
		else
			buffer[0] = ~(1 << (spaak-9)); 
	}
 	I2C_SendByte(Sky[spaak].address, 1, buffer);  // laad pre-selectie met spaak-IC
	// set level
	buffer[0] = PWM1;	// subaddress
	buffer[1] = 0;		// PSC1
	buffer[2] = level & 0xFF;
	I2C_SendByte(0xC0, 3, buffer);
	// update data
	if (spaak == 0)
	{
		buffer[0] = LS0;
		tmp = (0x03 << (2*(led-1)));
		if (OnOff == ON)
			Sky[spaak].data |= tmp;
		else 
			Sky[spaak].data &= ~tmp;
		buffer[1] = Sky[spaak].data;
	}
	else
	{
		tmp = (0x03 << (2*(led-1)));
		if (OnOff == ON)
			Sky[spaak].data |= tmp;
		else 
			Sky[spaak].data &= ~tmp;
		if (led < 5)
		{
			buffer[0] = LS0;
			buffer[1] = (Sky[spaak].data & 0xFF);
		}
		else
		{
			buffer[0] = LS1;
			buffer[1] = ((Sky[spaak].data >> 8) & 0xFF);
		}
	}
	I2C_SendByte(0xC0, 2, buffer);
	buffer[0] = 0xFF;
	I2C_SendByte(Sky[spaak].address, 1, buffer);
}
/* =================================================================================== */
/* =					Functies voor het uitvoeren van een commando				 = */
/* = ------------------------------------------------------------------------------- = */
/* = cmdStim		-> execStim			-> Voert een stim uit buiten de FSM om       = */
/* = cmdInfo		-> getInfo			-> Geeft de string LPC2119->Monkey.........  = */
/* = cmdClock		-> getClock			-> Geeft de tijd controller in seconds		 = */
/* = cmdState		-> getState 		-> Geeft de fase (2..0) van de afzonderlijke = */
/*										   stimuli									 = */
/* = cmdStateTrial	-> getStateTrial	-> Geeft de fase waar de trial zich bevindt  = */
/* = cmdNextTrial 	-> execNextTrial	-> Start inlezen stimuli van nieuwe trial    = */
/* = cmdStartTrial	-> execStartTrial	-> Start uitvoeren van een nieuwe trial      = */
/* =================================================================================== */
void execStim()
{
 	int bit, level, n=0, i;
	int value;
	int outFlag = 0;
	switch (nBuffer[2])
	{
	case stimDin:
		value = GetBitsPar();
		value = ((parOutp << 8) | value);
		//            bitNo
		bit = (1 << nBuffer[3]-1);
		if ((value & bit) == 0) bit = 0; else bit = 1;
		n = sprintf(outBuf,"%d\n",bit);
		break;
	case stimDout:
		//            bitNo	
		bit = (1 << nBuffer[3]-1);
		level = nBuffer[4];
		if (level > 0)
		{
			SetBitsPar(bit);
			parOutp |= bit;
		}
		 else
		{ 
			ClrBitsPar(bit);
			parOutp &= ~bit;
		}
	    n = sprintf(outBuf,"%d\n",curTime);
		break;
	case stimSky:
		//          spoke       ring        int         onoff
		SkyOnOff(nBuffer[3], nBuffer[4], nBuffer[5], nBuffer[6]);
        n = sprintf(outBuf,"%d\n",curTime);
		break;
	case stimLed:
		//          Y          int         onoff
		LedOnOff(nBuffer[4], nBuffer[5], nBuffer[6]);
        n = sprintf(outBuf,"%d\n",curTime);
		break;
	case stimSelADC:
		//
//		ADC_Select(nBuffer[3]);
    	n = sprintf(outBuf,"%d\n",curTime);
		break;
	case stimADC:
		//
		getADC();
		outFlag = 1;
		break;
	default:
    	n = sprintf(outBuf,"%d\n",curTime);
		break;
	}

	if (outFlag == 0)
	{
		i = UART0_Str(outBuf, n);
		nBuffer[1] = 0;
	}
}
void getInfo()
{
	int n, i;

	n = 0;
	while ((n < 80) && (version[n] > 0)) n++;
	i = UART0_Str(version, n);
	nBuffer[1] = 0;
}
/* *********************************************************************************** */
void getClock()
{
	int val;
	int n, i;
	val = Clock_GetSeconds();
	n = sprintf(outBuf,"%d\n",val);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}
/* *********************************************************************************** */
void getState()
{
	int n, i;
	
	n = 0;
	while ((n < 80) && (state[n] > 0)) n++;
	i = UART0_Str(state, n);
	nBuffer[1] = 0;
}
/* *********************************************************************************** */
void getStateTrial()
{
	int n, i;
	
	n = sprintf(outBuf,"%d\n",MCS);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}
/* *********************************************************************************** */
void execNextTrial()
{
	int n,i;

	nStim   = 0;
	MCS     = statNextTrial;		

	n = sprintf(outBuf,"%d\n",curTime);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}
/* *********************************************************************************** */
void execStartTrial()
{
	int n,i;
//	while (Clock_GetTicks() < (T_ITI+ITI));
	T_start = Clock_GetTicks();
	T_ITI   = T_start - T_done;
	MCS = statRunTrial;
	errFlag = false;
	n = sprintf(outBuf,"%d\n",curTime);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}
/* =================================================================================== */
/* =					Functies voor het uitvoeren van een stimulus				 = */
/* = ------------------------------------------------------------------------------- = */
/* =          		-> execEvent		-> Verwerken van events					     = */
/* = stimBar		-> execBar			-> Inlezen van toestand drukknop		     = */
/* = stimSky		-> execSky			-> Led op de sky aan/uit				     = */
/* = stimLed		-> execLed			-> Led op de boog aan/uit				     = */
/* = stimRec		-> execRec			-> Start RA16 TDT circuit				     = */
/* =================================================================================== */
void execEvent(int event)
{
	int i;
	int newTime = Clock_GetTicks() - T_start;
	if (event == 99)
	{
		execError();
	}
	else
	{
		if (event != 0)
		{
		for (i = 0; i < nStim; i++) 
			{
				if (stim[i].startRef == event)
				{
					stim[i].startRef = 0;
					stim[i].startTime += newTime;
				}
				if (stim[i].stopRef == event)
				{
					stim[i].stopRef = 0;
					stim[i].stopTime += newTime;
				}
			}
		}
	}
}
/* *********************************************************************************** */
int execBar(int index)
{
	int ans = 0;
	switch(stim[index].mode)
	{
	case 0:	ans = execBarFlank(index);	break;
	case 1:	ans = execBarLevel(index);	break;
	case 2: ans = execBarCheck(index);	break;
	}
	return ans;
}
/* *********************************************************************************** */
int execBarLevel(int index)
{
	int newTime = Clock_GetTicks() - T_start;
	int	barBit  = (1 << (stim[index].bitNo-1));
	int	barEdge = stim[index].edge;
	int mode    = stim[index].mode;

	if (stim[index].status == statInit)
	{
		if (stim[index].startRef == 0)
		{
			if(curTime < stim[index].startTime)  // end off start delay ?
				return 2;
			else
			{
				stim[index].startTime = newTime;
				stim[index].status    = statRun;
				return 1;
			}
		}
		else
			return 2;
	}
	

	if (stim[index].status == statRun)
	{
		if (stim[index].stopRef == 0)			// endtime set ?
		{										// yes
			if (curTime < stim[index].stopTime)	// and reached
			{									// no
				// positive, bit must be set
				// negative, bit must be cleared
				if (((barEdge == 1) && ((parInp & barBit) == 0)) ||
				    ((barEdge == 0) && ((parInp & barBit) >  0)))
				{
					stim[index].stopTime = newTime;
					execError();
					return 0;
				}
				return 1;
			}
			else
			{
				stim[index].stopTime = newTime;
				stim[index].status   = statDone;
				execEvent(stim[index].event);
				return 0;					// exit after executing event
			}
		}
		else
		{									// no endtime
			// positive, bit must be set
			// negative, bit must be cleared
			if (((barEdge == 1) && ((parInp & barBit) ==  0)) ||
			    ((barEdge == 0) && ((parInp & barBit) >   0)))
			{
				stim[index].stopTime = newTime;
				execError();
				return 0;
			}
			return 1;
		}
	}

    return 0;
}
/* *********************************************************************************** */
int execBarCheck(int index)
{
	int newTime = Clock_GetTicks() - T_start;
	int	barBit  = (1 << (stim[index].bitNo-1));
	int	barEdge = stim[index].edge;
	int mode    = stim[index].mode;

	if (stim[index].status == statInit)
	{
		if (stim[index].startRef == 0)
		{
			if(curTime < stim[index].startTime)  // end off start delay ?
				return 2;
			else
			{
				stim[index].startTime = newTime;
				stim[index].status    = statRun;
				return 1;
			}
		}
		else
			return 2;
	}
	

	if (stim[index].status == statRun)
	{
		if (stim[index].stopRef == 0)			// endtime set ?
		{										// yes
			if (curTime < stim[index].stopTime)	// and reached
			{									// no
				// positive, bit must be set
				// negative, bit must be cleared
				if (((barEdge == 1) && ((parInp & barBit) >  0)) ||
				    ((barEdge == 0) && ((parInp & barBit) == 0)))
				{
					stim[index].stopTime = newTime;
					stim[index].status   = statDone;
					execEvent(stim[index].event);
					return 0;					// exit after executing event
				}
				return 1;
			}
			else
			{
				stim[index].stopTime = newTime;
				execError();
				return 0;
			}
		}
		else
		{									// no endtime
			// positive, bit must be set
			// negative, bit must be cleared
			if (((barEdge == 1) && ((parInp & barBit) >  0)) ||
			    ((barEdge == 0) && ((parInp & barBit) == 0)))
			{
				stim[index].stopTime = newTime;
				stim[index].status   = statDone;
				execEvent(stim[index].event);
				return 0;	// exit after executing event
			}
			return 1;
		}
	}

    return 0;
}
/* *********************************************************************************** */
int execBarFlank(int index)
{
	int newTime = Clock_GetTicks() - T_start;
	int	barBit  = (1 << (stim[index].bitNo-1));
	int	barEdge = stim[index].edge;
	int mode    = stim[index].mode;

	if (stim[index].status == statInit)
	{
		if (stim[index].startRef == 0)
		{
			if(curTime < stim[index].startTime)  // end off start delay ?
			{									 // no
				// positive flank, bit must be cleared
				// negative flank, bit must be set
				if (((barEdge == 1) && ((parInp & barBit) == 0)) ||
				    ((barEdge == 0) && ((parInp & barBit) >  0)))
				{
					return 2;
				}
				else
				{
					stim[index].startTime = newTime;
					execError();
					return 0;					// exit with error
				}
			}
			else
			{ 									// yes, start run fase
				stim[index].startTime = newTime;
				stim[index].status    = statRun;
				return 1;
			}
		}
		else
			return 2;
	}
	

	if (stim[index].status == statRun)
	{
		if (stim[index].stopRef == 0)			// endtime set ?
		{										// yes
			if (curTime < stim[index].stopTime)	// and reached
			{									// no
				// positive flank, bit must be set
				// negative flank, bit must be cleared
				if (((barEdge == 1) && ((parInp & barBit) >  0)) ||
				    ((barEdge == 0) && ((parInp & barBit) == 0)))
				{
					stim[index].stopTime = newTime;
					stim[index].status   = statDone;
					execEvent(stim[index].event);
					return 0;					// exit after executing event
				}
				else
				{
					return 1;
				}
			}
			else
			{
				stim[index].stopTime = newTime;
				execError();
				return 0;
			}
		}
		else
		{									// no endtime
			// positive flank, bit must be set
			// negative flank, bit must be cleared
			if (((barEdge == 1) && ((parInp & barBit) >  0)) ||
			    ((barEdge == 0) && ((parInp & barBit) == 0)))
			{
					stim[index].stopRef  = 0;
					stim[index].stopTime = newTime;
					stim[index].status   = statDone;
					execEvent(stim[index].event);
					return 0;					// exit after executing event
			}
			else
			{
				return 1;
			}
		}
	}

    return 0;
}
/* *********************************************************************************** */
int execSky(int index)
{																	    
	int newTime = Clock_GetTicks() - T_start;
	if (stim[index].status == statInit)
	{
		if ((stim[index].startRef == 0) && (curTime >= stim[index].startTime))
			{
				SkyOnOff(stim[index].posX, stim[index].posY, stim[index].level, ON);
				stim[index].startTime = newTime;
				stim[index].status    = statRun;
				return 1;
			}
		
		return 2;
	}
	
	if (stim[index].status == statRun)
	{
		if ((stim[index].stopRef == 0) && (curTime >= stim[index].stopTime))
		{
			SkyOnOff(stim[index].posX, stim[index].posY, stim[index].level, OFF);
			stim[index].stopTime = newTime;
			stim[index].status   = statDone;
			execEvent(stim[index].event);
			return 0;
		}
		return 1;
	}
	return 0;
}
/* *********************************************************************************** */
int execLed(int index)
{ 
	int newTime = Clock_GetTicks() - T_start;
	if (stim[index].status == statInit)
	{
		if ((stim[index].startRef == 0) && (curTime >= stim[index].startTime))
		{
			LedOnOff(stim[index].posY, stim[index].level, ON);
			stim[index].startTime = newTime;
			stim[index].status = statRun;
			return 1;
		}
		return 2;
	}
	
	if (stim[index].status == statRun)
	{
		if ((stim[index].stopRef == 0) && (curTime >= stim[index].stopTime))
		{
			LedOnOff(stim[index].posY, stim[index].level, OFF);
			stim[index].stopTime = newTime;
			stim[index].status   = statDone;
			execEvent(stim[index].event);
			return 0;
		}
		return 1;
	}

	return 0;
}
/* *********************************************************************************** */
int execRec(int index)
{
	int newTime = Clock_GetTicks() - T_start;

	if (stim[index].status == statInit)
	{
		if ((stim[index].startRef == 0) && (curTime >= stim[index].startTime))
		{
			stim[index].startTime = newTime;
			stim[index].status    = statRun;
			SetBitsPar(recBit);	  // maak trigger hoog
			parOutp |= recBit;
			return 1;
		}
		return 2;
	}
	
	if (stim[index].status == statRun)
	{
		if (curTime > stim[index].startTime+10) // geef circuit tijd om te starten
		{
			int parInp  = GetBitsPar();
			if ((parInp & recBit) == 0)         // ready
			{
				parOutp &= ~recBit;			    // trigger laag
				ClrBitsPar(recBit);
				stim[index].stopTime = newTime;
				stim[index].status   = statDone;
				execEvent(stim[index].event);
				return 0;
			}
		}
		if ((stim[index].stopRef == 0) && (curTime >= stim[index].stopTime))
		{
			parOutp &= ~recBit;			    // trigger laag
			ClrBitsPar(recBit);
			stim[index].stopTime = newTime;
			stim[index].status   = statDone;
			execEvent(stim[index].event);
			return 0;
		}
		return 1;
	}
	return 0;
}
/* *********************************************************************************** */
int execSnd(int index)
{
	int newTime = Clock_GetTicks() - T_start;

	if (stim[index].status == statInit)
	{
		if ((stim[index].startRef == 0) && (curTime >= stim[index].startTime))
		{
			stim[index].startTime = newTime;
			stim[index].status    = statRun;
			SetBitsPar(sndBit);	  
			parOutp |= sndBit;
			return 1;
		}
		return 2;
	}
	
	if (stim[index].status == statRun)
	{
		if ((stim[index].stopRef == 0) && (curTime >= stim[index].stopTime))
		{
				ClrBitsPar(sndBit);	 
				parOutp &= ~sndBit;
				stim[index].stopTime = newTime;
				execError();
		}
		if ((parInp & sndBit) == 0)
		{
			if (newTime > (stim[index].startTime+10))
			{
				ClrBitsPar(sndBit);	 
				parOutp &= ~sndBit;
				stim[index].stopTime = newTime;
				stim[index].status   = statDone;
				execEvent(stim[index].event);
				return 0;
			}
		}
		return 1;
	}
	return 0;
}

void loadNNMod() {
	int i, n, pnt;

    pnt = (int) rBuffer[1];
	switch (pnt)
	{
		case 0: NetNum = (int) rBuffer[3];
				NNs[NetNum].active  = 0;
				NNs[NetNum].nInput  = (int) rBuffer[4];
				NNs[NetNum].nHidden = (int) rBuffer[5];
				for (i=0;i<NNs[NetNum].nInput;i++) NNs[NetNum].channels[i] = (int) rBuffer[6+i];
				break;
		case 11:for (i=0;i<NNs[NetNum].nHidden;i++) NNs[NetNum].weightsHidden[0][i] = rBuffer[3+i]; 
				break;
		case 12:for (i=0;i<NNs[NetNum].nHidden;i++) NNs[NetNum].weightsHidden[1][i] = rBuffer[3+i]; 
				break;
		case 13:for (i=0;i<NNs[NetNum].nHidden;i++) NNs[NetNum].weightsHidden[2][i] = rBuffer[3+i]; 
				break;
		case 14:for (i=0;i<NNs[NetNum].nHidden;i++) NNs[NetNum].weightsHidden[3][i] = rBuffer[3+i]; 
				break;
		case 15:for (i=0;i<NNs[NetNum].nHidden;i++) NNs[NetNum].weightsHidden[4][i] = rBuffer[3+i]; 
				break;
		case 16:for (i=0;i<NNs[NetNum].nHidden;i++) NNs[NetNum].weightsHidden[5][i] = rBuffer[3+i]; 
				break;
		case 2: for (i=0;i<NNs[NetNum].nHidden;i++) NNs[NetNum].weightsOutput[i]    = rBuffer[3+i]; 
				break;
		case 3: for (i=0;i<NNs[NetNum].nHidden;i++) NNs[NetNum].biasHidden[i]       = rBuffer[3+i]; 
				break;
		case 4: NNs[NetNum].biasOutput = rBuffer[3];
				n = 4; 
				for (i=0;i<NNs[NetNum].nInput;i++)	NNs[NetNum].scaleInput[i][0]    = rBuffer[n+i];
				n = n + NNs[NetNum].nInput;
		        for (i=0;i<NNs[NetNum].nInput;i++)	NNs[NetNum].scaleInput[i][1]    = rBuffer[n+i];
				n = n + NNs[NetNum].nInput;
		        NNs[NetNum].scaleOutput[0] = rBuffer[n];
		        NNs[NetNum].scaleOutput[1] = rBuffer[n+1];
				NNs[NetNum].active  = 1;
				break;
	}
	n = sprintf(outBuf,"Loaded net:%d\n",NetNum);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}	

double tansig(double d)
{
    double e = 2.71828;
    return (2.0/(1.0+pow(e,-2.0*d))-1.0);
}

double simulateNN(int mode)
{
	int i, n, nn, nh, id1=0, id2=0, lp;
	double temp, test[6], val, values[4];
	double inp[6];
	unsigned int t0=Clock_GetTicks();

	int id = mode;
	if (mode == -1)id = (int) rBuffer[1];
	if (id <  0) {id1 = 0;  id2 = 3;}
	if (id > -1) {id1 = id; id2 = id;}
	if (id == -1)
	{
		id1 = 0;
		id2 = 3;
	}
	else
	{
		id1 = id;
		id2 = id;
	}

	val = 0;
	for (i=0; i<4; i++) values[i] = 0;
	for (lp=id1; lp<=id2; lp++)
	{
		if (NNs[lp].active == 1)
		{
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
			values[lp] = val;
		}
		else
		{
			val = 0;
			values[lp] = val;
		}
	}
	if (mode > -1)
	{
		return val;
	}
	t0= Clock_GetTicks() - t0;
	n = sprintf(outBuf,"%d ",t0); 
	if (id > -1)
	{
		for (i=0;i<NNs[id].nInput;i++)
		{
			n += sprintf(outBuf+n," %f",inp[i]);
		}
		n += sprintf(outBuf+n," %f\n",val);
	}
	else
	{
		for (i=0;i<3;i++)
		{
			n += sprintf(outBuf+n," %f",values[i]);
		}
		n += sprintf(outBuf+n," %f\n",values[3]);
	}

	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
	return 0;
}

int execFixWnd(int index)
{
	int newTime = Clock_GetTicks() - T_start;
	int id = stim[index].index;

	if (stim[index].status == statInit)
	{
		if ((stim[index].startRef == 0) && (curTime >= stim[index].startTime))
		{
			testFixWnd(index);
			stim[index].startTime = newTime;
			stim[index].status    = statRun;
			return 1;
		}
		fixWindows[id].fix = 0;
		return 2;
	}

	if (stim[index].status == statRun)
	{
		if ((stim[index].stopRef == 0) && (curTime >= stim[index].stopTime))
		{
			stim[index].stopTime = newTime;
			stim[index].delay    = fixWindows[id].time;
			execError();
			return 0;
		}
		else
		{
			if (testFixWnd(index) == 1)
			{
				stim[index].stopTime = newTime;
				stim[index].status   = statDone;
				stim[index].delay    = fixWindows[id].time;
				execEvent(stim[index].event);
				return 0;
			}
			return 1;
		}
	}
	return 0;
}

int testFixWnd(int index)
{
	int n;

	int time;
	double Xm    = (double) stim[index].posX;
	double Ym    = (double) stim[index].posY;
	double Sx    = (double) stim[index].winX;
	double Sy    = (double) stim[index].winY;
	int id    = stim[index].index;
	int fix   = fixWindows[id].fix;
	int t0    = fixWindows[id].t0;
	int nx    = fixWindows[id].Xnet;
	int ny    = fixWindows[id].Ynet;
	double Xh = (double) fixWindows[id].Xh/10.0;  // to use integers, the value
	double Yh = (double) fixWindows[id].Yh/10.0;  // was multiplied by 10
	double x  = simulateNN(nx);
	double y  = simulateNN(ny);
 
	if (fix == 1)
	{
		if ((x > (Xm-Sx-Xh)) && (x < (Xm+Sx+Xh)) &&
		    (y > (Ym-Sy-Yh)) && (y < (Ym+Sy+Yh)))
		{
			time = curTime-t0;
		}
		else
		{
			time = 0;
			fix  = 0;
		}
	}
	else
	{
		time = 0;
		if ((x > (Xm-Sx+Xh)) && (x < (Xm+Sx-Xh)) &&
		    (y > (Ym-Sy+Yh)) && (y < (Ym+Sy-Yh)))
			{
				fixWindows[id].t0 = curTime;
				fix  = 1;
			}
	}

	if (time > fixWindows[id].time)
		fixWindows[id].time = time;
	fixWindows[id].fix  = fix;

	if (time > stim[index].delay) n = 1; else n = 0;
	return n;
}
/****************************************************************************
Procedure "execSpeed" is left after:
1/ The stop time is exceeded.
2/ The desired speed is reached.

Procedure:
1/ The average of 10 samples is taken for the AD values,
   (For 8 channels, this gives a sample rate of 5 kHz.),
2/ A new calculation is started every mSec:
	a/ Netwerk is used for the calculation of the X and Y position 
	   (position in degrees NNx, NNy).
*****************************************************************************/
double X[5], Y[5];
double range[11];
int execSpeed(int index)
{
	int i, nx, ny;
	int newTime = Clock_GetTicks() - T_start;
	double NNx, NNy, d1, d2;

	if (stim[index].status == statInit)
	{
		if ((stim[index].startRef == 0) && (curTime >= stim[index].startTime))
		{
			stim[index].startTime = newTime;
			stim[index].status    = statRun;
			pntNN = 0;
			speed[0] = 0;
			speed[1] = 0;
			return 1;
		}
		return 2;
	}

	if (stim[index].status == statRun)
	{
		if ((stim[index].stopRef == 0) && (curTime >= stim[index].stopTime))
		{
			stim[index].stopTime = newTime;
			execError();
			return 0;
		}
		nx = stim[index].mode & 3;
		ny = ((stim[index].mode & 12) >> 2);
		X[pntNN] = Clock_GetTicks() - T_start;
		NNx = simulateNN(nx)-stim[index].posX;
		NNy = simulateNN(ny)-stim[index].posY;
		NNy = 0;
		Y[pntNN] = NNx*NNx+NNy*NNy;
		if (Y[pntNN] > 0) Y[pntNN] = sqrt(Y[pntNN]);
		pntNN++;
		if (pntNN == 5)
		{
			calculateSpeed();
			pntNN = 4;
			range[0] = X[0]-X[0];
			range[1] = X[1]-X[0];
			range[2] = X[2]-X[0];
			range[3] = X[3]-X[0];
			range[4] = X[4]-X[0];
			range[5] = Y[0];
			range[6] = Y[1];
			range[7] = Y[2];
			range[8] = Y[3];
			range[9] = Y[4];
			range[10] = X[4]-X[0];
			for (i=1; i<5; i++)
			{
				X[i-1] = X[i];
				Y[i-1] = Y[i];
			}
		}
		d1 = 1000.0*speed[0]/range[10];
		range[10] = d1;
		d2 = stim[index].level;
		if (d1 < d2)
		{
			stim[index].stopTime = newTime;
			stim[index].status   = statDone;
			execEvent(stim[index].event);
			return 0;
		}
		return 1;
	}

	return 0;
}

void calculateSpeed(void)
{
	double slope;
    double X1[5], sumX, sumY, sumXY, sumXX, meanX, meanY;
	int    n;
	// FIT
    sumX = 0; sumY = 0; sumXY = 0; sumXX = 0;
	for (n=0;n<5;n++) 
	{
		X1[n] = X[n] - X[0];
	}
	X1[0] = 0;
	for (n=0;n<5;n++)
	{
    	sumX  = sumX  + X1[n];
	    sumY  = sumY  + Y[n]; 
    	sumXY = sumXY + X1[n]*Y[n];
	    sumXX = sumXX + X1[n]*X1[n];
    	meanX = sumX/5.0;
	    meanY = sumY/5.0;
	}							   	
	slope = (5.0*sumXY-sumX*sumY)/(5.0*sumXX-sumX*sumX);
	speed[0] = slope;
	speed[1] = meanY -(slope*meanX);
	// FIT                
}

void getSpeed()
{
	int i, n;
	double slope, offset;

	slope  = speed[0];
	offset = speed[1];

	n = sprintf(outBuf,"%f %f %f %f %f %f %f %f %f %f %f %f %f\n",slope,offset,range[0],range[1],range[2],range[3],range[4],range[5],range[6],range[7],range[8],range[9],range[10]);
 	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}

