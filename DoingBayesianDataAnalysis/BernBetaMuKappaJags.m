function BernBetaMuKappaJags
% BERNBETAKAPPUMUJAGS
%
% Bernouilli likelihood with hierarchical prior
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

%% Clean
close all hidden
clear all hidden
clc

%% THE MODEL.
% Specify the model in JAGS language, but save it as a string in R:
str = ['# JAGS model specification begins ...\r\n',...
	'model {\r\n',...
	'\t# Likelihood:\r\n',...
	'\tfor ( t in 1:nTrialTotal ) {\r\n',...
	'\t\t y[t] ~ dbern( theta[ coin[ t ] ] )\r\n',...
	'\t}\r\n',...
	'\t# Prior:\r\n',...
	'\tfor ( j in 1:nCoins ) {\r\n',...
	'\t\t theta[j] ~ dbeta( a , b )T(0.001,0.999)\r\n',...
	'\t}\r\n',...
	'\ta <- mu * kappa\r\n',...
	'\tb <- ( 1.0 - mu ) * kappa\r\n',...
	'\tmu ~ dbeta( Amu , Bmu )\r\n',...
	'\tkappa ~ dgamma( Skappa , Rkappa )\r\n',...
	'\tAmu <- 2.0\r\n',...
	'\tBmu <- 2.0\r\n',...
	'\tSkappa <- pow(10,2)/pow(10,2)\r\n',...
	'\tRkappa <- 10/pow(10,2)\r\n',...
	'}\r\n',...
	'# ... JAGS model specification ends.\r\n'];

% Write the modelString to a file, using Matlab commands:
fid			= fopen('model.txt','w');
fprintf(fid,str);
fclose(fid);

%% THE DATA.
% % Exercise 9.1, Comment if not used
% ncoins			= 5; 
% nflipspercoin	= 50;
% muAct			= .7; 
% kappaAct		= 20;
% thetaAct		= betarnd(muAct*kappaAct,(1-muAct)*kappaAct,[ncoins 1]);
% N				= repmat(nflipspercoin,[ncoins 1]);
% z				= binornd(N,thetaAct);

% Demo data for various figures in the book:
% N =  [5, 5, 5, 5, 5]; % [10, 10, 10];  % [15, 5];
% z =  [1, 1, 1, 1, 5]; % [1,  5,  9];  % [3, 4];

% Therapeutic touch data:
 z = [1,2,3,3,3,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5,5,5,6,6,7,7,7,8];
 N = repmat(10,size(z));
% Convert z,N to vectors of individual flips.
% coin vector is index of coin for each flip.
% y vector is head or tail for each flip.
% For example,
%  coin = [1, 1, 2, 2, 2];
%  y    = [1, 0, 0, 0, 1]
% means that the first flip was of coin 1 and it was a head, the second flip
% was of coin 1 and it was a tail, the third flip was of coin 2 and it was a
% tail, etc.


coin	= [];
y		= [];
for coinIdx = 1:length(N)
	coin	= [coin, repmat(coinIdx,[1 N(coinIdx)])]; %#ok<*AGROW>
	y		= [y, ones([1 z(coinIdx)]), zeros([1 N(coinIdx)-z(coinIdx)]) ];
end
nTrialTotal = length(y);
nCoins		= length(unique(coin));

% close all
% plot(N,'.')
% return

%%
dataStruct.y			= y;
dataStruct.coin			= coin;
dataStruct.nTrialTotal	= nTrialTotal;
dataStruct.nCoins		= nCoins;


%% INTIALIZE THE CHAIN.
%
% Can be done automatically in jags.model() by commenting out inits argument.
% But not so in matlab & matjags
nChains			= 3;			% Number of chains to run.
initStruct		= struct([]);
for ii = 1:nChains
	thetaguess				= repmat(sum([dataStruct.y])/length([dataStruct.y]),[1 nCoins]); % Notice the dimensions!
	% 	thetaguess = 0.7;
	initStruct(ii).theta	= thetaguess;
end

%% RUN THE CHAINS.
parameters		= {'mu','kappa','theta'};		% The parameter(s) to be monitored.
% adaptSteps		= 1000;			% Number of steps to 'tune' the samplers.
burnInSteps		= 5000;			% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 50000;		% Total number of steps in chains to save.
thinSteps		= 1;			% Number of steps to 'thin' (1=keep every step).
nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
doparallel		= 0; % do not use parallelization

