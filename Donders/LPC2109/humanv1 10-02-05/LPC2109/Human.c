/*************************************************************************
						    Human.c

Project		 				Controller		            DJH MBFYS CNS UMCN
--------------------------------------------------------------------------
Versie  0.00	30-mar-2006 Start uitzoeken mogelijkheid toepassen micro 
							controller voor lokalisatie experimenten en
							de ontwikkeling van de interrupt routines
      	1.00	14-jan-2008 Toevoegen van commentaar
		1.02	04-feb-2008	Resetten van boog en sky leds 
		1.03	03-mar-2009 Leds+Blink
		1.30    19-okt-2009	Toevoeg stim Las
**************************************************************************/
#include <lpc21xx.h>
#include <stdio.h>
#include <inttypes.h>

#include "Human.h"
#include "Config.h"
#include "Clock.h"
#include "Serial.h"
#include "i2c.h"
#include "ADC.h"											   

char version[] = "LPC2119\t - Human \t1.30 19-Oct-2009\n";

char inBuf[80];		   		// gebruikt voor RS232 communicatie
char outBuf[80];
int  inpPnt, outPnt;   		// de bijbehorende pointers
char wrd[10];				// geheugen voor 1 woord uit inBuf
int32_t	 nBuffer[12]; 		// stimulus plus parameters uit inBuf
int  nStatus;				// toestand state-machine
int  nStimLeds = 0;			// index stimLeds in record stim;
unsigned int startTime;		// begin van de ITI, daarna begin van een trial						 	
unsigned int curTime;		// de huidige tijd in msec
int nStim   = 0;
int newStim = 0;
recStim stim[20];           // er kunnen maximaal 20 simuli in 1 trial
							// dit kan uitgebreid worden

int tmp[7];
recLedIC Leds[3][2][4];		// [1-voor/2-achter] [Interne selectie PCA 9532 LS0..LS3]
                            // {3-parallel voor]
recLedIC Sky[13];       	// 5,9,14,20,27,35,44,54,65 graden

int boards[8]   = {0xF7,0xFB,0xFD,0xFE,0x7F,0xBF,0xDF,0xEF};  // pre selectie speaker
int speakers[8] = {0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01};
int gain1[8]    = {0x7F,0xDF,0xF7,0xFD,0x7F,0xDF,0xF7,0xFD};  // snd1
int gain2[8]    = {0xBF,0xEF,0xFB,0xFE,0xBF,0xEF,0xFB,0xFE};  // snd2
// signaal: bit=0->signaal2, bit=1->signaal1
int statusBoards[8][3];  // [board][signal, gain1..4, gain5..8]
                         // 0x4E=board, 0x40=signal, 0x44 gain1..4, 0x42 gain1..8  
//q int lastBoard = 0;
int  tBuf[6];       /* 	tijd doorgebracht in een toestand
					 	0 =	inlezen van een trial
						1 =	wachten op start commando PC
						2 =	start ITI
						3 =	duur van een trial
						4 =	duur wegschrijven trial gegevens
						5 = N.U.
					*/		  

int  snd12Flag;		// trigger mode RP2's
					// 1=RP2_1, 2=RP2_2, 3=beide RP2's
int  tmpSnd1[4];   	// [0]=flag, [1]time mode [2]=time [3]=index
int  tmpSnd2[4];

void Delay (unsigned long a)
{
    while (--a != 0);
}
/**************************************************************************************
	Voor het aansturen van de boog- en skyleds worden PCA 9532 IC's gebruikt.
	De PCA 9532 is een 16-bit I2C led dimmer
**************************************************************************************/
void LedOnOff(int index, int level, int OnOff, int parallel)
{
	int n, ic, led, ls, tmp;
	unsigned char buffer[4];
	int PWM1 = 0x14;	// (autoincrement (16) + register
	int LS0  = 0x06;	
	int LS1  = 0x07;	
	int LS2  = 0x08;	
	int LS3  = 0x09;
	                //   1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31}
	int ledsIndex[] = { 13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,15,14};

	// Leds aan de voorzijde zijn genummerd van 1..29, de linker led = 30 en de rechter = 31
	// De leds aan de achterzijde van 101..129
	if (index > 100) led = index - 100; else led = index; // led in de range van 1..29 
	led = ledsIndex[led-1];								  // hernummering ivm elektronica
	if (led <= 16) ic = 0; else ic = 1;					  // IC 1..2
    led = led - ic*16;									  // led 1..16
	ls = (led-1)/4;										  // led selector 1..4

	if (index < 100) n = 0; else n = 1;
	if (parallel == true) n = 2;
	buffer[0] = Leds[n][ic][ls].address;				  // adres led-IC
 	I2C_SendByte(0x72, 1, buffer);   					  // laad pre-selectie met adres

	// set level
	buffer[0] = PWM1;				// subaddress
	buffer[1] = 0;					// PSC1
	buffer[2] = level & 0xFF;
	I2C_SendByte(0xC0, 3, buffer);	// preselectie bepaalt welk IC adres C0 heeft

	// update data
//	if (led > 8) led = led - 8;
    led = (led-1) % 4;
	tmp = (0x03 << (2*(led)));  	// 11 = blink at PWM1 rate
	if (OnOff == ON)
		Leds[n][ic][ls].data |= tmp;
	else 
		Leds[n][ic][ls].data &= ~tmp;

	switch(ls)
	{
	case 0:	buffer[0] = LS0; break;
	case 1:	buffer[0] = LS1; break;
	case 2:	buffer[0] = LS2; break;
	case 3:	buffer[0] = LS3; break;
	}
//	if (led < 5)
	{
		buffer[1] = Leds[n][ic][ls].data & 0xFF;
	}
//	else
	{
//		buffer[1] = ((Leds[n][ic].data >> 8) & 0xFF);
	}
	I2C_SendByte(0xC0, 2, buffer);

	buffer[0] = 0xFF;
	I2C_SendByte(0x72,1,buffer);
		
}

