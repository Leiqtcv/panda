function CentralFilter2AFCRnd(Debug)

%   The signal is DAC2 and must go to one of the doubly wired speakers
%   (i.e., +/- 80, 40, 0 degrees), which are on DAC2. The masker is on DAC1. When
%   Sig= Mask, both play on DAC1.
%
%   SigSpkrIdx and MaskSpkrIdx refer to the position in the speaker
%   table (counted from 1). Sig and MaskSpkrMux refer to the corresponding
%   MUX channel.

%-- General Intialization --%
InHumanLab	=	1;		%-- set to zero to work in Med Sci Lab			--%
dBRef		=	94;		%-- calibration reference level					--%
CalFreqStep	=	1/6;	%-- must match value hard coded in BBToneCal	--%

RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));   % seed the random number generator

if( nargin < 1 )
	Debug	=	0;
end

if( isunix )
	OSx		=	1;
else
	OSx		=	0;
end

PlotStim	=	1;	%-- 1: Plot recorded waveform & spectrogram --%

TrlVal		=	struct([]);	%-- Initialize the trial value structure --%

%-- Get directories & files --%
if( Debug )
	close all
	clc
	
	PScript		=	'HumBDS0M0F4000Prate5Asyn';
	SubjCode	=	'pb';
	BlockNum	=	'debug';
else
	PScript		=	input('Enter the name of the parameter script: ','s');
	Folder		=	input('Enter the folder name: ','s');
	SubjCode	=	input('Enter the subject code for the data file: ','s');
	BlockNum	=	input('Enter the block number for the data file: ','s');
	
	% 	RX6path		=	'k:\open\TDTPatch\BeepBoop\RX6BeepBoop.rcx';
	RX6path		=	'C:\MAT_PB\TDT\BeepBoop\RX6RecordIMstim.rcx';
	% 	RX6path		=	'K:\Open\MAT_PB\TDT\BeepBoop\RX6RecordIMstimAM.rcx';
	MUXpath		=	'C:\MAT_PB\TDT\BeepBoop\MUXSet.rcx';
end

%-- data file --%
if( OSx )
	DataPath	=	[ '/Users/peterbr/Work/Experiments/Irvine/Data/Human/BeepBoop2010/' Folder '/' SubjCode '/' PScript '_' BlockNum ];
	CalPath		=	'/Users/peterbr/Work/Experiments/Irvine/Human/Calibration/';
