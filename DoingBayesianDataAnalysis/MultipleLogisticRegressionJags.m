function MultipleLogisticRegressionJags(dataSource,checkConvergence)
% MILTILINREGRESSHYPERJAGS
%
% Multiple logistic regression
%
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij
% for 2 independent variables
close all

%% THE MODEL.
str = ['model {\r\n',...
	'\tfor( i in 1 : nData ) {\r\n',...
	'\t\ty[i] ~ dbern( mu[i] )\r\n',...
	'\t\tmu[i] <- 1/(1+exp(-( b0 + inprod( b[] , x[i,] ))))\r\n',...
	'\t}\r\n',...
	'\tb0 ~ dnorm( 0 , 1.0E-12 )\r\n',...
	'\tfor ( j in 1 : nPredictors ) {\r\n',...
	'\t\tb[j] ~ dnorm( 0 , 1.0E-12 )\r\n',...
	'\t}\r\n',...
	'}\r\n',...
	];
% Write the modelString to a file, using Matlab commands:
fid			= fopen('model.txt','w');
fprintf(fid,str);
fclose(fid);

%% THE DATA.
if nargin<1
	dataSource = {'HtWt','Cars','HeartAttack','pet'};
	dataSource = dataSource{1};
	
end
if nargin<2
	checkConvergence = false;
end

if strcmpi(dataSource,'HtWt')
	% Generate random but realistic data:
	nSubj				= 70;
	rndsd				= 474;
	dataMat			= HtWtDataGenerator(nSubj,rndsd);
	predictedName		= 'male';
	predictorNames	= {'height','weight'};
	nData				= size(dataMat,1);
	y					= dataMat(:,1);
	x					= dataMat(:,[2 3]);
	nPredictors		= size(x,2);
end
% if ( dataSource == 'Cars' ) {
%   fileNameRoot = paste( fileNameRoot , dataSource , sep='' )
%   dataMat = read.table(file='Lock1993data.txt',header=T,sep=' ')
%   predictedName = 'AirBag'
%   predictorNames = c( 'MidPrice' , 'RPM' , 'Uturn' )
%   nData = NROW( dataMat )
%   y = as.matrix( as.numeric( dataMat[,predictedName] > 0 ) ) % 0,1,2 to 0,1
%   x = as.matrix( dataMat[,predictorNames] )
%   nPredictors = NCOL( x )
% }
%
% if ( dataSource == 'HeartAttack' ) {
%   fileNameRoot = paste( fileNameRoot , dataSource , sep='' )
%   dataMat = read.table(file='BloodDataGeneratorOutput.txt',header=T,sep=' ')
%   predictedName = 'HeartAttack'
%   predictorNames = c( 'Systolic', 'Diastolic', 'Weight', 'Cholesterol',
%                       'Height', 'Age' )
% %  predictorNames = c( 'Systolic', 'Diastolic' )
%   nData = NROW( dataMat )
%   y = as.matrix( dataMat[,predictedName] )
%   x = as.matrix( dataMat[,predictorNames] )
%   nPredictors = NCOL( x )
% }

% Re-center data at mean, to reduce autocorrelation in MCMC sampling.
% Standardize (divide by SD) to make initialization easier.
[zx,Mx,SDx]				= zscore(x);
zy						= y; % y is not standardized; must be 0,1
dataStruct.x			= zx;
dataStruct.y			= zy; % BUGS does not treat 1-column mat as vector
dataStruct.nPredictors	= nPredictors;
dataStruct.nData		= nData;



%% INTIALIZE THE CHAINS.
b				= glmfit(zx,zy,'binomial','link','logit'); % link function in Bugs
b0Init			= b(1);
bInit			= b(2:3);

nChains			= 3;                   % Number of chains to run.
initsStruct		= struct([]);
for ii = 1:nChains
	initsStruct(ii).b0 = b0Init;
	initsStruct(ii).b = bInit;
end


%% RUN THE CHAINS
parameters		= {'b0','b'};		% The parameter(s) to be monitored.
% adaptSteps		= 1000;			% Number of steps to 'tune' the samplers.
burnInSteps		= 2000;			% Number of steps to 'burn-in' the samplers.
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
%
% checkConvergence = F
% if ( checkConvergence ) {
%   show( summary( codaSamples ) )
%   openGraph()
%   plot( codaSamples , ask=F )
%   openGraph()
%   autocorr.plot( codaSamples , ask=F )
% }
%

