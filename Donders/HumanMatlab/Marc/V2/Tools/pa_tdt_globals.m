%==================================================================
% Globals for TDT systeem
%==================================================================

%% kind of flags
statTDTConnect = 1;
statTDTLoad    = 2;
statTDTRun     = 3;

%% standard variables
if exist('RA16_1circuit','var')~=1
    RA16_1circuit = 'C:\humanv1\RPvdsEx\Remmel_8Channels_ra16_1.rco';
end
if exist('RA16_2circuit','var')~=1
    RA16_2circuit = '';
end
if exist('RX6circuit','var')~=1
    RX6circuit = '';
end
if exist('RP2_1circuit','var')~=1
    RP2_1circuit = 'C:\humanv1\RPvdsEx\hrtf_2Channels_rp2.rco';
end
if exist('RP2_2circuit','var')~=1
    RP2_2circuit = 'C:\humanv1\RPvdsEx\hrtf_2Channels_rp2.rco';
end
if exist('HeadCalNetFile','var')~=1
    %HeadCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\OrcHead.net'; HeadInputChans = [5 6];
    %HeadCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaInSituLinearHead.net'; HeadCalNetInputChans = [5 6];
    HeadCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaGimbalLinearHead.net'; HeadCalNetInputChans = [5 6];
end
if exist('GazeCalNetFile','var')~=1
    %GazeCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaGazeHeadFixed.net';
    %GazeCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaGazeHeadFree.net';
    %GazeCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaGazeHeadFree5ChanIn_V2.net';GazeCalNetInputChans = [1 2 3 5 6];
    %GazeCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\ManaGazeHeadFree_5chan_tansig_purelin_5hid.net';GazeCalNetInputChans = [1 2 3 5 6];
    GazeCalNetFile = 'D:\Tom\MonkeyMatlab\RCO&RPX\simple.net'; GazeCalNetInputChans = [1 2];

end
