function Akaike_analysis3
% AKAIKE_ANALYSIS
%

% 2013

%% Cleansing
clc;
close all;
clear all;

%% Data stored @
cd('E:\DATA\Cortex\top-down paper data');
thorfiles   = dir('thor*');
joefiles    = dir('joe*');
files       = [thorfiles' joefiles'];
dspFlag = true;
% dspFlag = false;

%% Initialization

sigma		= 70;
dur			= 1000;

analyze(files,sigma,dur,dspFlag);

function analyze(files,sigma,dur,dspFlag)
ncells		= length(files);
sgnindx		= (-500:100)+300+dur; % this is the index, from 500 ms before reaction, to 100 ms after reaction
sgnindx500 =(-500:100)+300+500;
LL = NaN(ncells,4);
for ii				 = 1:ncells
	%% Load
	fname			 = files(ii).name;
	disp(fname);
	load(fname);
	
% 	spikeA = spikeAMA;
% 	spikeP = spikeAMP;
% 	beh = behAM;
	
	
	% 	keep spikeA spikeP beh
	%% Select data (reaction time and spike trains) based on duration of static sound
	[Spike,RT]			= seldur(spikeA,beh,dur);
	[Spike500,RT500] = seldur(spikeA,beh,500);

	%% Analyze
	% We will subtract the passive response from the active condition
	% this will presumably remove the acoustic component (if not, we will
	% see some acoustic modulations left). We will do this for every trial
	% in the active condition with the firing rate from the passive
	% condition averaged. For reasons, that will be explained below, we
	% do this removal with heavily smoothed spike density functions.
	
	[AVel,ADens,PVel,PDens] = getparams(Spike,spikeP);
	
	%% Determine modulations
	% relative to the passive signal
	% % 	ntrials			= size(Asdf70,1);
	% 	addMod			= NaN(size(Asdf70)); % Mod = modulation, add = additive model
	% 	multMod			= addMod; % mult = multiplicative model
	% 	passMod			= addMod; % pass = passive model
	% 	% 	prepMod			= addMod; % preparatory model without prediction, only for the additive model
	% 	actSignal		= addMod; % actual signal
	Psdf70	= pa_spk_sdf(spikeP,'sigma',sigma); % The smoothed active condition spike density function
	Asdf70	= pa_spk_sdf(Spike,'sigma',sigma); % The smoothed active condition spike density function
	Asdf500	= pa_spk_sdf(Spike500,'sigma',sigma); % The smoothed active condition spike density function
	Psdf	= pa_spk_sdf(spikeP,'sigma',10); % The smoothed active condition spike density function
	Asdf	= pa_spk_sdf(Spike,'sigma',10); % The smoothed active condition spike density function
	Rmu		= nanmean(RT(RT<700& RT>-800));
	Rmu500		= nanmean(RT500(RT500<700& RT500>-800));
	
	mxSize		= min([size(Psdf70,2) size(Asdf70,2) size(Asdf,2) size(Psdf70,2)  size(Asdf500,2)]); % because sdf is to the end of the last spike, we might need to remove the last bit
	Asdf70		= Asdf70(1:mxSize);
	Asdf500		= Asdf500(1:mxSize);
	Psdf70		= Psdf70(1:mxSize);
	Psdf500		= Psdf70(1:mxSize);
	Asdf		= Asdf(1:mxSize);
	Psdf		= Psdf(1:mxSize);
		
	Asdf70		= circshift(Asdf70',-round(Rmu));
	Psdf70		= circshift(Psdf70',-round(Rmu));
	Asdf		= circshift(Asdf',-round(Rmu));
	Psdf		= circshift(Psdf',-round(Rmu));
	Asdf500		= circshift(Asdf500',-round(Rmu500));
	Psdf500		= circshift(Psdf500',-round(Rmu500));
	
	addMod		= Asdf70(sgnindx)-Psdf70(sgnindx500);
	multMod		= Asdf70(sgnindx)./Psdf70(sgnindx500);
	prepMod		= Asdf500(sgnindx500)-Psdf500(sgnindx500);
	

	if dspFlag
		figure(1)
		subplot(221)
		cla
		plot(Psdf70,'k-');
		hold on
		plot(Psdf,'k:');
		plot(Asdf70,'r-');
		plot(Asdf,'r:');
		pa_verline(300+dur,'k-');
		xlabel('Time re react+300+dur');
		ylabel('SDF');
		legend({'P70';'P';'A70';'A'});
		xlim([0 2500]);
		
		subplot(222)
		cla
		plot(Asdf70-Psdf70,'k-');
		hold on
		pa_verline(300+dur);
		pa_horline(0);
		xlabel('Time re trial onset');
		ylabel('A70-P70 SDF');
		xlim([-500 100]+300+dur);

		subplot(223)
		cla
		plot(addMod,'k-');
		hold on
		plot((prepMod),'r-');
		pa_verline(500,'k-');
		pa_horline(0);
		xlabel('Time re reaction');
		ylabel('SDF');
		legend({'Additive';'Preparatory'});		
		xlim([0 length(sgnindx)]);
		
		subplot(224)
		cla
% 		plot(addMod,'k-');
		hold on
		plot(addMod-prepMod,'k-');
		pa_verline(500,'k-');
		pa_horline(0);
		xlim([0 length(sgnindx)]);
% 		return
		drawnow
		pause;
% return
	end
	
	ntrials			= size(AVel,2);
	
	
	% 		if dspFlag
	% 			figure(2)
	% 		end
	% 	col = jet(ntrials);
	pProb = NaN(ntrials,4);
	for jj	= 1:ntrials % this analysis is done for every trial in the active condition, which is noisy
		sel		= PVel == AVel(jj) & PDens == ADens(jj);
		Pmu		= pa_spk_sdf(spikeP(sel),'sigma',10); % The smoothed active condition spike density function
		
		passTrial	= circshift(Pmu',-RT(jj));
		
		try
			passTrial	= passTrial(sgnindx);
			addTrial	= passTrial+addMod;
			multTrial	= passTrial.*multMod;
			prepTrial	= passTrial+prepMod;

			indx = ceil(Spike(jj).spiketime)-(300+dur+RT(jj))+500;
			% 		figure(2)
			% 		plot(indx)
			
			indx = indx(indx>0 & indx<length(sgnindx));
			
			addProb = addTrial(indx);
			multProb = multTrial(indx);
			prepProb = prepTrial(indx);
			passProb = passTrial(indx);
			
			addProb(addProb<0.0001) = 0.0001;
			multProb(multProb<0.0001) = 0.0001;
			passProb(passProb<0.0001) = 0.0001;
			prepProb(prepProb<0.0001) = 0.0001;
			
			if dur==1000
			pProb(jj,:) = [nansum(log(addProb)) nansum(log(multProb)) nansum(log(passProb)) nansum(prepProb)];
			else
			pProb(jj,1:3) = [nansum(log(addProb)) nansum(log(multProb)) nansum(log(passProb))];
			end
		end
		% 		sumProb = sum(Prob);
		% 		if dspFlag
		% 			figure(2)
		% 			if jj==1
		% 				cla
		% 			end
		% 			plot(Pmu+jj*0.01,'k-','Color',col(jj,:));
		% 			hold on
		% 		end
	end
% 	if dur==1000
	LL(ii,:) = nansum(pProb);
% 	else
% 	LL(ii,1:3) = nansum(pProb);
% 	end
	% 			if dspFlag
	%
	% 	drawnow
	% 			end
end
if dur==1000
getakaike(-2*nansum(LL(:,1)),-2*nansum(LL(:,2)),-2*nansum(LL(:,3)),-2*nansum(LL(:,4)));
else
getakaike(-2*nansum(LL(:,1)),-2*nansum(LL(:,2)),-2*nansum(LL(:,3)));
end
function [Asdf70,Psdf70,Psdf,Asdf] = getsdf(Spike,spikeP,sigma)
[~,Asdf70]	= pa_spk_sdf(Spike,'Fs',1000,'sigma',sigma); % The smoothed active condition spike density function
[~,Psdf70]	= pa_spk_sdf(spikeP,'Fs',1000,'sigma',sigma); % the smoothed passive sdf

[~,Psdf]	= pa_spk_sdf(spikeP,'Fs',1000,'sigma',5);   % passive response with sigma = 5
[~,Asdf]	= pa_spk_sdf(Spike,'Fs',1000,'sigma',5);           % A500 response with sigma = 5

mxSize		= min([size(Psdf70,2) size(Asdf70,2) size(Asdf,2) size(Psdf70,2)]); % because sdf is to the end of the last spike, we might need to remove the last bit
Asdf70		= Asdf70(:,1:mxSize);
Psdf70		= Psdf70(:,1:mxSize);
Asdf		= Asdf(:,1:mxSize);
Psdf		= Psdf(:,1:mxSize);

function 	[AVel,ADens,PVel,PDens] = getparams(Spike,spikeP)

stim			= [Spike.stimvalues]; % active trial parameters
AVel			= round(stim(5,:)*1000)/1000; % velocity (Hz), with some rounding so MatLab can select with "precision"
ADens			= round(stim(6,:)*1000)/1000;

stim			= [spikeP.stimvalues]; % passive trial parameters
PVel			= round(stim(5,:)*1000)/1000;
PDens			= round(stim(6,:)*1000)/1000;

function [Spike,RT] = seldur(spike,beh,dur)
stim			= [spike.stimvalues];
durstat			= stim(3,:);
sel				= durstat == dur;
Spike			= spike(sel);

sel				= beh(4,:)==dur; %#ok<*NODEF>
rt				= beh(2,:);
RT				= rt(sel); % Check this
mn              = min(length(Spike),length(RT));
Spike			= Spike(1:mn);
RT				= RT(:,1:mn);

function [AIC,Di,Lm,wi,er] = getakaike(addAIC, multAIC, passAIC,prepAIC)
if nargin<4
AIC = [addAIC multAIC passAIC]
else
AIC = [addAIC multAIC passAIC prepAIC]
end
Di = AIC-min(AIC)
Lm = exp(-0.5*Di)
wi = Lm./sum(Lm)
er = 1./Lm

function sLL = getloglikelihood(Err,control)

x			= round(Err(:)*10)/10;
x			= x(~isnan(x));
xi			= unique(x);
[~,LOCB]	= ismember(x,xi);
L			= ksdensity(control(:),xi,'function','pdf');
L			= L./sum(L);
LL			= log(L(LOCB));
sel			= ~isfinite(LL);
% min(LL(~sel))
LL(sel)		= min(LL(~sel));
LL(sel)		= -100;
LL(LL<-100) = -100;
% LL = LL(isfinite(LL));
sLL		= sum(LL);