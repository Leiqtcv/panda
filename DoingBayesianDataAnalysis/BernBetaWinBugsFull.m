% PLOTPOST(P)
%
% plot MCMC parameter sample vector P
%
% POSTSUMMARY = PLOTPOST(P)
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij
% rm(list = ls())
% graphics.off()
% source('openGraphSaveGraph.R')
% 
% require(rjags)         % Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%                        % A Tutorial with R and BUGS. Academic Press / Elsevier.

close all hidden
clear all hidden
%% THE MODEL.
% Specify the model in winBugs language, but save it as a string in Matlab:
% Very cumbersome in Matlab, easier in R
fid			= fopen('model.txt','w');
fprintf(fid,'# winBUGS model specification begins ...\r\n'); % \r\n, to have CR+LF for Windows Notepad end of line
fprintf(fid,'model {\r\n');
fprintf(fid,'\t# Likelihood:\r\n');
fprintf(fid,'\t for ( i in 1:nFlips ) { \t\t # nFlips = the number of flips \r\n');
fprintf(fid,'\t\t y[i] ~ dbern( theta ) \t\t # data model, Bernouilli likelihood\r\n');
fprintf(fid,'\t }\r\n');
fprintf(fid,'\t # Prior distribution:\r\n');
fprintf(fid,'\t theta ~ dbeta( priorA , priorB ) \t # conjugate prior, beta distribution \r\n');
fprintf(fid,'\t priorA <- 1 \t\t\t\t # non-informative prior a=b=1\r\n');
fprintf(fid,'\t priorB <- 1 \t\t\t\t # non-informative prior a=b=1\r\n');
fprintf(fid,'}\r\n');
fprintf(fid,'# ... winBUGS model specification ends.\r\n');
fclose(fid);

%% THE DATA.
% Specify the data in Matlab, using a structure:
dataStruct.nFlips	= 14;
dataStruct.y		= [1,1,1,1,1,1,1,1,1,1,1,0,0,0];

%% INTIALIZE THE CHAIN.
% 
% % Can be done automatically in jags.model() by commenting out inits argument.
% % Otherwise could be established as:
% % initsList = list( theta = sum(dataList$y)/length(dataList$y) )
% 

%% RUN THE CHAINS.
parameters		= {'theta'};		% The parameter(s) to be monitored.
adaptSteps		= 500;			% Number of steps to 'tune' the samplers.
burnInSteps		= 1000;			% Number of steps to 'burn-in' the samplers.
nChains			= 3;			% Number of chains to run.
numSavedSteps	= 50000;		% Total number of steps in chains to save.
thinSteps		= 1;			% Number of steps to 'thin' (1=keep every step).
nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
% Create, initialize, and adapt the model:
% jagsModel = jags.model( 'model.txt' , data=dataList , % inits=initsList , 
%                         n.chains=nChains , n.adapt=adaptSteps )
% % Burn-in:
% cat( 'Burning in the MCMC chain...\r\n' )
% update( jagsModel , n.iter=burnInSteps )
% % The saved MCMC chain:
% cat( 'Sampling final MCMC chain...\r\n' )
% codaSamples = coda.samples( jagsModel , variable.names=parameters , 
%                             n.iter=nIter , thin=thinSteps )
% % resulting codaSamples object has these indices: 
% %   codaSamples(( chainIdx ))( stepIdx , paramIdx )
    

bugsFolder = 'C:\Users\Marc\Documents\WinBUGS14';
[samples, stats] = matbugs(dataStruct, ...
		fullfile(pwd, 'model.txt'), ...
		'nChains',nChains,...
		'view', 1, 'nburnin', burnInSteps, 'nsamples', nIter, ...
		'thin', thinSteps, ...
		'monitorParams', parameters, ...
		'Bugdir', bugsFolder);

%% EXAMINE THE RESULTS.
% % Convert coda-object codaSamples to matrix object for easier handling.
% % But note that this concatenates the different chains into one long chain.
% % Result is mcmcChain( stepIdx , paramIdx )
% mcmcChain = as.matrix( codaSamples )
% 
% thetaSample = mcmcChain
% 
% % Make a graph using R commands:
% openGraph(width=10,height=6)
% layout( matrix( c(1,2) , nrow=1 ) )
% plot( thetaSample(1:500) , 1:length(thetaSample(1:500)) , type='o' ,
%       xlim=c(0,1) , xlab=bquote(theta) , ylab='Position in Chain' ,
%       cex.lab=1.25 , main='JAGS Results' , col='skyblue' )
% source('plotPost.R')
% histInfo = plotPost( thetaSample , xlim=c(0,1) , xlab=bquote(theta) )
% saveGraph( file='BernBetaJagsFullPost' , type='eps' )
% 
% % Posterior prediction:
% % For each step in the chain, use posterior theta to flip a coin:
% chainLength = length( thetaSample )
% yPred = rep( NULL , chainLength )  % define placeholder for flip results
% for ( stepIdx in 1:chainLength ) {
%   pHead = thetaSample(stepIdx)
%   yPred(stepIdx) = sample( x=c(0,1), prob=c(1-pHead,pHead), size=1 )
% }
% % Jitter the 0,1 y values for plotting purposes:
% yPredJittered = yPred + runif( length(yPred) , -.05 , +.05 )
% % Now plot the jittered values:
% openGraph(width=5,height=5.5)
% par( mar=c(3.5,3.5,2.5,1) , mgp=c(2,0.7,0) )
% plot( thetaSample(1:500) , yPredJittered(1:500) , xlim=c(0,1) ,
%       main='posterior predicted sample' ,
%       xlab=expression(theta) , ylab=expression(hat(y)*' '*(jittered)) , 
%       col='skyblue' )
% points( mean(thetaSample) , mean(yPred) , pch='+' , cex=2 , col='skyblue' )
% text( mean(thetaSample) , mean(yPred) ,
%       bquote( mean(hat(y)) == .(signif(mean(yPred),2)) ) ,
%       adj=c(1.2,.5) )
% text( mean(thetaSample) , mean(yPred) , srt=90 ,
%       bquote( mean(theta) == .(signif(mean(thetaSample),2)) ) ,
%       adj=c(1.2,.5) )
% abline( 0 , 1 , lty='dashed' , lwd=2 )
% saveGraph( file='BernBetaJagsFullPred' , type='eps' )
