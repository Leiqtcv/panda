function pet_multilogregress_all
% Multiple logistic regression
%
% 2013) Marc M. van Wanrooij

close all

%% The JAGS model
str = ['model {\r\n',...
	'#Logistic regression\r\n',...
	'\tfor(i in 1:nData) {\r\n',...
	'\t\ty[i] ~ dbin(mu[i],n[i])\r\n',...
	'\t\tmu[i] <- 1/(1+exp(-(b0[cond[i]]+inprod(b[,cond[i]],x[i,]))))\r\n',...
	'\t}\r\n',...
	'\t#priors on betas\r\n',...
	'\tfor (condIdx in 1:nCond) {\r\n',...
	'\t\tb0[condIdx] ~ dnorm(mub0,taub0[condIdx])\r\n',...
	'\t\ttaub0[condIdx] ~ dchisqr(S0)\r\n',...
	'\t\tfor (j in 1:nPredictors) {\r\n',...
	'\t\t\tb[j,condIdx] ~ dnorm(mub[j],taub[j,condIdx])\r\n',...
	'\t\t\ttaub[j,condIdx] ~ dchisqr(S[j])\r\n',...
	'\t\t}\r\n',...
	'\t}\r\n',...
	'#Hyperpriors\r\n',...
	'\tS0   ~ dunif(0.01,2)\r\n',...
	'\tmub0 ~ dnorm(0,gamma0)\r\n',...
	'\tgamma0 ~ dchisqr(1)\r\n',...
	'\tfor (j in 1:nPredictors) {\r\n',...
	'\tS[j]  ~ dunif(0.01,2)\r\n',...
	'\t\tmub[j] ~ dnorm(0,bgamma[j])\r\n',...
	'\tbgamma[j] ~ dchisqr(1)\r\n',...
	'\t}\r\n',...
	'#Missing values\r\n',...
	'\tfor(i in 1:nData) {\r\n',...
	'\t\tfor (j in 1:nPredictors) {\r\n',...
	'\t\t\tx[i,j] ~ dnorm(mux[j],taux)\r\n',...
	'\t\t}\r\n',...
	'\t}\r\n',...
	'\t#Vague priors on missing predictors,\r\n',...
	'\t#assuming predictor variances are equal\r\n',...
	'\ttaux ~ dgamma(0.001,0.001)\r\n',...
	'\tfor (j in 1:nPredictors) {\r\n',...
	'\t\tmux[j] ~ dnorm(0,1.0E-12)\r\n',...
	'\t}\r\n',...
	'}\r\n',...
	];
fid			= fopen('model.txt','w');
fprintf(fid,str);
fclose(fid);
% return
%% The data
nArea = 3;
for areaIndx = 1:nArea
	[x,y,N,cond,nData,nCond,nPredictors,predictorNames] = getdata(areaIndx);
	
	figure(666)
	mrk		= ['o','s','d'];
	col		= ['k','r','b'];
	selMissing	= isnan(x(:,1)) | isnan(x(:,2));
	
	for ii	= 1:nPredictors
		subplot(2,3,areaIndx)
		plot(x(~selMissing,ii),100*y(~selMissing)./N(~selMissing),['k' mrk(ii)],'MarkerFaceColor',col(ii),'MarkerEdgeColor','k');
		hold on
		coef	= glmfit(x(~selMissing,ii),[y(~selMissing) N(~selMissing)],'binomial','link','logit');
		xi		= linspace(90,130,100)';
		yfit	= glmval(coef, xi,'logit','size',3*12);
		plot(xi,100*yfit/(3*12),'LineWidth',2,'Color',col(ii));
	end
	box off;
	set(gca,'TickDir','out');
	ylim([-0.1 1.1]*100);
