function data = read_nirs(filename)
% READ_NIRS reads NIRS time signals from OxyMon excel data
% format.
%
% NIRS = READ_NIRS(FILENAME)
%
% The output spike structure contains
%   NIRS.label     = 1xNchans cell-array, with channel labels
%   NIRS.trial     = 1xNchans cell-array, with channel labels
%   NIRS.waveform  = 1xNchans cell-array, each element contains a matrix (Nsamples X Nspikes)
%   NIRS.timestamp = 1xNchans cell-array, each element contains a vector (1 X Nspikes)
%   NIRS.unit      = 1xNchans cell-array, each element contains a vector (1 X Nspikes)
%
% See also RESULTS, GOTONIRS, READ_HDR_NIRS

% 2011 Marc van Wanrooij

%% Check file
if nargin<1
    filename = pa_fcheckexist([]);
end
%% Load data from Excelsheet
[chan,TXT,RAW]	= xlsread(filename);

%% Load header
hdr				= read_hdr_nirs(TXT,RAW);
hdr.start       = 15;
%% Get events
event			= read_event(chan,hdr, hdr.Fs);
data.fsample	= hdr.Fs; % sampling frequency in Hz, single number
data.label		= hdr.label;
data.event		= event;
data.hdr		= hdr;

%% Remove the header-information
start           = event(1).start - hdr.start*hdr.Fs;
chan			= chan((hdr.startdata+1):end,:);
chan            = chan(start:end,:);

