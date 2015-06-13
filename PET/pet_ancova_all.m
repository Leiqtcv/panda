function pet_ancova_all
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

close all
model = 'petancova.txt';



%% THE MODEL.
% Ntotal = n data points
% a0 = bias
% a1/x1 = Group Pre vs Post vs NH
% a2/x2 = Stimulus Rest vs V vs AV
% aS/S = subject 1-16
% bMet*xMet = phoneme score 0-100 %
% 		'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + bMet*xMet[i]\r\n',...
% 		'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + aS[S[i]] + bMet*xMet[i]\r\n',...
% 		'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + aS[S[i]]\r\n',...
% 		'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] \r\n',...

if ~exist(model,'file')
	% if true
% 	str = ['model {\r\n',...
% 		'\tfor ( i in 1:Ntotal ) {\r\n',...
% 		'\t\ty[i] ~ dnorm( mu[i],tau )\r\n',...
% 		'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + aS[S[i]] + bMet*xMet[i]\r\n',...
% 		'#Missing values\r\n',...
% 		'\t\t\tx1[i] ~ dnorm(mux,taux)\r\n',...
% 		'\t\t\tx2[i] ~ dnorm(mux,taux)\r\n',...
% 		'\t}\r\n',...
% 		'\t#\r\n',...
% 		'\ttau <- pow(sigma,-2)\r\n',...
% 		'\tsigma ~ dunif(0,10) # y values are assumed to be standardized\r\n',...
% 		'\t#\r\n',...
% 		'\ta0 ~ dnorm(0,0.001) # y values are assumed to be standardized\r\n',...
% 		'\t#\r\n',...
% 		'\tfor ( j1 in 1:Nx1Lvl ) { a1[j1] ~ dnorm(0.0,a1tau) }\r\n',...
% 		'\ta1tau <- 1/pow(a1SD,2)\r\n',...
% 		'\ta1SD <- abs(a1SDunabs) + .1\r\n',...
% 		'\ta1SDunabs ~ dt(0,0.001,2)\r\n',...
% 		'\t#\r\n',...
% 		'\tfor (j2 in 1:Nx2Lvl) {a2[j2] ~ dnorm( 0.0 , a2tau ) }\r\n',...
% 		'\ta2tau <- 1 / pow( a2SD , 2 )\r\n',...
% 		'\ta2SD <- abs( a2SDunabs ) + .1\r\n',...
% 		'\ta2SDunabs ~ dt( 0 , 0.001 , 2 )\r\n',...
% 		'\t#\r\n',...
% 		'\tfor ( jS in 1:NSLvl ) { aS[jS] ~ dnorm( 0.0 , aStau ) }\r\n',...
% 		'\taStau <- 1/pow(aSSD,2)\r\n',...
% 		'\taSSD <- abs(aSSDunabs)+.1\r\n',...
% 		'\taSSDunabs ~ dt(0,0.001,2)\r\n',...
% 		'\tbMet ~ dnorm(0.0,btau)\r\n',...
% 		'\tbtau <- 1/pow(bSD,2)\r\n',...
% 		'\tbSD <- abs(bSDunabs)+.1\r\n',...
% 		'\tbSDunabs ~ dt(0,0.001,2)\r\n',...
% 		'\t#Vague priors on missing predictors,\r\n',...
% 		'\t#assuming predictor variances are equal\r\n',...
% 		'\ttaux ~ dgamma(0.001,0.001)\r\n',...
% 		'\tmux ~ dnorm(0,1.0E-12)\r\n',...
% 		'}\r\n',...
% 		];

	str = ['model {\r\n',...
		'\tfor ( i in 1:Ntotal ) {\r\n',...
		'\t\ty[i] ~ dnorm( mu[i],tau )\r\n',...
		'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + aS[S[i]] + bMet*xMet[i]\r\n',...
		'#Missing values\r\n',...
		'\t\t\tx1[i] ~ dnorm(mux,taux)\r\n',...
		'\t\t\tx2[i] ~ dnorm(mux,taux)\r\n',...
		'\t}\r\n',...
		'\t#\r\n',...
		'\ttau <- pow(sigma,-2)\r\n',...
		'\tsigma ~ dunif(0,10) # y values are assumed to be standardized\r\n',...
		'\t#\r\n',...
		'\ta0 ~ dnorm(0,0.001) # y values are assumed to be standardized\r\n',...
		'\t#\r\n',...
		'\tfor ( j1 in 1:Nx1Lvl ) { a1[j1] ~ dnorm(0.0,a1tau) }\r\n',...
		'\ta1tau <- 1/pow(a1SD,2)\r\n',...
		'\ta1SD <- abs(a1SDunabs) + .1\r\n',...
		'\ta1SDunabs ~ dt(0,0.001,2)\r\n',...
		'\t#\r\n',...
		'\tfor (j2 in 1:Nx2Lvl) {a2[j2] ~ dnorm( 0.0 , a2tau ) }\r\n',...
		'\ta2tau <- 1 / pow( a2SD , 2 )\r\n',...
		'\ta2SD <- abs( a2SDunabs ) + .1\r\n',...
		'\ta2SDunabs ~ dt( 0 , 0.001 , 2 )\r\n',...
		'\t#\r\n',...
		'\tfor ( jS in 1:NSLvl ) { aS[jS] ~ dnorm( 0.0 , aStau ) }\r\n',...
		'\taStau <- 1/pow(aSSD,2)\r\n',...
		'\taSSD <- abs(aSSDunabs)+.1\r\n',...
		'\taSSDunabs ~ dt(0,0.001,2)\r\n',...
		'\tbMet ~ dnorm(0.0,btau)\r\n',...
		'\tbtau <- 1/pow(bSD,2)\r\n',...
		'\tbSD <- abs(bSDunabs)+.1\r\n',...
		'\tbSDunabs ~ dt(0,0.001,2)\r\n',...
		'\t#Vague priors on missing predictors,\r\n',...
		'\t#assuming predictor variances are equal\r\n',...
		'\ttaux ~ dgamma(0.001,0.001)\r\n',...
		'\tmux ~ dnorm(0,1.0E-12)\r\n',...
		'}\r\n',...
		];
