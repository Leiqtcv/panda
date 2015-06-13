//
//tools.cpp
//
#include "tools.h"
LARGE_INTEGER clockStart;
LARGE_INTEGER clockStop;
LARGE_INTEGER clockFreq;
LARGE_INTEGER clockElapsed;

//====================================================================//
//	RS232 - I2C
//====================================================================//
int number;
char inBuf[81];
char outBuf[81];
char inChar;
DWORD bytesRead, bytesWritten;
HANDLE serial;
size_t needle;

bool AFM_openSerial(void)
{
	bool bRet = false;
	DCB dcb;
	COMMTIMEOUTS CommTimeouts;
	CommTimeouts.ReadIntervalTimeout = 1;
	CommTimeouts.ReadTotalTimeoutMultiplier = 0;
	CommTimeouts.ReadTotalTimeoutConstant = 10;
	serial = CreateFile(TEXT("COM1"),
					   GENERIC_READ | GENERIC_WRITE,
					   0, NULL,
					   OPEN_EXISTING,
					   FILE_ATTRIBUTE_NORMAL,
					   NULL);
    if (serial != INVALID_HANDLE_VALUE)
	{
		dcb.DCBlength = sizeof(DCB);
		if (GetCommState(serial,&dcb))
		{
			dcb.BaudRate = CBR_19200;
			dcb.ByteSize = 8;
			dcb.Parity   = 0;
			dcb.StopBits = 0;
			dcb.fDtrControl = 0;
			dcb.fBinary = true;
			bRet = SetCommState(serial,&dcb);
		}
	}
	return bRet;
}
void AFM_close()
{
	CloseHandle(serial);
}
bool AFM_activate(void)
{
    // Activates iPort/AFM as an active device on the I2C bus
    // Command: /O[CR]
    // Response: /OCC[CR]  => Open Connection Complete
	bool bRet = false;
	number = 3;
	string str = "";
	sprintf(&outBuf[0],"/O\r");
	bRet = WriteFile(serial,&outBuf,number,&bytesWritten,NULL);
	do {
		bRet = ReadFile(serial,&inChar,1,&bytesRead,NULL);
		str = str + inChar;
	} while (inChar != '*');
	needle = str.find("/OCC");
	return (needle != str.npos);
}
bool AFM_setSpeed(void)
{
	// Set I2C speed = 100 KHz.
    // Command: /K2[CR]
    // Response: * 
	bool bRet = false;
	string str = "";
	sprintf(&outBuf[0],"/K2\r");
	number=4;
	bRet = WriteFile(serial,&outBuf,number,&bytesWritten,NULL);
	do
	{
		bRet = ReadFile(serial,&inChar,1,&bytesRead,NULL);
		str = str + inChar;
	} while (inChar != '*');
	return true;
}
bool AFM_slaveAddress(string address)
{
    // Set destination I2C slave address
    // Command: /Dxx[CR]
    // Response 1: *       => iPort/AFM Ready
    // Response 2: /I89    => Invalid command argument
	bool bRet = false;
	string str = "/D";		// "/DC0\r"
	str.append(address);
	str.append("\r");
	str.copy(&outBuf[0],6);
	number=5;
	str = "";
	bRet = WriteFile(serial,&outBuf,number,&bytesWritten,NULL);
	do
	{
		bRet = ReadFile(serial,&inChar,1,&bytesRead,NULL);
		str = str + inChar;
	} while (inChar != '*');
	return (str.find("/I89") == str.npos);  // is false
}
bool AFM_slaveWrite(int num, float data[])
{
	// Write data bytes to the currently selected I2C slave
    // Command: /Ttext[CR]
    // Response 1: /MTC    => Master transmit completed
    // Response 2: /SNA    => Slave not acknowledging
    // Response 3: /I81    => busy
    // Response 4: /I83    => arbitration loss
    // Response 5: /I88    => Not open
	
	bool bRet;
//	sprintf(&outBuf[0],"/T~06~FF\r");  // data
	string str = "/T";		// "/T~06~FF\r"
	string tmp = "";
	for (int i = 0; i < num; i++)
	{
		tmp = HexVal((BYTE) data[i]);
		str.append(tmp);
	}
	str.append("\r");
	number=3+num*3;
	str.copy(&outBuf[0],number);
	str = "";
	bRet = WriteFile(serial,&outBuf,number,&bytesWritten,NULL);
	do
	{
		bRet = ReadFile(serial,&inChar,1,&bytesRead,NULL);
		str = str + inChar;
	} while (inChar != '*');
	return (str.find("/MTC") != str.npos);
}
//====================================================================//
string HexVal(BYTE b)
{
	string hex = "0123456789ABCDEF";
	string st  = "~00";

	int i1 = (b & 0x0F);		
	int i2 = (b >>= 4);
	st[1] = hex[i2];
	st[2] = hex[i1];

	return st;
}
void setClock(void)
{
	QueryPerformanceCounter(&clockStart);
}
float getClock(void)
{
	QueryPerformanceCounter(&clockStop);
	clockElapsed.QuadPart = (clockStop.QuadPart - clockStart.QuadPart);
	return ((float)clockElapsed.QuadPart /(float)clockFreq.QuadPart);
}
