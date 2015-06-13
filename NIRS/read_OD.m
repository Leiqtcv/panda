function data = read_OD(fullname)
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

%% Check file
% DATA = READNIRS(FNAME)
%		or
% [DATA,FNAME,PNAME] = READNIRS
%
% Read data DATA from NIRS-excel file FNAME.
% If FNAME is not given, a window will ask for a file.
%
% See also RESULTS, GOTONIRS
%
% 2011 Marc van Wanrooij

%% Initialization
if nargin<1
	[fname, pname]	= uigetfile('.xls');
	fullname		= [pname fname];
end
nADC    = 2;

%% Load data from Excelsheet
[chan,TXT,RAW]	= xlsread(fullname);

%% Remove the header-information
hdr     = read_hdr_nirs(TXT,RAW,nADC);
nchan   = hdr.nreceivers*hdr.nlasers;
hdr.nChans = nchan + nADC + 2;

%% Get events
event			= read_event(chan,hdr, hdr.Fs);
data.fsample	= hdr.Fs; % sampling frequency in Hz, single number
data.label		= hdr.label;
data.event		= event;
data.hdr		= hdr;

%% Remove the header-informationc
start           = event(1).start - 15*hdr.Fs;
chan			= chan((hdr.startdata+2):end,:);
chan            = chan(start:end,:);


%% Raw data
chan(:,2:nchan+1)   = MBLL(chan(:,2:nchan+1), hdr); % cell-array containing a data matrix for each trial (1 X Ntrial), each data matrix is Nchan X Nsamples
data.trial{1}       = chan(:,1:hdr.nChans)';
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


function hdr = read_hdr_nirs(TXT,RAW, nADC)
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


hdr.pos_indx	= [1 5 2 6 3 7 4 8]; % Changed! [4 1 8 6 3 2 5 7];
switch hdr.optodetemplate
	case '8 channel (split)'
	hdr.pos_indx	= [1 5 2 6 3 7 4 8]; % Changed! [4 1 8 6 3 2 5 7];
	otherwise
		disp('No template found');
end
hdr.optodedistance	= [35 22 35 15]; % (mm)

hdr.DPF				= RAW{12,2}; % Differential pathlength factor
hdr.deviceid		= RAW{14,2}; % ???
hdr.nreceivers		= RAW{15,2};
hdr.nlasers			= RAW{16,2};
hdr.ADC				= nADC;           %RAW{17,2}; In OD files all ADC are given
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
		ii = 1;
        while ii <= hdr.nChans
            Rx = RAW{legindx+1+ii,2};
            Tx = RAW{legindx+1+ii,3};
            AD = RAW{legindx+1+ii,4};
            if ii == 1 || ii == hdr.nChans
                hdr.label{ii,1} = RAW{legindx+1+ii,2};
            elseif mod(ii,2) == 0 && isnan(AD)
                hdr.label{ii,1} = ['Rx' num2str(Rx) ' - Tx' num2str(ceil(Tx/2)) ' O2Hb']; % cell-array containing strings, Nchan X 1
            elseif isnan(AD)
                hdr.label{ii,1} = ['Rx' num2str(Rx) ' - Tx' num2str(ceil(Tx/2)) ' HHb']; % cell-array containing strings, Nchan X 1
            elseif ~isnan(AD) && AD <= nADC
                hdr.label{ii,1} = ['A/D Channel ' num2str(AD)];
            elseif AD > nADC
                hdr.label{ii,1} = RAW{legindx+1+hdr.nChans,2};
                ii = hdr.nChans;
            end
            ii = ii +1;
        end
end
hdr.nChans = numel(hdr.label);

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

function data = MBLL(data, hdr)
dist = [hdr.optodedistance hdr.optodedistance];
DPF = hdr.DPF;
alpha = absorption_coeff2;
for ii = 1:2:hdr.nlasers*hdr.nreceivers
    jj = mod(ii,hdr.nlasers);
    
    kk = (ii + 1)/2;
    d     = dist(kk)/10; % in cm    
    
    las1  = hdr.laserwavelength(jj);
    las2  = hdr.laserwavelength(jj+1);
    
    HbO1  = alpha(alpha(:,1) == las1,2)/10^6; % uM;
    HbR1  = alpha(alpha(:,1) == las1,3)/10^6; % uM;
    
    HbO2  = alpha(alpha(:,1) == las2,2)/10^6; % uM;
    HbR2  = alpha(alpha(:,1) == las2,3)/10^6; % uM;
    
    dA1 = data(:,ii) - data(1,ii);
    dA2 = data(:,ii+1)- data(1,ii+1);
    
    OHb = (dA1 - dA2*HbR1/HbR2)/(d*DPF)*HbR2/(HbO1*HbR2-HbO2*HbR1);   
    HHb = (dA1 - dA2*HbO1/HbO2)/(d*DPF)*HbO2/(HbR1*HbO2-HbR2*HbO1);
    data(:,ii) = OHb;
    data(:,ii+1) = HHb;
end

function event = read_event(chan,hdr, Fs)
% [TRIAL,EVENT] = READ_EVENT(FILENAME)
%
% READ_EVENT reads all events from a NIRS dataset and returns
% them in a well defined structure.ADindx = find(strncmpi('A/D',hdr.label,3));

if strcmp(hdr.dataformat, 'oxy')
	ADindx			= strncmpi('A/D',hdr.label,3);
else
    ADindx          = 18:19;
end

event			= chan(hdr.startdata+1:end,ADindx);
if size(event,2) == 2
    trial			= event(:,2);
else
    trial			= event(:,1);
end

tmp             = peak_detect(trial);
peak            = NaN(1,2*length(tmp));
peak(1:2:end)   = tmp;
peak(2:2:end)   = tmp+20*Fs; % duration stim is 20.0s 

event = struct([]);
event(1).start = peak(1);
for ii = 1:length(peak)
	if mod(ii,2)
		event(ii).value		= 1; % Assumption: first peak is onset. Is this correct?
	else
		event(ii).value		= 0;
	end
	event(ii).type		= 'backpanel ADC1';
	event(ii).sample	= peak(ii)-peak(1)+15*Fs; % (samples), the first sample of a recording is 1
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
	peak		= peak(sel);
	muduration	= mean(diff(peak));
end