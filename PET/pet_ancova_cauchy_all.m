function pet_ancova_cauchy_all
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
loadflag = false;
loadbrainflag = true;
% if ~exist(model,'file')
if ~loadflag
	if true
		% robust - with y ~ t instead of y~N
		% 		'\t\ty[i] ~ dt( mu[i],tau,nu)\r\n',...
		% 	 '\t# For sparse data with lots of outliers, there can be multimodal small-nu\r\n',...
		%   '\t# estimates, in which case you may want to change the prior to force a\r\n',...
		%   '\t# larger value of nu, such as \r\n',...
		%   '\t# nuMinusOne ~ dgamma(5.83,0.0483) # mode 100, sd 50\r\n',...
		%   '\tnu <- nuMinusOne+1\r\n',...
		%   '\tnuMinusOne ~  dexp(1/29)\r\n',...
% 					'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + a1a2[x1[i],x2[i]] + aS[S[i]]  + bMet*xMet[i]\r\n',...

		
		% with cauchy
		str = ['model {\r\n',...
			'\tfor ( i in 1:Ntotal ) {\r\n',...
			'\t\ty[i] ~ dnorm( mu[i],tau)\r\n',...
			'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + a1a2[x1[i],x2[i]] + aS[S[i]]  +(bMet+bMetI[x1[i],x2[i]])*xMet[i]\r\n',...
			'\t#Missing values\r\n',...
			'\t\t\tx1[i] ~ dnorm(mux,taux)\r\n',...
			'\t\t\tx2[i] ~ dnorm(mux,taux)\r\n',...
			'\t}\r\n',...
			'\t#\r\n',...
			'\ttau <- pow(sigma,-2)\r\n',...
			'\tsigma ~ dgamma(1.01005,0.1005) # y values are assumed to be standardized\r\n',...
			'\t#\r\n',...
			'\ta0 ~ dnorm(0,lambda0) # y values are assumed to be standardized\r\n',...
			'\tlambda0 ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { a1[j1] ~ dnorm(0.0,lambda1) }\r\n',...
			'\tlambda1 ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor (j2 in 1:Nx2Lvl) {a2[j2] ~ dnorm(0.0,lambda2) }\r\n',...
			'\tlambda2 ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor ( jS in 1:NSLvl ) { aS[jS] ~ dnorm(0.0,lambdaS) }\r\n',...
			'\tlambdaS ~ dchisqr(1)\r\n',...
			'\tbMet ~ dnorm(0.0,lambdaMet)\r\n',...
			'\tlambdaMet ~ dchisqr(1)\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
			'\t\tbMetI[j1,j2] ~ dnorm(0.0,lambdaMetI)\r\n',...
			'\t} }\r\n',...
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
			'\ta0prior ~ dnorm(0,lambda0prior) # y values are assumed to be standardized\r\n',...
			'\tlambda0prior ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { a1prior[j1] ~ dnorm(0.0,lambda1prior) }\r\n',...
			'\tlambda1prior ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor (j2 in 1:Nx2Lvl) {a2prior[j2] ~ dnorm(0.0,lambda2prior) }\r\n',...
			'\tlambda2prior ~ dchisqr(1)\r\n',...
			'\t#\r\n',...
			'\tfor ( jS in 1:NSLvl ) { aSprior[jS] ~ dnorm(0.0,lambdaSprior) }\r\n',...
			'\tlambdaSprior ~ dchisqr(1)\r\n',...
			'\tbMetprior ~ dnorm(0.0,lambdaMetprior)\r\n',...
			'\tlambdaMetprior ~ dchisqr(1)\r\n',...
			'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
			'\t\tbMetIprior[j1,j2] ~ dnorm(0.0,lambdaMetIprior)\r\n',...
			'\t} }\r\n',...
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
	
	
	
	%% THE DATA.
	% Load the data:
	pa_datadir
	load('petancova')
	nroi		= numel(data);
	param		= struct([]);
	col			= pa_statcolor(100,[],[],[],'def',8);
	dataStruct	= struct('y',[],'x1',[],'x2',[]);
	BF			= struct([]);
	for roiIdx = 1:nroi
		% 	data
		data(roiIdx).roi
		y		= data(roiIdx).FDG(:);
		x1		= data(roiIdx).group(:); % group
		x2		= data(roiIdx).stim(:); % stimulus
		S		=  repmat(data(roiIdx).subject(:),5,1); % subject
		xMet	= repmat(data(roiIdx).phoneme(:),5,1); % phoneme score
		xMet(1:5) = 90;
		% xMet(1:5)
		xMet	= pa_logit(xMet/100); % convert to -inf to + inf scale
		sel		= y<30; % remove unlikely FDG values, i.e. because of poor scan view
		y(sel)	= NaN;
		x1names	= {'Pre-implant','Post-implant','Normal-hearing'};
		x2names	= {'Rest','Video','Audio-Video'};
		% 	Snames	= {'S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','S11','S12','S13','S14','S15','S16'};
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
		linpred		= A1'+A2'+a0;
		a1a2		= accumarray([x1 x2],y,[],@nanmean)-a0-linpred;
		% 	b			= regstats(y,xMet,'linear','beta');
		
		% graphics
		figure(666)
		clf
		subplot(221)
		colormap(col);
		imagesc((linpred)')
		colorbar
		axis square
		set(gca,'YDir','reverse','XTick',1:3,'XTickLabel',x1names,'YTick',1:4,'YTickLabel',x2names)
		title('Likelihood');
		
			
		%% Data
		dataStruct.y		= z';
		dataStruct.x1		= x1;
		dataStruct.x2		= x2;
		dataStruct.xMet		= zMet;
		dataStruct.S		= S;
		dataStruct.Ntotal	= Ntotal;
		dataStruct.Nx1Lvl	= Nx1Lvl;
		dataStruct.Nx2Lvl	= Nx2Lvl;
		dataStruct.NSLvl	= NSLvl;
		
		%% INTIALIZE THE CHAINS.
		a0			= nanmean(dataStruct.y);
		a1			= accumarray(dataStruct.x1,dataStruct.y,[],@nanmean)-a0;
		a2			= accumarray(dataStruct.x2,dataStruct.y,[],@nanmean)-a0;
		aS			= accumarray(dataStruct.S,dataStruct.y,[],@nanmean)-a0;
		b			= regstats(dataStruct.y-a0,dataStruct.xMet,'linear','beta');
		nChains		= 5;
		initsStruct = struct([]);
		for ii = 1:nChains
			initsStruct(ii).a0		= a0;
			initsStruct(ii).a1		= a1;
			initsStruct(ii).a2		= a2;
			initsStruct(ii).aS		= aS;
			initsStruct(ii).a1a2	= a1a2;
			initsStruct(ii).bMet	= b.beta(2);
			initsStruct(ii).bMetI	= zeros(3,3);
			initsStruct(ii).a0prior		= a0;
			initsStruct(ii).a1prior		= a1;
			initsStruct(ii).a2prior		= a2;
			initsStruct(ii).aSprior		= aS;
			initsStruct(ii).a1a2prior	= a1a2;
			initsStruct(ii).bMetprior	= b.beta(2);		initsStruct(ii).sigma	= nanstd(dataStruct.y)/2; % lazy
			initsStruct(ii).bMetIprior	= zeros(3,3);
		end
		
		%% RUN THE CHAINS
		parameters		= {'b0','b1','b2','aS','b1b2','bMet','bMetI','bMetIprior','b0prior','b1prior','b2prior','aSprior','b1b2prior','bMetprior','sigma','lambda0','lambda1','lambda2','lambdaS','lamdaMet'};	% The parameter(s) to be monitored.
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
		% 	stats.Rhat
		% 	stats.Rhat.b1
		% 	stats.Rhat.b2
		% 	stats.Rhat.aS
		% 	return
		%% EXAMINE THE RESULTS
		% Extract b values:
		b0Sample	= samples.b0(:);
		chainLength = length(samples.b0);
		b1Sample	= reshape(samples.b1,nChains*chainLength,Nx1Lvl);
		b2Sample	= reshape(samples.b2,nChains*chainLength,Nx2Lvl);
		bSSample	= reshape(samples.aS,nChains*chainLength,NSLvl);
		b1b2Sample	=  reshape(samples.b1b2,nChains*chainLength,Nx1Lvl,Nx2Lvl);
		bMetSample	= samples.bMet(:);
		bMetISample		= reshape(samples.bMetI,nChains*chainLength,Nx1Lvl,Nx2Lvl);
		
		b0priorSample	= samples.b0prior(:);
		b1priorSample	= reshape(samples.b1prior,nChains*chainLength,Nx1Lvl);
		b2priorSample	= reshape(samples.b2prior,nChains*chainLength,Nx2Lvl);
		bSpriorSample	= reshape(samples.aSprior,nChains*chainLength,NSLvl);
		b1b2priorSample = reshape(samples.b1b2prior,nChains*chainLength,Nx1Lvl,Nx2Lvl);
		bMetpriorSample	= samples.bMetprior(:);
		bMetIpriorSample		= reshape(samples.bMetIprior,nChains*chainLength,Nx1Lvl,Nx2Lvl);
		
		% Convert from standardized b values to original scale b values:
		b0Sample	= b0Sample*ySDorig + yMorig;
		b1Sample	= b1Sample*ySDorig;
		b2Sample	= b2Sample*ySDorig;
		% 	bSSample	= bSSample*ySDorig;
		b1b2Sample	= b1b2Sample*ySDorig;
		bMetSample	= bMetSample*ySDorig/metSD;
		
		b0priorSample	= b0priorSample*ySDorig + yMorig;
		b1priorSample	= b1priorSample*ySDorig;
		b2priorSample	= b2priorSample*ySDorig;
		% 	bSSample	= bSSample*ySDorig;
		b1b2priorSample	= b1b2priorSample*ySDorig;
		bMetpriorSample	= bMetpriorSample*ySDorig/metSD;
		bMetIpriorSample = bMetIpriorSample*ySDorig;

% 		[z,yMorig,ySDorig]	= pa_zscore(y');
% 		[zMet,metM,metSD]	= pa_zscore(xMet');
		
		%% Bayes
		keyboard
		% BF = pa_bayesfactor(bMetSample,bMetpriorSample);
		
		%% Graphics
		% Plot b values:
		figure(2)
		clf
		histinfo	= plotPost(b0Sample,'xlab','\beta_0','main','Baseline');
		MAP0		= histinfo.mean;
		
		figure(3)
		clf
		MAPg = NaN(Nx1Lvl,1);
		for x1idx = 1:Nx1Lvl
			subplot(1,Nx1Lvl,x1idx)
			histinfo = plotPost(b1Sample(:,x1idx),'xlab','\beta_1','main',['x1:' x1names{x1idx}]);
			MAPg(x1idx) = histinfo.mean;
		end
		figure(4)
		clf
		MAPs = NaN(Nx2Lvl,1);
		for x2idx = 1:Nx2Lvl
			subplot(1,Nx2Lvl,x2idx)
			histinfo = plotPost(b2Sample(:,x2idx),'xlab','\beta_2','main',['x2:' x2names{x2idx}]);
			MAPs(x2idx) = histinfo.mean;
		end
		figure(5)
		clf
		subplot(121)
		plotPost(bMetSample(:),'xlab','\beta_{Phoneme}','main',['Phoneme']);
		
		figure(6)
		clf
		MAPgs = NaN(Nx1Lvl,Nx2Lvl);
		k = 0;
		for x1idx = 1:Nx1Lvl
			for x2idx = 1:Nx2Lvl
				k = k+1;
				subplot(Nx1Lvl,Nx2Lvl,k)
				histinfo = plotPost(squeeze(b1b2Sample(:,x1idx,x2idx)),'xlab','\beta_2','main',['x1:' x2names{x1idx} 'x2:' x2names{x2idx}]);
				MAPgs(x1idx,x2idx) = histinfo.mean;
			end
		end
		
		%% Bayes factors
		figure(7)
		clf
		samplesPost = NaN(numSavedSteps,Nx1Lvl,Nx2Lvl);
		k = 0;
		for x1idx = 1:Nx1Lvl
			for x2idx = 1:Nx2Lvl
				k = k+1;
				samplesPost(:,x1idx,x2idx) = b1Sample(:,x1idx)+b2Sample(:,x2idx)+squeeze(b1b2Sample(:,x1idx,x2idx));
				samplesPrior(:,x1idx,x2idx) = b1priorSample(:,x1idx)+b2priorSample(:,x2idx)+squeeze(b1b2priorSample(:,x1idx,x2idx));
				
				figure(7)
				subplot(3,3,k)
				plotPost(squeeze(samplesPost(:,x1idx,x2idx)),'compVal',0);
				
				
				% 			subplot(3,3,k)
				% 			plotPost(squeeze(samplesPrior(:,x1idx,x2idx)),'showCurve',true);
			end
		end
		% 	samplesPost = b1Sample+b2Sample
		% 	BF = pa_bayesfactor(samplesPost,samplesPrior);
		% Question 1: Does visual stimulation (2 re 1) activate auditory areas
		% in prelingually deaf (1)?
		gidx	= 1; % Pre-implant
		BF(roiIdx).q1a		= pa_bayesfactor(squeeze(samplesPost(:,gidx,2))-squeeze(samplesPost(:,gidx,1)),squeeze(samplesPrior(:,gidx,2))-squeeze(samplesPrior(:,gidx,1)),1);
		gidx	= 2; % Post-implant
		BF(roiIdx).q1b		= pa_bayesfactor(squeeze(samplesPost(:,gidx,2))-squeeze(samplesPost(:,gidx,1)),squeeze(samplesPrior(:,gidx,2))-squeeze(samplesPrior(:,gidx,1)),1);
		gidx	= 3; % Normal-hearing
		BF(roiIdx).q1c		= pa_bayesfactor(squeeze(samplesPost(:,gidx,2))-squeeze(samplesPost(:,gidx,1)),squeeze(samplesPrior(:,gidx,2))-squeeze(samplesPrior(:,gidx,1)),1);
		BF(roiIdx).q1text = 'Question 1: Does visual stimulation re rest activate auditory areas in pre a, post b, nh c?';
		
		% Question 2: Does auditory stimulation (3 re 2) activate auditory areas in CI-users (2)?
		gidx	= 2; % Post-implant
		BF(roiIdx).q2a		= pa_bayesfactor(squeeze(samplesPost(:,gidx,3))-squeeze(samplesPost(:,gidx,2)),squeeze(samplesPrior(:,gidx,3))-squeeze(samplesPrior(:,gidx,2)),2);
		gidx	= 3; % Post-implant
		BF(roiIdx).q2b		= pa_bayesfactor(squeeze(samplesPost(:,gidx,3))-squeeze(samplesPost(:,gidx,2)),squeeze(samplesPrior(:,gidx,3))-squeeze(samplesPrior(:,gidx,2)),2);
		BF(roiIdx).q2text = 'Question 2: Does auditory stimulation (3 re 2) activate auditory areas in CI-users a and NH b??';
		% Question 3: Does plasticity occur after cochlear implantation (2-1)
		sidx	= 1; % Stimulus index, rest
		BF(roiIdx).q3a		= pa_bayesfactor(squeeze(samplesPost(:,2,sidx))-squeeze(samplesPost(:,1,sidx)),squeeze(samplesPrior(:,2,sidx))-squeeze(samplesPrior(:,1,sidx)),3);
		sidx	= 2; % Stimulus index, video
		BF(roiIdx).q3b		= pa_bayesfactor(squeeze(samplesPost(:,2,sidx))-squeeze(samplesPost(:,1,sidx)),squeeze(samplesPrior(:,2,sidx))-squeeze(samplesPrior(:,1,sidx)),4);
		BF(roiIdx).q3text = 'Question 3: Does plasticity occur after cochlear implantationfor rest a, and vision b?';
		% Question 4: Does phoneme score matter?
		BF(roiIdx).q4text = 'Question 4: Does phoneme score matter?';
		BF(roiIdx).q4		= pa_bayesfactor(squeeze(bMetSample(:)),squeeze(bMetpriorSample(:)),5);
		
		% Question 5:
		% 	return
		%%
		
		param(roiIdx).MAPgs = MAPgs;
		param(roiIdx).MAPg = MAPg;
		param(roiIdx).MAPs = MAPs;
		param(roiIdx).Phoneme = bMetSample(:);
		[MAPg,MAPs]			= meshgrid(MAPg,MAPs);
		MAP					= MAPg+MAPs+MAP0+MAPgs;
		param(roiIdx).MAP	= MAPg+MAPs+MAPgs;
		
		figure(666)
		% 	subplot(224)
		% 	h	= scatter(b1Sample(:),b2Sample(:),15,'filled');
		%
		% 	title(MAP0);
		% 	axis square
		
		subplot(222)
		colormap(col)
		imagesc(MAP)
		axis square
		colorbar
		set(gca,'YDir','reverse','XTick',1:3,'XTickLabel',x1names,'YTick',1:3,'YTickLabel',x2names)
		title('Likelihood');
		
		subplot(234)
		colormap(col)
		imagesc(MAPg)
		axis square
		colorbar
		set(gca,'YDir','reverse','XTick',1:3,'XTickLabel',x1names,'YTick',1:3,'YTickLabel',x2names)
		title('Likelihood');
		caxis([-5 5]);
		
		subplot(235)
		colormap(col)
		imagesc(MAPs)
		axis square
		colorbar
		set(gca,'YDir','reverse','XTick',1:3,'XTickLabel',x1names,'YTick',1:3,'YTickLabel',x2names)
		title('Likelihood');
		caxis([-5 5]);
		
		subplot(236)
		colormap(col)
		imagesc(MAPgs)
		axis square
		colorbar
		set(gca,'YDir','reverse','XTick',1:3,'XTickLabel',x1names,'YTick',1:3,'YTickLabel',x2names)
		title('Likelihood');
		caxis([-5 5]);
		
		figure(7)
		% 	title(data(roiIdx).roi);
		drawnow
		% 	pause(.5)
	end
	
	pa_datadir
	save petanalysis BF param
	
else
	load petanalysis
	load petancova

end
%%
	nroi	= numel(data);
	col		= pa_statcolor(100,[],[],[],'def',8);
	p		= 'E:\Backup\Nifti\';
	fname	= 'gswro_s5834795-d20120323-mPET.img';
	nii		= load_nii([p fname],[],[],1);
	img		= nii.img;	
	
		indx	= 1:5:61;
	nindx	= numel(indx);
	roi = char([data.roi]);

%% Brain
if ~loadbrainflag
	roifiles = [data.roi];
	

	% 	%% he brain contour
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
% Question 1: Does visual stimulation (2 re 1) activate auditory areas
% in prelingually deaf (1)?
% Question 2: Does auditory stimulation (3 re 2) activate auditory areas in CI-users (2)?
% Question 3: Does plasticity occur after cochlear implantation (2-1)
% Question 4: Does phoneme score matter?
% keyboard

clc

% Bayes factors
figure(601)
q1a = log10(1./[BF.q1a]);
q1b = log10(1./[BF.q1b]);
q1c = log10(1./[BF.q1c]);
x = -10:0.5:10;
figure(700)
subplot(131)
plotPost(q1a')
pa_verline(log10([1/10 1/3 3 10]));
sel = q1a>log10(3);
roi(sel,:)

subplot(132)
plotPost(q1b')
pa_verline(log10([1/10 1/3 3 10]));
sel = q1b>log10(3);
roi(sel,:)

subplot(133)
plotPost(q1c')
pa_verline(log10([1/10 1/3 3 10]));
sel = q1c>log10(3);
roi(sel,:)


%% Image question 1
img = zeros(size(img));
mu = struct([]);
for jj = [1:2 4:5 7:8]
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).MAP(jj);
		switch jj
			case {1, 2}
				a = 1./BF(roiIdx).q1a<3;
			case {4, 5}
				a = 1./BF(roiIdx).q1b<3;
			case {7, 8}
				a = 1./BF(roiIdx).q1c<3;
		end
		if a
			MAP(roiIdx) = 0;
		end
	end
	muimg1	= roicolourise2(p,fname,[data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp];
	end
	mu(jj).img = muIMG1;
end

IMG = [mu(2).img-mu(1).img mu(5).img-mu(4).img mu(8).img-mu(7).img;];
figure(701)
colormap(col)
imagesc(IMG')
hold on
contour(repmat(braincontour',3,1),1,'k');
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Rest')
for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
end

pa_datadir;
print('-depsc','-painter',[mfilename 'question1']);



%% Image question 2
q2a = log10(1./[BF.q2a]);
q2b = log10(1./[BF.q2b]);
figure(602)
subplot(121)
plotPost(q2a')
pa_verline(log10([1/10 1/3 3 10]));
sel = q2a>log10(3);
roi(sel,:)

subplot(122)
plotPost(q2b')
pa_verline(log10([1/10 1/3 3 10]));
sel = q2b>log10(3);
roi(sel,:)
img = zeros(size(img));
mu = struct([]);
for jj = [5:6 8:9]
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).MAP(jj);
		switch jj
			case {5,6}
				a = 1./BF(roiIdx).q2a<3;
			case {8,9}
				a = 1./BF(roiIdx).q2b<3;
		end
		if a
			MAP(roiIdx) = 0;
		end
	end
	muimg1	= roicolourise2(p,fname,[data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp];
	end
	mu(jj).img = muIMG1;
end

IMG = [mu(6).img-mu(5).img mu(9).img-mu(8).img;];
figure(702)
colormap(col)
imagesc(IMG')
hold on
contour(repmat(braincontour',2,1),1,'k');
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Rest')
for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
end

pa_datadir;
print('-depsc','-painter',[mfilename 'question2']);

%% Image question 3
% Bayes factors
disp('---- ROI Question 3 -------');
figure(601)
q3a = log10(1./[BF.q3a]);
q3b = log10(1./[BF.q3b]);
x = -10:0.5:10;
figure(603)
subplot(121)
plotPost(q3a')
pa_verline(log10([1/10 1/3 3 10]));
sel = q3a>log10(3);
roi(sel,:)

subplot(122)
plotPost(q3b')
pa_verline(log10([1/10 1/3 3 10]));
sel = q3b>log10(3);
roi(sel,:)


img = zeros(size(img));
mu = struct([]);
for jj = [1:2 4:5]
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).MAP(jj);
		switch jj
			case {1, 4}
				a = 1./BF(roiIdx).q3a<=3;
			case {2, 5}
				a = 1./BF(roiIdx).q3b<=3;
		end
		if a
			MAP(roiIdx) = NaN;
		else
			roi(roiIdx,:)
		end
	end
	muimg1	= roicolourise2(p,fname,[data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp];
	end
	mu(jj).img = muIMG1;
end

IMG = [mu(4).img-mu(1).img mu(5).img-mu(2).img ];
IMG(isnan(IMG)) = 0;
figure(703)
colormap(col)
imagesc(IMG')
hold on
contour(repmat(braincontour',2,1),1,'k');
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Rest')
for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
end

pa_datadir;
print('-depsc','-painter',[mfilename 'question3']);
%% Image question 4
% Bayes factors
disp('---- ROI Question 4 -------');
q4 = log10(1./[BF.q4]);
figure(604)
plotPost(q4')
pa_verline(log10([1/10 1/3 3 10]));
sel = q4>log10(3);
roi(sel,:)


img = zeros(size(img));
mu = struct([]);
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = nanmean(param(roiIdx).Phoneme(:));
				a = 1./BF(roiIdx).q4<3;
		if a
			MAP(roiIdx) = NaN;
		else
			roi(roiIdx,:)
		end
	end
	muimg1	= roicolourise2(p,fname,[data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp];
	end
IMG = muIMG1;
% IMG = [mu(4).img-mu(1).img mu(5).img-mu(2).img ];
IMG(isnan(IMG)) = 0;
figure(704)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k');
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Rest')
for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
end

pa_datadir;
print('-depsc','-painter',[mfilename 'question4']);


%%
return
%%
a = repmat(mu(1).img,1,8);
a = 0
IMG = [mu(1).img mu(2).img mu(4).img mu(5).img mu(6).img  mu(7).img mu(8).img  mu(9).img]-a;

figure(900)
colormap(col)

imagesc(IMG')
hold on
contour(repmat(braincontour,1,8)',1,'k')

axis equal
% 	caxis([-80 80]);
% 	caxis([-1 1])
% caxis([90 100])
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off

%% Question 1: Is there plasticity?
close all
% Let's compare Pre vs Post rest
IMG = mu(4).img-mu(1).img;
figure(901)
subplot(211)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Rest')

IMG = mu(5).img-mu(2).img;
figure(901)
subplot(212)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Video');

%% Question 2: Crossmodal activity?
% Let's compare V vs Rest
IMG = mu(2).img-mu(1).img;
figure(902)
subplot(311)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Pre')

IMG = mu(5).img-mu(4).img;
figure(902)
subplot(312)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Post');

IMG = mu(8).img-mu(7).img;
figure(902)
subplot(313)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('NH');

%% Question 2: Audiovisual activity?
% Let's compare V vs Rest

IMG = mu(6).img-mu(5).img;
figure(903)
subplot(211)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Post');

IMG = mu(9).img-mu(8).img;
figure(903)
subplot(212)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('NH');
%%
keyboard
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


function [img,indx] = roicolourise2(p,files,roi,indx,img)
cd('E:\DATA\KNO\PET\marsbar-aal\');
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


function BF = pa_bayesfactor(samplesPost,samplesPrior,sb)
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
% BF = [v1/v2 log(v1)-log(v2)];
BF = v1/v2;

% figure(555+sb)
% clf
% subplot(122)
% plot(x2,f2,'k-');
% hold on
% plot(xi,f,'r-');
% axis square;
% box off
% set(gca,'TickDir','out');
% title(1/BF(1))