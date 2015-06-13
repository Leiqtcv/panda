/**************************************************************************************
Project:	HumanV1	-> 20-06-07
Subject:	Named pipes, server/client
Start:		DJH		-> 20-06-07	version 1.0	
***************************************************************************************/
#include "StdAfx.h"
#include "Pipe.h"

CPipe::CPipe(void)
{
}

CPipe::~CPipe(void)
{
}
/**************************************************************************************
***************************************************************************************/
HANDLE CPipe::Create(bool server, LPTSTR name, 
		           DWORD BufSizeOutp, DWORD BufSizeInp, int Timeout)
{
	HANDLE hPipe;
	if (server)
	{
		hPipe = CreateNamedPipe(name, 
								PIPE_ACCESS_DUPLEX,			// read/write access 
                                PIPE_TYPE_MESSAGE |			// message type pipe 
                                PIPE_READMODE_MESSAGE |		// message-read mode 
                                PIPE_WAIT,					// blocking mode 
                                PIPE_UNLIMITED_INSTANCES,	// max. instances 
                                BufSizeOutp,				// output buffer size 
                                BufSizeInp,					// input buffer size 
                                Timeout,					// client time-out 
                                NULL);						// no security attribute 
	}
	else // client
	{
		hPipe = CreateFile(name,
						   GENERIC_WRITE|GENERIC_READ,
                           0, NULL, OPEN_EXISTING,
                           0, NULL);
	}
	return hPipe;
}
/**************************************************************************************
***************************************************************************************/
bool CPipe::IsConnected(HANDLE hPipe)
{
	return (ConnectNamedPipe(hPipe, NULL) == TRUE);
}
/**************************************************************************************
***************************************************************************************/
bool CPipe::ReadPipe(HANDLE hPipe, void *pBuf, DWORD size,DWORD *res)
{
	bool ok;
	BOOL OK;
	OK = ReadFile(hPipe,	// handle to the file to read
				  pBuf,		// buffer to receive data
				  size,		// number of bytes to read
				  res,		// number of bytes read
				  NULL);	// not overlapped I/O

	ok = (OK == TRUE);
	return ok;
}
/**************************************************************************************
***************************************************************************************/
bool CPipe::WritePipe(HANDLE hPipe, void *pBuf, DWORD size)
{
	BOOL OK;
	bool ok;
	DWORD res;
	OK = WriteFile(hPipe,	// handle
				   pBuf,	// buffer
				   size,	// number of bytes to write
				   &res,	// number of bytes written 
				   NULL);

	ok = (OK == TRUE);
	ok = ok && (size == res);
	return ok;
}
/**************************************************************************************
***************************************************************************************/
DWORD CPipe::SizeReadPipe(HANDLE hPipe)
{
	return GetFileSize(hPipe, NULL);
}
/**************************************************************************************
***************************************************************************************/
bool CPipe::WriteCmd(HANDLE hPipe, int cmd)
{
	int i = cmd;

	bool ok = WritePipe(hPipe, &i, sizeof(i)); 
	
	return ok;
}
/**************************************************************************************
***************************************************************************************/
int CPipe::ReadCmd(HANDLE hPipe)
{
	DWORD res;
	int cmd = -1;

	ReadPipe(hPipe, &cmd, sizeof(cmd),&res);

	return cmd;
}