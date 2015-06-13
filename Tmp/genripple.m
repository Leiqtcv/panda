function [Snd,Fs] = genripple(Vel,Dens,Mod,Dur,Fs,PlotFlag,PlayFlag)
% [SND,FS] = GENRIPPLE(VEL,DENS,MOD,DUR,FS,PLOTFLAG,PLAYFLAG)
%
% Generate a ripple stimulus with velocity (amplitude-modulation) VEL (Hz),
% density (frequency-modulation) DENS (cyc/oct), a modulation depth MOD
% (0-1), and a duration DUR (ms) at a sampling frequency of FS (Hz).
%
% Optional parameters:
% PlotFlag	=	Show waveform spectrogram and power spectrum [1,0]
% PlayFlag	=	Play the sound via the sound card [1,0]
%
% These stimuli are parametrized naturalistic, speech-like sounds, whose
% envelope changes in time and frequency. Useful to determine
% spectro-temporal receptive fields (see e.g. Depireux et al., 2001 in J Neurophys).
%
% based on a function written by Marc van Wanrooij
% modified March 2012 by peterbr

% Note to self:
% vel	=	[2:2:10 20:10:160];
% dens	=	-4:.4:4;
% vel		=	[2:2:10 20:10:50];
% vel		=	4:4:60;
% dens	=	-4:.2:4;
% clc
% clear all
% close all
% % vel     =   5:5:60;
% % dens    =   -1:.15:1;
% vel     =   5:10:55;
% dens    =   -1:.16:1;
% 
% vel		=	5:5:60;
% dens	=	-1.5:.15:1.5;
% 
% [X,Y]   =   meshgrid(vel,dens);
% Z       =   [X(:) Y(:)];
% ExpTime =   size(Z,1)/60*2*10
%  
% NW      =   length(vel);
% Whi     =   max(vel);
% Wlo     =   min(vel);
% Wstep   =   (Whi-Wlo)/(NW-1);
% time    =   sort((0:NW*2-1)/(NW*2-1)./Wstep*1000)
% 
% NO      =   length(dens);
% Ohi     =   max(dens);
% Olo     =   min(dens);
% Ostep   =   (Ohi-Olo)/(NO-1);
% freq    =   (1:NO-1)/(NO-1)/Ostep
% (250.*2.^freq)

%--  Initialization --%
if( nargin < 1 )
	Vel		=	10;			%-- Ripple velocity [Hz]			--%
end
if( nargin < 2 )
	Dens	=	0;			%-- Ripple density [cyc/oct]		--%
end
if( nargin < 3 )
	Mod		=	1;			%-- Modulation depth (0-1)			--%
end
if( nargin < 4 )
	Dur		=	1000;		%-- Duration [msec]					--%
end
if( nargin < 5)
	Fs		=	48828.125;	%-- Sampling frequency [Hz]			--%
end
if( nargin < 6 )
	PlotFlag	=	1;		%-- 1: Show plot; 0: No plot		--%
end
if( nargin < 7 )
	PlayFlag	=	1;		%-- 1: Play sound; 0: Don't play	--%
end

%-- Main --%
nTime		=	round( (Dur/1000)*Fs );		%-- # samples		--%
Time		=	( (1:nTime)-1 ) / Fs;		%-- Time axis [sec]	--%

%-- According to Depireux et al. (2001) --%
nFreq		=	128;
FreqNr		=	0:1:nFreq-1;
F0			=	250;
Freq		=	F0 * 2.^(FreqNr/20);
Oct			=	FreqNr/20;					%-- Octaves above F0		--%
Phi			=	pi - 2*pi*rand(1,nFreq);	%-- Random starting	phase	--%
Phi(1)		=	pi/2;						%-- Set first to 0.5*pi		--%

%-- Generating amplitude modulation for the ripple --%
A			=	NaN(nTime,nFreq);
for k=1:nTime
	for l=1:nFreq
		A(k,l)	=	1 + Mod*sin(2*pi*Vel*Time(k) + 2*pi*Dens*Oct(l));
	end
end

%-- Modulate carrier --%
Snd			=	0;
for k=1:nFreq
	Rip		=	A(:,k)'.*sin(2*pi* Freq(k) .* Time + Phi(k));
	Snd		=	Snd + Rip;
end

%-- Apply envelope --%
Nenv	=	round( 5 *10^-3 * Fs );
Snd		=	pa_envelope(Snd',Nenv)';

%-- Plotting --%
if( PlotFlag )
	%-- Normalization --%
	Snd			=	.999 * Snd / max(abs(Snd));
	
	figure
	
	t		=	(1:length(Snd))/Fs*1000;
	Env		=	A(:,1) / 2;
	
	subplot(2,2,[1 2])
	plot(t,Snd,'k-')
	hold on
	plot(t,Env,'r-','LineWidth',2)
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
	ylim([min(Freq) max(Freq)])
	set(gca,'YTick',[.125 .25 .5 1 2 4 8 16 max(Freq)]*1000);
	set(gca,'YTickLabel',[.125 .25 .5 1 2 4 8 16 max(round(Freq))]);
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
end

%-- Play the soudn via the sound card --%
if( PlayFlag == 1 )
	%-- Normalization --%
	Snd			=	.999 * Snd / max(abs(Snd));
	if( isunix )
		sound(Snd,Fs);
	else
		wavplay(Snd,Fs);
	end
end

%-- Locals --%
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
