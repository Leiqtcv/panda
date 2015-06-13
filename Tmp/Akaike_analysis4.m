function Akaike_analysis4
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
dspFlag = false;

%% Initialization

sigma		= 70;
dur			= 500;

analyze(files,sigma,dur,dspFlag);

function analyze(files,sigma,dur,dspFlag)
ncells		= length(files);
sgnindx1000	= (-500:100)+300+1000; % this is the index, from 500 ms before reaction, to 100 ms after reaction
sgnindx500	=(-500:100)+300+500;
LL500 = NaN(ncells,4);
LL1000 = NaN(ncells,4);
LLprep = NaN(ncells,1);
M500 = NaN(ncells,numel(sgnindx500));

M1000 = NaN(ncells,numel(sgnindx1000));
Nspikes500 = NaN(ncells,1);
Nspikes1000 = NaN(ncells,1);
Ntrials500 = NaN(ncells,1);
Ntrials1000 = NaN(ncells,1);

for ii				 = 1:ncells
	%% Load
	
	fname			 = files(ii).name;
	disp(fname);
	load(fname);
	
	spikeA = spikeAMA;
	spikeP = spikeAMP;
	beh = behAM;
	
	
	% 	keep spikeA spikeP beh
	%% Select data (reaction time and spike trains) based on duration of static sound
	[S1000,RT1000]	= seldur(spikeA,beh,1000);
	[S500,RT500]	= seldur(spikeA,beh,500);
	SP				= rmfield(spikeP,{'spikewave';'timestamp';'stimparams';'trialorder';'trial';'aborted'});
	clear spikeA beh behAM spikeAMA spikeAMP spikeP
	
	%% Analyze
	% We will subtract the passive response from the active condition
	% this will presumably remove the acoustic component (if not, we will
	% see some acoustic modulations left). We will do this for every trial
	% in the active condition with the firing rate from the passive
	% condition averaged. For reasons, that will be explained below, we
	% do this removal with heavily smoothed spike density functions.
	[par500,par1000,parP,isripple]						= getparams(S500,S1000,SP);
	[sdf70A500,sdf70A1000,sdf70P,sdfA500,sdfA1000,sdfP] = getsdf(S500,S1000,SP,sigma);
	
	%% Determine modulations
	[addMod500,multMod500,passMod500,actSignal500] = getmod(sdf70A500,sdfA500,RT500,par500,sdf70P,sdfP,parP,isripple);
	addMod500	= nanmean(addMod500);
	multMod500	= nanmean(multMod500);
	
	[addMod1000,multMod1000,passMod1000,actSignal1000] = getmod(sdf70A1000,sdfA1000,RT1000,par1000,sdf70P,sdfP,parP,isripple);
	addMod1000	= nanmean(addMod1000);
	multMod1000	= nanmean(multMod1000);
	
	prepMod = addMod500;
	t = 1:length(addMod500);
	
	if dspFlag
		
		subplot(231)
		cla;
		plot(t,addMod500,'k-');
		hold on;
		pa_horline(0);
		pa_verline([300 300+dur]);
		plot(t(sgnindx500),addMod500(sgnindx500),'k','LineWidth',3);
		subplot(232)
		cla;
		plot(t,multMod500,'k-');
		hold on;
		plot(t(sgnindx500),multMod500(sgnindx500),'k','LineWidth',3);
		
		pa_horline(0);
		pa_verline([300 300+dur]);
		
		subplot(233)
		cla;
		plot(t,nanmean(passMod500),'k-');
		hold on
		plot(t,nanmean(actSignal500),'r-');
		
		mp = nanmean(passMod500);
		plot(t(sgnindx500),mp(sgnindx500),'k-','LineWidth',3);
		ma = nanmean(actSignal500);
		plot(t(sgnindx500),ma(sgnindx500),'r-','LineWidth',3);
		pa_verline([300 300+dur]);
		
		subplot(231)
		plot(t(sgnindx500),ma(sgnindx500)-mp(sgnindx500),'r-','LineWidth',1);
		
		subplot(232)
		plot(t(sgnindx500),ma(sgnindx500)./mp(sgnindx500),'r-','LineWidth',1);
		
		%% 1000
		subplot(234)
		cla;
		plot(t,addMod1000,'k-');
		hold on;
		pa_horline(0);
		pa_verline([300 300+1000]);
		plot(t(sgnindx1000),addMod1000(sgnindx1000),'k','LineWidth',3);
		plot(t(sgnindx1000),prepMod(sgnindx1000),'b','LineWidth',3);
		
		subplot(235)
		cla;
		plot(t,multMod1000,'k-');
		hold on;
		plot(t(sgnindx1000),multMod1000(sgnindx1000),'k','LineWidth',3);
		
		pa_horline(0);
		pa_verline([300 300+1000]);
		
		subplot(236)
		cla;
		plot(t,nanmean(passMod1000),'k-');
		hold on
		plot(t,nanmean(actSignal1000),'r-');
		
		mp = nanmean(passMod1000);
		plot(t(sgnindx1000),mp(sgnindx1000),'k-','LineWidth',3);
		ma = nanmean(actSignal1000);
		plot(t(sgnindx1000),ma(sgnindx1000),'r-','LineWidth',3);
		pa_verline([300 300+1000]);
		
		subplot(234)
		plot(t(sgnindx1000),ma(sgnindx1000)-mp(sgnindx1000),'r-','LineWidth',1);
		
		subplot(235)
		plot(t(sgnindx1000),ma(sgnindx1000)./mp(sgnindx1000),'r-','LineWidth',1);
		drawnow
		% 				pause
	end
	
	%% Determine probabilities
	[LL500(ii,:),Nspikes500(ii),Ntrials500(ii)]		= getprob(sdfA500,passMod500,addMod500,multMod500,S500,RT500,sgnindx500,500,actSignal500,sgnindx500);
	[LL1000(ii,:),Nspikes1000(ii),Ntrials1000(ii)]	= getprob(sdfA1000,passMod1000,addMod1000,multMod1000,S1000,RT1000,sgnindx1000,1000,actSignal1000,sgnindx500);
	LLprep(ii)		= geprepprob(sdfA1000,passMod1000,prepMod,S1000,RT1000,sgnindx1000,1000);
	
	M500(ii,:)		= addMod500(sgnindx500);
	M1000(ii,:)		= addMod1000(sgnindx1000);
	
