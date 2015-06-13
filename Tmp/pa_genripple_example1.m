function pa_genripple_example
% PA_GENRIPPLE(VEL,DENS,MOD,DURDYN,DURSTAT)
%
% Generate a ripple stimulus with velocity (amplitude-modulation) VEL (Hz),
% density (frequency-modulation) DENS (cyc/oct), and a modulation depth MOD
% (0-1). Duration of the ripple stimulus is DURSTAT+DURRIP (ms), with the first
% DURSTAT ms no modulation occurring.
%
% These stimuli are parametrized naturalistic, speech-like sounds, whose
% envelope changes in time and frequency. Useful to determine
% spectro-temporal receptive fields.  Many scientists use speech as
% stimuli (in neuroimaging and psychofysical experiments), but as they are
% not parametrized, they are basically just using random stimulation (with
% random sentences).
%
% See also PA_GENGWN, PA_WRITEWAV

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com


%% Initialization
vel = 4;
dens = 0;
mod = 100; % Percentage (0-100%)
durrip = 1000; %msec
durstat = 1; %msec
disp	= 1;
sv	= 'n';
plee	= 'n';

tic
mod			= mod/100; % Gain (0-1)
Fs			= 50000; % Freq (Hz)
nRip        = round( (durrip/1000)*Fs ); % # Samples for Rippled Noise
nTime		= nRip; % Total # of samples
time		= ((1:nTime)-1)/Fs; % Time (sec)

%% According to Depireux et al. (2001)
nFreq   = 128;
FreqNr  = 0:1:nFreq-1;
F0      = 250;
Freq    = F0 * 2.^(FreqNr/20);
max(Freq)
Oct     = FreqNr/20;                   % octaves above the ground frequency
Phi     = pi - 2*pi*rand(1,nFreq); % random phase
Phi(1)  = pi/2; % set first to 0.5*pi
oct		= repmat(Oct',1,nTime); % Octave

%% Generating the ripple
% Create amplitude modulations completely dynamic without static
A = NaN(nTime,nFreq);
for ii = 1:nTime
	for jj = 1:nFreq
		A(ii,jj)      = 1 + mod*sin(2*pi*vel*time(ii) + 2*pi*dens*oct(jj));
	end
end

% Modulate carrier, with static and dynamic part
snd = 0;
for ii = 1:nFreq
	carr			= A(:,ii)'.*sin(2*pi* Freq(ii) .* time + Phi(ii));
	snd				= snd+carr;
end


toc


%% Graphics
if disp
	close all
	figure
	t = (1:length(snd))/Fs;
	subplot(221)
	plot(t,snd,'k-')
	ylabel('Amplitude (au)');
	ylabel('Time (ms)');
	xlim([min(t) max(t)]);
	axis square;
	box off;
	
	subplot(223)
	nfft = 2^11;
	window			= 2^7; % resolution
	noverlap		= 2^5; % smoothing
	spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');
	cax = caxis;
	caxis([0.7*cax(1) 1.1*cax(2)])
	ylim([min(Freq) max(Freq)])
	set(gca,'YTick',(1:2:20)*1000,'YTickLabel',1:2:20);
	axis square;

	subplot(224)
	pa_getpower(snd,Fs,'orientation','y'); % obtain from PandA
	ylim([min(Freq) max(Freq)])
	ax = axis;
	xlim(0.6*ax([1 2]));
	set(gca,'Yscale','linear','YTick',(1:2:20)*1000,'YTickLabel',1:2:20)
	axis square;
	box off;
	
	
end

%% Print
cd('C:\DATA'); % See also PA_DATADIR
print('-depsc','-painter',mfilename); % I try to avoid bitmaps, 
% so I can easily modify the figures later on in for example Illustrator
% For web-and Office-purposes, I later save images as PNG-files
print('-djpeg','-r300',mfilename);

%% Play
if strcmpi(plee,'y');
	wavplay(snd,Fs);
end

%% Save
if strcmpi(sv,'y');
	wavfname = ['V' num2str(vel) 'D' num2str(dens) '.wav'];
	pa_writewav(snd,wavfname);
end
