#pragma once

typedef struct
{
	HANDLE hPipe;
	LPTSTR name;		// "\\\\.\\pipe\\SamplePipe"
	DWORD BufSizeOutp;	// bytes
	DWORD BufSizeInp;
	int   Timeout;
} PIPE_INFO;

class CPipe
{

public:
	CPipe(void);
public:
	~CPipe(void);
public:
	HANDLE	Create(bool server, LPTSTR name, 
		           DWORD BufSizeOutp, DWORD BufSizeInp, int Timeout);

	bool	IsConnected(HANDLE hPipe);

	bool	ReadPipe(HANDLE hPipe, void *pBuf, DWORD size,DWORD *res);
	bool	WritePipe(HANDLE hPipe, void *pBuf, DWORD size);
	DWORD	SizeReadPipe(HANDLE hPipe);
	bool	WriteCmd(HANDLE hPipe, int cmd);
	int 	ReadCmd(HANDLE hPipe);

};