end
disp('--------------');
getakaike(-2*nansum(LL500(:,1)),-2*nansum(LL500(:,2)),-2*nansum(LL500(:,3)));

% disp('--------------');
% getakaike(-2*nansum(LL1000(:,1)),-2*nansum(LL1000(:,2)),-2*nansum(LL1000(:,3)),-2*nansum(LLprep));
disp('--------------');
getakaike(-2*nansum(LL1000(:,1)),-2*nansum(LL1000(:,2)),-2*nansum(LL1000(:,3)));
disp('--------------');

% Check if values seem correct
figure
subplot(221)
x	= M500';
x1	= x(1,:);
x = bsxfun(@minus,x,x1);
plot(x,'k-','Color',[.7 .7 .7]);
hold on
plot(mean(x,2),'k-','LineWidth',2);
axis square
box off
xlim([0 600]);
title('A500');

subplot(222)
x	= M1000';
x1	= x(1,:);
x = bsxfun(@minus,x,x1);
plot(x,'k-','Color',[.7 .7 .7]);
hold on
plot(mean(x,2),'k-','LineWidth',2);
axis square
box off
xlim([0 600]);

title('A1000');

subplot(223)
x	= M1000'-M500';
x1	= x(1,:);
x = bsxfun(@minus,x,x1);
plot(x,'k-','Color',[.7 .7 .7]);
hold on
plot(mean(x,2),'k-','LineWidth',2);
axis square
box off
xlim([0 600]);
title('A1000-A500');

subplot(224)
hold on
x	= M500';
x1	= x(1,:);
x = bsxfun(@minus,x,x1);
plot(mean(x,2),'r-','LineWidth',2);

x	= M1000';
x1	= x(1,:);
x = bsxfun(@minus,x,x1);
plot(mean(x,2),'b-','LineWidth',2);

