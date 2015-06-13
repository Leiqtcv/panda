// FSM.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "FSM.h"

#include "math.h"
#include "tools.h"

#include <MMSystem.h>
#pragma comment(lib, "winmm")
//=====================================================================//
//	Hardware control
//	Leds:
//		intensity - address = 0x44, data = 0..255 (max->min)
//		red/green - address = 0X74, data red   = bit 0..2 + 4..6 = 1
//										 green = bit 4..6 + 0..2 = 1
//		central led 0x000001
//
//  Version 1.0 - 16-03-2011 - Led control
//                           - Dimming paradigm
//              - 12-09-2011 - Delayed reward. 
//								Reward circuit is now running on rp2.2
//								and stimRew is added
//				- 26-01-2012 - Speaker selection implemented
//								problem with speakers ring 5, spoke 8-12 
//
//=====================================================================//

// leds
int ledIntensity   = 0x44;  // PWM
int ledICselect    = 0x74;
int ledICdata      = 0x70;
//                          R1        R2        R3        R4        R5        ?? 
int LEDADDRESS[12][6] = {
	 /* S1 */           {0X000002, 0X002000, 0X010200, 0X030002, 0X032000, 0X040200},
	 /* S2 */           {0X000004, 0X004000, 0X010400, 0X030004, 0X034000, 0X040400},
	 /* S3 */           {0X000008, 0X008000, 0X010800, 0X030008, 0X038000, 0X040800},
	                    {0X000010, 0X010001, 0X011000, 0X030010, 0X040001, 0X041000},
	                    {0X000020, 0X010002, 0X012000, 0X030020, 0X040002, 0X042000},
	                    {0X000040, 0X010004, 0X014000, 0X030040, 0X040004, 0X044000},
	                    {0X000080, 0X010008, 0X018000, 0X030080, 0X040008, 0X048000},
	                    {0X000100, 0X010010, 0X020001, 0X030100, 0X040010, 0X050001},
	                    {0X000200, 0X010020, 0X020002, 0X030200, 0X040020, 0X050002},
	                    {0X000400, 0X010040, 0X020004, 0X030400, 0X040040, 0X050004},
	                    {0X000800, 0X010080, 0X020008, 0X030800, 0X040080, 0X050008},
	 /* S12 */          {0X001000, 0X010100, 0X020010, 0X031000, 0X040100, 0X050010}
                        };
int ledData[2][6];  // red=0, green=1
int skyData[2][12]; // intensity red/green per spoke,
					// each spoke 6 rings
// sound
int boardSelect  = 0X4E;
int muteSelect   = 0X72;
int sourceSelect = 0X40;
// 8 amplifiers per board
// mute: 1-minimum and 0-maximum volume
// source: 0-source A, 1-source B
// 0-7	board
// 8-15	mute
//                          R1        R2        R3        R4        R5        ?? 
int speakerData[12][6] = {   
	       /* S1 */      {0X00FD00, 0X00DF01, 0X00FD03, 0X00FE05, 0X00EF06, 0X00FE08},
	       /* S2 */      {0X00FB00, 0X00BF01, 0X00FB03, 0X00FD05, 0X00DF06, 0X00FD08},
	       /* S3 */      {0X00F700, 0X007F01, 0X00F703, 0X00FB05, 0X00BF06, 0X00FB08},
	                     {0X00EF00, 0X00FE02, 0X00EF03, 0X00F705, 0X007F06, 0X00F708},
	                     {0X00DF00, 0X00FD02, 0X00DF03, 0X00EF05, 0X00FE07, 0X00EF08},
	                     {0X00BF00, 0X00FB02, 0X00BF03, 0X00DF05, 0X00FD07, 0X00DF08},
	                     {0X007F00, 0X00F702, 0X007F03, 0X00BF05, 0X00FB07, 0X00BF08},
	                     {0X00FE01, 0X00EF02, 0X00FE04, 0X007F05, 0X00F707, 0X007F08},
	                     {0X00FD01, 0X00DF02, 0X00FD04, 0X00FE06, 0X00EF07, 0X00FE09},
	                     {0X00FB01, 0X00BF02, 0X00FB04, 0X00FD06, 0X00DF07, 0X00FD09},
	                     {0X00F701, 0X007F02, 0X00F704, 0X00FB06, 0X00BF07, 0X00FB09},
	        /* S12 */    {0X00EF01, 0X00FE03, 0X00EF04, 0X00F706, 0X007F07, 0X00F709}
                         };
