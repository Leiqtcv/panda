function pet_bayesiananalysis_withinS_phistimnotgroup
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
			'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + a1a2[x1[i],x2[i]] + aS[S[i]]   + (bMetI[x2[i]])*xMet[i]\r\n',...
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
	
	
	
	%% THE DATA.
	% Load the data:
	pa_datadir
	load('petancova')
	nroi		= numel(data);
	param		= struct([]);
	dataStruct	= struct('y',[],'x1',[],'x2',[]);
	BF			= struct([]);
	for roiIdx = 1:nroi
		% 	data
		data(roiIdx).roi
		y		= data(roiIdx).FDG(:);
		x1		= data(roiIdx).group(:); % group
		x2		= data(roiIdx).stim(:); % stimulus
		S = data(roiIdx).subject(:);
		S		=  repmat(S,5,1); % subject
		xMet	=	data(roiIdx).phoneme;
		
		xMet(1:5) = 80;
		xMet	= repmat(xMet,5,1); % phoneme score
		% xMet(1:5)
		xMet	= pa_logit(xMet/100); % convert to -inf to + inf scale
		sel		= y<30; % remove unlikely FDG values, i.e. because of poor scan view
		y(sel)	= NaN;
% 		x1names	= {'Pre-implant','Post-implant','Normal-hearing'};
% 		x2names	= {'Rest','Video','Audio-Video'};
		% 	Snames	= {'S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','S11','S12','S13','S14','S15','S16'};
		Ntotal	= length(y);
		Nx1Lvl	= length(unique(x1));
		Nx2Lvl	= length(unique(x2));
		NSLvl	= length(unique(S));
		% Normalize, for JAGS MCMC sampling, e.g. to use cauchy(0,1) prior
		[z,yMorig,ySDorig]	= pa_zscore(y');
		zMet	= pa_zscore(xMet');
% 		[zMet,metM,metSD]	= pa_zscore(xMet');
		
		% 		a0			= nanmean(y);
		% 		a1			= accumarray(x1,y,[],@nanmean)-a0;
		% 		a2			= accumarray(x2,y,[],@nanmean)-a0;
		% 		[A1,A2]		= meshgrid(a1,a2);
		% 		linpred		= A1'+A2'+a0;
		% 		a1a2		= accumarray([x1 x2],y,[],@nanmean)-linpred;
		
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
		a1a2 = a1a2';
		%% a1a2
		%		-	-	 - >
		%		Pre Post NH
		% | R	1,1 1,2	 1,3
		% | V   2,1 2,2  ...
		% | AV  3,1 ...  ...
		% v
		% 	b			= regstats(y,xMet,'linear','beta');
		
		% graphics
% 		figure(666)
% 		clf
% 		subplot(221)
% 		colormap(col);
% 		imagesc((linpred)')
% 		colorbar
% 		axis square
% 		set(gca,'YDir','reverse','XTick',1:3,'XTickLabel',x1names,'YTick',1:4,'YTickLabel',x2names)
% 		title('Likelihood');
		
		
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
			initsStruct(ii).bMetI	= zeros(3,1);
			initsStruct(ii).a0prior		= a0;
			initsStruct(ii).a1prior		= a1;
			initsStruct(ii).a2prior		= a2;
			initsStruct(ii).aSprior		= aS;
			initsStruct(ii).a1a2prior	= a1a2;
			initsStruct(ii).bMetprior	= b.beta(2);		initsStruct(ii).sigma	= nanstd(dataStruct.y)/2; % lazy
			initsStruct(ii).bMetIprior	= zeros(3,1);
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
			stats.Rhat
			stats.Rhat.b1
			stats.Rhat.b2
		% 	stats.Rhat.aS
		% 	return
		%% EXAMINE THE RESULTS
		% Extract b values:
		b0	= samples.b0(:);
		chainLength = length(samples.b0);
		b1	= reshape(samples.b1,nChains*chainLength,Nx1Lvl);
		b2	= reshape(samples.b2,nChains*chainLength,Nx2Lvl);
		% 		bS	= reshape(samples.aS,nChains*chainLength,NSLvl);
		b1b2	=  reshape(samples.b1b2,nChains*chainLength,Nx1Lvl,Nx2Lvl);
		bMetI		= reshape(samples.bMetI,nChains*chainLength,Nx2Lvl);
		
% 		b0prior	= samples.b0prior(:);
		b1prior	= reshape(samples.b1prior,nChains*chainLength,Nx1Lvl);
		b2prior	= reshape(samples.b2prior,nChains*chainLength,Nx2Lvl);
		% 		bSprior	= reshape(samples.aSprior,nChains*chainLength,NSLvl);
		b1b2prior = reshape(samples.b1b2prior,nChains*chainLength,Nx1Lvl,Nx2Lvl);
		bMetIprior		= reshape(samples.bMetIprior,nChains*chainLength,Nx2Lvl);
		
		% Convert from standardized b values to original scale b values:
		b0	= b0*ySDorig + yMorig;
		b1	= b1*ySDorig;
		b2	= b2*ySDorig;
		% 	bS	= bS*ySDorig;
		b1b2	= b1b2*ySDorig;
		bMetI = bMetI*ySDorig;

% 		b0prior	= b0prior*ySDorig + yMorig;
		b1prior	= b1prior*ySDorig;
		b2prior	= b2prior*ySDorig;
		% 	bS	= bS*ySDorig;
		b1b2prior	= b1b2prior*ySDorig;
		bMetIprior = bMetIprior*ySDorig;
		
		param(roiIdx).b0 = mean(b0);
		param(roiIdx).b1 = mean(b1);
		param(roiIdx).b2 = mean(b2);
		param(roiIdx).b1b2 = squeeze(mean(b1b2));
		param(roiIdx).bMetI = squeeze(mean(bMetI));
		
		
		%% Hypothesis testing
		% q1: are prelingually deaf different from normal-hearing? Main
		% factor
		H1 = sum(b1(:,[1 2]),2)/2-b1(:,3);
		H0 = sum(b1prior(:,[1 2]),2)/2-b1prior(:,3);
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).q1 = bf;
		
		% q2: is there some change after one year of implantation? Main
		% factor
		H1 = b1(:,2)-b1(:,1);
		H0 = b1prior(:,2)-b1prior(:,1);
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).q2 = bf;
		
		% q3: what are visual areas?? Main
		% factor
		H1 = b2(:,2)-b2(:,1);
		H0 = b2prior(:,2)-b2prior(:,1);
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).q3 = bf;
		
		% q4: what are auditory areas?? Main
		% factor
		H1 = b2(:,3)-b2(:,2);
		H0 = b2prior(:,3)-b2prior(:,2);
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).q4 = bf;
	
		% q5: do normal-hearing have auditory areas?
		%		-	-	 - >
		%		Pre Post NH
		% | R	1,1 1,2	 1,3
		% | V   2,1 2,2  ...
		% | AV  3,1 ...  ...
		% NH AV - NH V
		a = b1(:,3) + b2(:,3) + squeeze(b1b2(:,3,3));
		b =  b1(:,3) + b2(:,2) + squeeze(b1b2(:,3,2));
		H1 = a-b;
		a = b1prior(:,3) + b2prior(:,3) + squeeze(b1b2prior(:,3,3));
		b = b1prior(:,3) + b2prior(:,2) + squeeze(b1b2prior(:,3,2));
		H0 = a-b;
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).q5 = bf;
		
		% q6: do POST have auditory areas?
		%		-	-	 - >
		%		Pre Post NH
		% | R	1,1 1,2	 1,3
		% | V   2,1 2,2  ...
		% | AV  3,1 ...  ...
		% NH AV - NH V
