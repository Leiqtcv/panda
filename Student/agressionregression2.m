function agressionregression2


%% THE MODEL. Robust regression


close all
%% THE DATA.

% http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3304483/
% data obtained via grabit.m
load('Data001.mat'); % Left
x1 = Data001(:,1); %#ok<*NODEF>
y1 = Data001(:,2);

load('Data002.mat'); % Right
x2 = Data002(:,1);
y2 = Data002(:,2);

load('Data003.mat'); % Sham
x3 = Data003(:,1);
y3 = Data003(:,2);

% n = 50;
% x1 = randn(n,1);
% y1 = -10*x1 +0.2*randn(n,1)+3;
% x2 = randn(n,1);
% y2 = 0*x2 +0.5*randn(n,1)+3;
% x3 = randn(n,1);
% y3 = 0*x3 +0.5*randn(n,1)+3;

%% Simple linear regression and graphs
figure;
subplot(221)
plot(x1,y1,'.');
hold on
axis square
lsline;
b = regstats(y1,x1);
title(b.beta(2));

subplot(222)
plot(x2,y2,'.');
hold on
axis square
lsline;
b = regstats(y2,x2);
title(b.beta(2));

subplot(223)
plot(x3,y3,'.');
hold on
axis square
lsline;
b = regstats(y3,x3);
title(b.beta(2));
% return
xMet1	= [x1; x2; x3];
y		= [y1; y2; y3];
xNom1		= [ones(size(x1)); repmat(2,size(x2)); repmat(3,size(x3))];

subplot(224)
plot(xMet1,y,'.');
hold on
axis square
lsline;
b = regstats(y,xMet1);
title(b.beta(2));

%% Labels
names.x1	= {'Left','Right','Sham'};

