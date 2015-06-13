function pet_bayesiananalysis_2013_11_06
% ANOVATWOWAYJAGSSTZ
%
% Bayesian two-way anova
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

% % Specify data source:
% dataSource = c( 'Ex19.3' )[1]
%
% Specify data source:
% To do:
% Interactions
% Bayes factor
% Estimate phoneme-score for normal-hearing
% Add uncertainty phoneme score

close all
model = 'petancova.txt';

%% THE MODEL.
pa_datadir;
loadflag = true;
% loadflag = false;
loadbrainflag = true;
% if ~exist(model,'file')
% 			'\tlambdasigma ~ dchisqr(1)\r\n',...
% 			'\tsigmatmp ~ dnorm(0,lambdasigma)\r\n',...
% 			'\tsigma <- abs(sigmatmp)\r\n',...
if ~loadflag
	if true
		
		% with cauchy
		str = ['model {\r\n',...
			'\tfor ( i in 1:Ntotal ) {\r\n',...
			'\t\ty[i] ~ dnorm( mu[i],tau)\r\n',...
			'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + a1a2[x1[i],x2[i]] + (bMetI[x2[i]])*xMet[i]\r\n',...
			'\t#Missing values\r\n',...
			'\t\t\tx1[i] ~ dnorm(mux,taux)\r\n',...
			'\t\t\tx2[i] ~ dnorm(mux,taux)\r\n',...
			'\t}\r\n',...
			'\t#\r\n',...
			'\ttau <- pow(sigma,-2)\r\n',...
			'\tsigma ~ dgamma(1.01005,0.1005) # y values are assumed to be standardized\r\n',...
			'\t#\r\n',...
			'\ta0 ~ dnorm(0,lambda0)\r\n',...
			'\tlambda0 ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { a1[j1] ~ dnorm(0.0,lambda1) }\r\n',...
			'\tlambda1 ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor (j2 in 1:Nx2Lvl) {a2[j2] ~ dnorm(0.0,lambda2) }\r\n',...
			'\tlambda2 ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor ( j2 in 1:Nx2Lvl ) {\r\n',...
			'\t\tbMetI[j2] ~ dnorm(0.0,lambdaMetI)\r\n',...
			'\t}\r\n',...
			'\tlambdaMetI ~ dchisqr(1)\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
			'\t\ta1a2[j1,j2] ~ dnorm(0.0,lambda12)\r\n',...
			'\t} }\r\n',...
			'\tlambda12 ~ dchisqr(1)\r\n',...
			' \r\n',...
			'\t#Vague priors on missing predictors,\r\n',...
			'\t#assuming predictor variances are equal\r\n',...
			'\ttaux ~ dgamma(0.001,0.001)\r\n',...
			'\tmux ~ dnorm(0,1.0E-12)\r\n',...
			'\t# Convert a0,a1[],a2[],a1a2[,] to sum-to-zero b0,b1[],b2[],b1b2[,] :\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
			'\t\tm[j1,j2] <- a0 + a1[j1] + a2[j2] + a1a2[j1,j2]  \r\n',...
			'\t} }\r\n',...
			'\tb0 <- mean( m[1:Nx1Lvl,1:Nx2Lvl] )\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { b1[j1] <- mean( m[j1,1:Nx2Lvl] ) - b0 }\r\n',...
			'\tfor ( j2 in 1:Nx2Lvl ) { b2[j2] <- mean( m[1:Nx1Lvl,j2] ) - b0 }\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
			'\t\tb1b2[j1,j2] <- m[j1,j2] - ( b0 + b1[j1] + b2[j2] )  \r\n',...
			'\t} }\r\n',...
			'\t# Sampling from Prior distribution :\r\n',...
			'\ta0prior ~ dnorm(0,lambda0prior)\r\n',...
			'\tlambda0prior ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { a1prior[j1] ~ dnorm(0.0,lambda1prior) }\r\n',...
			'\tlambda1prior ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor (j2 in 1:Nx2Lvl) {a2prior[j2] ~ dnorm(0.0,lambda2prior) }\r\n',...
			'\tlambda2prior ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor ( j2 in 1:Nx2Lvl ) {\r\n',...
			'\t\tbMetIprior[j2] ~ dnorm(0.0,lambdaMetIprior)\r\n',...
			'\t}\r\n',...
			'\tlambdaMetIprior ~ dchisqr(1)\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
			'\t\ta1a2prior[j1,j2] ~ dnorm(0.0,lambda12prior)\r\n',...
			'\t} }\r\n',...
			'\tlambda12prior ~ dchisqr(1)\r\n',...
			' \r\n',...
			'\t# Convert a0,a1[],a2[],a1a2[,] to sum-to-zero b0,b1[],b2[],b1b2[,] :\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
			'\t\tmprior[j1,j2] <- a0prior + a1prior[j1] + a2prior[j2] + a1a2prior[j1,j2]  \r\n',...
			'\t} }\r\n',...
			'\tb0prior <- mean(mprior[1:Nx1Lvl,1:Nx2Lvl])\r\n',...
			'\tfor (j1 in 1:Nx1Lvl) {b1prior[j1] <- mean(mprior[j1,1:Nx2Lvl] ) - b0prior }\r\n',...
			'\tfor (j2 in 1:Nx2Lvl) {b2prior[j2] <- mean(mprior[1:Nx1Lvl,j2] ) - b0prior }\r\n',...
			'\tfor (j1 in 1:Nx1Lvl) {for ( j2 in 1:Nx2Lvl ) {\r\n',...
			'\t\tb1b2prior[j1,j2] <- mprior[j1,j2] - ( b0prior + b1prior[j1] + b2prior[j2] )  \r\n',...
			'\t} }\r\n',...
			'}\r\n',...
			];
		% Write the modelString to a file, using Matlab commands:
		pa_datadir;
		fid			= fopen(model,'w');
		fprintf(fid,str);
		fclose(fid);
	end
	
	% 	return
	
	%% THE DATA.
	% Load the data:
	pa_datadir
	load('petancova')
	nroi		= numel(data);
	param		= struct([]);
	dataStruct	= struct('y',[],'x1',[],'x2',[]);
	BF			= struct([]);
	samp		= struct([]);
	for roiIdx = 1:nroi
		% 	data
		data(roiIdx).roi
		y		= data(roiIdx).FDG;
		y(1:4,1:2) = NaN;