void ClearArc(void)
{
	int index;
	for (index = 1; index <= 31; index++)
		LedOnOff(index, 0, OFF, false);
	for (index = 101; index <=129; index++)
		LedOnOff(index, 0, OFF, false);
	for (index = 1; index <= 31; index++)
		LedOnOff(index, 0, OFF, true);
}

void ClearSky(void)
{
	int spaak, led;
	SkyOnOff(0, 1, 0, OFF);
	SkyOnOff(0, 2, 0, OFF);
	for (spaak = 1; spaak <= 12; spaak++)
	{
		for (led = 0; led <= 7; led++)
		{
			SkyOnOff(spaak, led, 0, OFF);
		}
	}
}

void SkyOnOff(int spaak, int led, int level, int OnOff)
{
	int tmp;
	unsigned char buffer[4];
	int PWM1 = 0x14;	// (autoincrement (16) + register
	int LS0  = 0x06;	
	int LS1  = 0x07;	

	if (spaak == 0)
	{
		buffer[0] = 0xEF;
	}
	else
	{
		if (spaak < 9)
			buffer[0] = ~(1 << (spaak-1));
		else
			buffer[0] = ~(1 << (spaak-9));
	}
 	I2C_SendByte(Sky[spaak].address, 1, buffer);  // laad pre-selectie met spaak-IC
	// set level
	buffer[0] = PWM1;	// subaddress
	buffer[1] = 0;		// PSC1
	buffer[2] = level & 0xFF;
	I2C_SendByte(0xC0, 3, buffer);
	// update data
	if (spaak == 0)
	{
		buffer[0] = LS0;
		tmp = (0x03 << (2*(led-1)));
		if (OnOff == ON)
			Sky[spaak].data |= tmp;
		else 
			Sky[spaak].data &= ~tmp;
		buffer[1] = Sky[spaak].data;
	}
	else
	{
		tmp = (0x03 << (2*(led-1)));
		if (OnOff == ON)
			Sky[spaak].data |= tmp;
		else 
			Sky[spaak].data &= ~tmp;
		if (led < 5)
		{
			buffer[0] = LS0;
			buffer[1] = (Sky[spaak].data & 0xFF);
		}
		else
		{
			buffer[0] = LS1;
			buffer[1] = ((Sky[spaak].data >> 8) & 0xFF);
		}
	}
	I2C_SendByte(0xC0, 2, buffer);
	buffer[0] = 0xFF;
	I2C_SendByte(Sky[spaak].address, 1, buffer);
}

