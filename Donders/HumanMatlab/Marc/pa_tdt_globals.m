% PA_TDT_GLOBALS
%
% "Globals constants" for the TDT-system. These are actually local
% variables, so do not change any of these later on.
%
% This checks whether you have defined the filename of the RCO-files for
% the RA16 and RP2 systems, in variables:
% - RA16_1circuit
% - RA16_2circuit
% - RP2_1circuit
% - RP2_2circuit
%
% If not, it will use default or empty strings.
%
% Also checks for the filename of neural-network files in variables:
% - HeadCalNetFile
% - GazeCalNetFile


% Dick Heeren
% 2013 Marc van Wanrooij

%% TDT flags
statTDTConnect = 1;
statTDTLoad    = 2;
statTDTRun     = 3;

%% standard variables
if ~exist('RA16_1circuit','var')
    RA16_1circuit = 'C:\humanv1\RPvdsEx\Remmel_8Channels_ra16_1.rco';
end
if ~exist('RA16_2circuit','var')
    RA16_2circuit = '';
end
if ~exist('RX6circuit','var')
    RX6circuit = '';
end
if ~exist('RP2_1circuit','var')
    RP2_1circuit = 'C:\humanv1\RPvdsEx\hrtf_2Channels_rp2.rco';
end
if ~exist('RP2_2circuit','var')
    RP2_2circuit = 'C:\humanv1\RPvdsEx\hrtf_2Channels_rp2.rco';
end
if ~exist('HeadCalNetFile','var')
    %HeadCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\OrcHead.net'; HeadInputChans = [5 6];
    %HeadCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaInSituLinearHead.net'; HeadCalNetInputChans = [5 6];
    HeadCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaGimbalLinearHead.net'; HeadCalNetInputChans = [5 6];
end
if ~exist('GazeCalNetFile','var')
    %GazeCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaGazeHeadFixed.net';
    %GazeCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaGazeHeadFree.net';
    %GazeCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaGazeHeadFree5ChanIn_V2.net';GazeCalNetInputChans = [1 2 3 5 6];
    %GazeCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaGazeHeadFree_5chan_tansig_purelin_5hid.net';GazeCalNetInputChans = [1 2 3 5 6];
    GazeCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\simple.net'; GazeCalNetInputChans = [1 2];
end
