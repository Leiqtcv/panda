function Akaike_analysis_onsetAligned
% AKAIKE_ANALYSIS
%

% 2013

%% Cleansing
clc;
close all;
clear all;

%% Data stored @

cd('E:\DATA\Cortex\top-down paper data'); % Change this to suit your needs
thorfiles   = dir('thor*');
joefiles    = dir('joe*');
files       = [thorfiles' joefiles'];
dspFlag     = true;
dspFlag     = false;

%% Initialization

sigma		= 70;
dur			= 1000;

analyze(files,sigma);

function analyze(files,sigma)
ncells		= length(files);
sgnindx 	= 800:1300; % this is the index, from 500 ms before reaction, to 100 ms after reaction
LL500       = NaN(ncells,4);
LL1000      = NaN(ncells,4);
LLprep      = NaN(ncells,1);
M500        = NaN(ncells,numel(sgnindx));

M1000       = NaN(ncells,numel(sgnindx));
Nspikes500  = NaN(ncells,1);
Nspikes1000 = NaN(ncells,1);
Ntrials500  = NaN(ncells,1);
Ntrials1000 = NaN(ncells,1);

for ii				 = 1:ncells
    %% Load
    
    fname			 = files(ii).name;
    disp(fname);
    load(fname);

%     spikeA = spikeA;
%     spikeP = spikeP;
%     beh    = beh;
    
    spikeA = spikeAMA;
    spikeP = spikeAMP;
    beh    = behAM;
    
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
    [par500,par1000,parP,isripple]						= getparams(S500,S1000,SP); % the acoustic parameters
    [sdf70A500,sdf70A1000,sdf70P,sdfA500,sdfA1000,sdfP] = getsdf(S500,S1000,SP,sigma); % Spike probability (sdf)
    
	figure(1)
	clf
	subplot(221)
	plot(nanmean(sdfP),'k-','Color',[.7 .7 .7]);
	hold on
	plot(nanmean(sdfA500),'r-','Color',[1 .7 .7]);
	plot(nanmean(sdfA1000),'b-','Color',[.7 .7 1]);

	plot(nanmean(sdf70P),'k-','LineWidth',2);
	plot(nanmean(sdf70A500),'r-','LineWidth',2);
	plot(nanmean(sdf70A1000),'b-','LineWidth',2);
	
	xlabel('Time (ms)');
	ylabel('Probability');

	y = mean([sdfP; sdfA500; sdfA1000]);
	xi = linspace(min(y),max(y),20);
	
	y = mean(sdfP);
	N = hist(y,xi);
	subplot(222)
	h = bar(xi,N,'k');set(h,'FaceColor',[.7 .7 .7]);
	axis square
	
	y = mean(sdfA500);
	N = hist(y,xi);
	subplot(223)
	h = bar(xi,N,'k');set(h,'FaceColor',[.7 .7 .7]);
	axis square

	y = mean(sdfA1000);
	N = hist(y,xi);
	subplot(224)
	h = bar(xi,N,'k');set(h,'FaceColor',[.7 .7 .7]);
	axis square

% 	return
% 	pause
drawnow
	
    %% Determine modulations
    [addMod500,multMod500,passMod500,actSignal500] = getmod(sdf70A500,sdfA500,RT500,par500,sdf70P,sdfP,parP,isripple);
    addMod500	= nanmean(addMod500);
    multMod500	= nanmean(multMod500);
    
    [addMod1000,multMod1000,passMod1000,actSignal1000] = getmod(sdf70A1000,sdfA1000,RT1000,par1000,sdf70P,sdfP,parP,isripple);
    addMod1000	= nanmean(addMod1000);
    multMod1000	= nanmean(multMod1000);
    
    prepMod = addMod500;
    t = 1:length(addMod500); 
    
    %% Determine probabilities
   
    [LL500(ii,:),Nspikes500(ii),Ntrials500(ii)]		= getprob(sdfA500,passMod500,addMod500,multMod500,S500,sgnindx,actSignal500);
    [LL1000(ii,:),Nspikes1000(ii),Ntrials1000(ii)]	= getprob(sdfA1000,passMod1000,addMod1000,multMod1000,S1000,sgnindx,actSignal1000);
    
    LLprep(ii)		                                = geprepprob(sdfA1000,passMod1000,prepMod,S1000,sgnindx);

    M500(ii,:)		                                = addMod500(sgnindx);
    M1000(ii,:)		                                = addMod1000(sgnindx);
    
end
% keyboard

%% Display values
disp('--------------');
getakaike(-2*nansum(LL500(:,1)),-2*nansum(LL500(:,2)),-2*nansum(LL500(:,3)));