x	= M1000'-M500';
x1	= x(1,:);
x = bsxfun(@minus,x,x1);
plot(mean(x,2),'k-','LineWidth',2);

axis square
box off
xlim([0 600]);
title('Averages');
for ii = 1:4
	subplot(2,2,ii)
	pa_verline(500);
	xlabel('Time re Bar Release (ms)');
	ylabel('Spike density');
	pa_text(0.1,0.9,char(96+ii));
end
function [sdf70A500,sdf70A1000,sdf70P,sdfA500,sdfA1000,sdfP] = getsdf(S500,S1000,SP,sigma)
[~,sdf70A500]	= pa_spk_sdf(S500,'sigma',sigma); % The smoothed active condition spike density function
[~,sdf70A1000]	= pa_spk_sdf(S1000,'sigma',sigma); % the smoothed passive sdf
[~,sdf70P]		= pa_spk_sdf(SP,'sigma',sigma); % the smoothed passive sdf

[~,sdfA500]		= pa_spk_sdf(S500,'sigma',5); % The smoothed active condition spike density function
[~,sdfA1000]	= pa_spk_sdf(S1000,'sigma',5); % the smoothed passive sdf
[~,sdfP]		= pa_spk_sdf(SP,'sigma',5); % the smoothed passive sdf

mxSize = min([size(sdfP,2) size(sdfA500,2) size(sdfA1000,2)]);

sdf70P		= sdf70P(:,1:mxSize);
sdf70A500		= sdf70A500(:,1:mxSize);
sdf70A1000		= sdf70A1000(:,1:mxSize);
sdfP			= sdfP(:,1:mxSize);
sdfA500			= sdfA500(:,1:mxSize);
sdfA1000			= sdfA1000(:,1:mxSize);

function 	[par500,par1000,parP,isripple] = getparams(S500,S1000,SP)

stim	= [S500.stimvalues]; % active500 parameters
if size(stim,1)==7
	indx = [5 6]; % for ripples
	isripple = true;
elseif size(stim,1)==6
	indx = 5; % for AM
	isripple = false;
end
par500	= round(stim(indx,:)*1000)/1000;
stim	= [S1000.stimvalues]; % active1000 trial parameters
par1000	= round(stim(indx,:)*1000)/1000;
stim	= [SP.stimvalues]; % passive trial parameters
parP		= round(stim(indx,:)*1000)/1000;


function [Spike,RT] = seldur(spike,beh,dur)
stim			= [spike.stimvalues];
durstat			= stim(3,:);
sel				= durstat == dur;
Spike			= spike(sel);
Spike			= rmfield(Spike,{'spikewave';'timestamp';'stimparams';'trialorder';'trial';'aborted'});

sel				= beh(4,:)==dur; %#ok<*NODEF>
rt				= beh(2,:);
RT				= rt(sel); % Check this
mn              = min(length(Spike),length(RT));
Spike			= Spike(1:mn);
RT				= RT(:,1:mn);

function [AIC,Di,Lm,wi,er] = getakaike(addAIC, multAIC, passAIC,prepAIC)
if nargin<4
	AIC = [addAIC multAIC passAIC];
else
	AIC = [addAIC multAIC passAIC prepAIC];
end
minprob = 1;

AIC = AIC./minprob
Di = AIC-min(AIC)
Lm = exp(-0.5*Di)
wi = Lm./sum(Lm)
er = 1./Lm



function [addMod,multMod,passMod,actSignal] = getmod(sdf70A,sdfA,RT,par,sdf70P,sdfP,parP,isripple)