int main (void)
{
	int num, EOL, abort;
	int inChar;
	int i, n, done;
	unsigned int Seconds;
	int LS0 = 0x06;
	int LS1 = 0x07;
	
	num      = 0;
	EOL      = 0;
	abort    = 0;
	if (InitAll()  != 0)
		return -1;

	nStatus = statInit;
	Clock_Reset();
	curTime = 0;

	done = 0;
	for (;;)
	{
		if (UART0_RxNumber() > 0)
		{
			inChar = UART0_Get();
			if (inChar == ESCAPE) abort = 1;
 			if (inChar == ENTER)  
			{
				EOL   = 1; 			// new command
				inBuf[num] = 0;
				splitInput();
			}
			if (EOL == 0) inBuf[num++] = (char) inChar;
		}
		curTime = Clock_GetTicks();

		if (abort == 1)
		{
//			nStatus = statAbort;
			InitAll();
		 	nStatus = statInit;
			Clock_Reset();
			curTime = 0;
			EOL = 0;
			num = 0;
			abort = 0;
		}
		if ((EOL == 1) && (nBuffer[1] == cmdTime)) GetTime();
		if (nStatus == statInit)
		{
			if (EOL == 1)
			{
				if (nBuffer[1] == cmdSpeakersOff) SpeakersOff();
				if (nBuffer[1] == cmdInfo)   ReturnInfo();		
				if (nBuffer[1] == cmdGetPIO) GetPIO();

				if (nBuffer[1] == cmdNewTrial) 
				{
					startTime = nBuffer[2]; 	// ITI
					Clock_Reset();
					curTime = 0;
					nStatus = statTrial;
					nStim = 0;
					newStim = nBuffer[3];  		// komt van PC
					i = startTime;
					n = sprintf(outBuf,"%d\n",i); 
					i = UART0_Str(outBuf, n);
					tmpSnd1[0] = 0;
					tmpSnd2[0] = 0;
				}
				EOL = 0;
				num = 0;
			}
		}

	 	if (nStatus == statTrial)
	 	{
			if (EOL == 1)
			{
				switch (nBuffer[1])
				{
				case stimLed:	stim[nStim].status    = statInit;
							stim[nStim].kind      = stimLed;
							stim[nStim].posX      = nBuffer[2];
							stim[nStim].posY      = nBuffer[3];		
							stim[nStim].level     = nBuffer[4];		
							stim[nStim].startRef  = nBuffer[5];
							stim[nStim].startTime = nBuffer[6];	
							stim[nStim].stopRef   = nBuffer[7];	
							stim[nStim].stopTime  = nBuffer[8];	
							break;
				case stimLeds:	stim[nStim].status    = statInit;
							stim[nStim].kind      = stimLeds;
							stim[nStim].posX      = nBuffer[2];
							stim[nStim].posY      = nBuffer[3];		
							stim[nStim].level     = nBuffer[4];		
							stim[nStim].startRef  = nBuffer[5];
							stim[nStim].startTime = nBuffer[6];	
							stim[nStim].stopRef   = nBuffer[7];	
							stim[nStim].stopTime  = nBuffer[8];	
							stim[nStim].index     = nBuffer[9];	
							nStimLeds = nStim;
							break;
				case stimBlink:	stim[nStim].status    = statInit;
							stim[nStim].kind      = stimBlink;
							stim[nStim].posX      = nBuffer[2];
							stim[nStim].posY      = nBuffer[3];		
							stim[nStim].level     = nBuffer[4];		
							stim[nStim].startRef  = nBuffer[5];
							stim[nStim].startTime = nBuffer[6];	
							stim[nStim].stopRef   = nBuffer[7];	
							stim[nStim].stopTime  = nBuffer[8];	
							stim[nStim].index     = nBuffer[9];	
							break;
				case stimAcq:	stim[nStim].status    = statInit;
							stim[nStim].kind      = stimAcq;
							stim[nStim].startRef  = nBuffer[2];
							stim[nStim].startTime = nBuffer[3];	
							break;
				case stimSnd1:	stim[nStim].status    = statInit;
							stim[nStim].kind      = stimSnd1;
							stim[nStim].posX      = nBuffer[2];
							stim[nStim].posY      = nBuffer[3];		
							stim[nStim].index     = nBuffer[4];	
							stim[nStim].level     = nBuffer[5];		
							stim[nStim].startRef  = nBuffer[6];
							stim[nStim].startTime = nBuffer[7];
							stim[nStim].width     = nBuffer[8];
							tmpSnd1[0] = 1;
							tmpSnd1[1] = nBuffer[6];
							tmpSnd1[2] = nBuffer[7]; 
							tmpSnd1[3] = nStim;
							break;
				case stimSnd2:	stim[nStim].status    = statInit;
							stim[nStim].kind      = stimSnd2;
							stim[nStim].posX      = nBuffer[2];
							stim[nStim].posY      = nBuffer[3];		
							stim[nStim].index     = nBuffer[4];	
							stim[nStim].level     = nBuffer[5];		
							stim[nStim].startRef  = nBuffer[6];
							stim[nStim].startTime = nBuffer[7];	
							stim[nStim].width     = nBuffer[8];
							tmpSnd2[0] = 1;
							tmpSnd2[1] = nBuffer[6];
							tmpSnd2[2] = nBuffer[7];
							tmpSnd2[3] = nStim;
							break;
				case stimTrg0:stim[nStim].status    = statInit;
							stim[nStim].kind      = stimTrg0;
							stim[nStim].edge	  = nBuffer[2];
							stim[nStim].bitNo     = nBuffer[3];
							stim[nStim].startRef  = nBuffer[4];
							stim[nStim].startTime = nBuffer[5];	
							stim[nStim].event     = nBuffer[6];
							break;
				case stimSky:	stim[nStim].status    = statInit;
							stim[nStim].kind      = stimSky;
							stim[nStim].posX      = nBuffer[2];
							stim[nStim].posY      = nBuffer[3];		
							stim[nStim].level     = nBuffer[4];		
							stim[nStim].startRef  = nBuffer[5];
							stim[nStim].startTime = nBuffer[6];	
							stim[nStim].stopRef   = nBuffer[7];	
							stim[nStim].stopTime  = nBuffer[8];	
							break;
				case stimInp1:	stim[nStim].status = statDone;    // start en duur wordt bepaald door SND1
							stim[nStim].kind      = stimInp1;
							break;
				case stimInp2:	stim[nStim].status = statDone;
							stim[nStim].kind      = stimInp2;
							break;
				case stimLas:	stim[nStim].status = statInit;
							stim[nStim].kind       = stimLas;
							stim[nStim].bitNo      = nBuffer[2];
							stim[nStim].startRef   = nBuffer[3];
							stim[nStim].startTime  = nBuffer[4];	
							stim[nStim].stopRef    = nBuffer[5];	
							stim[nStim].stopTime   = nBuffer[6];	
							break;
				}
				if (nStim < (newStim-1))
					nStim++;
				else
				{
					nStatus = statWait;
					tBuf[0] = curTime;
					Clock_Reset();
					snd12Flag = 0;
					// sndflag=3 betekend dat beide rp2's gelijk moeten worden getriggerd.
					for (i = 0; i < 3; i++) 
					{
						if (tmpSnd1[i] == tmpSnd2[i]) snd12Flag++;
					}
				}
				i = curTime;
				n = sprintf(outBuf,"%d\n",i);
				i = UART0_Str(outBuf, n);
				EOL = 0;
				num = 0;
			}
	 	}

		if (nStatus == statWait)
		{
			if (EOL == 1)
			{
				if (nBuffer[1] == cmdStart)
				{
					tBuf[1] = curTime;
					Clock_Reset();
					curTime = 0;
					nStatus = statITI;
					EOL = 0;
					num = 0;
				}
			}
		}

		if (nStatus == statITI)
		{
			if (curTime >= startTime)
			{
				nStatus   = statRun;
				startTime = curTime;
				tBuf[2] = curTime;
				Clock_Reset();
				curTime = 0;
			}
		}

		if (nStatus == statRun)
		{
			done = 0;
			for (i = 0; i <= nStim; i++)
			{
				switch(stim[i].kind)
				{
				case stimLed:  done += ExecLed(i);  break;
				case stimLeds: done += ExecLeds(i); break;
				case stimBlink:done += ExecBlink(i);break;
				case stimSnd1: done += ExecSnd(i);  break;
				case stimSnd2: done += ExecSnd(i);  break;
				case stimTrg0: done += ExecTrg0(i); break;
				case stimAcq:  done += ExecAcq(i);  break;
				case stimSky:  done += ExecSky(i);  break;
				case stimLas:  done += ExecLas(i);  break;
				}
			}
			curTime = Clock_GetTicks();
			
			if (done == 0)
			{
				tBuf[3] = curTime;
			 	nStatus = statWaitPC;
//				EOL = 0;
//				num = 0;
			}
		}

		if (nStatus == statWaitPC)
		{
			if (EOL == 1)
			{
				if (nBuffer[1] == cmdDataMicro)
				{
					Clock_Reset();
					curTime = 0;
					ReturnDataMicro();
					Clock_Reset();
					curTime = 0;
					nStatus = statInit;
					EOL = 0;
					num = 0;
				}
			}
		}

		curTime = Clock_GetTicks();
		Seconds = Clock_GetSeconds();
		if ((Seconds & 0x01) > 0) ClrBitsPar(0x01); else SetBitsPar(0x01);
		if (EOL == 1)
		{
			if (nBuffer[1] == cmdReady)
			{
				if ((nStatus == statWaitPC) || (nStatus == statRun))
					i = done;
				else
					 i = -1;
				n = sprintf(outBuf,"%d\n",i); 
				i = UART0_Str(outBuf, n);
			}
			EOL = 0;
			num = 0;
		}
	}

	return 0;
}

