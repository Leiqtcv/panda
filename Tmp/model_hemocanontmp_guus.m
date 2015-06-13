%% Clean
close all
clear all


%% Hemodynamic impulse response
Fs      = 10;
dur     = 50; % sec
xh       = 0:(1/Fs):dur; % sec
a1		= 6; % peak time 4.5 s after stim, shape
b1		= 1; % scale
a2		= 16; % peak time 4.5 s after stim, shape
b2		= 1; % scale
c		= 1/6;
% delta	= 2; % 2s delay
beta	= 0.5;
sigma	= 1;
H       = beta*(gampdf(xh,a1,b1)-c*gampdf(xh,a2,b2));



%% Convolution with stimulus block
Fs      = 10;
dur     = 180; % sec
xx       = 0:(1/Fs):dur; % sec
N		= length(xx);
xx		= xx(1:N);
X		= zeros(N,1);
X((20*Fs:40*Fs))	= 1;
X((80*Fs:100*Fs))	= 1;
X((140*Fs:160*Fs))	= 1;
C       = conv(X,H);
C       = C(1:N);
X_single = X(20*Fs:40*Fs-1);
%% Sinusoid noise
s = 2*sin(2*pi*0.1*xx)';
C = C + s;

%% Convolution size parameters
u = X_single;
v = H;
m = length(u);
n = length(v);

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
dataStruct.y		= y; %
dataStruct.T		= xh;
dataStruct.u		= X_single; % stimulus  block
dataStruct.Ntotal	= length(y);
dataStruct.m		= length(X_single);
dataStruct.n		= length(H);
dataStruct.o		= m+n-1;
dataStruct.onset    = round([20*Fs,80*Fs,140*Fs]);
dataStruct.start    = round(20*Fs);
dataStruct.stimdur  = round(20*Fs);
dataStruct.offset   = dataStruct.onset+dataStruct.stimdur;

dataStruct.Nstim    = 3;
dataStruct.ISI      = 10*Fs-1;
% dataStruct.Totalsize = 
%% INTIALIZE THE CHAINS
nChains		= 3;
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).sigma		= sigma;
	initsStruct(ii).a1			= a1;
	initsStruct(ii).b1			= b1;
	initsStruct(ii).a2			= a2;
	initsStruct(ii).b2			= b2;
	initsStruct(ii).beta		= beta;
end

%% RUN THE CHAINS
parameters		= {'b1','a1','b2','a2','c','sigma','beta','wn'}; % The parameter(s) to be monitored.
burnInSteps		= 1000;		% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 3000;		% Total number of steps in chains to save.
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
model = 'model_hemocanon_guus.txt';
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
b1		= samples.b1;
a1		= samples.a1;
b2		= samples.b2;
a2		= samples.a2;
c		= samples.c;
sigma	= samples.sigma;
beta	= samples.beta;
pred	= samples.wn; % posterior predictive

[m,n,o] = size(pred);
pred	= reshape(pred,m*n,o);

figure(1)
subplot(231)
plot(b1');

subplot(232)
plot(a1');

subplot(233)
plot(sigma');

subplot(234)
plot(b2');

subplot(235)
plot(a2');

subplot(236)
plot(c');

%%
b1		= b1(:);
a1		= a1(:);
b2		= b2(:);
a2		= a2(:);
c		= c(:);
sigma	= sigma(:);
beta	= beta(:);
% delta	= delta(:);

figure(2)
subplot(231)
plotPost(b1,'showMode',true);
xlabel('b1');

subplot(232)
plotPost(a1,'showMode',true);
xlabel('a1');

subplot(233)
plotPost(sigma,'showMode',true);
xlabel('sigma');

subplot(234)
plotPost(b2,'showMode',true);
xlabel('b2');

subplot(235)
plotPost(a2,'showMode',true);
xlabel('a2');

subplot(236)
plotPost(beta);
xlabel('beta');


% %%
% figure(3)
% subplot(221)
% plot(a1,b1,'k.');
% axis square
% box off
% set(gca,'TickDir','out');
% xlim([0.8*min(a1) 1.2*max(a1)]);
% ylim([0.8*min(b1) 1.2*max(b1)]);
% 
% subplot(222)
% plot(a1,beta,'k.');
% axis square
% box off
% set(gca,'TickDir','out');
% xlim([0.8*min(a1) 1.2*max(a1)]);
% ylim([0.8*min(beta) 1.2*max(beta)]);
% 
% subplot(223)
% plot(b1,beta,'k.');
% axis square
% box off
% set(gca,'TickDir','out');
% xlim([0.8*min(b1) 1.2*max(b1)]);
% ylim([0.8*min(beta) 1.2*max(beta)]);
% 
% subplot(224)
% plot(a1,sigma,'k.');
% axis square
% box off
% set(gca,'TickDir','out');
% xlim([0.8*min(a1) 1.2*max(a1)]);
% ylim([0.8*min(sigma) 1.2*max(sigma)]);
%%
x       = 0:(1/Fs):dur; % sec
figure(4)
plot(x,y,'k-','LineWidth',2)

hold on
for idx = 1:numSavedSteps
	hpred   = beta(idx)*(gampdf(x,a1(idx),b1(idx))-c(idx)*gampdf(x,a2(idx),b2(idx)));
	ypred       = conv(X,hpred);
	ypred       = ypred(1:N);
	plot(x,ypred,'k-','Color',[.7 .7 .7]);
end
axis square
box off
set(gca,'TickDir','out');