%% Raw data
data.trial{1}		= chan(:,1:hdr.nChans)'; % cell-array containing a data matrix for each trial (1 X Ntrial), each data matrix is Nchan X Nsamples
data.time{1}		= (chan(:,1)'-start)/data.fsample;  % cell-array containing a time axis for each trial (1 X Ntrial), each time axis is a 1 X Nsamples vector

%% Bookkeeping
% add version information to the configuration
cfg.version.name	= mfilename('fullpath');

% add information about the Matlab version used to the configuration
cfg.version.matlab	= version;

% remember the configuration details of the input data
cfg.previous = [];
try %#ok<TRYNC>
    cfg.previous	= cfg;
end
% remember the exact configuration details in the output
data.cfg = cfg;

function hdr = read_hdr_nirs(TXT,RAW)
% READ_HDR_NIRS reads header/stimulus information from NIRS time signals of
% OxyMon excel data format.
%
% HDR = READ_HDR_NIRS(FILENAME)
%
% Returns a header structure with the following elements
%   hdr.Fs                  sampling frequency
%   hdr.nChans              number of channels
%   hdr.nSamples            number of samples per trial
%   hdr.label               cell-array with labels of each channel
%
% And some additional info, which is probably never used in data analysis.
%
%   hdr.nSamplesPre         number of pre-trigger samples in each trial
%   hdr.nTrials             number of trials
%
% See also READ_HEADER, READ_NIRS

% 2011 Marc van Wanrooij

%% Insert header information in hdr
hdr.oxyexport		= TXT{1,2};
hdr.xcldate			= TXT{2,2};
hdr.filedate		= TXT{3,2};
hdr.Fs				= RAW{28,2}; %after export to xcl
hdr.samplerate		= RAW{5,2}; % (Hz)
hdr.duration		= RAW{6,2}; % (s)
hdr.nSamples		= RAW{7,2};	% number of samples per trial
hdr.optodetemplate	= RAW{10,2};
hdr.optodedistance	= RAW{11,2}; % (mm)

switch hdr.optodetemplate
    case '8 channel (split)'
        hdr.pos_indx	= [4 1 8 6 3 2 5 7];
        if hdr.optodedistance ~=40
            str = char(strcat({('--------------------------------------------------------');...
                ['    According to header, Optode Distance is ' num2str(hdr.optodedistance) ' mm.'] ;...
                ('    Set to 40 mm, as this makes more sense.');...
                ('--------------------------------------------------------')}));
            disp(str)
            hdr.optodedistance = 40;
        end
    case '6 channel (plus 2 chan split)'
        hdr.pos_indx	= [1 5 2 6 3 7 4 8];
    case '2 chan-Sevy'
        hdr.pos_indx	= [1 2];
    case '2 x 1 channel'
        hdr.pos_indx	= [1 2];        
    case '3 x 1 channel III'
        hdr.pos_indx	= [1 2 3];
    otherwise
        disp('No template found');
end

hdr.DPF				= RAW{12,2}; % Differential path length
hdr.deviceid		= RAW{14,2}; % ???
hdr.nreceivers		= RAW{15,2};
hdr.nlasers			= RAW{16,2};
hdr.ADC				= RAW{17,2};
hdr.laserwavelength = [RAW{19:18+hdr.nlasers,2}];

%% Now it gets tricky:
% Have we set an export sample time and rate?
if strcmpi(TXT{29,1},'Export timespan') % Yes we do!
    hdr.exporttimespan		= [RAW{29,2:3}];
    hdr.exportsamplespan	= [RAW{30,2:3}];
end
% Start of legend varies depending on whether we set an export time
legindx = find(strcmpi('Legend',TXT(:,1)));
% We have to check what dataformat we have exported to
switch TXT{legindx+1,2}
    case 'Trace (Measurement)'
        hdr.dataformat = 'oxy'; % oxy and deoxy concentrations
    case 'Rx'
        hdr.dataformat = 'OD';	% optical densities or raw values
end
% Determine the number of data channels (columns)
leg_end_indx	= find(isnan([RAW{legindx+2:legindx+30,1}]),1);
hdr.nChans		= leg_end_indx-1;
%
switch hdr.dataformat
    case'oxy'
        for ii = 1:hdr.nChans
            hdr.label{ii,1} = RAW{legindx+1+ii,2}; % cell-array containing strings, Nchan X 1
        end
    case 'OD'
        for ii = 1:hdr.nChans
            hdr.label{ii,1} = RAW{legindx+1+ii+ii,2}; % cell-array containing strings, Nchan X 1
        end
end
% Find oxyhemoglobin
indx = NaN(hdr.nChans,1);
for ii = 1:hdr.nChans
    tmp = strfind(hdr.label{ii},'O2Hb');
    if ~isempty(tmp)
        indx(ii) = tmp;
    end
end
hdr.oxyindx		= find(~isnan(indx)); % first label is

% Find deoxyhemoglobin
indx = NaN(hdr.nChans,1);
for ii = 1:hdr.nChans
    tmp = strfind(hdr.label{ii},'HHb');
    if ~isempty(tmp)
        indx(ii) = tmp;
    end
end
hdr.deoxyindx		= find(~isnan(indx));

% Start data column
hdr.startdata = leg_end_indx+legindx+3-4; % +3: data starts 3 after leg_end_ind + legindx, -4: chan starts from line 5, txt/raw from line 1

%% Default values
hdr.nSamplesPre		= 0;
hdr.nTrials			= 1;


function event = read_event(chan,hdr, Fs)
% [TRIAL,EVENT] = READ_EVENT(FILENAME)
%
% READ_EVENT reads all events from a NIRS dataset and returns
% them in a well defined structure.ADindx = find(strncmpi('A/D',hdr.label,3));
ADindx			= strncmpi('A/D',hdr.label,3);
event			= chan(hdr.startdata+1:end,ADindx);
trial			= event(:,size(event,2));
tmp             = peak_detect(trial);
% tmp             = oddball(tmp, event(:,1)); % auditory oddball exp

peak            = NaN(1,2*length(tmp));
peak(1:2:end)   = tmp;
peak(2:2:end)   = tmp+30*Fs; % duration stim is 20.0 s
% peak = peak(1:20);
event = struct([]);
event(1).start = peak(1); % start of first event in used time scale
peak = peak - peak(1) + hdr.start*Fs;

for ii = 1:length(peak)
    if mod(ii,2)
        event(ii).value		= 1; % Assumption: first peak is onset. Is this correct?
    else
        event(ii).value		= 0;
    end
    event(ii).type		= 'backpanel ADC1';
    event(ii).sample	= peak(ii); % (samples), the first sample of a recording is 1, first event set at + 10 s
    event(ii).offset	= 0; % (samples)
    if ii<length(peak)
        event(ii).duration	= peak(ii+1)-peak(ii); % (samples)
    else % last offset of pulse
        event(ii).duration	= 0; % (samples)
    end
end

function peak = peak_detect(trial)
pulse			= [0; diff(trial)];	% 'differentiate' pulse
lvl				= 2*std(pulse);		% threshold set at 2 SD
peak			= find(pulse>lvl | pulse<-lvl);	% Obtain peaks (sample numbers) both onset and offset as double check

% Check to see whether peaks are not too close together
% e.g. each peak should be minimally half the average duration away
muduration	= mean(diff(peak));
sel			= false;
while any(~sel)
    peak1		= peak(1:end-1);
    sel			= (peak-[0;peak1])>(muduration/2);
    sel(1)      = 1; % First peak doesn't need to be > (muduration/2)
    if ~isempty(peak)
        peak		= peak(sel);
    end
    muduration	= mean(diff(peak));
end