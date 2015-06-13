function [S2,M2,Fs] = geniMBDsyn(Lvl)

%% Creating stimulus containing signal and masker
% This function generates an synchronous informational Multiple Bursts
% Different for a given level (Lvl). 
% S2 contains signal and maskers
% M2 contains only maskers
%
%% Important!!: sort gets the masker values in ascending order, but we want random values
%%  Setting stimulus sound parameters
dur			= 10; % ms
Fs          = 48828.125; % TDT Nyquist sampling frequency (Hz)
N = round(dur/1000*Fs);  % samples
durenv = 2.5; %ms
Nenv = round(durenv/1000*Fs); %samples envelope

%% Creating frequency bands, 0.2-14 kHz spaced 1/6 octave
F1			= 200;					%beginning frequency hz
Fsig		= 4000;					%signal frequency (Hz)
Nfreq		= 38;					%number of frequency bands
Nmask		= 20;					%number of tones in masker
freqband	= pa_oct2bw(F1,(0:Nfreq-1)*1/6);	%frequency band, 0.2-14 kHz spaced 1/6 octave
protband	= pa_oct2bw(Fsig,[-1/3 1/3]);		%create protected band (1/3 octave above/below Fsig)
sel			= freqband<protband(1) | freqband>protband(2);
freqband	= freqband(sel); 
Nfreq		= numel(freqband);			%Nfreq - protected band
indx		= randperm(Nfreq,Nmask);	%selecting (16) maskers from Nfreq
Fmask		= sort(freqband(indx));		%retrieving corresponding frequencies from indx (masker frequencies) [Hz]

%% Creating signal stimulus + maskers; synchronous iMBD
[s2,fs]     = pa_gentone(N,Fsig,Nenv,Fs,0);				 %signal synchronous iMBD
[m11,fs]    = pa_gentone(N,Fmask(1),Nenv,Fs,0); %masker 1
[m12,fs]    = pa_gentone(N,Fmask(2),Nenv,Fs,0); %masker 2
[m13,fs]    = pa_gentone(N,Fmask(3),Nenv,Fs,0); %masker 3
[m14,fs]    = pa_gentone(N,Fmask(4),Nenv,Fs,0); %masker 4
[m15,fs]    = pa_gentone(N,Fmask(5),Nenv,Fs,0); %masker 5
[m16,fs]    = pa_gentone(N,Fmask(6),Nenv,Fs,0); %masker 6
[m17,fs]    = pa_gentone(N,Fmask(7),Nenv,Fs,0); %masker 7
[m18,fs]    = pa_gentone(N,Fmask(8),Nenv,Fs,0); %masker 8
[m19,fs]    = pa_gentone(N,Fmask(9),Nenv,Fs,0); %masker 9
[m20,fs]    = pa_gentone(N,Fmask(10),Nenv,Fs,0); %masker 10
[m111,fs]   = pa_gentone(N,Fmask(11),Nenv,Fs,0); %masker 11
[m112,fs]   = pa_gentone(N,Fmask(12),Nenv,Fs,0); %masker 12
[m113,fs]   = pa_gentone(N,Fmask(13),Nenv,Fs,0); %masker 13
[m114,fs]   = pa_gentone(N,Fmask(14),Nenv,Fs,0); %masker 14
[m115,fs]   = pa_gentone(N,Fmask(15),Nenv,Fs,0); %masker 15
[m116,fs]   = pa_gentone(N,Fmask(16),Nenv,Fs,0); %masker 16
[m117,fs]   = pa_gentone(N,Fmask(17),Nenv,Fs,0); %masker 17
[m118,fs]   = pa_gentone(N,Fmask(18),Nenv,Fs,0); %masker 18
[m119,fs]   = pa_gentone(N,Fmask(19),Nenv,Fs,0); %masker 19
[m120,fs]   = pa_gentone(N,Fmask(20),Nenv,Fs,0); %masker 20

rate = 10;									%cycli/s frequency
period = 1/rate;							%s time interval
nrep = 4;									%repetitions of signal
nperiod = round(period*Fs);					%time interval between signals (samples)
S2 = zeros(1,round(nrep*nperiod));			%creating empty vector for signal + maskers
M2 = zeros(1,round(nrep*nperiod));			%creating empty vector for maskers only

S2(0*nperiod+1:0*nperiod+N) = s2+m11+m17+m113+m119;	%filling in signal + maskervector voor synchronous iMBD
S2(1*nperiod+1:1*nperiod+N) = s2+m12+m18+m114+m120;
S2(2*nperiod+1:2*nperiod+N) = s2+m13+m19+m115+m116;
S2(3*nperiod+1:3*nperiod+N) = s2+m14+m20+m111+m117;
S2(4*nperiod+1:4*nperiod+N) = s2+m15+m116+m112+m118;

M2(0*nperiod+1:0*nperiod+N) = m11+m17+m113+m119;	%filling in masker vector voor synchronous iMBD
M2(1*nperiod+1:1*nperiod+N) = m12+m18+m114+m120;
M2(2*nperiod+1:2*nperiod+N) = m13+m19+m115+m116;
M2(3*nperiod+1:3*nperiod+N) = m14+m20+m111+m117;
M2(4*nperiod+1:4*nperiod+N) = m15+m116+m112+m118;


t = 1:length(S2);							%time [samples]
t = t/fs;									%time [s]

% figure
% plot(t,S2)									%sinus of sound waves S
% 
% figure
% plot(t,M2)

wavplay(S2,fs)								%play sound, synchronous iMBD
wavplay(M2,fs)

plotspec(S2,Fs)
plotspec(M2,Fs)

