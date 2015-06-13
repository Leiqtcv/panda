function basbim2

close all force hidden
clear all



x		= -90:90;
sigmaL	= 5;
sigmaP	= 10;

v = sigmaP^2 * sigmaL^2;
o = sigmaP^2 + sigmaL^2;

postMu		= sigmaP^2/o;
postSigma	=  sqrt(v/o);

P	= x+sigmaL*randn(size(x));
y	= postMu*P+postSigma*randn(size(P));

plot(x,y,'.');
hold on
axis square
axis([-90 90 -90 90]);
box off
pa_unityline;

b = regstats(y,x,'linear','beta');
pa_regline(b.beta,'k-');
G = 1-postSigma^2/sigmaP^2;
str = ['G_{actual} = ' num2str(round(b.beta(2)*100)/100) '; G_{pred} = ' num2str(round(G*100)/100)]
	
title(str)
%%
Ntotal	= length(y);
Nx1Lvl	= length(unique(x));

% Normalize, for JAGS MCMC sampling, e.g. to use cauchy(0,1) prior
[z,My,SDy]		= pa_zscore(y);
[z1,Mx,SDx]		= pa_zscore(x);


%% Data
dataStruct.y		= y;
dataStruct.x		= x;
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
parameters		= {'sigmaL','sigmaP'}; % The parameter(s) to be monitored.
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
model = 'model_basbim.txt';
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

% keyboard

%%
figure
subplot(221)
plotPost(samples.sigmaL(:));
xlim([3 12]);

subplot(222)
plotPost(samples.sigmaP(:));
% xlim([0 1]);
xlim([3 12]);

subplot(223)
plot(samples.sigmaP(1:10:end),samples.sigmaL(1:10:end),'.','Color',[.5 .5 1])
hold on
 [MU,SD,A] = pa_ellipse(samples.sigmaP(:),samples.sigmaL(:));
 pa_ellipseplot(MU,3*SD,A,'Color',[.7 .7 1]);

axis square
box off
set(gca,'TickDir','out');
xlim([3 12]);
ylim([3 12]);
pa_unityline;
% keyboard
%%
% close all


% %%
% subplot(223)
% plotPost(samples.sigmaL(:)*SDy/SDx);
% % xlim([0 1]);
% 
% subplot(224)
% plotPost(samples.sigmaP(:)*SDy/SDx);
% % xlim([0 5]);


