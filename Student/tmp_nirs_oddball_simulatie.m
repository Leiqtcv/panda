%% Simulate oddball paradigm

% By Luuk van de Rijt & Marc van Wanrooij, July 2014

%% Clean

clear all;
close all;
clc;

%% Data simuleren

dur     =   4*60;                                   % duur van blok (s)
fs      =   50;                                     % sampling rate/ freq (Hz) or (samples/s)
N       =   dur*fs;                                 % aantal samples

t       = 0:(N-1);                                  % tijd (samples)
t       = t/fs;                                     % tijd (s)

%% Signaal
x       =   zeros(size(t)); 

%% Grafiek
figure (1)
subplot (231)
plot (t,x)
xlabel('time (s)');
ylabel ('[OHb] (\muM)');

%% Heartbeat
% Simulatie van hartslag dmv sinus

heartrate       = 60/60;                            % 60 slagen per minuut = 1 Hz
heartamp        = 1.1;
heart           = heartamp*sin(2*pi*heartrate*t+cumsum(0.5*rand(size(t)))); %sinusfunctie hartslag

hold on
figure(1)
subplot (232)
plot (t,heart,'r');
xlim ([0 5]);
title('Heartrate');

%% Mayer waves


mayerrate       = 0.1;                                          % 1 mayer wave per 10 sec 1/10 (Hz)
mayeramp        = 0.4;
mayer           = mayeramp*sin (2*pi*mayerrate*t+2*pi*rand(1)); % sinusfunctie mayerwave

hold on
figure(1)
subplot (233)
plot (t,mayer,'r');
xlim ([0 50]);
title('Mayer wave');

%% Ruis

noiseamp    =  0.2;                                                 %amplitude noise
noise       =   noiseamp*randn(size(t));                            % random noise

figure (1)
subplot(234)
plot (t,noise,'b');
xlim ([0 5]);
title ('Noise');


%% Signal toevoegen

stimdur = 100/1000;                                             % stim dur in s
ISI = 1500/1000;                                                % inter stimulus interval (s)
nstim = floor (dur/((stimdur + ISI)));                          % number of stimuli in block
nstd = floor (0.92*nstim);                                      % number of std stimuli is 92%
nodd = nstim - nstd;                                            % number of odd stimuli is 8%
stimindx = 1:nstim;                                             % complete index stimuli
stdindx = sort(randperm (nstim,nstd));                          % random oddballs and standard times
oddindx = setdiff(stimindx,stdindx);                            % index for odd stimuli = setdifference between complete stimuli index and standard stimuli index
stdstimulus = zeros (size(t)); 
oddstimulus = zeros (size(t));
for ii = 1:nstim
    sel = stdindx == ii;
    idx = floor((1:(stimdur*fs))+(ii-1)*(stimdur+ISI)*fs);
    if any (sel) 
    stdstimulus(idx) = 1; 
    elseif ~any(sel)
        oddstimulus (idx) = 1;
        
    end
end

%% Adaptation
dstnd = [1 diff(stdindx)]

plot(stdindx,dstnd)
pa_horline
%%
% return
%% Hemodynamic impulse response
hdur     = 50;                      % sec
xh      = 0:(1/fs):hdur;            % sec
a1		= 6;                        % peak time 4.5 s after stim, shape
b1		= 1;                        % scale
a2		= 16;                       % peak time 4.5 s after stim, shape
b2		= 1;                        % scale
c		= 1/6;
stdbeta	= 0.3;
oddbeta = 0.4;

H       = (gampdf(xh,a1,b1)-c*gampdf(xh,a2,b2));

figure (4)
plot (xh,H);

%% Convolutie signal - summatie met verleden - linear systeem theorie

stdsignaal = conv(stdstimulus,H*stdbeta);               % convoluting is het summeren van H en stdstimulus, waarbij beta voor std stimulus
stdsignaal = stdsignaal (1:length(t)); 

oddsignaal = conv(oddstimulus,H*oddbeta);               % beta coefficient for oddstimulus
oddsignaal = oddsignaal (1:length(t)); 

%%
figure (1)
subplot (235)
hold on
plot (t,stdstimulus,'k');
plot (t,stdsignaal,'r','LineWidth',2); 
plot (t,oddsignaal,'g','LineWidth',2);
plot (t,oddsignaal+stdsignaal,'b','LineWidth',2);
title ('Signal / design matrix');
%xlim ([0 50]); 
xlabel('time (s)');
ylabel ('[OHb] (\muM)');
hold on
 
%% Add total signal

x = x + heart + mayer + noise + stdsignaal; 
x = stdsignaal; 

figure (1)
subplot (236)
plot (t,x);

figure(3)
x		= stdsignaal; 
nfft	= 2^(nextpow2(length(x)));
s		= fft(x,nfft);
m		= abs(s)/length(x);
m		= m(1:nfft/2)*2;
f		= (0:nfft/2-1)*fs/nfft;
plot(f,m,'r');
hold on

x		= oddsignaal; 
nfft	= 2^(nextpow2(length(x)));
s		= fft(x,nfft);
m		= abs(s)/length(x);
m		= m(1:nfft/2)*2;
f		= (0:nfft/2-1)*fs/nfft;
plot(f,m,'g');

x		= noise; 
nfft	= 2^(nextpow2(length(x)));
s		= fft(x,nfft);
m		= abs(s)/length(x);
m		= m(1:nfft/2)*2;
f		= (0:nfft/2-1)*fs/nfft;
plot(f,m,'k');


x		= heart+mayer; 
nfft	= 2^(nextpow2(length(x)));
s		= fft(x,nfft);
m		= abs(s)/length(x);
m		= m(1:nfft/2)*2;
f		= (0:nfft/2-1)*fs/nfft;
plot(f,m,'b');

xlabel('Frequency (Hz)');
ylabel('Magnitude / [OHb] (\muM)');
xlim([0 1]);
axis square









