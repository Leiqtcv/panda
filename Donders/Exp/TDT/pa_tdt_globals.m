% pa_tdt_globals
% Globals for TDT systeem

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com

%% TDT flags
statTDTConnect = 1;
statTDTLoad    = 2;
statTDTRun     = 3;

%% standard variables
if ~exist('RA16_1circuit','var')
    RA16_1circuit = 'C:\matlab\Marc\Experiment\RPvdsEx\Remmel_8Channels_ra16_1.rco';
end
if ~exist('RA16_2circuit','var')
    RA16_2circuit = '';
end
if ~exist('RX6circuit','var')
    RX6circuit = '';
end
if ~exist('RP2_1circuit','var')
    RP2_1circuit = 'C:\matlab\Marc\Experiment\RPvdsEx\hrtf_2Channels_rp2.rco';
end
if ~exist('RP2_2circuit','var')
    RP2_2circuit = 'C:\matlab\Marc\Experiment\RPvdsEx\hrtf_2Channels_rp2.rco';
end

% short names of TDT circuits
[~,sRA16_1circuit]	= fileparts(RA16_1circuit);
[~,sRA16_2circuit]	= fileparts(RA16_2circuit);
[~,sRX6circuit]		= fileparts(RX6circuit);
[~,sRP2_1circuit]	= fileparts(RP2_1circuit);
[~,sRP2_2circuit]	= fileparts(RP2_2circuit);
