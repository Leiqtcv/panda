function pp_resultsfigure6

% Subtract Bias (Offset, which can be different for various blocks/sessies
% This removes noise (artificial variation when data is combined, e.g. in
% one set you start from +10 and another time you start at +3, when
% combining sets, the responses will be distributed largely. But when the
% offset is 0 in both, the distribution of responses can be combined, no
% artificial variation.

%% Initialization
close all
clear all
clc

% pa_datadir('RG-MW-2011-12-02')
fnames = {'RG-MW-2011-12-02-0001';'RG-MW-2011-12-02-0002';'RG-MW-2011-12-02-0003';'RG-MW-2011-12-02-0004';...
    'RG-MW-2011-12-02-0005';'RG-MW-2011-12-02-0006';'RG-MW-2011-12-02-0007';'RG-MW-2011-12-02-0008';...
    'RG-MW-2011-12-08-0001';'RG-MW-2011-12-08-0002';'RG-MW-2011-12-08-0003';'RG-MW-2011-12-08-0004';...
    'RG-MW-2012-01-11-0001';'RG-MW-2012-01-11-0002';'RG-MW-2012-01-11-0003';'RG-MW-2012-01-11-0004';...
    'RG-MW-2012-01-12-0005';'RG-MW-2012-01-12-0006';'RG-MW-2012-01-12-0007';'RG-MW-2012-01-12-0008';...
    'RG-MW-2012-01-19-0001';'RG-MW-2012-01-19-0002';'RG-MW-2012-01-19-0003';'RG-MW-2012-01-19-0004';...
    };
sessienr = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 ];
conditions = [3 2 3 1,...
    3 2 1 3,...
    2 3 1 3,...
    2 3 1 3,...
    3 1 3 2,...
    1 3 3 2
    
    ]; % 1 - 10 deg, 2 - 29 deg, 3 - 50 deg, 4 - 50 deg

% for
% nsets = length(fnames);
rng = [10 30 50];
% nrng = length(rng);
% Gain = NaN(nsets,nrng,2);
for ii = 2
    sel = conditions==ii;
    
    fname = fnames(sel);
    nfiles = length(fname);
    SS = [];
    %     nfiles = 4;
    for jj = 1:nfiles
        file = fname{jj};
        pa_datadir(['Prior\' file(1:end-5)]);
        load(file); %load fnames(ii) = load('fnames(ii)');
        SupSac      = pa_supersac(Sac,Stim,2,1);
        SS          = [SS;SupSac];
    end
    TarAz       = SS(:,23);
    TarEl       = SS(:,24);
    ResAz       = SS(:,8);
    ResEl       = SS(:,9);
    
    plot(ResEl,'r.');
    hold on
    plot(TarEl,'g-');
    
    
    s.x = 12;
    s.A = 1;
    % Define a process noise (stdev) of 2 volts as the car operates:
    s.Q = 3^2; % variance, hence stdev^2
    % Define the voltimeter to measure the voltage itself:
    s.H = 1;
    % Define a measurement error (stdev) of 2 volts:
    s.R = 0.5^2; % variance, hence stdev^2
    % Do not define any system input (control) functions:
    s.B = 0;
    s.u = 0;
    % Do not specify an initial state:
    s.x = nan;
    s.P = nan;
    % Generate random voltages and watch the filter operate.
    tru = []; % truth voltage
    n = length(ResEl);
    for t = 1:n
        tru(end+1)	= TarEl(t);
        s(end).z		= ResEl(t); % create a measurement
        s(end+1)		= kalmanf(s(end)); % perform a Kalman filter iteration
    end
    figure
    subplot(211)
    hold on
    grid on
    % plot measurement data:
    hz=plot([s(1:end-1).z],'r.');
    % plot a-posteriori state estimates:
    hk=plot([s(2:end).x],'b-');
    ht=plot(tru,'g-');
    legend([hz hk ht],'observations','Kalman output','true voltage',0)
    title('Automobile Voltimeter Example')
    hold off
    
    MAP = [s(2:end).x];
    subplot(234)
    pa_loc(tru',MAP');
    pa_unityline;
    axis square;
    
    tru1 = tru(1:n/2);
    MAP1 = MAP(1:n/2);
    sel = abs(tru1)<10;
    subplot(235)
    pa_loc(tru1(sel)',MAP1(sel)');
    pa_unityline;
    axis square;
    
    tru2 = tru((n/2+1):end);
    MAP2 = MAP((n/2+1):end);
    sel = abs(tru1)<10;
    
    subplot(236)
    pa_loc(tru2(sel)',MAP2(sel)');
    pa_unityline;
    axis square;
end
pa_datadir;
save kalmanSS SS