% 	xlim([90 130]);
	title(predictorNames{ii})
	xlabel('FDG (%)');
	ylabel('Phoneme Score (%)');
	pa_horline([0 100]);
	
	
	%% Run the model
	[samples,Mx,SDx,nChains,nIter]		= runmodel(x,y,N,cond,nData,nCond,nPredictors);
	%% Extract chain values
	for condIdx = 1:nCond
		% 		zb0Sample	= reshape(samples.b0,nChains*nIter,nCond);
		% 		zb0Sample	= squeeze(zb0Sample(:,:,condIdx));
		zbSample	= reshape(samples.b,nChains*nIter,nPredictors,nCond);
		zbSample	= squeeze(zbSample(:,:,condIdx));
		whos zbSample
		% Convert to original scale:
		% 		a			= bsxfun(@times,zbSample,Mx./SDx);
		% 		b0Sample	= zb0Sample-sum(a,2);
		bSample		= bsxfun(@rdivide,zbSample,SDx);
		
		figure(1+condIdx*100)
		subplot(1,3,areaIndx)
		plot(bSample(1:100:end,1),bSample(1:100:end,2),'.','Color','r');
		hold on
		plot(bSample(1:100:end,1),bSample(1:100:end,3),'.','Color','b');
		xlim([-2 2]);
		ylim([-2 2]);
		box off
		set(gca,'TickDir','out');
		xlabel('\beta_{Rest}');
		ylabel('\beta_{video}');
		pa_horline(0,'k:');
		pa_verline(0,'k:');
		pa_revline('k:');
		axis square;
		set(gca,'Xtick',-2:0.5:2,'YTick',-2:0.5:2);
		
		figure(2+condIdx*100)
		subplot(1,3,areaIndx)
		plotPost(bSample(:,1),'compVal',0);
		hold on
		xlim([-2 2]);
		ylim([-2 2]);
		box off
		set(gca,'TickDir','out');
		xlabel('\beta_{Rest}');
		ylabel('\beta_{video}');
		pa_horline(0,'k:');
		pa_verline(0,'k:');
		pa_revline('k:');
		axis square;
		set(gca,'Xtick',-2:0.5:2,'YTick',-2:0.5:2);
		
		figure(3+condIdx*100)
		subplot(1,3,areaIndx)
		plotPost(bSample(:,2),'compVal',0);
		hold on
		xlim([-2 2]);
		ylim([-2 2]);
		box off
		set(gca,'TickDir','out');
		xlabel('\beta_{Rest}');
		ylabel('\beta_{video}');
		pa_horline(0,'k:');
		pa_verline(0,'k:');
		pa_revline('k:');
		axis square;
		set(gca,'Xtick',-2:0.5:2,'YTick',-2:0.5:2);
		
		figure(4+condIdx*100)
		subplot(1,3,areaIndx)
		plotPost(bSample(:,3),'compVal',0);
		hold on
		xlim([-2 2]);
		ylim([-2 2]);
		box off
		set(gca,'TickDir','out');
		xlabel('\beta_{Rest}');
		ylabel('\beta_{video}');
		pa_horline(0,'k:');
		pa_verline(0,'k:');
		pa_revline('k:');
		axis square;
		set(gca,'Xtick',-2:0.5:2,'YTick',-2:0.5:2);
		
	end
end

function [postSummary,histInfo] = plotPost(paramSampleVec, varargin)
% PLOTPOST(P)
%
% plot MCMC parameter sample vector P
%
% POSTSUMMARY = PLOTPOST(P)
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

%% Check arguments
% At least this is better in R
% Override defaults of hist function, if not specified by user
if nargin<1
	paramSampleVec = 1;
