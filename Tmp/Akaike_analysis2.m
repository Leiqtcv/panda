function Akaike_analysis
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
dur			= 500;

analyze(files,sigma,dur,dspFlag);

function analyze(files,sigma,dur,dspFlag)
ncells		= length(files);
ADDMOD		= NaN(ncells,300+dur+100);
MULTMOD		= ADDMOD;
sgnindx		= (-500:100)+300+dur; % this is the index, from 500 ms before reaction, to 100 ms after reaction

addAIC		= 0;
multAIC		= 0;
passAIC		= 0;
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
	[Spike,RT]		= seldur(spikeA,beh,dur);
	
	%% Analyze
	% We will subtract the passive response from the active condition
	% this will presumably remove the acoustic component (if not, we will
	% see some acoustic modulations left). We will do this for every trial
	% in the active condition with the firing rate from the passive
	% condition averaged. For reasons, that will be explained below, we
	% do this removal with heavily smoothed spike density functions.
	
	[Asdf70,Psdf70,Psdf,Asdf] = getsdf(Spike,spikeP,sigma);
	[AVel,ADens,PVel,PDens] = getparams(Spike,spikeP);
	
	%% Determine modulations
	% relative to the passive signal
	ntrials			= size(Asdf,1);
	addMod			= NaN(size(Asdf70)); % Mod = modulation, add = additive model
	multMod			= addMod; % mult = multiplicative model
	passMod			= addMod; % pass = passive model
	% 	prepMod			= addMod; % preparatory model without prediction, only for the additive model
	actSignal		= addMod; % actual signal
	Pmu = addMod;
	A = addMod;
	for jj	= 1:ntrials % this analysis is done for every trial in the active condition, which is noisy
		sel = PVel == AVel(jj) & PDens == ADens(jj);
		sdf = 
		mu = circshift(mean(Psdf(sel,:)),-RT(jj)); % and we mean the data for the passive trials, to remove some of the variability
		Pmu(jj,:) = mu;
		
		mu = circshift(Asdf(jj,:),-RT(jj));
		A(jj,:) = mu;
	end
	
	X = Pmu(:,sgnindx);
	Y = A(:,sgnindx);
	indx = 1:100:601;
	X = X(:,indx);
	Y = Y(:,indx);
	
	for jj = 1:numel(indx)
		x = X(:,jj);
		y = Y(:,jj);
		b = regstats(y,x,'linear','beta');
		str  = ['Y = ' num2str(b.beta(2),2) ' X + ' num2str(b.beta(1),2)];
		figure(1)
		
		subplot(3,3,jj)
		cla
	plot(x,y,'.');
	
	lsline
	unityline
	axis square
	title(str);
	G(jj) = b.beta(2);
	
	B(jj) = b.beta(1);
	end
	subplot(3,3,8)
	cla;
	plot(indx,G);
	pa_horline(1);
	
	subplot(3,3,9)
	cla;
	plot(indx,B);
	pa_horline(0);
	pause(.5);
	drawnow
	continue
