% BBToneCal -- Calibrate free-field speakers using tones. This version is
%   hard coded for the BeepBoop experiment

VRef			=	3.6;	% half inch mic gives 3.6 V p-2-p on the 40 dB preamp setting at MedSci
dBref			=	94;
SpeakerDirex	=	[2000 4000 5000 7000 20000 40000; 1 1 2 2 10 23];

OutPath			=	'c:\calibration\BBTones';
OldDir			=	pwd;
cd c:\'calibration'
eval('SpeakerTable');
cd (OldDir)

VOutMax			=	10;    % max output for the RX6
VInMax			=	0.1;  % work at 0.1 V p-2-p so we're closer to the range of levels that we will need

FMin			=	200;
FMax			=	14370;
FStep			=	1/6;
FList			=	FMin * 2.^(0:FStep:log2(FMax/FMin));

FList			=	FList';
NFreq			=	length(FList);
GainVec			=	zeros(NFreq,1);
PhiVec			=	zeros(NFreq,1);

% set up the TDT

figure(100);
set(gcf,'Units','normalized');
set(gcf,'Position',[0 0 .01 .01]);

% set up the ZBus
ZBus	=	actxcontrol('ZBUS.x',[1 1 1 1]);
success	=	ZBus.ConnectZBUS('GB');
if ~success
	error('Failed to init ZBus');
end

% set up the MUX
MUX		=	actxcontrol('RPco.X',[1 1 .01 .01]);
if ~MUX.ConnectRP2('GB',1);
	error('Failed to init RP2');
end
MUX.LoadCOF('K:\Open\MAT_PB\TDT\Calibration\MUXSet.rcx');
MUX.Run;
MUXClear(MUX);

% set up the RX6 on the gigabit interface
RX6		=	actxcontrol('RPco.X');
if ~success
	error('Failed to init RX6');
end

success	=	RX6.ConnectRX6('GB',1);
if ~success
	error('Failed to connect RX6');
end

success	=	RX6.LoadCOF('K:\Open\MAT_PB\TDT\Calibration\RX6FFToneCalPB.rcx');
if ~success
	error('Failed to load RX6ToneCal COF');
end

RX6.Run;

Fs		=	RX6.GetSFreq;
DACTick	=	1/Fs;  % in seconds

% Get the numbers of speakers
NDAC1	=	size(Cn.DAC1SpkrTable,1);
if isfield(Cn,'DAC2SpkrTable'),
	NDAC2	=	size(Cn.DAC2SpkrTable,1);
else
	NDAC2	=	0;
end

DAC1ToneGain	=	[];
DAC2ToneGain	=	[];

% For each speaker, step through all the frequencies. Always use MyAmp from the previous trial,
% but adjust to try to keep within 6 dB of VInMax

Vdac	=	VOutMax;

for iDAC=1:2
	if iDAC == 1
		SpkrTable	=	Cn.DAC1SpkrTable;
		NSpkr		=	NDAC1;
		RX6.SetTagVal('DACChan',1);
	else
		if ~NDAC2
			continue
		else
			SpkrTable	=	Cn.DAC2SpkrTable;
			NSpkr		=	NDAC2;
			RX6.SetTagVal('DACChan',2);
		end
	end
	
	figure
	NPanelRow	=	ceil(sqrt(NSpkr));
	NPanelCol	=	ceil(NSpkr/NPanelRow);
	
	myGain		=	nan*ones(NFreq,NSpkr);
	
	for iSpkr=1:NSpkr
		
		subplot(NPanelRow,NPanelCol,iSpkr);
		
		ThisSpkr	=	SpkrTable(iSpkr,1);
		MUXClear(MUX);
		if iDAC == 1 && ThisSpkr <= 16
			MUXSet(MUX,1,ThisSpkr);
		elseif iDAC == 1 && ThisSpkr > 16
			MUXSet(MUX,2,ThisSpkr-16);
		else
			MUXSet(MUX,3,ThisSpkr); % use MUX device 3 for DAC2
		end
		pause(.05)
		disp(['Speaker: ',num2str(ThisSpkr)]);
		
		for iFreq=1:NFreq
			
			Frequency	=	FList(iFreq);
			if ~rem(iFreq,50)
				title([num2str(round(Frequency)),' Hz']);
			end
			RX6.SetTagVal('Freq', Frequency);
			myDur		=	min(200/Frequency, .1);    % Get data from at least 200 cycles, up to 100 ms
			SweetPts	=	round(.020*Fs) + (1:round(myDur*Fs)) - 1;    % the portion of the ADC buffer that we want, skipping first 20 ms
			myDur		=	myDur + 0.020;   % duration padded w/ 20 ms before sweet spot
			ADCNpts		=	round(myDur*Fs);
			RX6.SetTagVal('BuffSize', ADCNpts);
			ADCMax		=	VInMax+1;
			
			while ADCMax > VInMax || ADCMax < 0.5*VInMax
				
				RX6.SetTagVal('Amp', Vdac);
				
				RX6.SoftTrg(1);
				pause(0.05);
				while RX6.GetTagVal('Active')
					% hang while we're still recording
					pause(0.05);
				end
				
				% upload the data
				ADCBuff	=	RX6.ReadTagV('ADCBuff', 0, ADCNpts); % get waveform data
				ADCBuff	=	ADCBuff(SweetPts);
				ADCMax	=	max(abs(ADCBuff));
				ADCBuff	=	ADCBuff/Vdac;
				
				if ADCMax > VInMax
					Vdac	=	Vdac/2;
				elseif ADCMax < 0.2*VInMax && Vdac < VOutMax
					Vdac	=	min(Vdac*2,VOutMax);
				else
					break
				end
			end
			
			NADC	=	length(ADCBuff);
			t		=	(1:NADC)/Fs;
			SineRef	=	sin(2*pi*Frequency*t);
			CosRef	=	cos(2*pi*Frequency*t);
			
			N		=	ADCNpts;
			SineVal	=	sum(ADCBuff.*SineRef);
			CosVal	=	sum(ADCBuff.*CosRef);
			myVal	=	sqrt(SineVal.^2 + CosVal.^2)/N;  % this give values in peak-to-peak volts
			
			idx		=	find(SpeakerDirex(1,:) <= Frequency);  % correct for 90-degree angle of incidence to mic
			if ~isempty(idx)
				BoostDB	=	SpeakerDirex(2,idx(end));
			else
				BoostDB	=	0;
			end
			Boost	=	10^(BoostDB/20);
			myVal	=	myVal*Boost;
			
			myGain(iFreq,iSpkr)	=	myVal / VRef; % we have already divided by Vdac;
			% given Vdac of 1, the system returns ADC value of GainVec, corrected by VRef;
			% when VRef is 1.0, sound level is 94 dB SPL
			if iFreq > 2 && abs( GainVec(iFreq)-GainVec(iFreq-1) ) > 5	% kludge to screen for glitches
				iFreq	=	iFreq-1;
			end
		end
		
		plot(FList,94 + 20*log10(myGain(:,iSpkr)),'x-')
		set(gca,'xlim',[0 ceil(FMax)],'xtick',0:5000:40000,'xticklabel',0:5:40,'ylim',[10 70]);
		title(num2str(SpkrTable(iSpkr,2)))
	end
	if iDAC == 1
		DAC1ToneGain	=	[FList myGain];
	else
		DAC2ToneGain	=	[FList myGain];
	end
end

% save (OutPath,'DAC1ToneGain','DAC2ToneGain')
