%% Clean
close all
clear all



%% Hemodynamic impulse response
Fs      = 10;
dur     = 10; % sec
xh       = 0:(1/Fs):dur; % sec
a		= 4.30; % peak time 4.5 s after stim, shape
b		= 0.75; % scale
beta	= 0.5;
sigma	= 1;
H       = beta*gampdf(xh,a,b);

%% Convolution with stimulus block
Fs      = 10;
dur     = 180; % sec
xx       = 0:(1/Fs):dur; % sec
N		= length(xx);
xx		= xx(1:N);
X		= zeros(N,1);
X((20*Fs:40*Fs))	= 1;
X((80*Fs:100*Fs))	= 1;
C       = conv(X,H);
C       = C(1:N);

%% Sinusoid noise
s = 1*sin(2*pi*0.1*xx)';
C = C + s;

%% Convolution size parameters
u = X;
v = H;
m = length(u);
n = length(v);
o = m+n-1;

%% Graph
figure(666)
subplot(131)
plot(xh,H)
xlabel('Time (s)');
ylabel('\Delta [OHb] (\muM)');
axis square
box off

subplot(132)
plot(xx,X);
axis square
box off

subplot(133)
plot(xx,C);
axis square
box off

drawnow
%% Data
y					= C+sigma*randn(size(C));
Fs					= 10;
dur					= 180; % sec
dataStruct.y		= y;
dataStruct.T		= xx;
dataStruct.u		= X; % stimulus  block
dataStruct.Ntotal	= length(y);
dataStruct.m		= length(X);
dataStruct.n		= length(H);
dataStruct.o		= m+n-1;

%% INTIALIZE THE CHAINS
nChains		= 3;
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).sigma		= sigma;
	initsStruct(ii).a			= a;
	initsStruct(ii).b			= b;
	initsStruct(ii).beta		= beta;
end

%% RUN THE CHAINS
parameters		= {'b','a','sigma','beta','wn'}; % The parameter(s) to be monitored.
burnInSteps		= 1000;		% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 1000;		% Total number of steps in chains to save.
thinSteps		= 1;		% Number of steps to 'thin' (1=keep every step).
nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
doparallel		= 1; % do not use parallelization
if doparallel
	isOpen = matlabpool('size') > 0;
	if ~isOpen
		matlabpool open
	end
end
fprintf( 'Running JAGS...\n' );
% [samples, stats, structArray] = matjags( ...
% 	tic
model = 'model_hemo.txt';
[samples,stats,structArray] = pa_matjags(...
	dataStruct,...                     % Observed data
	fullfile(pwd, model), ...			% File that contains model definition
	initsStruct,...                    % Initial values for latent variables
	'doparallel',doparallel, ...      % Parallelization flag
	'nchains',nChains,...              % Number of MCMC chains
	'nburnin',burnInSteps,...          % Number of burnin steps
	'nsamples',nIter,...				% Number of samples to extract
	'thin',thinSteps,...              % Thinning parameter
	'monitorparams',parameters, ...    % List of latent variables to monitor
	'savejagsoutput',1,...          % Save command line output produced by JAGS?
	'verbosity',0,...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
	'cleanup',0);                    % clean up of temporary files?


%%
b		= samples.b;
a		= samples.a;
sigma	= samples.sigma;
beta	= samples.beta;
pred	= samples.wn; % posterior predictive

[m,n,o] = size(pred);
pred	= reshape(pred,m*n,o);

figure(1)
subplot(131)
plot(b');

subplot(132)
plot(a');

subplot(133)
plot(sigma');

%%
b		= b(:);
a		= a(:);
sigma	= sigma(:);
beta	= beta(:);

figure(2)
subplot(221)
plotPost(b,'showMode',true);
xlabel('b');

subplot(222)
plotPost(a,'showMode',true);
xlabel('a');

subplot(223)
plotPost(sigma,'showMode',true);
xlabel('sigma');

subplot(224)
plotPost(beta);
xlabel('beta');

%%
figure(3)
subplot(221)
plot(a,b,'k.');
axis square
box off
set(gca,'TickDir','out');
xlim([0.8*min(a) 1.2*max(a)]);
ylim([0.8*min(b) 1.2*max(b)]);

subplot(222)
plot(a,beta,'k.');
axis square
box off
set(gca,'TickDir','out');
xlim([0.8*min(a) 1.2*max(a)]);
ylim([0.8*min(beta) 1.2*max(beta)]);

subplot(223)
plot(b,beta,'k.');
axis square
box off
set(gca,'TickDir','out');
xlim([0.8*min(b) 1.2*max(b)]);
ylim([0.8*min(beta) 1.2*max(beta)]);

subplot(224)
plot(a,sigma,'k.');
axis square
box off
set(gca,'TickDir','out');
xlim([0.8*min(a) 1.2*max(a)]);
ylim([0.8*min(sigma) 1.2*max(sigma)]);
%%
x       = 0:(1/Fs):dur; % sec
figure(4)
plot(x,y,'k-','LineWidth',2)

hold on
for idx = 1:numSavedSteps
	hpred   = beta(idx)*gampdf(x,a(idx),b(idx));
	ypred       = conv(X,hpred);
	ypred       = ypred(1:N);
	plot(x,ypred,'k-','Color',[.7 .7 .7]);
end
axis square
box off
set(gca,'TickDir','out');