int InitAll()
{
	unsigned char buffer[4];
	int n, i;
	
	LPCinit();
	IODIR0  = 0x00000FF0;	// P0.4-P0.11 as output bit 0..7
							// PO.18-P0.25 as input bit 0..7
  	IOSET0 |= 0x00000FF0;	// LED off 

	Clock_Init();			// interrupt 0
	I2C_Init();				// interrupt 1
	UART0_Init();			// interrupt 2
   	ADC_Init();				// interrupt 3, channel 0

//	nieuw: voor-onder, voor-boven, achter-onder, achter-boven.
	for (n=0; n < 3; n++)
	{
		for (i=0; i < 4; i++)
		{
			Leds[n][0][i].data    = 0; 
			Leds[n][0][i].level   = 0;
			Leds[n][1][i].data    = 0; 
			Leds[n][1][i].level   = 0;
		}
	}
	for (i=0; i < 4; i++)
	{
		Leds[0][0][i].address = 0xF7; // Voor 1-15
		Leds[0][1][i].address = 0xFB; // Voor 16-31
		Leds[1][0][i].address = 0xFD; // Achter 101-115
		Leds[1][1][i].address = 0xFE; // Achter 116-129
		Leds[2][0][i].address = 0x7F; // Voor 1-15 parallel voor blinken
		Leds[2][1][i].address = 0xBF; // Voor 16-31	 parallel
	}


	Sky[ 0].address  = 0x76;  Sky[ 0].data 	 = 0; Sky[ 0].level   = 0x00;
	Sky[ 1].address  = 0x74;  Sky[ 1].data 	 = 0; Sky[ 1].level   = 0x00;
	Sky[ 2].address  = 0x74;  Sky[ 2].data 	 = 0; Sky[ 2].level   = 0x00;
	Sky[ 3].address  = 0x74;  Sky[ 3].data 	 = 0; Sky[ 3].level   = 0x00;
	Sky[ 4].address  = 0x74;  Sky[ 4].data 	 = 0; Sky[ 4].level   = 0x00;
	Sky[ 5].address  = 0x74;  Sky[ 5].data 	 = 0; Sky[ 5].level   = 0x00;
	Sky[ 6].address  = 0x74;  Sky[ 6].data 	 = 0; Sky[ 6].level   = 0x00;
	Sky[ 7].address  = 0x74;  Sky[ 7].data 	 = 0; Sky[ 7].level   = 0x00;
	Sky[ 8].address  = 0x74;  Sky[ 8].data 	 = 0; Sky[ 8].level   = 0x00;
	Sky[ 9].address  = 0x76;  Sky[ 9].data 	 = 0; Sky[ 9].level   = 0x00;
	Sky[10].address  = 0x76;  Sky[10].data 	 = 0; Sky[10].level   = 0x00;
	Sky[11].address  = 0x76;  Sky[11].data 	 = 0; Sky[11].level   = 0x00;
	Sky[12].address  = 0x76;  Sky[12].data 	 = 0; Sky[12].level   = 0x00;
	ClearSky();
	ClearArc();

	buffer[0] = 0x00;
	buffer[1] = 0x76;
	buffer[2] = 0x00;														   
	buffer[3] = 0x00;
	I2C_SendByte(0x70, 4, buffer);

	for (i=0; i < 8; i++)
	{
		buffer[0] = boards[i];
		I2C_SendByte(0x4E, 1, buffer);
		buffer[0] = 0xFF;
		I2C_SendByte(0x42, 1, buffer);
		I2C_SendByte(0x44, 1, buffer);
		statusBoards[i][0] = 0xFF;	
		statusBoards[i][1] = 0xFF;	
		statusBoards[i][2] = 0xFF;	
	}
	ClrBitsPar(outRP2_1);  // sound trigger
	ClrBitsPar(outRP2_2);  // sound trigger
	ClrBitsPar(outRA16);   // acq   trigger

	return(0);
}
void getWord(void) 
{
	int pnt = 0;
	while ((inBuf[inpPnt] != ';') && (inBuf[inpPnt] != '\0'))
	{
		wrd[pnt++] = inBuf[inpPnt++];
	}
	wrd[pnt] = '\0';
	if (inBuf[inpPnt] == '\0') inpPnt = -1; else inpPnt++;
}