else
	DataPath	=	[ 'C:\MAT_PB\BeepBoop\Data\' Folder '\' SubjCode '\' PScript '_' BlockNum ];
	CalPath		=	'c:\calibration\';
end

%-- Make sure that the data directory exists --%
makedir(DataPath);

if( exist([DataPath,'.mat'],'file') )
	disp( [DataPath,' already exists!'] );
	BlockNum	=	input('  Re-enter the block number to write over it or enter a new block number: ','s');
	if( OSx )
		DataPath	=	[ '/Users/peterbr/Work/Experiments/Irvine/Data/Human/BeepBoop2011/' SubjCode '/' PScript '_' BlockNum ];
%		DataPath	=	[ '/Users/peterbr/Work/Experiments/Irvine/Data/Human/BeepBoop2010/' Folder '/' SubjCode '/' PScript '_' BlockNum ];
	else
		DataPath	=	[ 'C:\MAT_PB\BeepBoop\Data\' Folder '\' SubjCode '\' PScript '_' BlockNum ];
	end
end

CurDir		=	getcurdir;

%-- Run the script to define the constant (Cn) structure	--%
Cn			=	[];
Cn.TestDate	=	date;

if( OSx )
	load( [CurDir 'ParamFiles/' Folder '/' PScript] );
else
	load( [CurDir 'ParamFiles\' Folder '\' PScript] );
end


%-- DAC1ToneGain has column 1 with freq list, then one column of gains for each speaker	--%
%-- ditto for DAC2ToneGain																--%
cd(CalPath);
load([Cn.ToneGains 'PB']);

%-- I am not sure what is happening here.							--%
%-- Cn.ToneGains is not used later on, instead DACxToneGain is used	--%
%-- Any change to the gains will thus not be effective				--%
if( isfield(Cn,'FreqStep') )
	SkipFreq		=	Cn.FreqStep / CalFreqStep;
	Cn.ToneGains	=	Cn.ToneGains(1:SkipFreq:end,:);
end

%-- Assume that DAC1 and DAC2 have same frequency lists --%
FreqVec		=	DAC1ToneGain(:,1);								%#ok<NODEF>

%-- In the c:\calibration directory in each lab								--%
%-- SpeakerTable has Cn.DAC1SpkrTable consisting of column of MUX numbers	--%
%-- and column of speaker locs; ditto for Cn.DAC2SpkrTable; DAC2 has just	--%
%-- the doubly-wired speakers and the null speaker							--%
eval('SpeakerTable');

cd(CurDir)

%-- Check for valid Signal and Masker locations	--%
checkloc(Cn);

%-- Start: Comment the following lines if you are not training --%
% Cn.MaskSPL		=	45;
% Cn.SigSPLStart	=	55;
% Cn.SigSPLMax	=	60;
%-- Stop: Comment the lines above if you are not training --%
%-- Please change this for practice --%
ForceFeedback	=	0;	%-- 1: Practice = Feedback; 0: No feeback --%

%-- Setup TDT --%
if( ~Debug )
	[RX6,ZBus,SigGainVec,MaskGainVec]	=	setuptdt(Cn,RX6path,MUXpath,DAC1ToneGain,DAC2ToneGain);
	
	%-- Flash some LEDs and get the subject ready --%
	getready(RX6,InHumanLab);
	
	Fs			=	RX6.GetSFreq;
	myperiod	=	1/Cn.BaseRate;
	ADCNpts		=	Cn.NPulse * myperiod * Fs + round( .1 * Fs );
	Cn.Fs		=	Fs;
else
	[SigGainVec,MaskGainVec]	=	getgainvec(Cn,DAC1ToneGain,DAC2ToneGain);
end

%-- Set signal frequency --%
iSigBand	=	find( FreqVec >= Cn.SigBand(1) & FreqVec <= Cn.SigBand(2) );
if( isempty(iSigBand) )
	% if you don't get one of the calibrated frequencies in SigBand, get the one closest to Cn.SigBand(1) --%
	[~,iSigBand]	=	min( abs(FreqVec - Cn.SigBand(1)) );
end
[~,k]		=	sort( rand(1,length(iSigBand)) );
kk			=	iSigBand(k(1));
SigFreq		=	FreqVec(kk);

plotdat(Cn,[],[])

%-- Main --%
tic

ReversePtr	=	0;
RevVec		=	nan * ones(1,Cn.NReversals);

NHit		=	0;
DownFlag	=	1;
% SigSPL		=	Cn.SigSPLStart;
SigSPL		=	getsigstart(DataPath);
if( isempty(SigSPL) )
	SigSPL	=	Cn.SigSPLStart;
end
iTrial		=	1;

while ReversePtr < Cn.NReversals
	
	if( ForceFeedback )
		Cn.Feedback		=	1;
	else
		if( iTrial < 11 )
			Cn.Feedback		=	1;
		else
			Cn.Feedback		=	0;
		end
	end
	
	% for zzz=1:3
	TrlVal(iTrial).SigSPL		=	SigSPL;
	TrlVal(iTrial).SigInterval	=	ceil(2*rand(1,1));
	
	if( isfield(Cn,'SyncSigMask') && Cn.SyncSigMask )
		TrlVal(iTrial).SigOnsetDelay	=	Cn.SigMaxOnsetDelay;
	else
		TrlVal(iTrial).SigOnsetDelay	=	Cn.SigMaxOnsetDelay * rand(1,1);
	end
	
	if( ~Debug )
		RX6.SetTagVal('SignalDelay',TrlVal(iTrial).SigOnsetDelay);
	end
	
	TrlVal(iTrial).SigFreq	=	SigFreq;
	
	SigGain		=	SigGainVec(kk);
	SigFreqVec	=	ones(1,Cn.NPulse) * SigFreq;
	if( ~Debug )
		RX6.WriteTagV('SignalFreqs', 0, [0 SigFreqVec]);
	end
	
	disp(['Trial: ' num2str(iTrial) '; Signal SPL: ' num2str(SigSPL) '; ' num2str(ReversePtr) ' reversals; Interval: ' num2str(TrlVal(iTrial).SigInterval)]);
	if( ~Debug )
		BBoxLEDs(RX6,[1 1 1 1]);
		pause (.5)
		BBoxLEDs(RX6,[0 0 0 0]);
		pause(.5);
	end
	
	for iInterval=1:2
		
		if( ~Debug )
			if( iInterval == 1 )
% 				BBoxLEDs(RX6,[1 0 0 0]);
				BBoxLEDs(RX6,[0 1 0 0]);
			else
% 				BBoxLEDs(RX6,[0 0 0 1]);
				BBoxLEDs(RX6,[0 0 1 0]);
			end
		end
		
		if( TrlVal(iTrial).SigInterval == iInterval )
			SigAmps					=	ones(1,Cn.NPulse) .* (10^((SigSPL-dBRef)/20)) ./ SigGain;
			%SigAmps((end-Cn.SigMaxOnsetDelay+1):end)	=	0;	% shorten the signal to permit an onset delay
			%-- That's the trouble maker! Commented the line --%
			% 			SigAmps(end)			=	0;		%-- clear the last pulse to permit a delay in signal onset --%
			TrlVal(iTrial).SigSPL	=	SigSPL;
		else
			SigAmps					=	zeros(1,Cn.NPulse);
		end
		
		if( ~Debug )
			RX6.WriteTagV('SignalAmps', 0, [0 SigAmps]);
		end
		
		%-- Check stimulus --%
		if( Debug )
			Stim	=	reconstim(Cn,SigFreq,SigAmps,TrlVal(iTrial).SigOnsetDelay,FreqMat,AmpMat,MaskDelayVec,1,FreqVec);
		else
			%-- Load masker freq and level buffers --%
			[FreqMat,AmpMat]	=	createmasker(Cn,SigFreq,FreqVec,MaskGainVec);
			myPeriod			=	(1000/Cn.BaseRate) / Cn.NMask;
			if( Cn.MaskRand )
				[~,k]			=	sort( rand(1,Cn.NMask) );
			else
				k				=	ones(1,Cn.NMask);   %-- No delay, masker "synchronous" with signal --%
			end
			MaskDelayVec		=	myPeriod*(k-1);
			
			for iBand=1:Cn.NMask
				mystr			=	['Mask' num2str(iBand) 'Freqs'];
				RX6.WriteTagV(mystr, 0, [0 FreqMat(:,iBand)']);
				
				mystr			=	['Mask' num2str(iBand) 'Amps'];
				RX6.WriteTagV(mystr, 0, [0 AmpMat(:,iBand)']);
				
				mystr			=	['Mask',num2str(iBand),'Delay'];
				RX6.SetTagVal(mystr, MaskDelayVec(iBand));
			end
		end
		
		if( iInterval==1 )
			TrlVal(iTrial).MaskFreq1	=	FreqMat;
		else
			TrlVal(iTrial).MaskFreq2	=	FreqMat;
		end
		
		TrlVal(iTrial).MaskAmpMat		=	AmpMat;
		TrlVal(iTrial).MaskDelayVec		=	MaskDelayVec;
		
		%-- Run this interval --%
		if( ~Debug )
			ZBus.zBusTrigA(0,0,10);
			
			if( InHumanLab )
				BBoxClear(RX6);
				while RX6.GetTagVal('Active') && ~any(BBoxRead(RX6)),
					%-- hang while we're still recording --%
					pause(0.05);
				end
			else
				while RX6.GetTagVal('Active'),
					%-- hang while we're still recording --%
					pause(0.05);
				end
			end
			
			BBoxLEDs(RX6,[0 0 0 0]);
			
			if( iInterval == 1 )
				pause(.2);  %-- inter-trial interval --%
			end
		else
			sound(Stim,48828)
		end
		
		if( ~Debug && Cn.SaveStim )
			Stim	=	RX6.ReadTagV('ADCBuff', 0, ADCNpts);	%-- Get waveform data --%
			TrlVal(iTrial).WF(:,iInterval)	=	Stim;
			if( PlotStim )
				plotstim(Cn,TrlVal(iTrial).WF(:,iInterval),TrlVal(iTrial).SigSPL,FreqVec,Cn.NMaskBand,SigFreq)
			end
		end
	end		%-- end of this interval --%
	
	if( InHumanLab && ~Debug )
% 		[ButtonVec,ET,AllButtons]	=	BBoxPoll(RX6, 10000);
		[ButtonVec,ET]	=	BBoxPoll(RX6, 10000);
		
		if( ~ET ) %-- No response within 10 seconds --%
			disp('Listener failed to respond in time!');
			for k=1:3
				beep
			end
			WhatToDo	=	input('Enter 1 to try again, 0 to abort session: ');
			if( WhatToDo )
				iTrial	=	iTrial-1;
				continue
			else
				return
			end
		end
		
% 		if( ButtonVec(1) )
		if( ButtonVec(2) )
			TrlVal(iTrial).RespKey	=	1;
		else
			TrlVal(iTrial).RespKey	=	2;
		end
		
		TrlVal(iTrial).ET	=	ET;
		
		if( ~Debug )
			BBoxClear(RX6);
		end
	else
% 		if( Debug )
% 			disp(['Signal interval = ' num2str(TrlVal(iTrial).SigInterval)])
% 			TrlVal(iTrial).RespKey	=	ceil(2*rand(1,1));%TrlVal(iTrial).SigInterval;
% 		else
		tstart	=	tic;
		TrlVal(iTrial).RespKey	=	input('Strike 1 or 2: ');
		tstop	=	toc(tstart) * 10^3;
		
		TrlVal(iTrial).ET	=	tstop;
% 		end
	end
	
	if( TrlVal(iTrial).RespKey == TrlVal(iTrial).SigInterval)	%-- A hit --%
		NHit		=	NHit + 1;
		if( NHit == Cn.NDown )	%-- Decrease sig level --%
			NHit	=	0;
			if( ~DownFlag )		%-- If we weren't already decreasing --%
				ReversePtr			=	ReversePtr + 1;
				RevVec(ReversePtr)	=	SigSPL;
			end
			
			DownFlag	=	1;
			SigSPL		=	SigSPL - Cn.StepList(ReversePtr+1);
		end
	else	%-- It's a miss --%
		NHit			=	0;
		if( DownFlag )
			ReversePtr			=	ReversePtr + 1;
			RevVec(ReversePtr)	=	SigSPL;
		end
		
		DownFlag	=	0;
		SigSPL		=	SigSPL + Cn.StepList(ReversePtr+1);		%-- Always increase Offset after a miss --%
		SigSPL		=	min(SigSPL, Cn.SigSPLMax);
	end
	
	for k=1:iTrial
		myDat(k)	=	TrlVal(k).SigSPL;						%#ok<AGROW>
	end
	
	if( ~Debug )
		if( Cn.Feedback )
			if( TrlVal(iTrial).SigInterval == 1 )
% 				BBoxLEDs(RX6,[1 0 0 0]);
				BBoxLEDs(RX6,[0 1 0 0]);
			else
% 				BBoxLEDs(RX6,[0 0 0 2]);
				BBoxLEDs(RX6,[0 0 1 0]);
			end
		end
		
		pause(.2)
		BBoxLEDs(RX6,[0 0 0 0]);
		pause(.2)
	end
	
	plotdat(Cn,iTrial,myDat)
	
	iTrial	=	iTrial + 1;
end		%-- End of main loop --%

Threshold	=	mean(RevVec(end-5:end));

%-- Wrapping up --%

%-- Save the data, flash the LEDs & alert operator --%
try
	save( DataPath,'TrlVal','Cn','Threshold' );
catch																		%#ok<CTCH>
	for k=1:3
		beep
	end
	
	disp(DataPath)
	warning('HumInfoMask:noSaveDirectory','Save directory does not exist. Please use the dialog to indicate a new directory.')
	
	DataPath	=	uigetdir('C:\','Please navigate to the save directory.');
	DataPath	=	[DataPath '\' PScript '_' BlockNum '.mat'];
	save( DataPath,'TrlVal','Cn','Threshold' );
end

for k=1:5
	beep
	pause(.3)
end

if( ~Debug )
	for k=1:10
		BBoxLEDs(RX6,[1 1 1 1]);
		pause(.3)
		BBoxLEDs(RX6,[0 0 0 0]);
		pause(.3)
	end
	BBoxLEDs(RX6,[1 1 1 1]);
	
	BBoxLEDs(RX6,[0 0 0 0]);
	RX6.Halt;
end

fprintf('Threshold: %.1f\n',Threshold);

t	=	toc;
disp(['Elapsed time: ',num2str(floor(t/60)),':',num2str(floor(rem(t,1)*60))])

return

%-- Locals --%
function makedir(DataPath)

if( isunix )
	idx		=	strfind(DataPath,'/');
else
	idx		=	strfind(DataPath,'\');
end
NewPath	=	DataPath(1:idx(end)-1);
if( ~exist( NewPath,'dir' ) )
	mkdir(NewPath)
end

return

function CurDir = getcurdir

P	=	mfilename('fullpath');
if( isunix )
	idx	=	strfind(P,'/');
else
	idx	=	strfind(P,'\');
end
CurDir	=	P(1:idx(end));

function checkloc(Cn)

BadLoc	=	find( ~ismember(Cn.MaskLoc,Cn.DAC1SpkrTable(:,2)) );
if( ~isempty(BadLoc) )
	disp(['Mask location ' num2str(Cn.MaskLoc(BadLoc)) ' is not in the speaker table!']);
	return
end

BadLoc	=	find(~ismember(Cn.SigLoc,Cn.DAC2SpkrTable(:,2)));
if( ~isempty(BadLoc) )
	disp(['Signal location ',num2str(Cn.SigLoc(BadLoc)),' is not in the speaker table!']);
	return
end

return

function [RX6,ZBus,SigGainVec,MaskGainVec] = setuptdt(Cn,RX6path,MUXpath,DAC1ToneGain,DAC2ToneGain)

%-- set up the ZBus --%
figure(100)
set(gcf,'position',[1 1 1 1])
ZBus = actxcontrol('ZBUS.x',[1 1 .01 .01]);
success = ZBus.ConnectZBUS('GB');
if( ~success )
	error('Failed to init ZBus');
end

%-- set up the RX6 on the gigabit interface --%
RX6= actxcontrol('RPco.X');
if( ~success )
	error('Failed to init RX6');
end

success = RX6.ConnectRX6('GB',1);
if( ~success )
	error('Failed to connect RX6');
end

RX6.ClearCOF;
if( ~RX6.LoadCOF(RX6path) )
	error(['Failure to load ' RX6path '!']);
end

%-- set up the MUX --%
MUX		=	actxcontrol('RPco.X',[1 1 .01 .01]);
if( ~MUX.ConnectRP2('GB',1) )
	error('Failed to init RP2');
end
MUX.LoadCOF(MUXpath);
MUX.Run;
MUXClear(MUX);

%-- Set the constant stimulus values --%
myperiod	=	1000/Cn.BaseRate;
RX6.SetTagVal( 'HiTime', myperiod/2 );
RX6.SetTagVal( 'LoTime', myperiod/2 );
% RX6.SetTagVal( 'NPulse', Cn.NPulse+1 );
RX6.SetTagVal( 'NPulse', Cn.NPulse );

%-- Set high time for cosine gate --%
RX6.SetTagVal( 'GateHigh', myperiod-8 );

%-- Set the high time for the recording --%
RX6.SetTagVal( 'RecHiTime', Cn.NPulse*myperiod + 100 );

%-- Set serial buffer length --%
Fs			=	RX6.GetSFreq;
T			=	1/Cn.BaseRate;
RecBuff		=	round( Cn.NPulse * T * Fs  ) + round( .1 * Fs );
RX6.SetTagVal( 'RecBuff', RecBuff );

%-- load the Gauss buffers --%
Fs					=	RX6.GetSFreq;
NGaussPts			=	ceil(Cn.GaussDur*Fs/1000);
NSigmaPts			=	ceil(Cn.GaussSigma*Fs/1000);
myGauss				=	UnitGauss(NSigmaPts,NGaussPts);
myGauss				=	myGauss/max(myGauss);
myGauss([1 end])	=	0;
RX6.SetTagVal( 'GaussLength', NGaussPts );
RX6.WriteTagV( 'GaussBuffSig', 0, myGauss ); %-- need buffers for the signal and each of up to 4 maskers --%
RX6.WriteTagV( 'GaussBuffM1', 0, myGauss );
RX6.WriteTagV( 'GaussBuffM2', 0, myGauss );
RX6.WriteTagV( 'GaussBuffM3', 0, myGauss );
RX6.WriteTagV( 'GaussBuffM4', 0, myGauss );
RX6.WriteTagV( 'GaussBuffM5', 0, myGauss );

%-- set the MUXes --%
MUXClear(MUX);

pause(.05);

if( Cn.SigLoc == Cn.MaskLoc )   %-- play both on DAC1 --%
	
	SigSpkrIdx	=	find( Cn.DAC1SpkrTable(:,2) == Cn.SigLoc );
	
	if( isempty(SigSpkrIdx) )
		disp(['Can''t find a speaker at ' num2str(Cn.SigLoc) '!']);
		return
	end
	
	SigGainVec	=	DAC1ToneGain(:,SigSpkrIdx+1);
	SigSpkrMUX	=	Cn.DAC1SpkrTable(SigSpkrIdx,1);
	
	% 	MaskSpkrIdx	=	SigSpkrIdx;
	MaskGainVec	=	SigGainVec;
	% 	MaskSpkrMUX	=	SigSpkrMUX;
	
	MUXDev		=	ceil(SigSpkrMUX/16);
	MUXNum		=	rem(SigSpkrMUX-1,16)+1;
	MUXSet(MUX,MUXDev,MUXNum);
	RX6.SetTagVal('MixChannels',1);
	RX6.SetTagVal('EnableDAC2',0);
	MUXSet(MUX,3,0);				%-- important to clear DAC2 mux in merged condition --%
else	%-- Mask on DAC1, Sig on 2 --%
	SigSpkrIdx	=	find(Cn.DAC2SpkrTable(:,2)==Cn.SigLoc);
	
	if( isempty(SigSpkrIdx) )
		disp(['Can''t find a speaker at ',num2str(Cn.SigLoc),'!']);
		return
	end
	
	SigGainVec	=	DAC2ToneGain(:,SigSpkrIdx+1);
	SigSpkrMUX	=	Cn.DAC2SpkrTable(SigSpkrIdx,1);
	
	MaskSpkrIdx	=	find(Cn.DAC1SpkrTable(:,2)==Cn.MaskLoc);
	
	if( isempty(MaskSpkrIdx) )
		disp(['Can''t find a speaker at ',num2str(Cn.MaskLoc),'!']);
		return
	end
	
	MaskGainVec	=	DAC1ToneGain(:,MaskSpkrIdx+1);
	MaskSpkrMUX	=	Cn.DAC1SpkrTable(MaskSpkrIdx,1);
	
	MUXDev		=	ceil(MaskSpkrMUX/16);
	MUXNum		=	rem(MaskSpkrMUX-1,16)+1;
	MUXSet(MUX,MUXDev,MUXNum);
	
	MUXSet(MUX,3,SigSpkrMUX);
	
	RX6.SetTagVal('MixChannels',0);
	RX6.SetTagVal('DAC2Enable',1);
end

return

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

function getready(RX6,InHumanLab)

RX6.Run;
% if( InHumanLab )
%     BBoxClear(RX6);
%     BBoxLEDs(RX6,[0 0 0 0]);
% end
% disp('Prepare the subject, then press any key...');
% pause

if( InHumanLab )
	BBoxClear(RX6);
	BBoxLEDs(RX6,[0 0 0 0]);
	
	disp('Waiting for double button press from subject');
	BBoxLEDs(RX6,[1 1 1 1]);										%-- light up all the LEDs			--%
	
	% 	[ButtonVec,inf,AllButtons]		=	BBoxPoll(RX6, 20000,2000);	%-- wait for double button press	--%
	ButtonVec		=	BBoxPoll(RX6, 20000,2000);	%-- wait for double button press	--%
	
% 	while ~all( ButtonVec([2 4]) )
	while ~all( ButtonVec([2 3]) )
		%         [ButtonVec,inf,AllButtons]	=	BBoxPoll(RX6, 20000,2000);
		ButtonVec	=	BBoxPoll(RX6, 20000,2000);
	end
else
	disp('Press any key to start the run...');
	pause
end

BBoxLEDs(RX6,[0 0 0 0]);
if( InHumanLab )
	BBoxClear(RX6);
end
pause(.5)

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

function plotdat(Cn,iTrial,myDat)

if( ~isempty(myDat) )
	ymin	=	min( min(myDat,0) ) * 1.1;
else
	ymin	=	0;
end
if( ~isempty(myDat) )
	ymax	=	max( max(myDat,Cn.SigSPLStart) ) * 1.1;
else
	ymax	=	1 + Cn.SigSPLStart * 1.1;
end

yy	=	sort([ymin ymax]);

figure(1)
clf
plot(1:iTrial,myDat,'ko-','MarkerFaceColor',[.9 .9 .9]);
try																%#ok<TRYNC>
	ylim(yy)
end
set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
xlabel('trial')
ylabel('threshold [dB]')
title('Subject has started trials')
box on

function Stim = reconstim(Cn,SigFreq,SigAmp,SigDelay,FreqMat,AmpMat,MaskDelayVec,flag,FreqVec)

if( nargin < 8 )
	flag	=	0;
end

Fs			=	48828;

T			=	1 / Cn.BaseRate;
Dur			=	Cn.GaussDur * 10^-3;
Sigma		=	Cn.GaussSigma * 10^-3;
NPulse		=	Cn.NPulse;

NPer		=	round( T * Fs );
NSigDelay	=	round( SigDelay*10^-3 * Fs );
NSamp		=	round( Dur * Fs ) + 1;
NSig		=	NPer*NPulse + NSigDelay;
Noct		=	Cn.ProtectBand;
ProtectBand	=	[SigFreq / 2^Noct, SigFreq * 2^Noct];%  + [-100 100];
CB1_3		=	[SigFreq / 2^(1/6), SigFreq * 2^(1/6)];

NMaskBand	=	Cn.NMaskBand;
NMaskDelay	=	round( MaskDelayVec*10^-3 * Fs );
NMask		=	NPer*(NPulse+1);

S			=	zeros(NSig,1);
M			=	zeros(NMask,NMaskBand);
start		=	NSigDelay;
if( start ~= 1 )
	start	=	1;
end
stop		=	start + NSamp - 1;
mtart		=	1;
for k=1:NPulse
	S(start:stop,1)	=	makesine(SigFreq,SigAmp(k),Dur,Sigma,Fs);
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

NMask		=	size(M,1);

NDif		=	NMask - NSig;
Stim		=	[S; zeros(NDif,1)];
Stim		=	Stim + sum(M,2);

maxStim		=	max(Stim);
Stim		=	.999 .* (Stim ./ maxStim);

if( flag )
	Fbands	=	getfreqband(FreqVec,Cn.NMaskBand);
	
	ts			=	( ( (0:NSig-1) ) * 1/Fs ) * 10^3;
	tm			=	( ( (0:NMask-1) ) * 1/Fs ) * 10^3;
	
	window		=	round( 10^-2*Fs );
	noverlap	=	round( .5*10^-3*Fs );
	Nfft		=	1024;
	
	figure(1)
	clf
	
	subplot(2,3,1)
	plot(ts,S,'k-')
	xlim([ts(1) ts(end)])
	ylim([-1.1 1.1])
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [msec]')
	ylabel('amplitude [a.u.]')
	title('signal alone')
	axis('square')
	
	subplot(2,3,2)
	plot(tm,M)
	xlim([tm(1) tm(end)])
	ylim([-1.1 1.1])
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [msec]')
	ylabel('amplitude [a.u.]')
	title('masker alone')
	axis('square')
	
	subplot(2,3,3)
	plot(ts,S,'k-')
	hold on
	plot(tm,M)
	xlim([tm(1) tm(end)])
	ylim([-1.1 1.1])
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [msec]')
	ylabel('amplitude [a.u.]')
	title('signal + masker')
	axis('square')
	
	subplot(2,3,4)
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
	
	for k=1:size(Fbands,1)
		plot([T(1) T(end)],[Fbands(k,1) Fbands(k,1)],'b-')
		plot([T(1) T(end)],[Fbands(k,2) Fbands(k,2)],'b--')
	end
	
	set(gca,'YTick',[62.5 125 250 500 1000 2000 4000 8000 16000 32000],'YTickLabel',[62.5 125 250 500 1000 2000 4000 8000 16000 32000])
	set(gca,'YScale','log')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [ms]')
	ylabel('frequency [Hz]')
	title('signal alone')
	box on
	
	subplot(2,3,5)
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
	
	for k=1:size(Fbands,1)
		plot([T(1) T(end)],[Fbands(k,1) Fbands(k,1)],'b-')
		plot([T(1) T(end)],[Fbands(k,2) Fbands(k,2)],'b--')
	end
	
	set(gca,'YTick',[62.5 125 250 500 1000 2000 4000 8000 16000 32000],'YTickLabel',[62.5 125 250 500 1000 2000 4000 8000 16000 32000])
	set(gca,'YScale','log')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [ms]')
	ylabel('frequency [Hz]')
	title('masker alone')
	box on
	
	subplot(2,3,6)
	[~,F,T,P] = spectrogram(Stim,window,noverlap,Nfft,Fs);
	T	=	T * 10^3;
	surf(T,F,10*log10(abs(P)+eps),'EdgeColor','none');
	axis tight
	view(0,90);
	hold on
	plot([T(1) T(end)],[ProtectBand(1) ProtectBand(1)],'r-')
	plot([T(1) T(end)],[ProtectBand(2) ProtectBand(2)],'r-')
	plot([T(1) T(end)],[CB1_3(1) CB1_3(1)],'r--')
	plot([T(1) T(end)],[CB1_3(2) CB1_3(2)],'r--')
	
	for k=1:size(Fbands,1)
		plot([T(1) T(end)],[Fbands(k,1) Fbands(k,1)],'b-')
		plot([T(1) T(end)],[Fbands(k,2) Fbands(k,2)],'b--')
	end
	
	set(gca,'YTick',[62.5 125 250 500 1000 2000 4000 8000 16000 32000],'YTickLabel',[62.5 125 250 500 1000 2000 4000 8000 16000 32000])
	set(gca,'YScale','log')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('time [ms]')
	ylabel('frequency [Hz]')
	title('signal + masker')
	box on
	
	colormap('gray')
	keyboard
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

function plotstim(D,WF,SigSPL,FreqVec,NMaskBand,SigFreq)

Fs		=	D.Fs;

Nwf		=	length(WF);

window		=	round( 10^-2*Fs );
noverlap	=	round( .5*10^-3*Fs );
Nfft		=	1024;

Noct		=	D.ProtectBand;

ProtectBand	=	[SigFreq / 2^Noct, SigFreq * 2^Noct];%  + [-100 100];
CB1_3		=	[SigFreq / 2^(1/6), SigFreq * 2^(1/6)];

Fbands	=	getfreqband(FreqVec,NMaskBand);

t		=	( ( 0:Nwf-1 ) ./ Fs ) * 10^3;

%-- TDT offset removal --%
WF		=	WF - mean(WF);

yy		=	max(abs(WF)) * 1.1;

figure(2)
clf

subplot(2,1,1)
plot(t,WF,'k-')
xlim([t(1) t(end)])
ylim([-yy yy])
set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
xlabel('time [msec]')
ylabel('amplitude [a.u.]')
title(['S' num2str(D.SigLoc) 'M' num2str(D.MaskLoc) '; SPL_{sig}= ' num2str(SigSPL) ' dB & SPL_{mask}= ' num2str(D.MaskSPL) ' dB'])

subplot(2,1,2)
[~,F,T,P] = spectrogram(WF,window,noverlap,Nfft,Fs);
T	=	T * 10^3;
surf(T,F,10*log10(abs(P)+eps),'EdgeColor','none');
axis tight
view(0,90);
hold on
for k=1:size(Fbands,1)
	plot([T(1) T(end)],[Fbands(k,1) Fbands(k,1)],'b-')
	plot([T(1) T(end)],[Fbands(k,2) Fbands(k,2)],'b--')
end
plot([T(1) T(end)],[ProtectBand(1) ProtectBand(1)],'r-')
plot([T(1) T(end)],[ProtectBand(2) ProtectBand(2)],'r-')
plot([T(1) T(end)],[CB1_3(1) CB1_3(1)],'r--')
plot([T(1) T(end)],[CB1_3(2) CB1_3(2)],'r--')
set(gca,'YTick',[62.5 125 250 500 1000 2000 4000 8000 16000 32000],'YTickLabel',[62.5 125 250 500 1000 2000 4000 8000 16000 32000])
set(gca,'YScale','log')
set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
xlabel('time [ms]')
ylabel('frequency [Hz]')
title('spectrogram')
box on

colormap('gray')

function SigSPL	= getsigstart(D)

try
	load([D(1:end-1) '1'])
	SigSPL	=	round( Threshold + 15 );
	if SigSPL > 55
		SigSPL = 55;
	end
catch															%#ok<CTCH>
	SigSPL	=	[];
end

%-- Junk --%
%{
function [FreqMat,AmpMat] = LoadMaskBuffers2(Cn,SigFreq,FreqVec,MaskGainVec)

% LoadMaskBuffers: For each interval, fill the frequency and amplitude buffers for the info masker

dBRef	=	94;

Protect	=	SigFreq * 2.^[-Cn.ProtectBand Cn.ProtectBand] + [-100 100];	%-- Add 100 Hz to the protected band	--%
AmpVec	=	(10^((Cn.MaskSPL-dBRef)/20)) ./ MaskGainVec;
AmpVec	=	min(AmpVec, 1.0);								%-- Limit amplitudes to avoid speaker distortion --%

AmpMat	=	zeros(Cn.NPulse,Cn.NMaskBand);
FreqMat	=	ones(Cn.NPulse,Cn.NMaskBand);
for iBand=1:Cn.NMaskBand
	%-- Informational masking with protected band --%
	if( Cn.Paradigm == 0 )
		idx	=	find(	FreqVec >= Cn.MaskBand(iBand,1) & FreqVec <= Cn.MaskBand(iBand,2) & ...
						(FreqVec <= Protect(1) | FreqVec >= Protect(2)) );
	%-- Energetic masking = all masker frequencies fall within the protected band --%
	elseif( Cn.Paradigm == 1 )
		idx	=	find(	FreqVec >= Cn.MaskBand(iBand,1) & FreqVec <= Cn.MaskBand(iBand,2) & ...
						(FreqVec >= Protect(1) & FreqVec <= Protect(2)) );
	%-- Complex tone --%
	elseif( Cn.Paradigm == 2 )
		idx	=	find(	FreqVec >= Cn.MaskBand(iBand,1) & FreqVec <= Cn.MaskBand(iBand,2) );
	end
	
	if( isempty(idx) )
		FreqMat(:,iBand)	=	1000*ones(Cn.NPulse,1);    %-- A dummy frequency --%
		AmpMat(:,iBand)		=	zeros(Cn.NPulse,1);
	else
		if( Cn.Paradigm == 2 )
			myFreqs			=	mean( Cn.MaskBand(iBand,:) );
		else
			myFreqs			=	FreqVec(idx);
		end
		myAmps				=	AmpVec(idx);
		myNFreq				=	length(idx);
		k					=	ceil( myNFreq * rand(1,Cn.NPulse) )';
		FreqMat(:,iBand)	=	myFreqs(k);
		AmpMat(:,iBand)		=	myAmps(k);
	end
end

return
%}