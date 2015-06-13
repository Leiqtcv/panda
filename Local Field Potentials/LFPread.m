function [data,cfg] = LFPread(cfg)
% [DATA,CFG] = LFPREAD(CFG)
%
% Read the data from LFP-files into DATA-structure. Configuration
% structure CFG should contain:
% - cfg.filename, filename of data file
%
% This function not only reads the data as stored, but downsamples and
% removes any 50 Hz line noise when needed...
%
% The DATA-structure is organized by trials, and contains the following
% fields:
%
%  - data.lfp
%  - data.lfpfilt
%  - data.spiketrace
%  - data.stimulus.params
%  - data.stimulus.values
%  - data.samplefrequency
%
% See also REMOVE50HZ
%
% 2010 Marc van Wanrooij

%% Initialization
disp(['Start ' mfilename]);
tic

%% File & Bookkeeping
if ~isfield(cfg,'filename');
    cfg.filename = fcheckexist([]);
end
if ~isfield(cfg,'behavior');
    cfg.behavior = [];
end
fname		= cfg.filename;
previous	= cfg;

%% Original data-files
cfg.srcfile				= [fname '.src']; % BrainWare-detected Spike Times and Shapes
cfg.damfile				= [fname '.dam']; % The high-pass filtered voltage trace
if exist([fname '.dat'],'file')
	cfg.behaviorfile		= [fname '.dat']; % behavioral data-file
else
	cfg.behaviorfile		= []; % behavioral data-file
end


%% Load DAM-file (high-pass filtered voltage trace & experimental info)
try
    dam		= damfileread(cfg.damfile);
catch %#ok<CTCH>
    data = [];
    disp('No Dam-file');
    return
end
nTrials = length(dam);

%% Load DAT-file
if ~isempty(cfg.behaviorfile)
[TN, D, A, RV, RD, MD, RT, RW] = textread (cfg.behaviorfile,...
        '%d %d  %f %f %f %f %d %d','headerlines',3,'delimiter',';');
    Trialnum        = TN;
    duration        = D;
    Attenuation     = A;
    ripplevelocity  = RV;
    rippledensity   = RD;
    modulationdepth = MD;
    reac            = RT;
    reward          = RW;
end

%% Load MAT-file
d		= dir([fname '-*.mat']);
if length(d)==(length(dam)-1)
    skip = 2;
    disp('Uh-Oh');
    str = ['# LFP-files: ' num2str(length(d))];
    disp(str);
    str = ['# DAM-trials: ' num2str(length(dam))];
    disp(str);
    str = 'Missing 1 Trial in LFP-files';
    disp(str);
    str = 'Skipping Trial #2';
    disp(str);
elseif length(d)~=length(dam) 
    disp('Uh-Oh');
    str = ['# LFP-files: ' num2str(length(d))];
    disp(str);
    str = ['# DAM-trials: ' num2str(length(dam))];
    disp(str);
    data = [];
    return
else
    skip = [];
end

Trial	= struct([]);
if isempty(skip)
    trialnr = 1:nTrials;
elseif skip==2
    trialnr = [1 3:nTrials];
end
nTrials = 1:length(trialnr);
for i = nTrials
% 	disp(['Trial: ' num2str(i)]);
	% Load
    matname = [fname '-' num2str(i)];
	load(matname);

    % Decimate LFP
	x       = data(:,1); %#ok<NODEF>
	Fs		= round(1/mean(diff(reltime))); % Sample frequency Hz
	if Fs > 1000
		q = round(Fs/1000);
		x = decimate(x,q);
		Trial(i).samplefrequency					= round(Fs/q); % Downsampled Sample Frequency
    else
		Trial(i).samplefrequency					= Fs; % Downsampled Sample Frequency
	end
	Trial(i).lfp				= x;
      
    % Load Spike-trace
    Trial(i).spiketrace			= dam(trialnr(i)).signal;
	
    % Stimulus parameters
    Trial(i).stimulus.params	= dam(trialnr(i)).stim.params;
	Trial(i).stimulus.values	= dam(trialnr(i)).stim.values;

	Trial(i).TrialNr			= i;
    
    % Behavior
    if ~isempty(cfg.behaviorfile)
        try
        Trial(i).reactiontime = reac(trialnr(i));
        catch
        Trial(i).reactiontime = -5000;
        end
    end
end
toc
disp(['End ' mfilename]);

%%
data	= struct([]); %#ok<NASGU>
data    = Trial;

%% Bookkeeping
% Add function name to configuration
cfg.function = mfilename('fullpath');

% Add input/previous configuration to cfg structure
cfg.previous = previous;