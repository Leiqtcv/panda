function BernTwoJAGS
% BERNTWOJAGS
%
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

close all

%% THE MODEL.
fid			= fopen('model.txt','w');
fprintf(fid,'# JAGS model specification begins ...\r\n'); % \r\n, to have CR+LF for Windows Notepad end of line
fprintf(fid,'model {\r\n');
fprintf(fid,'\t# Likelihood:\r\n');
fprintf(fid,'\t for ( i in 1 : N1 ) { y1[i] ~ dbern( theta1 ) }\r\n');
fprintf(fid,'\t for ( i in 1 : N2 ) { y2[i] ~ dbern( theta2 ) }\r\n');
fprintf(fid,'\t # Prior. Independent beta distributions.\r\n');
fprintf(fid,'\t theta1 ~ dbeta( 3 , 3 ) \t # conjugate prior, beta distribution \r\n');
fprintf(fid,'\t theta2 ~ dbeta( 3 , 3 ) \t # conjugate prior, beta distribution \r\n');
%% Experiment 8.1
% fprintf(fid,'\t theta1 ~ dbeta( 30 , 10 ) \t # conjugate prior, beta distribution \r\n');
% fprintf(fid,'\t theta2 ~ dbeta( 30 , 10 ) \t # conjugate prior, beta distribution \r\n');
fprintf(fid,'}\r\n');
fprintf(fid,'# ... end JAGS model specification.\r\n');
fclose(fid);

%% THE DATA.
% Specify the data in a form that is compatible with JAGS model, as a Struct:
dataStruct.N1 = 7;
dataStruct.y1 = [1,1,1,1,1,0,0];
dataStruct.N2 = 7;
dataStruct.y2 = [1,1,0,0,0,0,0];

%% Experiment 8.1
% dataStruct.N1 = 285;
% dataStruct.y1 = [ones(1,251) zeros(1,285-251)];
% dataStruct.N2 = 53;
% dataStruct.y2 = [ones(1,48) zeros(1,53-48)];

%% INTIALIZE THE CHAIN.
% Cannot be done automatically in jags.model() by commenting out inits
% argument...
nChains = 3;
initStruct = struct([]);
for ii = 1:nChains
	initStruct(ii).theta1 = sum(dataStruct.y1)/length(dataStruct.y1);
	initStruct(ii).theta2 = sum(dataStruct.y2)/length(dataStruct.y2);
end
%% RUN THE CHAINS.
parameters		= {'theta1','theta2'};		% The parameter(s) to be monitored.
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
	initStruct, ...                          % Initial values for latent variables
	'doparallel' , doparallel, ...      % Parallelization flag
	'nchains', nChains,...              % Number of MCMC chains
	'nburnin', burnInSteps,...			% Number of burnin steps
	'nsamples', nIter, ...				% Number of samples to extract
	'thin', thinSteps, ...				% Thinning parameter
	'dic', 1, ...                       % Do the DIC?
	'monitorparams', parameters, ...    % List of latent variables to monitor
	'savejagsoutput' , 1 , ...          % Save command line output produced by JAGS?
	'verbosity' , 1 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
	'cleanup' , 0 );                    % clean up of temporary files?


%% EXAMINE THE RESULTS.

mcmcChain		= [samples.theta1];
theta1Sample	= mcmcChain(:);
mcmcChain		= [samples.theta2];
theta2Sample	= mcmcChain(:);

chainlength		= size(mcmcChain,2);

%% Plot the trajectory of the last 500 sampled values.
x = theta1Sample((chainlength-500):chainlength);
y = theta2Sample((chainlength-500):chainlength);
plot(x,y,'bo-','MarkerFaceColor','w','Color',[.7 .7 1]);
axis square;
xlim([-0.1 1.1]);
ylim([-0.1 1.1]);
xlabel('\theta_1');
ylabel('\theta_2');
title('JAGS Results');
set(gca,'TickDir','out');
box off;

%% Display means in plot.
theta1mean = mean(theta1Sample);
theta2mean = mean(theta2Sample);
if theta1mean>0.5
	xpos = 0.1;
	xadj = 'left';
else
	xpos = 0.9;
	xadj = 'right';
end
if theta2mean>0.5
	ypos = 0.1;
	yadj = 'bottom';
else
	ypos = 0.9;
	yadj = 'top';
end
str = ['M=' num2str(theta1mean,3) ',' num2str(theta2mean,3)];
text(xpos,ypos,str,'HorizontalAlignment',xadj,'VerticalAlignment',yadj,'Fontsize',12);

%% Plot a histogram of the posterior differences of theta values.
thetaDiff = theta1Sample - theta2Sample;
figure;
plotPost(thetaDiff ,'xlab','\theta_1-\theta_2','compVal',0);

%% For Exercise 8.5:
% Posterior prediction. For each step in the chain, use the posterior thetas
% to flip the coins.
chainLength = length(theta1Sample);
% Create matrix to hold results of simulated flips:
yPred = NaN(2,chainLength);
for stepIdx = 1:chainLength % step through the chain
  % flip the first coin:
  pHead1 = theta1Sample(stepIdx);
  yPred(1,stepIdx) = binornd(1,pHead1);
  % flip the second coin:
  pHead2 = theta2Sample(stepIdx);
  yPred(2,stepIdx) = binornd(1,pHead2);
end
% Now determine the proportion of times that y1==1 and y2==0
pY1eq1andY2eq0 = sum(yPred(1,:)==1 & yPred(2,:)==0)/chainLength;
disp(pY1eq1andY2eq0);