disp('--------------');

getakaike(-2*nansum(LL1000(:,1)),-2*nansum(LL1000(:,2)),-2*nansum(LL1000(:,3)));
disp('--------------');

%% Check if values seem correct

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
xlim([0 500]);
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
xlim([0 500]);
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
xlim([0 500]);
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
xlim([0 500]);
title('Averages');
for ii = 1:4
    subplot(2,2,ii)
    xlabel('Time re Bar Release (ms)');
    ylabel('Spike density');
    pa_text(0.1,0.9,char(96+ii));
end
%%

function [sdf70A500,sdf70A1000,sdf70P,sdfA500,sdfA1000,sdfP] = getsdf(S500,S1000,SP,sigma)
[~,sdf70A500]	= pa_spk_sdf(S500,'sigma',sigma);  % The 70-ms smoothed active 500 condition spike density function
[~,sdf70A1000]	= pa_spk_sdf(S1000,'sigma',sigma); % the 70ms smoothed active 1000 condition spike density function
[~,sdf70P]		= pa_spk_sdf(SP,'sigma',sigma);    % the smoothed passive sdf

[~,sdfA500]		= pa_spk_sdf(S500,'sigma',5);      % The 5-ms smoothed active 500 condition spike density function
[~,sdfA1000]	= pa_spk_sdf(S1000,'sigma',5);     % the 5-ms smoothed active 1000 condition spike density function
[~,sdfP]		= pa_spk_sdf(SP,'sigma',5);        % the smoothed passive sdf

mxSize			= min([size(sdfP,2) size(sdfA500,2) size(sdfA1000,2)]);

sdf70P			= sdf70P(:,1:mxSize);
sdf70A500		= sdf70A500(:,1:mxSize);
sdf70A1000		= sdf70A1000(:,1:mxSize);
sdfP			= sdfP(:,1:mxSize);
sdfA500			= sdfA500(:,1:mxSize);
sdfA1000		= sdfA1000(:,1:mxSize);

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
parP	= round(stim(indx,:)*1000)/1000;


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
Di  = AIC-min(AIC)
Lm  = exp(-0.5*Di)
wi  = Lm./sum(Lm)
er  = 1./Lm

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
    actSignal(jj,:)	= sdfA(jj,:);
    
    % Remove responses that are way too fast (-800 ms because you only
    % have 800 ms of data before the modulation), or way too late
    % (after 900 ms).
    if 	RT(jj)>900 || RT(jj)<-800
        addMod(jj,:)	= NaN(size(addMod(jj,:)));
        multMod(jj,:)	= NaN(size(multMod(jj,:)));
        passMod(jj,:)	= NaN(size(passMod(jj,:)));
        actSignal(jj,:) = NaN(size(actSignal(jj,:)));
    end
end


function 	[LL,Nspikes,Ntrials] = getprob(sdfA,passMod,addMod,multMod,S,sgnindx,actSignal)

minprob    = 1e-5;
ntrials	   = size(sdfA,1);
pProb      = NaN(ntrials,3);
Nspikes    = 0;
Ntrials    = 0;

for jj	= 1:ntrials % this analysis is done for every trial in the active condition, which is noisy
    
   
    passTrial	= passMod(jj,sgnindx);
    actTrial	= actSignal(jj,sgnindx);
    
    addTrial	= passTrial+addMod(sgnindx);
    multTrial	= passTrial.*multMod(sgnindx);
    
    indx		= ceil(S(jj).spiketime);
    indx		= indx(indx>800 & indx<800+(length(sgnindx)))-800;
    if isempty(indx)
        indx = 250;
    end
    
    addProb		= addTrial(indx);
    multProb	= multTrial(indx);
    passProb	= passTrial(indx);
    actProb		= actTrial(indx);
    
     
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

function LL = geprepprob(sdfA,passMod,prepMod,S,sgnindx)

minprob	   = 1e-5;
ntrials	   = size(sdfA,1);
pProb      = NaN(ntrials,1);
for jj	   = 1:ntrials % this analysis is done for every trial in the active condition, which is noisy
    passTrial	= passMod(jj,:);
    prepTrial	= passTrial+prepMod;
    
    indx		= ceil(S(jj).spiketime);
    indx		= indx(indx>800 & indx<800+(length(sgnindx)))-800;
    if isempty(indx)
        indx = length(sgnindx);
    end
    prepProb		= prepTrial(indx);
    
    
    prepProb(prepProb<minprob) = minprob;
    prepProb(isinf(prepProb)) = minprob;
    
    pProb(jj) = nansum(log(prepProb));
    
end
LL = nansum(pProb);
