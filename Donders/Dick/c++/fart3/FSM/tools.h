//
//tools.h
//
#include "stdafx.h"

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <iostream>

// Need to link with Ws2_32.lib, Mswsock.lib, and Advapi32.lib
#pragma comment (lib, "Ws2_32.lib")
#pragma comment (lib, "Mswsock.lib")
#pragma comment (lib, "AdvApi32.lib")
#pragma comment (lib, "inpout32.lib")

#define DEFAULT_BUFLEN 512
#define DEFAULT_PORT "27016"

#define LPTdata    0x378
#define LPTstatus  0x379
#define LPTcontrol 0x37a

#define TCPinit          1		//=> TCPIP commando's
#define TCPread          2
#define TCPwrite         3
#define TCPquery         4
#define TCPclose         5
#define stimLed         10		//=> stimuli
#define stimBar			11
#define stimBit			12
#define stimRew			13
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

#define stateInitTrial   0
#define stateNextTrial   1
#define stateRunTrial    2
#define stateDoneTrial   3
#define stateAbortTrial  4

#define statError        9
#define statInit	     2
#define statRun          1
#define statDone         0

struct STIMREC
{
	int stim;
	int bitno;
	int mode;
	int edge;
	int index;
	int pos[2];
	int level;
	int start[2];
	int stop[2];
	int latency;
	int duration;
	int Event;		
	int status;
};

using namespace std;
int InitializeWinsock(void);

int ConnectServer(SOCKET &ConnectSocket, char *host);
int ConnectClient(SOCKET &ListenSocket,SOCKET &ClientSocket);

int SendBuffer(SOCKET ConnectSocket, char *msg);
int sendRecord(SOCKET ConnectSocket,char *dataRecord,int size);
int ReceiveBuffer(SOCKET ConnectSocket, char *buffer, int size);
int ReceiveRecord(SOCKET ConnectSocket, char *dataRecord, int size);

int CloseConnection(SOCKET ConnectSocket,int how);
void CleanupConnection(SOCKET ConnectSocket);

//=====================================================================//
bool AFM_openSerial(DWORD baud, int fDtr);
void AFM_setBaud(DWORD baud);
void AFM_close();

DWORD AFM_slaveWrite(char *outbuf,int number);
DWORD AFM_slaveRead(char *inpBuf, int number);
//=====================================================================//
string HexVal(BYTE b);
void getFrequency();
void setClock();
float getClock();
int readLPT1(short port);
void writeLPT1(short port, short val);
