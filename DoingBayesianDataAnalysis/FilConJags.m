function FilConJags
% FILCONJAGS
%
% Filtration-condensation experiment
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

%% Clean
close all hidden
clear all hidden
clc

%% THE MODEL.
fid			= fopen('model.txt','w');
% str = ['# JAGS model specification begins ...\r\n\r\n',...
% 	'model {\r\n\r\n',...
% 	'\t# Likelihood:\r\n\r\n',...
% 	'\t for ( i in 1:nFlips ) { \t\t # nFlips = the number of flips \r\n\r\n',...
% 	'\t\t y[i] ~ dbern( theta ) \t\t # data model, Bernouilli likelihood\r\n\r\n',...
% 	'\t }\r\n\r\n',...
% 	'\t # Prior distribution:\r\n\r\n',...
% 	'\t theta ~ dbeta( priorA , priorB ) \t # conjugate prior, beta distribution \r\n\r\n',...
% 	'\t priorA <- 1 \t\t\t\t # non-informative prior a=b=1\r\n\r\n',...
% 	'\t priorB <- 1 \t\t\t\t # non-informative prior a=b=1\r\n\r\n',...
% 	'}\r\n\r\n',...
% 	'# ... JAGS model specification ends.\r\n'];

str = ['model {\r\n',...
   '\tfor ( subjIdx in 1:nSubj ) {\r\n',...
      '\t\t# Likelihood:\r\n',...
      '\t\tz[subjIdx] ~ dbin( theta[subjIdx] , N[subjIdx] )\r\n',...
      '\t\t# Prior on theta: Notice nested indexing.\r\n',...
      '\t\ttheta[subjIdx] ~ dbeta( a[cond[subjIdx]] , b[cond[subjIdx]] )T(0.001,0.999)\r\n',...
   '\t}\r\n',...
   '\tfor ( condIdx in 1:nCond ) {\r\n',...
      '\t\ta[condIdx] <- mu[condIdx] * kappa[condIdx]\r\n',...
      '\t\tb[condIdx] <- (1-mu[condIdx]) * kappa[condIdx]\r\n',... 
      '\t\t# Hyperprior on mu and kappa:\r\n',...
      '\t\tmu[condIdx] ~ dbeta( Amu , Bmu )\r\n',...
      '\t\tkappa[condIdx] ~ dgamma( Skappa , Rkappa )\r\n',...
   '\t}\r\n',...
   '\t# Constants for hyperprior:\r\n',...
   '\tAmu <- 1\r\n',...
   '\tBmu <- 1\r\n',...
   '\tSkappa <- pow(meanGamma,2)/pow(sdGamma,2)\r\n',...
   '\tRkappa <- meanGamma/pow(sdGamma,2)\r\n',...
   '\tmeanGamma <- 10\r\n',...
   '\tsdGamma <- 10\r\n',...
'}\r\n',...
];

% Uncomment for Exercise 9.2A
% str = ['model {\r\n',...
%    '\tfor ( subjIdx in 1:nSubj ) {\r\n',...
%       '\t\t# Likelihood:\r\n',...
%       '\t\tz[subjIdx] ~ dbin( theta[subjIdx] , N[subjIdx] )\r\n',...
%       '\t\t# Prior on theta: Notice nested indexing.\r\n',...
%       '\t\ttheta[subjIdx] ~ dbeta( a[cond[subjIdx]] , b[cond[subjIdx]] )T(0.001,0.999)\r\n',...
%    '\t}\r\n',...
%    '\tfor ( condIdx in 1:nCond ) {\r\n',...
%       '\t\ta[condIdx] <- mu[condIdx] * kappa\r\n',... 
%       '\t\tb[condIdx] <- (1-mu[condIdx]) * kappa\r\n',... 
%       '\t\t# Hyperprior on mu and kappa:\r\n',...
%       '\t\tmu[condIdx] ~ dbeta( Amu , Bmu )\r\n',...
%    '\t}\r\n',...
%    '\t# Constants for hyperprior:\r\n',...
%    '\tAmu <- 1\r\n',...
%    '\tBmu <- 1\r\n',...
%     '\tkappa ~ dgamma( Skappa , Rkappa )\r\n',...
%    '\tSkappa <- pow(meanGamma,2)/pow(sdGamma,2)\r\n',...
%    '\tRkappa <- meanGamma/pow(sdGamma,2)\r\n',...
%    '\tmeanGamma <- 10\r\n',...
%    '\tsdGamma <- 10\r\n',...
% '}\r\n',...
% ];

fprintf(fid,str);
fclose(fid);
%% THE DATA.

