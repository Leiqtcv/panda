%% Creating stimulus containing signal and masker
% This script creates a psychophysical experiment by which the test person
% is given a 2AFC for a sound containing only signals or a sound containing
% signals and maskers. 
% the maskers are arranged by a 'asynchronous multiple burst same' order.
%% %% Important!!: not working, str2double(resp) gives NaN???
%%  Setting stimulus sound parameters
close all
clear all
dur = 10; % ms
Fs          = 48828.125; % TDT Nyquist sampling frequency (Hz)
N = round(dur/1000*Fs);  % samples
durenv = 2.5; %ms
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
%% Creating user input after delivering sound stimulus; asynchronous iMBS
i = 0;
step = 1 % dB
stp = 0; % stp for ending experiments after 10 reversals
h = figure;
Lvl = 20; %starting signal level
cnt=1; % starting count
CNT=0;	%starting count for reversals

while ~stp	
	cnt = cnt+1;
	[S3,M3,Fs] = geniMBSasyn(Lvl);		%opening masker and signal for Lvl
										
	int = randperm(2,1);				%creating random interval for signal + masker or masker alone
	INT(cnt) = int;						%keeping track of interval for count
	LVL(cnt) = Lvl;						%keeping track of level for count

	switch int							%creating switch for random interval delivery
		case 1							%first signal + masker
			p = audioplayer(S3, Fs);		
			playblocking(p);
			
			pause(1);					%pause 1 s
			
			p = audioplayer(M3, Fs);		%second masker no signal
			playblocking(p);
			
			plotspec(S3,Fs)
		case 2							%first only masker
			p = audioplayer(M3, Fs);
			playblocking(p);
			
			pause(1);
			
			p = audioplayer(S3, Fs);
			playblocking(p);
			
			plotspec(M3,Fs)
	end
	
	figure(h);
										
	pause;									%Get the keypress
	resp = get(h,'CurrentCharacter');		%Get the keypress. choose if signal + masker was case 1 or 2
	%whos resp								%show responses
	if str2double(resp)==int				%if response was correct interval (1 or 2), 3 step down
		Lvl = Lvl-3*step;
		correctresp(1,cnt) = 1
	elseif str2double(resp)~=int			%if response was incorrect interval, 1 step up
		Lvl = Lvl+1*step;
		correctresp(1,cnt) = 0
	end
	%if correctresp(1,cnt)~=correctresp(1,cnt-1)
	%	CNT = CNT + 1
	%end
	if cnt == 5							%creating end for stimuli, after CNT-1(!) reversals
		stp = 1;						%CAUTION: FIRST RESPONSE NEEDS TO BE CORRECT
	end
	RESP(cnt) = str2double(resp);
end