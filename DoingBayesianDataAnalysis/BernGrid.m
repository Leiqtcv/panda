function pThetaGivenData = BernGrid(Theta,pTheta,Data,credib,nToPlot)
% BERNGRID(THETA,PTHETA,DATA,CREDIB,N2PLOT)
%
% Bayesian updating for Bernoulli likelihood and prior specified on a grid.
% Input arguments:
%  Theta is a vector of theta values, all between 0 and 1.
%  pTheta is a vector of corresponding probability _masses_.
%  Data is a vector of 1's and 0's, where 1 corresponds to a and 0 to b.
%  credib is the probability mass of the credible interval, default is 0.95.
%  nToPlot is the number of grid points to plot; defaults to all of them.
% Output:
%  pThetaGivenData is a vector of posterior probability masses over Theta.
%  Also creates a three-panel graph of prior, likelihood, and posterior
%  probability masses with credible interval.
% Example of use:
%  % Create vector of theta values.
%  > binwidth = 1/1000
%  > thetagrid = seq( from=binwidth/2 , to=1-binwidth/2 , by=binwidth )
%  % Specify probability mass at each theta value.
%  > relprob = pmin(thetagrid,1-thetagrid) % relative prob at each theta
%  > prior = relprob / sum(relprob) % probability mass at each theta
%  % Specify the data vector.
%  > datavec = c( rep(1,3) , rep(0,1) ) % 3 heads, 1 tail
%  % Call the function.
%  > posterior = BernGrid( Theta=thetagrid , pTheta=prior , Data=datavec )
% Hints:
%  You will need to "source" this function before calling it.
%  You may want to define a tall narrow window before using it; e.g.,
%  > source("openGraphSaveGraph.R")
%  > openGraph(width=7,height=10,mag=0.7)
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij


%% Check input
if nargin<1
	binwidth	= 1/1000;
	Theta		= (binwidth/2):binwidth:(1-binwidth/2);
end
if nargin<2
	% Specify probability mass at each theta value.
	relprob = min([Theta;1-Theta]); % relative prob at each theta
	pTheta	= relprob./sum(relprob); % probability mass at each theta
end
if nargin<3
	% Specify the data vector.
	Data = [ones(1,3) zeros(1,1)]; % 3 heads, 1 tail
end
if nargin<4
	credib = 0.95;
end
if nargin<5
	nToPlot = length(Theta);
end
%% Exercise 7.3B
% binwidth	= 1/1000;
% Theta		= binwidth/2:binwidth:1-binwidth/2;
% pTheta		= (cos(4*pi*Theta)+1).^2;
% pTheta		= pTheta./sum(pTheta);
% Data		= [ones(1,8) zeros(1,4)]; % 8 heads, 4 tail

%% Create summary values of Data
z = sum(Data==1); % number of 1's in Data
N = length(Data); % number of flips in Data
% Compute the likelihood of the Data for each value of Theta.
pDataGivenTheta = Theta.^z.*(1-Theta).^(N-z);
% Compute the evidence and the posterior.
pData			= sum( pDataGivenTheta.*pTheta);
pThetaGivenData = pDataGivenTheta.*pTheta/pData; % Bayes rule


% Plot the results.
close all
clc
figure;
plot(Theta,pThetaGivenData);
% If the comb has a zillion teeth, it's too many to plot, so plot only a
% thinned out subset of the teeth.
nteeth = length(Theta);

if nteeth>nToPlot
	thinIdx = 1:round(nteeth/nToPlot):nteeth;
	if length(thinIdx)<length(Theta)
		thinIdx = [thinIdx,nteeth];% makes sure last tooth is included
	end
else
	thinIdx = 1:nteeth;
end
%% Plot the prior.
meanTheta = sum(Theta.*pTheta); % mean of prior, for plotting
subplot(131)
plot(Theta(thinIdx),pTheta(thinIdx),'b.','Color',[.7 .7 1]);
hold on
% stem(Theta(thinIdx),pTheta(thinIdx),'b-','Marker','none');

xlim([0 1]);
ylim([0 1.1*max(pThetaGivenData)]);
axis square
xlabel('\theta');
ylabel('p(\theta)');
title('Prior');
if meanTheta>0.5
	textx = 0.1;
	algn = 'left';
else
	textx = 0.9;
	algn = 'right';
end
str = ['mean(\theta)=' num2str(meanTheta,3)];
text(textx,max(pThetaGivenData),str,'HorizontalAlignment',algn);

%% Plot the likelihood: p(Data|Theta)
subplot(132)
plot(Theta(thinIdx),pDataGivenTheta(thinIdx),'b.','Color',[.7 .7 1]);
xlim([0 1]);
ylim([0 1.1*max(pDataGivenTheta)]);
axis square
xlabel('\theta');
ylabel('p(D|\theta)');
title('Likelihood');
if z>0.5*N
	textx = 0.1;
	algn = 'left';
else
	textx = 0.9;
	algn = 'right';
end
str = ['Data: z=' num2str(z) ',N=' num2str(N)];
text(textx,max(pDataGivenTheta),str,'HorizontalAlignment',algn);


%% Plot the posterior.
meanThetaGivenData = sum(Theta.*pThetaGivenData);
subplot(133)
plot(Theta(thinIdx),pThetaGivenData(thinIdx),'b.','Color',[.7 .7 1]);
hold on
xlim([0 1]);
ylim([0 1.1*max(pThetaGivenData)]);
axis square
xlabel('\theta');
ylabel('p(\theta|D)');
title('Prior');
if meanThetaGivenData>0.5
	textx = 0.1;
	algn = 'left';
else
	textx = 0.9;
	algn = 'right';
end
str = ['mean(\theta|D)=' num2str(meanThetaGivenData,3)];
text(textx,max(pThetaGivenData),str,'HorizontalAlignment',algn);
str = ['p(D)=' num2str(pData,3)];
text(textx,0.75*max(pThetaGivenData),str,'HorizontalAlignment',algn);

% Mark the highest density interval. HDI points are not thinned in the plot.
HDIinfo = HDIofGrid(pThetaGivenData,credib);
plot(Theta(HDIinfo.idx),HDIinfo.height,'k-');
str		= [num2str(100*HDIinfo.mass,3) '% HDI'];
text(mean(Theta(HDIinfo.idx)),HDIinfo.height,str,'HorizontalAlignment','center','VerticalAlignment','bottom');

% Mark the left and right ends of the waterline.
% Find indices at ends of sub-intervals:
inLim = HDIinfo.idx(1); % first point

for ii = 2:length(HDIinfo.idx)-1
	if HDIinfo.idx(ii) ~= HDIinfo.idx(ii-1)+1 || HDIinfo.idx(ii) ~= HDIinfo.idx(ii+1)-1
		inLim = [inLim HDIinfo.idx(ii)]; %#ok<AGROW>
	end
end
inLim = [inLim HDIinfo.idx(length(HDIinfo.idx))];

% Mark vertical lines at ends of sub-intervals:
for ii = inLim
	plot([Theta(ii) Theta(ii)],[-0.5 HDIinfo.height],'k:');
	str = num2str(Theta(ii),3);
	text(Theta(ii),HDIinfo.height,str,'HorizontalAlignment','center','VerticalAlignment','bottom');
end

