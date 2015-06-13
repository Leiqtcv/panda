///////////////////////////////////////////////////////////////////////////
//                              GLOBALS                                  //
///////////////////////////////////////////////////////////////////////////
#define stimLed      10		// stimuli
#define stimBar      11		// bit input
#define stimBit		 12		// bit output
#define stimRew      13		// reward with delay
#define stimSnd      14     // sound

#define cmdLedOn    100
#define cmdLedOff   101
#define cmdSetPIO   102
#define cmdGetPIO   103
#define cmdMaxInt   104     // maximum led intensity (min..max = 255..0)

#define cmdTestLeds   200
#define cmdNextTrial  201   // data next trial to FSM

#define LPTdata    0x378    // output bit 7 6 5 4 3 2 1 0 
#define LPTstatus  0x379    // input  bit 7 6 5 4 3 x x x
                            // inv        x - - - - - - -   
#define LPTcontrol 0x37a    // input  bit x x x x x 2 1 0
                            // inv    bit - - - - - x - x
#define cRed       1
#define cGreen     0

#define statInit   2
#define statRun    1
#define statDone   0
#define statError  9

#define ledIntensity 0x44   // PWM
#define ledICselect  0x74
#define ledICdata    0x70

const int maxStim  = 20;
const int maxParam = 12;
//=======================================================================//
static double timerFrequency;      // frequency high performance counter
static HANDLE serial;
static char outBuf[80];
static char inpBuf[80];
//=======================================================================//
// leds
int LEDADDRESS[12][6] = {
//              R1        R2        R3        R4        R5        ?? 
    
  /* S1 */  {0X000002, 0X002000, 0X010200, 0X030002, 0X032000, 0X040200},
  /* S2 */  {0X000004, 0X004000, 0X010400, 0X030004, 0X034000, 0X040400},
  /* S3 */  {0X000008, 0X008000, 0X010800, 0X030008, 0X038000, 0X040800},
	        {0X000010, 0X010001, 0X011000, 0X030010, 0X040001, 0X041000},
	        {0X000020, 0X010002, 0X012000, 0X030020, 0X040002, 0X042000},
	        {0X000040, 0X010004, 0X014000, 0X030040, 0X040004, 0X044000},
	        {0X000080, 0X010008, 0X018000, 0X030080, 0X040008, 0X048000},
	        {0X000100, 0X010010, 0X020001, 0X030100, 0X040010, 0X050001},
	        {0X000200, 0X010020, 0X020002, 0X030200, 0X040020, 0X050002},
	        {0X000400, 0X010040, 0X020004, 0X030400, 0X040040, 0X050004},
	        {0X000800, 0X010080, 0X020008, 0X030800, 0X040080, 0X050008},
  /* S12 */ {0X001000, 0X010100, 0X020010, 0X031000, 0X040100, 0X050010}};
  
int ledData[2][6];  // red=0, green=1
int skyData[2][12]; // intensity red/green per spoke,
					// each spoke 6 rings
//=======================================================================//
// speakers
int boardSelect  = 0X4E;
int muteSelect   = 0X72;
int sourceSelect = 0X40;
// 8 amplifiers per board
// mute: 1-minimum and 0-maximum volume
// source: 0-source A, 1-source B
// 0-7	board
// 8-15	mute
//               R1        R2        R3        R4        R5        ?? 
int speakerData[12][6] = {   
/* S1 */     {0X00FD00, 0X00DF01, 0X00FD03, 0X00FE05, 0X00EF06, 0X00FE08},
/* S2 */     {0X00FB00, 0X00BF01, 0X00FB03, 0X00FD05, 0X00DF06, 0X00FD08},
/* S3 */     {0X00F700, 0X007F01, 0X00F703, 0X00FB05, 0X00BF06, 0X00FB08},
             {0X00EF00, 0X00FE02, 0X00EF03, 0X00F705, 0X007F06, 0X00F708},
             {0X00DF00, 0X00FD02, 0X00DF03, 0X00EF05, 0X00FE07, 0X00EF08},
             {0X00BF00, 0X00FB02, 0X00BF03, 0X00DF05, 0X00FD07, 0X00DF08},
             {0X007F00, 0X00F702, 0X007F03, 0X00BF05, 0X00FB07, 0X00BF08},
             {0X00FE01, 0X00EF02, 0X00FE04, 0X007F05, 0X00F707, 0X007F08},
             {0X00FD01, 0X00DF02, 0X00FD04, 0X00FE06, 0X00EF07, 0X00FE09},
             {0X00FB01, 0X00BF02, 0X00FB04, 0X00FD06, 0X00DF07, 0X00FD09},
             {0X00F701, 0X007F02, 0X00F704, 0X00FB06, 0X00BF07, 0X00FB09},
/* S12 */    {0X00EF01, 0X00FE03, 0X00EF04, 0X00F706, 0X007F07, 0X00F709}};
int preBoard = 0;
//=======================================================================//
