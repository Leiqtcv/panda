function pet_MultiLinRegressHyperJagsbeta(dataSource,checkConvergence)
% MILTILINREGRESSHYPERJAGS
%
% Multiple linear regression with hyperprior
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij


%% THE MODEL.

% str = ['model {\r\n',...
% 	'\tfor( i in 1 : nData ) {\r\n',...
% 	'\t\ty[i] ~ dnorm( mu[i] , tau )\r\n',...
% 	'\t\tmu[i] <- b0 + inprod( b[] , x[i,] )\r\n',...
% 	'\t}\r\n',...
% 	'\ttau ~ dgamma(.01,.01)\r\n',...
% 	'\tb0 ~ dnorm(0,1.0E-12) \r\n',...
% 	'\tfor ( j in 1:nPredictors ) {\r\n',...
% 	'\t\tb[j] ~ dt( muB , tauB , tdfB )\r\n',...
% 	'\t}\r\n',...
% 	'\tmuB ~ dnorm( 0 , .100 )\r\n',...
% 	'\ttauB ~ dgamma(.01,.01)\r\n',...
% 	'\tudfB ~ dunif(0,1)\r\n',...
% 	'\ttdfB <- 1 + tdfBgain * ( -log( 1 - udfB ) )\r\n',...
% 	'}\r\n',...
% 	];