int preBoard = 0;

#define cRed    1
#define cGreen  0


int barBit;
int barLevel; 
bool barActiveHigh = true;
int barTime;
int parInp;
int parOut;

// Trial stuff
int state;
int stateTrial;
int FSM_CMD;	// 0-idle,	  set by FSM 
				// 1-newCMD,  set by caller (request)
				// 2-Busy,	  set by FSM	(execute)
				// 3-Results, set by FSM	(if available)
CString FSM_Status = "";
int  dataRecord[32];
bool finishStimulus;
int fix, tar, dim, ITI;
int nStim;
Stims_Record stims[50];
bool loadTrial = false;
int refT0;
int trialStatus = 0; 

// clock times
int curTime;
int startTrial;
int realStart;
int preDim;
int reactionTime;
int pressTime;

char outBuf[80];
char inpBuf[80];

LARGE_INTEGER clockStart;
LARGE_INTEGER clockFreq;
LARGE_INTEGER clockStop;
LARGE_INTEGER clockElapsed;

IMPLEMENT_DYNAMIC(CFSM, CDialog)

CFSM::CFSM(CWnd* pParent /*=NULL*/)
	: CDialog(CFSM::IDD, pParent)
	, m_Status(_T(""))
{
}

CFSM::~CFSM()
{
}

void CFSM::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT1, m_Status);
	DDX_Control(pDX, IDC_CHECK2, m_BarActive);
}

BEGIN_MESSAGE_MAP(CFSM, CDialog)
	ON_WM_TIMER()
	ON_BN_CLICKED(IDC_CHECK2, &CFSM::OnBnClickedCheck2)
END_MESSAGE_MAP()
void CFSM::Start(void)
{
	AFM_openSerial(115200);
    nFSMtimer = SetTimer(1,10,0);
    AfxBeginThread( FSMThread, NULL, THREAD_PRIORITY_HIGHEST); 

	int number;
	DWORD d1;
	DWORD d2;

	clearSky();

	for (int board = 0;board < 9;board++) 
	{
		number = sprintf(&outBuf[0],"%d %d %d\r\n",boardSelect, 1, board); // board
		d1     = AFM_slaveWrite(&outBuf[0],number);
		d2     = AFM_slaveRead(&inpBuf[0], 2);
		number = sprintf(&outBuf[0],"%d %d %d\r\n",muteSelect, 1, 0XFF); // mute
		d1     = AFM_slaveWrite(&outBuf[0],number);
		d2     = AFM_slaveRead(&inpBuf[0], 2);
	}
}
BOOL CFSM::OnInitDialog()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	CDialog::OnInitDialog();
	FSM_Status = "Init";
	barActiveHigh = pnt->getSettings()->Sundries.barActiveHigh;
	m_BarActive.SetCheck(barActiveHigh);
	Start();
	return TRUE;
}
void CFSM::OnBnClickedCheck2()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	
	pnt->getSettings()->Sundries.barActiveHigh = (m_BarActive.GetCheck() == 1);
	barActiveHigh = pnt->getSettings()->Sundries.barActiveHigh;
}
void CFSM::OnTimer(UINT nTimer) 
{ 
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	int n, num;
	if (FSM_CMD == 0)
	{
		if (*pnt->getFSMcmd() == 1)
		{
			FSM_CMD = 1;
		}
	}
	if (FSM_CMD == 1)
	{
		num = pnt->getDataRecord()[0];
		for (int i = 0; i < num; i++)
			dataRecord[i] = pnt->getDataRecord()[i];
		*pnt->getFSMcmd() = 2;
		FSM_CMD = 2;
	}
	if (FSM_CMD == 2)
	{
		// running
	}
	if (FSM_CMD == 3)
	{
		num = dataRecord[0];
		for (int i = 0; i < num; i++)
			pnt->getDataRecord()[i] = dataRecord[i];
		*pnt->getFSMcmd() = 3;
		FSM_CMD = 0;
	}

	if (loadTrial)
	{
		loadTrial = false;
		for (int n=0; n<nStim; n++)
		{
			stims[n].stim     = pnt->getStimRecord(n)->stim;
			stims[n].pos[0]   = pnt->getStimRecord(n)->pos[0];
			stims[n].pos[1]   = pnt->getStimRecord(n)->pos[1];
			stims[n].start[0] = pnt->getStimRecord(n)->start[0];
			stims[n].start[1] = pnt->getStimRecord(n)->start[1];
			stims[n].stop[0]  = pnt->getStimRecord(n)->stop[0];
			stims[n].stop[1]  = pnt->getStimRecord(n)->stop[1];
			stims[n].level    = pnt->getStimRecord(n)->level;
			stims[n].bitno    = pnt->getStimRecord(n)->bitno;
			stims[n].duration = pnt->getStimRecord(n)->duration;
			stims[n].edge     = pnt->getStimRecord(n)->edge;
			stims[n].index    = pnt->getStimRecord(n)->index;
			stims[n].latency  = pnt->getStimRecord(n)->latency;
			stims[n].mode     = pnt->getStimRecord(n)->mode;
			stims[n].Event    = pnt->getStimRecord(n)->Event;
			stims[n].status   = pnt->getStimRecord(n)->status;
		}
	}

	barActiveHigh = m_BarActive.GetCheck();

	pnt->g_barLevel = barLevel;

	pnt->setTrialStatus(trialStatus);
	pnt->g_barTime  = barTime; 
	*pnt->getParInp()= parInp;
	
	for (n=0; n<12; n++)
	{
		pnt->getGreenLeds()[n] = skyData[0][n];
		pnt->getRedLeds()[n]   = skyData[1][n];
	}
	
	if (strcmp(m_Status,FSM_Status) != 0)
	{
		m_Status = FSM_Status; 
		UpdateData(false);
	}
}
int *CFSM::getDataRecord(void)
{
	return &dataRecord[0];
}
void CFSM::openValve()
{
	writeLPT1(LPTdata,0x02);
}
void CFSM::closeValve()
{
	writeLPT1(LPTdata,0);
}

