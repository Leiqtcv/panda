#include "windows.h"
#include "stdio.h"
#include "mex.h"
#include "math.h"
#include "time.h"
#include "wsc32.h"
#include "string.h"

// rs232 errors
int errNoError     =  0;
int errTimeOut     = -1;    // time out error (elapsed time > 1000 mSec)
int errInputArg    = -2;    // two input arguments are needed
int errNotFunction = -3;
int errInitialize  = -4;

/*
	MEX-Function [resp msg] = rs232(mode, arg);
    mode (int) = 0 => initialize port com1
    mode (int) = 1 => transmit string to micro controller
    mode (int) = 2 => receive string from micro controller
    mode (int) = 5 => put stims
                      first row: nStim, ITI
                      next rows: stims
    mode (int) = 6 => get trial results
                      first row:  nStim, ITI, time span trial, -1
                      next rows: stim, state, Ton, Toff
    mode (int) = 9 => close port com1
    arg (string) parameters or command
 
    resp (string) respons micro controller
    msg(0) (int) 0 => no error
    msg(0) (int)-1 => time out
    msg(0) (int)-2 => wrong number of input arguments 
    msg(0) (int)-3 => not an implemented function
    msg(0) (int)-4 => Initialize error;
    
    msg(1) (int) elapsed time (mSec)
    call (string) = copy of arg
 ************************************************************************
    initialize com port 1
	[resp msg] = rs232(0, ''])   	default: timeOut=1000 baudRate=115200
	[resp msg] = rs232(0, [timeOut baudRate])
    resp: ''
    error: Initialize
 ************************************************************************
*/
int     com = 0;
int     LF = 10;
long    timeOnEnter;
int     timeOut  = 1000;
int     baudRate = 115200;

char    outBuf[128];
char    inBuf[128];
char    tmpBuf[128];
char    wrd[10];

int     iBuf[4];

int Transmit(char *arg) {
    int i, n, d;
    n = sprintf(outBuf,"%s\n",arg);
    d = SioPuts(com, (LPSTR)outBuf, n);
    return d;
}

int ReceiveLine() {
    bool EOL = false;
    int  n, d, d1 = 0;
    int  len = 0;
    while (!EOL) {    // waiting for a LF
        len = SioRxQue(com);
        if (len > 0) {
            // Gets reads the smaller of 128 and number of bytes
            // in receive buffer (len)
            d = SioGets(com, tmpBuf, 128);
            n = 0;
            while ((n < d) && (!EOL)) {
                if (tmpBuf[n] == LF) 
                    EOL = true;
                else
                    inBuf[d1++] = tmpBuf[n];
                n++;
            }
            inBuf[d1] = 0;

        }
        if ((clock()-timeOnEnter) > timeOut) { // time out
            EOL = true;
            len = errTimeOut;
        }
    }
    return d1; // = len
}

int getWord(int inpPnt) {
    int pnt =0;
	while ((inBuf[inpPnt] != ' ') && (inBuf[inpPnt] != '\0')) {
		wrd[pnt++] = inBuf[inpPnt++];
	}
	wrd[pnt] = '\0';
	if (inBuf[inpPnt] == '\0') inpPnt = -1; else inpPnt++;
    return inpPnt;
}

int getVal(void) 
{
	int val = 0;
	int pnt = 0;
    int min = 1;
    
    pnt = 0;
	if (wrd[0] == '-') {
        pnt =  1;
        min = -1;
    }
    val = wrd[pnt++] - '0';
	while (wrd[pnt] != '\0') {
		val *= 10;
		val += wrd[pnt++] - '0';
	}
    return min*val;
}

// inBuf => iBuf
int getValues() {
    int inpPnt  = 0;
    int outPnt = 0;
    while (inpPnt != -1) {
        inpPnt = getWord(inpPnt);
        iBuf[outPnt++] = getVal();
    }
    return outPnt;
}