% 			'\t\tb[j] ~ dnorm(0,lambda[j])\r\n',...
% 		'\tlambda[j] ~ dchisqr(1)\r\n',...
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

nroi = numel(data);
param = struct([]);
	col = pa_statcolor(100,[],[],[],'def',8);

for roiIdx = 1:nroi
% for roiIdx = 1
	
	
	
	y		= data(roiIdx).FDG(:);
	x1		= data(roiIdx).group(:); % group
	x2		= data(roiIdx).stim(:); % stimulus
	S		=  repmat(data(roiIdx).subject(:),5,1); % subject
	xMet	= repmat(data(roiIdx).phoneme(:),5,1); % phoneme score
	xMet	= pa_logit(xMet/100); % convert to -inf to + inf scale
	x1names	= {'Pre-implant','Post-implant','Normal-hearing'};
	x2names	= {'Rest','Video','Audio-Video'};
	Snames	= {'S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','S11','S12','S13','S14','S15','S16'};
	Ntotal	= length(y);
	Nx1Lvl	= length(unique(x1));
	Nx2Lvl	= length(unique(x2));
	NSLvl	= length(unique(S));
	
	[z,yMorig,ySDorig] = pa_zscore(y');
	
	
		figure(666)
		
	clf
	subplot(221)
	a0			= nanmean(y);
	a1			= accumarray(x1,y,[],@nanmean)-a0;
	a2			= accumarray(x2,y,[],@nanmean)-a0;
	aS			= accumarray(S,y,[],@nanmean)-a0;
	[A1,A2]		= meshgrid(a1,a2);
	linpred		= A1'+A2'+a0;
	colormap(col);
	imagesc((linpred)')
	colorbar
% 	caxis([-3 3])
	axis square
	set(gca,'YDir','reverse','XTick',1:3,'XTickLabel',x1names,'YTick',1:4,'YTickLabel',x2names)
	title('Likelihood');
	
	subplot(222)
	plot(xMet,y,'k.');
	axis square
	box off;
	set(gca,'TickDir','out');
	b = regstats(y,xMet,'linear','beta');
	pa_regline(b.beta,'k-');
	xlabel('Phoneme score');
	ylabel('FDG');
	
	%% Data
	dataStruct.y		= z';
	dataStruct.x1		= x1;
	dataStruct.x2		= x2;
	dataStruct.xMet		= xMet;
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
	
	nChains		= 5;
	
	initsStruct = struct([]);
	for ii = 1:nChains
		initsStruct(ii).a0		= a0;
		initsStruct(ii).a1		= a1;
		initsStruct(ii).a2		= a2;
		initsStruct(ii).aS		= aS;
		initsStruct(ii).bMet	= b.beta(2);
		initsStruct(ii).sigma	= nanstd(dataStruct.y)/2; % lazy
		initsStruct(ii).a1SDunabs	= nanstd(a1);
		initsStruct(ii).a2SDunabs	= nanstd(a2);
		initsStruct(ii).bSDunabs	= nanstd(xMet);
		initsStruct(ii).aSSDunabs	= nanstd(aS);
	end
	
	%% RUN THE CHAINS
	parameters		= {'a0','a1','a2','aS','bMet','sigma','a1SD','a2SD','aSSD','bSD'};	% The parameter(s) to be monitored.
	burnInSteps		= 2000;			% Number of steps to 'burn-in' the samplers.
	numSavedSteps	= 5000;		% Total number of steps in chains to save.
	thinSteps		= 1;			% Number of steps to 'thin' (1=keep every step).
	nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
	doparallel		= 0; % do not use parallelization
	
	fprintf( 'Running JAGS...\n' );
	% [samples, stats, structArray] = matjags( ...
	samples = matjags(...
		dataStruct,...                     % Observed data
		fullfile(pwd, model), ...			% File that contains model definition
		initsStruct,...                    % Initial values for latent variables
		'doparallel',doparallel, ...      % Parallelization flag
		'nchains',nChains,...              % Number of MCMC chains
		'nburnin',burnInSteps,...          % Number of burnin steps
		'nsamples',nIter,...				% Number of samples to extract
		'thin',thinSteps,...              % Thinning parameter
		'dic',1,...                       % Do the DIC?
		'monitorparams',parameters, ...    % List of latent variables to monitor
		'savejagsoutput',1,...          % Save command line output produced by JAGS?
		'verbosity',1,...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
		'cleanup',0);                    % clean up of temporary files?
	
	%% EXAMINE THE RESULTS
	% Extract and plot the SDs:
	
	sigmaSample		= samples.sigma(:);
	a1SDSample		= samples.a1SD(:);
	a2SDSample		= samples.a2SD(:);
	aSSDSample		= samples.aSSD(:);
	
	% 	figure(1);
	% 	subplot(221)
	% 	plotPost(sigmaSample,'xlab','sigma','main','Cell SD','showMode',true);
	% 	subplot(222)
	% 	plotPost(a1SDSample,'xlab','a1SD','main','a1 SD','showMode',true);
	% 	subplot(223)
	% 	plotPost(a2SDSample,'xlab','a2SD','main','a2 SD','showMode',true)
	% 	subplot(224)
	% 	plotPost(aSSDSample,'xlab','aSSD','main','aS SD','showMode',true)
	
	% Extract a values:
	a0Sample	= samples.a0(:);
	chainLength = length(samples.a0);
	a1Sample	= reshape(samples.a1,nChains*chainLength,Nx1Lvl);
	a2Sample	= reshape(samples.a2,nChains*chainLength,Nx2Lvl);
	aSSample	= reshape(samples.aS,nChains*chainLength,NSLvl);
	
	
	% Convert the a values to zero-centered b values.
	% m12Sample is predicted cell means at every step in MCMC chain:
	nSamples	= nIter*nChains;
	m12Sample	= NaN(nSamples,Nx1Lvl,Nx2Lvl,NSLvl);
	for stepIdx = 1:nSamples
		for a1idx = 1:Nx1Lvl
			for a2idx = 1:Nx2Lvl
				for aSidx = 1:NSLvl
					m12Sample(stepIdx,a1idx,a2idx,aSidx) = a0Sample(stepIdx)+a1Sample(stepIdx,a1idx)+a2Sample(stepIdx,a2idx)+aSSample(stepIdx,aSidx);
				end
			end
		end
	end
	
	% b0Sample is mean of the cell means at every step in chain:
	b0Sample = mean(reshape(m12Sample,nSamples,Nx1Lvl*Nx2Lvl*NSLvl),2);
	% b1Sample is deflections of factor 1 marginal means from b0Sample:
	b1Sample = squeeze(mean(mean(m12Sample,4),3))-repmat(b0Sample,1,Nx1Lvl);
	% b2Sample is deflections of factor 2 marginal means from b0Sample:
	b2Sample = squeeze(mean(mean(m12Sample,4),2))-repmat(b0Sample,1,Nx2Lvl);
	% bSSample is deflections of factor S marginal means from b0Sample:
	bSSample = squeeze(mean(mean(m12Sample,3),2))-repmat(b0Sample,1,NSLvl);
	% linpredSample is linear combination of the marginal effects:
	linpredSample	= NaN(nSamples,Nx1Lvl,Nx2Lvl,NSLvl);
	for stepIdx = 1:nSamples
		for a1idx = 1:Nx1Lvl
			for a2idx = 1:Nx2Lvl
				for aSidx = 1:NSLvl
					linpredSample(stepIdx,a1idx,a2idx,aSidx) = b0Sample(stepIdx)+b1Sample(stepIdx,a1idx)+b2Sample(stepIdx,a2idx)+bSSample(stepIdx,aSidx);
				end
			end
		end
	end
	
	
	%%
	% Convert from standardized b values to original scale b values:
	b0Sample	= b0Sample*ySDorig + yMorig;
	b1Sample	= b1Sample*ySDorig;
	b2Sample	= b2Sample*ySDorig;
	bSSample	= bSSample*ySDorig;
	
		% Plot b values:
		figure(2)
		clf
		histinfo = plotPost(b0Sample,'xlab','\beta_0','main','Baseline');
		MAP0 = histinfo.mean;
		
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
	%
	% 	figure(5)
	% 	% keyboard
	% 	bMet = samples.bMet;
	% 	histinfo = plotPost(bMet(:),'xlab','\beta_{Phoneme}','main',['Phoneme']);
	%
	% 	% keyboard
	% 	figure(6)
	% 	plotPost(bSSample(:))
	%%

	param(roiIdx).MAPg = MAPg;
	param(roiIdx).MAPs = MAPs;

	[MAPg,MAPs] = meshgrid(MAPg,MAPs);
	MAP = MAPg+MAPs+MAP0;
	param(roiIdx).MAP = MAPg+MAPs;

	figure(666)
	subplot(224)
	h	= scatter(b1Sample(:),b2Sample(:),15,'filled');

title(MAP0);
	axis square
	subplot(223)
	colormap(col)
	imagesc(MAP)
	axis square
	colorbar
	
	set(gca,'YDir','reverse','XTick',1:3,'XTickLabel',x1names,'YTick',1:3,'YTickLabel',x2names)
	title('Likelihood');
	
% 	figure(2)
	drawnow
% 	pause(.5)
end

%%
% keyboard

%% Brain
roifiles = [data.roi];
p		= 'E:\Backup\Nifti\';
fname	= 'gswro_s5834795-d20120323-mPET.img';
nii		= load_nii([p fname],[],[],1);
img		= nii.img;

indx	= 1:5:46;
nindx	= numel(indx);
% 	%% he brain contour
img = roicolourise(p,fname,roifiles,ones(length(roifiles),1),zeros(size(img)));
IMG = [];
for zIndx = 1:nindx
	tmp	= squeeze(img(:,:,indx(zIndx)));
	IMG	= [IMG;tmp];
end
braincontour = IMG;

% keyboard

%%
img = repmat(0,size(img));
mu = struct([]);
for jj = 1:9
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).MAP(jj);
	end
	muimg1	= roicolourise2(p,fname,[data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp];
	end
	mu(jj).img = muIMG1;
end

%%
IMG = [mu(1).img mu(2).img mu(4).img mu(5).img mu(6).img  mu(7).img mu(8).img  mu(9).img]-repmat(mu(7).img,1,8);

figure(900)
colormap(col)

imagesc(IMG')
hold on
contour(repmat(braincontour,1,8)',1,'k')

axis equal
% 	caxis([-80 80]);
% 	caxis([-1 1])
% caxis([90 100])
caxis([-8 8])
colorbar
set(gca,'YDir','normal');
axis off
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