% For each subject, specify the condition s/he was in,
% the number of trials s/he experienced, and the number correct.
% (These lines intentionally exceed the margins so that they don't take up
% excessive space on the printed page.)
cond	= [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4];
N		= [64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64];
z		= [45,63,58,64,58,63,51,60,59,47,63,61,60,51,59,45,61,59,60,58,63,56,63,64,64,60,64,62,49,64,64,58,64,52,64,64,64,62,64,61,59,59,55,62,51,58,55,54,59,57,58,60,54,42,59,57,59,53,53,42,59,57,29,36,51,64,60,54,54,38,61,60,61,60,62,55,38,43,58,60,44,44,32,56,43,36,38,48,32,40,40,34,45,42,41,32,48,36,29,37,53,55,50,47,46,44,50,56,58,42,58,54,57,54,51,49,52,51,49,51,46,46,42,49,46,56,42,53,55,51,55,49,53,55,40,46,56,47,54,54,42,34,35,41,48,46,39,55,30,49,27,51,41,36,45,41,53,32,43,33];
nSubj	= length(cond);
nCond	= length(unique(cond));

% Specify the data in a form that is compatible with Jags model, as a structure:
dataStruct.nCond	= nCond;
dataStruct.nSubj	= nSubj;
dataStruct.cond		= cond;
dataStruct.N		= N;
dataStruct.z		= z;

%% INTIALIZE THE CHAINS.
nChains = 3;
sqzData				= .01+.98*dataStruct.z./dataStruct.N;
a					= dataStruct.cond';
mu					= accumarray(a,sqzData',[],@mean);
sd					= accumarray(a,sqzData',[],@std);
% mu		= aggregate( sqzData , list(dataList.cond) , 'mean' )(,'x')
% sd		= aggregate( sqzData , list(dataList.cond) , 'sd' )(,'x')
kappa				= mu.*(1-mu)./sd.^2 - 1;
% kappa		= mean(kappa); % uncomment for exercise 9.2A
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).theta	= sqzData;
	initsStruct(ii).mu		= mu;
	initsStruct(ii).kappa	= kappa;
end

%% RUN THE CHAINS.
parameters		= {'mu','kappa','theta','a','b'};		% The parameter(s) to be monitored.
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

%% EXAMINE THE RESULTS.


% Extract parameter values and save them.
mcmcChain	= [samples.mu];
[m,n,p]		= size(mcmcChain);
mu			= reshape(mcmcChain,m*n,p)';
mcmcChain	= [samples.kappa];
[m,n,p]		= size(mcmcChain);
kappa		= reshape(mcmcChain,m*n,p)';
chainLength = size(mu,2);


checkConvergence = true;
if checkConvergence
	close all
	% thetaSample = reshape(mcmcChain,[numSavedSteps+1 nCoins]);
	for ii = 1:4
		if ii<=size(mu,1)
		x		= mu(ii,:);
		x		= x(1:16667);
		x		= zscore(x);
		maxlag	= 30;
		[c,l]	= xcorr(x,maxlag,'coeff');
		subplot(2,4,ii)
		h		= stem(l(maxlag:end),c(maxlag:end),'k-');
		xlim([0 maxlag]);
		set(h,'MarkerEdgeColor','none');
		axis square;
		box off
		set(gca,'TickDir','out');
		str = ['\mu_' num2str(ii)];
		xlabel('Lag');
		ylabel('Autocorrelation');
		title(str);
		end
		
		if ii<=size(kappa,1)
		x		= kappa(ii,:);
		x		= x(1:16667);
		x		= zscore(x);
		maxlag	= 30;
		[c,l]	= xcorr(x,maxlag,'coeff');
		subplot(2,4,ii+4)
		h		= stem(l(maxlag:end),c(maxlag:end),'k-');
		xlim([0 maxlag]);
		set(h,'MarkerEdgeColor','none');
		axis square;
		box off
		set(gca,'TickDir','out');
		str = ['\kappa_' num2str(ii)];
		xlabel('Lag');
		ylabel('Autocorrelation');
		title(str);
		end
		%   show( gelman.diag( codaSamples ) )
		%   effectiveChainLength = effectiveSize( codaSamples )
		%   show( effectiveChainLength )
	end
end


%% Histograms of mu differences:
close all
clc
subplot(131)
x = mu(1,:)-mu(2,:);
plotPost(x','xlab','\mu_1-\mu_2','main',[],'compVal',0);
x = mu(3,:)-mu(4,:);
subplot(132)
plotPost(x','xlab','\mu_3-\mu_4','main',[],'compVal',0);
subplot(133)
x = (mu(1,:)+mu(2,:))/2 - (mu(3,:)+mu(4,:))/2;
plotPost(x','xlab','(\mu_1+\mu_3)/2 - (\mu_3+\mu_4)/2','main',[],'compVal',0);

% Scatterplot of mu,kappa in each condition:

muLim		= [.60,1]; 
kappaLim	= [2.0 , 40];
mainLab		= 'Posterior';
thindex		= round(linspace(1,chainLength,300));
figure
hold on
xlim(muLim);
ylim(kappaLim);
text(mu(1,thindex),kappa(1,thindex),'1','Color','r');
title(mainLab);
xlabel('\mu_c');
ylabel('\kappa_c');
set(gca,'Yscale','log','YTick',[2 5 10 20],'YTickLabel',[2 5 10 20]);
axis square;

text(mu(2,thindex),kappa(2,thindex),'2','Color','b');
text(mu(3,thindex),kappa(3,thindex),'3','Color','g');
text(mu(4,thindex),kappa(4,thindex),'4','Color','k');
