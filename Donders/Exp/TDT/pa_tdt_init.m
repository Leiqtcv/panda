% PA_TDTINIT
%
% Initializes TDT system, checks and opens graphical monitor
%
% See also PA_TDT_GLOBALS

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com

%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\t***************************');
fprintf('\t\tInit TDT\n');

pa_tdt_globals;		% [RA16_1,RA16_2,RX6,RP2_1,RP2_2]
% Active X Controls: how does this work?
[zBus err(1)]	= ZBUS(1); % number of racks
[RP2_1 err(2)]	= RP2(1,RP2_1circuit); % Real-time processor 1
[RP2_2 err(3)]	= RP2(2,RP2_2circuit); % Real-time processor 2
[RA16_1 err(4)]	= RA16(1,RA16_1circuit); % Real-time acquisition


% open ActiveX window
FLAG_firstrun = false;
HF = findobj('Tag','ActXWin');

%% TDT status
fprintf('\t***************************');
fprintf('\t\tupdate TDT monitor\n');
RA16_1Status = RA16_1.GetStatus;
% RA16_2Status = RA16_2.GetStatus;
% RX6Status = RX6.GetStatus;
RP2_1Status = RP2_1.GetStatus;
RP2_2Status = RP2_2.GetStatus;
pa_tdt_monitor
fprintf('\t***************************');
fprintf('\t\tupdate TDT monitor DONE\n');

%% test leds
%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\t***************************');
fprintf('\t\tTest leds (optional)\n');