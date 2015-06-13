function MultiLinRegressHyperJags(dataSource,checkConvergence)
% MILTILINREGRESSHYPERJAGS
%
% Multiple linear regression with hyperprior
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij


%% THE MODEL.

str = ['model {\r\n',...
	'\tfor( i in 1 : nData ) {\r\n',...
	'\t\ty[i] ~ dnorm( mu[i] , tau )\r\n',...
	'\t\tmu[i] <- b0 + inprod( b[] , x[i,] )\r\n',...
	'\t}\r\n',...
	'\ttau ~ dgamma(.01,.01)\r\n',...
	'\tb0 ~ dnorm(0,1.0E-12) \r\n',...
	'\tfor ( j in 1:nPredictors ) {\r\n',...
	'\t\tb[j] ~ dt( muB , tauB , tdfB )\r\n',...
	'\t}\r\n',...
	'\tmuB ~ dnorm( 0 , .100 )\r\n',...
	'\ttauB ~ dgamma(.01,.01)\r\n',...
	'\tudfB ~ dunif(0,1)\r\n',...
	'\ttdfB <- 1 + tdfBgain * ( -log( 1 - udfB ) )\r\n',...
	'}\r\n',...
	];

% Write the modelString to a file, using Matlab commands:
fid			= fopen('model.txt','w');
fprintf(fid,str);
fclose(fid);

%% THE DATA.

tdfBgain = 1;
if nargin<1
	dataSource = {'Guber1999','McIntyre1994','random','pet'};
	dataSource = dataSource{3};
	
end
if nargin<2
	checkConvergence = false;
end

% if ( dataSource=='Guber1999' ) {
%    fileNameRoot = paste('Guber1999','tdf',tdfBgain,sep='')
%    dataMat = read.table( file='Guber1999data.txt' ,
%                          col.names = c( 'State','Spend','StuTchRat','Salary',
%                                         'PrcntTake','SATV','SATM','SATT') )
%    % Specify variables to be used in BUGS analysis:
%    predictedName = 'SATT'
%    predictorNames = c( 'Spend' , 'PrcntTake' )
%    %predictorNames = c( 'Spend' , 'PrcntTake' , 'Salary' , 'StuTchRat' )
%    nData = NROW( dataMat )
%    y = as.matrix( dataMat[,predictedName] )
%    x = as.matrix( dataMat[,predictorNames] )
%    nPredictors = NCOL( x )
% }
%
% if ( dataSource=='McIntyre1994' ) {
%    fileNameRoot = paste('McIntyre1994','tdf',tdfBgain,sep='')
%    dataMat = read.csv(file='McIntyre1994data.csv')
%    predictedName = 'CO'
%    predictorNames = c('Tar','Nic','Wt')
%    nData = NROW( dataMat )
%    y = as.matrix( dataMat[,predictedName] )
%    x = as.matrix( dataMat[,predictorNames] )
%    nPredictors = NCOL( x )
% }
%
if strcmpi(dataSource,'random')
	%    fileNameRoot = paste('Random','tdf',tdfBgain,sep='')
	% Generate random data.
	% True parameter values:
	betaTrue		= [100, 1, 2, zeros(1,21)]; % beta0 is first component
	nPredictors	= length(betaTrue)-1;
	sdTrue		= 2;
	% 	tauTrue		= 1/sdTrue^2;
	% Random X values:
	
	stream = RandStream('mt19937ar','Seed',47405); % MATLAB's start-up settings
	RandStream.setGlobalStream(stream);
	xM		= 5;
	xSD		= 2;
	nData	= 100;
	
	x		= xM+xSD*randn(nData,nPredictors);
	predictorNames = cell(nPredictors,1);
	for ii	= 1:nPredictors
		predictorNames{ii} = ['X' num2str(ii)];
	end
	
	% Random Y values generated from linear model with true parameter values:
	eta		= sdTrue*randn(1,nData);
	b0		= betaTrue(1)';
	bix		= (x*betaTrue(2:end)')';
	y		= bix+b0+eta;
	y		= y';
	
	predictedName	= 'Y';
	% Select which predictors to include
	includeOnly		= 1:nPredictors; % default is to include all
	%    %includeOnly = 1:6; % subset of predictors overwrites default
	x				= x(:,includeOnly);
	predictorNames	= predictorNames(includeOnly);
	nPredictors		= size(x,2);
end


% Re-center data at mean, to reduce autocorrelation in MCMC sampling.
% Standardize (divide by SD) to make initialization easier.
[zx,mux,sdx] = zscore(x);
[zy,muy,sdy] = zscore(y);

% plot(zx,zy,'.');
dataStruct.x			= zx;
dataStruct.y			= zy; % BUGS does not treat 1-column mat as vector
dataStruct.nPredictors	= nPredictors;
dataStruct.nData		= nData;
dataStruct.tdfBgain		= tdfBgain;

%% INTIALIZE THE CHAINS.
nChains					= 3;                   % Number of chains to run.

% lmInfo = lm( y ~ x ) % R function returns least-squares (normal MLE) fit.
lmInfo			= regstats(y,x,'linear',{'beta','r'});
bInit			= lmInfo.beta(2:end)'.*sdx./sdy;
tauInit			= length(y).*(sdy.^2)/sum((lmInfo.r).^2);
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).b0		= 0;
	initsStruct(ii).b		= bInit;
	initsStruct(ii).tau		= tauInit;
	initsStruct(ii).muB		=  mean(bInit);
	initsStruct(ii).tauB	= 1/std(bInit)^2;
	initsStruct(ii).udfB	= 0.95; % tdfB = 4
	
end

