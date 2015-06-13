 function postShape = BernBeta(priorShape,dataVec,credMass,saveGr)
% Bayesian updating for Bernoulli likelihood and beta prior.
% Input arguments:
%   priorShape
%     vector of parameter values for the prior beta distribution.
%   dataVec
%     vector of 1's and 0's.
%   credMass
%     the probability mass of the HDI.
% Output:
%   postShape
%     vector of parameter values for the posterior beta distribution.
% Graphics:
%   Creates a three-panel graph of prior, likelihood, and posterior
%   with highest posterior density interval.
% Example of use:
% > postShape = BernBeta( priorShape=c(1,1) , dataVec=c(1,0,0,1,1) )
% You will need to 'source' this function before using it, so R knows
% that the function exists and how it is defined.
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij


clc
close all
% Check for errors in input arguments:
if nargin<1
	priorShape = [1 1];
	priorShape = [4 4];
end
if nargin<2
	dataVec = [1 0 0 1 1];
	dataVec = 1;
end
if nargin<3
	credMass = 0.95;
end
if nargin<4
	saveGr = false;
end
if length(priorShape)~= 2
	disp('priorShape must have two components.')
	return
end
if any(priorShape<=0)
	disp('priorShape components must be positive.')
	return
end
if any(~ismember(dataVec,[0 1]))
	disp('dataVec must be a vector of 1s and 0s.')
	return
end
if credMass<=0 || credMass>=1.0
	disp('credMass must be between 0 and 1.')
	return
end

% Rename the prior shape parameters, for convenience:
a = priorShape(1);
b = priorShape(2);
% Create summary values of the data:
z = sum(dataVec == 1); % number of 1's in dataVec
N = length(dataVec);   % number of flips in dataVec
% Compute the posterior shape parameters:
postShape = [a+z,b+N-z];
% Compute the evidence, p(D):
pData = beta(z+a,N-z+b)/beta(a,b);

% Determine the limits of the highest density interval.
% This uses a home-grown function called HDIofICDF.
hpdLim = HDIofICDF('beta',credMass,1e-08,postShape(1),postShape(2));

% Now plot everything:
% Construct grid of theta values, used for graphing.
binwidth = 0.005; % Arbitrary small value for comb on Theta.
Theta = binwidth/2:binwidth:(1-binwidth/2);
% Compute the prior at each value of theta.
pTheta = betapdf(Theta,a,b);
% Compute the likelihood of the data at each value of theta.
pDataGivenTheta = Theta.^z .* (1-Theta).^(N-z);
% Compute the posterior at each value of theta.
pThetaGivenData = betapdf(Theta,a+z,b+N-z);


% Open a window
figure;
maxY = max([pTheta,pThetaGivenData]); % max y for plotting

% Plot the prior.
subplot(131)
plot(Theta,pTheta,'b-','LineWidth',2);
xlim([0 1]);
ylim([0 maxY]);
xlabel('\theta');
ylabel('p(\theta)');
title('Prior');
axis square;
if a>b
	textx = 0.1;
	algn = 'left';
else
	textx = 0.9;
	algn = 'right';
end
str = ['beta(\theta|' num2str(a) ',' num2str(b) ')'];
text(textx,0.9*max(pThetaGivenData),str,'HorizontalAlignment',algn);

% Plot the likelihood: p(data|theta)
subplot(132)
plot(Theta,pDataGivenTheta,'b-','LineWidth',2);
xlim([0 1]);
ylim([0 1.1*max(pDataGivenTheta)]);
xlabel('\theta');
ylabel('p(D|\theta)');
title('Likelihood');
axis square;
if z>0.5*N
	textx = 0.1;
	algn = 'left';
else
	textx = 0.9;
	algn = 'right';
end
str = ['Data: z=' num2str(z) ', N=' num2str(N)];
text(textx,max(pDataGivenTheta),str,'HorizontalAlignment',algn);

% Plot the posterior.
subplot(133)
plot(Theta,pThetaGivenData,'b-','LineWidth',2);
hold on
xlabel('\Theta');
ylabel('p(\theta|D')
title('Posterior');
xlim([0 1]);
ylim([0 maxY]);
xlabel('\theta');
ylabel('p(\theta)');
title('Prior');
axis square;
if a+z > b+N-z
	textx = 0.1;
	algn = 'left';
else
	textx = 0.9;
	algn = 'right';
end
str = ['beta(\theta|' num2str(a+z) ',' num2str(b+N-z) ')'];
text(textx,0.9*max(pThetaGivenData),str,'HorizontalAlignment',algn);
str = ['p(D)=' num2str(pData,3)];
text(textx,0.75*max(pThetaGivenData),str,'HorizontalAlignment',algn);

% Mark the HDI in the posterior.
hpdHt = mean(betapdf(hpdLim,a+z,b+N-z));
plot(hpdLim([1 1]),[-0.5 hpdHt],'k:');
plot(hpdLim([2 2]),[-0.5 hpdHt],'k:');
plot(hpdLim,[hpdHt hpdHt],'k-');

text(mean(hpdLim),hpdHt,str);

% To save graph
if ispc
print('-depsc','-painter',[mfilename '_' num2str(a) '_' num2str(b) '_' num2str(z) '_' num2str(N)]);
elseif ismac
	print('-depsc','-painters',[mfilename '_' num2str(a) '_' num2str(b) '_' num2str(z) '_' num2str(N)]);

end