%% Determine modulations
% relative to the passive signal
[ntrials,ntime]			= size(sdfA);
addMod			= NaN(ntrials,ntime); % Mod = modulation, add = additive model
multMod			= addMod; % mult = multiplicative model
passMod			= addMod; % pass = passive model
actSignal		= addMod; % actual signal
for jj	= 1:ntrials % this analysis is done for every trial in the active condition, which is noisy
	if isripple
		sel = parP(1,:)==par(1,jj) & parP(2,:)==par(2,jj);
	elseif ~isripple
		sel = parP==par(jj);
	end
	Pmu = mean(sdf70P(sel,:)); % and we mean the data for the passive trials, to remove some of the variability
	
	%% modulations
	addMod(jj,:)	= sdf70A(jj,:)-Pmu;
	multMod(jj,:)	= sdf70A(jj,:)./Pmu;
	Pmu				= mean(sdfP(sel,:)); % for the small sigma
	passMod(jj,:)	= Pmu; % Passive model
	
	%% align to reaction time
	% this is done by a circular shift by an amount of RT samples
	% RT = 0 -> sample 800 for 500 conditions
	% -> sample 1300 for 1000 conditions
	addMod(jj,:)	= circshift(addMod(jj,:)',-RT(jj))';
	multMod(jj,:)	= circshift(multMod(jj,:)',-RT(jj))';
	
	passMod(jj,:)	= circshift(passMod(jj,:)',-RT(jj))';
	actSignal(jj,:)	= circshift(sdfA(jj,:)',-RT(jj))';
	
	% Remove responses that are way too fast (-800 ms because you only
	% have 800 ms of data before the modulation), or way too late
	% (after 900 ms).
	if 			RT(jj)>700 || RT(jj)<-800 
		addMod(jj,:)	= NaN(size(addMod(jj,:)));
		multMod(jj,:)	= NaN(size(multMod(jj,:)));
		passMod(jj,:)	= NaN(size(passMod(jj,:)));
		actSignal(jj,:) = NaN(size(actSignal(jj,:)));
	end
	
	
end


function 	[LL,Nspikes,Ntrials] = getprob(sdfA,passMod,addMod,multMod,S,RT,sgnindx,dur,actSignal,passindx)
minprob = 1e-5;

ntrials			= size(sdfA,1);
pProb = NaN(ntrials,3);
Nspikes = 0;
Ntrials = 0;
for jj	= 1:ntrials % this analysis is done for every trial in the active condition, which is noisy
	passTrial	= passMod(jj,passindx);
	actTrial	= actSignal(jj,sgnindx);

	addTrial	= passTrial+addMod(sgnindx);
	multTrial	= passTrial.*multMod(sgnindx);
	
	indx		= ceil(S(jj).spiketime)-(300+dur+RT(jj))+500;
	indx		= indx(indx>0 & indx<length(sgnindx));

	addProb		= addTrial(indx);
	multProb	= multTrial(indx);
	passProb	= passTrial(indx);
	actProb		= actTrial(indx);
	
% % 	%% AD-HOC
% % 	disp('AD-HOC NORMALIZATION');
% % 	
% 	addProb = addProb./actProb;
% 	multProb = multProb./actProb;
% 	passProb = passProb./actProb;
	
	addProb(addProb<minprob) = minprob;
	multProb(multProb<minprob) = minprob;
	passProb(passProb<minprob) = minprob;
	actProb(actProb<minprob) = minprob;
	
	addProb(isinf(addProb)) = minprob;
	multProb(isinf(multProb)) = minprob;
	passProb(isinf(passProb)) = minprob;
	actProb(isinf(addProb)) = minprob;
	
	pProb(jj,1:4) = [nansum(log(addProb)) nansum(log(multProb)) nansum(log(passProb)) nansum(log(actProb))];
	
	Nspikes = Nspikes+numel(indx);
	if ~any(isnan(addTrial))
		Ntrials = Ntrials+1;
	end
end
LL = nansum(pProb);

function LL = geprepprob(sdfA,passMod,prepMod,S,RT,sgnindx,dur)
minprob	= 1e-5;

ntrials			= size(sdfA,1);
pProb = NaN(ntrials,1);
for jj	= 1:ntrials % this analysis is done for every trial in the active condition, which is noisy
	passTrial	= passMod(jj,:);
	prepTrial	= passTrial+prepMod;
	
	indx		= ceil(S(jj).spiketime)-(300+500+RT(jj))+dur;
	indx		= indx(indx>0 & indx<length(sgnindx));
	
	prepProb		= prepTrial(indx);
	
	
	prepProb(prepProb<minprob) = minprob;
	prepProb(isinf(prepProb)) = minprob;
	
	pProb(jj) = nansum(log(prepProb));
	
end
LL = nansum(pProb);
