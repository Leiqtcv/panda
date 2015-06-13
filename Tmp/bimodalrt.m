close all
clear all

mur = 4;
sdr = 1;
dS = 1;
n = 100;
r = mur+sdr*randn([n,1]);
r(r<1) = [];
n = numel(r);

figure
subplot(212);
plot([0 100],[0 0],'k-');
hold on

T = 1000*dS./r;

x = [repmat(100,[n,1]) 100+T];
y = [zeros(n,1) ones(n,1)];

whos x y T r
subplot(212)
plot(x',y','k-');
xlim([0 1000]);

subplot(211)
hist(100+T);
xlim([0 1000]);


w = pa_oct2bw(0.5,0:1:7);
w		= [-w w];
[r,w]	= meshgrid(r,w);
r		= r(:);
w		= w(:);


P = 1./w;
l = 0.18*abs(P)*1000;



T = 1000*dS./r+l+100;

% figure
% hist(T)
% return
Tinv = 1000./T;


%%
uw = unique(w);
nw = numel(uw);
for ii = 1:nw
	sel = w==uw(ii);
	muT(ii) = 1./mean(1000./T(sel));
end

%%
figure;
subplot(221)
plot(w,l,'k.','MarkerFaceColor','w');
axis square
box off
set(gca,'TickDir','out','XTick',unique(w));

subplot(222)
plot(P,l,'k.','MarkerFaceColor','w');
axis square
box off
set(gca,'TickDir','out','XTick',unique(P));



% T = 1./Tinv;
subplot(223)
plot(P,Tinv,'k.','MarkerFaceColor','w');
hold on
plot(1./uw,1./muT,'ko-','MarkerFaceColor','w');
axis square
box off
set(gca,'TickDir','out','XTick',unique(P));


%% Bayes
return
model = 'AMmodel.txt';
%% Data
dataStruct.y		= T/1000;
dataStruct.omega	= w;
dataStruct.dS		= 1;
dataStruct.Ntotal	= numel(T);

%% INTIALIZE THE CHAINS.
% mur = 2;
% sdr = 0.5;
nChains		= 4;
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).murt			= 3;
	initsStruct(ii).sigmar			= 1;
	initsStruct(ii).lambda			= 0.2;
end

%% RUN THE CHAINS
parameters		= {'mur','sigmar','lambda'}; % The parameter(s) to be monitored.
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
% 	toc

% keyboard