%% Extract chain values:
zb0Sample	= samples.b0(:);
zbSample	= reshape(samples.b,nChains*nIter,nPredictors);

% Convert to original scale:
a			= bsxfun(@times,zbSample,Mx./SDx);
b0Sample	= zb0Sample-sum(a,2);
bSample		= bsxfun(@rdivide,zbSample,SDx);

% Examine sampled values, z scale:
figure;
X		= [zb0Sample(:) zbSample];
[~,AX]	= plotmatrix(X);
set(get(AX(3,1),'XLabel'),'String','z\beta_0')
set(get(AX(3,2),'XLabel'),'String','z\beta_{weight}')
set(get(AX(3,3),'XLabel'),'String','z\beta_{height}')
set(get(AX(1,1),'YLabel'),'String','z\beta_0')
set(get(AX(2,1),'YLabel'),'String','z\beta_{weight}')
set(get(AX(3,1),'YLabel'),'String','z\beta_{height}')
% axis(AX(:),'square');

% Examine sampled values, original scale:
figure;
X		= [b0Sample(:) bSample];
[~,AX]	= plotmatrix(X);
set(get(AX(3,1),'XLabel'),'String','\beta_0')
set(get(AX(3,2),'XLabel'),'String','\beta_{weight}')
set(get(AX(3,3),'XLabel'),'String','\beta_{height}')
set(get(AX(1,1),'YLabel'),'String','\beta_0')
set(get(AX(2,1),'YLabel'),'String','\beta_{weight}')
set(get(AX(3,1),'YLabel'),'String','\beta_{height}')

% Display the posterior :
figure;
subplot(131)
plotPost(b0Sample,'xlab','\beta_0 Value','main',['logit(p(' predictedName '=1)) when predictors=0']);
for bIdx = 1:nPredictors
	subplot(1,3,bIdx+1)
	plotPost(bSample(:,bIdx),'xlab',['\beta_' num2str(bIdx) ' Value'],'compVal',0,'main',predictorNames{bIdx});
end


%%
% close all
% Plot data with .5 level contours of believable logistic surfaces.
% The contour lines are best interpreted when there are only two predictors.
figure;
hold on
axis square;
set(gca,'TickDir','out');
xlabel(predictorNames{1});
ylabel(predictorNames{2});
title('Male');
xl = minmax(x(:,1)');
yl = minmax(x(:,2)');
xlim(xl);
ylim(yl);
sel = y==1;
text(x(sel,1),x(sel,2),'1')
text(x(~sel,1),x(~sel,2),'0')

plot(x(:,1),x(:,2),'k.');

%%
for p1idx = 1:(nPredictors-1)
	for p2idx = (p1idx+1):nPredictors
		% Some of the 50% level contours from the posterior sample.
		% We want:
		%	p(y=1) = m = 0.5
		% for:
		%	m = sig(b1*x1+b2*x2+b0)
		% since:
		%	logit(0.5)	= log(0.5/(1-0.5)) = 0
		%
		% for every x1, we get x2:
		%	b1*x1+b2*x2+b0	= 0
		%	b2*x2			= -b1*x1-b0
		%	x2				= -b1/b2*x-b0/b2
		for chainIdx = ceil(linspace(1,nChains*nIter,20))
			a = -(b0Sample(chainIdx))/bSample(chainIdx,p2idx);
			b = -bSample(chainIdx,p1idx)/bSample(chainIdx,p2idx);
			h = refline(b,a);
			set(h,'LineWidth',1,'Color',[.7 .7 .7]);
		end
	end
end


%
coef				= glmfit(x,y,'binomial','link','logit');
str = ['m = sig(' num2str(coef(2)) 'x_1 + ' num2str(coef(3)) 'x_2 + ' num2str(coef(1)) ')'];
disp(str)
a = -coef(1)/coef(3);
b = -coef(2)/coef(3);
h = refline(b,a);set(h,'LineWidth',2,'Color','k');
xlim(xl);
ylim(yl);