end
credMass	= pa_keyval('credMass', varargin); if isempty(credMass), credMass = 0.95; end;
showMode	= pa_keyval('showMode', varargin); if isempty(showMode), showMode = false; end;
showCurve	= pa_keyval('showCurve', varargin); if isempty(showCurve), showCurve = false; end;
compVal		= pa_keyval('compVal', varargin);
ROPE		= pa_keyval('ROPE', varargin);
yaxt		= pa_keyval('yaxt', varargin);
ylab		= pa_keyval('ylab', varargin);
xlab		= pa_keyval('xlab', varargin); if isempty(xlab), xlab = 'Parameter'; end;
xl			= pa_keyval('xlim', varargin); if isempty(xl), xl = minmax([compVal; paramSampleVec]'); end;
main		= pa_keyval('main', varargin);
col			= pa_keyval('col', varargin); if isempty(col), col = [.7 .7 .7]; end;
breaks		= pa_keyval('breaks', varargin);
% HDItextPlace = pa_keyval('HDItextPlace', varargin); if isempty(HDItextPlace), HDItextPlace = 0.7; end;
% border		= pa_keyval('border', varargin); if isempty(border), border='w'; end;

%% Determine interesting parameters
postSummary.mean	= mean(paramSampleVec);
postSummary.median	= median(paramSampleVec);
[mcmcDensity.y,mcmcDensity.x] = ksdensity(paramSampleVec);
[~,indx]			= max(mcmcDensity.y);
postSummary.mode	= mcmcDensity.x(indx);
HDI					= HDIofMCMC(paramSampleVec,credMass);
postSummary.hdiMass = credMass;
postSummary.hdiLow	= HDI(1);
postSummary.hdiHigh	= HDI(2);

%% Plot histogram.
hold on
if isempty(breaks)
	by=(HDI(2)-HDI(1))/18;
	breaks = unique([min(paramSampleVec):by:max(paramSampleVec) max(paramSampleVec)]);
	breaks = linspace(-2,2,100);
end

N					= histc(paramSampleVec,breaks);
db					= mean(diff(breaks));
histInfo.N			= N;
histInfo.density	= 0.25*N./db/sum(N);
if ~showCurve
	h = bar(breaks,histInfo.density,'style','histc');
	delete(findobj('marker','*')); % Matlab bug?
	set(h,'FaceColor',col,'EdgeColor','w');
end
if showCurve
	[densCurve.y,densCurve.x] = ksdensity(paramSampleVec);
	h = plot(densCurve.x, densCurve.y,'b-');
	set(h,'Color',col,'LineWidth',2);
end
xlabel(xlab);
ylabel(ylab);
box off
xlim(xl);
title(main);

cenTendHt	= 0.9*nanmax(histInfo.density);
cvHt		= 0.7*nanmax(histInfo.density);
ROPEtextHt	= 0.55*nanmax(histInfo.density);

% Display mean or mode:
if ~showMode
	str			= ['mean = ' num2str(postSummary.mean,'%g')];
	text(postSummary.mean,cenTendHt,str,'HorizontalAlignment','center');
else
	[~,indx]	= max(mcmcDensity.y);
	modeParam	= mcmcDensity.x(indx);
	str			= ['mode = ' num2str(postSummary.mode,'%g')];
	text(modeParam, cenTendHt, str,'HorizontalAlignment','center');
end

%% Display the comparison value.
if ~isempty(compVal)
	cvCol = [0 .3 0];
	pcgtCompVal = round(100*sum(paramSampleVec>compVal)/length(paramSampleVec)); % percentage greater than
	pcltCompVal = 100 - pcgtCompVal; % percentage lower than
	plot([compVal compVal],[0.96*cvHt 0],'k-','Color',cvCol,'LineWidth',2);
	str = [num2str(pcltCompVal) '% < ' num2str(compVal,3) ' < ' num2str(pcgtCompVal) '%'];
	text(compVal,cvHt,str,'HorizontalAlignment','center','Color',cvCol);
	postSummary.compVal = compVal;
	postSummary.pcGTcompVal = sum(paramSampleVec>compVal)/length(paramSampleVec);
end
%% Display the ROPE.
if ~isempty(ROPE)
	ropeCol = [.5 0 0];
	pcInROPE = sum(paramSampleVec>ROPE(1) & paramSampleVec<ROPE(2))/length(paramSampleVec);
	plot(ROPE([1 1]),[0 0.96*ROPEtextHt],':','LineWidth',2,'Color',ropeCol);
	plot(ROPE([2 2]),[0 0.96*ROPEtextHt],':','LineWidth',2,'Color',ropeCol);
	
	str = [num2str(round(100*pcInROPE)) '% in ROPE'];
	text(mean(ROPE),ROPEtextHt,str,'Color',ropeCol,'HorizontalAlignment','center');
	
	postSummary.ROPElow		= ROPE(1);
	postSummary.ROPEhigh	= ROPE(2);
	postSummary.pcInROPE	= pcInROPE;
end
%% Additional stuff: To make Matlab figure look more like R figure
ax		= axis;
yl		= ax([3 4]);
ydiff	= yl(2)-yl(1);
yl		= [yl(1)-ydiff/20 yl(2)];
ylim(yl);
set(gca,'TickDir','out');
axis square;

%% Display the HDI.
plot(HDI,[0 0],'k-','LineWidth',4);
str = [num2str(100*credMass,'%g') '% HDI'];
text(mean(HDI),ydiff/20+ydiff/20,str,'HorizontalAlignment','center');
str = num2str(HDI(1),'%g');
text(HDI(1),ydiff/20,str,'HorizontalAlignment','center');
str = num2str(HDI(2),'%g');
text(HDI(2),ydiff/20,str,'HorizontalAlignment','center');

function [x,y,N,cond,nData,nCond,nPredictors,predictorNames,predictedName] = getdata(areaIndx)
% Load
fname = 'C:\MATLAB\PandA\DoingBayesianDataAnalysis\petdata.mat';
if exist(fname,'file')
	load(fname)
else
	load('E:\DATA\petdata')
end
data

area	= areaIndx;

% pre		= [DAT(area).Dprerest DAT(area).Dprevideo DAT(area).Dprevideo];
% nh		= [DAT(area).DNHrest DAT(area).DNHvideo DAT(area).DNHav];
% post	= [DAT(area).Dpostrest DAT(area).Dpostvideo  DAT(area).Dpostav];
% F		= DAT(area).Fpost;
% Fnh		= DAT(area).FNH;
% 
% x	= [pre;post;nh];
% y	= [F;F;Fnh];
a = data.FDGrest;
b = data.FDGvideo;
c = data.FDGav;
d = data.group;
f = data.Phoneme
x = [a b c];
y = f;
whos x y
cond = d;
nCond	= numel(unique(cond));


y	= round((y/100*3*12));
N	= repmat(3*12,size(y));

[nData,nPredictors]	= size(x)
predictorNames = {'Rest','Video','AV'};
predictedName = 'Phoneme Score';

function [samples,Mx,SDx,nChains,nIter] = runmodel(x,y,N,cond,nData,nCond,nPredictors)
% Re-center data at mean, to reduce autocorrelation in MCMC sampling.
% Standardize (divide by SD) to make initialization easier.
zx		= NaN(size(x));
Mx		= NaN(1,nPredictors);
SDx		= Mx;
for predIndx = 1:nPredictors
	selMissing = isnan(x(:,predIndx));
	[zxt,Mxt,SDxt]				= zscore(x(~selMissing,predIndx));
	
	zx(~selMissing,predIndx) = zxt;
	Mx(predIndx) = Mxt;
	SDx(predIndx) = SDxt;
	
end
zy						= y; % y is not standardized; must be 0,1
dataStruct.x			= zx;
dataStruct.y			= zy; % BUGS does not treat 1-column mat as vector
dataStruct.n			= N;
dataStruct.nPredictors	= nPredictors;
dataStruct.nData		= nData;
dataStruct.cond			= cond;
dataStruct.nCond		= nCond;

%% Initialize the chains
b0Init = NaN(1,nCond);
bInit = NaN(nPredictors,nCond);
% 	selMissing	= isnan(x(:,1)) | isnan(x(:,2));
% 	
% 	for ii	= 1:nPredictors
% 		subplot(2,3,areaIndx)
% 		plot(x(~selMissing,ii),100*y(~selMissing)./N(~selMissing),['k' mrk(ii)],'MarkerFaceColor',col(ii),'MarkerEdgeColor','k');
% 		hold on
% 		coef	= glmfit(x(~selMissing,ii),[y(~selMissing) N(~selMissing)],'binomial','link','logit');
% 		xi		= linspace(90,130,100)';
% 		yfit	= glmval(coef, xi,'logit','size',3*12);
% 		
% keyboard
for condIdx = 1:nCond
	sel = cond==condIdx ;
	xtmp = zx(sel,:)
	ytmp = [zy(sel) N(sel)]

	sel = isnan(xtmp(:,1)) | isnan(xtmp(:,2));
	xtmp = xtmp(~sel,:);
	ytmp = ytmp(~sel,:);
	whos xtmp
	if condIdx==1
	b				= glmfit(xtmp(:,1:2),ytmp,'binomial','link','logit');
	indx = (1:nPredictors-1)+1;
	bInit(:,condIdx)		= [b(indx); b(nPredictors-1)];
	else
	b				= glmfit(xtmp,ytmp,'binomial','link','logit');
	indx = (1:nPredictors)+1;
	bInit(:,condIdx)		= b(indx);
	end
	b0Init(condIdx)			= b(1);
end
nChains			= 3;                   % Number of chains to run.
initsStruct		= struct([]);
for ii = 1:nChains
	initsStruct(ii).b0 = b0Init;
	initsStruct(ii).b = bInit;
end

%% Run the chains
parameters		= {'b0','b','x','taub','taub0'};		% The parameter(s) to be monitored.
% adaptSteps		= 1000;			% Number of steps to 'tune' the samplers.
burnInSteps		= 2000;			% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 50000;		% Total number of steps in chains to save.
thinSteps		= 1;			% Number of steps to 'thin' (1=keep every step).
nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
doparallel		= 0; % do not use parallelization
fprintf( 'Running JAGS...\n' );
samples = matjags( ...
	dataStruct, ...                     % Observed data
	fullfile(pwd, 'model.txt'), ...    % File that contains model definition
	initsStruct, ...                          % Initial values for latent variables
	'doparallel' , doparallel, ...      % Parallelization flag
	'nchains', nChains,...              % Number of MCMC chains
	'nburnin', burnInSteps,...              % Number of burnin steps
	'nsamples', nIter, ...           % Number of samples to extract
	'thin', thinSteps, ...                      % Thinning parameter
	'dic', 1, ...                       % Do the DIC?
	'monitorparams', parameters, ...     % List of latent variables to monitor
	'savejagsoutput' , 1 , ...          % Save command line output produced by JAGS?
	'verbosity' , 1 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
	'cleanup' , 0 );                    % clean up of temporary files?
