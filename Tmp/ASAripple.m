function ASAripple
tic
close all
clc

%-- Flags --%

%-- Variables --%
Vel1	=	2;			%-- Ripple velocity [Hz]			--%
Dens1	=	2;			%-- Ripple density [cyc/oct]		--%
Mod1	=	1;			%-- Modulation depth (0-1)			--%
Dur1	=	1000;		%-- Duration [msec]					--%

Vel2	=	2;			%-- Ripple velocity [Hz]			--%
Dens2	=	2;		%-- Ripple density [cyc/oct]		--%
Mod2	=	1;			%-- Modulation depth (0-1)			--%
Dur2	=	1000;		%-- Duration [msec]					--%

Delay	=	10;		%-- delay S2 re S1 [msec]			--%
Fs		=	48828.125;	%-- Sampling frequency [Hz]			--%

%-- Main --%
Ndelay	=	round(Delay * 10^-3 * Fs);
Dur2	=	Dur2 - Delay;

Snd1	=	genripple(Vel1,Dens1,Mod1,Dur1,Fs,0,0);
Snd2	=	genripple(Vel2,Dens2,Mod2,Dur2,Fs,0,0);

Snd2	=	[ zeros(1,Ndelay) Snd2 ];

%-- Normalization --%
Snd1	=	.5 * Snd1 / max(abs(Snd1));
Snd2	=	.5 * Snd2 / max(abs(Snd2));

Snd		=	Snd1 + Snd2;
Snd		=	.5 * Snd / max(abs(Snd));

%-- Plotting --%
plotsnd(Snd1,Fs)
plotsnd(Snd2,Fs)
plotsnd(Snd,Fs)

if( isunix )
	sound(Snd1,Fs);
	sound(Snd2,Fs);
	sound(Snd,Fs);
else
% 	wavplay(Snd1,Fs);											%#ok<REMFF1>
% 	wavplay(Snd1,Fs);											%#ok<REMFF1>
	wavplay(Snd2,Fs);											%#ok<REMFF1>
	s = [Snd1; Snd2];
	s = s';
	whos s
% 	keyboard
	wavplay(s,Fs);											%#ok<REMFF1>
	wavplay(s,Fs);											%#ok<REMFF1>
end

%-- Wrapping up --%
tend	=	( round(toc*100)/100 );
str		=	sprintf('\n%s\n',['Mission accomplished after ' num2str(tend) ' sec!']);
disp(str)
% keyboard
%-- Locals --%
function plotsnd(Snd,Fs)

%-- Normalization --%
Snd			=	.999 * Snd / max(abs(Snd));

figure

t		=	(1:length(Snd))/Fs*1000;

subplot(2,2,[1 2])
plot(t,Snd,'k-')
xlim([min(t) max(t)]);
ylim([-1.1 1.1])
set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
ylabel('amplitude [au]');
xlabel('time [ms]');
title('Waveform')

subplot(2,2,3)
Nfft		=	2^9;
Window		=	2^8;	%-- Resolution	--%
Noverlap	=	2^5;	%-- Smoothing	--%
spectrogram(Snd,Window,Noverlap,Nfft,Fs,'yaxis');
cax			=	caxis;
caxis([0.7*cax(1) 1.1*cax(2)])
set(gca,'YTick',[.125 .25 .5 1 2 4 8 16]*1000);
set(gca,'YTickLabel',[.125 .25 .5 1 2 4 8 16]);
set(gca,'YScale','log');
set(gca,'Layer','Top')
set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
xlabel('time [s]')
ylabel('frequency [kHz]')
title('Spectrogram')
box on

subplot(2,2,4)
pa_getpower(Snd,Fs,1,'x');
drawnow

function [f,mx,ph,h] = pa_getpower(x,Fs,disp,orient,col)
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

% Initialization
if( nargin < 2 )
	Fs		=	50000;
end
if( nargin < 3 )
	disp	=	0;
end
if( nargin < 4)
	orient	=	'x'; % Freq = x-axis
else
	disp = 1;
end
if( nargin < 5 )
	col		=	'k';
end

% Time vector of 1 second
% Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
nfft			=	2^(nextpow2(length(x)));
% Take fft, padding with zeros so that length(fftx) is equal to nfft
fftx			=	fft(x,nfft);
% Calculate the numberof unique points
NumUniquePts	=	ceil((nfft+1)/2);
% FFT is symmetric, throw away second half
fftx			=	fftx(1:NumUniquePts);
% Take the magnitude of fft of x and scale the fft so that it is not a function of
% the length of x
mx				=	abs(fftx)/length(x);
ph				=	angle(fftx);

% Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.
% The DC component and Nyquist component, if it exists, are unique and should not
% be mulitplied by 2.
if( rem(nfft, 2) ) % odd nfft excludes Nyquist point
	mx(2:end)		=	mx(2:end)*2;
else
	mx(2:end -1)	=	mx(2:end -1)*2;
end
% This is an evenly spaced frequency vector with NumUniquePts points.
f		=	(0:NumUniquePts-1)*Fs/nfft;

% Take the square of the magnitude of fft of x -> magnitude 2 power
% mx				= mx.^2;
mx		=	20*log10(mx);
sel		=	isinf(mx);
mx(sel)	=	min(mx(~sel));

% Display option
if disp
	if( strcmpi(orient,'x') )
		h = semilogx(f,mx);
		set(h,'Color',col);
		xlim([125 max(f)])
		ylim([min(mx)*1.1 max(mx)*.9])
		set(gca,'XTick',[.125 .25 .5 1 2 3 4 6 8 10 14 20]*1000);
		set(gca,'XTickLabel',[.125 .25 .5 1 2 3 4 6 8 10 14 20]);
		set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
		xlabel('frequency [kHz]');
		ylabel('power [dB]');
	elseif( strcmpi(orient,'y') );
		h = semilogy(mx,f);
		set(h,'Color',col);
		ylim([0 max(f)])
		xlim([min(mx) max(mx)]*1.1)
		set(gca,'YTick',[0.05 1 2 3 4 6 8 10 14]*1000);
		set(gca,'YTickLabel',[0.05 1 2 3 4 6 8 10 14]);
		set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
		ylabel('frequency [kHz]');
		xlabel('power [dB]');
	end
	title('Power Spectrum');
end
