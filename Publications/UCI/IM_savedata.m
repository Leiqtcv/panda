function IM_savedata
% This function analyses the data collected from iMBD/iMBS or fix/random
% conditions (script name....)

%Data that is loaded contains:
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19  20		21			--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct AvgDist UpLow   ];	--%
% 1: Threshold
% 2: Signal Frequency kHz
% 3: Signal location (degrees)
% 4: Masker location (degrees)
% 5: Masker intensity (dB SPL)
% 6: Block number
% 7: Asynchronous = 0 / Synchronous = 1
% 8: iMBS(C) = 0 / iMBD(R) = 1
% 9: Number of masker
% 10: Basal Rate (usually 10 Hz)
% 11: Protected Band
% 12:
% 13:
% 14:
% 15: Signal intensity (dB SPL)
% 16: Subject
% 17: Fix = 0 / Rnd = 1
% 18: SDM
% 19: Protected Band (octaves)
% 20: Average Distance of Masker to Signal Frequency
% 21: UpperLowermasker (0 = only lower, 1 = only upper, 99 = both)

%if CheckmaskerFreq || ThrVsCOG == 1
% 22/37: Maskerfrequencies (1/4 = first pulse, 5/8 = second puls, 9/12 =
% third puls, 13/16 = fourth pulse)

tic
clear all
close all
clc

%% Flags

CheckMaskerFreq	=	false;   %Plot the Masker Frequencies, only for fixed conditions!
ThrVsCOG		=	false;	 %Plot the threshold vs. the masker's center of gravity

