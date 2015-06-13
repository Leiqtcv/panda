% function elahe_tmp

%
% function y = modelfun(x,b1,b2)
% y = b1./(1+b2*x);
close all;
clear all; %#ok<CLSCR>

%% Model
% utility-function:
% V(t) = a/(1+b*t) with a reward factor and b discount/impulsivity factor.
% V lies between 0 and 1
% Cost-function:
% J			= 1-V(t) lying between 1 and 0
% (In these experiments t = unknown, yet constant across age?, and a =
% constant)
% In these experiments t = duration percept, and a = constant
% V			= a/(1+b*t)
% J			= 1- a
/(1+b*t) = (1+b*t-1)/(1+b*t) = b*t/(1+b*t)
% We assume b and t depend on age, with V constant (i.e. people respond for
% the same utitility/cost)
% V		= 1/(1+b(age)*t(age))
% V and t are unknown

% The only thing we know is age and t, what is b? Let's assume V =
% constant, across ages
% V		= 1/(1+b(age)*t)
% C					= 1/(1+b(age)*t(age))
% C*(1+b(age)*t)		= 1
% b(age)*t+1		= 1/C
% b(age)*t		= 1/C-1
% b(age)		= (1-C)/(C*t)
% t				= (1-C)/(C*b(age))




age = 0:.1:100;
b	= 1./age;
b = 1-0.01*age;
t	= repmat(10,size(b));
subplot(121)
plot(age,b);
hold on
c = 0.1:0.001:0.9;
n = numel(c);
for ii = 1:n
	C	= repmat(c(ii),size(b));
	y = (1-C)./(C.*t);
	
	plot(age,y,'-');
	[mn,idx] = min(abs(b-y));
	B(ii) = b(idx);
	T(ii) = (1-C(idx))/(C(idx)*b(idx));
end
axis square;
box off

subplot(122)
plot(c,T)
axis square;
box off
return
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
load('graitings'); %load saccade parameters
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