int getVal(void) 
{
	int val = 0;
	int pnt = 0;
	if (wrd[0] == '-')
	{
		val = -1*(wrd[1] - '0');
		pnt = 2;
		while (wrd[pnt] != '\0')
		{
			val *= 10;
			val -= wrd[pnt++] - '0';
		}
	}
	else
	{
		val = (wrd[0]- '0');
		pnt = 1;
		while (wrd[pnt] != '\0')
		{
			val *= 10;
			val += wrd[pnt++] - '0';
		}
	}
	return val;
}

void splitInput(void)					
{
	outPnt = 0;
	if (inBuf[0] == '$')
	{
		inpPnt = 1;
		outPnt = 1;
		while (inpPnt != -1)
		{
			getWord();
			nBuffer[outPnt++] = getVal();
		}
	}
	nBuffer[0] = outPnt-1;
}

void ReturnInfo(void)
{
	int n, i;

	n = 0;
	while ((n < 80) && (version[n] > 0)) n++;
	i = UART0_Str(version, n);
	nBuffer[1] = 0;
}

 void GetSamples(void)				   
{
	adc_buffer buffer;
	int start, i, n;
	start = Clock_GetTicks();
 	buffer  = ADC_GetSamples();
	n = sprintf(outBuf,"%d;%d;%d;%d;%d\n",start, 
	buffer.data[0],buffer.data[1],buffer.data[2],buffer.data[3]);
	i = UART0_Str(outBuf, n);
}

void ChannelOn(void)
{
	ADC_Select(nBuffer[2]);
}

void ChannelOff(void)
{
	ADC_Select(-1*nBuffer[2]);
}
void GetPIO(void)
{
  	int i, n, val;

	val = GetBitsPar();
	n = sprintf(outBuf,"%d\n",val);
	i = UART0_Str(outBuf, n);
}

void Trigger(int bit, int Up)
{
	if (Up == true)
	{
		SetBitsPar(bit);
		Delay(10000);			 // 10000 ca 1.5 mSec
		ClrBitsPar(bit);
	}
	else
	{
		ClrBitsPar(bit);
		Delay(10000);			 
		SetBitsPar(bit);
	}
}

void SetBitsPar(int i)
{
	IOSET0 = (i & 0xFF) << 4;		   
}


void ClrBitsPar(int i)
{
	IOCLR0 = (i & 0xFF) << 4;
}

int GetBitsPar(void)
{
	int i;
	i = (IOPIN0 >> 17) & 0x00FF;
	return i;
}

int TstBitPar(int bit)
{
	int i;
	i = GetBitsPar();
	i = (i & bit);

	return i;
}
void WaitForEnter(void)
{
	int inChar;
	inChar = 0;
	
	while (inChar == 0)
	{
		if (UART0_RxNumber() > 0)
		{
			inChar = UART0_Get();
		}
	}
}

