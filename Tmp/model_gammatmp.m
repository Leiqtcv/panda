%% Test spike

close all
clear all

%% Test 1


Fs      = 10;
dur     = 10; % sec
x       = 0:(1/Fs):dur; % sec

a		= 4.30; % peak time 4.5 s after stim, shape
b		= 0.75; % scale
sigma	= 0.1;
y       = gampdf(x,a,b);
y		= y+sigma*randn(size(y));

figure(666)
subplot(221)
plot(x,y)
xlabel('Time (s)');
ylabel('\Delta [OHb] (\muM)');


r			= a;
lambda		= 1;
aprior		= r; % peak time 4.5 s after stim, shape
bprior		= 1/lambda; % scale
prior       = gampdf(x,aprior,bprior);

subplot(223)
plot(x,prior)
xlabel('Prior a');
ylabel('Probability');

r			= b;
lambda		= 1;
aprior		= r; % peak time 4.5 s after stim, shape
bprior		= 1/lambda; % scale
prior       = gampdf(x,aprior,bprior);

subplot(224)
plot(x,prior)
xlabel('Prior b');
ylabel('Probability');

% return
%% Data
dataStruct.y		= y;
dataStruct.x		= x;
dataStruct.Ntotal	= length(y);

%% INTIALIZE THE CHAINS

nChains		= 4;
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).sigma		= sigma;
	initsStruct(ii).a			= a;
	initsStruct(ii).b			= b;
end


%% RUN THE CHAINS
parameters		= {'b','a','sigma','g'}; % The parameter(s) to be monitored.
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
model = 'model_gamma.txt';
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
a	= samples.a;
sigma	= samples.sigma;

figure(1)
subplot(131)
plot(b');

subplot(132)
plot(a');

subplot(133)
plot(sigma');

%%
b = b(:);
a = a(:);
sigma = sigma(:);


figure(2)
subplot(221)
plotPost(b,'showMode',true);

subplot(222)
plotPost(a,'showMode',true);

subplot(223)
plotPost(sigma);

% subplot(224)
% col = pa_statcolor(64,[],[],[],'def',6);
% col = col(:,[3 2 1]);
% colormap(col);
%  [N,C] = hist3([a b],{0:1:20 0:.1:10});
%   imagesc(C{1},C{2},N)
%   xlabel('a');
%   ylabel('b');
% % plot(b,a,'.');
% box off
% set(gca,'TickDir','out','YDir','normal');
% axis square
%%
x       = 0:(1/Fs):dur; % sec
% figure(3)
subplot(224)
plot(x,y,'k-','LineWidth',2)

hold on
for idx = 1:numSavedSteps
ypred   = gampdf(x,a(idx),b(idx));
plot(x,ypred,'k-','Color',[.7 .7 .7]);
end
axis square
box off
set(gca,'TickDir','out');

%%
return
d = 'E:\DATA\Studenten\Guus\LR-1705';
cd(d);
fname = 'processed_nirs_data_LR-1705-2013-10-14-0001';

load(fname);
whos
O = nirs_data.processed_data(2,:);
S = nirs_data.stimulus;

% plot(O)
% hold on
% plot(S')
% T81

y		= nirs_data.processed_data(2,:);
xa		= nirs_data.stimulus(1,:)+nirs_data.stimulus(3,:);
xv		= nirs_data.stimulus(2,:)+nirs_data.stimulus(3,:);
xav		= nirs_data.stimulus(3,:);
Ntotal	= length(y);

%% Data
dataStruct.y		= y;
dataStruct.xa		= xa;
dataStruct.xv		= xv;
dataStruct.xav		= xav;
dataStruct.Ntotal	= Ntotal;

%% INTIALIZE THE CHAINS
b = regstats(dataStruct.y,dataStruct.x,'linear',{'beta','r'});
% G = 1 - sigma^2/p^2;
% sigma = v/o
%
G = b.beta(2);
sigma = std(b.r);
sigmaP = -sigma/(G-1);
sigmaL = sigma;

nChains		= 4;
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).sigmaL			= sigmaL;
	initsStruct(ii).sigmaP			= sigmaP;
end

%% RUN THE CHAINS
parameters		= {'b','a','sigma'}; % The parameter(s) to be monitored.
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
model = 'model_nirshrf.txt';
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