//=====================================================================//
void setClock()
{
	QueryPerformanceCounter(&clockStart);
	QueryPerformanceFrequency(&clockFreq);
}
void getFrequency()
{
	QueryPerformanceFrequency(&clockFreq);
}
int getClock()
{
	QueryPerformanceCounter(&clockStop);
	clockElapsed.QuadPart = 1000*(clockStop.QuadPart - clockStart.QuadPart);
	float t = ((float)clockElapsed.QuadPart /(float)clockFreq.QuadPart);
	return (int) t;
}
//=====================================================================//
void selectSpeaker(int ring, int spoke, int source)
{
	int number, board, mute;
	DWORD d1;
	DWORD d2;

	if (ring >0)
	{
		number = sprintf(&outBuf[0],"%d %d %d\r\n",boardSelect, 1, preBoard); // board
		d1     = AFM_slaveWrite(&outBuf[0],number);
		d2     = AFM_slaveRead(&inpBuf[0], 2);
		number = sprintf(&outBuf[0],"%d %d %d\r\n",muteSelect, 1, 0XFF); // mute
		d1     = AFM_slaveWrite(&outBuf[0],number);
		d2     = AFM_slaveRead(&inpBuf[0], 2);

		board = speakerData[spoke-1][ring-1] & 0X0000FF;
		mute  = (speakerData[spoke-1][ring-1] >> 8) & 0X0000FF;
		preBoard = board;

		number = sprintf(&outBuf[0],"%d %d %d\r\n",boardSelect, 1, board);	// board
		d1     = AFM_slaveWrite(&outBuf[0],number);
		d2     = AFM_slaveRead(&inpBuf[0], 2);

		number = sprintf(&outBuf[0],"%d %d %d\r\n",sourceSelect, 1, 0X00);	// A or B
		d1     = AFM_slaveWrite(&outBuf[0],number);
		d2     = AFM_slaveRead(&inpBuf[0], 2);

		number = sprintf(&outBuf[0],"%d %d %d\r\n",muteSelect, 1, mute);	// mute
		d1     = AFM_slaveWrite(&outBuf[0],number);
		d2     = AFM_slaveRead(&inpBuf[0], 2);
	}
	
}
//=====================================================================//
void execSetPIO(int value)
{
	int val = value;
	parOut  = ~val;
	writeLPT1(LPTdata,parOut);
}
int execGetPIO(void)
{	
	int val  = readLPT1(LPTstatus);
	val &= 0xFF;
	val = val >> 3;
	val = (~val) & 0x1F;
	if ((val & 0x10) > 0)
		val &= 0x0F;
	else
		val |= 0x10;
	return val;
}
void execSetBit(int value)
{
	int val = value;
	parOut |= val;
	writeLPT1(LPTdata,parOut);
}
void execClrBit(int value)
{
	int val = ~value;
	parOut &= val;
	writeLPT1(LPTdata,parOut);
}