%%
return
figure
% subplot(121
n = numel(samples.aMet0(:));
for ii = 1:100:n
	b0 = (samples.aMet0(ii) * SDy + My - samples.aMet1(ii)*SDy*Mx1/SDx1 - samples.aMet2(ii)*SDy*Mx2/SDx2 );
	b1 = samples.aMet1(ii)*SDy/SDx1;
	b2 = samples.aMet2(ii)*SDy/SDx2;
ypred = b0 +b1*xMet1+b2*xMet2;
h = scatter(xMet1,ypred,30,xMet2,'filled');
ylim([-90 90]);
xlim([-90 90]);
hold on

h = scatter(xMet1,y,70,xMet2,'filled');
set(h,'MarkerEdgeColor','k');
axis square;
box off
set(gca,'TickDir','out');
ylim([-90 90]);
xlim([-90 90]);

% subplot(122)
hold on


% 	h = scatter(T,R,70,I,'filled');

end
axis square;
box off
set(gca,'TickDir','out');

function [y,x1,x2,s] = getdata


fnames	= {'bn01','cd01','gk01','ie01','jp03','ld01','po01','rh01','sb01'};
d		= {'l';'r';'r';'l';'r';'r';'r';'l';'r';};
con		= [0 1 0 1 1 1 0 1 1];

n  = numel(fnames);
gain = NaN(n,1);
B = NaN(n,9,2);
y = [];
x1 = [];
x2 = [];
s = [];
for ii = 1:9
	if strcmpi(fnames{ii},'rh01')
		SupSac = consider('rh01','adapt'); %#ok<*NASGU>
		splittom;
		HP		= BB;
		stim	= 'HP';
		% stim = 'BB';
		
	else
		SupSac  = consider(fnames{ii},d{ii});
		sel     = SupSac(:,26)==2;
		stim	= 'HP';
		% stim = 'BB';
		if sum(sel)==0
			sel     = SupSac(:,26)==2;
			stim = 'HP';
			
		end
		HP      = SupSac(sel,:);
	end
	R = HP(:,8);
	T = HP(:,23);
	d(ii)
	switch d{ii}
		case 'r'
			R = -R;
			T = -T;
	end
	I = 90+HP(:,25);
	minI = min(I);
	switch minI
		case 27
			I = I+3;
		case 32
			I = I-2;
		case 29
			I = I+1;
		otherwise
			I = HP(:,27);
	end
	
	
HSE = 9.7*sin(0.02*T+0.27);
y	= [y;R]; %#ok<*AGROW>
x1	= [x1;T];
x2	= [x2;I+HSE];
s = [s;repmat(ii,size(R))];
end


function alldata
fnames	= {'bn01','cd01','gk01','ie01','jp03','ld01','po01','rh01','sb01'};
d		= {'l';'r';'r';'l';'r';'r';'r';'l';'r';};
con		= [0 1 0 1 1 1 0 1 1];

n  = numel(fnames);
gain = NaN(n,1);
B = NaN(n,7,2);
for ii = 3
	if strcmpi(fnames{ii},'rh01')
		SupSac = consider('rh01','adapt'); %#ok<*NASGU>
		splittom;
		HP		= BB;
		stim	= 'HP';
		% stim = 'BB';
		
	else
		SupSac  = consider(fnames{ii},d{ii});
		sel     = SupSac(:,26)==2;
		stim	= 'HP';
		% stim = 'BB';
		if sum(sel)==0
			sel     = SupSac(:,26)==2;
			stim = 'HP';
			
		end
		HP      = SupSac(sel,:);
	end
	R = HP(:,8);
	T = HP(:,23);
	d(ii)
	switch d{ii}
		case 'r'
			R = -R;
			T = -T;
	end
	I = 90+HP(:,25);
	minI = min(I);
	switch minI
		case 27
			I = I+3;
		case 32
			I = I-2;
		case 29
			I = I+1;
		otherwise
			I = HP(:,27);
			% 		keyboard
			fnames{ii}
			unique(I)
			% 		error('uh-oh');
	end
	
	uI = unique(I);
	nI = numel(uI);
	k = 0;
	for intIdx = 1:2:nI
		sel = I==uI(intIdx);
		k = k+1;
		figure(ii)
		subplot(1,4,k)
		h = plot(T(sel),R(sel),'ko');
			set(h,'MarkerFaceColor',[.7 .7 1],'MarkerEdgeColor','k');
		set(gca,'TickDir','out','Xtick',-90:30:90,'YTick',-90:30:90);
		axis([-100 100 -100 100]);
		axis square
		box off
		drawnow
		xlabel('Target azimuth (deg)');
		ylabel('Response azimuth (deg)');
		b = regstats(R(sel),T(sel),'linear','beta');
		B(ii,intIdx,:) = b.beta;
		h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
		gain(ii) = b.beta(2);
		if b.beta(1)<0
			plsmn = '-';
		else
			plsmn = '+';
		end
		str = [num2str(uI(intIdx)) ' dB :' plsmn num2str(abs(b.beta(1)),2) ' deg'];
		title(str)
% 		pa_horline;
% 		pa_verline;
		pa_unityline('k:');
		drawnow
	end
	
% 	sel = I==uI(intIdx);
% 	figure(ii)
% 	subplot(2,4,8)
% 	h = scatter(T,R,70,I,'filled');
% 	% 	set(h,'MarkerFaceColor',[.7 .7 1],'MarkerEdgeColor','none');
% 	set(gca,'TickDir','out','Xtick',-80:20:80,'YTick',-80:20:80);
% 	axis([-90 90 -90 90]);
% 	axis square
% 	box off
% 	drawnow
% 	xlabel('Stimulus \alpha');
% 	ylabel('Response \alpha');
% 	b = regstats(R,T,'linear','beta');
% 	h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
% 	gain(ii) = b.beta(2);
% 	if b.beta(1)<0
% 		plsmn = '-';
% 	else
% 		plsmn = '+';
% 	end
% 	str = [upper(fnames{ii}(1:2)) ',' stim ': \alpha_T = ' num2str(b.beta(2),2) '\alpha_R' plsmn num2str(abs(b.beta(1)),2)];
% 	title(str)
% 	drawnow
end

% keyboard
%%
% figure(666);
% subplot(131)
% x = squeeze(B(:,:,1));
% y = squeeze(B(:,:,2));
% plot(x,y,'ko');
% hold on
% xlim([-90 90]);
% ylim([-0.2 1.2]);
% axis square;
% box off
% set(gca,'TickDir','out');
% pa_horline(0,'k:');
% pa_verline(0,'k:');
% 
% plot([-90 0],[0 1],'k:');
% plot([90 0],[0 1],'k:');
% sel = x>0;
% b = regstats(y(sel),x(sel),'linear','beta');
% h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
% sel = x<0;
% b = regstats(y(sel),x(sel),'linear','beta');
% h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
% 
% subplot(132)
% plot(uI,squeeze(B(:,:,1))','k-');
% ylim([-90 90]);
% xlim([25 65]);
% axis square;
% box off
% set(gca,'TickDir','out');
% 
% subplot(133)
% plot(uI,squeeze(B(:,:,2))','k-');
% xlim([25 65]);
% ylim([-0.2 1.2]);
% axis square;
% box off
% set(gca,'TickDir','out');

function [azC,azS,intC,intS]=mlreg(subject,direct,side,Par)
% MLREG(SUBJECT,DIRECT,SIDE)
% mulitple linear regression on monaural localization data
% from subject SUBJECT in directory DIRECT. SIDE is good/hearing
% side ('l'=left, 'r'=right).

SupSac  = consider(subject,direct);
sel     = SupSac(:,26)==2;
HP      = SupSac(sel,:);
az      = HP(:,23);
azr     = HP(:,8);
int     = HP(:,25);
if strcmp(side,'l')
	az  = -az;
	azr = -azr;
end

% Head shadow effect
%[sall,aall,Par]=schaduw;

intc   = sinfun(az,Par);
int    = int+intc;
% Normalize
az     = pnorm(az);
azr    = pnorm(azr);
int    = pnorm(int);
% regr.
X        = [az int];
Y        = azr;
[c,s,T,Pc,Rp,F,Pf,R,Pr,CB]    = linreg(X,Y);
azC      = c(1); azS = s(1);
intC     = c(2); intS = s(2);

function [azC,azS,intC,intS]=mlreg2(subject,direct)
% MLREG2(SUBJECT,DIRECT)
% mulitple linear regression on binaural localization data
% from subject SUBJECT in directory DIRECT.
SupSac = consider(subject,direct);
sel    = SupSac(:,26)==2;
HP     = SupSac(sel,:);
az     = HP(:,23);
azr    = HP(:,8);
int    = HP(:,25);
% Normalize
az     = pnorm(az);
azr    = pnorm(azr);
int    = pnorm(int);
% regr.
X        = [az int];
Y        = azr;
[c,s,T,Pc,Rp,F,Pf,R,Pr,CB]    = linreg(X,Y);
azC      = c(1); azS = s(1);
intC     = c(2); intS = s(2);

function mens(dirname,expname)

% MENS(DIRNAME,EXPNAME)
%
%   Jumps to the human data-directory, DIRNAME and EXPNAME are optional
%   parameters:
%
%   cd /data/auditief/marc/data/adaptmold/
%    OR
%   cd /data/auditief/marc/data/adaptmold/DIRNAME
%    OR
%   cd /data/auditief/marc/data/EXPNAME/DIRNAME
%
%   See also AAP, HRTF
%   Ereated by: Marcus
%   Ereated at: 04-10-2002

% First check if

if     nargin==0,
	cd(['E:\DATA\'])
elseif nargin==1
	cd(['E:\DATA\Monaural Localization\' dirname])
elseif nargin==2
	if ~strcmpi(expname,'plug') && ~strcmpi(expname,'owl');
		cd(['E:\DATA\Monaural Localization\' dirname])
	else
		k=strfind(dirname,'-');
		session = dirname(1:k(2)-1);
		cd(['E:\DATA\Monaural Localization\' session '\' dirname])
	end
end

function [SupSac]=consider(subject,exp,wie)
% SUPSAC = CONSIDER(SUBJECT,EXP,WIE)
%
% This function combines all Sac-matrices of one session, and makes use of
% the SUPERSAC-function (thereby adding STIM-information).
% SUBJECT should be the session's name according to convention.
% If the batch-file SPLIT is to be used afterwards (which is standard
% practice), SUPSAC should be written literally as 'SupSac' in the MATLAB
% forum.
% FIRSTSAC is also applied to the SUPSAC-matrix.
% EXPERIMENTER is the name (string) of the experimenter's personal directory on the
% data-disk 'Augustus' or 'R\auditief:' (default: marc).
%
% See also SUPERSAC, MENS
%
% Created by: Marcus
% Created at: 01-01-2002

wd   = cd;
if nargin==1,
	mens(subject)
elseif nargin ==2
	mens(subject,exp)
elseif nargin==3,
	if isunix
		eval(['cd /data/auditief/' wie '/data/' exp '/' subject])
	else
		eval(['cd r:\' wie '\data\' exp '\' subject])
	end
end

w    = what;
file = w.mat;
n    = size(file,1);


for i=1:n,
	matfile=file{i};
	loadstr=['s' num2str(i) '=load([matfile]);'];
	eval(loadstr)
	sacstr=['Sac' num2str(i) '=s' num2str(i) '.Sac;'];
	eval(sacstr)
	stimstr=['Stim' num2str(i) '=s' num2str(i) '.Stim;'];
	eval(stimstr)
end

Sac=Sac1;
Stim=Stim1;
for j=2:n,
	Sacstr1=['Sac' num2str(j) '(:,1)=Sac' num2str(j) '(:,1)+' ...
		' Stim(size(Stim,1),1);'];
	eval(Sacstr1);
	Sacstr=['Sac=[Sac;Sac' num2str(j) '];'];
	eval(Sacstr)
	Stimstr1=['Stim' num2str(j) '(:,1)=Stim' num2str(j) '(:,1)+' ...
		' Stim(size(Stim,1),1);'];
	eval(Stimstr1)
	Stimstr=['Stim=[Stim;Stim' num2str(j) '];'];
	eval(Stimstr)
end

cd(wd)

SupSac=supersac(Sac,Stim);
SupSac=firstsac(SupSac);

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
	Nnom = 0;
end
if nargin<3
	Nmet =2;
end
if nargin<4
	xmet(1).Nom = 1;
	xmet(2).Nom = 1;
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


% metric factors: linear regression
strMet = ' aMet0 ';

for ii = 1:Nmet
	str1 = ['+ aMet' num2str(ii) '['];
	for nomIdx = 1:length(xmet(ii).Nom)
		str2 =	[repmat(',',1,nomIdx-1) 'x' num2str(xmet(ii).Nom(nomIdx)) '[i]'];
		str1 = [str1 str2];
	end
	str2 = ['*xMet' num2str(ii) '[i]'];
	tmp = [str1 ']' str2];
	strMet = [strMet tmp];
end
% combine in ANCOVA
% str		= ['mu[i] <- 180/(1+exp(-(' strMet ')))-90'];
str		= ['mu[i] <- ' strMet ];
fprintf(fid,'\t\t%s\r\n',str); % Model

% %% Missing values
% fprintf(fid,'\t%s\r\n','# Missing values'); % Missing values
% for ii = 1:Nnom
% 	str = ['x' num2str(ii) '[i] ~ dcat(pix' num2str(ii) '[])']; % normally distributed around mean of all levels in factor
% 	fprintf(fid,'\t\t%s\r\n',str);
% end
%
% for ii = 1:Nmet
% 	str = ['xMet' num2str(ii) '[i] ~ dnorm(muxMet' num2str(ii) ',tauxMet' num2str(ii) ')']; % normally distributed around mean of all conditions
% 	fprintf(fid,'\t\t%s\r\n',str); % Missing values
% end


%% Close model
fprintf(fid,'\t%s\r\n','}'); % with end

%% Priors on missing predictors
% fprintf(fid,'\t\r\n');
% fprintf(fid,'%s\r\n','# Vague priors on missing predictors');
% fprintf(fid,'%s\r\n','# Assuming predictor variances are equal');
% for ii = 1:Nnom
% 	strfor			= ['for (j' num2str(ii) ' in 1:Nx' num2str(ii) 'Lvl){ '];
% 	str = ['pix' num2str(ii) '[j' num2str(ii) '] <- 1/Nx' num2str(ii) 'Lvl'];
% 	fprintf(fid,'\t%s\r\n',[strfor str ' }']);
% end
%
%
% for ii = 1:Nmet
% 	str = ['muxMet' num2str(ii) ' ~ dnorm(0,1.0E-12)'];
% 	fprintf(fid,'\t%s\r\n',str); % Missing values
% end
%
% for ii = 1:Nmet
% 	str = ['tauxMet' num2str(ii) ' ~ dgamma(0.001,0.001)'];
% 	fprintf(fid,'\t%s\r\n',str); % Missing values
% end

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

if ispc
	dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' model ' &']);
end

function priors(fid,Nnom,Nmet,xmet,strprior)


%% Priors
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Hyper Priors');

fprintf(fid,'\t\r\n');
fprintf(fid,'\t%s\r\n',['aMet0' strprior ' ~ dnorm(0,lambdaMet0' strprior ')']); % offset

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


for ii = 1:Nnom
	str = ['lambda' num2str(ii) strprior  ' ~ dchisqr(1)'];
	fprintf(fid,'\t%s\r\n',str);
end
fprintf(fid,'\t%s\r\n',['lambdaMet0' strprior ' ~ dchisqr(1)']); % chi sqr for nice statistical properties
for ii = 1:Nmet
	str = ['lambdaMet' num2str(ii) strprior ' ~ dchisqr(1)'];
	fprintf(fid,'\t%s\r\n',str);
end


