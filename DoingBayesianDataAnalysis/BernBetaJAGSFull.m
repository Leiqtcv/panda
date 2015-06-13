function BernBetaJAGSFull
% BERNBETAJAGSFULL
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

close all hidden
clear all hidden
%% THE MODEL.
% Specify the model in winBugs language, but save it as a string in Matlab:
% Very cumbersome in Matlab, easier in R
fid			= fopen('model.txt','w');
str = ['# JAGS model specification begins ...\r\n',...
	'model {\r\n',...
	'\t# Likelihood:\r\n',...
	'\t for ( i in 1:nFlips ) { \t\t # nFlips = the number of flips \r\n',...
	'\t\t y[i] ~ dbern( theta ) \t\t # data model, Bernouilli likelihood\r\n',...
	'\t }\r\n',...
	'\t # Prior distribution:\r\n',...
	'\t theta ~ dbeta( priorA , priorB ) \t # conjugate prior, beta distribution \r\n',...
	'\t priorA <- 1 \t\t\t\t # non-informative prior a=b=1\r\n',...
	'\t priorB <- 1 \t\t\t\t # non-informative prior a=b=1\r\n',...
	'}\r\n',...
	'# ... JAGS model specification ends.\r\n'];
fprintf(fid,str);
fclose(fid);

%% THE DATA.
% Specify the data in Matlab, using a structure:
dataStruct.nFlips	= 14;
dataStruct.y		= [1,1,1,1,1,1,1,1,1,1,1,0,0,0];

%% INTIALIZE THE CHAIN.
%
% Can be done automatically in jags.model() by commenting out inits argument.
% Otherwise could be established as:
nChains			= 3;			% Number of chains to run.
initStruct		= struct([]);
for ii = 1:nChains
	thetaguess			= sum(dataStruct.y)/length(dataStruct.y);
	initStruct(ii).theta = thetaguess;
% 	initStruct(ii).theta = 0.5; % for exercise 7.5, modify to a possible theta value in the prior

end

%% RUN THE CHAINS.
parameters		= {'theta'};		% The parameter(s) to be monitored.
% adaptSteps		= 500;			% Number of steps to 'tune' the samplers.
burnInSteps		= 1000;			% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 50000;		% Total number of steps in chains to save.
thinSteps		= 1;			% Number of steps to 'thin' (1=keep every step).
nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
doparallel		= 0; % do not use parallelization

fprintf( 'Running JAGS...\n' );
% [samples, stats, structArray] = matjags( ...
samples = pa_matjags( ...
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


% 	fullfile(pwd, 'model.txt'), ...    % File that contains model definition

%% EXAMINE THE RESULTS.
% Result is mcmcChain(stepIdx,paramIdx)
mcmcChain	= [samples.theta];
thetaSample = mcmcChain(:);
% Make a graph using Matlab commands:
subplot(221)
plot(thetaSample(1:500),1:length(thetaSample(1:500)),'o-','MarkerFaceColor','w','Color',[.7 .7 1]);
axis square;
xlim([-0.1 1.1]);
ylim([-50 550]);
xlabel('\theta');
ylabel('Position in Chain');
title('JAGS Results');
set(gca,'TickDir','out');
box off;

subplot(222)
[~,histInfo] = plotPost(thetaSample,'xlim',[0,1],'xlab','\theta');

%% Posterior prediction:
% For each step in the chain, use posterior theta to flip a coin:
chainLength = length(thetaSample);
yPred		= NaN(1,chainLength);  % define placeholder for flip results
for stepIdx = 1:chainLength
	pHead				= thetaSample(stepIdx);
	yPred(stepIdx) = binornd(ones(1),pHead);
end
% Jitter the 0,1 y values for plotting purposes:
yPredJittered = yPred + (rand(size(yPred))-0.5)/10;
% Now plot the jittered values:
subplot(223)
% par( mar=c(3.5,3.5,2.5,1) , mgp=c(2,0.7,0) )
plot( thetaSample(1:500) , yPredJittered(1:500),'o','Color',[.7 .7 1],'MarkerFaceColor','w');
title('posterior predicted sample');
xlabel('\theta');
ylabel('$\hat{y} (jittered)$','Interpreter','LaTeX');
axis square
box off
set(gca,'TickDir','out');

hold on
plot(mean(thetaSample),mean(yPred),'+','Color',[.7 .7 1]);
xlim([-0.1 1.1]);
ylim([-0.1 1.1]);
pa_unityline('k:');
str = ['\mu(\theta) = ' num2str(mean(thetaSample),2)];
text(mean(thetaSample),0.9*mean(yPred),str,'Rotation',90,'HorizontalAlignment','right');
str = ['$\mu(\hat{y}) = ' num2str(mean(yPred),2) '$'];
text(0.9*mean(thetaSample),mean(yPred),str,'HorizontalAlignment','right','Interpreter','LaTeX');

%% Exercise 7.5A, p(D)
subplot(222);
acceptedTraj = thetaSample;
meanTraj	= mean(thetaSample);
sdTraj		= std(thetaSample);
a			= meanTraj*((meanTraj*(1-meanTraj)/sdTraj^2)-1);
b			= (1-meanTraj)*((meanTraj*(1-meanTraj)/sdTraj^2)-1);
myData		= dataStruct.y;
pr			= prior(acceptedTraj);
l			= likelihood(acceptedTraj,myData);
post		= (l.*pr);
wtdEvid		= betapdf(acceptedTraj,a,b)./post;
pData		= 1/mean(wtdEvid);

% Display p(D) in the graph
if meanTraj > 0.5
	xpos = 0.1; 
	xadj = 'left';
else
	xpos = 0.9;
	xadj = 'right';
end
densMax = max(histInfo.density);
str = ['p(D) = ' num2str(pData,3)];
text(xpos,0.75*densMax,str,'HorizontalAlignment',xadj)

%% To save graph
if ispc
	print('-depsc','-painter',mfilename);
elseif ismac
	print('-depsc','-painters',mfilename);
end
%% Functions below for exercise 7.5
% copied from BernMetropolisTemplate
function pDataGivenTheta = likelihood(theta,data)
z						= sum(data == 1);
N						= length(data);
pDataGivenTheta			= theta.^z.*(1-theta).^(N-z);
sel						= theta>1 | theta<0;
pDataGivenTheta(sel)	= 0;

function pTheta = prior(theta)
pTheta				= ones(length(theta),1);
% pTheta(theta<0.4)	= 0;
% pTheta(theta>0.6)	= 0;
sel			= theta>1 | theta<0;
pTheta(sel) = 0;