y = y(:);
		x1		= data(roiIdx).group(:); % group
		x2		= data(roiIdx).stim(:); % stimulus
		
		S		= data(roiIdx).subject(:);
		S		=  repmat(S,5,1); % subject
		
		xMet	=	data(roiIdx).phoneme;
		xMet(1:5) = 80;
		xMet	= repmat(xMet,5,1); % phoneme score
		
		
		sel		= ismember(x1,1:2) & ismember(x2,1:2);
		x1		= x1(sel); % 'Pre-implant','Post-implant'
		x2		= x2(sel); % 'Rest','Video'
		y		= y(sel);
		S		= S(sel)-5;
		xMet	= xMet(sel);
		xMet	= pa_logit(xMet/100); % convert to -inf to + inf scale
		sel		= y<30; % remove unlikely FDG values, i.e. because of poor scan view
		y(sel)	= NaN;
		
		Ntotal	= length(y);
		Nx1Lvl	= length(unique(x1));
		Nx2Lvl	= length(unique(x2));
		NSLvl	= length(unique(S));
		% Normalize, for JAGS MCMC sampling, e.g. to use cauchy(0,1) prior
		[z,yMorig,ySDorig]	= pa_zscore(y');
		[zMet,metM,metSD]	= pa_zscore(xMet');
		
		a0			= nanmean(y);
		a1			= accumarray(x1,y,[],@nanmean)-a0;
		a2			= accumarray(x2,y,[],@nanmean)-a0;
		[A1,A2]		= meshgrid(a1,a2);
		linpred		= A1+A2;
		linpred		= linpred+a0;
		subs		= [x1 x2];
		val			= y;
		a1a2		= accumarray(subs,val,[],@nanmean);
		a1a2		= a1a2'-linpred;
		a1a2		= a1a2';
		
		%% a1a2
		%		-	-	 - >
		%		Pre Post
		% | R	1,1 1,2
		% | V   2,1 2,2
		
		
		%% Data
		dataStruct.y		= z';
		dataStruct.x1		= x1;
		dataStruct.x2		= x2;
		dataStruct.xMet		= zMet;
		dataStruct.Ntotal	= Ntotal;
		dataStruct.Nx1Lvl	= Nx1Lvl;
		dataStruct.Nx2Lvl	= Nx2Lvl;
		
		%% INTIALIZE THE CHAINS.
		a0			= nanmean(dataStruct.y);
		a1			= accumarray(dataStruct.x1,dataStruct.y,[],@nanmean)-a0;
		a2			= accumarray(dataStruct.x2,dataStruct.y,[],@nanmean)-a0;
		nChains		= 5;
		initsStruct = struct([]);
		for ii = 1:nChains
			initsStruct(ii).a0			= a0;
			initsStruct(ii).a1			= a1;
			initsStruct(ii).a2			= a2;
			initsStruct(ii).a1a2		= a1a2;
			initsStruct(ii).bMetI		= zeros(2,1);
			initsStruct(ii).a0prior		= a0;
			initsStruct(ii).a1prior		= a1;
			initsStruct(ii).a2prior		= a2;
			initsStruct(ii).a1a2prior	= a1a2;
			initsStruct(ii).sigma		= nanstd(dataStruct.y)/2; % lazy
			initsStruct(ii).bMetIprior	= zeros(2,1);
		end
		
		%% RUN THE CHAINS
		parameters		= {'b0','b1','b2','b1b2','bMetI','bMetIprior','b0prior','b1prior','b2prior','b1b2prior','sigma','lambda0','lambda1','lambda2','lamdaMet'};	% The parameter(s) to be monitored.
		burnInSteps		= 2000;		% Number of steps to 'burn-in' the samplers.
		numSavedSteps	= 5000;		% Total number of steps in chains to save.
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
		[samples,stats] = matjags(...
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
		% check convergence
% 		stats.Rhat
% 		stats.Rhat.b1
% 		stats.Rhat.b2
		% 	stats.Rhat.aS
		% 	return
		%% EXAMINE THE RESULTS
		% Extract b values:
		b0			= samples.b0(:);
		chainLength = length(samples.b0);
		b1			= reshape(samples.b1,nChains*chainLength,Nx1Lvl);
		b2			= reshape(samples.b2,nChains*chainLength,Nx2Lvl);
		b1b2		=  reshape(samples.b1b2,nChains*chainLength,Nx1Lvl,Nx2Lvl);
		bMetI		= reshape(samples.bMetI,nChains*chainLength,Nx2Lvl);
		
		b1prior		= reshape(samples.b1prior,nChains*chainLength,Nx1Lvl);
		b2prior		= reshape(samples.b2prior,nChains*chainLength,Nx2Lvl);
		b1b2prior	= reshape(samples.b1b2prior,nChains*chainLength,Nx1Lvl,Nx2Lvl);
		bMetIprior	= reshape(samples.bMetIprior,nChains*chainLength,Nx2Lvl);
		
		% Convert from standardized b values to original scale b values:
		b0			= b0*ySDorig + yMorig;
% 		b0			= b0*ySDorig + yMorig +metM;
		b1			= b1*ySDorig;
		b2			= b2*ySDorig;
		b1b2		= b1b2*ySDorig;
		bMetI		= bMetI*ySDorig/metSD;
		
		b1prior		= b1prior*ySDorig;
		b2prior		= b2prior*ySDorig;
		b1b2prior	= b1b2prior*ySDorig;
		bMetIprior	= bMetIprior*ySDorig/metSD;
		
		%% Save
		% Averages
		param(roiIdx).b0	= nanmean(b0);
		param(roiIdx).b1	= nanmean(b1);
		param(roiIdx).b2	= nanmean(b2);
		param(roiIdx).b1b2	= squeeze(nanmean(b1b2));
param(roiIdx).b1b2
param(roiIdx).bMetI = squeeze(nanmean(bMetI));
		param(roiIdx).metM = metM;
		% Samples
		samp(roiIdx).b0		= b0;
		samp(roiIdx).b1		= b1;
		samp(roiIdx).b2		= b2;
		samp(roiIdx).b1b2	= b1b2;
		samp(roiIdx).bMetI	= bMetI;
		
		%% Hypothesis testing
		
		% q1: is there some change after one year of implantation? Main
		% factor
		H1	= b1(:,2)-b1(:,1);
		H0	= b1prior(:,2)-b1prior(:,1);
		bf	= pa_bayesfactor(H1,H0);
		BF(roiIdx).q1 = bf;
		
		% q2: what are visual areas?? Main
		% factor
		H1	= b2(:,2)-b2(:,1);
		H0	= b2prior(:,2)-b2prior(:,1);
		bf	= pa_bayesfactor(H1,H0);
		BF(roiIdx).q2 = bf;
		
		% q3: does adaptation occur for rest?
		%		-	-	 - >
		%		Pre Post
		% | R	1,1 1,2
		% | V   2,1 2,2
		
		a	= squeeze(b1b2(:,2,1));
		b	= squeeze(b1b2(:,1,1));
		H1	= a-b;
		a	= squeeze(b1b2prior(:,2,1));
		b	= squeeze(b1b2prior(:,1,1));
		H0	= a-b;
% 
% 		a	= b1(:,2) + b2(:,1) + squeeze(b1b2(:,2,1));
% 		b	=  b1(:,1) + b2(:,1) + squeeze(b1b2(:,1,1));
% 		H1	= a-b;
% 		a	= b1prior(:,2) + b2prior(:,1) + squeeze(b1b2prior(:,2,1));
% 		b	= b1prior(:,1) + b2prior(:,1) + squeeze(b1b2prior(:,1,1));
% 		H0	= a-b;
		bf	= pa_bayesfactor(H1,H0);
		BF(roiIdx).q3 = bf;
		
		% q4: does adaptation occur for video?
		%		-	-	 - >
		%		Pre Post NH
		% | R	1,1 1,2	 1,3
		% | V   2,1 2,2  ...
		% | AV  3,1 ...  ...
		% NH AV - NH V
		% 		H1 = squeeze(b1b2(:,2,2))-squeeze(b1b2(:,2,1));
		% 		a = squeeze(b1b2prior(:,2,2));
		% 		b = squeeze(b1b2prior(:,2,1));
		
% 			a	= b1(:,2) + b2(:,2) + squeeze(b1b2(:,2,2));
% 		b	=  b1(:,1) + b2(:,2) + squeeze(b1b2(:,1,2));
% 		H1	= a-b;
% 		a	= b1prior(:,2) + b2prior(:,2) + squeeze(b1b2prior(:,2,2));
% 		b	= b1prior(:,1) + b2prior(:,2) + squeeze(b1b2prior(:,1,2));
% 		
		a	= squeeze(b1b2(:,2,2));
		b	= squeeze(b1b2(:,1,2));
		H1	= a-b;
		a	= squeeze(b1b2prior(:,2,2));
		b	=  squeeze(b1b2prior(:,1,2));
		H0	= a-b;
		bf	= pa_bayesfactor(H1,H0);
		BF(roiIdx).q4 = bf;
		
		
		%% Phoneme score Rest
		H1	= bMetI(:,1);
		H0	= bMetIprior(:,1);
		bf	= pa_bayesfactor(H1,H0);
		BF(roiIdx).qrest = bf;
		
		H1	= bMetI(:,2);
		H0	= bMetIprior(:,2);
		bf	= pa_bayesfactor(H1,H0);
		BF(roiIdx).qvideo = bf;
		
	end
	
	pa_datadir
	save petanalysis BF param samp
	
else
	load petanalysis
	load petancova
	
end
%%
nroi	= numel(data);
col		= pa_statcolor(100,[],[],[],'def',8);

if exist('E:\','dir')
	p		= 'E:\Backup\Nifti\';
else
	p = 'C:\DATA\KNO\PET\Nifti\';
end
fname	= 'gswro_s5834795-d20120323-mPET.img';
nii		= load_nii([p fname],[],[],1);
img		= nii.img;

indx	= 1:5:41;
nindx	= numel(indx);
% roi = char([data.roi]);

%% Brain
if ~loadbrainflag
	roifiles = [data.roi];
	%% he brain contour
	img = roicolourise(p,fname,roifiles,ones(length(roifiles),1),zeros(size(img)));
	IMG = [];
	for zIndx = 1:nindx
		tmp	= squeeze(img(:,:,indx(zIndx)));
		IMG	= [IMG;tmp];
	end
	braincontour = IMG;
	pa_datadir
	save braincontour braincontour
else
	load braincontour;
end


%%
b0flag	= true;
b1flag	= true;
b2flag		= true;
b1b2flag	= true;
xiflag		= true;

b0flag	= false;
b1flag	= false;
b2flag		= false;
b1b2flag	= false;
xiflag		= false;

crit		= 3;
% xflag = true;
%% Baseline b0
if b0flag
% 	colb0
% 	colb0		= pa_statcolor(100,[],[],[],'def',7);
	colb0 = hot(100);
colb0 = [[1 1 1];colb0];
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).b0;
	end
	img			= repmat(mean(MAP),size(img));
	img = NaN(size(img));
	img			= repmat(50,size(img));

	muimg1		= roicolourise2([data.roi],MAP,img);
	IMG	=		 [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		IMG		= [IMG;tmp]; %#ok<*AGROW>
	end
	figure(701)
	colormap(colb0)
	ucol = unique(IMG(:));
	contourf(IMG',ucol);
	shading flat
	% 	imagesc(IMG');
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([50 100])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Baseline \beta_0')
	for ii = 1:nindx
		str = round((indx(ii))*2)-52;
		str = num2str(str);
		text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
	end
	
	pa_datadir;
	print('-depsc','-painter',[mfilename '_b0']);
end

% return
%% General plasticity
if b1flag
	img = zeros(size(img));
	mu = struct([]);
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).b1(2)-param(roiIdx).b1(1);
		a = 1./BF(roiIdx).q1<crit;
		if a
			MAP(roiIdx) = 0;
		end
	end
	muimg1	= roicolourise2([data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
	end
	mu(1).img = muIMG1;
	
	IMG = [mu(1).img];
	figure(602)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-10 10])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Adaptation');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q1']);
end
% sel = 1./[BF.q1]>=crit;
% char([data(sel).roi])
% a = 1./[BF(sel).q1]
pa_datadir;
xlswrite('table1',[data.roi]',1,'A2');
xlswrite('table1',1./[BF.q1]',1,'C2');
p = NaN(nroi,2);
for ii = 1:nroi
	p(ii,1) = param(ii).b1(1);
	p(ii,2) = param(ii).b1(2);
end
p = p(:,2)-p(:,1);
xlswrite('table1',p,1,'B2');

% 	xlswrite('table1',vmap,1,'B');
% 	xlswrite('table1',rroi',2,'A');
% 	xlswrite('table1',rmap,2,'B');
	
% close all
%% Example
selroi = strcmp([data.roi],'MNI_Temporal_Inf_R_roi.mat');
stmIdx	= 1;
stp		= 25;
y		= data(selroi).FDG(:);
x1		= data(selroi).group(:); % group
x2		= data(selroi).stim(:); % stimulus
phi		= repmat(data(selroi).phoneme(:),5,1); % phoneme
sel		= ismember(x1,1:3) & ismember(x2,1:2) & y>30;
x1		= x1(sel);
y		= y(sel);
phi		= phi(sel);
figure(101)
subplot(131)
a		= samp(selroi).b0;
bias	= a(1:stp:end); % credible bias
a		= samp(selroi).b1;
b1		= a(1:stp:end,:); % credible group effect
a		= samp(selroi).b2;
b2		= a(1:stp:end,:); % credible stim effect
a		=  samp(selroi).bMetI;
gain	= mean(a(1:stp:end,:),2); whos gain
pho		= NaN(length(gain),2);
offset	= param(selroi).metM;
sel		= x1==1;
pho(:,1)	= gain.*pa_logit(nanmean((phi(sel))/100))-gain*offset;
sel		= x1==2;
pho(:,2)	= gain.*pa_logit(nanmean((phi(sel))/100))-gain*offset;
n	= numel(bias);
for ii = 1:n
	b = bias(ii) + b1(ii,:)+nanmean(b2(ii,:))+pho(ii,:);
	plot(1:2,b,'k-','Color',[.7 .7 .7],'LineWidth',1)
	hold on
end
gain	= mean(param(selroi).bMetI);
offset	= param(selroi).metM;
bias	= param(selroi).b0;
b1		= param(selroi).b1;
b2		= nanmean(param(selroi).b2(:));
b1b2	= mean(param(selroi).b1b2(:,:),2)';
sel		= x1==1;
pho		= NaN(1,2);
pho(1)	= gain*pa_logit(nanmean((phi(sel))/100))-gain*offset;
sel		= x1==2;
pho(2)	= gain*pa_logit(nanmean((phi(sel))/100))-gain*offset;
plot(1:2,bias+b1+b2+b1b2+pho,'Color','k','LineWIdth',2)
sel = x1==1;
plot(x1(sel)+randn(sum(sel),1)/10,y(sel),'ko','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
hold on
% plot(1,mean(y(sel)),'ro','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
sel = x1==2;
plot(x1(sel)+randn(sum(sel),1)/10,y(sel),'ks','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
% plot(2,mean(y(sel)),'ro','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
sel = x1==3;
plot(x1(sel),y(sel),'k^','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
% plot(3,mean(y(sel)),'ro','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
xlim([0 4])
axis square;
box off;
axis square;
set(gca,'TickDir','out','XTick',[1 2 3],'XTickLabel',{'Pre-CI','Post-CI','NH'});
ylabel('[^{18}f]FDG (ml/dl/min)');
xlabel('Group');
str = ['Region: ' char(data(selroi).roi) ', stimulus: ' num2str(stmIdx)];
title(str)
bf	= 1/BF(selroi).q1;
str = ['Bayes factor = ' num2str(bf,2)];
pa_text(0.5,0.9,str);
str = ['\beta_{post} - \beta_{pre} = ' num2str(b1(2)-b1(1),2)];
pa_text(0.5,0.8,str);


%% Visual areas
if b2flag
	img = zeros(size(img));
	mu = struct([]);
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).b2(2)-param(roiIdx).b2(1);
		a = 1./BF(roiIdx).q2<crit;
		if a
			MAP(roiIdx) = 0;
		end
	end
	muimg1	= roicolourise2([data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
	end
	mu(1).img = muIMG1;
	
	IMG = [mu(1).img];
	figure(603)
	colormap(col)
	% 	imagesc(IMG')
	ucol = unique(IMG(:));
	contourf(IMG',ucol);
	shading flat
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-10 10])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('VIDEO areas');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q2']);
end
pa_datadir;
xlswrite('table1',1./[BF.q2]',1,'E2');
p = NaN(nroi,2);
for ii = 1:nroi
	p(ii,1) = param(ii).b2(1);
	p(ii,2) = param(ii).b2(2);
end
p = p(:,2)-p(:,1);
xlswrite('table1',p,1,'D2');

%% Example
% close all
selroi = strcmp([data.roi],'MNI_Calcarine_L_roi.mat');
stmIdx	= 1;
stp		= 25;
y		= data(selroi).FDG(:);
x1		= data(selroi).group(:); % group
x2		= data(selroi).stim(:); % stimulus
phi		= repmat(data(selroi).phoneme(:),5,1); % phoneme
sel		= ismember(x1,1:3) & ismember(x2,1:2) & y>30;
x1		= x1(sel);
x2		= x2(sel);
y		= y(sel);
phi		= phi(sel);
figure(101)
subplot(132)
a		= samp(selroi).b0;
bias	= a(1:stp:end); % credible bias
a		= samp(selroi).b1;
b1		= a(1:stp:end,:); % credible group effect
a		= samp(selroi).b2;
b2		= a(1:stp:end,:); % credible stim effect
a		= samp(selroi).bMetI;
gain	= a(1:stp:end,:); whos gain
pho		= NaN(length(gain),2);
offset	= param(selroi).metM;
sel		= x2==1;
pho(:,1)	= gain(:,1).*nanmean(pa_logit((phi(sel))/100))-gain(1)*offset;
sel		= x2==2;
pho(:,2)	= gain(:,2).*nanmean(pa_logit((phi(sel))/100))-gain(2)*offset;
n	= numel(bias);
for ii = 1:n
	b = bias(ii) + nanmean(b1(ii,:)) + b2(ii,:)+pho(ii,:);
	plot(1:2,b,'k-','Color',[.7 .7 .7],'LineWidth',1)
	hold on
end
gain	=  param(selroi).bMetI;
offset	= param(selroi).metM;
bias	=  param(selroi).b0;
b1		=  nanmean(param(selroi).b1);
b2		=  param(selroi).b2(:);
b1b2	=  mean(param(selroi).b1b2(:,:),1)';
sel		= x2==1;
pho		= NaN(2,1);
pho(1)	= nanmean(gain(1)*pa_logit((phi(sel))/100))-gain(1)*offset;
sel		= x2==2;
pho(2)	= nanmean(gain(2)*pa_logit((phi(sel))/100))-gain(2)*offset;
plot(1:2,bias+b1+b2+b1b2+pho,'Color','k','LineWIdth',2)
hold on
sel = x1==1;
plot(x2(sel)+randn(sum(sel),1)/10,y(sel),'ko','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
% plot(1,mean(y(sel)),'ro','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
sel = x1==2;
plot(x2(sel)+randn(sum(sel),1)/10,y(sel),'ks','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
sel = x1==3;
plot(x2(sel)+randn(sum(sel),1)/10,y(sel),'k^','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
% plot(2,mean(y(sel)),'rs','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
xlim([0 3])
axis square;
box off;
axis square;
set(gca,'TickDir','out','XTick',[1 2],'XTickLabel',{'Rest','Video'});
ylabel('[^{18}f]FDG (ml/dl/min)');
xlabel('Group');
str = ['Region: ' char(data(selroi).roi) ', stimulus: ' num2str(stmIdx)];
title(str)
bf	= 1/BF(selroi).q2;
str = ['Bayes factor = ' num2str(bf,2)];
pa_text(0.1,0.9,str);
str = ['\beta_{video} - \beta_{rest} = ' num2str(b2(2)-b2(1),2)];
pa_text(0.1,0.8,str);


pa_datadir;
print('-depsc','-painter',[mfilename 'visual']);

%%
% keyboard
%% q7: does adaptation occur for rest?
% 		%		-	-	 - >
% 		%		Pre Post NH
% 		% | R	1,1 1,2	 1,3
% 		% | V   2,1 2,2  ...
% 		% | AV  3,1 ...  ...
% 		% NH AV - NH V
% 		H1 = squeeze(b1b2(:,1,2))-squeeze(b1b2(:,1,1));
% 		a = squeeze(b1b2prior(:,1,2));
% 		b = squeeze(b1b2prior(:,1,1));
% 		H0 = a-b;
% 		bf = pa_bayesfactor(H1,H0);
% 		BF(roiIdx).q7 = bf;
%

if b1b2flag
	img = zeros(size(img));
	mu = struct([]);
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		%		-	-	 - >
		%		Pre Post NH
		% | R	1,1 1,2	 1,3
		% | V   2,1 2,2  ...
		% | AV  3,1 ...  ...
% 		a = param(roiIdx).b1(2) + param(roiIdx).b2(1) + param(roiIdx).b1b2(2,1);
% 		b =  param(roiIdx).b1(1) + param(roiIdx).b2(1) + param(roiIdx).b1b2(1,1);
		a = param(roiIdx).b1b2(2,1);
		b =  param(roiIdx).b1b2(1,1);
		MAP(roiIdx) = a-b;
		
		% 		MAP(roiIdx) = param(roiIdx).b1b2(1,2)-param(roiIdx).b1b2(1,1);
		a = 1./BF(roiIdx).q3<crit;
		if a
			MAP(roiIdx) = 0;
		end
	end
	muimg1	= roicolourise2([data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
	end
	mu(1).img = muIMG1;
	
	IMG = [mu(1).img];
	figure(607)
	colormap(col)
	ucol = unique(IMG(:));
	contourf(IMG',ucol);
	shading flat
	% 	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Adaptation REST');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q3']);
end

xlswrite('table1',1./[BF.q3]',1,'G2');


p = NaN(nroi,1);
for roiIdx = 1:nroi
	param(roiIdx).b1b2
	a = param(roiIdx).b1b2(2,1);
	b =  param(roiIdx).b1b2(1,1);
	p(roiIdx) = a-b;
end
xlswrite('table1',p,1,'F2');

%% q8: does adaptation occur for video?
% 		%		-	-	 - >
% 		%		Pre Post NH
% 		% | R	1,1 1,2	 1,3
% 		% | V   2,1 2,2  ...
% 		% | AV  3,1 ...  ...
% 		% NH AV - NH V
% 		H1 = squeeze(b1b2(:,2,2))-squeeze(b1b2(:,2,1));
% 		a = squeeze(b1b2prior(:,2,2));
% 		b = squeeze(b1b2prior(:,2,1));
% 		H0 = a-b;
% 		bf = pa_bayesfactor(H1,H0);
% 		BF(roiIdx).q8 = bf;
if b1b2flag
	img = zeros(size(img));
	mu = struct([]);
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		%		-	-	 - >
		%		Pre Post NH
		% | R	1,1 1,2	 1,3
		% | V   2,1 2,2  ...
		% | AV  3,1 ...  ...
% 		a = param(roiIdx).b1(2) + param(roiIdx).b2(2) + param(roiIdx).b1b2(2,2);
% 		b =  param(roiIdx).b1(1) + param(roiIdx).b2(2) + param(roiIdx).b1b2(1,2);
		a = param(roiIdx).b1b2(2,2);
		b =  param(roiIdx).b1b2(1,2);
		MAP(roiIdx) = a-b;
		
		% 		MAP(roiIdx) = param(roiIdx).b1b2(2,2)-param(roiIdx).b1b2(2,1);
		a = 1./BF(roiIdx).q4<crit;
		if a
			MAP(roiIdx) = 0;
		end
	end
	muimg1	= roicolourise2([data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
	end
	mu(1).img = muIMG1;
	
	IMG = [mu(1).img];
	figure(608)
	colormap(col)
	ucol = unique(IMG(:));
	contourf(IMG',ucol);
	shading flat
	% 	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Adaptation VIDEO');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q4']);
end

xlswrite('table1',1./[BF.q4]',1,'I2');


p = NaN(nroi,1);
for roiIdx = 1:nroi
	param(roiIdx).b1b2
	a = param(roiIdx).b1b2(2,2);
	b =  param(roiIdx).b1b2(1,2);
	p(roiIdx) = a-b;
end
xlswrite('table1',p,1,'H2');



%%
% keyboard
%% q9rest: Phoneme score in rest
% 		%		-	-	 - >
% 		%		Pre Post NH
% 		% | R	1,1 1,2	 1,3
% 		% | V   2,1 2,2  ...
% 		% | AV  3,1 ...  ...
% 		% NH AV - NH V
% 		H1 = squeeze(b1b2(:,3,2))-squeeze(b1b2(:,3,3));
% 		a = squeeze(b1b2prior(:,3,2));
% 		b = squeeze(b1b2prior(:,3,3));
% 		H0 = a-b;
% 		bf = pa_bayesfactor(H1,H0);
% 		BF(roiIdx).q9 = bf;
if xiflag
	img = zeros(size(img));
	mu = struct([]);
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		%		-	-	 - >
		%		Pre Post NH
		% | R	1,1 1,2	 1,3
		% | V   2,1 2,2  ...
		% | AV  3,1 ...  ...
		MAP(roiIdx) = param(roiIdx).bMetI(1);
		
		% 		MAP(roiIdx) = param(roiIdx).b1b2(3,2)-param(roiIdx).b1b2(3,3);
		a = 1./BF(roiIdx).qrest<crit;
		if a
			MAP(roiIdx) = 0;
		end
	end
	muimg1	= roicolourise2([data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
	end
	mu(1).img = muIMG1;
	
	IMG = [mu(1).img];
	figure(901)
	colormap(col)
	ucol = unique(IMG(:));
	contourf(IMG',ucol);
	shading flat
	% 	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Phoneme score REST');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_qrest']);
end
pa_datadir;
xlswrite('table1',1./[BF.qrest]',1,'K2');
p = NaN(nroi,1);
for ii = 1:nroi
	p(ii,1) = param(ii).bMetI(1);
end
% p = p(:,2)-p(:,1);
xlswrite('table1',p,1,'J2');

%% qvideo: Phoneme score in rest
% 		%		-	-	 - >
% 		%		Pre Post NH
% 		% | R	1,1 1,2	 1,3
% 		% | V   2,1 2,2  ...
% 		% | AV  3,1 ...  ...
% 		% NH AV - NH V
% 		H1 = squeeze(b1b2(:,3,2))-squeeze(b1b2(:,3,3));
% 		a = squeeze(b1b2prior(:,3,2));
% 		b = squeeze(b1b2prior(:,3,3));
% 		H0 = a-b;
% 		bf = pa_bayesfactor(H1,H0);
% 		BF(roiIdx).q9 = bf;
if xiflag
	img = zeros(size(img));
	mu = struct([]);
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		%		-	-	 - >
		%		Pre Post NH
		% | R	1,1 1,2	 1,3
		% | V   2,1 2,2  ...
		% | AV  3,1 ...  ...
		MAP(roiIdx) = param(roiIdx).bMetI(2);
		
		% 		MAP(roiIdx) = param(roiIdx).b1b2(3,2)-param(roiIdx).b1b2(3,3);
		a = 1./BF(roiIdx).qvideo<crit;
		if a
			MAP(roiIdx) = 0;
		end
	end
	muimg1	= roicolourise2([data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
	end
	mu(1).img = muIMG1;
	
	IMG = [mu(1).img];
	figure(902)
	colormap(col)
	ucol = unique(IMG(:));
	contourf(IMG',ucol);
	shading flat
	% 	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Phoneme score VIDEO');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_qvideo']);
end
pa_datadir;
xlswrite('table1',1./[BF.qvideo]',1,'M2');
p = NaN(nroi,1);
for ii = 1:nroi
	p(ii,1) = param(ii).bMetI(2);
end
% p = p(:,2)-p(:,1);
xlswrite('table1',p,1,'L2');
%%
% close all
roi = 'MNI_Cuneus_R_roi.mat';
% roi = 'MNI_Frontal_Mid_Orb_L_roi.mat'
stm = 2;
figure(100)
subplot(131)
plotcred(data,param,samp,BF,roi,stm,[85 105])
xlim([85 105])
% xlim([65 85])




%%
roi = 'MNI_Temporal_Sup_L_roi.mat';
stm = 1;
figure(100)
subplot(132)
plotcred(data,param,samp,BF,roi,stm,[75 95])
xlim([75 95])


%%
% selroi = strcmp([data.roi],'MNI_Frontal_Mid_Orb_L_roi.mat');
% stmIdx	= 1;
% close all
bf = [BF.qvideo];


	[mx,indx] = max(bf);
% 	selroi = strcmp([data.roi],roi);
data(indx).roi
	
% 	bf	= 1/[BF(selroi).qrest];
% 	
roi = 'MNI_Cuneus_R_roi.mat';
roi = 'MNI_Amygdala_L_roi.mat';
stm = 2;
figure(100)
subplot(133)
plotcred(data,param,samp,BF,roi,stm,[50 70]);
% xlim([85 105])
% xlim([65 85])


% 
% roi = 'MNI_Temporal_Sup_L_roi.mat';
% stm = 2;
% figure(100)
% subplot(133)
% plotcred(data,param,samp,BF,roi,stm,[75 95])
% xlim([75 95])

% 
% stp		= 25;
% y		= data(selroi).FDG(:);
% x1		= data(selroi).group(:); % group
% x2		= data(selroi).stim(:); % stimulus
% xMet	=	data(selroi).phoneme;
% xMet(1:5) = 90;
% xMet	= repmat(xMet,5,1); % phoneme score
% sel		= ismember(x1,1:3) & ismember(x2,stmIdx) & y>30;
% x1		= x1(sel);
% y		= y(sel);
% xMet	= xMet(sel);
% figure(100)
% subplot(133)
% a		= samp(selroi).bMetI;
% a		= a(:,stmIdx);
% gain	= a(1:stp:end); % credible gains
% a		= samp(selroi).b0;
% bias	= a(1:stp:end); % credible bias
% a		= samp(selroi).b1;
% b1		= a(1:stp:end,:); % credible group effect
% a		= samp(selroi).b2;
% b2		= a(1:stp:end,stmIdx); % credible stim effect
% a		= samp(selroi).b1b2;
% b1b2	= squeeze(a(1:stp:end,:,stmIdx)); % credible stim effect
% nGain	= numel(gain);
% x = 0:0.001:1.0;
% p = pa_logit(x);
% for ii = 1:nGain
% 	fdg = gain(ii)*p;
% 	tmp = nanmean(b1b2(ii,:))+nanmean(b1(ii,:))+b2(ii);
% 	plot(x,fdg+bias(ii)+tmp,'k-','Color',[.7 .7 .7],'LineWidth',1)
% 	hold on
% end
% gain	=  param(selroi).bMetI(stmIdx);
% bias	=  param(selroi).b0;
% b1		=  mean(param(selroi).b1);
% b2		=  param(selroi).b2(stmIdx);
% b1b2	=  mean(param(selroi).b1b2(:,stmIdx));
% fdg		= gain*p;
% plot(x,fdg+bias+b1+b2+b1b2,'Color','k','LineWIdth',2)
% sel = x1==1;
% plot(xMet(sel)/100,y(sel),'ko','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
% hold on
% sel = x1==2;
% plot(xMet(sel)/100,y(sel),'ks','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
% sel = x1==3;
% plot(xMet(sel)/100,y(sel),'k^','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
% xlim([-0.1 1.1])
% ylim([75 95])
% axis square;
% box off;
% axis square;
% set(gca,'TickDir','out','XTick',0:0.1:1,'XTickLabel',0:10:100);
% ylabel('[^{18}f]FDG (ml/dl/min)');
% xlabel('Phoneme score (%)');
% str = ['Region: ' char(data(selroi).roi) ', stimulus: ' num2str(stmIdx)];
% title(str)
% pa_verline([0 1],'k-');
% if stmIdx ==2
% 	bf	= 1/BF(selroi).qvideo;
% else
% 	bf	= 1/BF(selroi).qrest;
% end
% str = ['Bayes factor = ' num2str(bf,2)];
% pa_text(0.5,0.9,str);
% str = ['\beta_{\phi} = ' num2str(gain,2)];
% pa_text(0.5,0.8,str);

pa_datadir
print('-depsc','-painter',[mfilename 'phoneme']);

function [img,indx] = roicolourise(p,files,roi,bf,img)
cd('E:\DATA\KNO\PET\marsbar-aal\');
nroi = numel(roi);
bf	= -log(bf);

% bf = round(bf/max(bf)*50)+50;
% 1-3-10-30-100
% No - Anecdotal - Moderate - Strong - Very - Extreme
levels	= log([1/100 1/100 1/30 1/10 1/3 1 3 10 30 100 100]);

nlevels = numel(levels);
% x		= repmat(bf,1,nlevels);
% x		= abs(bsxfun(@minus,x,levels));
% [~,indx] = min(x,[],2);

% n = numel(bf);
x = NaN(size(bf));
for ii = 2:nlevels-1
	sel = bf>=levels(ii) & bf<levels(ii+1);
	x(sel) = ii;
end
sel		= bf<levels(1);
x(sel)	= 1;
sel		= bf>=levels(end);
x(sel)	= nlevels;
indx	= x;
% indx = round(bf/max(bf)*50)+50;
for kk = 1:nroi
	roiname		= roi{kk};
	roi_obj		= maroi(roiname);
	fname		= [p files];
	[~,~,vXYZ]	= getdata(roi_obj, fname);
	x1 = vXYZ(1,:);
	y1 = vXYZ(2,:);
	z1 = vXYZ(3,:);
	for zIndx = 1:length(z1)
		img(x1(zIndx),y1(zIndx),z1(zIndx)) = indx(kk);
	end
end


function [img,indx] = roicolourise2(roi,indx,img)
if exist('E:\','dir')
	p		= 'E:\Backup\Nifti\';
else
	p = 'C:\DATA\KNO\PET\Nifti\';
end
files	= 'gswro_s5834795-d20120323-mPET.img';
if exist('E:\','dir')
	cd('E:\DATA\KNO\PET\marsbar-aal\');
else
	cd('C:\DATA\KNO\PET\marsbar-aal\');
end
nroi = numel(roi);
for kk = 1:nroi
	roiname		= roi{kk};
	roi_obj		= maroi(roiname);
	fname		= [p files];
	[~,~,vXYZ]	= getdata(roi_obj, fname);
	x1 = vXYZ(1,:);
	y1 = vXYZ(2,:);
	z1 = vXYZ(3,:);
	for zIndx = 1:length(z1)
		img(x1(zIndx),y1(zIndx),z1(zIndx)) = indx(kk);
	end
end

function BF = pa_bayesfactor(samplesPost,samplesPrior)
% samplesPost =
eps		= 0.01;
binse	= -100:eps:100;
crit = 0;
% Posterior
[f,xi]		= ksdensity(samplesPost,'kernel','normal');
[~,indk]	= min(abs(xi-crit));

% Prior on Delta
tmp			= samplesPrior;
tmp			= tmp(tmp>binse(1)&tmp<binse(end));
[f2,x2]		= ksdensity(tmp,'kernel','normal','support',[binse(1) binse(end)]);
[~,indk2]	= min(abs(x2-crit));

v1 = f(indk);
v2 = f2(indk2);
BF = v1/v2;

function plotcred(data,param,samp,BF,roi,stm,lm)

%%
selroi = strcmp([data.roi],roi);
stmIdx	= stm;

stp		= 25;
y		= data(selroi).FDG(:);
x1		= data(selroi).group(:); % group
x2		= data(selroi).stim(:); % stimulus
xMet	=	data(selroi).phoneme;
xMet(1:5) = 90;
xMet	= repmat(xMet,5,1); % phoneme score
sel		= ismember(x1,1:3) & ismember(x2,stmIdx) & y>30;
x1		= x1(sel);
y		= y(sel);
xMet	= xMet(sel);
offset	= param(selroi).metM;

a		= samp(selroi).bMetI;
a		= a(:,stmIdx);
gain	= a(1:stp:end); % credible gains
a		= samp(selroi).b0;
bias	= a(1:stp:end); % credible bias
a		= samp(selroi).b1;
b1		= a(1:stp:end,:); % credible group effect
a		= samp(selroi).b2;
b2		= a(1:stp:end,stmIdx); % credible stim effect
a		= samp(selroi).b1b2;
b1b2	= squeeze(a(1:stp:end,:,stmIdx)); % credible stim effect
nGain	= numel(gain);
x		= 0:0.001:1.0;
p		= pa_logit(x);
pMet	= pa_logit(xMet/100);
for ii = 1:nGain
	fdg = gain(ii)*p;
	tmp = nanmean(b1b2(ii,:))+nanmean(b1(ii,:))+b2(ii);
	plot(fdg+bias(ii)+tmp,pa_logistic(p+offset),'k-','Color',[.7 .7 .7],'LineWidth',1)
	hold on
	X(ii,:) = fdg+bias(ii)+tmp;
end
a		= prctile(X,[2.5 97.5]);

gain	=  param(selroi).bMetI(stmIdx);
bias	=  param(selroi).b0;
b1		=  mean(param(selroi).b1);
b2		=  param(selroi).b2(stmIdx);
b1b2	=  mean(param(selroi).b1b2(:,stmIdx));
fdg		= gain*p;
plot(fdg+bias+b1+b2+b1b2,pa_logistic(p+offset),'Color','r','LineWIdth',2)
plot(a,pa_logistic(p+offset),'LineWidth',2);

sel = x1==1;
plot(y(sel),xMet(sel)/100,'ko','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
hold on
sel = x1==2;
plot(y(sel),xMet(sel)/100,'ks','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
sel = x1==3;
plot(y(sel),xMet(sel)/100,'k^','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
ylim([-0.1 1.1])
xlim(lm)
axis square;
box off;
axis square;
set(gca,'TickDir','out','YTick',0:0.1:1,'YTickLabel',0:10:100,'XTick',0:5:150);
xlabel('[^{18}f]FDG (ml/dl/min)');
ylabel('Phoneme score (%)');
str = ['Region: ' char(data(selroi).roi) ', stimulus: ' num2str(stmIdx)];
title(str)
pa_horline([0 1],'k-');
if stmIdx ==2
	bf	= 1/BF(selroi).qvideo;
else
	bf	= 1/BF(selroi).qrest;
end
str = ['Bayes factor = ' num2str(bf,2)];
pa_text(0.5,0.9,str);
str = ['\beta_{\phi} = ' num2str(gain,2)];
pa_text(0.5,0.8,str);