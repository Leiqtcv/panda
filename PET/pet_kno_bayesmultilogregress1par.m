
function pet_kno_bayesmultilogregress(checkConvergence)

% See also kno_pet_meanroidata

% MILTILINREGRESSHYPERJAGS
%
% Multiple logistic regression
%
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij
% for 2 independent variables
%
% See also kno_pet_meanroidata

% warning off;
pa_datadir;
if true
% if false
	
	%% THE MODEL.
	% 		str = ['model {\r\n',...
	% 			'\tfor( i in 1 : nData ) {\r\n',...
	% 			'\t\ty[i] ~ dbin( mu[i], n[i] )\r\n',...
	% 			'\t\tmu[i] <- 1/(1+exp(-( b0 + inprod( b[] , x[i,] ))))\r\n',...
	% 			'\t}\r\n',...
	% 			'\tb0 ~ dnorm( 0 , 1.0E-6 )\r\n',...
	% 			'\tfor ( j in 1 : nPredictors ) {\r\n',...
	% 			'\t\tb[j] ~ dnorm( 0 , 1.0E0)\r\n',...
	% 			'\t\tbprior[j] ~ dnorm( 0 , 1.0E0) # not for updating\r\n',...
	% 			'\t}\r\n',...
	% 			'}\r\n',...
	% 			];
	
	str = ['model {\r\n',...
		'\tfor( i in 1 : nData ) {\r\n',...
		'\t\ty[i] ~ dbin( mu[i], n[i] )\r\n',...
		'\t\tmu[i] <- 1/(1+exp(-( b0 + b*x[i] )))\r\n',...
		'\t}\r\n',...
		'\t#b0 ~ dt(0,1,2.5)\r\n',...
		'\tb0 ~ dnorm(0,lambda0)\r\n',...
		'\tlambda0 ~ dchisqr(1)\r\n',...
		'\t#lambda0 <-0.1\r\n',...
		'\tfor ( j in 1 : nPredictors ) {\r\n',...
		'\t\t#b[j] ~ dt(0,1,2.5)\r\n',...
		'\t\tb[j] ~ dnorm(0,lambda[j])\r\n',...
		'\tlambda[j] ~ dchisqr(1)\r\n',...
		'\t#lambda[j] <- 0.1\r\n',...
		'\t\t#bprior[j] ~ dt(0,1,2.5) # not for updating\r\n',...
		'\t\tbprior[j] ~ dnorm(0,lambdaprior[j]) # not for updating\r\n',...
		'\tlambdaprior[j] ~ dchisqr(1)\r\n',...
		'\t#lambdaprior[j] <-0.1\r\n',...
		'\t}\r\n',...
		'}\r\n',...
		];
	
	% 	Cauchy: t-dist t(0,1)
	% Write the modelString to a file, using Matlab commands:
	fid			= fopen('model.txt','w');
	fprintf(fid,str);
	fclose(fid);
	
	%%
	eps =.01;
	binsc = -3+eps/2:eps:3-eps/2;
	binse = -3:eps:3;

	%% THE DATA.
	dataSource = 'pet';
	if nargin<1
		checkConvergence = false;
	end
	
	cd('E:\DATA\KNO\PET\marsbar-aal\');
	d			= dir('MNI_*.mat');
	roifiles	=  {d.name};
	nfiles		= numel(roifiles);
	data		= struct([]);
	for roiIdx	= 1:nfiles
		str		= [num2str(roiIdx) roifiles{roiIdx}];
		disp(str)
	end
	pa_datadir;
	% Load
	if strcmpi(dataSource,'pet')
		
		fname = 'C:\MATLAB\PandA\DoingBayesianDataAnalysis\petpredata.mat';
		if exist(fname,'file')
			load(fname)
		else
			load('E:\DATA\petpredata')
		end
	end
	nroi		= numel(roifiles);
	nPredictors = 1;
	BF = NaN(nroi,nPredictors+1,2);
	MU = NaN(nroi,nPredictors+1);
	
	for roiIdx = 1:nroi
		area = roiIdx;
		data(area)
		x		= [data(area).FDGrest];
		y		= data(area).Phoneme;
		
		xprior	= x(12:end,:);
		sel		= isnan(xprior(:,1));
		xprior	= xprior(~sel,:);
		
		x		= x(1:11,:);
		y		= y(1:11);
		
		sel		= isnan(x(:,1)) ;
		x		= x(~sel,:);
		y		= round((y(~sel)/100*3*12));
		N		= repmat(3*12,size(y));
		
		[nData,nPredictors]	= size(x)
		predictorNames		= {'Rest','Video'};
		predictedName		= 'Phoneme Score';
		
% 		for ii	= 1:nPredictors
% 			
% 			coef	= glmfit(x,[y N],'binomial','link','logit');
% 			xi		= linspace(95,120,100)';
% 			indx	= [1 2] ~= ii;
% 			yfit	= glmval(coef, [xi repmat(mean(x(:,indx)),size(xi))],'logit','size',3*12);
% 		end
		
		% Re-center data at mean, to reduce autocorrelation in MCMC sampling.
		% Standardize (divide by SD) to make initialization easier.
		% 				[~,Mx,SDx]				= zscore(xprior);
		% zx = bsxfun(@minus,x,Mx);
		% zx = bsxfun(@rdivide,zx,SDx);
		
		[zx,Mx,SDx]				= zscore(x);
		zy						= y; % y is not standardized; must be 0,1
		dataStruct.x			= zx;
		dataStruct.y			= zy; % BUGS does not treat 1-column mat as vector
		dataStruct.n			= N;
		dataStruct.nPredictors	= nPredictors;
		dataStruct.nData		= nData;
		
		%% INTIALIZE THE CHAINS.
		% 	b				= glmfit(x,[y N],'binomial','link','logit');
		b				= glmfit(zx,[zy N],'binomial','link','logit');
		b0Init			= b(1);
		bInit			= b(2);
		
		nChains			= 3;                   % Number of chains to run.
		initsStruct		= struct([]);
		for ii = 1:nChains
			initsStruct(ii).b0 = b0Init;
			initsStruct(ii).b = bInit;
		end
		
		%% RUN THE CHAINS
		parameters		= {'b0','b','bprior'};		% The parameter(s) to be monitored.
		% adaptSteps		= 1000;			% Number of steps to 'tune' the samplers.
		burnInSteps		= 1e3;			% Number of steps to 'burn-in' the samplers.
		numSavedSteps	= 1e5;		% Total number of steps in chains to save.
		thinSteps		= 1;			% Number of steps to 'thin' (1=keep every step).
		nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
		doparallel		= 0; % do not use parallelization
		
		fprintf( 'Running JAGS...\n' );
		% [samples, stats, structArray] = matjags( ...
		samples = matjags( ...
			dataStruct, ...                     % Observed data
			fullfile(pwd, 'model.txt'), ...    % File that contains model definition
			initsStruct, ...                          % Initial values for latent variables
			'doparallel' , doparallel, ...      % Parallelization flag
			'nchains', nChains,...              % Number of MCMC chains
			'nburnin', burnInSteps,...              % Number of burnin steps
			'nsamples', nIter, ...           % Number of samples to extract
			'thin', thinSteps, ...                      % Thinning parameter
			'monitorparams', parameters, ...     % List of latent variables to monitor
			'savejagsoutput' , 1 , ...          % Save command line output produced by JAGS?
			'verbosity' , 1 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
			'cleanup' , 0 );                    % clean up of temporary files?
		
		%% EXAMINE THE RESULTS
		%
		% checkConvergence = F
		% if ( checkConvergence ) {
		%   show( summary( codaSamples ) )
		%   openGraph()
		%   plot( codaSamples , ask=F )
		%   openGraph()
		%   autocorr.plot( codaSamples , ask=F )
		% }
		%
		
		%% Extract chain values:
		zb0Sample	= samples.b0(:);
		zbSample	= reshape(samples.b,nChains*nIter,nPredictors);
		zbpriorSample	= reshape(samples.bprior,nChains*nIter,nPredictors);
		
		% Convert to original scale:
		a			= bsxfun(@times,zbSample,Mx./SDx);
		b0Sample	= zb0Sample-sum(a,2);
		bSample		= bsxfun(@rdivide,zbSample,SDx);
		bpriorSample	= bsxfun(@rdivide,zbpriorSample,SDx);
		
		
		% Display the posterior :
		
		crit = 0;
		figure(1);
		clf
		subplot(141)
		plotPost(b0Sample,'xlab','\beta_0 Value','main',['logit(p(' predictedName '=1)) when predictors=0']);
		for bIdx = 1:nPredictors
			tmp = bpriorSample(:,bIdx);
		    tmp = tmp(tmp>binse(1)&tmp<binse(end));
			[f2,x2]		= ksdensity(t,'kernel','normal','support',[binse(1) binse(end)]); % prior


			[~, indk2] = min(abs(x2-crit));
			tmp = bSample(:,bIdx);
		    tmp = tmp(tmp>binse(1)&tmp<binse(end));
			[fi,xi]		= ksdensity(tmp,'kernel','normal','support',[binse(1) binse(end)]); %posterior
			[~, indk] = min(abs(xi-crit));
			v1			= fi(indk); % posterior null prob
			v2			= f2(indk2); % prior null prob
			bf			= [v1/v2 log(v1)-log(v2)]; % Savage-Dickey Bayes Factor,  >1 evidence for null
			BF(roiIdx,bIdx,:) = bf;
			[~,MAPindx] = max(fi);
			MU(roiIdx,bIdx) = xi(MAPindx);
			subplot(1,4,bIdx+1)
			% 			plotPost(bSample(:,bIdx),'xlab',['\beta_' num2str(bIdx) ' Value'],'compVal',0,'main',predictorNames{bIdx},'showCurve',true);
			hold on
			plot(x2,f2,'b:');
			plot(xi,fi,'k-');
			xlim([-3 3]);
			title(MU(roiIdx,bIdx))
			
			% 			ylim([0 1.1*max(f2)]);
			str = ['BF = ' num2str(round(max([bf(1) 1/bf(1)]))) ', ' num2str(1/bf(1))];
			disp(str)
		end
		
		[f2,x2]		= ksdensity(bpriorSample(:)); % prior
		[~, indk2] = min(abs(x2-crit));
		[fi,xi]		= ksdensity(bSample(:)); %posterior
		[~, indk] = min(abs(xi-crit));
		
		subplot(144)
		hold on
		plot(x2,f2,'b:');
		plot(xi,fi,'k-');
		xlim([-3 3]);
		axis square;
		
		v1			= fi(indk); % posterior null prob
		v2			= f2(indk2); % prior null prob
		bf			= [v1/v2 log(v1)-log(v2)]; % Savage-Dickey Bayes Factor,  >1 evidence for null
		BF(roiIdx,3,:) = bf;
		
		title(-bf(2))
	end
	% 		keyboard
	
	%%
	pa_datadir
	save('petbf1par','BF','roifiles','MU');
else
	%% Initial stuff
	close all
	pa_datadir
	
	load('petbf1par')
	figure(666)
	hist(MU)
	
	% 	return
	bf		= squeeze(BF(:,:,1));
	p		= 'E:\Backup\Nifti\';
	fname	= 'gswro_s5834795-d20120323-mPET.img';
	
	nii		= load_nii([p fname],[],[],1);
	img		= nii.img;
	
	indx	= 1:5:46;
	nindx	= numel(indx);
	
	%% he brain contour
	img = roicolourise(p,fname,roifiles,ones(size(MU(:,1))),zeros(size(img))); %#ok<NODEF>
	IMG = [];
	for zIndx = 1:nindx
		tmp	= squeeze(img(:,:,indx(zIndx)));
		IMG	= [IMG;tmp];
	end
	braincontour = IMG;
	
	%%
	img		= repmat(6,size(img));
	img1	= roicolourise(p,fname,roifiles,bf(:,1),img);
	IMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(img1(:,:,indx(zIndx)));
		IMG1	= [IMG1;tmp];
	end
	
	
	%% Graphics
	col = pa_statcolor(100,[],[],[],'def',8);
	figure(4)
	colormap(col)
	% 	K = wiener2(img1(:,:,30)',[3 3]);
	% 	K = img1(:,:,30)';
	
	imagesc([IMG1]')
	hold on
	contour([braincontour braincontour]',1,'k')
	h = colorbar;
	set(get(h,'YLabel'),'String','Bayes Factor')
	set(h,'YTick',1:1:11,'YTickLabel',{'Extreme','Very strong','Strong','Moderate','Anecdotal','No','Anecdotal','Moderate','Strong','Very strong','Extreme'})
	
	caxis([1 11])
	axis equal
	set(gca,'YDir','normal');
	axis off
	drawnow
	
	%%
	% 	keyboard
	%%
	img = repmat(0,size(img));
	muimg1	= roicolourise2(p,fname,roifiles,MU(:,1),img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp];
	end
	

	
	muIMG1(IMG1<8) = 0;
	
	figure(900)
	colormap(col)
	
	imagesc( muIMG1')
	hold on
	contour(braincontour',1,'k')
	
	axis equal
	% 	caxis([-80 80]);
	caxis([-1 1])
	% caxis auto
	colorbar
	set(gca,'YDir','normal');
	axis off
	%% Which ROIs
% 	keyboard
	%%
	clc
	bf		= 1./squeeze(BF(:,:,1));
	sel = bf>100;
	rroi = roifiles(sel(:,1));
	rmap = MU(sel(:,1),1);
	pa_datadir;
	

	xlswrite('table3rest',rroi',2,'A');
	xlswrite('table3rest',rmap,2,'B');

	%%
end

figure(900)
pa_datadir;
print('-depsc','-painter',[mfilename 'bayesv']);

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

