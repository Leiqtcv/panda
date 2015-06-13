function IM_figure4
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

pa_datadir;
load Drempel
load Track


%%
clc
N = numel(T)

%% Determine unique Masker frequencies
cnt = 0;
MF = NaN(N*4,1);
for ii = 1:N
	idx = ii;
	Freq = T(idx).Spectral;
	Time = T(idx).Temporal;
	Fresh = T(idx).Fresh;
	if Freq == 2 && Time==1 && Fresh == 0 % Frequency Constant, Time Synchronous, Frozen
		x	= [T(idx).TrlVal.SigSPL];
		mf	= [T(idx).TrlVal.MaskFreq1]; % masker frequencies interval 1 (for FrozenFcTa == interval 2), row = pulse, column = component
		ntrials = numel(x);
		for trial = 1:ntrials
			cnt = cnt+1;
			indx = (trial-1)*4+(1:4);
			cindx = (cnt-1)*4+(1:4);
			MF(cindx) = unique(mf(:,indx)); % Masker Frequencies, for FrozenFcTa == same for all pulses & intervals, so unique can be used %
		end
	end
end
O = pa_freq2bw(1600,MF);
O = round(O*100)/100;
uO = unique(O);
nO = numel(uO);
%%
cnt = 0;
MF = NaN(N*4,1);
for ii = 1:N
	idx = ii;
	Freq = T(idx).Spectral;
	Time = T(idx).Temporal;
	Fresh = T(idx).Fresh;
	if Freq == 2 && Time==1 && Fresh == 0 % Frequency Constant, Time Synchronous, Frozen
		x	= [T(idx).TrlVal.SigSPL];
		r	= [T(idx).TrlVal.RespKey];
		s	= [T(idx).TrlVal.SigInterval];
		y = r==s;
		mf	= [T(idx).TrlVal.MaskFreq1]; % masker frequencies interval 1 (for FrozenFcTa == interval 2), row = pulse, column = component
		ntrials = numel(x);
		for trial = 1:ntrials
			cnt = cnt+1;
			indx = (trial-1)*4+(1:4);
			cindx = (cnt-1)*4+(1:4);
			MF = unique(mf(:,indx)); % Masker Frequencies, for FrozenFcTa == same for all pulses & intervals, so unique can be used %
			O = pa_freq2bw(1600,MF);
			O = round(O*100)/100;
			sel = ismember(uO,O)';
			Pred(cnt,1:nO) = sel+0;
% 			SL(cindx) = repmat(x(trial),4,1); % Signal Level
% 			RC(cindx) = repmat(y(trial),4,1); % Response Correct
			
			
		end
	end
end

%% Data structure
% dataStruct = struct([]);
for fidx = 1:nO
	dataStruct.(['x' num2str(fidx)]) = Pred(:,1)+1;
% ux = unique(dataStruct.(['x' num2str(fidx)]));
end

%%
keyboard


