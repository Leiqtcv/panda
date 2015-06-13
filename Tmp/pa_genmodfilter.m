function [snd,Fs] = pa_genmodfilter
% [SND,FS] = PA_GENRIPPLE(VEL,DENS,MOD,DURDYN,DURSTAT)
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
% random sentences).  Moving ripples are a complete set of orthonormal
% basis functions for the spectrogram.
%
% See also PA_GENGWN, PA_WRITEWAV

% 2012 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
sigVel = 4; % (Hz)
sigDens = 0; % (cyc/oct)
mskVel	= 4; % (Hz)
mskDens = 0; % (cyc/oct)

md = 100; % Percentage (0-100%)
dur = 1000; %msec
Ftar			= 8000;

%% Optional arguments
dspFlag	= 1;
sv		= 'n';
plee	= 'y';
Fs		= 48828.125; % Freq (Hz)
md			= md/100; % Gain (0-1)

%% According to Depireux et al. (2001)
nFreq	= 128;
FreqNr	= 0:1:nFreq-1;
F0		= 250;
df		= 1/20;
Freq	= F0 * 2.^(FreqNr*df);
Oct		= FreqNr/20;                   % octaves above the ground frequency
Phi		= 2*pi*rand(1,nFreq); % random phase

%% Sounds
mask			= genmask(mskVel,mskDens,md,dur,Fs,nFreq,Freq,Ftar,Oct,Phi);
signal			= gensignal(sigVel,sigDens,md,dur,Fs,nFreq,Freq,Ftar,Oct,Phi);
snd				= signal+mask;


%% Normalization
% Because max amplitude should not exceed 1
% So set max amplitude ~= 0.8 (44/55)
snd			= snd/55; % in 3 sets of 500 trials, mx was 3 x 44+-1
mask		= mask/55;
signal		= signal/55;

%% Graphics
if dspFlag
	plotspec(snd,Fs,Freq);
end

%% Play
if strcmpi(plee,'y');
	snd = pa_envelope(snd',round(10*Fs/1000));
	p	= audioplayer(snd,Fs);
	playblocking(p);

	snd = pa_envelope(mask',round(10*Fs/1000));
	p	= audioplayer(snd,Fs);
	playblocking(p);
end

%% Save
if strcmpi(sv,'y');
	wavfname = ['V' num2str(vel) 'D' num2str(dens) '.wav'];
	pa_writewav(snd,wavfname);
end

function plotspec(snd,Fs,Freq,durstat)
close all hidden;
t = (1:length(snd))/Fs*1000;
subplot(221)
plot(t,snd,'k-')
ylabel('Amplitude (au)');
ylabel('Time (ms)');
xlim([min(t) max(t)]);
hold on

subplot(224)
pa_getpower(snd,Fs,'orientation','y');
set(gca,'YTick',[0.5 1 2 4 8 16]*1000);
set(gca,'YTickLabel',[0.5 1 2 4 8 16]);
ylim([min(Freq) max(Freq)])
ax = axis;
xlim(0.6*ax([1 2]));
set(gca,'YScale','log');

subplot(223)
nsamples	= length(snd);
t			= nsamples/Fs*1000;
dt			= 12.5;
nseg		= t/dt;
segsamples	= round(nsamples/nseg); % 12.5 ms * 50 kHz = 625 samples
noverlap	= round(0.6*segsamples); % 1/3 overlap
window		= segsamples+noverlap; % window size
nfft		= 1000;
spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');

cax = caxis;
caxis([0.7*cax(1) 1.1*cax(2)])
ylim([min(Freq) max(Freq)])
set(gca,'YTick',[0.5 1 2 4 8 16]*1000);
set(gca,'YTickLabel',[0.5 1 2 4 8 16]);
set(gca,'YScale','log');
colormap gray
drawnow

subplot(221)
[~,~,t,p] = spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');
p = 10*log10(p);
p = smooth(sum(p,1),3);
p = p-min(p);
p = p/max(p);
hold on
plot(t*1000,p,'r-' );

function [snd,A] = genmask(vel,dens,md,durrip,Fs,nFreq,Freq,Ftar,Oct,Phi)
protband	= pa_oct2bw(Ftar,[-1/3 1/3]);		%create protected band (1/3 octave above/below Fsig)
sel			= Freq<protband(1) | Freq>protband(2);
Freq		= Freq(sel);
nFreq		= numel(Freq);			%Nfreq - protected band

nTime   = round( (durrip/1000)*Fs ); % # Samples for Rippled Noise
time	= ((1:nTime)-1)/Fs; % Time (sec)

%% Generating the ripple
% Create amplitude modulations completely dynamic without static
T			= 2*pi*vel*time;
F			= 2*pi*dens*Oct;
[T,F]		= meshgrid(T,F);
% A			= 1+md*cos(T+F+pi+pi*rand(size(T)));
A			= 1+md*cos(T+F+pi);
A			= A';

snd		= 0; % 'initialization'
% for ii = 1:nFreq
for ii = [pa_rndval(1,nFreq,[1,10])]
	rip		= A(:,ii)'.*sin(2*pi*Freq(ii) .* time + Phi(ii));
	snd		= snd+rip;
end

rip		= A(:,ii)'.*sin(2*pi*Freq(ii) .* time + Phi(ii));
snd		= snd+rip;

function [snd,A] = gensignal(vel,dens,md,durrip,Fs,nFreq,Freq,Ftar,Oct,Phi)
nTime   = round( (durrip/1000)*Fs ); % # Samples for Rippled Noise
time	= ((1:nTime)-1)/Fs; % Time (sec)

%% Generating the ripple
% Create amplitude modulations completely dynamic without static
T			= 2*pi*vel*time;
F			= 2*pi*dens*Oct;
[T,F]		= meshgrid(T,F);
A			= 1+md*cos(T+F+pi);
A			= A';

[~,indx] = min(abs(Freq-Ftar));%% Modulate carrier
snd		= A(:,indx)'.*sin(2*pi*Freq(indx) .* time + Phi(indx));