% 		H1 = squeeze(b1b2(:,3,2))-squeeze(b1b2(:,2,2));
% 		a = squeeze(b1b2prior(:,3,2));
% 		b = squeeze(b1b2prior(:,2,2));
% 		H0 = a-b;

		a = b1(:,2) + b2(:,3) + squeeze(b1b2(:,2,3));
		b =  b1(:,2) + b2(:,2) + squeeze(b1b2(:,2,2));
		H1 = a-b;
		a = b1prior(:,2) + b2prior(:,3) + squeeze(b1b2prior(:,2,3));
		b = b1prior(:,2) + b2prior(:,2) + squeeze(b1b2prior(:,2,2));
		H0 = a-b;
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).q6 = bf;
		
		% q7: does adaptation occur for rest?
		%		-	-	 - >
		%		Pre Post NH
		% | R	1,1 1,2	 1,3
		% | V   2,1 2,2  ...
		% | AV  3,1 ...  ...
		% NH AV - NH V
% 		H1 = squeeze(b1b2(:,1,2))-squeeze(b1b2(:,1,1));
% 		a = squeeze(b1b2prior(:,1,2));
% 		b = squeeze(b1b2prior(:,1,1));

		a = b1(:,2) + b2(:,1) + squeeze(b1b2(:,2,1));
		b =  b1(:,1) + b2(:,1) + squeeze(b1b2(:,1,1));
		H1 = a-b;
		a = b1prior(:,2) + b2prior(:,1) + squeeze(b1b2prior(:,2,1));
		b = b1prior(:,1) + b2prior(:,1) + squeeze(b1b2prior(:,1,1));
		H0 = a-b;
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).q7 = bf;
		
		% q8: does adaptation occur for video?
		%		-	-	 - >
		%		Pre Post NH
		% | R	1,1 1,2	 1,3
		% | V   2,1 2,2  ...
		% | AV  3,1 ...  ...
		% NH AV - NH V
