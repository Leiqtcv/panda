//
//tools.cpp
//
#include "stdafx.h"
#include "tools.h"

short _stdcall Inp32(short PortAddress);
void _stdcall Out32(short PortAddress, short data);
//====================================================================//
//	RS232 - I2C
//====================================================================//
HANDLE serial;

bool AFM_openSerial(DWORD baud)
{
	bool bRet = false;
	DCB dcb;
	COMMTIMEOUTS CommTimeouts;
	CommTimeouts.ReadIntervalTimeout = 1;
	CommTimeouts.ReadTotalTimeoutMultiplier = 1;
	CommTimeouts.ReadTotalTimeoutConstant = 1;
	CommTimeouts.WriteTotalTimeoutMultiplier = 1;
	CommTimeouts.WriteTotalTimeoutConstant = 1;
	serial = CreateFile(TEXT("COM1"),
					   GENERIC_READ | GENERIC_WRITE,
					   0, NULL,
					   OPEN_EXISTING,
					   FILE_ATTRIBUTE_NORMAL,
					   NULL);
	SetCommTimeouts(serial,&CommTimeouts);
    if (serial != INVALID_HANDLE_VALUE)
	{
		dcb.DCBlength = sizeof(DCB);
		if (GetCommState(serial,&dcb))
		{
			dcb.BaudRate = baud;
			dcb.ByteSize = 8;
			dcb.Parity   = 0;
			dcb.StopBits = 0;
			dcb.fDtrControl = 2;
			dcb.fBinary = true;
			dcb.fParity = false;
			bRet = SetCommState(serial,&dcb);
		}
	} 
	return bRet;
}
void AFM_close()
{
	CloseHandle(serial);
}
bool AFM_slaveWrite(char *outBuf,int number)
{
	DWORD bytesWritten;
	bool bRet;
	bRet = WriteFile(serial,outBuf,number,&bytesWritten,NULL);
	return true;
}
DWORD AFM_slaveRead(char *inpBuf, int number)
{
	DWORD bytesRead;
	bool bRet;
	DWORD ans;
	int repeat = 5;
	inpBuf[0] = 'E';
	while ((inpBuf[0] == 'E') && (repeat > 0))
	{
		bRet = ReadFile(serial,inpBuf,number,&bytesRead,NULL);
		if (bRet)
			if (inpBuf[0] == 'E')
			{
				ans = 0;
				repeat--;
			}
			else
				ans = bytesRead;
		else
		{
			printf("RS232 read error\n");
			ans = 0;
		}
	}
	if (inpBuf[0] == 'E')
		printf("I2C read error\n");
	return ans;
}
int AFM_readStatus(char *outBuf,int number)
{
	char inChar;
	int val;
	DWORD bytesRead, bytesWritten;
	bool bRet;
	bytesRead = 0;
	bRet = WriteFile(serial,outBuf,number,&bytesWritten,NULL);
	do
	{	
			bRet = ReadFile(serial,&inChar,1,&bytesRead,NULL);
	}while (bytesRead == 0);
	val = (int) inChar;
	return (val & 0XF);
}
//====================================================================//
int readLPT1(short port)
{
	int inp = Inp32(port);
	
	return inp;
}
void writeLPT1(short port, short val)
{
	Out32(port, val);
}
//====================================================================//
int GetRandom(int min, int max)
{
	if (max <= 0)
		return min;

	float f;
	f = ((float) rand()) / ((float) RAND_MAX);
	f = f*((float) (max - min));

	return (min + ((int) f));
}
//====================================================================//
//====================================================================//
