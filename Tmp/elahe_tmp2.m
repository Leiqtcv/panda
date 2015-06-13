% function elahe_tmp

%
% function y = modelfun(x,b1,b2)
% y = b1./(1+b2*x);
close all;
clear all; %#ok<CLSCR>

%% THE MODEL.
str = ['model {\r\n',...
	'\tfor( i in 1 : Ndata ) {\r\n',...
	'\t\ty[i] ~ dgamma( mu[i] , tau ) \r\n',...
	'\t\tmu[i] <- beta0 + beta1 * x[i]\r\n',...
	'\t}\r\n',...
	'\tbeta0 ~ dnorm( 0 , 1.0E-12 )\r\n',...
	'\tbeta1 ~ dnorm( 0 , 1.0E-12 )\r\n',...
	'\ttau ~ dgamma( 0.001 , 0.001 )\r\n',...
	'}\r\n',...
	];

% Write the modelString to a file, using Matlab commands:
fid			= fopen('model.txt','w');
fprintf(fid,str);
fclose(fid);


%% THE DATA.
cd('/Users/marcw/DATA/Student/Elahe');
% load('graitings'); %load saccade parameters
load('allSubject');
% [#Percept, Duration, #subject, Age, #Session]
dur		= allSubject(:,2);
percept = allSubject(:,1);
subject = allSubject(:,3);
age		= allSubject(:,4);
rate	= 1./dur;

usubject = unique(subject);
nsubject = numel(usubject);

A = NaN(nsubject,1);
B = A;
X = A;
Mrate = A;
for ii = 1:nsubject
	sel = subject==usubject(ii);
	Y	= rate(sel);
	[parmhat] = gamfit(Y);
	A(ii) = parmhat(1);
	B(ii) = parmhat(2);
	X(ii) = unique(age(sel));
	Mrate(ii) = mean(rate(sel));
	
% 	xi = 0:.1:10;
% 	N = hist(Y,xi);
% 	N = N./sum(N);
% 	P = gampdf(xi,A(ii),B(ii));
% 	P = P./sum(P);
% 	figure(1)
% 	clf
% 	plot(xi,N);
% 	hold on
% 	plot(xi,P);
% 	xlim([0 3]);
% 	drawnow
	
end

[M,V] = gamstat(A,B);

cnt = 10:80;
n = numel(cnt);
sd = 5;
mu = NaN(size(cnt));
for ii = 1:n
	p = normpdf(age,cnt(ii),sd);
	p = p.*rate/sum(p);
	mu(ii) = sum(p);
end
plot(cnt,mu,'k-','Color',[.7 .7 .7]);

hold on
plot(age,rate,'.','Color',[.8 .8 .8])
hold on




cnt = 10:80;
n = numel(cnt);
sd = 4;
mu = NaN(size(cnt));
for ii = 1:n
	p = normpdf(X,cnt(ii),sd);
	p = p.*M/sum(p);
	mu(ii) = sum(p);
end
plot(cnt,mu,'k-');
plot(X,M,'ko','MarkerFaceColor','w');
% plot(X,smooth(M,20),'k-','LineWidth',2);

% errorbar(X,M,V,'ko','MarkerFaceColor','w');
ylim([0 1]);
xlim([0 90]);
axis square
box off
xlabel('Age (years)');
ylabel('Rate (s^{-1})');
set(gca,'TickDir','out');
% lsline
return
figure(2);
scatter(A,B,X.^1.2,X,'filled')
hold on
scatter(A,B,X.^1.2,'k')
set(gca,'XScale','log','YScale','log')
axis square
xlabel('Shape');
ylabel('Scale');
xlim([0.25 32]);
ylim([1e-2 1]);
set(gca,'XTick',pa_oct2bw(1,-2:5),'XTickLabel',pa_oct2bw(1,-2:5));
set(gca,'YTick',pa_oct2bw(0.1,-5:3),'YTickLabel',pa_oct2bw(0.1,-5:3));

return
%% Duration 

t	= 0:.5:100;
N	= hist(dur,t); % histogram
N	= N./sum(N);
F	= ksdensity(dur,t)/2; % estimated kernel density functiond

P = gamfit(dur); % gamma density function fit
Y = gampdf(t,P(1),P(2))/2;

% graphics
figure(1)
subplot(221)
plot(t,N,'-');
hold on
plot(t,F);
plot(t,Y);
axis square;
box off;
xlim([0 40])
set(gca,'TickDir','out','XTick',0:10:30,'YTick',0:0.05:0.2);
xlabel('Duration Percept');
ylabel('Probability');

%% Rate (1/duration)
t	= 1/100:0.1:2;
N	= hist(rate,t); % histogram
N	= N./sum(N);
F	= ksdensity(rate,t)/10; % estimated kernel density functiond
P	= gamfit(rate); % gamma density function fit
Y	= gampdf(t,P(1),P(2))/10;

% graphics
figure(1)
subplot(222)
plot(t,N,'-');
hold on
plot(t,F);
plot(t,Y);
axis square;
box off;
xlim([0 2])
set(gca,'TickDir','out');
xlabel('Rate Percept');
ylabel('Probability');



subplot(223)
plot(age,dur,'k.');
axis square;
box off;
xlim([0 100])
set(gca,'TickDir','out');
xlabel('Rate Percept');
ylabel('Probability');
lsline;

figure
% rate = dur;
plot(age,rate,'k.');
axis square;
box off;
xlim([0 100])
set(gca,'TickDir','out');
xlabel('Rate Percept');
ylabel('Probability');
% lsline;

[b,dev,stats] = glmfit(age,rate,'gamma','link','identity');

x = 1:100;
[yhat,dylo,dyhi] = glmval(b,x,'identity',stats);
hold on
plot(x,yhat,'-');
plot(x,yhat-dylo,'-');
plot(x,yhat+dyhi,'-');
ylim([0 1])
return
x		= Graitings(1,:)';
y		= Graitings(2,:)';
nSubj	= numel(x);

% Specify data, as a structure
dataStruct.x		= x;
dataStruct.y		= y;
dataStruct.Ndata	= nSubj;

%% INTIALIZE THE CHAINS.
nChains		= 3;                   % Number of chains to run.
r			= corrcoef(x,y);
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).beta0		= 0;    % because data are standardized
	initsStruct(ii).beta1		= r(2);        % because data are standardized
	initsStruct(ii).tau			= 1/(1-r(2)^2);  % because data are standardized
