// FSM.cpp : Defines the entry point for the console application.
//
#include "FSM.h"
#include <time.h>

#include <MMSystem.h>
#pragma comment(lib, "winmm");

//=====================================================================//
//	Hardware control
//	Leds:
//		intensity - address = 0X44, data = 0..255 (max->min)
//		red/green - address = 0X74, data red   = bit 0..2 + 4..6 = 1
//										 green = bit 4..6 + 0..2 = 1
//		central led 0x000001
//
//  Version 1.0 - 16-03-2011 - Led control
//                           - Dimming paradigm
//              - 12-09-2011 - Delayed reward. 
//								Reward circuit is now running on rp2.2
//								and stimRew is added
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
string boardSelect  = "4E";
string muteSelect   = "72";
string sourceSelect = "40";
// 8 amplifiers per board
// mute: 1-minimum and 0-maximum volume
// source: 1-source A, 0-source B
							 // pnt    pnt      data (A)      data (OFF)
int speakerData[12][6] = {   //sp=6, board=5, source=4..3, mute=2..1
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF},
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF},
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF},
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF},
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF},
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF},
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF},
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF},
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF},
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF},
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF},
	                     {0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF, 0X00FFFF}
                         };

double curTime, startTrial;
double realStart;
double preDim;
double reactionTime;
double pressTime;
int stateTrial;
int nStim;
STIMREC stims[50];
int parInp;
int parOut;
int barBit = 8;
char prtBuf[81];
char outBuf[80];
char inpBuf[80];
int refT0;
SOCKET ConnectSocket = INVALID_SOCKET;
double dataRecord[32];
bool finishStimulus;
int state;
double fix, tar, dim, ITI;