void ReturnDataMicro(void)
{
	int t0, i, n, lp;

	n = sprintf(outBuf,"%d;%d;%d\n",startTime,curTime,nStim);
 	i = UART0_Str(outBuf, n);
	WaitForEnter();

	// find start acq
	t0 = 0; // incase of missing acq
	for (lp=0; lp <=nStim; lp++)
	{
		if (stim[lp].kind == stimAcq)
		{
			t0 = stim[lp].startTime;
		}
	}

 	for (lp=0; lp <= nStim; lp++)
	{
		switch (stim[lp].kind)
		{
		case stimLed:	n = sprintf(outBuf,"%4d;%4d;%4d;%5d;%5d;%4d;   1; NaN; NaN\n",
						stimLed, stim[lp].posX,stim[lp].posY, 
						stim[lp].startTime-t0,stim[lp].stopTime-t0, stim[lp].level);
						break;													 
		case stimLeds:	n = sprintf(outBuf,"%4d;%4d;%4d;%5d;%5d;%4d;   %d; NaN; NaN\n",
						stimLeds, stim[lp].posX,stim[lp].posY, 
						stim[lp].startTime-t0,stim[lp].stopTime-t0, stim[lp].level, stim[lp].index);
						break;													 
		case stimBlink:	n = sprintf(outBuf,"%4d;%4d;%4d;%5d;%5d;%4d;   %d; NaN; NaN\n",
						stimBlink, stim[lp].posX,stim[lp].posY, 
						stim[lp].startTime-t0,stim[lp].stopTime-t0, stim[lp].level, stim[lp].index);
						break;													 
		case stimSnd1:	n = sprintf(outBuf,"%4d;%4d;%4d;%5d;%5d;%4d;%4d;%4d; NaN\n",
						stimSnd1, stim[lp].posX,stim[lp].posY, 			 
						stim[lp].startTime-t0,stim[lp].stopTime-t0,stim[lp].level,
						stim[lp].index,stim[lp].width);
						break;
		case stimSnd2:	n = sprintf(outBuf,"%4d;%4d;%4d;%5d;%5d;%4d;%4d;%4d; NaN\n",
						stimSnd2, stim[lp].posX,stim[lp].posY, 			 
						stim[lp].startTime-t0,stim[lp].stopTime-t0,stim[lp].level,
						stim[lp].index,stim[lp].width);
						break;
		case stimAcq:	n = sprintf(outBuf,"%4d; NaN; NaN;%5d;  NaN; NaN; NaN; NaN; NaN\n",
				 		stimAcq, stim[lp].startTime-t0);
						break;
		case stimTrg0:	n = sprintf(outBuf,"%4d; NaN; NaN;%5d;%5d; NaN; NaN;%4d;%4d\n",
				 		stimTrg0, stim[lp].startTime-t0,stim[lp].stopTime-t0,
						stim[lp].bitNo,stim[lp].edge);
						break;
		case stimSky:	n = sprintf(outBuf,"%4d;%4d;%4d;%5d;%5d;%4d;   1; NaN; NaN\n",
						stimSky, stim[lp].posX,stim[lp].posY, 
						stim[lp].startTime-t0,stim[lp].stopTime-t0, stim[lp].level);
						break;													 
		case stimLas:	n = sprintf(outBuf,"%4d; NaN; NaN;%5d;%5d; NaN; NaN;%4d; NaN\n",
				 		stimLas, stim[lp].startTime-t0,stim[lp].stopTime-t0,
						stim[lp].bitNo);
						break;
		case stimInp1:  n = sprintf(outBuf,"%4d; NaN; NaN; NaN;  NaN; NaN; NaN; NaN; NaN\n", stimInp1);
						break;
		case stimInp2:  n = sprintf(outBuf,"%4d; NaN; NaN; NaN;  NaN; NaN; NaN; NaN; NaN\n", stimInp2);
						break;
		}
		i = UART0_Str(outBuf, n);
		WaitForEnter();
	}

	tBuf[4] = Clock_GetTicks();
	n = sprintf(outBuf,"%d;%d;%d;%d;%d\n",
   			tBuf[0],tBuf[1],tBuf[2],tBuf[3],tBuf[4]);
	i = UART0_Str(outBuf, n);
	WaitForEnter();
}

int ExecLed(int i)
{ 
	curTime = Clock_GetTicks();
	if (stim[i].status == statInit)
	{
		if ((stim[i].startRef == 0) && (curTime >= stim[i].startTime))
		{
			LedOnOff(stim[i].posY, stim[i].level, ON, false);
			curTime = Clock_GetTicks();
			stim[i].startTime = curTime;
			stim[i].status = statRun;
		}
		return 1;
	}
	
	if (stim[i].status == statRun)
	{
		if ((stim[i].stopRef == 0) && (curTime >= stim[i].stopTime))
		{
			LedOnOff(stim[i].posY, stim[i].level, OFF, false);
			curTime = Clock_GetTicks();
			stim[i].stopTime = curTime;
			stim[i].status = statDone;
			return 0;
		}
		return 1;
	}

	return 0;
}

