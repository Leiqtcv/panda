function MakeEEGStim
tic
clear all
close all
clc

%-- Flags --%
FixedFreq	=	0;

%-- Variables --%
% pname		=	'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/LP/All/UCI032/';
% fname		=	'HumBDS0M0F600Prate10Asyn_1.mat';
pname		=	'C:\MATLAB\PandA\Publications\UCI\ParamFiles\';
fname		=	'CF_iC_PB0F4000Prate10Asyn.mat';
CalPath		=	'C:\MATLAB\PandA\Publications\UCI\Calibration\';
% Freqname	=	'/Users/pbremen/Work/Experiments/Irvine/Data/Human/IMEEG/Peter/EEG/iMBSs_Peter_HighThr_Mtx.mat';

SigAmp		=	[-100 10:10:40];
dBRef		=	94;
Fs			=	48828;%/2;

%-- Main --%
load([pname fname])
load([CalPath Cn.ToneGains '.mat']);

sname		=	getsavename(Cn);

%-- Assume that DAC1 and DAC2 have same frequency lists --%
FreqVec		=	DAC1ToneGain(:,1);								%#ok<NODEF>

iSigBand	=	find( FreqVec >= Cn.SigBand(1) & FreqVec <= Cn.SigBand(2) );
if( isempty(iSigBand) )
	% if you don't get one of the calibrated frequencies in SigBand, get the one closest to Cn.SigBand(1) --%
	[~,iSigBand]	=	min( abs(FreqVec - Cn.SigBand(1)) );
end
SigFreq				=	FreqVec(iSigBand);

if( ~FixedFreq )
	[~,MaskGainVec]		=	getgainvec(Cn,DAC1ToneGain,DAC2ToneGain);
	[FreqMat,AmpMat]	=	LoadMaskBuffers(Cn,SigFreq,FreqVec,MaskGainVec);
else
	load(Freqname)
	AmpMat			=	ones(size(FreqMat));
end

myPeriod			=	(1000/Cn.BaseRate) / Cn.NMask;
if( Cn.MaskRand )
	[~,idx]				=	sort( rand(1,Cn.NMask) );
	MaskDelayVec		=	myPeriod*(idx-1);
else
	MaskDelayVec		=	zeros(1,Cn.NMask);
end

M			=	reconmask(Cn,SigFreq,FreqMat,AmpMat,MaskDelayVec,Fs,1);

for k=1:length(SigAmp)
	SigAmps		=	(10^((SigAmp(k)-dBRef)/20)) ./ ones(Cn.NPulse);
	S			=	reconsig(Cn,Cn.SigBand(1),SigAmps,TrlVal(1,1).SigOnsetDelay,Fs,1);
	
	NSig		=	size(S,1);
	NMask		=	size(M,1);
	NDif		=	NMask - NSig;
	Stim		=	[S; zeros(NDif,1)];
	Stim		=	Stim + sum(M,2);
	
% 	maxStim		=	max(Stim);
% 	Stim		=	.999 .* (Stim ./ maxStim);
	
% 	if( SigAmp(k) == -100 )
% 		Norm	=	maxStim;
% 	end

	y			=	downsample(Stim,2) * 1000;
	sound(.999*(y/max(abs(y))),Fs/2);
	
