%=========================================================================
%                           stimuli and constants
%=========================================================================
function loadGlobals(hObject)
data = guidata(hObject);

STIMREC= struct('stim',0,'mode',0,'index',0,'edge',0,'bitno',0,...
                'pos',[0 0],'level',0,'start',[0 0],'stop',[0 0],...
                'delay',0,'width',[0 0],'event',0,'stat',0);
         
data.Globals.TCPinit        =   1;
data.Globals.TCPread        =   2;
data.Globals.TCPwrite       =   3;
data.Globals.TCPquery       =   4;
data.Globals.TCPclose       =   5;
data.Globals.stimLed        =  10;
data.Globals.stimBar        =  11;
data.Globals.cmdGetStatus   = 101;      % current trial status
data.Globals.cmdSetClock    = 102;      % set clock client = 0.0 mSec
data.Globals.cmdGetClock    = 103;      % get time client (mSec)
data.Globals.cmdNextTrial   = 104;      % data to client
data.Globals.cmdStartTrial  = 105;      % start a new trial
data.Globals.cmdResultTrial = 106;      % get results last trial
data.Globals.cmdAbortTrial  = 107;      % abort running trial
data.Globals.cmdSetPIO      = 108;      % set parallel output (printer)
data.Globals.cmdGetPIO      = 109;      % get parallel output (  port )
data.Globals.cmdTestLeds    = 200;      % test leds one by one

guidata(hObject, data);
end