int ExecLeds(int i)
{ 	
	int n;
	curTime = Clock_GetTicks();
	if (stim[i].status == statInit)
	{
		if ((stim[i].startRef == 0) && (curTime >= stim[i].startTime))
		{
			for (n = 1;n < 30; n++)
				LedOnOff(n, stim[i].level, ON, false);
			curTime = Clock_GetTicks();
			stim[i].startTime = curTime;
			stim[i].status = statRun;
		}
		return 1;
	}
	
	if (stim[i].status == statRun)
	{
		if ((stim[i].stopRef == 0) && (curTime >= stim[i].stopTime))
		{
			for (n = 1;n < 30; n++)
				LedOnOff(n, stim[i].level, OFF, false);
			curTime = Clock_GetTicks();
			stim[i].stopTime = curTime;
			stim[i].status = statDone;
			return 0;
		}
		return 1;
	}

	return 0;
}
//qq
int ExecBlink(int i)
{ 
	curTime = Clock_GetTicks();
	if (stim[i].status == statInit)
	{
		if ((stim[i].startRef == 0) && (curTime >= stim[i].startTime))
		{
			LedOnOff(stim[i].posY, stim[nStimLeds].level, OFF, false);
			LedOnOff(stim[i].posY, stim[i].level, ON, true);
			curTime = Clock_GetTicks();
			stim[i].startTime = curTime;
			stim[i].status = statRun;
		}
		return 1;
	}
	
	if (stim[i].status == statRun)					   
	{
		if ((stim[i].stopRef == 0) && (curTime >= stim[i].stopTime))
		{
			LedOnOff(stim[i].posY, stim[0].level, OFF, true);
			LedOnOff(stim[i].posY, stim[nStimLeds].level, ON, false);
			curTime = Clock_GetTicks();
			stim[i].stopTime = curTime;
			stim[i].status = statDone;
			return 0;
		}
		return 1;
	}

	return 0;
}

int ExecSky(int i)
{ 
	curTime = Clock_GetTicks();
	if (stim[i].status == statInit)
	{
		if ((stim[i].startRef == 0) && (curTime >= stim[i].startTime))
		{
			SkyOnOff(stim[i].posX, stim[i].posY, stim[i].level, ON);
			curTime = Clock_GetTicks();
			stim[i].startTime = curTime;
			stim[i].status = statRun;
		}
		return 1;
	}
	
	if (stim[i].status == statRun)
	{
		if ((stim[i].stopRef == 0) && (curTime >= stim[i].stopTime))
		{
			SkyOnOff(stim[i].posX, stim[i].posY, stim[i].level, OFF);
			curTime = Clock_GetTicks();
			stim[i].stopTime = curTime;
			stim[i].status = statDone;
			return 0;
		}
		return 1;
	}

	return 0;

}	  

int ExecSnd(int i)
{
	int n, tmp, board, address, bit, speaker;
	unsigned char buffer[2];
	curTime = Clock_GetTicks();
	if (stim[i].status == statInit)
	{
		if ((stim[i].startRef == 0) && (curTime >= stim[i].startTime))
		{
			// Select board	en speaker
			n = stim[i].posY + 2;
			// speaker 30=1, speaker 31=2
			if (n == 32) n = 1;
			if (n == 33) n = 2;
			// < 100 voor- anders achterzijde
			if (n < 100) board = n / 8; else board = ((n - 100) / 8) + 4;
			if (n > 100) n = n - 100 + 32;  // correctie voor/achter en board 4=board 0
			speaker = n - 8*board;

			address   = 0x4E;
			buffer[0] = boards[board]; 
			I2C_SendByte(address, 1, buffer);

			// Set signal 1 or 2
			tmp = statusBoards[board][0];

			if (stim[i].kind == stimSnd1) 
				tmp |= speakers[speaker];	    // set speakerbit
			else
				tmp &= ~speakers[speaker]; 	    // clr speakerbit 

			statusBoards[board][0] = tmp;
			buffer[0] = tmp;
			address   = 0x40;
			I2C_SendByte(address, 1, buffer);

			if (speaker < 4)
			{
				address  = 0x44;
				tmp = statusBoards[board][1];
				if (stim[i].kind == stimSnd1)
					tmp &= gain1[speaker];
				else
					tmp &= gain2[speaker];
				statusBoards[board][1] = tmp;
			}
			else
			{
				address  = 0x42;
				tmp = statusBoards[board][2];
				if (stim[i].kind == stimSnd1)
					tmp &= gain1[speaker];
				else
					tmp &= gain2[speaker];
				statusBoards[board][2] = tmp;
			}

			buffer[0] = tmp;
			I2C_SendByte(address, 1, buffer);
			
			// Trigger TDT
			curTime = Clock_GetTicks();
			
			if (snd12Flag == 3) // beide triggeren
			{
				if (stim[i].kind == stimSnd1) tmpSnd1[0] = 0; else tmpSnd2[0] = 0; 
				if ((tmpSnd1[0] == 0) && (tmpSnd2[0] == 0)) // beide geladen
				{
					Trigger(outRP2_1 | outRP2_2,true);
			     	stim[tmpSnd1[3]].startTime = curTime;
					stim[tmpSnd1[3]].status    = statRun;
					stim[tmpSnd2[3]].startTime = curTime;
					stim[tmpSnd2[3]].status    = statRun;
				}
			}
			else
			{
				if (stim[i].kind == stimSnd1) 
					Trigger(outRP2_1,true);	// Start
				else
					Trigger(outRP2_2,true);

				stim[i].startTime = curTime;
				stim[i].status    = statRun;
			}
			
		}
		return 1;
	}
	if (stim[i].status == statRun)
	{
		if (curTime > (stim[i].startTime+100))
		{
			if (stim[i].kind == stimSnd1)
				bit = TstBitPar(inpRP2_1);
			else
				bit = TstBitPar(inpRP2_2);
			if (bit == 0)
			{
				stim[i].stopTime = curTime;
				stim[i].status   = statDone;
				// Select board
				n = stim[i].posY + 2;
				// speaker 30=1, speaker 31=2
				if (n == 32) n = 1;
				if (n == 33) n = 2;
				if (n < 100) board = n / 8; else board = ((n - 100) / 8) + 4;
				if (n > 100) n = n - 100 + 32;  // correctie voor/achter en board 4=board 0
				speaker = n - 8*board;
				address   = 0x4E;
				buffer[0] = boards[board]; 
				I2C_SendByte(address, 1, buffer);

				if (speaker < 4)
				{
					address  = 0x44;
					tmp = statusBoards[board][1];
					if (stim[i].kind == stimSnd1)
						tmp |= ~gain1[speaker];
					else
						tmp |= ~gain2[speaker];
					statusBoards[board][1] = tmp;
				}
				else
				{
					address  = 0x42;
					tmp = statusBoards[board][2];
					if (stim[i].kind == stimSnd1)
						tmp |= ~gain1[speaker];
					else
						tmp |= ~gain2[speaker];
					statusBoards[board][2] = tmp;
				}

				buffer[0] = tmp;
				I2C_SendByte(address, 1, buffer);
 				return 0;
			}
		}
		return 1;
	}
	return 0;
}

