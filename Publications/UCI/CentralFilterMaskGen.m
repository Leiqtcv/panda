function CentralFilterMaskGen
% function [M,S] = CentralFilterMaskGen

tic
close all
clc

Pname		=	'C:\MATLAB\PandA\Publications\UCI\ParamFiles\';
Type		=	'iC';
PB			=	1; % 0:1/3:2;
Nrep		=	1;
Fs			=	48828;
dBRef		=	94; % dB SPL

Cn.NPulse		=	4;
Cn.BaseRate		=	10;
Cn.NMaskLow		=	2;
Cn.NMaskHigh	=	2;
Cn.ProtectBand	=	PB;
Cn.MaskSPL		=	45;
Cn.MaskRand		=	0; % 1: Tasyn; 0: Tsyn --%
Cn.MaskRng		=	1; % octave
Cn.Paradigm		=	2; %-- 1: FR; 2: FC --%
Cn.GaussDur		=	50;
Cn.GaussSigma	=	6.25;

len			=	length(PB);
for k = 1:len
	FreqVec		=	genfreqvec(200,14370,1/6)';
	MaskGainVec	=	ones(length(FreqVec),1);
	SigFreq		=	1600; % Cn.SigBand(1);
	
	Freq		=	createmasker(Cn,SigFreq,FreqVec,MaskGainVec);
	
	NMask			=	Cn.NMaskLow + Cn.NMaskHigh;
	myPeriod		=	(1000/Cn.BaseRate) / NMask;
	if( Cn.MaskRand )
		[~,idx]				=	sort( rand(1,NMask) );
		MaskDelayVec		=	myPeriod*(idx-1);
	else
		MaskDelayVec		=	zeros(1,NMask);
	end
	
	FreqMat		= squeeze(Freq);
	AmpMat		= ones(size(FreqMat));
	M			= reconmask(Cn,SigFreq,FreqMat,AmpMat,MaskDelayVec,Fs,1);
	
	SigAmps		= (10^((60-dBRef)/20)) ./ ones(Cn.NPulse);
	SigAmps		= ones(size(SigAmps));
	S			= reconsig(Cn,SigFreq,SigAmps,0,Fs,1);
end

M = M(1:length(S));
S = pa_appendn(S,length(M)-length(S));
figure
subplot(211)
plot(M);

subplot(212)
plot(S);

whos M S
return
%% Local functions
function F = genfreqvec(Fmin,Fmax,Fstep)

if( nargin < 1 )
	Fmin	=	200;
end
if( nargin < 2 )
	Fmax	=	14370;
end
if( nargin < 3 )
	Fstep	=	1/6;
end

F	=	Fmin * 2.^(0:Fstep:log2(Fmax/Fmin));

function [FreqMat,AmpMat] = createmasker(Cn,SigFreq,FreqVec,MaskGainVec)

% LoadMaskBuffers: For each interval, fill the frequency and amplitude buffers for the info masker

dBRef	=	94;

NMask	=	Cn.NMaskLow + Cn.NMaskHigh;

Protect	=	SigFreq * 2.^[-Cn.ProtectBand Cn.ProtectBand];
AmpVec	=	(10^((Cn.MaskSPL-dBRef)/20)) ./ MaskGainVec;
AmpVec	=	min(AmpVec, 1.0);								%-- Limit amplitudes to avoid speaker distortion --%

AmpMat	=	zeros(Cn.NPulse,NMask);
FreqMat	=	1000 * ones(Cn.NPulse,NMask);

for iPulse=1:Cn.NPulse
	Fbands		=	getfreqband(FreqVec,Protect,Cn.MaskRng);
	
	low			=	find( FreqVec > Fbands(1) & FreqVec < Protect(1) );
	high		=	find( FreqVec < Fbands(2) & FreqVec > Protect(2) );
	
	Nuni		=	0;
	while( Nuni ~= Cn.NMaskLow )
		if( length(high) == 1 )
			ldx		=	randi(length(low),Cn.NMaskLow+Cn.NMaskHigh-1,1);
		else
			ldx		=	randi(length(low),Cn.NMaskLow,1);
		end
		Nuni	=	length( unique(ldx) );
	end
	LowFreq		=	FreqVec(low(ldx))';
	LowAmp		=	AmpVec(low(ldx))';
	
	if( length(high) > 1 )
		Nuni		=	0;
		while( Nuni ~= Cn.NMaskHigh )
			hdx		=	randi(length(high),Cn.NMaskHigh,1);
			Nuni	=	length( unique(hdx) );
		end
	else
		hdx		=	1;
	end
	HighFreq	=	FreqVec(high(hdx))';
	HighAmp		=	AmpVec(high(hdx))';
	
	FreqMat(iPulse,1:NMask)	=	[LowFreq HighFreq];
	AmpMat(iPulse,1:NMask)	=	[LowAmp HighAmp];
end

%-- C: all pulses have the same frequency --%
if( Cn.Paradigm == 2 )
	FreqMat		=	repmat(FreqMat(1,:),Cn.NPulse,1);
	AmpMat		=	repmat(AmpMat(1,:),Cn.NPulse,1);
end

function Fbands = getfreqband(FreqVec,Protect,MaskRng)

Mrng(1)		=	Protect(1) * 2.^-MaskRng;
Mrng(2)		=	Protect(2) * 2.^+MaskRng;

sel			=	FreqVec >= Mrng(1) & FreqVec <= Mrng(2);
Bands		=	FreqVec(sel);
Fbands		=	[Bands(1) Bands(end)];

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

NMaskBand	=	Cn.NMaskLow + Cn.NMaskHigh;
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