fprintf( 'Running JAGS...\n' );
% [samples, stats, structArray] = matjags( ...
[samples,stats] = matjags( ...
	dataStruct, ...                     % Observed data
	fullfile(pwd, 'model.txt'), ...    % File that contains model definition
	initStruct, ...                          % Initial values for latent variables
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

%% EXAMINE THE RESULTS.

% checkConvergence = true;
checkConvergence = false;
if checkConvergence
	mcmcChain	= [samples.theta];
	% thetaSample = reshape(mcmcChain,[numSavedSteps+1 nCoins]);
	x		= squeeze(mcmcChain(:,:,:));
	x = x(:);
	maxlag = 30;
	[c,l]	= xcorr(x,maxlag,'coeff');
	h		= stem(l,c,'k-');
	set(h,'MarkerEdgeColor','none');
	%   autocorr.plot( codaSamples[[1]] , ask=FALSE )
	%   show( gelman.diag( codaSamples ) )
	%   effectiveChainLength = effectiveSize( codaSamples )
	%   show( effectiveChainLength )
	str = ['Gelman''s Rhat: ' num2str(stats.Rhat)];
	disp(str);
% 	keyboard
end

% Extract the posterior sample from JAGS:
mcmcChain	= [samples.theta];
thetaSample = reshape(mcmcChain,[numSavedSteps+1 nCoins])';
mcmcChain	= [samples.mu];
muSample	= mcmcChain(:);
mcmcChain	= [samples.kappa];
kappaSample = mcmcChain(:);


% Make a graph using Matlab commands:
if ncoins <= 5 % Only make this figure if there are not too many coins
	figure;
	nPtsToPlot	= 500;
	plotIdx		= floor(linspace(1,length(muSample),nPtsToPlot));
	kPltLim		= quantile(kappaSample,[.01,.99]);
	subplot(1,3,1)
	plot(muSample(plotIdx),kappaSample(plotIdx),'bo','Color',[.7 .7 1]);
	ylim(kPltLim);
	xlim([0 1]);
	axis square;
	xlabel('\mu');
	ylabel('\kappa');
	box off
	set(gca,'TickDir','out');
	
	subplot(1,3,2);
	plotPost(muSample,'xlab','\mu','xlim',[0,1],'main',[])
	
	subplot(1,3,3);
	plotPost(kappaSample,'xlab','\kappa','main',[],'showMode',true);
	
	figure;
	for coinIdx = 1:nCoins
		subplot(3,nCoins,coinIdx);
		plotPost(thetaSample(coinIdx,:),'xlab',['\theta_{' num2str(coinIdx) '}'],'xlim',[0,1],'main',[]);
		
		subplot(3,nCoins,coinIdx+nCoins);
		plot(thetaSample(coinIdx,plotIdx),muSample(plotIdx),'o','Color',[.7 .7 1]);
		xlim([0,1]);
		ylim([0,1]);
		xlabel(['\theta_{' num2str(coinIdx) '}']);
		ylabel('\mu');
		axis square;
		box off;
		
		subplot(3,nCoins,coinIdx+2*nCoins);
		plot(thetaSample(coinIdx,plotIdx),kappaSample(plotIdx),'o','Color',[.7 .7 1]);
		xlim([0,1]);
		ylim(kPltLim);
		xlabel(['\theta_{' num2str(coinIdx) '}']);
		ylabel('\kappa');
		axis square;
		box off;
	end
end % end if ( nCoins <= ...

%%
figure
subplot(221)
plotPost(muSample,'xlab','\mu','main',[],'compVal',0.5);
subplot(222)
plotPost(kappaSample,'xlab','\kappa','main',[],'HDItextPlace',0.1,'showMode',true);
subplot(223)
plotPost(thetaSample(1,:)','xlab','\theta_1','main',[],'compVal',0.5);
subplot(224)
lastIdx = length(z);
plotPost(thetaSample(lastIdx,:)','xlab',['\theta_{' num2str(lastIdx) '}'],'main',[],'compVal',0.5);
