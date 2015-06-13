/*************************************************************************
						Global.h
**************************************************************************/
#ifndef __Globals__
#define __Globals__
#define Micro
//#define Fart1
#define Fart2

/* Special keys */
#define SPACE			32
#define ESCAPE			27
#define ENTER			13
#define LF				10
#define TAB				 9				

#define	false			0
#define	true			1
#define OFF				0
#define ON				1
#define LOW				0
#define HIGH			1

#define MaxStim			20000
#define MaxTrials		 2000
/* Outputs */
#define outClock		0x01

/* Inputs */
#define inpDummy1		0x01

#ifdef PC
typedef struct
{
	int clock;
	int value;
	int status;
}MICRO_STATUS;

typedef struct
{
	int		fase;     // Trial_xxx, nFase micro
	bool	ready;
	bool	abort;
	int		curTrial;
	int		lastTrial;
	int		preX;
	int		preY;
}TRIAL_STATUS;

typedef struct
{
	CString Filename;
	int		ITI;			// inter trial interval
	int		Trials;			// maximal number of trials
	int		Repeats;		// repeating data in exp. file
	int		Random;			// 0-No, 1-per set, 2-over all sets
	int		Found;			// number of trials found in .exp
	bool	errors;			// number of errors found in .exp 
	CString LastError;
}EXP_Record;
#endif

enum
{
	Trial_idle,				//- No trial is executed
	Trial_next,				//- Prepare nect trial
	Trial_run,				//-	Trial is executed
	Trial_abort, 			//-	Abort trial
	Trial_reward,			//-	A reward is given (puls)
	Trial_error,			//-	Error, wait as long as the reward time 
	Trial_ready,			//-	Trial ready, data can be collected
	Trial_collect, 			//-	Collect results
	Trial_save, 			//-	
	Trial_wait_busy, 		//-
	Trial_wait_not_busy, 	//-
};
/* Commands */
enum
{
	cmdStim = 100,
	cmdInit,		//- Initialise micro
	cmdWin,
	cmdSpd,
	cmdInfo,		//- geeft de string LPC2119 terug
	cmdClock, 		//- geeft de tijd in seconden na het resetten micro, of na OnGo
	cmdClrClock,	//- 
	cmdState,		//- geeft de toestand van het experiment
	cmdNextTrial,	//- start uitvoeren van een nieuwe trial
	cmdStartTrial,	//- 
	cmdSaveTrial,	//- 110
	cmdStateTrial,	//- init, .., done
	cmdReset,		//- zet results op nul, en neem nieuwe starttijd
	cmdClrTime,		//- clock wordt op nul gezet
	cmdAbort,		//- 
	cmdReward,		//- manual reward (gebuik laatst opgegeven hoeveelheid
	cmdTime, 		//- geeft de tijd in mSec na het starten van een trial
	cmdBar,	  		//- geeft level bar en tijd in seconden
	cmdADC,
	cmdSelADC,
	cmdPin,			//- 120
	cmdSpeaker,		//- Selecteer speaker
	cmdNNMod,		//- Model Neuraal netwerk 
	cmdNNSim,		//- Simuleren NN
	cmdFixWnd,		//- Initialiseren van een fixatie window
	cmdSpeed
};

enum
{
	cInit = 200,//- Initialiseren micro
	cInfo,		//- geeft de string LPC2119 terug
	cStatus,	//- geeft de toestand, tijd van het experiment
 	cTime,		//- geeft de tijd in msec na het starten van een nieuwe trial
	cClock, 	//- geeft de tijd in seconden na het resetten micro, of na OnGo
	cClrTime,	//- trial clock wordt op nul gezet
	cClrClock,	//- seconde clock wordt op nul gezet
	cTrial,		//- start uitvoeren van een nieuwe trial
	cResults,	//- geeft #trials, #rewards en laatste reactie tijd
	cReset,		//- zet results op nul, en neem nieuwe starttijd
	cParam,		//- parameters van een trial (recMicro)
 	cTime,		//- geeft de tijd in msec na het starten van een nieuwe trial
	cClock, 	//- geeft de tijd in seconden na het resetten micro
	cClrTime,	//- trial clock wordt op nul gezet
	cClrClock,	//- seconde clock wordt op nul gezet
	cClrSky,    //- alle leds uit
	cSetSky,   	//- alle leds met intensiteit 100
	cReward,	//- manual reward (gebuik laatst opgegeven hoeveelheid
	cNewTrial,
	cStart,
	cDataMicro
};
/* script, functions */
enum
{
	scrNextTrial,
	scrITI,
	scrTrials,
	scrRepeats,
	scrRandom,
	scrBar,
	scrFix,
	scrTar,
	scrDim,
	scrRew,
};
/* stimuli */
enum
{
	stimDin = 1,
	stimDout,
	stimBar,
	stimSky,
	stimLed,
	stimFix,
	stimTar,
	stimDim,
	stimRew,
	stimRec,
	stimSnd1,
	stimSnd2,
	stimSelADC,
	stimADC,
	stimLas,
	stimErr,
	stimFixWnd,
	stimSpeed
};

enum
{
	statInit = 1,
	statNextTrial,
	statRunTrial,
	statDoneTrial,
	statDone,
	statError,

	statTrial,
	statWait,
	statITI,
	statRun,
	statAbort,
	statDone,
	statWaitPC,
	statResults																																												   
};

typedef struct
{
	int address;
	int data;
	int level;
} recLedIC;

typedef struct
{
	int ITI;
	int reward;		// klep-open-tijd
	int fixLed[3];	// spoke, ring, intensity (sri)
	int tarLed[3];
	int dimLed[3];
	int nStim;
}RECMICRO;

typedef struct
{
	int trial;		// belongs to trial
	int status;		// status stimulus: init, run, done (/aborted)
					// led	acq		Inp1	snd		trg0	trg		opm
					//  7    2       2		 8		 6		 6
	int kind;		//	x	 x		 x		 x		 x		 x		kind of stimuli							
	int index;		//			     		 						wav file =sndxxxx.wav xxxx=index
	int edge;		//								 x		 x		0-down, 1=up
	int bitNo;		//								 x		 x
	int posX;		//	x					 x
	int posY;		//	x					 x
	int level;		//	x					 x
	int startRef;	//	x	 x		 x		 x		 x		 x
	int startTime;	//	x	 x		 x		 x		 x		 x
	int stopRef;	//	x	     
	int stopTime;	//	x	 	 
	int width;		//		 x		 x				 x
	int delay;
	int event;		//								 x		 x
	int mode;
	int winX;
	int winY;
	// led en sky zijn gelijk
	// Inp2 = Inp1, snd = snd1 = snd2
	// om compatible te zijn met oude exp file's wordt snd gelijk aan snd1
	// voor width wordt bij acq het aantal samples verwacht en terug gegeven
}recStim;

typedef struct
{
	int active;
	int nInput;
	int nOutput;
	int nHidden;
	int channels[6];
	double scaleInput[6][2];
	double scaleOutput[2];
	double biasHidden[20];
	double biasOutput;
	double weightsHidden[6][20];
	double weightsOutput[20];
}NNMOD;

typedef struct
{
	int fix;		// 0=No, 1=Yes
	int t0;			// start fixatie
	int	Xnet;		// netwerk (0..3) used for simulation X direction
	int Ynet;   	// netwerk (0..3) used for simulation Y direction
	double Xh;		// hysteresis X
	double Yh;		// hysteresis Y
	int time;		// elapsed time current fixation
}FIXWND;

typedef struct 
{
	double	data[8][11];
	int     select[8];    // 0 = not selected, 1 = selected
} adc_buffer;

#endif