p = 'E:\DATA\Irvine\';
pname		=	[	...
	{[p 'Rnd\UCImd\']}; ...
	{[p 'Fix\UCImd\']}; ...
	{[p 'Rnd\UCI060\']}; ...
	{[p 'Fix\UCI060\']}; ...
	{[p 'Rnd\UCI059\']}; ...
	{[p 'Fix\UCI059\']}; ...
	{[p 'Rnd\UCI058\']}; ...
	{[p 'Fix\UCI058\']}; ...
	{[p 'Rnd\UCI057\']}; ...
	{[p 'Fix\UCI057\']}; ...
	{[p 'Rnd\UCI037\']}; ...
	{[p 'Fix\UCI037\']}; ...
	{[p 'Rnd\UCI033\']};...
	{[p 'Fix\UCI033\']};...
	];

%% Load data

[D,T]		=	loaddat(pname,CheckMaskerFreq, ThrVsCOG);
tic
D			=	corrctrlindivsub(D,1);  % Correct for control condition (individual subjects)
pa_datadir;
tic
disp('------- Saving IM data --------');
save Drempel D
disp('------- Finished saving IM data --------');
toc

tic
disp('------- Saving tracking data --------');
save Track T
disp('------- Finished saving tracking data --------');
toc

function [D,T] = loaddat(pname,CheckMaskerFreq,ThrVsCOG,Check)

if( nargin < 4 )
	Check	=	0;
end

T			=	struct([]);
Store		=	zeros(1,6);
len			=	length(pname);
cnt			=	1;
D			= NaN(len,21);
for k=1:len
	tic
	Pname	=	cell2mat(pname(k,1));
	name	=	dir([ Pname '*.mat' ]);
	
	idx		=	strfind(Pname,'\');
	
	if strcmpi(Pname(idx(end-4):idx(end-3)),'\UpLowMask\')
		UpperLower = 1;
	else
		UpLow = 99;
		UpperLower = 0;
	end
	
	Subject	=	getsubj(Pname);
	Ndat	=	length(name);
	for l=1:Ndat
		N		=	name(l,1).name;
		load([Pname N])
		
		idx1	=	strfind(N,'_')+1;
		idx2	=	strfind(N,'.')-1;
		NBlock	=	str2double( N(idx1(end):idx2(end)) );
		
		%-- Check file name congruency --%
		if( Check )
			if( ~strcmpi(N(1:idx1-2),Cn.ParamFile) )
				disp(['S' num2str(Subject) ' File ' num2str(l) ' Block ' num2str(NBlock) ' ' N(1:idx1-2) '   ' Cn.ParamFile ])
				in	=	input('Files do not match. Continue (1) or Quit (0): ');
				if( ~in )
					error('Parameter file name and executed parameter file are different!')
				end
			end
		end
		
		Thr		=	Threshold;
		Sfreq	=	Cn.SigBand;
		Sloc	=	Cn.SigLoc;
		Mloc	=	abs( Cn.MaskLoc );
		Mspl	=	Cn.MaskSPL;
		Sspl	=	Cn.SigSPLStart;
		
		Timing	=	N(idx1(end)-4);
		if( strcmp(Timing,'s') )
			Timing		=	0;
		elseif( strcmp(Timing,'S') )
			Timing		=	1;
		end
		
		%% Warning: only for fixed conditions!!!
		MaskFreqHz	=	[TrlVal(1).MaskFreq1(1,:) TrlVal(1).MaskFreq1(2,:) TrlVal(1).MaskFreq1(3,:) TrlVal(1).MaskFreq1(4,:)];
		MaskFreq	=	TrlVal(1).MaskFreq1;
		
		LowerM		=	sum( mean(MaskFreq(:,1:Cn.NMaskLow),2) ) / 4;
		diffLowM	=	Sfreq(1) - LowerM;
		UpperM		=	sum( mean(MaskFreq(:,Cn.NMaskLow+1:end),2) ) / 4;
		diffUpM		=	UpperM - Sfreq(1);
		if UpperLower == 1
			if MaskFreq(:,:) > 1600
				UpLow	=	1;	% for the upper masker type
				AvgDiff	=	diffUpM;
			elseif MaskFreq(:,:) < 1600
				UpLow	=	0;	% for the lower masker type
				AvgDiff =	diffLowM;
			end
		elseif UpLow == 99
			AvgDiff		=	(diffLowM + diffUpM)/2;
		end
		
		Type			=	Cn.Paradigm;	%-- Stimulus types: 1: BS 2: BD 4: ES 5: ED	--%
		
		if( isfield( Cn,'NMask' ) )
			Nmask	=	Cn.NMask;
		else
			Nmask	=	Cn.NMaskBand;
		end
		
		Store(cnt,:)	=	[Type NBlock Sloc Mloc Mspl Timing];
		
		BaseRate		=	Cn.BaseRate;
		
		F				=	mean(Sfreq);
		ProtectBand		=	[F / 2^Cn.ProtectBand, F * 2^Cn.ProtectBand] + [-100 100];
		CB1_3			=	[F / 2^(1/6), F * 2^(1/6)];
		Folder			=	getfolder(Pname);
		
		Mfreq			=	getmaskfreq(TrlVal);
		keyboard
		if CheckMaskerFreq == 1 || ThrVsCOG == 1
			D(cnt,:)		=	[Thr Sfreq(1) Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Folder...
				Mfreq Cn.ProtectBand AvgDiff UpLow MaskFreqHz];
		elseif CheckMaskerFreq == 0 && ThrVsCOG == 0
			D(cnt,:)		=	[Thr Sfreq(1) Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Folder...
				Mfreq Cn.ProtectBand AvgDiff UpLow];
		end
		T(cnt).TrlVal		=	TrlVal;
		T(cnt).Subject		= Subject;
		T(cnt).Band			= Cn.ProtectBand;
		T(cnt).Temporal		= Timing; % 0 - asynchronous, 1- synchronous
		T(cnt).Spectral		= Type; % 1 - constant, 2 - random
		T(cnt).Fresh		= Folder; % 0 - Fix, 1 - Rnd
		
		cnt				=	cnt + 1;
	end
	toc
end
D = D(1:cnt-1,:);

function Subject = getsubj(Pname)

if( isunix)
	idx	=	strfind(Pname,'/');
else
	idx	=	strfind(Pname,'\');
end

Name	=	Pname(idx(end-1)+4:end-1);
Subject	=	str2double( Name );

if( isnan(Subject) )
	if( strcmpi(Name,'pb') )
		Subject	=	0;
	elseif( strcmpi(Name,'md') )
		Subject	=	1;
	else
		Subject	=	99;
	end
end

function Folder = getfolder(Pname)

if( isunix)
	idx	=	strfind(Pname,'/');
else
	idx	=	strfind(Pname,'\');
end

Folder	=	Pname(idx(end-2)+1:idx(end-1)-1); %all data

if( strcmpi(Folder,'Fix') )
	Folder	=	0;
elseif( strcmpi(Folder,'Rnd') )
	Folder	=	1;
else
	Folder	=	NaN;
	disp('Unknown folder! Inserting NaN.')
end

function Mfreq = getmaskfreq(D,MedianFlag,PlotFlag)

if( nargin < 2 )
	MedianFlag	=	1;
end
if( nargin < 3 )
	PlotFlag	=	0;
end

Sfreq		=	D(1,1).SigFreq;

N		=	length(D);
% Mfreq	=	nan(N,1);
for k=N%1:N
	SI	=	D(1,k).SigInterval;
	MF	=	eval(['D(1,k).MaskFreq' num2str(SI)]);
	
	if( MedianFlag )
		%-- "Reversal" function lower octave --%
		Noctl		=	log2( Sfreq ./ MF );
		
		%-- "Reversal" function upper octave --%
		Noctu		=	log2( MF ./ Sfreq );
		
		dMF			=	abs( [Noctu(:); Noctl(:)] );
		Mfreq		=	median(dMF(:));
		% 		Mfreq(k,1)	=	median(dMF(:));
	else
		Mfreq(k,1)	=	sum(MF(:));
	end
	
	if( PlotFlag )
		f = figure;
		for l=1:size(dMF,1)
			for m=1:size(dMF,2)
				plot(l,dMF(l,m),'k.')
				hold on
			end
		end
		plot(2.5,Mfreq(k,1),'ko')
		% 		ylim([200 15000])
		ylim([0 4.5])
		xlim([.5 4.5])
		set(gca,'XTick',1:4)
		set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
		xlabel('pulse #')
		ylabel('frequency [oct]')
		pause
		close(f)
	end
end

%-- Median across all trials until end of tracking --%
if( MedianFlag )
	Mfreq	=	median(Mfreq);
else
	Mfreq	=	sum(Mfreq);
end

function C = getctrl(D,Mlvl)

if( nargin < 2 )
	Mlvl	=	-80;	%-- If signal alone Masker level = -80 --%
end

sel	=	D(:,5) == Mlvl;

mC	=	nanmean(D(sel,1),1);
% sC	=	nanstd(D(sel,:),[],1);				%-- Std deviation		--%
sC	=	nanstd(D(sel,1),[],1) / sqrt(sum(sel));	%-- Std error of mean	--%

C	=	[mC sC];

function D = corrctrlindivsub(D,RemoveCtrl)

if( nargin < 2 )
	RemoveCtrl	=	0;
end

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

for k=1:Nsubj
	cel	=	D(:,8) == 2 & D(:,5) == -80 & D(:,16) == Usubj(k);
	CA	=	getctrl(D(cel,:),-80);
	
	sel			=	D(:,16) == Usubj(k);
	D(sel,1)	=	D(sel,1) - CA(1,1);
end

if( RemoveCtrl )
	sel			=	D(:,5) == -80;
	D(sel,:)	=	[];
end

