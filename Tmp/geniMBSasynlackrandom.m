function [S3,M3,Fs] = geniMBSasyn(Lvl)

%% Creating stimulus containing signal and masker
% 
% This function generates an asynchronous informational Multiple Bursts Different
% for a given level (Lvl). 
% S3 is the sound containing signal and maskers
% M3 is the sound containing only maskers
if nargin<1
	Lvl = 10;
end
%% Important!!!: the delays are arbirtrarly chosen, shouldn't there be a random interval???

%%  Setting stimulus sound parameters
dur			= 10;			% duration of signal stimulus in [ms]
Fs          = 48828.125;	% TDT Nyquist sampling frequency (Hz)
N = round(dur/1000*Fs);		%samples
durenv = 2.5;				%duration of envelope in, prevent click [ms]
Nenv = round(durenv/1000*Fs); %samples envelope

%% Creating frequency bands, 0.2-14 kHz spaced 1/6 octave
F1			= 200;					%beginning frequency hz
Fsig		= 4000;					%frequency signal (Hz)
Nfreq		= 38;					%number of frequency bands
Nmask		= 4;					%number of tones in masker
freqband	= pa_oct2bw(F1,(0:Nfreq-1)*1/6);	%frequency band, 0.2-14 kHz spaced 1/6 octave
protband	= pa_oct2bw(Fsig,[-1/3 1/3]);		%create protected band (1/3 octave above/below Fsig)
sel			= freqband<protband(1) | freqband>protband(2);
freqband	= freqband(sel); 
Nfreq		= numel(freqband);			%Nfreq - protected band
indx		= randperm(Nfreq,Nmask);	%selecting (4) maskers from Nfreq
Fmask		= sort(freqband(indx));		%retrieving corresponding frequencies from indx (masker frequencies) [Hz]
%% Creating signal stimulus + maskers; asynchronous iMBS
rate = 10;									%cycli/s frequency, create rate for stimulus
period = 1/rate;							%s time interval
nrep = 4;									%repetitions of signal +1 
nperiod = round(period*Fs);					%time interval between signals (samples)
%% new
s3			= pa_gentone(N,Fsig,Nenv,Fs,0);		%signal iMBD
	s3 = Lvl*s3;
% 	dB = 20*log10(rms(Lvl*s3));
m21			= pa_gentone(N,Fmask(1),Nenv,Fs,0); %masker 1
m22			= pa_gentone(N,Fmask(2),Nenv,Fs,0); %masker 2
m23			= pa_gentone(N,Fmask(3),Nenv,Fs,0); %masker 3
[m24,fs]    = pa_gentone(N,Fmask(4),Nenv,Fs,0); %masker 4 

S3 = zeros(1,round(nrep*nperiod));			%creating sound
S3(1:N) = s3;								%filling first stimulus interval
interval = (nperiod-N)/4;					%interval between maskers
interval = round(interval);

delay1 = delay(100)
delay2 = N+interval+delay(100)
delay3 = N+2*interval+delay(100)
delay4 = N+3*interval+delay(100)

S3(N+delay1:2*N+delay1-1) = m23;
S3(N+delay2:2*N+delay2-1) = m21;
S3(N+delay3:2*N+delay3-1) = m22;
S3(N+delay4:2*N+delay4-1) = m24;
S3(nperiod+1:nperiod+N) = s3

plotspec(S3,Fs)
wavplay(S3, Fs)

t = 1:length(S3);
t = t/fs;

figure
plot(t,S3)




% M3 = zeros(1,round(nrep*nperiod)+delaym24);
% 
% 
% d = 0;			
% while d < nrep;
% 	d = d + 1;
% 	
% 	indexs = (d*nperiod+1):(d*nperiod+N); %filling in signal sound
% 	S3(indexs) = s3;
% 	
% 	indexm21 = (d*nperiod+N+delaym21):(d*nperiod+2*N+delaym21-1); %filling in first delayed masker (m21)
% 	S3(indexm21) = m21;
% 	M3(indexm21) = m21;
% 	
% 	indexm22 = (d*nperiod+N+delaym22):(d*nperiod+2*N+delaym22-1); %filling in first delayed masker (m21)
% 	S3(indexm22) = m22;
% 	M3(indexm22) = m22;
% 	
% 	indexm23 = (d*nperiod+N+delaym23):(d*nperiod+2*N+delaym23-1); %filling in first delayed masker (m21)
% 	S3(indexm23) = m23;
% 	M3(indexm23) = m23;
% 	
% 	indexm24 = (d*nperiod+N+delaym24):(d*nperiod+2*N+delaym24-1); %filling in second delayed masker (m22)
% 	S3(indexm24) = m24;
% 	M3(indexm24) = m24;
% end
% 
% t = 1:length(S3);
% t = t/fs;
% 
% figure
% plot(t,S3)
% 
% figure
% plot(t,M3)
% 
% wavplay(S3,fs) %#ok<*REMFF1>
% 
% wavplay(M3,fs)
% 
% 
% plotspec(S3,fs)
% plotspec(M3,fs)









