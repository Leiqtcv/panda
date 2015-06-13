function gen60(grph)
% GEN60(grph)
%
% Generate 20 BB, 20 HP and 20 LP stimuli.

% Author: Marc van Wanrooij
% Copyright 2007

%% Initialization
if nargin<1
	grph = 0;
end
if grph
	close all;
end
marc

%%
Fs          = 48828.125;
Fn          = Fs/2; % TDT Nyquist sampling frequency (Hz)
Fc          = 20000; % Hz
Fl          = 1500; % Hz
Fh          = 3000; % Hz
order       = 120; % samples
NEnvelope   = 500; % samples
T           = 0.15; % sec
Tbzz		= .02; % sec
N           = ceil(T*Fs); % samples
Nbzz		= round(Tbzz*Fs);
fac			= round(N/Nbzz);

Nfft        = 2^12;
SF          = 0.999;
%% Experiment 1
Tn			= [7 0 127 77];
speaker		= [8 20 30 31];

%% Experiment 2
Tn			= round([3.1455 5.0000 0 79.0000 69.4727]);
speaker		= [9 12 16 30 31];
N0samples   = ceil(60/1000*Fs);

BZZ			= genbzz(N,Nbzz,NEnvelope,order,Fc,Fn,500);
mn			= min([numel(BZZ) N]);
SND			= gengwn(mn,NEnvelope,order,Fc,Fn,500);

% wavplay(BZZ,Fs);
% return
SND			= highpassnoise(SND,500,Fn);
BZZ			= highpassnoise(BZZ,500,Fn);
20*[log10(rms(SND))-log10(rms(BZZ))]

DD			= SND+BZZ;
for i       = 1:length(Tn)
	N0pre			= zeros(1,N0samples-Tn(i));
	N0post          = zeros(1,N0samples+Tn(i));
	stm				= [N0pre SND N0post]; %#ok<AGROW>
	bzz				= [N0pre BZZ N0post];
	dd				= [N0pre DD N0post];
	if speaker(i)<11
		fname = ['snd10' num2str(speaker(i)) '.wav'];
		bzzname = ['snd20' num2str(speaker(i)) '.wav'];
		ddname = ['snd30' num2str(speaker(i)) '.wav'];
	else
		fname = ['snd1' num2str(speaker(i)) '.wav'];
		bzzname = ['snd2' num2str(speaker(i)) '.wav'];
		ddname = ['snd3' num2str(speaker(i)) '.wav'];
	end
	writewav(stm,fname,SF);
	writewav(bzz,bzzname,SF);
	writewav(dd,ddname,SF);
	
% 	wavplay(dd,Fs)
	[y,fs]	= wavread(bzzname);
	t		= 1000*(0:length(y)-1)/fs;
	if grph
		figure
		clf
		subplot(211)
		plot(t,y,'k-');
		xlabel('Time (msec');
		ylabel('Amplitude (a.u.)');
% 		xaxis([1 t(end)]);
		box on
		ylim([-1 1])
		
		subplot(212)
		X           = y(N0samples:end-N0samples);
		WINDOW      = 2^9;
		NOVERLAP    = 2^8;
		NFFT        = 2^9;
		spectrogram(X,WINDOW,NOVERLAP,NFFT,Fs,'yaxis')
		drawnow
% 		pause
	end
end
writewav(stm,'snd100',0);