% My priors
str = ['model {\r\n',...
	'\tfor( i in 1 : nData ) {\r\n',...
	'\t\ty[i] ~ dbeta( alpha[i] ,beta[i] )T(0.001,0.999)\r\n',...
	'\t\talpha[i] <- mu[i] * kappa\r\n',...
	'\t\tbeta[i] <- ( 1.0 - mu[i] ) * kappa\r\n',...
	'\t\tmu[i] <- 1 / ( 1 + exp( -(b0 + inprod( b[] , x[i,] ))\r\n',...
	'\t}\r\n',...
	'\tkappa ~ dgamma(1,0.1)\r\n',...
	'\tb0 ~ dnorm(0,1.0E-12) \r\n',...
	'\tfor ( j in 1:nPredictors ) {\r\n',...
	'\t\tb[j] ~ dt( muB , tauB , tdfB )\r\n',...
	'\t}\r\n',...
	'\tmuB ~ dnorm( 0 , 0.1 )\r\n',...
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
	dataSource ='pet';
end
if nargin<2
	checkConvergence = false;
end

if strcmpi(dataSource,'pet')
	% Load
	load('E:\DATA\petdata')
	
	area = 2;
	x	= [DAT(area).Dprerest DAT(area).Dprevideo];
	y	= DAT(area).Fpost;
	sel = ~isnan(x(:,1));
	x	= x(sel,:);
	y	= y(sel)/100;
	
	[nData,nPredictors]	= size(x);
	
	predictorNames = {'Rest','Video'};
	predictedName = 'Phoneme Score';
	
	close all
end
figure
for ii = 1:nPredictors
	subplot(1,3,ii)
	plot(x(:,ii),y,'ko','MarkerFaceColor','w','MarkerEdgeColor',[.7 .7 1]);
	hold on
	axis square;
	box off;
	set(gca,'TickDir','out');
	ylim([0 1]);
	
	lsline
	ylim([0 1]);
	title(predictorNames{ii})
	xlabel('FDG (%)');
	ylabel('Phoneme Score (%)');
end
subplot(1,3,3)
plot3(x(:,1),x(:,2),y,'ko','MarkerEdgeColor','k','MarkerFaceColor',[.7 .7 1]);
hold on
axis square;
grid on;
set(gca,'TickDir','out');
zlim([0 1]);


dataStruct.x			= x;
dataStruct.y			= y; % BUGS does not treat 1-column mat as vector
dataStruct.nPredictors	= nPredictors;
dataStruct.nData		= nData;
dataStruct.tdfBgain		= tdfBgain;

%% INTIALIZE THE CHAINS.
lmInfo	= regstats(y,x,'linear',{'beta','r'});
% indx	= [1 2];
% for ii = 1:nPredictors
% 	subplot(1,3,ii);
% 	b		= lmInfo.beta([1 ii+1]);
% 	sel		= find(~(indx==ii));
% 	bias	= lmInfo.beta(1+sel)*mean(x(:,sel));
% 	b(1)	= b(1)+bias;
% 	pa_regline(b);
% end

% subplot(133)
% a		= [1.07*min(x(:)) 0.93*max(x(:))];
% [a,b]	= meshgrid(a);
% c		= a*lmInfo.beta(2)+b*lmInfo.beta(3)+lmInfo.beta(1);
% a		= a(:); a = a([1 2 4 3]);
% b		= b(:); b = b([1 2 4 3]);
% c		= c(:);c = c([1 2 4 3]);
% h		= patch(a(:),b(:),c(:),[.7 .7 1]);
% alpha(h,0.3);
% xlabel('Rest');
% ylabel('Video');
% zlabel('Phoneme score (%)');
% drawnow;

bInit			= lmInfo.beta(2:end)';
b0				= lmInfo.beta(1)';

initsStruct		= struct([]);
phat			= betafit(y);

nChains					= 3;                   % Number of chains to run.
for ii = 1:nChains
	initsStruct(ii).b0		= mean(logit(y));
	initsStruct(ii).b		= bInit;
	initsStruct(ii).kappa	= sum(phat);
	initsStruct(ii).muB		= mean(bInit);
	initsStruct(ii).tauB	= 1/std(bInit)^2;
	initsStruct(ii).udfB	= 0.95; % tdfB = 4
	
end

%% RUN THE CHAINS
parameters		= {'b0','b','kappa','muB','tauB','tdfB'};		% The parameter(s) to be monitored.
% adaptSteps		= 500;			% Number of steps to 'tune' the samplers.
burnInSteps		= 1000;			% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 50000;		% Total number of steps in chains to save.
thinSteps		= 1;			% Number of steps to 'thin' (1=keep every step).
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
b0Samp		= samples.b0(:);
bSamp		= reshape(samples.b,nIter*nChains,nPredictors);
TauSamp		= samples.tau(:);
SigmaSamp	= 1./sqrt(TauSamp);
chainLength = length(TauSamp);


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
figure
subplot(nsub,nsub,1);
plotPost(sigmaSamp,'xlab','\sigma','compVal',[],'main','\sigma_y');

subplot(nsub,nsub,2);
plotPost(b0Samp,'xlab','Intercept Value','compVal',[],'main',[predictedName ' at x = 0']);
for sIdx = 1:nPredictors
	subplot(nsub,nsub,2+sIdx)
	plotPost(bSamp(:,sIdx),'xlab','Slope','compVal',0,'main',['\Delta' predictedName(1) '/ \Delta' predictorNames{sIdx}]);
end

figure
subplot(121)
plot(bSamp(:,1),bSamp(:,2),'.','Color',[.7 .7 1]);
axis square
box off
set(gca,'TickDir','out');
xlabel('\beta_{rest}');
ylabel('\beta_{video}');
pa_revline;
hold on
plot(lmInfo.beta(2),lmInfo.beta(3),'ko','MarkerFaceColor','w');

subplot(122)
contrast = (bSamp(:,2)-bSamp(:,1));
plotPost(contrast,'xlab','Slope','compVal',0,'main',['\Delta' predictedName(1) '/ \Delta' predictorNames{sIdx}]);

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

% figure;
% for ii = 1:3
% 	subplot(1,3,ii)
% 	plotPost(yPostPred(ii,:)');
% end
for xIdx = 1:size(xPostPred,1)
	yHDIlim(xIdx,:) = HDIofMCMC(yPostPred(xIdx,:));
end

disp('Posterior predicted y for selected x:')
disp(xPostPred)
disp(mean(yPostPred,2))
disp('Limits:')
disp(yHDIlim)


function l = logit(p)
l = log(p./(1-p));