% 		H1 = squeeze(b1b2(:,2,2))-squeeze(b1b2(:,2,1));
% 		a = squeeze(b1b2prior(:,2,2));
% 		b = squeeze(b1b2prior(:,2,1));

		a = b1(:,2) + b2(:,2) + squeeze(b1b2(:,2,2));
		b =  b1(:,1) + b2(:,2) + squeeze(b1b2(:,1,2));
		H1 = a-b;
		a = b1prior(:,2) + b2prior(:,2) + squeeze(b1b2prior(:,2,2));
		b = b1prior(:,1) + b2prior(:,2) + squeeze(b1b2prior(:,1,2));
		H0 = a-b;
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).q8 = bf;
		
		% q9: is audiovisual response different for POST and NH?
		%		-	-	 - >
		%		Pre Post NH
		% | R	1,1 1,2	 1,3
		% | V   2,1 2,2  ...
		% | AV  3,1 ...  ...
		% NH AV - NH V
% 		H1 = squeeze(b1b2(:,3,2))-squeeze(b1b2(:,3,3));
% 		a = squeeze(b1b2prior(:,3,2));
% 		b = squeeze(b1b2prior(:,3,3));

		a = b1(:,2) + b2(:,3) + squeeze(b1b2(:,2,3));
		b =  b1(:,1) + b2(:,3) + squeeze(b1b2(:,1,3));
		H1 = a-b;
		a = b1prior(:,2) + b2prior(:,3) + squeeze(b1b2prior(:,2,3));
		b = b1prior(:,1) + b2prior(:,3) + squeeze(b1b2prior(:,1,3));
		H0 = a-b;
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).q9 = bf;
		
		%% Phoneme score Rest
% 				bMetI = bMetI*ySDorig;
		H1 = bMetI(:,1);
		H0 = bMetIprior(:,1);
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).qrest = bf;

		H1 = bMetI(:,2);
		H0 = bMetIprior(:,2);
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).qvideo = bf;

		H1 = bMetI(:,3);
		H0 = bMetIprior(:,3);
		bf = pa_bayesfactor(H1,H0);
		BF(roiIdx).qav = bf;
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

