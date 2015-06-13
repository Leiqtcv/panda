//
//tools.cpp
//
//#define FSM
#include "stdafx.h"
#include "tools.h"

int InitializeWinsock(void)
{
    WSADATA wsaData;
    int iResult = WSAStartup(MAKEWORD(2,2), &wsaData);
    if (iResult != 0) {
        printf("WSAStartup failed with error: %d\n", iResult);
        return -1;
    }
	return 0;
}
int ConnectServer(SOCKET &ConnectSocket, char *host)
{
    struct addrinfo *result = NULL,
                    *ptr = NULL,
                    hints;

	ZeroMemory( &hints, sizeof(hints) );
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
    // Resolve the server address and port
    int iResult = getaddrinfo(host, DEFAULT_PORT,
        &hints, &result);
    if ( iResult != 0 ) {
        WSACleanup();
        return -1;
    }
    // Attempt to connect to an address until one succeeds
    for(ptr=result; ptr != NULL ;ptr=ptr->ai_next) {

        // Create a SOCKET for connecting to server
        ConnectSocket = socket(ptr->ai_family, ptr->ai_socktype,
            ptr->ai_protocol);
        if (ConnectSocket == INVALID_SOCKET) {
            WSACleanup();
            return -1;
        }
        // Connect to server.
        iResult = connect( ConnectSocket, ptr->ai_addr,
            (int)ptr->ai_addrlen);
        if (iResult == SOCKET_ERROR) {
            closesocket(ConnectSocket);
            ConnectSocket = INVALID_SOCKET;
            continue;
        }
        break;
    }
    freeaddrinfo(result);
    if (ConnectSocket == INVALID_SOCKET) {
        WSACleanup();
        return -1;
    }
	return 0;
}
int ConnectClient(SOCKET &ListenSocket,SOCKET &ClientSocket)
{
    struct addrinfo *result = NULL,
                    hints;

	ZeroMemory( &hints, sizeof(hints) );
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
	hints.ai_flags    = AI_PASSIVE;
    // Resolve the client address and port
    int iResult = getaddrinfo(NULL, DEFAULT_PORT,
        &hints, &result);
    if ( iResult != 0 ) {
        printf("getaddrinfo failed with error: %d\n", iResult);
        WSACleanup();
        return -1;
    }
    // Create a SOCKET for connecting to server
    ListenSocket = socket(result->ai_family, result->ai_socktype,
        result->ai_protocol);
    if (ListenSocket == INVALID_SOCKET) {
        printf("socket failed with error: %ld\n", WSAGetLastError());
        freeaddrinfo(result);
        WSACleanup();
        return -1;
    }
    // Setup the TCP listening socket
    iResult = bind( ListenSocket, result->ai_addr,
        (int)result->ai_addrlen);
    if (iResult == SOCKET_ERROR) {
        printf("bind failed with error: %d\n", WSAGetLastError());
        closesocket(ListenSocket);
        WSACleanup();
        return -1;
    }
    freeaddrinfo(result);
    iResult = listen(ListenSocket, SOMAXCONN);
    if (iResult == SOCKET_ERROR) {
        printf("listen failed with error: %d\n", WSAGetLastError());
        closesocket(ListenSocket);
        WSACleanup();
        return -1;
    }
    // Accept a client socket
    ClientSocket = accept(ListenSocket, NULL, NULL);
    if (ClientSocket == INVALID_SOCKET) {
        printf("accept failed with error: %d\n", WSAGetLastError());
        closesocket(ListenSocket);
        WSACleanup();
        return -1;
    }
    // No longer need server socket
    closesocket(ListenSocket);
	return 0;
}
int SendBuffer(SOCKET ConnectSocket, char *buffer)
{
	int iResult = send( ConnectSocket, buffer,
        (int)strlen(buffer), 0 );
    if (iResult == SOCKET_ERROR) {
        printf("send failed with error: %d\n",
            WSAGetLastError());
        closesocket(ConnectSocket);
        WSACleanup();
        return -1;
    }
	return iResult;
}
int sendRecord(SOCKET ConnectSocket,char *dataRecord,int size)
{
	int iResult = send( ConnectSocket, dataRecord, size, 0 );
    if (iResult == SOCKET_ERROR) {
        printf("send failed with error: %d\n",
            WSAGetLastError());
        closesocket(ConnectSocket);
        WSACleanup();
        return -1;
    }
	return iResult;
}

int ReceiveBuffer(SOCKET ConnectSocket, char *buffer, int size)
{
	int iResult = recv(ConnectSocket, buffer, size, 0);

	return iResult;
}
int ReceiveRecord(SOCKET ConnectSocket, double *dataRecord, int size)
{
	timeval time;
	time.tv_sec  = 0;
	time.tv_usec = 1;

	fd_set fd;
	fd.fd_count = 1;
	fd.fd_array[0] = ConnectSocket;

	if (select(1,&fd,NULL,NULL,&time) == 0)
		return 0;

	int iResult = recv(ConnectSocket,(char *)dataRecord, size, 0);

	return iResult;
}
int CloseConnection(SOCKET ConnectSocket,int how)
{
    int iResult = shutdown(ConnectSocket, how);
    if (iResult == SOCKET_ERROR) {
        printf("shutdown failed with error: %d\n",
            WSAGetLastError());
        closesocket(ConnectSocket);
        WSACleanup();
        return -1;
    }
	return 0;
}
void CleanupConnection(SOCKET ConnectSocket)
{
    closesocket(ConnectSocket);
    WSACleanup();
}
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
int GetRandom(int min, int max)
{
	if (max <= 0)
		return min;

	float f = rand();
	f = f / RAND_MAX;
	f = f*( (float) (max - min + 1));

	return (min + ((int) f));
}
#ifdef FSM
//====================================================================//
// LPTdata    0x378
// LPTstatus  0x379
// LPTcontrol 0x37a
//====================================================================//
short _stdcall Inp32(short PortAddress);
void _stdcall Out32(short PortAddress, short data);
int readLPT1(short port)
{
	int inp = Inp32(port);
	
	return inp;
}
void writeLPT1(short port, short val)
{
	Out32(port, val);
}
#endif