%% RUN THE CHAINS
parameters		= {'b0','b','tau','muB','tauB','tdfB'};		% The parameter(s) to be monitored.
% adaptSteps		= 500;			% Number of steps to 'tune' the samplers.
burnInSteps		= 500;			% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 50000;		% Total number of steps in chains to save.
thinSteps		= 1;			% Number of steps to 'thin' (1=keep every step).
nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
doparallel		= 0; % do not use parallelization

fprintf( 'Running JAGS...\n' );
% [samples, stats, structArray] = matjags( ...
samples = pa_matjags( ...
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
if checkConvergence
	% 	fnames = fieldnames(samples);
	% 	n = numel(fnames)-1;
	% 	for ii = 1:n
	% 		% thetaSample = reshape(mcmcChain,[numSavedSteps+1 nCoins]);
	% 		ns = ceil(sqrt(n));
	% 		figure(1)
	% 		subplot(ns,ns,ii)
	% 		s		= samples.(fnames{ii});
	% 		s		= s(1:16667);
	% 		s		= zscore(s);
	% 		maxlag	= 35;
	% 		[c,l]	= xcorr(s,maxlag,'coeff');
	% 		h		= stem(l(maxlag:end),c(maxlag:end),'k-');
	% 		xlim([-1 maxlag]);
	% 		set(h,'MarkerEdgeColor','none');
	% 		axis square;
	% 		box off
	% 		set(gca,'TickDir','out');
	% 		str = fnames{ii};
	% 		xlabel('Lag');
	% 		ylabel('Autocorrelation');
	% 		title(str);
	% 		%   show( gelman.diag( codaSamples ) )
	% 		%   effectiveChainLength = effectiveSize( codaSamples )
	% 		%   show( effectiveChainLength )
	% 	end
end

%% Extract chain values:
zb0Samp		= samples.b0(:);
zbSamp		= reshape(samples.b,nIter*nChains,nPredictors);
zTauSamp	= samples.tau(:);
zSigmaSamp	= 1./sqrt(zTauSamp);
chainLength = length(zTauSamp);

%% Convert to original scale:
bSamp		= bsxfun(@times,zbSamp,sdy./sdx);
b			= sum(bsxfun(@times,zbSamp,sdy./sdx.*mux),2);
b0Samp		= zb0Samp.*sdy+muy-b;
sigmaSamp	= zSigmaSamp.*sdy;

%% Scatter plots of parameter values, pairwise:
% if ( nPredictors <= 6 ) { % don't display if too many predictors
%     openGraph()
%     thinIdx = round(seq(1,length(zb0Samp),length=200))
%     pairs( cbind( zSigmaSamp[thinIdx] , zb0Samp[thinIdx] , zbSamp[thinIdx,] )  ,
%       labels=c('Sigma zy','zIntercept',paste('zSlope',predictorNames,sep='')))
%     openGraph()
%     thinIdx = seq(1,length(b0Samp),length=700)
%     pairs( cbind( sigmaSamp[thinIdx] , b0Samp[thinIdx] , bSamp[thinIdx,] ) ,
%       labels=c( 'Sigma y' , 'Intercept', paste('Slope',predictorNames,sep='')))
%     saveGraph(file=paste(fileNameRoot,'PostPairs.eps',sep=''),type='eps')
% }

%% Show correlation matrix on console:
% cat('\nCorrlations of posterior sigma, b0, and bs:\n')
% show( cor( cbind( sigmaSamp , b0Samp , bSamp ) ) )

%% Display the posterior:
nsub = ceil(sqrt(nPredictors+2));
subplot(nsub,nsub,1);
plotPost(sigmaSamp,'xlab','\sigma','compVal',[],'main','\sigma_y');

subplot(nsub,nsub,2);
plotPost(b0Samp,'xlab','Intercept Value','compVal',[],'main',[predictedName ' at x = 0']);
for sIdx = 1:nPredictors
	subplot(nsub,nsub,2+sIdx)
	plotPost(bSamp(:,sIdx),'xlab','Slope','compVal',0,'main',['\Delta' predictedName(1) '/ \Delta' predictorNames{sIdx}]);
end

keyboard
%% Posterior prediction:
% Specify x values for which predicted y's are needed.
% xPostPred is a matrix such that ncol=nPredictors and nrow=nPostPredPts.
% xPostPred = rbind(
%     apply(x,2,mean)-3*apply(x,2,sd) , % mean of data x minus thrice SD of data x
%     apply(x,2,mean)                 , % mean of data x
%     apply(x,2,mean)+3*apply(x,2,sd)   % mean of data x plus thrice SD of data x
% )
xPostPred = [mean(x)-3*std(x); mean(x); mean(x)+3*std(x)];

% Define matrix for recording posterior predicted y values for each xPostPred.
% One row per xPostPred value, with each row holding random predicted y values.
postSampSize	= chainLength;
yPostPred		= zeros(size(xPostPred,1),postSampSize);

% Define matrix for recording HDI limits of posterior predicted y values:
yHDIlim = zeros(size(xPostPred,1),2);

% Generate posterior predicted y values.
% This gets only one y value, at each x, for each step in the chain.
for chainIdx = 1:chainLength
	mu = b0Samp(chainIdx) + xPostPred*bSamp(chainIdx,:)';
	sd = sigmaSamp(chainIdx);
	% 	+ xPostPred %*% cbind(bSamp[chainIdx,]) ,
	yPostPred(:,chainIdx) = mu+sd*randn(size(xPostPred,1),1);
end

figure;
for ii = 1:3
	subplot(1,3,ii)
	plotPost(yPostPred(ii,:)')
end
for xIdx = 1:size(xPostPred,1)
	yHDIlim(xIdx,:) = HDIofMCMC(yPostPred(xIdx,:));
end

disp('Posterior predicted y for selected x:')
disp(xPostPred)
disp(mean(yPostPred,2))
disp('Limits:')
disp(yHDIlim)
