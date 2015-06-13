#include "StdAfx.h"
#include "Experiment.h"

static Stims_Record stims[10];

CExperiment::CExperiment(void)
{
	CreateExperiment();
}
CExperiment::~CExperiment(void)
{
}
void CExperiment::CreateExperiment()
{
	//-> bar is not pressed
	stims[0].stim     = stimBar;
	stims[0].start[0] =    0;
	stims[0].start[1] =    0;
	stims[0].stop[0]  =    1;
	stims[0].stop[1]  =    0;
	stims[0].bitno    =    0;
	stims[0].mode     =    2;		// check
	stims[0].edge     =    0;		// not used
	stims[0].level    =    0;      	// low, not pressed
	stims[0].Event    =    1;
	stims[0].status   = statInit;
	//-> bar pressed
	stims[1].stim     = stimBar;
	stims[1].start[0] =    1;
	stims[1].start[1] =    0;
	stims[1].stop[0]  =    2;
	stims[1].stop[1]  =    0;
	stims[1].bitno    =    0;
	stims[1].mode     =    0;		// flank
	stims[1].edge     =    1; 		// rising
	stims[1].level    =    0;		// not used
	stims[1].Event    =    2;
	stims[1].status   = statInit;
	//-> fixation led
	stims[2].stim     = stimLed;
	stims[2].start[0] =    2;
	stims[2].start[1] =	   0;
	stims[2].stop[0]  =    2;
	stims[2].stop[1]  =  100;		// set here fixation time
	stims[2].pos[0]   =    0;
	stims[2].pos[1]   =    0;
	stims[2].index    =    1;		// red
	stims[2].level    =    7;
	stims[2].Event    =    3;
	stims[2].status   = statInit;
	//-> target led
	stims[3].stim     = stimLed;
	stims[3].start[0] =    3;
	stims[3].start[1] =	   0;
	stims[3].stop[0]  =    3;
	stims[3].stop[1]  =  1000;		// set here target fixed time (static sound period)
	stims[3].pos[0]   =    3;
	stims[3].pos[1]   =    3;
	stims[3].index    =    0;		// green
	stims[3].level    =    7;
	stims[3].Event    =    4;
	stims[3].status   = statInit;
	//-> target led, changed intensity
	stims[4].stim     = stimLed;
	stims[4].start[0] =    4;
	stims[4].start[1] =	   0;
	stims[4].stop[0]  =    4;
	stims[4].stop[1]  =  1000;		// set here target changed time (dynamic sound period)
	stims[4].pos[0]   =    3;
	stims[4].pos[1]   =    3;
	stims[4].index    =    0;		// green
	stims[4].level    =    5;
	stims[4].Event    =    0;
	stims[4].status   = statInit;
	//-> bar keep pressed
	stims[5].stim     = stimBar;
	stims[5].start[0] =    2;
	stims[5].start[1] =   10;
	stims[5].stop[0]  =    4;
	stims[5].stop[1]  =  100;		// minimal reaction time, guess?
	stims[5].bitno    =    0;
	stims[5].mode     =    1;		// hold state
	stims[5].edge     =    0;		// not used
	stims[5].level    =    1; 		// high, pressed
	stims[5].Event    =    0;
	stims[5].status   = statInit;
	//-> bar is released
	stims[6].stim     = stimBar;
	stims[6].start[0] =    4;
	stims[6].start[1] =    0;
	stims[6].stop[0]  =    4;
	stims[6].stop[1]  = 1000;		// set here target changed time (dynamic sound period)
	stims[6].bitno    =    0;		
	stims[6].mode     =    0;		// flank
	stims[6].edge     =    0; 		// falling
	stims[6].level    =    0;		// not used
	stims[6].Event    =    5;
	stims[6].status   = statInit;
	//-> reward after bar pressed
	stims[7].stim     = stimRew;
	stims[7].start[0] =    2;
	stims[7].start[1] =    0;		// delay
	stims[7].stop[0]  =    2;
	stims[7].stop[1]  =    5;		// dummy
	stims[7].bitno    =    1;
	stims[7].mode     =    1;		// high puls	
	stims[7].Event    =    0;
	stims[7].status   = statInit;
	//-> start sound
	stims[8].stim     = stimBit;
	stims[8].start[0] =    3;
	stims[8].start[1] =    0;
	stims[8].stop[0]  =    5;
	stims[8].stop[1]  =    5;
	stims[8].bitno    =    0;
	stims[8].mode     =    1;		// high puls
	stims[8].Event    =    0;
	stims[8].status   = statInit;
	//-> reward after bar released
	stims[9].stim     = stimRew;
	stims[9].start[0] =    5;
	stims[9].start[1] =    0;		// delay
	stims[9].stop[0]  =    5;
	stims[9].stop[1]  =    5;		// duration 100 (subtract delay)
	stims[9].bitno    =    1;
	stims[9].mode     =    1;		// high puls	
	stims[9].Event    =    0;
	stims[9].status   = statInit;
}
Stims_Record *CExperiment::getStimRecord(int index)
{
	return &stims[index];
}