int getBar(void)
{
	int val = execGetPIO();
	val &= 0x01;
	return val;
}
//=====================================================================//
void execError(void)
{
	int i, n;
	int newTime = (int) (getClock() - startTrial);
	int tmp[] = {5,6,9}; 	// barL,barUp,rew2
	reactionTime = -(preDim - (newTime - realStart));
	pressTime = newTime - realStart;
	for (n = 0; n < 3; n++)	// disable bar and reward2
	{
		i = tmp[n];
		switch (stims[i].status)
		{
		case statInit:
			stims[i].start[1] = 0;
			stims[i].stop[1]  = 0;
			stims[i].status   = statError;
			break;
		case statRun:
			stims[i].stop[1] = newTime;
			stims[i].status  = statError;
			break;
		}
	}
	if (!finishStimulus) // disable all, except rew1
	{
		for (i = 0; i < nStim; i++)
		{
			if (i != 7)
			{
				switch (stims[i].status)
				{
				case statInit:
					stims[i].start[1] = 0;
					stims[i].stop[1]  = 0;
					stims[i].status   = statError;
					break;
				case statRun:
					stims[i].stop[1] = newTime;
					stims[i].status  = statError;
					break;
				}
			}
		}
		
		int	bit = (1 << (stims[8].bitno));
		if (stims[8].mode == 1)  // abort sound
			execClrBit(bit);
		else
			execSetBit(bit);

		clearSky();
	}
}
//=====================================================================//
void execEvent(int event)
{
	int i;
	int newTime = (int) (getClock() - startTrial);
	int	bit = (1 << (stims[8].bitno));
	if (event == 2)
	{
		// real start of the trial
		refT0     = newTime;
		realStart = newTime;
		preDim    = fix + tar;
	}
	if (event == 5)
	{
		if (!finishStimulus)
		{
			if (stims[8].mode == 1)  // abort sound
				execClrBit(bit);
			else
				execSetBit(bit);
		}
	}
	if (event == 6)
	{
		preDim = (stims[2].stop[1]-stims[2].start[1]) +    // fix + tar
			     (stims[3].stop[1]-stims[3].start[1]);
		reactionTime = newTime - stims[4].start[1];
		pressTime = newTime - realStart;
		if((reactionTime < 100) || (reactionTime > 700))
		{
			stims[9].start[0] = 0;
			stims[9].start[1] = 0;
			stims[9].stop[0]  = 0;
			stims[9].stop[1]  = 0;
			stims[9].status   = statError;
		}
	}
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
				if (stims[i].start[0] == event)
				{
					stims[i].start[0] = 0;
					stims[i].start[1] += newTime;
				}
				if (stims[i].stop[0] == event)
				{
					stims[i].stop[0] = 0;
					stims[i].stop[1] += newTime;
				}
			}
		}
	}
}/* *********************************************************************************** */
int execBit(int index)
{
	int newTime = (int) (getClock() - startTrial);
	int	bit    = (1 << (stims[index].bitno));
	int mode   = stims[index].mode;
	int status = stims[index].status;

	if ((status == 0) || (status == 9))	// ready or error
		return 0;

	if (status == statInit)
	{
		if ((stims[index].start[0] == 0) &&	    // start event has happened
			(newTime >= stims[index].start[1])) // time past 
		{
				stims[index].start[1] = newTime;
				stims[index].status = statRun;
				if (mode == 1)
					execSetBit(bit);
				else
					execClrBit(bit);
				return statRun;
		}
		return statInit;
	}

	if (status == statRun)
	{
		if ((stims[index].stop[0] == 0)	&&	    // stop event
			(newTime >= stims[index].stop[1]))  // time past 
		{		
			execEvent(stims[index].Event);
			stims[index].stop[1] = newTime;
			stims[index].status = statDone;
			if (mode == 1)
				execClrBit(bit);
			else
				execSetBit(bit);
			return statDone;
		}
		return statRun;
	}
}
int execRew(int index)
{
	int newTime = (int) (getClock() - startTrial);
	int	 bit    = (1 << (stims[index].bitno));
	int  status = stims[index].status;

	if ((status == 0) || (status == 9)) // ready or error
		return 0;

	if (status == statInit)
	{
		if ((stims[index].start[0] == 0) &&	    // start event had happened
			(newTime >= stims[index].start[1])) // time past 
		{
				stims[index].start[1] = newTime;
				stims[index].status = statRun;
				execSetBit(bit);
				return statRun;
		}
		return statInit;
	}

	if (status == statRun)
	{
		if ((stims[index].stop[0] == 0) &&	    // start event had happened
			(newTime >= stims[index].stop[1])) // time past 
		{
				stims[index].stop[1] = newTime;
				stims[index].status = statDone;
				execClrBit(bit);
				return statDone;
		}
		return statRun;
	}
}
/* *********************************************************************************** */
int execBar(int index)
{
	int ans = 0;

	switch(stims[index].mode)
	{
	case 0:	ans = execBarFlank(index);	break;
	case 1:	ans = execBarLevel(index);	break;
	case 2: ans = execBarCheck(index);	break;
	}
	return ans;
}
//=====================================================================//
int execBarFlank(int index)
{
	int newTime = (int) (getClock() - startTrial);
	int	 bit    = (1 << (stims[index].bitno));
	bool bar;
	bar = (parInp & bit) == 0;
	int	edge = stims[index].edge & 0x1;
	int  status = stims[index].status;

	if ((status == 0) || (status == 9)) // ready or error
		return 0;

	if (status == statInit)
	{
		if ((stims[index].start[0] == 0) &&	    // start event had happened
			(newTime >= stims[index].start[1])) // time past 
		{
				stims[index].start[1] = newTime;
				stims[index].status = statRun;
				return statRun;
		}
		return statInit;
	}

	if (status == statRun)
	{
		if ((stims[index].stop[0] == 0)	&&	    // stop event
			(newTime >= stims[index].stop[1]))  // time past 
		{		
			execError();
			stims[index].stop[1] = newTime;
			return statDone;
		}
		else
		{
			if (((edge == 1) &&  bar) ||
				((edge == 0) && !bar))
			{
				execEvent(stims[index].Event);
				stims[index].stop[1] = newTime;
				stims[index].status = statDone;
				return statDone;
			}
		}
		return statRun;
	}
}
/* *********************************************************************************** */
int execBarLevel(int index)
{	
	int newTime = (int) (getClock() - startTrial);
	int	bit    = (1 << (stims[index].bitno));
	bool bar;
	bar = (parInp & bit) == 0;
	int	level  = stims[index].level;
	int status = stims[index].status;

	if ((status == 0) || (status == 9))	// ready or error
		return 0;

	if (status == statInit)
	{
		if ((stims[index].start[0] == 0) &&	    // start event had happened
			(newTime >= stims[index].start[1])) // time past 
		{
				stims[index].start[1] = newTime;
				stims[index].status = statRun;
				return statRun;
		}
		return statInit;
	}

	if (status == statRun)
	{
		if ((stims[index].stop[0] == 0)	&&	    // stop event
			(newTime >= stims[index].stop[1]))  // time past 
		{		
			execEvent(stims[index].Event);
			stims[index].stop[1] = newTime;
			stims[index].status = statDone;
			return statDone;
		}
		else
		{
			if (((level == 1) && !bar) ||
				((level == 0) &&  bar))
			{
				execError();
				stims[index].stop[1] = newTime;
				return statDone;
			}
		}
		return statRun;
	}
}
/* *********************************************************************************** */
int execBarCheck(int index)
{
	int newTime = (int) (getClock() - startTrial);
	int	bit    = (1 << (stims[index].bitno));
	bool bar;
	bar = (parInp & bit) == 0;
	int	level  = stims[index].level;
	int status = stims[index].status;

	if ((status == 0) || (status == 9))	// ready or error
		return 0;

	if (status == statInit)
	{
		if ((stims[index].start[0] == 0) &&	    // start event had happened
			(newTime >= stims[index].start[1])) // time past 
		{
				stims[index].start[1] = newTime;
				stims[index].status = statRun;
				return statRun;
		}
		return statInit;
	}

	if (status == statRun)
	{
		if ((stims[index].stop[0] == 0)	&&	    // stop event
			(newTime >= stims[index].stop[1]))  // time past 
		{		
			execError();
			stims[index].stop[1] = newTime;
			return statDone;
		}
		else
		{
			if (((level == 1) &&  bar) ||
				((level == 0) && !bar))
			{
				execEvent(stims[index].Event);
				stims[index].stop[1] = newTime;
				stims[index].status = statDone;
				return statDone;
			}
		}
		return statRun;
	}
}
//=====================================================================//
void updateLedDriver(int numberIC, int color, int intensity)
{
	int IC, itmp, digit1, digit2, number;
	bool bRet;

	if (color == cRed)
	{
		IC = 0X70;				// choose a nonexistent ic for green
		IC = IC | numberIC;		// choose the red ic
	}
	else
	{
		IC = 0X07;
		IC = IC | (numberIC << 4);
	}
	number = sprintf(&outBuf[0],"%d %d %d\r\n",ledICselect, 1, IC);
	DWORD d1= AFM_slaveWrite(&outBuf[0],number);
	DWORD d2= AFM_slaveRead(&inpBuf[0], 2);

	itmp = ledData[color][numberIC];
	digit1 = itmp & 0XFF;
	digit2 = ((itmp >> 8) & 0XFF);
	itmp = (intensity << 4) | 0X06;

	number = sprintf(&outBuf[0],"%d %d %d %d %d %d\r\n",
						        ledICdata, 4, 0, itmp, digit1, digit2);
	d1= AFM_slaveWrite(&outBuf[0],number);
	d2= AFM_slaveRead(&inpBuf[0], 2);
}

