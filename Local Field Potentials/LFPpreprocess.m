function [data,cfg] = LFPpreprocess(data,cfg)
% [DATA,CFG] = LFPPREPROCESS(DATA,CFG)
%
% Preprocesses the LFP signals such that 50 Hz line noise and spike
% contribution is removed.
%
% See also LFPREMOVE50HZ, LFPREMOVESPIKES
%
% 2010 Marc van Wanrooij

%% Configuration
if ~isfield(cfg,'removespikemethod')
    cfg.removespikemethod = [];
end
if ~isfield(cfg,'removetrials')
    cfg.removetrials = [];
end

% Get Previous Configuration
previous                = cfg;

%% Trial-by-trial preprocessing
disp(['Start ' mfilename]);
tic
for i = 1:length(data)
    % Remove 50 Hz from LFP
    y               = LFPremove50hz(data(i).lfp,data(i).samplefrequency);
    y               = lowpassnoise(y,200,(data(i).samplefrequency)/2,100);
    data(i).lfpfilt            = y;
    
%     y               = lowpassnoise(data(i).lfp,200,(data(i).samplefrequency)/2,50);
%     data(i).lfpfilt            = y;
    
    % Filter Spike
    spike               = data(i).spiketrace;
    spike               = highpassnoise(spike,1000,25000,100);
    spike               = lowpassnoise(spike,10000,25000,100);
    data(i).spikefilt   = spike;
end

% %% Remove Trials with extremely large amplitudes
if cfg.removetrials
    LFPm    = [data.lfpfilt]; % Matrix, time x trial
    LFPv    = LFPm(:); % Vector
    lvl     = std(LFPv); % noise level
    sel     = any(abs(LFPm-mean(LFPv))>6*lvl);
    data    = data(~sel);
    % display what we removed
    str     = ['Removed ' num2str(sum(sel)) ' trials'];
    disp(str);
end
%% Cleanup LFP signal (remove spike power)
if ~isempty(cfg.removespikemethod)
    for i = 1:length(data)
        try
            x = data(i).spikefilt; x   = x(:);
            y = data(i).lfpfilt; y      = y(:);
            output_clean                = LFPremovespikes(x, 25000, y, 1000, 1000, cfg.removespikemethod, 0, 1);
            data(i).lfpclean            = output_clean';
        catch
            data(i).lfpclean            = data(i).lfpfilt;
        end
    end
end
toc
disp(['End ' mfilename]);

%% Bookkeeping
% Add function name to configuration
cfg.function = mfilename('fullpath');

% Add input/previous configuration to cfg structure
cfg.previous = previous;