% Normalize, for JAGS MCMC sampling, e.g. to use cauchy(0,1) prior
[z,yMorig,ySDorig]	= pa_zscore(y');
[zMet,~,metSD]		= pa_zscore(xMet1');

%%
Nnom = 1;
Nmet = 1;
xmet(1).Nom = 1;
model = 'model.txt';
pa_bayes_ancovamodel(model,Nnom,Nmet,xmet)

%% Data
dataStruct = dataconstruct(y,z,zMet,xNom1,Nnom);
dataStruct.tdfGain = 1;

%%
% 		keyboard
%% Initialize chains
nChains		= 4;
initsStruct = initconstruct(dataStruct,xmet,Nnom,nChains);

%% RUN THE CHAINS
parameters		= {'b0','b1',...
	'bMet1','bMet0'...
	'b0prior','b1prior',...
	'bMet1prior','bMet0prior'...
	}; % The parameter(s) to be monitored.
% adaptSteps		= 500;			% Number of steps to 'tune' the samplers.
burnInSteps		= 1000;			% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 10000;		% Total number of steps in chains to save.
thinSteps		= 1;			% Number of steps to 'thin' (1=keep every step).
nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
doparallel		= 1; % do not use parallelization
if doparallel
	isOpen = matlabpool('size') > 0;
	if ~isOpen
		matlabpool open
	end
end

fprintf( 'Running JAGS...\n' );
samples = matjags( ...
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
checkConvergence = true;
if checkConvergence
	fnames = fieldnames(samples);
	n = numel(fnames)-1;
	for ii = 1:n
		% thetaSample = reshape(mcmcChain,[numSavedSteps+1 nCoins]);
		ns = ceil(sqrt(n));
		figure(2)
		subplot(ns,ns,ii)
		s		= samples.(fnames{ii});
		m=numel(s);
		m = min(m,16667);
		s		= s(1:m);
		s		= zscore(s);
		maxlag	= 35;
		[c,l]	= xcorr(s,maxlag,'coeff');
		h		= stem(l(maxlag:end),c(maxlag:end),'k-');
		xlim([-1 maxlag]);
		set(h,'MarkerEdgeColor','none');
		axis square;
		box off
		set(gca,'TickDir','out');
		str = fnames{ii};
		xlabel('Lag');
		ylabel('Autocorrelation');
		title(str);
	end
end

%%
bMet1 = squeeze(samples.bMet1(:,:,1))*ySDorig/metSD;
figure;
plot(bMet1');

%%
samples = betaconvert(samples,dataStruct,Nnom,Nmet,xmet,ySDorig,yMorig,metSD,nChains);

%%
% Hypothesis testing
% nominal comparisons
for idx = 1:Nnom
	[db,bf,comp,xlbl,hd]	= getcomparisons(samples.(['b' num2str(idx)]),samples.(['b' num2str(idx) 'prior']),names.(['x' num2str(idx)])); % Main factor group
	stats.(['b' num2str(idx)]).Diff	= mean(db);
	stats.(['b' num2str(idx)]).BF		= bf;
	stats.(['b' num2str(idx)]).comp	= comp;
	stats.(['x' num2str(idx)]).label	= xlbl;
	stats.(['b' num2str(idx)]).HDI	= hd;
end

%%
for idx = 1:Nmet
	b		= samples.(['bMet' num2str(idx)]);
	bprior	= samples.(['bMet' num2str(idx) 'prior']);
	
	[db,bf,comp,xlbl,hd]	= getcomparisons(b,bprior,names.x1); % Main factor group
	stats.(['bMet' num2str(idx)]).Diff	= mean(db);
	stats.(['bMet' num2str(idx)]).BF		= bf;
	stats.(['bMet' num2str(idx)]).comp	= comp;
	stats.(['xMet' num2str(idx)]).label	= xlbl;
	stats.(['bMet' num2str(idx)]).HDI		= hd;
end

[db,bf,hd]		= get0comparisons(samples.bMet0,samples.bMet0prior); % Main factor phoneme score
idx = 0;
stats.(['bMet' num2str(idx)]).mu	= mean(db);
stats.(['bMet' num2str(idx)]).BF		= bf;
stats.(['bMet' num2str(idx)]).HDI		= hd;

%% Display the posterior of the b1:
figure(101)
for ii = 1:dataStruct.Nx1Lvl
	subplot(2,2,ii)
	bMet1 = samples.bMet1(:,ii)+samples.bMet0;
	plotPost(bMet1,'xlab','Slope');
	xlim([-8 8]);
	title(names.x1{ii});
set(gca,'TickDir','out','XTick',-6:2:6);
end

%% Display the posterior of the b1:
figure
for ii = 1:dataStruct.Nx1Lvl
	subplot(1,3,ii)
	b1 = samples.b1(:,ii)+samples.b0;
	plotPost(b1,'xlab','Offset','compVal',0);
end

%% Display data with believable regression lines and posterior predictions.
% Plot data values:
figure(201)
for idx = 1:3
	subplot(2,2,idx)
	switch idx
		case 1
			x = x1;
			y = y1;
		case 2
			x = x2;
			y = y2;
		case 3
			x = x3;
			y = y3;
	end
	xRang		= max(x)-min(x);
	yRang		= max(y)-min(y);
	limMult		= 0.25;
	xL		= [min(x)-limMult*xRang , max(x)+limMult*xRang];
	yL		= [min(y)-limMult*yRang , max(y)+limMult*yRang];
	
	plot(x,y,'ko','MarkerFaceColor','w','LineWidth',2);
	xlim(xL);
	ylim(yL);
	xlabel('Anger');
	ylabel('Agression');
	title('Data with credible regression lines');
	axis square
	axis([-2 6 -2 10]);
	box off
	set(gca,'TickDir','out','XTick',0:4,'YTick',0:2:8);
	% Superimpose a smattering of believable regression lines:
	bMet1	= samples.bMet1(:,idx)+samples.bMet0;
	b1		= samples.b1(:,idx)+samples.b0;
	for ii =  round(linspace(1,length(b1),50))
		beta = [b1(ii) bMet1(ii)];
		h = pa_regline(beta','k-');
		set(h,'Color',[.7 .7 1]);
	end
end

1./stats.bMet1.BF(1)
1./stats.bMet1.BF(2)
1./stats.bMet1.BF(3)
% keyboard

function pa_bayes_ancovamodel(model,Nnom,Nmet,xmet)
% function pa_bayes_modeldata
%
% For every nominal factor a parameter
% For every metric factor, N dependent parameters
%
% To do: multiple metrics
% PA_BAYES_MODELDATA
%
% Write Trial-line in an exp-file with file identifier FID.
% TRL - Trial Number
%
% See also GENEXPERIMENT, FOPEN, and the documentation of the Auditory
% Toolbox
pa_datadir

%% Initialization
if nargin<1
	model = 'model.txt';
end
if nargin<2
	Nnom = 1;
end
if nargin<3
	Nmet = 1;
end
if nargin<4
	xmet(1).Nom = 1;
end
robustFlag = false;

[~,n] = size(xmet);
if n~=Nmet
	disp('error');
	% 	return
end
%5
pa_datadir
fid = fopen(model,'w');

fprintf(fid,'%s \r\n','model {');
fprintf(fid,'\t\r\n');
fprintf(fid,'\t%s\r\n',		'for ( i in 1:Ntotal ) {'); % Loop through data
if robustFlag % use a t-distribution that allows for outliers
	fprintf(fid,'\t\t%s\r\n',		'y[i] ~ dt(mu[i],tau,tdf)'); % Data is normally distributed
else
	fprintf(fid,'\t\t%s\r\n',		'y[i] ~ dnorm(mu[i],tau)'); % Data is normally distributed
end
%%
% nominal factors: ANOVA
strNom = 'a0 ';
for ii = 1:Nnom
	tmp = [' + a' num2str(ii) '[x' num2str(ii) '[i]]'];
	strNom = [strNom tmp]; %#ok<*AGROW>
end

% nominal 2-way interactions
x		= 1:Nnom;
[x,y]	= meshgrid(x,x);
x		= x(:);
y		= y(:);
sel		= x==y; % remove identical
x		= x(~sel);
y		= y(~sel);
M		= [x y];
M		= unique(sort(M,2),'rows'); % unique interactions, don't care about direction
M
NxNom = size(M,1);
for ii = 1:NxNom
	tmp = [' + a' num2str(M(ii,1)) 'a' num2str(M(ii,2)) '[x' num2str(M(ii,1)) '[i],x' num2str(M(ii,2)) '[i]]'];
	strNom = [strNom tmp]; %#ok<*AGROW>
end

% metric factors: linear regression
strMet = ' + (aMet0 ';

for ii = 1:Nmet
	str1 = ['+ aMet' num2str(ii) '['];
	for nomIdx = 1:length(xmet(ii).Nom)
		str2 =	[repmat(',',1,nomIdx-1) 'x' num2str(xmet(ii).Nom(nomIdx)) '[i]'];
		str1 = [str1 str2];
	end
	str2 = ['*xMet' num2str(ii) '[i]'];
	tmp = [str1 '])' str2];
	strMet = [strMet tmp];
end
% combine in ANCOVA
str		= ['mu[i] <- ' strNom strMet];
fprintf(fid,'\t\t%s\r\n',str); % Model


%% Missing values
fprintf(fid,'\t%s\r\n','# Missing values'); % Missing values
for ii = 1:Nnom
	str = ['x' num2str(ii) '[i] ~ dcat(pix' num2str(ii) '[])']; % normally distributed around mean of all levels in factor
	fprintf(fid,'\t\t%s\r\n',str);
end

for ii = 1:Nmet
	str = ['xMet' num2str(ii) '[i] ~ dnorm(muxMet' num2str(ii) ',tauxMet' num2str(ii) ')']; % normally distributed around mean of all conditions
	fprintf(fid,'\t\t%s\r\n',str); % Missing values
end

%% Close model
fprintf(fid,'\t%s\r\n','}'); % with end


%% Priors on missing predictors
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Vague priors on missing predictors');
fprintf(fid,'%s\r\n','# Assuming predictor variances are equal');
for ii = 1:Nnom
	strfor			= ['for (j' num2str(ii) ' in 1:Nx' num2str(ii) 'Lvl){ '];
	str = ['pix' num2str(ii) '[j' num2str(ii) '] <- 1/Nx' num2str(ii) 'Lvl'];
	fprintf(fid,'\t%s\r\n',[strfor str ' }']);
end


for ii = 1:Nmet
	str = ['muxMet' num2str(ii) ' ~ dnorm(0,1.0E-12)'];
	fprintf(fid,'\t%s\r\n',str); % Missing values
end

for ii = 1:Nmet
	str = ['tauxMet' num2str(ii) ' ~ dgamma(0.001,0.001)'];
	fprintf(fid,'\t%s\r\n',str); % Missing values
end

%% Priors
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Priors');

fprintf(fid,'\t%s\r\n','tau <- pow(sigma,-2)'); % conversion from sigma to precision
fprintf(fid,'\t%s\r\n','sigma ~ dgamma(1.01005,0.1005) # standardized y values'); % Missing values
if robustFlag
	fprintf(fid,'\tudf ~ dunif(0,1)\r\n');
	fprintf(fid,'\ttdf <- 1-tdfGain*log(1-udf)\r\n');
end

priors(fid,Nnom,Nmet,xmet,[]);

%% Sampling from prior dist
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Sampling from Prior distribution :');
priors(fid,Nnom,Nmet,xmet,'prior');


%% Close
fprintf(fid,'%s\r\n','}');

%% Close model-textfile
fclose(fid);

function priors(fid,Nnom,Nmet,xmet,strprior)


%% Priors
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Hyper Priors');

%% Group-level priors
fprintf(fid,'\t\r\n');
fprintf(fid,'\t%s\r\n',['a0' strprior ' ~ dnorm(0,lambda0' strprior ')']); % offset
fprintf(fid,'\t%s\r\n',['aMet0' strprior ' ~ dnorm(0,lambdaMet0' strprior ')']); % offset
for ii = 1:Nnom
	str = ['for (j' num2str(ii) ' in 1:Nx' num2str(ii) 'Lvl){ a' num2str(ii) strprior '[j' num2str(ii) '] ~ dnorm(0.0,lambda' num2str(ii) strprior ') }'];
	fprintf(fid,'\t%s\r\n',str);
end
for ii = 1:Nmet
	for nomIdx = 1:length(xmet(ii).Nom)
		str = ['for (j' num2str(xmet(ii).Nom(nomIdx)) ' in 1:Nx' num2str(xmet(ii).Nom(nomIdx)) 'Lvl){ '];
		fprintf(fid,'\t%s',str);
	end
	fprintf(fid,'\t\r\n');
	str1 = ['aMet' num2str(ii) strprior '['];
	for nomIdx = 1:length(xmet(ii).Nom)
		str2 = [repmat(',',1,nomIdx-1) 'j'  num2str(xmet(ii).Nom(nomIdx)) ];
		str1 = [str1 str2];
	end
	str = [str1  ']~ dnorm(0.0,lambdaMet' num2str(ii) strprior ')'];
	fprintf(fid,'\t\t%s\r\n',str);
	for nomIdx = 1:length(xmet(ii).Nom)
		fprintf(fid,'\t%s','}');
	end
	fprintf(fid,'\t\r\n');
end

fprintf(fid,'\t%s\r\n',['lambda0' strprior ' ~ dchisqr(1)']); % chi sqr for nice statistical properties
for ii = 1:Nnom
	str = ['lambda' num2str(ii) strprior  ' ~ dchisqr(1)'];
	fprintf(fid,'\t%s\r\n',str);
end
fprintf(fid,'\t%s\r\n',['lambdaMet0' strprior ' ~ dchisqr(1)']); % chi sqr for nice statistical properties
for ii = 1:Nmet
	str = ['lambdaMet' num2str(ii) strprior ' ~ dchisqr(1)'];
	fprintf(fid,'\t%s\r\n',str);
end

%% Sum-to-zero for nominal factors
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Convert nominal factors to sum-to-zero');

strmuj		= [];
strNom		= [];
strClose	= [];
for ii = 1:Nnom
	strfor			= ['for (j' num2str(ii) ' in 1:Nx' num2str(ii) 'Lvl){ '];
	fprintf(fid,'\t%s\r\n',strfor);
	if ii<Nnom
		tmp		= ['j' num2str(ii) ','];
	else
		tmp		= ['j' num2str(ii)];
	end
	strmuj		= [strmuj tmp];
	
	tmp			= ['+ a' num2str(ii) strprior '[j' num2str(ii) '] '];
	strNom		= [strNom tmp]; %#ok<*AGROW>
	
	strClose	= [strClose '} '];
end
str = ['m' strprior '[' strmuj '] <- a0' strprior ' ' strNom ];
fprintf(fid,'\t\t%s\r\n',str);
fprintf(fid,'\t%s\r\n',strClose);

fprintf(fid,'\t%s\r\n',['b0' strprior '<-mean(m' strprior '[' repmat(',',1,Nnom-1) '])']);
for ii = 1:Nnom
	str1	= repmat(',',1,ii-1);
	str2	= repmat(',',1,Nnom-ii);
	str		= ['for ( j' num2str(ii) ' in 1:Nx' num2str(ii) 'Lvl ) { '];
	fprintf(fid,'\t%s\r\n',str);
	str = 	['b' num2str(ii) strprior '[j' num2str(ii) '] <- mean( m' strprior '[' str1  'j' num2str(ii) str2 '] ) - b0' strprior ' }'];
	fprintf(fid,'\t\t%s\r\n',str);
end

%% Sum-to-zero for metric factors
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Convert metric factors to sum-to-zero');

strmuj		= [];
strMet		= [];
for ii = 1:Nmet
	strfor = [];
	for nomIdx = 1:length(xmet(ii).Nom)
		str		= ['for (j' num2str(xmet(ii).Nom(nomIdx)) ' in 1:Nx' num2str(xmet(ii).Nom(nomIdx)) 'Lvl){ '];
		strfor = [strfor str];
	end
	fprintf(fid,'\t%s\r\n',strfor);
	
	for nomIdx = 1:length(xmet(ii).Nom)
		str		= [repmat(',',1,nomIdx-1) 'j' num2str(xmet(ii).Nom(nomIdx))];
		strmuj = [strmuj str];
	end
	
	tmp			= ['+ aMet' num2str(ii) strprior '[' strmuj '] '];
	strMet		= [strMet tmp]; %#ok<*AGROW>
	
	strClose	= [];
	for nomIdx = 1:length(xmet(ii).Nom)
		strClose	= [strClose '} '];
	end
end
str = ['mMet' strprior '[' strmuj '] <- aMet0' strprior ' ' strMet ];
fprintf(fid,'\t\t%s\r\n',str);
fprintf(fid,'\t%s\r\n',strClose);


fprintf(fid,'\t%s\r\n',['bMet0' strprior '<-mean(mMet' strprior '[' repmat(',',1,length(xmet(ii).Nom)-1) '])']);

strmuj		= [];
strMet		= [];
for ii = 1:Nmet
	strfor = [];
	for nomIdx = 1:length(xmet(ii).Nom)
		str		= ['for (j' num2str(xmet(ii).Nom(nomIdx)) ' in 1:Nx' num2str(xmet(ii).Nom(nomIdx)) 'Lvl){ '];
		strfor = [strfor str];
	end
	fprintf(fid,'\t%s\r\n',strfor);
	
	for nomIdx = 1:length(xmet(ii).Nom)
		str		= [repmat(',',1,nomIdx-1) 'j' num2str(xmet(ii).Nom(nomIdx))];
		strmuj = [strmuj str];
	end
	
	tmp			= ['aMet' num2str(ii) strprior '[' strmuj '] '];
	strMet		= [strMet tmp]; %#ok<*AGROW>
	
	str = ['bMet' num2str(ii) strprior '[' strmuj '] <- ' strMet ' - bMet0' strprior ];
	
	fprintf(fid,'\t\t%s\r\n',str);
	
	strClose	= [];
	for nomIdx = 1:length(xmet(ii).Nom)
		strClose	= [strClose '} '];
	end
end

fprintf(fid,'\t%s\r\n',strClose);

function dataStruct = dataconstruct(y,z,zMet,x,Nnom)

dataStruct.y		= z';
dataStruct.xMet1		= zMet;
dataStruct.Ntotal	= length(y);
for idx = 1:(Nnom)
	idx
	dataStruct.(['x' num2str(idx)])= x(:,idx);
	dataStruct.(['Nx' num2str(idx) 'Lvl'])	= length(unique(x(~isnan(x(:,idx)),idx)));
end

function initsStruct = initconstruct(dataStruct,xmet,Nnom,nChains)
initsStruct = struct([]);
for chain = 1:nChains
	initsStruct(chain).sigma	= nanstd(dataStruct.y)/2; % lazy
	initsStruct(chain).a0		= 0;
	
	initsStruct(chain).aMet1		= zeros(dataStruct.(['Nx' num2str(xmet(1).Nom(1)) 'Lvl'])	,1);
	initsStruct(chain).aMet1prior	= zeros(dataStruct.(['Nx' num2str(xmet(1).Nom(1)) 'Lvl'])	,1);
	dataStruct
	for nlvl = 1:dataStruct.Nx1Lvl
		sel = dataStruct.x1==nlvl;
		b = regstats(dataStruct.y(sel),dataStruct.xMet1(sel));
	initsStruct(chain).aMet1(nlvl)		= b.beta(2);
	initsStruct(chain).aMet1prior(nlvl)	= b.beta(2);
	end
% 	% Only works for 2 nominal factors in Metric parameter
% 	initsStruct(chain).aMet1(nvl)		= zeros(dataStruct.(['Nx' num2str(xmet(1).Nom(1)) 'Lvl'])	,1);
% 	initsStruct(chain).aMet1prior	= zeros(dataStruct.(['Nx' num2str(xmet(1).Nom(1)) 'Lvl'])	,1);
	initsStruct(chain).aMet0	= 0;
	initsStruct(chain).aMet0prior	= 0;
	
	for idx = 1:(Nnom)
		sel = isnan(dataStruct.(['x' num2str(idx)])) | isnan(dataStruct.y);
		initsStruct(chain).(['a' num2str(idx)])				= accumarray(dataStruct.(['x' num2str(idx)])(~sel),dataStruct.y(~sel),[],@nanmean);
		initsStruct(chain).(['a' num2str(idx) 'prior'])	= accumarray(dataStruct.(['x' num2str(idx)])(~sel),dataStruct.y(~sel),[],@nanmean);
	end
	
end

function  samples = betaconvert(samples,dataStruct,Nnom,Nmet,xmet,ySDorig,yMorig,metSD,nChains)
% Extract b values,
% and convert from standardized b values to original scale b values:
% b1 = reshape(b1,nCHains*chainLength,Nx1Level)*ySDorig


%%
chainLength			= length(samples.b0);
samples.b0			= samples.b0(:)*ySDorig + yMorig;
samples.b0prior			= samples.b0prior(:)*ySDorig + yMorig;
for idx = 1:Nnom
	samples.(['b' num2str(idx)]) = reshape(samples.(['b' num2str(idx)]),nChains*chainLength,dataStruct.(['Nx' num2str(idx) 'Lvl']))*ySDorig;
	samples.(['b' num2str(idx) 'prior']) = reshape(samples.(['b' num2str(idx) 'prior']),nChains*chainLength,dataStruct.(['Nx' num2str(idx) 'Lvl']))*ySDorig;
end
samples.bMet0		= reshape(samples.bMet0,nChains*chainLength,1)*ySDorig/metSD;
samples.bMet0prior	= reshape(samples.bMet0prior,nChains*chainLength,1)*ySDorig/metSD;
for idx = 1:Nmet
	samples.(['bMet' num2str(idx)]) = reshape(samples.(['bMet' num2str(idx)]),[nChains*chainLength,dataStruct.(['Nx' num2str(xmet(idx).Nom(1)) 'Lvl'])])*ySDorig/metSD;
	samples.(['bMet' num2str(idx) 'prior']) = reshape(samples.(['bMet' num2str(idx) 'prior']),[nChains*chainLength,dataStruct.(['Nx' num2str(xmet(idx).Nom(1)) 'Lvl'])])*ySDorig/metSD;
end

function [db,bf,indx,xlbl,HDI] = getcomparisons(b,bprior,x1label)
% determine unique comparisons
[~,nb]	= size(b); % number of factors
[indx1,indx2] = meshgrid(1:nb,1:nb); % possible comparisons
indx	= [indx1(:) indx2(:)];
indx	= unique(sort(indx,2),'rows'); % unique one-way comparisons
sel		= indx(:,1)==indx(:,2); % self-comparison not required for nominal factors
indx	= indx(~sel,:);
indx	= indx(:,[2 1]); % let's compare 'higher' to 'lower' factors (makes sense for Pre-Post-NH, and Rest-Video-AV)
ncomp	= size(indx,1); % number of unique comparisons
bf		= NaN(1,ncomp);
HDI		= NaN(2,ncomp);

db		= NaN(size(b,1),ncomp);
xlbl			= cell(ncomp,1);
for cIdx = 1:ncomp
	i1 = indx(cIdx,1);
	i2 = indx(cIdx,2);
	H1	= b(:,i1)-b(:,i2);
	H0	= bprior(:,i1)-bprior(:,i2);

	%%
	figure(666+cIdx)
	clf
	subplot(121)
	plotPost(H1);
	subplot(122)
	plotPost(H0);
% 	pause
	%%
% 	keyboard
	bf(cIdx)		= pa_bayesfactor(H1,H0);
	db(:,cIdx)		= H1;
	HDI(:,cIdx)		= HDIofMCMC(H1,0.95);
	xlbl{cIdx}		= ['[' x1label{i1} ' - ' x1label{i2} ']'];
end


function [db,bf,HDI] = get0comparisons(b,bprior)
[~,m,n]	= size(b); % number of factors

ncomp = m*n;
bf = NaN(1,ncomp);
db				= NaN(size(b,1),ncomp);
cIdx = 0;
HDI		= NaN(2,ncomp);
for mIdx = 1:m
	for nIdx = 1:n
		cIdx = cIdx+1;
		H1	= b(:,mIdx,nIdx);
		H0	= bprior(:,mIdx,nIdx);
		bf(cIdx)	= pa_bayesfactor(H1,H0);
		db(:,cIdx)	= H1;
		HDI(:,cIdx)			= HDIofMCMC(H1,0.95);
	end
end

function [Z,m,sd] = pa_zscore(x)
% Z = PA_ZSCORE(X)
%
% Z-transform variable X:
%
% Z = (X-mean(X))./std(X)
%
% This is useful for multiple linear regression, when one wants to compare
% variables of different units. Regression coefficients obtained from
% z-transformed data are called partial regression coefficients (cf.
% correlation coefficient).
%
% If you have the statistics toolbox:
% see also ZSCORE

% (c) 2011-04-27 Marc van Wanrooij
% E-mail: marcvanwanrooij@gmail.com

n   = size(x,1);
m   = nanmean(x); m = repmat(m,n,1);
sd  = nanstd(x); sd = repmat(sd,n,1);

Z = (x-m)./sd;



function BF = pa_bayesfactor(samplesPost,samplesPrior,crit)
% Quick and dirty code
%
% BF = PA_BAYESFACTOR(SAMPLESPOST,SAMPLESPRIOR)
%
% Determine Bayes factor for prior and posterior MCMC samples via the
% Savage-Dickey method.
%
% Determine if posterior is significantly different from a critical value
% CRIT:
% BF = PA_BAYESFACTOR(SAMPLESPOST,SAMPLESPRIOR,CRIT)
% By default this will the null hypothesis.
%
% See also KSDENSITY

% 2013 Marc van Wanrooij
% e: marcvanwanrooij@neural-code.com


eps		= 0.01; % bin size
binse	= -10:eps:10; % bin range
if nargin<3
	crit	= 0; % test null-hypothesis
end

% Posterior
tmp			= samplesPost;
tmp			= tmp(tmp>binse(1)&tmp<binse(end));
[f,xi]		= ksdensity(tmp,'kernel','normal');
[~,indk]	= min(abs(xi-crit));

% Prior on Delta
tmp			= samplesPrior;
tmp			= tmp(tmp>binse(1)&tmp<binse(end));
[f2,x2]		= ksdensity(tmp,'kernel','normal');
[~,indk2]	= min(abs(x2-crit));

v1 = f(indk);
v2 = f2(indk2);
BF = v1/v2;