if exist('E:\','dir')
p		= 'E:\Backup\Nifti\';
else
p = 'C:\DATA\KNO\PET\Nifti\';
end
fname	= 'gswro_s5834795-d20120323-mPET.img';
nii		= load_nii([p fname],[],[],1);
img		= nii.img;

indx	= 1:5:61;
nindx	= numel(indx);
% roi = char([data.roi]);

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
b0flag = true;
b1flag = true;
b2flag = true;
b1b2flag = true;
xiflag = true;
% xflag = true;
%% Baseline b0
if b0flag
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).b0;

	end
	img			= repmat(mean(MAP),size(img));
	muimg1		= roicolourise2([data.roi],MAP,img);
	IMG	=		 [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		IMG		= [IMG;tmp]; %#ok<*AGROW>
	end
	figure(701)
	colormap(col)
	imagesc(IMG')
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

%% Is prelingually deaf different from normal-hearing?
if b1flag
	img = zeros(size(img));
	mu = struct([]);
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = (param(roiIdx).b1(1)+param(roiIdx).b1(2))/2-param(roiIdx).b1(3);
		a = 1./BF(roiIdx).q1<10;
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
	figure(601)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-10 10])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Prelingual deaf \neq normal-hearing');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q1']);
end
sel = 1./[BF.q1]>=10;
char([data(sel).roi])
a = 1./[BF(sel).q1] %#ok<*NOPRT,*NASGU>

%%
% keyboard


%% General plasticity
if b1flag
	img = zeros(size(img));
	mu = struct([]);
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).b1(2)-param(roiIdx).b1(1);
		a = 1./BF(roiIdx).q2<3;
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
	print('-depsc','-painter',[mfilename '_q2']);
end
sel = 1./[BF.q2]>=10;
char([data(sel).roi])
a = 1./[BF(sel).q2]


%% Visual areas
if b2flag
	img = zeros(size(img));
	mu = struct([]);
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).b2(2)-param(roiIdx).b2(1);
		a = 1./BF(roiIdx).q3<3;
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
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-10 10])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('VIDEO areas');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q3']);
end
sel = 1./[BF.q3]>=3;
char([data(sel).roi])
a = 1./[BF(sel).q3]


%% Auditory areas
if b2flag
	img = zeros(size(img));
	mu = struct([]);
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).b2(3)-param(roiIdx).b2(2);
		a = 1./BF(roiIdx).q4<1;
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
	figure(604)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('AUDIO areas');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q4']);
end
sel = 1./[BF.q4]>=1;
char([data(sel).roi])
a = 1./[BF(sel).q4]

%% Auditory areas NH
% 		H1 = squeeze(b1b2(:,3,3))-squeeze(b1b2(:,3,2));
% a = b1(:,3) + b2(:,3) + squeeze(b1b2(:,3,3));
% 		b =  b1(:,3) + b2(:,2) + squeeze(b1b2(:,2,3));
% 		H1 = a-b;
% 		a = b1prior(:,3) + b2prior(:,3) + squeeze(b1b2prior(:,3,3));
% 		b = b1prior(:,3) + b2prior(:,2) + squeeze(b1b2prior(:,2,3));
% 		H0 = a-b;
% 		bf = pa_bayesfactor(H1,H0);
% 		BF(roiIdx).q5 = bf;
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
a = param(roiIdx).b1(3) + param(roiIdx).b2(3) + param(roiIdx).b1b2(3,3);
		b =  param(roiIdx).b1(3) + param(roiIdx).b2(2) + param(roiIdx).b1b2(3,2);
		MAP(roiIdx) = a-b;
		a = 1./BF(roiIdx).q5<3;
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
	figure(605)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('AUDIO areas NH');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q5']);
end

sel = 1./[BF.q5]>=3;
char([data(sel).roi])
a = 1./[BF(sel).q5]