% 	save([sname 'SPL' num2str(SigAmp(k)) 'both.mat'],'y')
	
	ts			=	( ( (0:NSig-1) ) * 1/Fs ) * 10^3;
	tm			=	( ( (0:NMask-1) ) * 1/Fs ) * 10^3;
	
	window		=	round( 10^-2*Fs );
	noverlap	=	round( .5*10^-3*Fs );
	Nfft		=	1024;
	
	figure(3)
	clf
	
	subplot(2,1,1)
	plot(ts,S*1000,'k-')
	hold on
	plot(tm,M*1000)
	xlim([tm(1) tm(end)])
	ylim([-1.1 1.1])
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [msec]')
	ylabel('amplitude [a.u.]')
	title('signal + masker')
	axis('square')
	
	subplot(2,1,2)
	[~,F,T,P] = spectrogram(Stim*1000,window,noverlap,Nfft,Fs);
	T	=	T * 10^3;
	surf(T,F,10*log10(abs(P)+eps),'EdgeColor','none');
	axis tight
	view(0,90);
	hold on
	% plot([T(1) T(end)],[ProtectBand(1) ProtectBand(1)],'r-')
	% plot([T(1) T(end)],[ProtectBand(2) ProtectBand(2)],'r-')
	% plot([T(1) T(end)],[CB1_3(1) CB1_3(1)],'r--')
	% plot([T(1) T(end)],[CB1_3(2) CB1_3(2)],'r--')
	set(gca,'YTick',[62.5 125 250 500 1000 2000 4000 8000 16000 32000],'YTickLabel',[62.5 125 250 500 1000 2000 4000 8000 16000 32000])
	set(gca,'YScale','log')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [ms]')
	ylabel('frequency [Hz]')
	title('signal + masker')
	box on
	axis('square')
	
	colormap('gray')
	keyboard
end

y		=	M;%.999 .* (M ./ Norm);
y		=	downsample(y,2) * 1000;
sound(.999*(y/max(abs(y))),Fs/2);
	
% save([sname 'SPL0Mask.mat'],'y')

% if( SigAmp(k) == 40 )
% 	y			=	downsample(S,2) * 1000;
% 	sound(.999*(y/max(abs(y))),Fs/2);
% 	save([sname 'SPL' num2str(SigAmp(k)) 'Signal.mat'],'y')
% end

%-- Plotting --%


%-- Wrapping up --%
tend		=	( round(toc*100)/100 );
str			=	sprintf('\n%s\n',['Mission accomplished after ' num2str(tend) ' sec!']);
disp(str)

%-- Locals --%
function sname = getsavename(Cn)

if( Cn.Paradigm == 1 )
	Type	=	'iMBD';
elseif( Cn.Paradigm == 2 )
	Type	=	'iMBS';
elseif( Cn.Paradigm == 4 )
	Type	=	'eMBD';
elseif( Cn.Paradigm == 5 )
	Type	=	'eMBS';
end

if( Cn.MaskRand == 1 )
	Time	=	'asyn';
elseif( Cn.MaskRand == 0 )
	Time	=	'syn';
end

sname	=	[Type Time];

function [SigGainVec,MaskGainVec] = getgainvec(Cn,DAC1ToneGain,DAC2ToneGain)

if( Cn.SigLoc == Cn.MaskLoc )   %-- play both on DAC1 --%
	
	SigSpkrIdx	=	find( Cn.DAC1SpkrTable(:,2) == Cn.SigLoc );
	
	if( isempty(SigSpkrIdx) )
		disp(['Can''t find a speaker at ' num2str(Cn.SigLoc) '!']);
		return
	end
	
	SigGainVec	=	DAC1ToneGain(:,SigSpkrIdx+1);
	
	MaskGainVec	=	SigGainVec;
	
else	%-- Mask on DAC1, Sig on 2 --%
	SigSpkrIdx	=	find(Cn.DAC2SpkrTable(:,2)==Cn.SigLoc);
	
	if( isempty(SigSpkrIdx) )
		disp(['Can''t find a speaker at ',num2str(Cn.SigLoc),'!']);
		return
	end
	
	SigGainVec	=	DAC2ToneGain(:,SigSpkrIdx+1);
	
	MaskSpkrIdx	=	find(Cn.DAC1SpkrTable(:,2)==Cn.MaskLoc);
	
	if( isempty(MaskSpkrIdx) )
		disp(['Can''t find a speaker at ',num2str(Cn.MaskLoc),'!']);
		return
	end
	
	MaskGainVec	=	DAC1ToneGain(:,MaskSpkrIdx+1);
end

return

function [FreqMat,AmpMat] = LoadMaskBuffers(Cn,SigFreq,FreqVec,MaskGainVec)

% LoadMaskBuffers: For each interval, fill the frequency and amplitude buffers for the info masker

dBRef	=	94;

Protect	=	SigFreq * 2.^[-Cn.ProtectBand Cn.ProtectBand] + [-100 100];
AmpVec	=	(10^((Cn.MaskSPL-dBRef)/20)) ./ ones(size(MaskGainVec));
AmpVec	=	min(AmpVec, 1.0);								%-- Limit amplitudes to avoid speaker distortion --%

