function tmp


close all hidden
clear all hidden
nFreq	= 128;
FreqNr	= 0:1:nFreq-1;
F0		= pa_oct2bw(250,0);
df		= 1/20;
Freq	= F0 * 2.^(FreqNr*df);
Freq	= log2(Freq./250);

udens = 0.5:0.02:8;
bw = 02;
ndens = numel(udens);
rf = round(Freq/bw);
uf = unique(rf);
nf = numel(uf);
A = NaN(nf,ndens);

for jj = 1:ndens
	dens = udens(jj);
	y = 0.5*sin(2*pi*dens*Freq);
	subplot(121)
	plot(Freq,y);
	
	
	for ii = 1:nf
		sel = rf==uf(ii);
		A(ii,jj) = mean(y(sel));
	end
end
subplot(222)
plot(A,'-')

subplot(223)
plot(udens,-smooth(mean(abs(A))),'k-','MarkerFaceColor','w');
pa_verline((0.5:0.5:3)/bw);
return
vel = 4;
dens = 0.5;
[snd,fs] = pa_genripple(vel,0,100,1000,0);
t = (0:length(snd)-1)./fs;
subplot(224)
plot(t,snd,'k-','Color',[.8 .8 .8])

X = hilbert(snd);
X = 2*smooth(abs(X),1000);
hold on
plot(t,X,'k-','LineWidth',2);
axis square;
%%
[snd,fs] = pa_genripple(0,dens,100,1000,0);
subplot(221)
% plot(snd,'k-')
Fs		= 48828.125; % Freq (Hz)

[f,X] = pa_getpower(snd,Fs);
hold on
nFreq	= 128;
FreqNr	= 0:1:nFreq-1;
F0		= pa_oct2bw(250,0);
df		= 1/20;
Freq	= F0 * 2.^(FreqNr*df);
A		= interp1(f,X,Freq,'spline');
Freq	= log2(Freq./250);
f	= log2(f./250);

plot(-X,f,'k-','Color',[.8 .8 .8]);
hold on
plot(-A,Freq,'k-','LineWidth',2);
axis square;
ylim([0 6]);

Fs		= 48828.125; % Freq (Hz)

[snd,fs,A] = pa_genripple(vel,dens,100,1000,0);

subplot(222)
y = (0:size(A,1)-1)./fs;
x = 0:size(A,2)-1;
x = x/20;
imagesc(y,x,A')
colormap bone
set(gca,'YDir','normal');
axis square;
ylim([0 6]);

subplot(224)
plot(y,A(:,1)/max(A(:,1))*44/55,'k-','LineWidth',2,'Color',[.4 .4 .4]);

subplot(221)
plot(-A(1,:)/max(A(1,:))*(44/55)/21.333,x,'k-','LineWidth',2,'Color',[.4 .4 .4]);

subplot(222)
nsamples	= length(snd);
t			= nsamples/Fs*1000;
dt			= 25;
nseg		= t/dt;
segsamples	= round(nsamples/nseg); % 12.5 ms * 50 kHz = 625 samples
noverlap	= round(0.7*segsamples); % 1/3 overlap
window		= segsamples+noverlap; % window size
nfft		= 10000;
spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');
% spectrogram(snd)
% colorbar
cax = caxis;
ylim([250 16000])
caxis([0.7*cax(1) 1.1*cax(2)])
set(gca,'YTick',[0.5 1 2 4 8 16]*1000);
set(gca,'YTickLabel',[0.5 1 2 4 8 16]);
set(gca,'YScale','log');
colormap gray
axis square
drawnow
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