% 	addMod = b.*
	for jj = 1:ntrials
		%% modulations
		addMod(jj,:)	= Asdf70(jj,:)-Pmu;
		multMod(jj,:)	= Asdf70(jj,:)./Pmu;
		
		%% Passive prediction
		Pmu				= mean(Psdf(sel,:)); % for the small sigma
		passMod(jj,:)	= Pmu; % Passive model
		
		%% align to reaction time
		% this is done by a circular shift by an amount of RT samples
		% RT = 0 -> sample 800 for 500 conditions
		% -> sample 1300 for 1000 conditions
		addMod(jj,:)	= circshift(addMod(jj,:)',-RT(jj));
		multMod(jj,:)	= circshift(multMod(jj,:)',-RT(jj));
		
		passMod(jj,:)	= circshift(passMod(jj,:)',-RT(jj));
		actSignal(jj,:)	= circshift(Asdf(jj,:)',-RT(jj));
		
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
	
	if dspFlag
		Amu				= mean(Asdf);
		Pmu = mean(Psdf);
		Rmu = mean(RT(RT<700& RT>-800));
		
		figure(1)
		
		subplot(221)
		cla
		plot(Pmu,'k-');
		hold on
		plot(Amu,'r-');
		xlabel('Time re trial onset (ms)');
		ylabel('Additive modulation (Hz)');
		str = ['Cell: ' fname];
		title(str);
		pa_verline([300 300+dur 300+dur+1000]);
		h = pa_verline(Rmu+dur+300,'k-');set(h,'LineWidth',2);
		
		t = (1:length(addMod))+ Rmu;
		plot(t,nanmean(addMod)+nanmean(Pmu),'k-','LineWidth',2);
		
		subplot(223)
		cla;
		% 		plot(addMod','k-','Color',[.7 .7 .7]);
		hold on
		plot(nanmean(addMod),'k-','LineWidth',2);
		pre = addMod(:,1:500);
		pa_horline(nanstd(pre(:)),'r-');
		pa_verline(300+dur);
		% 		ylim([-30 80]);
		xlim([0+dur-500 900+dur-500])
		xlabel('Time re reaction (ms)');
		ylabel('Additive modulation (Hz)');
		str = ['Cell: ' fname];
		title(str);
		
		subplot(224)
		cla;
		% 		plot(multMod','k-','Color',[.7 .7 .7]);
		hold on
		plot(nanmean(multMod),'k-','LineWidth',2);
		pre = multMod(:,1:500);
		pa_horline(nanstd(pre(:)),'r-');
		pa_verline(300+dur);
		% 		ylim([0 ]);
		xlim([0+dur-500 900+dur-500])
		xlabel('Time re reaction (ms)');
		ylabel('Multiplicative modulation (Hz)');
		
		drawnow
		% 		pause;
	end
	
	%% Average  modulation per cell
	mu		=  nanmean(addMod);
	ADDMOD(ii,sgnindx) = mu(sgnindx);
	mu		=  nanmean(multMod);
	MULTMOD(ii,sgnindx) = mu(sgnindx);
	
	
	%% Variation in the passive response
	% We will use this variation as the model variation in the active
	% response. So, we assume that the top-down modulation does not
	% change during
	PVD		= [PVel' PDens'];
	uPVD	= unique(PVD,'rows');
	nPVD	= size(uPVD,1);
	passVar	= NaN(size(Psdf));
	for jj = 1:nPVD
		sel		= uPVD(jj,1) == PVel & uPVD(jj,2) == PDens;
		cTrial	= Psdf(sel,:);
		Pmu		= mean(cTrial);
		
		err		= bsxfun(@minus,cTrial,Pmu);
		% 		if dspFlag
		% 			figure(2)
		% 			subplot(221)
		% 			cla
		% 			plot(cTrial')
		% 			hold on
		% 			plot(Pmu,'k-','LineWidth',2);
		% 			subplot(222)
		% 			hist(err(:));
		% 			drawnow
		% 		end
		passVar(sel,:) = err;
	end
	passVar = passVar(:,1:800);
	% 	f = f./sum(f);
	if dspFlag
		[f,xi]	= ksdensity(passVar(:));
		subplot(223);
		plot(xi,f,'k-');
	end
	
	%% Prediction of the models
	addPred = passMod+addMod;
	addErr = actSignal - addPred;
	addErr = addErr(:,sgnindx);
	
	multPred = passMod.*multMod;
	multErr = actSignal - multPred;
	multErr = multErr(:,sgnindx);
	
	passErr = actSignal-passMod;
	passErr = passErr(:,sgnindx);
	% 	if dspFlag
	%
	% 		[f,xi]	= ksdensity(addErr(:));
	% 		% 	f = f./sum(f);
	% 		subplot(223);
	% 		hold on
	% 		plot(xi,f,'r-');
	%
	% 		[f,xi]	= ksdensity(multErr(:));
	% 		subplot(223);
	% 		hold on
	% 		plot(xi,f,'b-');
	%
	% 		pause
	% 	end
	
	%% Likelihood of the data given the model
	indx	= 1:100:600;
	addLL	= getloglikelihood(addErr(:,indx),passVar(:,indx));
	multLL	= getloglikelihood(multErr(:,indx),passVar(:,indx));
	passLL	= getloglikelihood(passErr(:,indx),passVar(:,indx));
	
	getakaike(-2*addLL,-2*multLL,-2*passLL);
	
	addAIC = addAIC-2*addLL;
	multAIC = multAIC-2*multLL;
	passAIC = passAIC-2*passLL;
end
getakaike(addAIC, multAIC, passAIC)
AIC = [addAIC multAIC passAIC]
Di = AIC-min(AIC)
Lm = exp(-0.5*Di)
wi = Lm./sum(Lm)
er = 1./Lm

% return
% keyboard

%%
% figure(666)
% clf
% subplot(121)
% mu	= nanmedian(ADDMOD(:,200:400),2);
% f	= bsxfun(@minus,ADDMOD,mu);
% plot(f','Color',[.7 .7 .7]);
% hold on
% plot(nanmean(f),'k-','LineWidth',2);
% xlim([200 900]);
% pa_verline(300+dur);
% ylim([-5 10]);
%
% subplot(122)
% mu	= nanmedian(MULTMOD(:,200:400),2);
% f	= bsxfun(@minus,MULTMOD,mu)+1;
% plot(f','Color',[.7 .7 .7]);
% hold on
% plot(nanmedian(f),'k-','LineWidth',2);
% xlim([200 900]);
% ylim([0.75 1.5])
% pa_verline(300+dur);

function [Asdf70,Psdf70,Psdf,Asdf] = getsdf(Spike,spikeP,sigma)
[~,Asdf70]	= pa_spk_sdf(Spike,'Fs',1000,'sigma',sigma); % The smoothed active condition spike density function
[~,Psdf70]	= pa_spk_sdf(spikeP,'Fs',1000,'sigma',sigma); % the smoothed passive sdf

[~,Psdf]	= pa_spk_sdf(spikeP,'Fs',1000,'sigma',20);   % passive response with sigma = 5
[~,Asdf]	= pa_spk_sdf(Spike,'Fs',1000,'sigma',20);           % A500 response with sigma = 5

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

function [AIC,Di,Lm,wi,er] = getakaike(addAIC, multAIC, passAIC)
AIC = [addAIC multAIC passAIC];
Di = AIC-min(AIC);
Lm = exp(-0.5*Di);
wi = Lm./sum(Lm);
er = 1./Lm;

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