%% q6: do POST have auditory areas?
% 		%		-	-	 - >
% 		%		Pre Post NH
% 		% | R	1,1 1,2	 1,3
% 		% | V   2,1 2,2  ...
% 		% | AV  3,1 ...  ...
% 		% NH AV - NH V
% 		H1 = squeeze(b1b2(:,3,2))-squeeze(b1b2(:,2,2));
% 		a = squeeze(b1b2prior(:,3,2));
% 		b = squeeze(b1b2prior(:,2,2));
% 		H0 = a-b;
% 		bf = pa_bayesfactor(H1,H0);
% 		BF(roiIdx).q6 = bf;
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
a = param(roiIdx).b1(2) + param(roiIdx).b2(3) + param(roiIdx).b1b2(2,3);
		b =  param(roiIdx).b1(2) + param(roiIdx).b2(2) + param(roiIdx).b1b2(2,2);
		MAP(roiIdx) = a-b;
		
		a = 1./BF(roiIdx).q6<3;
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
	figure(606)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('AUDIO areas POST');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q6']);
end

sel = 1./[BF.q6]>=3;
char([data(sel).roi])
a = 1./[BF(sel).q6]

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
a = param(roiIdx).b1(2) + param(roiIdx).b2(1) + param(roiIdx).b1b2(2,1);
		b =  param(roiIdx).b1(1) + param(roiIdx).b2(1) + param(roiIdx).b1b2(1,1);
		MAP(roiIdx) = a-b;

% 		MAP(roiIdx) = param(roiIdx).b1b2(1,2)-param(roiIdx).b1b2(1,1);
		a = 1./BF(roiIdx).q7<3;
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
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Adaptation REST');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q7']);
end

sel = 1./[BF.q7]>=1/3;
char([data(sel).roi])
a = 1./[BF(sel).q7]

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
a = param(roiIdx).b1(2) + param(roiIdx).b2(2) + param(roiIdx).b1b2(2,2);
		b =  param(roiIdx).b1(1) + param(roiIdx).b2(2) + param(roiIdx).b1b2(1,2);
		MAP(roiIdx) = a-b;

% 		MAP(roiIdx) = param(roiIdx).b1b2(2,2)-param(roiIdx).b1b2(2,1);
		a = 1./BF(roiIdx).q8<3;
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
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Adaptation VIDEO');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q8']);
end

sel = 1./[BF.q8]>=3;
char([data(sel).roi])
a = 1./[BF(sel).q8]

%% q9: is audiovisual response different for POST and NH?
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
a = param(roiIdx).b1(2) + param(roiIdx).b2(3) + param(roiIdx).b1b2(2,3);
		b =  param(roiIdx).b1(1) + param(roiIdx).b2(3) + param(roiIdx).b1b2(1,3);
		MAP(roiIdx) = a-b;

% 		MAP(roiIdx) = param(roiIdx).b1b2(3,2)-param(roiIdx).b1b2(3,3);
		a = 1./BF(roiIdx).q9<3;
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
	figure(609)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('\Delta AUDIO Post-NH');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_q9']);
end

sel = 1./[BF.q9]>=1;
char([data(sel).roi])
a = 1./[BF(sel).q9]

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
		a = 1./BF(roiIdx).qrest<1;
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
	imagesc(IMG')
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

sel = 1./[BF.qrest]>=1;
char([data(sel).roi])
a = 1./[BF(sel).qrest]

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
		a = 1./BF(roiIdx).qvideo<1;
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
	imagesc(IMG')
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

sel = 1./[BF.qvideo]>=1;
char([data(sel).roi])
a = 1./[BF(sel).qvideo]

%% qav: Phoneme score in rest
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
		MAP(roiIdx) = param(roiIdx).bMetI(3);

% 		MAP(roiIdx) = param(roiIdx).b1b2(3,2)-param(roiIdx).b1b2(3,3);
		a = 1./BF(roiIdx).qav<1;
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
	figure(903)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Phoneme score AV');
	pa_datadir;
	print('-depsc','-painter',[mfilename '_qav']);
end

sel = 1./[BF.qav]>=1;
char([data(sel).roi])
a = 1./[BF(sel).qav]

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