void SpeakersOff(void)
{ // niet goed, per board moeten sig en speakers worden gereset.
	int address;
	unsigned char buffer[2];

	address   = 0x4E;	// board
	buffer[0] = 0xFF;	I2C_SendByte(address, 1, buffer);

	address   = 0x40;	// signal
	buffer[0] = 0xFF;	I2C_SendByte(address, 1, buffer);
	
	buffer[0] = 0xFF;	// speakers
	address  = 0x44;	I2C_SendByte(address, 1, buffer);
	address  = 0x42;	I2C_SendByte(address, 1, buffer);
}
void ExecEvent(int event)
{
	int i, time;
	time = Clock_GetTicks();
	for (i = 0; i <= nStim; i++)
	{
		if (stim[i].startRef == event)
		{
			stim[i].startRef = 0;
			stim[i].startTime += time;
		}
		if (stim[i].stopRef == event)
		{
			stim[i].stopRef = 0;
			stim[i].stopTime += time;
		}
	}
}

int ExecTrg0(int i)
{
	int bit;
	curTime = Clock_GetTicks();
	if (stim[i].status == statInit)
	{
		if ((stim[i].startRef == 0) && (curTime >= stim[i].startTime))
		{
			bit = TstBitPar(inpExtTrigger);
			if (stim[i].edge == 1)
			{
				if (bit == 0)
				{
					stim[i].startTime = curTime;
					stim[i].status    = statRun;
				}
			}
			else
			{
				if (bit > 0)
				{
					stim[i].startTime = curTime;
					stim[i].status    = statRun;
				}
			}
		}
		return 1;
	}
	if (stim[i].status == statRun)
	{
		bit = TstBitPar(inpExtTrigger);
		if (stim[i].edge == 1)
		{
			if (bit > 0)
			{
				stim[i].stopTime = curTime;
				stim[i].status   = statDone;
				ExecEvent(stim[i].event);
				return 0;
			}
		}
		else
		{
			if (bit == 0)
			{
				stim[i].stopTime = curTime;
				stim[i].status   = statDone;
				ExecEvent(stim[i].event);
				return 0;
			}
		}
		return 1;
	}
	return 0;
}

int ExecLas(int i) 
{
	int bitNo = (1 << (stim[i].bitNo-1));
	curTime = Clock_GetTicks();

	if (stim[i].status == statInit) 
	{
		if ((stim[i].startRef == 0) && (curTime >= stim[i].startTime)) 
		{
			curTime = Clock_GetTicks();
			stim[i].startTime = curTime;
			stim[i].status = statRun;
			SetBitsPar(bitNo);
		} 
		return 1;
	}

	if (stim[i].status == statRun) 
	{
		if ((stim[i].stopRef == 0) && (curTime >= stim[i].stopTime)) 
		{
			curTime = Clock_GetTicks();
			stim[i].stopTime = curTime;
			stim[i].status = statDone;
			ClrBitsPar(bitNo);
			return 0; 
		} 
		return 1;
	}
	return 0;
}

int ExecAcq(int i)
{
	int bit;

	curTime = Clock_GetTicks();
	if (stim[i].status == statInit)
	{
		if ((stim[i].startRef == 0) && (curTime >= stim[i].startTime))
		{
			stim[i].startTime = curTime;
			Trigger(outRA16,true);
			stim[i].status = statRun;					   
		}
		return 1;
	}

	if (stim[i].status == statRun)
	{
		if (curTime > (stim[i].startTime+100))
		{										 
			bit = TstBitPar(inpRA16);
			if (bit == 0)
			{
				stim[i].stopTime = curTime;
				stim[i].status = statDone;
				return 0;
			}
		}
		return 1;
	}

	return 0;
}

void GetTime()
{
	int val, n, i;
	val = Clock_GetTicks();
	n = sprintf(outBuf,"%d\n",val);
	i = UART0_Str(outBuf, n);
	nBuffer[1] = 0;
}