int main(void)
{
	bool GoOn = true;
	bool bRet;
	int number, command;
	int n, m, nTrial, error, curTrial;
	double timeSpan;
	double timeExitPrevTrial;
	double flagITI;
	int done = 0;
	char CR[] = "\n";
	char SP[] = " ";
	char NUMBERS[] = "0123456789";
	time_t ltime;
	int val;
	bool ledTestFlag = false;
	double ledTestTime;
	int ring;
	int spoke;
	int color;
	int ontime;

	printf("\n===============================================\n");
	printf("==         FSM: version 1.0 04-07-2011       ==\n");
	printf("===============================================\n");

	_strtime_s(prtBuf, 81);
	printf("-> %s Start\n",prtBuf);
	timeBeginPeriod(1);
//	bRet = SetPriorityClass(GetCurrentProcess(),HIGH_PRIORITY_CLASS);
	bRet = SetPriorityClass(GetCurrentProcess(),NORMAL_PRIORITY_CLASS);

	initAll();
	//==================================================================
	//	TCPIP connection
	//==================================================================
	char *msgRet = "\n\0";
	char *host = "localhost"; //"131.174.221.4";
    int iResult;
	int stimPnt = 999;
	if (InitializeWinsock() < 0) return 1;
	while (ConnectServer(ConnectSocket, host) < 0)
	{
		if (InitializeWinsock() < 0) return 1;
	}
	_strtime_s(prtBuf, 81);
	printf("-> %s Connected to server\n",prtBuf);
	nStim = 0;
	stateTrial = stateInitTrial;
	getFrequency();
    setClock();
	timeExitPrevTrial = getClock();
	state = 0;
//======================================================================
	while (GoOn)
	{
		iResult = ReceiveRecord(ConnectSocket,(char*)&dataRecord,sizeof(dataRecord));
		if (iResult > 0)   // a new command or data
		{
			command = (int) dataRecord[1];
			curTime = getClock();
			switch (command)
			{
				case TCPquery:
					 SendBuffer(ConnectSocket, msgRet);
					 break;
				case TCPclose:
					 GoOn = false;
  					 SendBuffer(ConnectSocket, msgRet);
					 break;
				case cmdSetClock:
					 setClock();
  					 SendBuffer(ConnectSocket, msgRet);
					 break;
				case cmdGetStatus:
					 dataRecord[0] = 4;
					 dataRecord[1] = cmdGetStatus;  // no error
					 dataRecord[2] = state; // qq
					 dataRecord[3] = nStim; 
					 sendRecord(ConnectSocket,(char*)&dataRecord,sizeof(dataRecord));
					 break;
				case cmdGetClock:
					 dataRecord[0] = 3;
					 dataRecord[1] = cmdGetClock;
					 dataRecord[2] = curTime;
					 sendRecord(ConnectSocket, (char*)&dataRecord,sizeof(dataRecord));
					 break;
				case cmdNextTrial: 
					 curTrial = (int) dataRecord[2];
					 fix      = dataRecord[3];
					 tar      = dataRecord[4];
					 dim      = dataRecord[5];
					 nStim    = (int) dataRecord[6];
					 finishStimulus  = (dataRecord[7] > 0.0);
  					 SendBuffer(ConnectSocket, msgRet);
					 _strtime_s(prtBuf, 81);
					 printf("-> %s #Trial %3d, #stim %2d, (%.f => %.f => %.f)\n",
					 	       prtBuf,curTrial, nStim, fix, tar, dim);
					 for (stimPnt = 0; stimPnt < nStim; stimPnt++)
					 {
						extract(stimPnt);
					 }
					stateTrial = stateRunTrial;
					startTrial = curTime;
					break;
				case cmdResultTrial:
					 dataRecord[0] = 9;
					 dataRecord[1] = stims[0].stop[1]-stims[0].start[1];
					 dataRecord[2] = stims[1].stop[1]-stims[1].start[1];
					 dataRecord[3] = stims[2].stop[1]-stims[2].start[1];
					 dataRecord[4] = stims[3].stop[1]-stims[3].start[1];
					 dataRecord[5] = stims[4].stop[1]-stims[4].start[1];
					 dataRecord[6] = reactionTime;
					 dataRecord[7] = pressTime;
					 dataRecord[8] = stims[7].stop[1]-stims[7].start[1];
					 dataRecord[9] = stims[9].stop[1]-stims[9].start[1];
					 sendRecord(ConnectSocket, (char*)&dataRecord,sizeof(dataRecord));
					 break;
				case cmdSetPIO:
					 SendBuffer(ConnectSocket, msgRet);
					 execSetPIO((int) dataRecord[2]);
					 break;
				case cmdSetBit:
					 SendBuffer(ConnectSocket, msgRet);
					 execSetBit((int) dataRecord[2]);
					 break;
				case cmdClrBit:
					 SendBuffer(ConnectSocket, msgRet);
					 execClrBit((int) dataRecord[2]);
					 break;
				case cmdGetPIO:
					val = execGetPIO();
					dataRecord[0] = 5;
					dataRecord[1] = cmdGetPIO;
					dataRecord[2] = val;
					dataRecord[3] = curTime-startTrial;
					dataRecord[4] = curTime;
					sendRecord(ConnectSocket, (char*)&dataRecord,sizeof(dataRecord));
					break;
				case cmdGetLeds:
					for (n=0; n<12; n++)
					{
						dataRecord[n]    = skyData[0][n];
						dataRecord[n+12] = skyData[1][n];
					}
					sendRecord(ConnectSocket, (char*)&dataRecord,sizeof(dataRecord));
					break;
			 	case cmdTestLeds:	
 				     SendBuffer(ConnectSocket, msgRet);
					 _strtime_s(prtBuf, 81);
					 color  = (int) dataRecord[2];
					 ontime = (int) dataRecord[3];
					 ring   =  0;
					 spoke  =  0;
					 printf("-> %s Test leds: color %d, ontime %d\n",
						    prtBuf, color, ontime);
					 ledTestFlag = true;
					 ledTestTime = curTime + ontime;
					 LedOnOff(ring,spoke,color,7,true);
					 break;
			}
		}
		if (ledTestFlag)
		{
			curTime = getClock();
			if (curTime > ledTestTime)
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
						 _strtime_s(prtBuf, 81);
						 printf("-> %s Ready\n", prtBuf);
					}
				}
				if (ledTestFlag)
				{
					ledTestTime = curTime + ontime;
					LedOnOff(ring,spoke,color,7,true);
				}
			}
		}
		//
		// Execute trial
		//
		if (stateTrial == stateRunTrial)
		{
			curTime = getClock()-startTrial;
			done = 0;
			state = 0; 
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
			}
			if (!finishStimulus)
			{
				stims[4].stop[1] = stims[6].stop[1];
			}
			if (done == 0)
			{
				stateTrial = stateInitTrial;
				printf("ITI   %5d\n",stims[0].stop[1]-stims[0].start[1]);
				printf("WAIT  %5d\n",stims[1].stop[1]-stims[1].start[1]);
				printf("FIX   %5d\n",stims[2].stop[1]-stims[2].start[1]);
				printf("TAR   %5d\n",stims[3].stop[1]-stims[3].start[1]);
				printf("DIM   %5d\n",stims[4].stop[1]-stims[4].start[1]);
				printf("REACT %5d\n",(int) reactionTime);
				printf("Rew1  %5d\n",stims[7].stop[1]-stims[7].start[1]);
				printf("Rew2  %5d\n",stims[9].stop[1]-stims[9].start[1]);
			}
		}
	}
//======================================================================

	//==================================================================
	//	TCPIP close connection
	//==================================================================
	if (CloseConnection(ConnectSocket, SD_SEND) < 0) return 1;
	do 
	{
		iResult = ReceiveBuffer(ConnectSocket, recvbuf, recvbuflen);
	} while (iResult > 0);
	CleanupConnection(ConnectSocket);

	AFM_close();
    return 0;
}
//======================================================================
void getStimRecord(int index)
{
	switch ((int) dataRecord[0])
	{
	case stimLed:
		execLed(index);
		break;
	case stimBar:
		execBar(index);
		break;
	case stimBit:
		execBit(index);
		break;
	}
}

