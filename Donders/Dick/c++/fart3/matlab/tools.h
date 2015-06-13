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

#define DEFAULT_BUFLEN 512
#define DEFAULT_PORT "27016"

#define TCPinit          1		//=> TCPIP commando's
#define TCPread          2
#define TCPwrite         3
#define TCPquery         4
#define TCPclose         5
#define stimLed         10		//=> stimuli
#define cmdGetStatus   101
#define cmdSetClock    102		//=> commando's FSM
#define cmdGetClock    103
#define cmdNextTrial   104
#define cmdStartTrial  105
#define cmdResultTrial 106
#define cmdAbortTrial  107
#define cmdSetPIO      108
#define cmdGetPIO      109
#define cmdTestLeds    200

using namespace std;
int InitializeWinsock(void);

int ConnectServer(SOCKET &ConnectSocket, char *host);
int ConnectClient(SOCKET &ListenSocket,SOCKET &ClientSocket);

int SendBuffer(SOCKET ConnectSocket, char *msg);
int ReceiveBuffer(SOCKET ConnectSocket, char *buffer, int size);

int CloseConnection(SOCKET ConnectSocket,int how);
void CleanupConnection(SOCKET ConnectSocket);

//=====================================================================//
bool AFM_openSerial(void);
void AFM_close();

bool AFM_activate(void);
bool AFM_setSpeed(void);
bool AFM_slaveAddress(string address);
bool AFM_slaveWrite(int num, float data[]);
//=====================================================================//
string HexVal(BYTE b);
void setClock(void);
float getClock(void);
