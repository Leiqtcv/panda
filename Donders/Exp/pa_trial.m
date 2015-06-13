% PA_TRIAL
%
% Run a trial
%
% See also PA_HARDWARE_INIT, PA_EXPERIMENT

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com

soundFile    = 'C:\matlab\Marc\Experiment\Sound\snd0001.wav';

% close all;
pa_hardware_init;

%% Stimuli
led			= STIMREC; % Initialized by PA_MICRO_GLOBALS, structure containing relevant fields
led.stim	= stimLed; % = 4, skyled initialized by PA_MICRO_GLOBALS
led.pos		= [0 18];
led.level	= 255;
led.start	= [0 0];
led.stop	= [0 2000]; % stop after 10 s
led.event	= 1;

led1		= STIMREC; % Initialized by PA_MICRO_GLOBALS, structure containing relevant fields
led1.stim	= stimLed; % = 4, skyled initialized by PA_MICRO_GLOBALS
led1.pos	= [0 19];
led1.level	= 255;
led1.start	= [0 0];
led1.stop	= [0 2000]; % stop after 10 s
led1.event	= 0;

speaker = 18;
Sound       = STIMREC;
Sound.stim  = stimSnd1;
Sound.pos	= [0 speaker];
Sound.bitNo = 8;
Sound.level = 200;
Sound.start = [0 0];
Sound.stop  = [0 2000];
Sound.event = 0;
snd		= transpose(wavread(soundFile));%Read wav file

%%
maxSamples	= length(snd);
RP2_1.SetTagVal('WavCount',maxSamples);
RP2_1.WriteTagV('WavData', 0, snd(1:maxSamples));

arg			= sprintf('%d;%d;1',speaker,stimSnd1); % micro argument: speaker,channel,onoff
micro_cmd(com,cmdSpeaker,arg); % give command to microcontroller

RP2_1.SetTagVal('Level',Sound.level/100); % Set speaker level
RP2_1.SoftTrg(1);
% RP2_1.SoftTrg(2);
pause(0.02);

%% Combine stimuli
stims(3)	= STIMREC;
nStim		= size(stims,2);

%% Prepare and start new trial
pa_micro_getvalues(com,cmdNextTrial, '');
stims(1)	= led;
stims(2)	= led1;
stims(3)	= Sound;

ret		= pa_micro_stims(com,nStim,stims); % store stimuli in microcontroller
a		= pa_micro_getvalues(com,cmdStartTrial,''); % start the trial

%% Wait until trial is finished
res		= pa_micro_getvalues(com,cmdStateTrial,''); % check state of trial
while res ~= statDoneTrial % end when trial is finished, i.e. status == 4
    res = pa_micro_getvalues(com,cmdStateTrial,'');
	busy = RP2_1.GetTagVal('Play'); % check sound playing
end

%%	Stop sound playing
RP2_1.SetTagVal('Level',0); % set level to 0
arg	= sprintf('%d;%d;0',speaker,stimSnd1); % 0 - speaker off
micro_cmd(com,cmdSpeaker,arg); % give command to microcontroller

%% Retrieve results, should be stored
[result,msg] = pa_micro_getresult(com);
nError = msg(1);
if (nError >= 0)
    disp(result);
else
    disp('****************************************');
    fprintf('Error: %d',nError);
    pause(1);
end

%%
close(com)