void extract(int nStim)
{
	int pnt = 0;
	int i = nStim;
	int stim;
	char *msgRet = "\n\0";
    int iResult = 0;

	while (iResult == 0)
		iResult = ReceiveRecord(ConnectSocket,
		                       (char*)&dataRecord,
							    sizeof(dataRecord));
	stim = (int) dataRecord[pnt];
	switch (stim) 
	{
	case stimLed:
		stims[i].stim     = dataRecord[pnt++];
		stims[i].start[0] = dataRecord[pnt++];
		stims[i].start[1] = dataRecord[pnt++];
		stims[i].stop[0]  = dataRecord[pnt++];
		stims[i].stop[1]  = dataRecord[pnt++];
		stims[i].pos[0]   = dataRecord[pnt++];
		stims[i].pos[1]   = dataRecord[pnt++];
		stims[i].index    = dataRecord[pnt++];
		stims[i].level    = dataRecord[pnt++];
		stims[i].Event    = dataRecord[pnt++];
		stims[i].status   = dataRecord[pnt++];
		break;
	case stimBar:
		stims[i].stim     = dataRecord[pnt++];
		stims[i].start[0] = dataRecord[pnt++];
		stims[i].start[1] = dataRecord[pnt++];
		stims[i].stop[0]  = dataRecord[pnt++];
		stims[i].stop[1]  = dataRecord[pnt++];
		stims[i].bitno    = dataRecord[pnt++];
		stims[i].mode     = dataRecord[pnt++];
		stims[i].edge     = dataRecord[pnt++];
		stims[i].level    = dataRecord[pnt++];
		stims[i].Event    = dataRecord[pnt++];
		stims[i].status   = dataRecord[pnt++];
		break;
	case stimBit:
		stims[i].stim     = dataRecord[pnt++];
		stims[i].start[0] = dataRecord[pnt++];
		stims[i].start[1] = dataRecord[pnt++];
		stims[i].stop[0]  = dataRecord[pnt++];
		stims[i].stop[1]  = dataRecord[pnt++];
		stims[i].bitno    = dataRecord[pnt++];
		stims[i].mode     = dataRecord[pnt++]; //0-clear, 1-set
		stims[i].Event    = dataRecord[pnt++];
		stims[i].status   = dataRecord[pnt++];
		break;
	case stimRew:
		stims[i].stim     = dataRecord[pnt++];
		stims[i].start[0] = dataRecord[pnt++];
		stims[i].start[1] = dataRecord[pnt++];
		stims[i].stop[0]  = dataRecord[pnt++];
		stims[i].stop[1]  = dataRecord[pnt++];
		stims[i].bitno    = dataRecord[pnt++];
		stims[i].mode     = dataRecord[pnt++]; //0-clear, 1-set
		stims[i].Event    = dataRecord[pnt++];
		stims[i].status   = dataRecord[pnt++];
		break;
	}
	SendBuffer(ConnectSocket, msgRet);
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
/* *********************************************************************************** */
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
	printf("bit-3\n");

}
/* *********************************************************************************** */
int execBar(int index)
{
	int ans = 0;
	parInp = execGetPIO();
	switch(stims[index].mode)
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
	int newTime = (int) (getClock() - startTrial);
	int	bit    = (1 << (stims[index].bitno));
	bool bar   = (parInp & bit) != 0;
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
	bool bar   = (parInp & bit) != 0; 
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
/* *********************************************************************************** */
int execBarFlank(int index)
{
	int newTime = (int) (getClock() - startTrial);
	int	 bit    = (1 << (stims[index].bitno));
	bool bar    = (parInp & bit) != 0;
	int	 edge   = stims[index].edge & 0x1;
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
		preDim = (stims[2].stop[1]-stims[2].start[1]) +    // fix + tar
			     (stims[3].stop[1]-stims[3].start[1]);
// qq		reactionTime = (newTime - realStart) - preDim;
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
}
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

/* *********************************************************************************** */

//=====================================================================//
void initAll(void)
{
	int number;
	bool bRet;
	char ans[2];
	int buf[4];
	bRet = AFM_openSerial(CBR_115200, 0);

	int lp  = 1000;
	int bar = 0;
	// check I2C

//  set maximum led intensity (255..0)
	number = sprintf(&outBuf[0],"%d %d %d\r\n",
		ledIntensity, 1, 0);
	DWORD d1= AFM_slaveWrite(&outBuf[0],number);
	DWORD d2= AFM_slaveRead(&inpBuf[0], 2);

	//  all leds off
	clearSky();
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
	updateLedDriver(numberIC, color, intensity);
}

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
void clearSky(void)
{
//  all leds off
	for (int color=0; color<2; color++)
	{
		for (int IC=0; IC<5; IC++)
		{
			ledData[color][IC] = 0x0000;
			updateLedDriver(IC, color, 0);
		}
		for (int spoke=0; spoke<12; spoke++)
			skyData[color][spoke] = 0;
	}
}
