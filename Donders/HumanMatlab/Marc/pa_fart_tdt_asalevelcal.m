function pa_fart_tdt_asalevelcal
% PA_ASACOMPLEX
%
% FART Experiment

% 2012 Marc van Wanrooij

%% Cleaning up
close all
clear all
clc

%% File IO Dialog
options.Resize		= 'on';
options.WindowStyle = 'normal';

% 
% pause(15);

%% Initalize TDT circuits
RP2_1circuit	= 'D:\HumanV1\Marc\RCO&RPX\MicroMarc2_rp2.rco'; %#ok<NASGU>
RP2_2circuit	= 'D:\HumanV1\Marc\RCO&RPX\MicroMarc2_rp2.rco'; %#ok<NASGU>
RA16_1circuit	= 'D:\HumanV1\Marc\RCO&RPX\Marc_8Channels_ra16_1.rco'; %#ok<NASGU>
pa_fart_tdt_humaninit; % Initialize TDT & microcontroller
H				= findobj('Tag','ActXWin');
figure(H)
zBus			= actxcontrol('zBus.x',[341 101 20 20]); % trigger zBus


%% Sound

sgndB		= 80; % dB
rand('twister', sum(100*clock)); % seed
speaker		= 12; % sound elevation
hoopled		= 12;
stimtype	= 1;

%% Response and data acquistion
nsamples	= 5000;
RA16_1.SetTagVal('Samples',nsamples);

%% Experiment

		lvl			= 80; % sound level (dB)

for ii = 1:12

		%% Generate signal
		sgnlvl	= 10^((sgndB-lvl)/20); %
		[SM,S,M] = pa_genasacomplex(stimtype,sgnlvl);
		
		%% Start trial by showing LED
		str		= sprintf('%d;%d;%d;%d;%d',stimLed,0,hoopled,255,1);
		micro_cmd(com,cmdStim,str);
		str		= sprintf('%d;%d;%d;%d;%d',stimSky,0,1,255,1);
		micro_cmd(com,cmdStim,str);

		lvl			= 95-ii*5; % sound level (dB)
		level		= 0.4 + 0.008*lvl; % sound level
		snd = M;
		
		
		pa_fart_tdt_playsound(snd,RP2_1,zBus,com,level,speaker,stimSnd1,cmdSpeaker)

	

		pause(15)
		

end
close(com);
% close all;



function [SM,S,M,Fs,par] = pa_genasacomplex(stim,Lvl)

if nargin<1
	stim = 4;
end
if nargin<2
	Lvl = 10;
end
%% Creating stimulus containing signal and masker
% This function generates an synchronous informational Multiple Bursts Same
% for a given level (Lvl).
% S is the sound containing signal and maskers
% M is the sound containing only maskers

%%  Setting stimulus sound parameters
dur			= 10000; % ms
Fs          = 48828.125; % TDT Nyquist sampling frequency (Hz)
N			= round(dur/1000*Fs);  % samples
durenv		= 50; %ms
Nenv		= round(durenv/1000*Fs); %samples envelope

%% Creating frequency bands, 0.2-14 kHz spaced 1/6 octave
F1			= 200;					%beginning frequency hz
Fsig		= 4000;					%frequency signal (Hz)
Nfreq		= 38;					%number of frequency bands
Nmask		= 1;					%number of tones in masker
freqband	= pa_oct2bw(F1,(0:Nfreq-1)*1/6);	%frequency band, 0.2-14 kHz spaced 1/6 octave
protband	= pa_oct2bw(Fsig,[-1/3 1/3]);		%create protected band (1/3 octave above/below Fsig)
sel			= freqband<protband(1) | freqband>protband(2);
freqband	= freqband(sel)
Nfreq		= numel(freqband);			%Nfreq - protected band

%% Creating temporal bands
rate		= .1;								% cycli/s frequency
period		= 1/rate;							% s time interval
Nrep		= 1;								% repetitions of signal
Nperiod		= round(period*Fs);					% time interval between signals (samples)

%% Timings and frequencies
T		= freqband(34)									%pa_rndval(1,Nperiod,[Nmask,Nrep]);
F		= T;
% for ii	= 1:Nrep
% 	indx			= randperm(Nfreq);	%selecting Nmask maskers from Nfreq
% 	indx			= indx(1:Nmask);
% 	F(:,ii)			=  sort(freqband(indx));		%retrieving corresponding frequencies from indx (masker frequencies) [Hz]
% end

%% Synchronous
switch stim
	case 1 % Different Masker  Frequency / Asynchronous
	case 2 % Same Masker  Frequency / Asynchronous
		F(:,2:Nrep) = repmat(F(:,1),1,(Nrep-1));
		T(:,2:Nrep) = repmat(T(:,1),1,(Nrep-1));
	case 3 % Different Masker  Frequency / Synchronous
		T			= zeros(Nmask,Nrep);
	case 4 % Same Masker  Frequency / Synchronous
		F(:,2:Nrep) = repmat(F(:,1),1,(Nrep-1));
		T			= zeros(Nmask,Nrep);
end
t = floor(T/Fs*1000/25)*25;
T = round(t*Fs/1000)+1;

%% Repetitive Signal
S		= zeros(1,round((Nrep+1)*Nperiod));			%creating empty vector for sounds
M		= zeros(1,round((Nrep+1)*Nperiod));			%creating empty vector for maskers
s		= pa_gentone(N,Fsig,Nenv,Fs,0);		%#ok<*NASGU> %signal synchronous iMBS
for ii = 1:Nrep
	indx	= ((ii-1)*Nperiod+1):((ii-1)*Nperiod+N);
	S(indx) = s;
end

%% Masker
for ii = 1:Nrep
	for jj = 1:Nmask
		s		= pa_gentone(N,F(jj,ii),Nenv,Fs,0);		%#ok<*NASGU> %signal synchronous iMBS
		indx	= ((ii-1)*Nperiod+1+T(jj,ii)):((ii-1)*Nperiod+N+T(jj,ii));
		M(indx) = M(indx)+s;
	end
end
SM = Lvl*S+M;

S = S(1:N);
M = M(1:N);

par.T		= T;
par.F		= F;
par.rate	= rate;
par.period	= period;							% s time interval
par.nrep	= Nrep;								% repetitions of signal
par.nperiod = Nperiod;
par.fsignal = Fsig;
par.fs		= Fs;
par.durenv	= durenv; % envelope duration
par.stim	= stim; % stimulus type