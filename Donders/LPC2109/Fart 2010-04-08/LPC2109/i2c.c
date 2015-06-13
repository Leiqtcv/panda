/*************************************************************************
						I2C.C

Project		 	Controller		DJH MBFYS UMCN
--------------------------------------------------------------------------
Versie 1.00		19-05-2005		Dick Heeren
**************************************************************************/

#include <lpc21xx.h> 
#include "I2C.h" 
#include "Config.h"

/* Dual color leds(green, red) are used. 32 "SAA1064 seven segment		  */
/* led driver" are used (16 per color), due to fact that it is a seven	  */
/* segment driver, the intensity of the leds are adjusted in groups of    */
/* seven leds. The PCF8574 selects one of the SAA1064 IC's (red or green).*/

//-> I2C Control Clear Register bits
#define I2CONCLR_AA   0x04;		// Assert acknowledge flag
#define I2CONCLR_SI   0x08;		// I2C interrupt flag
#define I2CONCLR_STA  0x20;		// Start flag
#define I2CONCLR_I2EN 0x40;		// I2C interface enable	

//-> I2C Control Set Register bits
#define I2CONSET_AA   0x04;		// Assert acknowledge flag
#define I2CONSET_SI   0x08;		// I2C interrupt flag
#define I2CONSET_STO  0x10;		// Stop flag
#define I2CONSET_STA  0x20;		// Start flag
#define I2CONSET_I2EN 0x40;		// I2C interface enable	

//-> I2C Message Codes (see also page 23 80C51 overview
#define	Start_TXD		 0x08	// Start condition has been transmitted
#define	Rep_Start_TXD	 0x10	// Repeated Start Condition ...
#define Address_TXD_ACK  0x18	// SLA+W has been transmitted, ACK has been received
#define Address_TXD_NACK 0x20	//  .... NOT ACK has been received
#define Data_TXD_ACK 	 0x28	// Data Byte has been transmitted, ACK has been received
#define Data_TXD_NACK	 0x30	//  .... NOT ACK has been received
#define ARB_Lost		 0x38	// Arbitration lost in SLA+R/W or Data bytes
#define Address_RXD_ACK  0x40	// SLA+R has been transmitted, ACK has been received
#define Address_RXD_NACK 0x48	//  .... NOT ACK has been received
#define Data_RXD_ACK 	 0x50	// Data Byte has been received, ACK has been returned
#define Data_RXD_NACK	 0x58	//  .... NOT ACK has been returned

#define	I2C_Error		 0x00
#define I2C_OK			 0x01
#define I2C_Busy		 0x02

unsigned char dataBuffer[4], numBytes, deviceAddress, dataIn, status, ReadWrite;
int index;

void I2C_Init(void)
{
 	PINSEL0 &= ~(3<<4);			// setup SCL pin 02 5:4 = 01
	PINSEL0 |=   1<<4;		

	PINSEL0 &= ~(3<<6);			// setup SDA pin 03 7:6 = 01
	PINSEL0 |=   1<<6;

	I2C_SetBitrate();			// set default bitrate = 100 KHz

	// disable, reset interface and enable interface
	I2CONCLR = 0x6C;			// clears in CONSET AA, SI, STA and I2EN bit

	VICIntSelect = 1;
	VICVectAddr1 = (unsigned long)I2C_irq;
	VICVectCntl1 = 0x20 | 9;	// I2C interrupt (irq enable + number of interrupt)
	VICIntEnable = 1 << 9;		// Enable I2C interrupt

	I2CONSET = I2CONSET_I2EN;	// enable interface
}					

void I2C_SetBitrate(void)
{
	// choose I2SCLL = I2CLH for a duty cicle of 50% 

	// Bit frequency = fclk / ( LH + LL).
	// Desired bit frequency = 100 Khz, fclk = PPL_Multiplier*crystal = 5*10 = 50 Mhz;
	unsigned int time;

	time = (LPCconfig()->PLL_Multiplier*LPCconfig()->crystal) / 100000; 
	I2SCLL = time / 2;
	I2SCLH = time - I2SCLL;
}

void I2C_irq(void) __irq
{
	switch (I2STAT)
	{
	case Start_TXD:	  				// Start condition has been transmitted
		if (ReadWrite)
			I2DAT = deviceAddress | 0x01;	// Read mode
		else
			I2DAT = deviceAddress & 0xFE;	// Write mode
		I2CONCLR = 0x38; // I2CONCLR_STA;	// Clear start bit
		break;

	case Rep_Start_TXD:
		I2CONCLR = I2CONCLR_STA;	// Clear start bit
		break;

	case Address_TXD_ACK:			// SLA+W has been transmitted, ACK has been received
		index = 0;					// Send first byte
		I2DAT = dataBuffer[index];
		I2CONCLR = 0x38; // I2CONCLR_STA;	// Clear start bit
		break;

	case Address_TXD_NACK:			// SLA+W has been transmitted, NOT ACK has been received
		I2CONSET = I2CONSET_STO;	// Stop the transfer - ERROR
		status = I2C_Error;
		break;

	case Data_TXD_ACK:	 			// Data Byte has been transmitted, ACK has been received
		index++;					// Next byte if any
		if (numBytes > index)
			I2DAT = dataBuffer[index];
		else
		{
			I2CONSET = I2CONSET_STO;// Stop the transfer - OK			
			status = I2C_OK;
		}
		break;

	case Data_TXD_NACK:	 			// Data Byte has been transmitted, NOT ACK has been received
		I2CONSET = I2CONSET_STO;	// Stop the transfer - ERROR
		status = I2C_Error;
		break;

	case Address_RXD_ACK:			// SLA+R has been transmitted, ACK has been received
		break;

	case Address_RXD_NACK:			// SLA+R has been transmitted, NOT ACK has been received
		status = I2C_Error;
		break;

	case Data_RXD_NACK:				// Data Byte has been received, no ACK sent
		dataIn = I2DAT;				// Read the byte
		I2CONSET = I2CONSET_STO;	// Stop the transfer - OK
		status = I2C_OK;
		break;

	default:						// Error out, unknown state
		I2CONSET = I2CONSET_STO;	// Stop the transfer - ERROR
		status = I2C_Error;
		break;
	}
	I2CONCLR = I2CONCLR_SI;
	VICVectAddr = 1;				// Acknowledge interrupt
}

void I2C_Start(void)
{
	I2CONSET = I2CONSET_STA;
	status = I2C_Busy;
	while (status == I2C_Busy);
}

void I2C_SendByte(unsigned char address, int num, unsigned char data[4])
{

	int i;
	deviceAddress = address;
	ReadWrite     = 0;
	numBytes      = num;
	for (i = 0; i < num; i++) dataBuffer[i] = data[i];
	I2C_Start();
}
		 