end

%% RUN THE CHAINS
parameters		= {'beta0' , 'beta1' , 'tau'};		% The parameter(s) to be monitored.
% adaptSteps		= 500;			% Number of steps to 'tune' the samplers.
burnInSteps		= 500;			% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 5000;		% Total number of steps in chains to save.
thinSteps		= 10;			% Number of steps to 'thin' (1=keep every step).
nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
doparallel		= 1; % do not use parallelization
if doparallel
	isOpen = matlabpool('size') > 0; %#ok<*DPOOL>
	if ~isOpen
		matlabpool open
	end
end
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

% fnames = fieldnames(samples);
% n = numel(fnames)-1;
% for ii = 1:n
% 	% thetaSample = reshape(mcmcChain,[numSavedSteps+1 nCoins]);
% 	ns = ceil(sqrt(n));
% 	figure(1)
% 	subplot(ns,ns,ii)
% 	s		= samples.(fnames{ii});
% 	s		= s(1:16667);
% 	s		= zscore(s);
% 	maxlag	= 35;
% 	[c,l]	= xcorr(s,maxlag,'coeff');
% 	h		= stem(l(maxlag:end),c(maxlag:end),'k-');
% 	xlim([-1 maxlag]);
% 	set(h,'MarkerEdgeColor','none');
% 	axis square;
% 	box off
% 	set(gca,'TickDir','out');
% 	str = fnames{ii};
% 	xlabel('Lag');
% 	ylabel('Autocorrelation');
% 	title(str);
% 	%   show( gelman.diag( codaSamples ) )
% 	%   effectiveChainLength = effectiveSize( codaSamples )
% 	%   show( effectiveChainLength )
% end

%% Extract chain values:
b0		= [samples.beta0];
b1		= [samples.beta1];
bTau	= [samples.tau];
b0		= b0(:);
b1		= b1(:);
bTau	= bTau(:);
sigma	= 1./bTau;


%
% Posterior prediction:
% Specify x values for which predicted y's are needed:
xPostPred		= 0:100;
% Define matrix for recording posterior predicted y values at each x value.
% One row per x value, with each row holding random predicted y values.
postSampSize	= length(b1);
yPostPred		= NaN(length(xPostPred),postSampSize);
% Define matrix for recording HDI limits of posterior predicted y values:
yHDIlim			= NaN(length(xPostPred),2);

% Generate posterior predicted y values.
% This gets only one y value, at each x, for each step in the chain.
for chainIdx = 1:postSampSize
	mu	= b0(chainIdx) + b1(chainIdx)*xPostPred;
	sd		= sigma(chainIdx);
	yPostPred(:,chainIdx) = gamrnd(mu,sd,size(xPostPred));
end

for xIdx = 1:length(xPostPred)
	yHDIlim(xIdx,:) = HDIofMCMC(yPostPred(xIdx,:));
end

%%
% Display believable beta0 and b1 values
thinIdx = round(linspace(1,length(b0),700));

figure(2);
subplot(131)
plot( b1(thinIdx),b0(thinIdx),'.','Color',[.7 .7 1]);
ylabel('Intercept');
xlabel('Slope');
axis square;
set(gca,'TickDir','out');
box off;

% Display the posterior of the b1:
subplot(132)
plotPost(b1,'xlab','Slope','compVal',0);

subplot(133)
plotPost(b0,'xlab','Intercept','compVal',0);

%% Display data with believable regression lines and posterior predictions.
% Plot data values:
xRang		= max(x)-min(x);
yRang		= max(y)-min(y);
limMult		= 0.25;
xL		= [min(x)-limMult*xRang , max(x)+limMult*xRang];
figure(3);
plot(x,y,'ko','MarkerFaceColor','w','LineWidth',2);
hold on
% xlim(xL);
% ylim(yL);
xlabel('X');
ylabel('Y');
title('Data with credible regression lines');
axis square
box off
set(gca,'TickDir','out');
% Superimpose a smattering of believable regression lines:
for ii =  round(linspace(1,length(b0),50))
	A		= b0(ii)+b1(ii)*[0 100];
	B		= sigma(ii);
	[M,V]	= gamstat(A,B);
	h		= plot([0 100],M,'k-');
	set(h,'Color',[.7 .7 1]);
end
pa_horline(0,'k:');

% Display data with HDIs of posterior predictions.
% Plot data values:
yL = [min(yHDIlim(:)) , max(yHDIlim(:))];
xlabel('Age (years)');
ylabel('Average percept duration (s)');
title('Data with 95% HDI & Mean of Posterior Predictions & believable regression lines');
axis square
box off
set(gca,'TickDir','out');


X	= xPostPred;
Y	= mean(yPostPred,2);
E	= yHDIlim';
pa_errorpatch(X,Y,E,'b');
box off
plot(x,y,'ko','MarkerFaceColor','w','LineWidth',2);
plot(X,Y,'k-','LineWidth',2);

%%
pa_datadir;
print('-depsc','-painters',mfilename);