AmpMat	=	zeros(Cn.NPulse,Cn.NMask);
FreqMat	=	1000 * ones(Cn.NPulse,Cn.NMask);

% sel		=	(FreqVec <= Protect(1) | FreqVec >= Protect(2)) & FreqVec < 1500 & FreqVec < 12000;
% FreqVec(sel)
% sum(sel)

for iPulse=1:Cn.NPulse
	if( ismember( Cn.Paradigm,1:2 )  )
		Fbands	=	getfreqband(FreqVec,Cn.NMaskBand);
		idx		=	nan(Cn.NMaskBand,1);
		for iBand=1:Cn.NMaskBand
			if( Cn.Paradigm == 9 || Cn.Paradigm == 10 )
				tmp	=	find(	FreqVec >= Cn.MaskBand(iBand,1) & FreqVec <= Cn.MaskBand(iBand,2) & ...
					(FreqVec >= Protect(1) & FreqVec <= Protect(2)) );
			else
				tmp	=	find(	( FreqVec >= Cn.MaskBand(iBand,1) & FreqVec <= Protect(1) & FreqVec >= Fbands(iBand,1) & FreqVec < Fbands(iBand,2) ) | ...
					( FreqVec >= Protect(2) & FreqVec <= Cn.MaskBand(iBand,2) & FreqVec >= Fbands(iBand,1) & FreqVec < Fbands(iBand,2) ) );
			end
			if( ~isempty(tmp) )
				idx(iBand,1)	=	tmp( randi(length(tmp),1,1) );
			end
		end
	elseif( ismember( Cn.Paradigm,4:5 ) )
		idx	=	[];
		for iBand=1:Cn.NMaskBand
			tmp	=	find(	FreqVec >= Cn.MaskBand(iBand,1) & FreqVec <= Cn.MaskBand(iBand,2) & ...
							(FreqVec >= Protect(1) & FreqVec <= Protect(2)) );
			idx	=	[idx; tmp];									%#ok<AGROW>
		end
	end
	
	idx			=	idx( ~isnan(idx) );
	
	Nuni		=	0;
	while( Nuni ~= Cn.NMask )
		rdx		=	randi(length(idx),Cn.NMask,1);
		Nuni	=	length( unique(rdx) );
	end
	idx			=	sort(idx(rdx));
	
	FreqMat(iPulse,1:Cn.NMask)	=	FreqVec(idx);
	AmpMat(iPulse,1:Cn.NMask)	=	AmpVec(idx);
end

%-- MBS: all pulses have the same frequency --%
if( Cn.Paradigm == 2 || Cn.Paradigm == 5 )
	FreqMat		=	repmat(FreqMat(1,:),Cn.NPulse,1);
	AmpMat		=	repmat(AmpMat(1,:),Cn.NPulse,1);
end

return

function Fbands = getfreqband(FreqVec,Nband)

len			=	length(FreqVec);
inc			=	round( len / Nband );

Bands		=	FreqVec(1:inc:end);

Fbands		=	[ Bands, [Bands(2:end); FreqVec(end)] ];
Fbands(:,3)	=	mean(Fbands,2);

return

function M = reconmask(Cn,SigFreq,FreqMat,AmpMat,MaskDelayVec,Fs,flag)

if( nargin < 7 )
	flag	=	0;
end

T			=	1 / Cn.BaseRate;
Dur			=	Cn.GaussDur * 10^-3;
Sigma		=	Cn.GaussSigma * 10^-3;
NPulse		=	Cn.NPulse;

NPer		=	round( T * Fs );
NSamp		=	round( Dur * Fs ) + 1;
Noct		=	Cn.ProtectBand;
ProtectBand	=	[SigFreq / 2^Noct, SigFreq * 2^Noct]  + [-100 100];
CB1_3		=	[SigFreq / 2^(1/6), SigFreq * 2^(1/6)];

NMaskBand	=	Cn.NMask;
NMaskDelay	=	round( MaskDelayVec*10^-3 * Fs );
NMask		=	NPer*(NPulse+1);

