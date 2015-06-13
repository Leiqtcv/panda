function Spike = SPKpeaklimits(Spike,cfg)
% SPKPLOTPEAKS(SPK)
%
% Plot two spike peaks against each other in BrainWare style
%
% (c) Marc van Wanrooij 2010

%% Initialization
previous	= cfg;
if isfield(cfg,'threshold')
	thresh	= cfg.threshold;
else
	thresh = 40;
end

spikes			= [Spike.spikewave];
trial			= [Spike.trial];
moments			= [Spike.spiketime];
uTrial			= unique(trial);

%% crude upper limit
MX			= max(abs(spikes));
sel			= MX>thresh;
spikes		= spikes(:,~sel);
trial		= trial(:,~sel);
moments		= moments(:,~sel);

l = length(uTrial);
for ii		= 1:l
	sel		= trial == uTrial(ii);
	if sum(sel)
		Spike(ii).spikewave = spikes(:,sel);
		Spike(ii).spiketime = moments(:,sel);
		Spike(ii).trial		= trial(:,sel);
	else
		Spike(ii).spikewave = [];
		Spike(ii).spiketime = [];
		Spike(ii).trial = [];
	end
end

%% Bookkeeping
% Add function name to configuration
cfg.function = mfilename('fullpath');

% Add input/previous configuration to cfg structure
cfg.previous = previous;