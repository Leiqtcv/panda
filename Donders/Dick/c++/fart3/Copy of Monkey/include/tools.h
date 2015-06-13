//
//tools.h
//
#include "stdafx.h"

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <iostream>

#pragma comment (lib, "inpout32.lib")

#define LPTdata    0x378    // output
#define LPTstatus  0x379    // input
#define LPTcontrol 0x37a    // input

//=====================================================================//
bool AFM_openSerial(DWORD baud);
void AFM_close();
bool AFM_activate(void);
int  AFM_readStatus(char *outBuf,int number);
bool AFM_slaveWrite(char *outbuf,int number);
DWORD AFM_slaveRead(char *inpBuf, int number);
//=====================================================================//
int	 readLPT1(short port);
void writeLPT1(short port, short val);
//=====================================================================//
// string HexVal(BYTE b);
int GetRandom(int min, int max);