M			=	zeros(NMask,NMaskBand);
start		=	1;
stop		=	start + NSamp - 1;
mtart		=	1;
for k=1:NPulse
	start			=	stop + (NPer - NSamp);
	stop			=	start + NSamp - 1;
	
	for l=1:NMaskBand
		if( NMaskDelay(l) == 0 )
			ttart	=	1;
		else
			ttart	=	NMaskDelay(l);
		end
		ttop		=	ttart + NSamp -1;
		Tmp(ttart:ttop,l)	=	makesine(FreqMat(k,l),AmpMat(k,l),Dur,Sigma,Fs); %#ok<AGROW>
	end
	
	mtop			=	mtart + size(Tmp,1)-1;
	M(mtart:mtop,:)	=	M(mtart:mtop,:) + Tmp;
	mtart			=	start;
end

if( flag )
	M			=	sum(M,2);
% 	M			=	M ./ max(abs(M));
	
	tm			=	( ( (0:NMask-1) ) * 1/Fs ) * 10^3;

	window		=	round( 10^-2*Fs );
	noverlap	=	round( .5*10^-3*Fs );
	Nfft		=	1024;
	
	figure(1)
	clf
	
	subplot(2,1,1)
	plot(tm,M)
	xlim([tm(1) tm(end)])
	ylim([-1.1 1.1])
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [msec]')
	ylabel('amplitude [a.u.]')
	title('masker alone')
	axis('square')
	
	subplot(2,1,2)
	[~,F,T,P] = spectrogram(sum(M,2),window,noverlap,Nfft,Fs);
	T	=	T * 10^3;
	surf(T,F,10*log10(abs(P)+eps),'EdgeColor','none');
	axis tight
	view(0,90);
	hold on
	plot([T(1) T(end)],[ProtectBand(1) ProtectBand(1)],'r-')
	plot([T(1) T(end)],[ProtectBand(2) ProtectBand(2)],'r-')
	plot([T(1) T(end)],[CB1_3(1) CB1_3(1)],'r--')
	plot([T(1) T(end)],[CB1_3(2) CB1_3(2)],'r--')
	set(gca,'YTick',[62.5 125 250 500 1000 2000 4000 8000 16000 32000],'YTickLabel',[62.5 125 250 500 1000 2000 4000 8000 16000 32000])
	set(gca,'YScale','log')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [ms]')
	ylabel('frequency [Hz]')
	title('masker alone')
	box on
	axis('square')
	
	colormap('gray')
end

function S = reconsig(Cn,SigFreq,SigAmp,SigDelay,Fs,flag)

if( nargin < 6 )
	flag	=	0;
end

T			=	1 / Cn.BaseRate;
Dur			=	Cn.GaussDur * 10^-3;
Sigma		=	Cn.GaussSigma * 10^-3;
NPulse		=	Cn.NPulse;

NPer		=	round( T * Fs );
NSigDelay	=	round( SigDelay*10^-3 * Fs );
NSamp		=	round( Dur * Fs ) + 1;
NSig		=	NPer*NPulse + NSigDelay;
Noct		=	Cn.ProtectBand;
ProtectBand	=	[SigFreq / 2^Noct, SigFreq * 2^Noct]  + [-100 100];
CB1_3		=	[SigFreq / 2^(1/6), SigFreq * 2^(1/6)];

S			=	zeros(NSig,1);
start		=	NSigDelay + 1;
stop		=	start + NSamp - 1;
for k=1:NPulse
	S(start:stop,1)	=	makesine(SigFreq,SigAmp(k),Dur,Sigma,Fs);
	start			=	stop + (NPer - NSamp);
	stop			=	start + NSamp - 1;
end

