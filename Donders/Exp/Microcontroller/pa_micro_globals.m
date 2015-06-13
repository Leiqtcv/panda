% Micro controller variables
%
% Compare this to ???

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com


%% Stimulus ID
stimDin    =  1; % Digital Input
stimDout   =  2; % Digital Output
stimBar    =  3; % Handle Bar
stimSky    =  4; % Sky LED
stimLed    =  5; % Speaker LED
stimFix    =  6; % Fixation LED
stimTar    =  7; % Target
stimDim    =  8; % ?
stimRew    =  9; % Reward
stimRec    = 10; % Data acquisition / record
stimSnd1   = 11; % Sound 1
stimSnd2   = 12; % Sound 2
stimSelADC = 13; % 
stimADC    = 14; %
stimLas    = 15; % Laser
stimErr    = 16; %
stimFixWnd = 17; % Fixation window
stimSpeed  = 18; %

stimNames = strvcat('Din','Dout','bar','sky','led','fix','tar','dim',...
                    'rew','rec','snd1','snd2','selADC',' ADC','las','err','fix','spd'); %#ok<*VCAT>
% Cell might be faster than STRVCAT, has to be checked				

%% Status IDs
statInit       = 1;
statNextTrial  = 2;
statRunTrial   = 3;
statDoneTrial  = 4;
statDone       = 5;
statError      = 6;
statNames      = strvcat('init','next','run','done','done','err');
statNamesStims = strvcat('Stop','Active','Wait'); %reverse order is intended
   
%% Command ID
cmdStim       = 100;                        
cmdInit       = 101;    
cmdWindow     = 102;    
cmdSpeed      = 103;     %#ok<NASGU>
cmdInfo       = 104;    
cmdClock      = 105;    
cmdClrClock   = 106;    
cmdState      = 107;    
cmdNextTrial  = 108;    
cmdStartTrial = 109;
cmdSaveTrial  = 110;
cmdStateTrial = 111;
cmdReset      = 112;
cmdClrTime    = 113;
cmdAbort      = 114;
cmdReward     = 115;
cmdTime       = 116;    
cmdBar        = 117;    
cmdADC        = 118;
cmdSelADC     = 119;
cmdPin        = 120;
cmdSpeaker    = 121;
cmdNNMod      = 122;
cmdNNSim      = 123;
cmdFixWnd     = 124;
cmdSpeed      = 125;

%% rs232 errors
errNoError     =  0;
errTimeOut     = -1;         % time out error (elapsed time > 1000 mSec)
errInputArg    = -2;         % two input arguments are needed
errNotFunction = -3;
errInitialize  = -4;

%% Structures
STIMREC= struct('stim',0,'mode',0,'index',0,'edge',0,'bitNo',0,'pos',[0 0],...
                'level',0,'start',[0 0],'stop',[0 0],'delay',0,'width',[0 0],'event',0);

barDown = 0;
barUp   = 1;

LOGREC = struct('Trial',0,'Fsamp',0,'NsampSet',0,'NsampWrite',0,'NsampWritePerChan',0,...
	'Nchan',0,'IxsChanWrite',0,'StimNames',0,'Ton',0,'Toff',0,'Status',0,...
	'Correct',0,'TarPos',0,'Level',0,'stim',0);

NNMOD = struct('index',0,'nInput',0','scaleInput',[],'nHidden',0,'transHidden',0,...
    'biasesHidden',[],'weightsHidden',[],'nOutput',0,'transOutput',0,'scaleOutput',[],...
    'biasesOutput',0,'weightsOutput',[]);

            