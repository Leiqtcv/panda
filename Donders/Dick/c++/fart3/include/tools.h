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

#define LPTdata    0x378    // output
#define LPTstatus  0x379    // input
#define LPTcontrol 0x37a    // input

int InitializeWinsock(void);

int ConnectServer(SOCKET &ConnectSocket, char *host);
int ConnectClient(SOCKET &ListenSocket,SOCKET &ClientSocket);

int SendBuffer(SOCKET ConnectSocket, char *msg);
int sendRecord(SOCKET ConnectSocket,char *dataRecord,int size);
int SendBuffer(SOCKET ConnectSocket, char *msg);
int sendRecord(SOCKET ConnectSocket,double *dataRecord,int size);
//int sendRecord(SOCKET ConnectSocket,char *dataRecord,int size);
int ReceiveBuffer(SOCKET ConnectSocket, char *buffer, int size);
int ReceiveRecord(SOCKET ConnectSocket, double *dataRecord, int size);
//int ReceiveRecord(SOCKET ConnectSocket, char *dataRecord, int size);

int CloseConnection(SOCKET ConnectSocket,int how);
void CleanupConnection(SOCKET ConnectSocket);

//=====================================================================//
bool AFM_openSerial(DWORD baud);
void AFM_close();

bool AFM_activate(void);
int  AFM_readStatus(char *outBuf,int number);
bool AFM_slaveWrite(char *outbuf,int number);
//=====================================================================//
int	 readLPT1(short port);
void writeLPT1(short port, short val);

int GetRandom(int min, int max);