void mexFunction(int nLeft, mxArray *pLeft[],
                 int nRight, const mxArray *pRight[]) {
    int nError = 0;
    int mode   = 0;
    int len    = 0;
    int i, d, n, d1, d2;
    char word[10];
    char str[80];
    
	mxArray *xArg;
    char *arg;
    char *stim = &str[0];
    int     index, r, c, colLen, rowLen, nStim, ITI, span, pnt;
    double  *pR, *pL;
	double  *xValues;
    double  *outArray;
	double  *msg;
	bool	leftFlag = false;
    bool    EOL = false;
	
    timeOnEnter = clock();

	if (nRight == 2) {
    	pR = mxGetPr(pRight[0]);     	// pointer to first input arg: mode
        mode = (int) *pR;
       	xArg = pRight[1];               // pointer to second input arg: arg
        xValues = mxGetPr(xArg);
        rowLen  = mxGetN(xArg);         // in case of numbers
        colLen  = mxGetM(xArg);
    	len     = colLen*(rowLen+1);       // or strings
        arg     = mxCalloc(len, sizeof(char)); // allocate space
    	mxGetString(xArg,arg,len);      // arg points now to Arguments

		switch (mode) {
			case 0:	mexPrintf("Initialize com port\n");
                    if (rowLen == 2) {
                        baudRate = (int)xValues[0];
                        timeOut  = (int)xValues[1];
                    } else {
                        timeOut  = 1000;
                        baudRate = 115200;
                    }
		            d = SioKeyCode(169356309);
			        mexPrintf("Keycode = %d\n",d);
				    d = SioReset(-1,1,1);      
					mexPrintf("Reset = %d\n",d);
	                // set Params
		            d = SioParms(-1,WSC_NoParity,WSC_OneStopBit,WSC_WordLength8);       
			        mexPrintf("Parms = %d\n",d);
				    // Port, Receive queue size, Transmit queue size
					d = SioReset(com,1024,1024);      
	                mexPrintf("Initialize com = %d\n",d);
		            // set new baud rate
			        d = SioBaud(0,baudRate);
				    mexPrintf("Baud = %d\n",d);
					if (d < 0)
						nError = errInitialize;
					break;
			case 1:	// mexPrintf("Transmit.......\n");
                    Transmit(arg);
					break;
		    case 2:	// mexPrintf("Receive.........\n");
                    nError = 0;
                    len = ReceiveLine();
                    // SioGets(inBuf) already executed, the first character is lost
                    // when executing it a next time (why ?)
                    if (len > 0) {
						pLeft[0] = mxCreateDoubleMatrix(1,len,mxREAL);
				        pL = mxGetPr(pLeft[0]);
					    for (n=0; n<len; n++) {
						    pL[n] = inBuf[n];
						}
                        // empty the receive buffer
		                d = SioRxClear(0);				
						leftFlag = true;
					} else nError = len; 
					break;
            case 5: //
                    for (n=0; n<colLen; n++) {
                        pnt = 0;
                        for (i=0; i<=rowLen; i++) {
                            if ((arg[(i*colLen)+n] == ' ') || 
                                (arg[(i*colLen)+n] == '\0')) break;
                            stim[pnt++]= arg[(i*colLen)+n];
                        }
                        stim[pnt] = 0;
                        Transmit(stim);
                        len = ReceiveLine();
                    }
                    break;
            case 6: // Get results (cmdSaveTrial)
                    nStim = (int)xValues[0];
                    ITI   = (int)xValues[1];
                    span  = (int)xValues[2];
                    colLen = nStim+1;
                    rowLen = 4;
    				pLeft[0] = mxCreateDoubleMatrix(colLen,rowLen,mxREAL);
                    outArray = mxGetPr(pLeft[0]);
                    outArray[0]        = nStim;
                    outArray[colLen]   = ITI;
                    outArray[2*colLen] = span;
                    outArray[3*colLen] = -1;
                    for (i=1;i<=nStim;i++) {
                        arg[0] = '\0';
                        n = Transmit(arg);
                        len = ReceiveLine();
                        d = getValues();
                        for(n=0;n<rowLen;n++) {
                            outArray[(n*colLen)+i] = iBuf[n];
                        }
                    }
                    leftFlag = true;
                    break;
			case 9:	mexPrintf("Close com port\n");  
		            d = SioDone(com);      
			        mexPrintf("Done = %d\n",d);
					break;
 		    default :
					mexPrintf("(%x) not a implemented function\n",mode);
	                nError = errNotFunction;
					break;
			}
		} else {
		    mexPrintf("Wrong number of input arguments");
			nError = errInputArg;
	}
	if (!leftFlag) {
		pLeft[0] = mxCreateDoubleMatrix(1,len,mxREAL);
 	    pL = mxGetPr(pLeft[0]);
 		for (n=0; n<len; n++) {
 			pL[n] = arg[n];
 		}
	}
	pLeft[1] = mxCreateDoubleMatrix(1, 2, mxREAL);
    msg    = mxGetPr(pLeft[1]);
	msg[0] = nError;
   	msg[1] = (1000*(clock()-timeOnEnter))/CLOCKS_PER_SEC;
}

