/**************************************************************************************
Project:	HumanV1	-> 20-06-07
Subject:	Globals
Start:		DJH		-> 21-06-07	version 1.0	
***************************************************************************************/

#pragma once
/**************************************************************************************
								C O N S T A N T S
***************************************************************************************/
const CString DefFile   = "C:\\HumanV1\\HumanV1.def";
const CString rcoRA16_1 = "C:\\HumanV1\\RPvdsEx\\Remmel_8Channels_Ra16_1.rco";
const CString rcoRP2_1  = "C:\\HumanV1\\RPvdsEx\\hrtf_2Channels_rp2.rco";
const CString rcoRP2_2  = "C:\\HumanV1\\RPvdsEx\\hrtf_2Channels_rp2.rco";

#define SPACE			32
#define ESCAPE			27
#define ENTER			13
#define TAB				 9

#define	penBlack	 0x000
#define	penWhite	 0xFFF
#define	penRed		 0xF00
#define	penGreen	 0x0F0
#define	penBlue		 0x00F

#define MaxStim		  20000
#define MaxTrials	   2000
#define MaxDataRA16  100000 //  8 channels    (100 sec)
#define MaxDataRP2	1000000 //  1 channel/RP2 ( 20 sec)
/**************************************************************************************
									S T R U C T U R E S
***************************************************************************************/
typedef struct
{
	int		fase;     // idle, next, save, wait, collect, abort, ready
	bool	ready;
	bool	abort;
	int		curTrial;
	int		lastTrial;
	int		preX;
	int		preY;
}TRIAL_STATUS;

typedef struct
{
	char	version[132];
	int		status;
	char	RP2_1_Filename[132];
	char	RP2_2_Filename[132];
	char	RA16_Filename[132];
	int		ADC[8][3];
	int		level1;
	int		level2;
	bool	Acq18;	   // er moeten kanalen worden gemeten
	bool	Acq;       // er is data ingelezen
	bool	Inp12[2];  // input is actief
	bool    Dat12[2];  // er is data ingelezen
	bool	CFGselect[8];
}TDT3_Record;

typedef struct
{
	char	version[132];
	int		status;
	int		error;
	float	position;
	float	target;
	DWORD	speed;
}Motor_Record;

typedef struct
{
	char	version[132];
	char	micro[132];		// version program micro controller
	int		status;
	int		ITI;
	int		nStim;
}Micro_Record;

typedef struct
{
	char	version[132];
	int		MaxData;
	int		SampleRate;
	bool	PlotYT;
	bool	bRaster;
	bool	plChannels[8];
	int		plYX[2];
	double	yValue[8];
	int		XaxisRange[2];
	bool	Apply;
	bool	CFGselect[8];
}Scope8_Record;

typedef struct
{
	char	version[132];
	int		MaxData;
	int		SampleRate;
	bool	PlotYT;
	bool	bRaster;
	bool	plChannels[2];
	double	yValue[2];
	int		XaxisRange[2];
	bool	Apply;
}Scope2_Record;


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
	int event;		//								 x		 x
	// led en sky zijn gelijk
	// Inp2 = Inp1, snd = snd1 = snd2
	// om compatible te zijn met oude exp file's wordt snd gelijk aan snd1
	// voor width wordt bij acq het aantal samples verwacht en terug gegeven
} recStim;

enum
{
	Trial_idle, 
	Trial_next, 
	Trial_save, 
	Trial_wait_busy, 
	Trial_wait_not_busy, 
	Trial_collect, 
	Trial_abort, 
	Trial_ready
};

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

enum			
{
	enLogMap,	// configuration wordt niet meer gebruikt (4-feb-08)
	enDatMap,
	enExpMap,
	enSndMap,
	enRP2_1,
	enRP2_2,
	enRA16_1,
	enADC1,
	enADC2,
	enADC3,
	enADC4,
	enADC5,
	enADC6,
	enADC7,
	enADC8,
	enTrials,	// experiment
	enRandom,
	enRepeats,
	enITI,
	enNextTrial,
	enMotor,
	enSky,
	enINP1,
	enINP2
};

typedef struct
{
	RECT posMain;
	RECT posMicro;
	RECT posTDT3;
	RECT posMotor;
	RECT posScope2;
	RECT posScope8;
}T_POS_Record;

typedef struct
{
	CString	DatMap;
	CString	ExpMap;
	CString	SndMap;
	CString	RP2_1;
	CString	RP2_2;
	CString	RA16_1;
	bool	errors;
}CFG_Record;

typedef struct
{
	CString Filename;
	int		Trials;
	int		Random;
	int		Repeats;
	int		ITI[2];
	int		Found;
	bool	errors;
}EXP_Record;

//---------------- Plot layout
typedef struct
{
	float	XX0, XY0;
	float	YX0, YY0;
	float	XL, YL;
	float	xLow, xHigh;
	int		xTicks;
	float   xLength;
	float	xMult;
	bool	showXscale;
	float	yLow, yHigh;
	int		yTicks;
	float	yLength;
	float	yMult;
	bool	showYscale;
}AXISDATA;

typedef struct
{
	char RIFF_ID[5];		// RIFF
	int  RIFF_Size;			
	char WAVE_ID[5];		// WAVE
	int  WAVE_Size;			// no chunk size
	char FMT_ID[5];			// fmt
	int  FMT_Size;
	char DATA_ID[5];		// data
	int  DATA_Size;
	short fmt_Tag;			// 1 = PCM
	short fmt_Channels;
	int	  fmt_Samples;		// Samples per Second
	int	  fmt_Byte;			// Bytes per Second
	short fmt_Block;		// Block Align
	short fmt_Bits;			// Bits per Sample (8 or 16)
}T_wavHeader;

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
	cmdDataMicro,
	cmdDataInp1,
	cmdDataInp2,
	cmdClrWavInfo
};

typedef struct
{
	int index;
	int delay;
	char Snd_Filename[132];
}T_wavFile;