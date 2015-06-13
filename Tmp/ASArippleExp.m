function ASArippleExp

tic
close all
clc

%-- Flags --%

%-- Variables --%
% Pname	=	'/Users/pbremen/Work/Experiments/Irvine/Data/Human/ASAripple/';
% Subj	=	'Peter_Pilot2';

Vel1	=	10;			%-- Ripple velocity [Hz]			--%
Dens1	=	0;			%-- Ripple density [cyc/oct]		--%
Mod1	=	.5;			%-- Modulation depth (0-1)			--%
Dur1	=	1000;		%-- Duration [msec]					--%

Vel2	=	0:5:20;		%-- Ripple velocity [Hz]			--%
Dens2	=	-4:1:4;		%-- Ripple density [cyc/oct]		--%
Mod2	=	0:.5:1;		%-- Modulation depth (0-1)			--%
Dur2	=	1000;		%-- Duration [msec]					--%

Delay	=	0;			%-- Delay S2 re S1 [msec]			--%
Amp		=	.4;			%-- AMplitude [0 1]					--%
Nrep	=	10;			%-- Number of repetitions			--%

Fs		=	48828.125;	%-- Sampling frequency [Hz]			--%

%-- Main --%
Ndelay	=	round(Delay * 10^-3 * Fs);
Dur2	=	Dur2 - Delay;

%-- Setup the trial matrix --%
StmMtx	=	makemtx(Vel2,Dens2,Mod2,Vel1,Dens1,Mod1,Nrep);
Ntrl	=	length(StmMtx);

D		=	nan(Ntrl,13);

%-- Paint the GUI and wait for button press before starting --%
hGui	=	makegui(Ntrl);

if waitforbuttonpress == 0
    disp('%-------------------------------------------------%')
	disp('%--		Starting experiment		--%')
	disp('%-------------------------------------------------%')
end

%-- Work through the trial list --%
k	=	1;
while k < Ntrl+1
	set(gcf,'Name',[num2str(k) '/' num2str(Ntrl) ' trials'])
	
	Snd1	=	genripple(Vel1,Dens1,Mod1,Dur1,Fs,0,0);
	Snd2	=	genripple(StmMtx(k,1),StmMtx(k,2),StmMtx(k,3),Dur2,Fs,0,0);
	
	Snd2	=	[ zeros(1,Ndelay) Snd2 ];						%#ok<AGROW>
	
	%-- Normalization --%
	Snd1	=	Amp * Snd1 / max(abs(Snd1));
	Snd2	=	Amp * Snd2 / max(abs(Snd2));
	
	if( StmMtx(k,4) == 1 )
		Snd	=	Snd2 + Snd2;
	else
		Snd	=	Snd1 + Snd2;
	end
	Snd		=	Amp * Snd / max(abs(Snd));
	
	set(hGui(1),'Str','please listen to the sound...')
	
	if( isunix )
		sound(Snd1,Fs);
		sound(Snd,Fs);
	else
		wavplay(Snd1,Fs);										%#ok<REMFF1>
		wavplay(Snd,Fs);										%#ok<REMFF1>
	end
	
	set(hGui(1),'Str','please press a button...')
	
	if waitforbuttonpress == 0
		disp('waiting')
	end
	
	h	=	getguiobj(hGui,'Pause');
	pause(.5)	%-- This delay is needed otherwise the state is not updated --%
	
	if( get(h,'Value') == 0 )
		set(hGui(1),'Str','press start to resume')
		waitfor(h,'Value',1)
	else
		pause(.1)
		h	=	getguiobj(hGui,'No');
		Str	=	get(h,'Tag');
		if( strcmpi(Str,'pressed') )
			Resp	=	1;	%-- No --%
		else
			Resp	=	0;	%-- Yes --%
		end
		set(h,'Tag','xxxxxxx')
		
		D(k,:)	=	[Resp StmMtx(k,4) StmMtx(k,1) StmMtx(k,2) StmMtx(k,3) Vel1 Dens1 Mod1 Delay Amp Dur1 Fs k];
		k		=	k + 1;
	end
end

set(hGui(1),'Str','Congratulations! You did it!')
set(getguiobj(hGui,'Pause'),'Visible','off')
set(getguiobj(hGui,'Yes'),'Visible','off')
set(getguiobj(hGui,'No'),'Visible','off')

save([Pname Subj '.mat'],'D')

%-- Wrapping up --%
tend	=	( round(toc*100)/100 );
str		=	sprintf('\n%s\n',['Mission accomplished after ' num2str(tend) ' sec!']);
disp(str)

%-- Locals --%
function Mtx = makemtx(Vel,Dens,Mod,cVel,cDens,cMod,Nrep)

[X,Y,Z]	=	meshgrid(Vel,Dens,Mod);
X		=	X(:);
Y		=	Y(:);
Z		=	Z(:);

Mtx		=	[X,Y,Z];

%-- Add catch trial --%
sel		=	cVel == Mtx(:,1) & cDens == Mtx(:,2) & cMod == Mtx(:,3);	%-- Make sure that you don't select Snd1 = Snd2 --%
M		=	Mtx(~sel,:);
C		=	[ M(randperm(sum(~sel),sum(sel)),:) ones(sum(sel),1)];

M		=	[Mtx zeros(size(Mtx,1),1)];

Mtx		=	[M; C];
Mtx		=	repmat(Mtx,Nrep,1);
len		=	length(Mtx);
idx		=	randperm(len);
Mtx		=	Mtx(idx,:);

function h = makegui(Ntrl)

f	=	figure(1);
% set(f,'Units','normalized','Position',[0 1 1 1])
clf
set(f,'MenuBar','none','Name',['1/' num2str(Ntrl) ' trials'],'NumberTitle','off')

h(1) = uicontrol( f,'Style','text',...
                'String','press start to begin', ...
				'Units','normalized','Position',[.45 .9 .1 .05], ...
				'FontName','Arial','FontWeight','bold','FontSize',14);

h(2) = uicontrol(	f,'Style','togglebutton','String','Start','BackgroundColor','g',...
				'Units','normalized','Position',[.2 .9 .1 .05], ...
				'FontName','Arial','FontWeight','bold','FontSize',14, ...
				'Callback',{@startbutton} );

h(3) = uicontrol(	f,'Style','pushbutton','String','Yes',...
				'Units','normalized','Position',[.45 .7 .1 .05], ...
				'FontName','Arial','FontWeight','bold','FontSize',14, ...
				'Callback',{@yesbutton} );
		
h(4) = uicontrol(	f,'Style','pushbutton','String','No',...
				'Units','normalized','Position',[.45 .6 .1 .05], ...
				'FontName','Arial','FontWeight','bold','FontSize',14, ...
				'Callback',{@nobutton} );

drawnow

function h = getguiobj(hGui,str)

len	=	length(hGui);
for k=1:len
	if( strcmp( get(hGui(k),'String'),str ) )
		h	=	hGui(k);
	end
end

function startbutton(source,~)

if( get(source,'Val') == 0 )
	set(source,'String','Start')
elseif( get(source,'Val') == 1 )
	set(source,'String','Pause')
end

function yesbutton(source,~)

set(source,'Tag','pressed')
disp('reference present')

function nobutton(source,~)

set(source,'Tag','pressed')
disp('reference not present')

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
		wavplay(Snd,Fs);										%#ok<REMFF1>
	end
end

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
