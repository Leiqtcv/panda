%=========================================================================
%                           Constants
%=========================================================================

STIMREC= struct('stim',0,'start',[0 0],'stop',[0 0],'pos',[0 0],...
                'mode',0,'level',0,'index',0,...
                'event',0,'stat',0);
         
Globals.stimLed        =  10;
Globals.stimBar        =  11;
Globals.stimBit        =  12;
Globals.stimRew        =  13;
Globals.stimSnd        =  14;

Globals.cmdLedOn       = 100;      % led on: ring, spoke, color
Globals.cmdLedOff      = 101;
Globals.cmdSetPIO      = 102;
Globals.cmdGetPIO      = 103;
Globals.cmdMaxInt      = 104;

Globals.cmdTestLeds    = 200;
Globals.cmdNextTrial   = 201;      % data to client

Globals.cmdGetStatus   = 301;      % current trial status
Globals.cmdSetClock    = 302;      % set clock client = 0.0 mSec
Globals.cmdGetClock    = 303;      % get time client (mSec)
Globals.cmdStartTrial  = 305;      % start a new trial
Globals.cmdResultTrial = 306;      % get results last trial
Globals.cmdAbortTrial  = 307;      % abort running trial

