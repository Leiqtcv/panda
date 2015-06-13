function SimpleLinearRegressionJAGS
% SIMPLELINEARREGRESSIONJAGS
%
% Simple linear regression
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij


%% THE MODEL. Robust regression
str = ['model {\r\n',...
	'\tfor( i in 1 : Ndata ) {\r\n',...
	'\t\ty[i] ~ dt(mu[i],tau,tdf)\r\n',...
	'\t\tmu[i] <- beta0 + beta1 * x[i]\r\n',...
	'\t}\r\n',...
	'\tbeta0 ~ dnorm( 0 , 1.0e-12)\r\n',...
	'\tbeta1 ~ dnorm( 0 , 1.0e-12)\r\n',...
	'\ttau ~ dgamma( 0.001 , 0.001 )\r\n',...
	'\tudf ~ dunif(0,1)\r\n',...
	'\ttdf <- 1-tdfGain*log(1-udf)\r\n',...
	'#\ttau ~ dchisq(1)\r\n',...
	'}\r\n',...
	];

% Write the modelString to a file, using Matlab commands:
fid			= fopen('model.txt','w');
fprintf(fid,str);
fclose(fid);

close all
%% THE DATA.

% Simulated height and weight data:
[HtWtData,~,height,weight] = HtWtDataGenerator(30,5678);
nSubj	= size(HtWtData,1);
x		= HtWtData(:,height);
y		= HtWtData(:,weight);
pa_datadir;
load('Data001.mat');
whos
x = Data001(:,1)';
y = Data001(:,2)';
% Re-center data at mean, to reduce autocorrelation in MCMC sampling.
% Standardize (divide by SD) to make initialization easier.
[zx,mux,sdx] = zscore(x);
[zy,muy,sdy] = zscore(y);

% Specify data, as a structure
dataStruct.x		= zx;
dataStruct.y		= zy;
dataStruct.Ndata	= numel(x);
dataStruct.tdfGain = 1;
%% INTIALIZE THE CHAINS.
nChains		= 3;                   % Number of chains to run.
r			= corrcoef(x,y);
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).beta0		= 0;    % because data are standardized
	initsStruct(ii).beta1		= r(2);        % because data are standardized
	initsStruct(ii).tau			= 1/(1-r(2)^2);  % because data are standardized
end

%% RUN THE CHAINS
parameters		= {'beta0' , 'beta1' , 'tau'};		% The parameter(s) to be monitored.
% adaptSteps		= 500;			% Number of steps to 'tune' the samplers.
burnInSteps		= 500;			% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 5000;		% Total number of steps in chains to save.
thinSteps		= 10;			% Number of steps to 'thin' (1=keep every step).
nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
doparallel		= 0; % do not use parallelization

fprintf( 'Running JAGS...\n' );
% [samples, stats, structArray] = matjags( ...
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

%% EXAMINE THE RESULTS
checkConvergence = true;
if checkConvergence
	fnames = fieldnames(samples);
	n = numel(fnames)-1;
	for ii = 1:n
		% thetaSample = reshape(mcmcChain,[numSavedSteps+1 nCoins]);
		ns = ceil(sqrt(n));
		figure(1)
		subplot(ns,ns,ii)
		s		= samples.(fnames{ii});
		s		= s(1:16667);
		s		= zscore(s);
		maxlag	= 35;
		[c,l]	= xcorr(s,maxlag,'coeff');
		h		= stem(l(maxlag:end),c(maxlag:end),'k-');
		xlim([-1 maxlag]);
		set(h,'MarkerEdgeColor','none');
		axis square;
		box off
		set(gca,'TickDir','out');
		str = fnames{ii};
		xlabel('Lag');
		ylabel('Autocorrelation');
		title(str);
		%   show( gelman.diag( codaSamples ) )
		%   effectiveChainLength = effectiveSize( codaSamples )
		%   show( effectiveChainLength )
	end
end

%% Extract chain values:
z0		= [samples.beta0];
z1		= [samples.beta1];
zTau	= [samples.tau];
z0		= z0(:);
z1		= z1(:);
zTau	= zTau(:);
zSigma	= 1./zTau;

% Convert to original scale:
b1		= z1*sdy/sdx;
b0		= z0*sdy+muy-z1*sdy*mux/sdx;
sigma	= zSigma*sdy;
%
% Posterior prediction:
% Specify x values for which predicted y's are needed:
xPostPred		= -1:4;
% Define matrix for recording posterior predicted y values at each x value.
% One row per x value, with each row holding random predicted y values.
postSampSize	= length(b1);
yPostPred		= NaN(length(xPostPred),postSampSize);
% Define matrix for recording HDI limits of posterior predicted y values:
yHDIlim			= NaN(length(xPostPred),2);

% Generate posterior predicted y values.
% This gets only one y value, at each x, for each step in the chain.
for chainIdx = 1:postSampSize
	mu	= b0(chainIdx) + b1(chainIdx)*xPostPred;
	sd		= sigma(chainIdx);
	yPostPred(:,chainIdx) = mu+sd*randn(size(xPostPred));
end

for xIdx = 1:length(xPostPred)
    yHDIlim(xIdx,:) = HDIofMCMC(yPostPred(xIdx,:));
end

% Display believable beta0 and b1 values
thinIdx = round(linspace(1,length(b0),700));
figure;
subplot(121)
plot( z1(thinIdx),z0(thinIdx),'o','MarkerFaceColor','w','MarkerEdgeColor',[.7 .7 1]);
      ylabel('Standardized Intercept');
	  xlabel('Standardized Slope');
axis square;
set(gca,'TickDir','out');
box off;

subplot(122)
plot( b1(thinIdx),b0(thinIdx),'.','Color',[.7 .7 1]);
      ylabel('Intercept (ht when wt=0)');
	  xlabel('Slope (pounds per inch)');
axis square;
set(gca,'TickDir','out');
box off;

% Display the posterior of the b1:
figure
subplot(121)
plotPost(z1,'xlab','Standardized slope','compVal',0);
subplot(122)
plotPost(b1,'xlab','Slope','compVal',0);

%% Display data with believable regression lines and posterior predictions.
% Plot data values:
xRang		= max(x)-min(x);
yRang		= max(y)-min(y);
limMult		= 0.25;
xL		= [min(x)-limMult*xRang , max(x)+limMult*xRang];
yL		= [min(y)-limMult*yRang , max(y)+limMult*yRang];
figure
plot(x,y,'ko','MarkerFaceColor','w','LineWidth',2);
xlim(xL);
ylim(yL);
xlabel('X (height in inches)');
ylabel('Y (weight in pounds)');
title('Data with credible regression lines');
axis square
box off
set(gca,'TickDir','out');
% Superimpose a smattering of believable regression lines:
for ii =  round(linspace(1,length(b0),50))
	beta = [b0(ii) b1(ii)];
	h = pa_regline(beta','k-');
	set(h,'Color',[.7 .7 1]);
end

% Display data with HDIs of posterior predictions.
% Plot data values:
figure
yL = [min(yHDIlim(:)) , max(yHDIlim(:))];
plot(x,y,'ko','MarkerFaceColor','w','LineWidth',2);
ylim(yL);
xlabel('X (height in inches)');
ylabel('Y (weight in pounds)');
title('Data with 95% HDI & Mean of Posterior Predictions');
axis square
box off
set(gca,'TickDir','out');
% Superimpose posterior predicted 95% HDIs:
hold on

line([xPostPred; xPostPred],yHDIlim','Color',[.7 .7 1],'LineWidth',2);
plot(xPostPred,mean(yPostPred,2),'+','Color',[.7 .7 1],'LineWidth',2);

