function ripplespectogramvocd


close all hidden
clear all hidden

vel		= 4;
dens	= 0.5;
dur = 500;
simflag = 0;
%% Velocity
[snd,fs] = pa_genripple(vel,0,100,1000,dur);
switch simflag
	case 0
	case 1
snd = pa_runCISim(snd,round(fs));
	case 2
		sndRs          = interp(snd, 8); % because resampling is only possible with integers
[xOut]         = HAtemporalsmearing(sndRs, 48828.125*8);
xOut           = resample(xOut, 1, 8); % back to 48828.125 Hz
sndSim         = HAsimulation(xOut, snd, 48828.125, 1); % filter high frequencies
snd         = sndSim * rms(snd) / rms(sndSim);

end
t = (0:length(snd)-1)./fs;
subplot(224)
plot(t,snd,'k-','Color',[.8 .8 .8])

X = hilbert(snd);
X = 2*smooth(abs(X),1000);
hold on
plot(t,X,'k-','LineWidth',2);
axis square;

%% Density
[snd,fs] = pa_genripple(0,dens,100,1000,dur);
switch simflag
	case 0
	case 1
snd = pa_runCISim(snd,round(fs));
	case 2
		sndRs          = interp(snd, 8); % because resampling is only possible with integers
[xOut]         = HAtemporalsmearing(sndRs, 48828.125*8);
xOut           = resample(xOut, 1, 8); % back to 48828.125 Hz
sndSim         = HAsimulation(xOut, snd, 48828.125, 1); % filter high frequencies
snd         = sndSim * rms(snd) / rms(sndSim);
end
subplot(221)
% plot(snd,'k-')
	Fs		= 48828.125; % Freq (Hz)

[f,X]	= pa_getpower(snd,Fs);
hold on
nFreq	= 128;
FreqNr	= 0:1:nFreq-1;
F0		= pa_oct2bw(250,0);
df		= 1/20;
Freq	= F0 * 2.^(FreqNr*df);
A		= interp1(f,X,Freq,'spline');
Freq	= log2(Freq./250);
f		= log2(f./250);

plot(-X,f,'k-','Color',[.8 .8 .8]);
hold on
plot(-A,Freq,'k-','LineWidth',2);
axis square;
ylim([0 6]);

%% Velocity & Density
Fs		= 48828.125; % Freq (Hz)
[snd,fs,A] = pa_genripple(vel,dens,100,1000,dur);
switch simflag
	case 0
	case 1
snd = pa_runCISim(snd,round(fs));
	case 2
		sndRs          = interp(snd, 8); % because resampling is only possible with integers
[xOut]         = HAtemporalsmearing(sndRs, 48828.125*8);
xOut           = resample(xOut, 1, 8); % back to 48828.125 Hz
sndSim         = HAsimulation(xOut, snd, 48828.125, 1); % filter high frequencies
snd         = sndSim * rms(snd) / rms(sndSim);
end

subplot(222)
hold on
nsamples	= length(snd);
t			= nsamples/Fs*1000;
dt			= 12.5;
nseg		= t/dt;
segsamples	= round(nsamples/nseg); % 12.5 ms * 50 kHz = 625 samples
noverlap	= round(0.7*segsamples); % 1/3 overlap
window		= segsamples+noverlap; % window size
nfft		= 1024;
[~,f,t,p] = spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');
p = 1000*abs(p);
for ii = 1:size(p,1);
	p(ii,:) = smooth(p(ii,:),5);
end
for ii = 1:size(p,2);
	p(:,ii) = smooth(p(:,ii),5);