if( flag )
% 	S			=	S ./ max(abs(S));
	ts			=	( ( (0:NSig-1) ) * 1/Fs ) * 10^3;

	window		=	round( 10^-2*Fs );
	noverlap	=	round( .5*10^-3*Fs );
	Nfft		=	1024;
	
	figure(2)
	clf
	
	subplot(2,1,1)
	plot(ts,S,'k-')
	xlim([ts(1) ts(end)])
	ylim([-1.1 1.1])
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [msec]')
	ylabel('amplitude [a.u.]')
	title('signal alone')
	axis('square')
	
	subplot(2,1,2)
	[~,F,T,P] = spectrogram(S,window,noverlap,Nfft,Fs);
	T	=	T * 10^3;
	surf(T,F,10*log10(abs(P)+eps),'EdgeColor','none');
	axis tight
	view(0,90);
	hold on
	plot([T(1) T(end)],[ProtectBand(1) ProtectBand(1)],'r-')
	plot([T(1) T(end)],[ProtectBand(2) ProtectBand(2)],'r-')
	plot([T(1) T(end)],[CB1_3(1) CB1_3(1)],'r--')
	plot([T(1) T(end)],[CB1_3(2) CB1_3(2)],'r--')
	set(gca,'YTick',[62.5 125 250 500 1000 2000 4000 8000 16000 32000],'YTickLabel',[62.5 125 250 500 1000 2000 4000 8000 16000 32000])
	set(gca,'YScale','log')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [ms]')
	ylabel('frequency [Hz]')
	title('signal alone')
	box on
	axis('square')
	
	colormap('gray')
end

function [s,x] = makesine(F,G,D,ramp,Fs)

len		=	length(F);

Ndur	=	round( D * Fs );
Nenv	=	round( ramp * Fs );

x		=	0:1/Fs:D;
s		=	nan(len,Ndur+1);
for k=1:len
	s(k,:)	=	G .* sin(2*pi*F(k)*x);
	s(k,:)	=	applyramp(s(k,:),Ndur,Nenv);
end

function out = applyramp(in,N,Ns,flag)

if( nargin < 4 )
	flag	=	0;
end

len		=	length(in)-1;

x		=	(0:N) / len;
Ns		=	Ns / len;
m		=	x(end) / 2;

g		=	exp( -( (x-m) ./ Ns ).^2 );
out		=	g .* in;

if( flag )
	figure(1)
	clf
	
	subplot(2,1,1)
	plot(x,g,'k-')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('normalized time')
	ylabel('normalized amplitude')
	title('Gaussian filter')
	
	subplot(2,1,2)
	plot(x,out,'k-')
	hold on
	plot(x,in,'r--')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('normalized time')
	ylabel('normalized amplitude')
	title('original filter (red) & filtered signal (black)')
end

%-- Junk --%
%{

%--				Sig0NoMask Sig80NoMask Sig80Mask-80 Sig80Mask80 Sig0Mask80 Sig0Mask0	 --%
D4k_1		=	[ -30 -30 -30 -20 -10 5 ];
D4k_2		=	[ -30 -36 -29 -8 -22 -24 ];
D1_2k		=	[ -23 -28 -25 -23 -15 -17 ];
D0_5k		=	[ -12 -23 -14 -13 -15 -12 ];

D			=	[ D4k_1 D4k_2 D1_2k D0_5k ];
y			=	[min(D)-5 max(D)+5];
x			=	1:length(D4k_1);

function s = makesine(F,D,ramp,Fs)

len		=	length(F);

Ndur	=	round( D * Fs );
Nenv	=	round( ramp * Fs );

x		=	0:1/Fs:D;
s		=	nan(len,Ndur+1);
for k=1:len
	s(k,:)	=	sin(2*pi*F(k)*x);
	s(k,:)	=	applyramp(s(k,:),Ndur,Nenv);
end

function out = applyramp(in,N,Ns,flag)

if( nargin < 4 )
	flag	=	0;
end

len		=	length(in)-1;

x		=	(0:N) / len;
Ns		=	Ns / len;
m		=	x(end) / 2;

g		=	exp( -( (x-m) ./ Ns ).^2 );
out		=	g .* in;

if( flag )
	figure(1)
	clf
	
	subplot(2,1,1)
	plot(x,g,'k-')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('normalized time')
	ylabel('normalized amplitude')
	title('Gaussian filter')
	
	subplot(2,1,2)
	plot(x,out,'k-')
	hold on
	plot(x,in,'r--')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('normalized time')
	ylabel('normalized amplitude')
	title('original filter (red) & filtered signal (black)')
end

%}