//=====================================================================//
void LedOnOff(int ring, int spoke, int color, int intensity, bool OnOff)
{
	int numberIC;
	int led;
	int tmp;

	if (spoke > 0) spoke -= 1;
	if (OnOff)
	{
		tmp = (intensity << 3*ring);
		skyData[color][spoke] |= tmp;
	}
	else
	{
		tmp = (0x7 << 3*ring);
		skyData[color][spoke] &= ~tmp;
	}
	if (ring == 0)
	{
		numberIC = 0;
		if (OnOff)
			ledData[color][numberIC] |= 0x0001;
		else
			ledData[color][numberIC] &= ~0x0001;
	}
	else
	{
		led = LEDADDRESS[spoke][ring-1];
		numberIC = (led & 0xF0000) >> 16;
		led = led & 0xFFFF;
		if (OnOff)
			ledData[color][numberIC] |= led;
		else
			ledData[color][numberIC] &= ~led;
	}

#ifdef _HARDWARE
	updateLedDriver(numberIC, color, intensity);
#endif
}
int execLed(int index)
{
	int newTime = (int) (getClock() - startTrial);
	int status  = stims[index].status;

	if ((status == 0) || (status == 9))	// ready or error
		return statDone;

	if (status == statInit)
	{
		if ((stims[index].start[0] == 0) &&	    // start event had happened
			(newTime >= stims[index].start[1])) // time past 
		{
			LedOnOff(stims[index].pos[0], stims[index].pos[1], 
					 stims[index].index,stims[index].level,true);
			stims[index].start[1] = newTime;
			stims[index].status   = statRun;
			selectSpeaker(stims[index].pos[0], stims[index].pos[1], 0); 
			return statRun;
		}
		return statInit;
	}

	if (status == statRun)
	{
		if ((stims[index].stop[0] == 0) && 
			(newTime >= stims[index].stop[1]))
		{
			LedOnOff(stims[index].pos[0], stims[index].pos[1], 
				     stims[index].index,stims[index].level,false);
			stims[index].stop[1] = newTime;
			stims[index].status  = statDone;
			execEvent(stims[index].Event);
			return statDone;
		}
		return statRun;
	}
}
void clearSky(void)
{
//  all leds off
	for (int color=0; color<2; color++)
	{
		for (int IC=0; IC<5; IC++)
		{
			ledData[color][IC] = 0x0000;
#ifdef _HARDWARE
			updateLedDriver(IC, color, 0);
#endif
		}
		for (int spoke=0; spoke<12; spoke++)
			skyData[color][spoke] = 0;
	}
}
UINT FSMThread( LPVOID pParam ) 
{ 
	bool GoOn = true;
	bool bRet;
	int number, command;
	int m, n, nTrial, error, curTrial;
	int timeSpan;
	int timeExitPrevTrial;
	int flagITI;
	int done = 0;
	int itmp;
	char NUMBERS[] = "0123456789";
	time_t ltime;
	int val;
	bool ledTestFlag = false;
	bool barLowFlag  = false;
	int ledTestTime;
	int ring;
	int spoke;
	int color;
	int ontime;
	timeBeginPeriod(1);
	char tmpBuf[80];
//	bRet = SetPriorityClass(GetCurrentProcess(),HIGH_PRIORITY_CLASS);
	// init all
	nStim = 0;
	stateTrial = stateInitTrial;
	setClock();
	timeExitPrevTrial = getClock();
	state = 0;
	FSM_CMD = 0;
	while (GoOn)
	{
		if (FSM_CMD == 2)  // a new command
		{
			command = dataRecord[1];
			curTime = getClock();
			switch (command)
			{
				case cmdSetClock:
					 setClock();
					 dataRecord[0] = 2;
					 dataRecord[1] = curTime; 
					 FSM_CMD = 3;
					 break;
				case cmdGetStatus:
					 dataRecord[0] = 3;
					 dataRecord[1] = curTime; 
					 dataRecord[2] = state; // qq
					 FSM_CMD = 3;
					 break;
				case cmdGetClock:
					 dataRecord[0] = 2;
					 dataRecord[1] = curTime;
					 FSM_CMD = 3;
					 break;
				case cmdNextTrial: 
					 curTrial = dataRecord[2];
					 fix      = dataRecord[3];
					 tar      = dataRecord[4];
					 dim      = dataRecord[5];
					 nStim    = dataRecord[6];
					 finishStimulus  = (dataRecord[7] > 0);
					 stateTrial = stateRunTrial;
					 startTrial = curTime;
					 loadTrial = true;
					 while (loadTrial)
						 Sleep(1);
					 dataRecord[0] = 2;
					 dataRecord[1] = curTime;
					 FSM_CMD = 3;
					 if (barLowFlag)
					 {
						 barLowFlag = false;
						 stims[0].status   = statDone;
						 stims[1].start[0] = 0;
					 }
					break;
				case cmdResultTrial:
					 dataRecord[0] = 11;
					 dataRecord[1] = curTime;
					 dataRecord[2] = stims[0].stop[1]-stims[0].start[1];
					 dataRecord[3] = stims[1].stop[1]-stims[1].start[1];
					 dataRecord[4] = stims[2].stop[1]-stims[2].start[1];
					 dataRecord[5] = stims[3].stop[1]-stims[3].start[1];
					 dataRecord[6] = stims[4].stop[1]-stims[4].start[1];
					 dataRecord[7] = reactionTime;
					 dataRecord[8] = pressTime;
					 dataRecord[9] = stims[7].stop[1]-stims[7].start[1];
					 dataRecord[10]= stims[9].stop[1]-stims[9].start[1];
					 FSM_CMD = 3;
					 break;
				case cmdSetPIO:
					 execSetPIO(dataRecord[2]);
					 dataRecord[0] = 2;
					 dataRecord[1] = curTime;
					 FSM_CMD = 3;
					 break;
				case cmdGetPIO:
 					 val = execGetPIO();
					 dataRecord[0] = 3;
					 dataRecord[1] = curTime;
					 dataRecord[2] = val;
					 FSM_CMD = 3;
					break;
				case cmdSetBit:
					 execSetBit(dataRecord[2]);
					 dataRecord[0] = 2;
					 dataRecord[1] = curTime;
					 FSM_CMD = 3;
					 break;
				case cmdClrBit:
					 execClrBit(dataRecord[2]);
					 dataRecord[0] = 2;
					 dataRecord[1] = curTime;
					 FSM_CMD = 3;
					 break;
				case cmdGetLeds:
					 for (n=0; n<12; n++)
					 {
						dataRecord[n+2]    = skyData[0][n];
						dataRecord[n+2+12] = skyData[1][n];
					 }
					 dataRecord[0] = 26;  // 2 + 12 + 12
					 dataRecord[1] = curTime;
					 FSM_CMD = 3;
					 break;
			 	case cmdTestLeds:	
					 color  =  dataRecord[2];
					 ontime =  dataRecord[3];
					 ring   =  0;
					 spoke  =  0;
					 ledTestFlag = true;
					 ledTestTime = curTime + ontime;
  		 			 curTime = getClock();
				     dataRecord[1] = curTime;
					 FSM_Status.Format("Test Led Sky....");
					 LedOnOff(ring,spoke,color,7,true);
					 break;
			}
		}
		if (ledTestFlag)
		{
			curTime = getClock();
			if (curTime >= ledTestTime)
			{
			    LedOnOff(ring,spoke,color,7,false);
				if (ring == 0)
				{
					spoke = 1;
					ring  = 1;
				}
				else
					spoke++;
				if (spoke > 12)
				{
					spoke = 1;
					ring++;
					if (ring > 5)
					{
						ledTestFlag = false;
						FSM_Status.Format("Time span: %d mSec",
							curTime-dataRecord[1]);
						dataRecord[0] = 2;
						dataRecord[1] = curTime;
						FSM_CMD = 3;
					}
				}
				if (ledTestFlag)
				{
					ledTestTime = curTime + ontime;
					LedOnOff(ring,spoke,color,7,true);
				}
			}
		}
		curTime  = getClock();
		//
		parInp   = execGetPIO() & 0x01;
		if (!barActiveHigh)
		{
			if (parInp == 0)
				parInp = 1;
			else
				parInp = 0;
		}
		barLevel = parInp;
		barTime  = curTime;
		if (!barLowFlag)
		{
			barLowFlag = (barLevel == 1);
		}
		//
		// Execute trial
		//
		if (stateTrial == stateRunTrial)
		{
			curTime = getClock()-startTrial;
			m = 0;
			done = 0;
			state = 0; 
			n = sprintf(tmpBuf,"State:");
			for (int i=0; i<nStim; i++)
			{
				switch ((int) stims[i].stim)
				{
				case stimLed: m = execLed(i); done += m; break;
				case stimBit: m = execBit(i); done += m; break;
				case stimBar: m = execBar(i); done += m; break;
				case stimRew: m = execRew(i); done += m; break;
				}
				if (m != 0) state |= (1 << i);
				n += sprintf(tmpBuf+n,"%2d",m);
			}
			FSM_Status.Format("%s",tmpBuf);
			trialStatus = state;
			if (!finishStimulus)
			{
				stims[4].stop[1] = stims[6].stop[1];
			}
			if (done == 0)
			{
				barLowFlag = false;
				stateTrial = stateInitTrial;
				dataRecord[0] = 11;
				dataRecord[1] = curTime;
				dataRecord[2] = stims[0].stop[1]-stims[0].start[1];
				dataRecord[3] = stims[1].stop[1]-stims[1].start[1];
				dataRecord[4] = stims[2].stop[1]-stims[2].start[1];
				dataRecord[5] = stims[3].stop[1]-stims[3].start[1];
				dataRecord[6] = stims[4].stop[1]-stims[4].start[1];
				dataRecord[7] = reactionTime;
				dataRecord[8] = pressTime;
				dataRecord[9] = stims[7].stop[1]-stims[7].start[1];
				dataRecord[10]= stims[9].stop[1]-stims[9].start[1];
			}
		}
	}
	return(0);
}


