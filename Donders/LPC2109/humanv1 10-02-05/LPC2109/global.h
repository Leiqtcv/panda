/*************************************************************************
						Global.h

Project		 	Human		DJH MBFYS CNS UMCN
--------------------------------------------------------------------------
Definitions used by the micro controller programs and 
programs running under OS XP

Versie 1.00		30-03-2006		Dick Heeren
**************************************************************************/


#define	true						0x01
#define	false						0x00
#define ON							0x01
#define OFF							0x00
 
/* Outputs */
#define outClock					0x01
#define outRP2_1					0x02
#define outRP2_2					0x04
#define outRA16						0x08

/* Inputs */
#define inpDummy1					0x01
#define inpRP2_1					0x02
#define inpRP2_2					0x04
#define inpRA16						0x08
/* with debounce circuit */
#define inpExtTrigger				0x10

/* Special keys */
#define	ESCAPE						27
#define ENTER						13

/* Commands */
enum
{
	cmdInit,
	cmdReady,
	cmdClose,
	cmdTDT3,
	cmdMicro,
	cmdScope,
	cmdMotor,
	cmdTrigger,
	cmdInfo, 			// Micro-> volgnummer + versie
	cmdNewTrial,		// + MICRO_Rec
	cmdGetPIO,
	cmdHide,
	cmdShow,
	cmdExit,
	cmdSpeakersOff,
	cmdRP2act,
	cmdRemmelData,
	cmdPlotData,
	cmdUpdateTDT3,
	cmdLoadSnd1,
	cmdLoadSnd2,
	cmdGetPos,
	cmdSetPos,
	cmdSndLevel1,
	cmdSndLevel2,
	cmdAbort,
	cmdRemmelEnable,
	cmdRemmelDisable,
	cmdGetStatus,
	cmdMoveTo,
	cmdInp1,
	cmdInp2,
	cmdResetRP2,
	cmdGetBusy,
	cmdBusy,
	cmdStart,
	cmdGoOn,
	cmdTime,
	cmdDataMicro
};

enum
{
	statInit,
	statITI,
	statTrial,
	statRun,
	statAbort,
	statDone,
	statWait,
	statWaitPC
};

enum			
{
	enLogMap,	// configuration
	enDatMap,
	enExpMap,
	enSndMap,
	enRP2_1,
	enADC1,
	enADC2,
	enADC3,
	enADC4,
	enTrials,	// experiment
	enRandom,
	enRepeats,
	enITI,
	enNextTrial,
	enRA16_1,
	enMotor

/*
	enLed,		// Stim
	enSnd,
	enAcq,
	enTrg0,
	enLogMap,	// configuration
	enDatMap,
	enExpMap,
	enRA16_1,
	enCH1,
	enCH2,
	enCH3,
	enCH4,
	enTrials,	// experiment
	enRandom,
	enRepeats,
	enITI,
	enNextTrial,
	enRA16_1,
	enMotor,
	enSky
*/
};

#ifndef __Structures__
#define __Structures__

typedef struct
{
	int trial;		// belongs to trial
	int status;		// status stimulus: init, run, done (/aborted)
					// led	acq		Inp1	snd		trg0	trg		opm
					//  7    2       2		 8		 6		 6
	int kind;		//	x	 x		 x		 x		 x		 x		kind of stimuli							
	int index;		//			     x		 						wav file =sndxxxx.wav xxxx=index
	int edge;		//								 x		 x		0-down, 1=up
	int bitNo;		//								 x		 x
	int posX;		//	x					 x
	int posY;		//	x					 x
	int level;		//	x					 x
	int startRef;	//	x	 x				 x		 x		 x
	int startTime;	//	x	 x				 x		 x		 x
	int stopRef;	//	x	     
	int stopTime;	//	x		 
	int width;		//								 x
	int event;		//								 x		 x
	// Inp2 = Inp1, snd = snd1 = snd2
	// om compatible te zijn met oude exp file's wordt snd gelijk aan snd1
} recStim;


typedef struct
{
	int address;
	int data;
	int level;
} recLedIC;

enum
{
	stimLed = 100,
	stimSnd1,
	stimSnd2,
	stimInp1,
	stimInp2,
	stimAcq,
	stimTrg0,
	stimTrial,
	stimSky,
	stimLeds,
	stimBlink,
	stimLas
};

#endif