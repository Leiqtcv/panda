//
//                  Dick Heeren     04-jan-2011
//
//#define test
#include <mex.h>
#include "mexServer.h"
//
double start, stop, elapsed;
char recvbuf[DEFAULT_BUFLEN];
int recvbuflen = DEFAULT_BUFLEN;

int iResult;
SOCKET ListenSocket, ClientSocket;

double dataRecord[184];

//**********************************************************************//
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
int SendRecord(SOCKET ConnectSocket)
{
	int iResult = send(ConnectSocket, (char*)&dataRecord,sizeof(dataRecord), 0);
    if (iResult == SOCKET_ERROR) {
        printf("send failed with error: %d\n",
            WSAGetLastError());
        closesocket(ConnectSocket);
        WSACleanup();
        return -1;
    }
	return iResult;
}
int ReceiveRecord(SOCKET ConnectSocket)
{
    return recv(ConnectSocket, (char*)&dataRecord,sizeof(dataRecord), 0);
}
//**********************************************************************//
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
// 	Declarations
    double *outArray;
    int command;
    int num;
    double error;
    
    mxArray *xinpBuf;
    double *inpBuf;
    xinpBuf = prhs[0];
    inpBuf = mxGetPr(xinpBuf);

    for (int n=0; n<inpBuf[0]; n++)
    {
        dataRecord[n] = inpBuf[n];
#ifdef test
        printf("%2d %5.2f\n",n,inpBuf[n]);
#endif
    }

    command = (int) dataRecord[1];
    error   = command; // no error
    if (command < 10)
    {
        switch (command)
        {
            case TCPinit:
                ListenSocket = INVALID_SOCKET;
                ClientSocket = INVALID_SOCKET;
                if (InitializeWinsock() < 0) 
                    error = -1;
                else
                {
                    if (ConnectClient(ListenSocket, ClientSocket) < 0)
                        error = -2;
                }
                plhs[0] = mxCreateDoubleScalar(error);
                break;
            case TCPquery:
                dataRecord[0] = 1;
                dataRecord[1] = command;
                if (SendRecord(ClientSocket) < 0)
                    error = -3;
                else
                {
                    if (ReceiveRecord(ClientSocket) < 0)
                        error = -4;
                }
                plhs[0] = mxCreateDoubleScalar(error);
                break;
            case TCPclose:
                dataRecord[0] = 1;
                dataRecord[1] = command;
                iResult = command;
                if (SendRecord(ClientSocket) < 0)
                    iResult = -3;
                else
                {
                    if (ReceiveRecord(ClientSocket) < 0)
                        error = -4;
                }
                if (CloseConnection(ClientSocket, SD_SEND) < 0)
                    iResult = -4;
                plhs[0] = mxCreateDoubleScalar(error);
                while (iResult > 0)
                {
                    iResult = ReceiveRecord(ClientSocket);
                }
                CleanupConnection(ClientSocket);
                break;
        }
    }
    else
    {
        switch (command)
        {
            case cmdGetStatus:
                 SendRecord(ClientSocket);
                 if (ReceiveRecord(ClientSocket) > 0)
                 {
                    num = dataRecord[0]; 
                    plhs[0] = mxCreateDoubleMatrix(num,1,mxREAL);
                    outArray = mxGetPr(plhs[0]);
                    for (int n=0; n<num; n++)
                    {
                        outArray[n] = dataRecord[n];
                    }
                 }
                 else
                 {
                     plhs[0] = mxCreateDoubleScalar(-1);
                 }
                 break;
            case cmdSetClock:
                 SendRecord(ClientSocket);
                 if (ReceiveRecord(ClientSocket) > 0)
                     plhs[0] = mxCreateDoubleScalar(command);
                 else
                     plhs[0] = mxCreateDoubleScalar(-1);
                 break;
            case cmdGetClock:
                 SendRecord(ClientSocket);
                 if (ReceiveRecord(ClientSocket) > 0)          // data
                 {
                     num = dataRecord[0]; 
                     plhs[0] = mxCreateDoubleMatrix(num,1,mxREAL);
                     outArray = mxGetPr(plhs[0]);
                     for (int n=0; n<num; n++)
                     {
                         outArray[n] = dataRecord[n];
                     }
                 }
                 else
                 {
                     plhs[0] = mxCreateDoubleMatrix(2,1,mxREAL);
                     outArray[0] =  2;
                     outArray[1] = -1;
                 }
                 break;
            case cmdNextTrial:
                 SendRecord(ClientSocket);
                 if (ReceiveRecord(ClientSocket) > 0)          // data
                 {
                     num = dataRecord[0]; 
                     plhs[0] = mxCreateDoubleMatrix(num,1,mxREAL);
                     outArray = mxGetPr(plhs[0]);
                     for (int n=0; n<num; n++)
                     {
                         outArray[n] = dataRecord[n];
                     }
                 }
                 else
                 {
                     plhs[0] = mxCreateDoubleMatrix(2,1,mxREAL);
                     outArray[0] =  2;
                     outArray[1] = -1;
                 }
                 break;
            case cmdSetPIO:
                  SendRecord(ClientSocket);
                  if (ReceiveRecord(ClientSocket) > 0)
                      plhs[0] = mxCreateDoubleScalar(command);
                  else
                      plhs[0] = mxCreateDoubleScalar(-1);
                 break;
            case cmdGetPIO:
                 SendRecord(ClientSocket);
                 if (ReceiveRecord(ClientSocket) > 0)          // data
                 {
                     num = dataRecord[0]; 
                     plhs[0] = mxCreateDoubleMatrix(num,1,mxREAL);
                     outArray = mxGetPr(plhs[0]);
                     for (int n=0; n<num; n++)
                     {
                         outArray[n] = dataRecord[n];
                     }
                 }
                 else
                 {
                     plhs[0] = mxCreateDoubleMatrix(2,1,mxREAL);
                     outArray[0] =  2;
                     outArray[1] = -1;
                 }
                 break;
            case cmdTestLeds:
                 SendRecord(ClientSocket);
                 if (ReceiveRecord(ClientSocket) > 0)
                     plhs[0] = mxCreateDoubleScalar(command);
                 else
                     plhs[0] = mxCreateDoubleScalar(-1);
                 break;
        }
    }
}
