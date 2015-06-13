% BayesUpdate
%
% Bayesian updating
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

close all
clear all

% Theta is the vector of candidate values for the parameter theta.
% nThetaVals is the number of candidate theta values.
% To produce the examples in the book, set nThetaVals to either 3 or 63.
nThetaVals = 3;
% Now make the vector of theta values:
Theta = (1:nThetaVals)/(nThetaVals+1);

% pTheta is the vector of prior probabilities on the theta values.
pTheta = min([Theta; 1-Theta]); % Makes a triangular belief distribution.
pTheta = pTheta/sum(pTheta);  % Makes sure that beliefs sum to 1.

% stem(Theta,pTheta,'Marker','none','LineWidth',2,'Color','b');
% xlim([0 1]);
% axis square;

% Specify the data. To produce the examples in the book, use either
% Data = c(rep(1,3),rep(0,9)) or Data = c(rep(1,1),rep(0,11)).
Data	= [ones(1,3) zeros(1,9)];
nHeads	= sum(Data);
nTails	= length(Data) - nHeads;

% Compute the likelihood of the data for each value of theta:
pDataGivenTheta = Theta.^nHeads .* (1-Theta).^nTails; % Bernouilli

% Compute the posterior:
pData			= sum(pDataGivenTheta.*pTheta);
pThetaGivenData = pDataGivenTheta.*pTheta/pData;   % This is Bayes' rule!

% Plot the results.
figure(1)

% Plot the prior:
subplot(131)
stem(Theta,pTheta,'k-','Marker','None','LineWidth',2,'Color','b');
title('Prior');
xlabel('\theta');
ylabel('p(\theta)');
xlim([0 1]);
ylim([0 1.1*max(pThetaGivenData)]);
axis square;

% Plot the likelihood:
subplot(132)
stem(Theta,pDataGivenTheta,'k-','Marker','None','LineWidth',2,'Color','b');
title('Likelihood');
xlabel('\theta');
ylabel('p(D|\theta)');
xlim([0 1]);
ylim([0 1.1*max(pDataGivenTheta)]);
axis square;
text(.55,.85*max(pDataGivenTheta),['D=' num2str(nHeads) 'H,' num2str(nTails) 'T']);

% Plot the posterior:
subplot(133)
stem(Theta,pThetaGivenData,'k-','Marker','None','LineWidth',2,'Color','b');
title('Posterior');
xlabel('\theta');
ylabel('p(\theta|D)');
xlim([0 1]);
ylim([0 1.1*max(pThetaGivenData)]);
axis square;
text(.55,.85*max(pThetaGivenData),['p(D)=' num2str(pData,3)]);

% To save graph
if ispc
	print('-depsc','-painter',mfilename);
elseif ismac
	print('-depsc','-painters',mfilename);
end