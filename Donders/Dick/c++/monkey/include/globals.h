/********************************************************************/
/*							globals.h								*/
/********************************************************************/
#define SPACE		32
#define ESCAPE		27
#define SP			20
#define CR			13
#define LF			10
#define TAB			 9

#define sampleRate	48828.125

#define stimLed         10		//=> stimuli
#define stimBar			11		//-> bit input
#define stimBit			12		//-> bit output
#define stimRew         13		//-> reward with delay
#define cmdGetStatus   101		//=> commando's FSM
#define cmdSetClock    102		
#define cmdGetClock    103
#define cmdNextTrial   104	
#define cmdStartTrial  105
#define cmdResultTrial 106
#define cmdAbortTrial  107
#define cmdSetPIO      108
#define cmdGetPIO      109
#define cmdSetBit      110
#define cmdClrBit      111
#define cmdGetLeds     112
#define cmdTestLeds    200
// stimulus status 
#define statError        9
#define statInit	     2
#define statRun          1
#define statDone         0

#define stateInitTrial   0
#define stateNextTrial   1
#define stateRunTrial    2
#define stateDoneTrial   3
#define stateAbortTrial  4

#define	penBlack 0x000
#define penGray  0x555
#define	penWhite 0xFFF
#define	penRed	 0xF00
#define	penGreen 0x0F0
#define	penBlue	 0x00F

#define pi 3.14159265358979323846

#ifndef GLOBALS
typedef struct
{
	int kind;			// 1-data, 2-prot, 3-all
	int ok;				// IDOK, IDCANCEL
	int nTrials;
	CString data;
	CString prot;
	CString cfg;
	CString log;
}Files_Record;
typedef struct
{
	int stim;
	int bitno;				// connected to
	int mode;			    // Bar(bit): 0->flank, 1->level, 2->check level
	int edge;				//    flank: 0->falling, 1->rising 
	int index;				// sound file name snd'index'.wav
							// led color: 0-green, 1-red
	int pos[2];				// x,y or ring,spoke
	int level;				// led intensity, sound volume
						    // Bar(bit): 0->low, 1->high
	int start[2];			// event + offset
	int stop[2];
	int latency;			// latency reward
	int duration;			// duration reward
							// TDT3 reward circuit uses both
	int Event;				// event
	int status;
}Stims_Record;
typedef struct
{
	int Fixation;			// fixation time
	int TargetFixed;		// target fixed time
	int TargetRandom;		// target random time
	int TargetChanged;		// target changed time
	int RandomTarget;		// fixed + Random
	int ReactFrom;			// Range valid reaction time
	int ReactTo;			// 100..700
}Param_Timing_Record;
typedef struct
{
	int Minimum;			// low led ring
	int Maximum;			// high led ring
	int Fixation;			// intensity fixation led
	int Target;				// intensity target led
	int TargetChanged;		// intersity after change
	int PerChanged;			// percentage target intensity
							// is changed
	bool FixRed;			// color fixation is red
	bool TarRed;			// color target is red
	bool FixTar;			// position fix = position target
	bool NoLed;				// leds are not used as a stimulus
}Param_Leds_Record;
typedef struct
{
	bool Press;				// reward after press 
	bool Release;			// reward after release
	int  Factor;			// release/press factor
	int  Punish;			// extra delay 
	int  Unit;			    // unit, open unit or factor*unit
	int	 Latency;			// time to wait before giving the reward
}Param_Rewards_Record;
typedef struct
{
	bool tone;
	bool noise;
	bool ripple;
	bool noSound;
	bool statDyn;
	bool dynStat;
	bool finishStimulus;
	bool abortStimuls;
}Acoustic_Main_Record;
typedef struct
{
	int	 CarrierF;	// Carrier Frequency
	int  CarrierFd;	// Delta, Random
	bool CarrierFv;	// Random active (vary)	
	int  Atten;
	int  Attend;
	bool Attenv;
	int  ModF;
	int  ModFd;	
	bool ModFv;	
	bool ModFz;	
	int  ModD;
	int  ModDd;
	bool ModDv;
}Acoustic_Main_Tone;
typedef struct
{
	int  Atten;
	int  Attend;
	bool Attenv;
	int  ModF;
	int  ModFd;	
	bool ModFv;	
	bool ModFz;	
	int  ModD;
	int  ModDd;
	bool ModDv;
}Acoustic_Main_Noise;
typedef struct
{
	int	 CarrierF;			// Carrier Frequency
	int  CarrierFd;			// Delta, Random
	bool CarrierFv;			// Random active (vary)
	int	 Atten;				// Attenuation (dB)
	int  Attend;
	bool Attenv;
	int	 ModF;				// Modulation Frequency
	int  ModFd;	
	bool ModFv;	
	bool ModFz;				// Zero, no modulation
	int	 ModD;				// Modulation Depth
	int  ModDd;
	bool ModDv;
	int  Density;			// ripple density 
	int  Densityd;			// delta
	bool Densityv;			// vary
	int  Spectral;			// velocity
	int  Tones;
	int  Octaves;			// ncomponents=nTones*nOctaves
	int  Phase;				// Ripple Phase at F0
	bool Freeze;			// no random phase f > F0
}Acoustic_Main_Ripple;
typedef struct
{
// parameters
	int	 numTrial;
	int  fix[5];			// ring,spoke,color,intensity,onTime
	int  tar[5];
	int  dim[5];
	bool led;
	bool snd;
	int	 sndType;
	int  carrier;
	int  modF;
	int  modD;
	int  atten;
	int  density;
// score
	int  result[3];			// timing: fix, tar, dim
	int  cum[32];			// ring buffer containing last 32 trials
// stimuli
	int  visual[2];			// total, correct
	int  auditive[2];
	int  visAud[2];			// visual+auditory
	int  total[2];
	int  rew1;
	int  rew2;
	int	 reactTime;
}Trial_Record;
typedef struct				// Options => Testing
{						
	int Maximum;			// maximum led intensity [0..255]
	bool Red;				// true: red else green
	int Intensity;			// used led intensity [0..7]
							// max. int. is divided in 7 
							// non-linear steps
	int OnTime;				// the time the led is on
	int PIO_IN;				// 8 bits parallel input
	int PIO_OUT;			// 8 bits parallel output
}Options_Testing_Record;