end
hold on
surf(t,f,p,'EdgeColor','none');
axis xy; axis tight; view(0,90);
% x = 1:numel(t);
% y = 1:numel(f);
% imagesc(t,f,p')
caxis([0 0.01])
% colorbar
cax = caxis;
ylim([250 pa_oct2bw(250,6)])
caxis([0.7*cax(1) 1.1*cax(2)])
% set(gca,'YTick',[0.5 1 2 4 8 16]*1000);
% set(gca,'YTickLabel',[0.5 1 2 4 8 16]);
set(gca,'YScale','log','Ydir','normal');
colormap gray
axis square
drawnow

pa_datadir;
print('-depsc','-painter',mfilename);
return
figure

subplot(222)
y = (0:size(A,1)-1)./fs;
x = 0:size(A,2)-1;
x = x/20;
imagesc(y,x,A')
colormap bone
set(gca,'YDir','normal');
axis square;
ylim([0 6]);
axis square;

subplot(224)
plot(y,A(:,1)/max(A(:,1))*44/55,'k-','LineWidth',2,'Color',[.4 .4 .4]);
axis square;

subplot(221)
plot(-A(1,:)/max(A(1,:))*(44/55)/21.333,x,'k-','LineWidth',2,'Color',[.4 .4 .4]);
axis square;
ylim([0 6]);

function [f,mx,ph,h]=pa_getpower(x,Fs,varargin)
% [F,A,PH] = PA_GETPOWER(X,FS)
%
% Get power A and phase PH spectrum of signal X, sampled at FS Hz.
%
% PA_GETPOWER(...,'PARAM1',val1,'PARAM2',val2) specifies optional
% name/value pairs. Parameters are:
%	'display'	- display graph. Choices are:
%					0	- no graph (default)
%					>0	- graph
%	'color'	- specify colour of graph. Colour choices are the same as for
%	PLOT (default: k - black).


% 2011  Modified from Mathworks Support:
% http://www.mathworks.com/support/tech-notes/1700/1702.html
% by: Marc van Wanrooij

%% Initialization
if nargin<2
	Fs = 50000;
end
% Optional display arguments
disp         = pa_keyval('display',varargin);
if isempty(disp)
	disp	= 0;
end
orient         = pa_keyval('orientation',varargin);
if isempty(orient)
	orient	= 'x'; % Freq = x-axis
else
	disp = 1;
end
col         = pa_keyval('color',varargin);
if isempty(col)
	col = 'k';
end

%%
% Time vector of 1 second
% Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
nfft = pa_keyval('nfft',varargin);
if isempty(nfft)
	nfft			= 2^(nextpow2(length(x)));
end
% Take fft, padding with zeros so that length(fftx) is equal to nfft
fftx			= fft(x,nfft);
% Calculate the numberof unique points
NumUniquePts	= ceil((nfft+1)/2);
% FFT is symmetric, throw away second half
fftx			= fftx(1:NumUniquePts);
% Take the magnitude of fft of x and scale the fft so that it is not a function of
% the length of x
mx				= abs(fftx)/length(x);
ph				= angle(fftx);

% Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.
% The DC component and Nyquist component, if it exists, are unique and should not
% be mulitplied by 2.
if rem(nfft, 2) % odd nfft excludes Nyquist point
	mx(2:end)	= mx(2:end)*2;
else
	mx(2:end -1) = mx(2:end -1)*2;
end
% This is an evenly spaced frequency vector with NumUniquePts points.
f		= (0:NumUniquePts-1)*Fs/nfft;

% Take the square of the magnitude of fft of x -> magnitude 2 power
% mx				= mx.^2;
% mx		= 20*log10(mx);
sel		= isinf(mx);
mx(sel) = min(mx(~sel));

%% Display option
if disp
	if strcmpi(orient,'x')
		h = semilogx(f,mx);
		set(h,'Color',[.7 .7 .7]);
		hold on
		
		h = semilogx(f,smooth(mx,100));
		set(h,'Color',col);
		set(gca,'XTick',[0.05 1 2 3 4 6 8 10 14]*1000);
		set(gca,'XTickLabel',[0.05 1 2 3 4 6 8 10 14]);
		title('Power Spectrum');
		xlabel('Frequency (kHz)');
		ylabel('Power (dB)');
	elseif strcmpi(orient,'y');
		h = semilogy(mx,f);
		set(h,'Color',col);
		set(gca,'YTick',[0.05 1 2 3 4 6 8 10 14]*1000);
		set(gca,'YTickLabel',[0.05 1 2 3 4 6 8 10 14]);
		title('Power Spectrum');
		ylabel('Frequency (kHz)');
		xlabel('Power (dB)');
		% 	axis square;
	end
	
end