typedef struct
{
	bool barActiveHigh;		// FSM: 1-active high 0-active low
}
Sundries_Record;

typedef struct
{
	Files_Record			Files;			//
	Param_Timing_Record		Parameters1;	// Timing
	Param_Leds_Record		Parameters2;	// Leds
	Param_Rewards_Record    Parameters3;	// Rewards
	Acoustic_Main_Record	Acoustic0;		// Main parameters
	Acoustic_Main_Tone	    Acoustic1;
	Acoustic_Main_Noise 	Acoustic2;
	Acoustic_Main_Ripple	Acoustic3;
	Options_Testing_Record	Options2;		// Testing
	Trial_Record			TrialInfo;		// Results
	Sundries_Record			Sundries;
}Settings_Record;
//---------------- Scope
typedef struct
{
	__int64	ticks;
	int		mSec;
	int 	value;
	int     color;
}TRACEPOINT;
#define maxTRACEPOINTS 1024		// has to be a power of 2

typedef struct
{
	int	num;			// number of trials
	int fixation;		// fixation duration
	int targetFixed;	// fixed part of target duration
	int targetChanged;	// changed (ripple, dimmed) target duration
	int led;			// 1- visual stimulus, 0-no vis
	int snd;			// 1- auditory stimulus, 0-no aud
	int sndType;		// sound type
	int fixIStar;		// position fixation = position target
	int ledFix;			// color fixation led
	int ledTar;			// color target led
	int intFix;			// intensity fixation led
	int intTar;			// intensity target led
	int intChanged;		// intensity changed target led
	int percChanged;	// percentage that changed target not equal fixed target (led, snd)
	int statDyn;		// 1- static followed by dynamic
	int tones;			// number of tones (max 20)
	int octaves;		// number of octaves (max 6)
	int phaseF0;		// phase F0, degrees
	int freeze;			// 1- keep phases of components
}Protocol_Record1;

typedef struct
{
	int index;			// trial number
	int tarRand;		// random part target
	int ring;
	int spoke;
	int freq;			// carrier or F0
	int modFreq;		// modulation frequency
	int modDepth;		// modulation depth (procent)
	double density;
	int atten;			// attenuation
}Protocol_Record2;

#endif
#define GLOBALS