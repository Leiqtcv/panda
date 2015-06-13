function pet_bayes_2014_02_09
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

% Check
% vermis
% left-right plot
% random check
% convergence
% SIR score

close all
model = 'petancova.txt';

%% THE MODEL.
pa_datadir;
loadflag		= true;
% loadflag		= false;
loadbrainflag	= true;
% loadbrainflag	= false;


%% Labels
x1names	= {'Deaf','Normal-hearing'};
x2names	= {'Pre-operative','Implant'}; % NaN
x3names	= {'Rest','Video'};
x4names	= {'No audio','audio'};
x5names	= {'Left','Right'};

if ~loadflag
	%% THE DATA.
	% Load the data:
	pa_datadir;
	load('petancova')
	[roi,uroi,nroi,s] = getroi(data);
	paramb0		= NaN(nroi,1); % bias
	paramb1		= NaN(nroi,2); % deaf vs nh
	paramb2		= NaN(nroi,2); % deaf vs implant
	paramb3		= NaN(nroi,2); % no vs video
	paramb4		= NaN(nroi,2); % no vs audio
	paramb5		= NaN(nroi,2); % laterality
	parammet1	= NaN(nroi,2); % gain phoneme
	parammet0	= NaN(nroi,2); % bias phoneme
	BF1			= NaN(nroi,2); D1 = BF1;
	BF2			= NaN(nroi,2); D2 = BF2;
	BF3			= NaN(nroi,2); D3 = BF3;
	BF4			= NaN(nroi,2); D4 = BF4;
	BF5			= NaN(nroi,2); D5 = BF5;
	BFMet1			= NaN(nroi,2); DMet1 = BFMet1;
	BFMet0			= NaN(nroi,2); DMet0 = BFMet0;
	
	dataStruct	= struct('y',[],'x1',[],'x2',[],'x3',[],'x4',[],'x5',[]);
	samp		= struct([]);
	for roiIdx = 1:nroi
		%% load regional data
		selroi		= strcmp(uroi(roiIdx),roi);
		disp([num2str(roiIdx) data(selroi).roi])
		y			= [data(selroi).FDG];


		y(1:4,1:2) = NaN;
		if sum(selroi)>1
			y(1:4,6:7) = NaN;
		end
		y	= y(:); % pre for nh is nonsense
		
		% x1 = Deaf vs Normal-hearing
		x1			= [data(selroi).group];	x1(1:4,1:2) = NaN;
		if sum(selroi)>1
			x(1:4,6:7) = NaN;
		end
		x1	= x1(:);
		sel_deaf		= ismember(x1,[1 2]); sel_implant	= x1==2; sel_hearing	= x1==3;
		x1(sel_deaf)	= 1; x1(sel_hearing)	= 2; x1 = round(x1);
		
		% x2 = No implant vs Implant
		x2 = x1; x2(~sel_implant) = 1; x2(sel_implant) = 2; x2(sel_hearing) = NaN;
		
		% x3 = Video vs Rest
		x3			= [data(selroi).stim];	x3(1:4,1:2) = NaN;
		if sum(selroi)>1
			x3(1:4,6:7) = NaN;
		end
		x3	= x3(:);
		sel_n = isnan(x3);	sel_r = x3==1;	sel_v = ismember(x3,[2 3]);	sel_a = x3==3;
		x3(sel_r) = 1;	x3(sel_v) = 2;
		
		% x4 = Audio vs not audio
		x4 = x3; x4(~sel_a) = 1; x4(sel_a) = 2;	x4(sel_n) = NaN;
		
		% x5 = Laterality
		x5			= ones(size(y));
		if sum(selroi)>1
			ny	= numel(y);	x5(ny/2+1:end) = 2;
		else
			x5 = pa_rndval(1,2,size(x5));
		end
	
		% Metric phoneme
		xMet		=	[data(selroi).phoneme];
		xMet(1:5,:)	= NaN;
		xMet		= repmat(xMet,5,1);
		xMet		= xMet(:);
		
		% NaN-selection
		sel		= isnan(y);
		y		= y(~sel);
		x1		= x1(~sel);
		x2		= x2(~sel);
		x3		= x3(~sel);
		x4		= x4(~sel);
		x5		= x5(~sel);
		xMet	= xMet(~sel);
		
		%% Selection
		xMet	= pa_logit(xMet/100); % convert to -inf to + inf scale
		m		= accumarray(x1,y,[],@nanmedian);
		sel		= y<mean(m)-30; % remove unlikely FDG values, i.e. because of poor scan view
		y(sel)	= NaN;
		y		= y(~sel); x1	= x1(~sel);	x2 = x2(~sel); x3 = x3(~sel); x4 = x4(~sel); x5	= x5(~sel);	xMet	= xMet(~sel);
		
		%% interactions
		%
		ix			= [x2 x3];
		[~,~,ib]	= unique(ix,'rows');
		
		sel			= isnan(ix(:,1)) | isnan(ix(:,2));
		ib(sel)		= NaN;
		x6			= ib;

		%%
		ix			= [x2 x4];
		[~,~,ib]	= unique(ix,'rows');
		
		sel			= isnan(ix(:,1)) | isnan(ix(:,2));
		ib(sel)		= NaN;
		x7			= ib;
% 		x7(x7==1)	= NaN;
% 		x7 = x7-1;
		
% keyboard
		%%
% 		keyboard
		%%
		Nnom = 7;
		xmet = 3;
		Nmet = numel(xmet);

% 		Nlvl = struct([]);
% 		for ii = 1:Nnom
% 		Nlvl.(str) = 
		Ntotal	= length(y);
		Nx1Lvl	= length(unique(x1));
		Nx2Lvl	= length(unique(x2(~isnan(x2))));
		Nx3Lvl	= length(unique(x3));
		Nx4Lvl	= length(unique(x4));
		Nx5Lvl	= length(unique(x5));
		Nx6Lvl	= length(unique(x6(~isnan(x6))));
		Nx7Lvl	= length(unique(x7(~isnan(x7))));
		
		% Normalize, for JAGS MCMC sampling, e.g. to use cauchy(0,1) prior
		[z,yMorig,ySDorig]	= pa_zscore(y');
		[zMet,metM,metSD]	= pa_zscore(xMet');

		%% Model
		if true
			pa_bayes_modeldata(model,Nnom,xmet)
		end

		%% Data
		dataStruct.y		= z';
		dataStruct.x1		= x1;
		dataStruct.x2		= x2;
		dataStruct.x3		= x3;
		dataStruct.x4		= x4;
		dataStruct.x5		= x5;
		dataStruct.x6		= x6;
		dataStruct.x7		= x7;
		dataStruct.xMet		= zMet;
		dataStruct.Ntotal	= Ntotal;
		dataStruct.Nx1Lvl	= Nx1Lvl;
		dataStruct.Nx2Lvl	= Nx2Lvl;
		dataStruct.Nx3Lvl	= Nx3Lvl;
		dataStruct.Nx4Lvl	= Nx4Lvl;
		dataStruct.Nx5Lvl	= Nx5Lvl;
		dataStruct.Nx6Lvl	= Nx6Lvl;
		dataStruct.Nx7Lvl	= Nx7Lvl;
		
% 		keyboard
		%% INTIALIZE THE CHAINS.
		
		sel = isnan(dataStruct.x1) | isnan(dataStruct.y);
		a1		= accumarray(dataStruct.x1(~sel),dataStruct.y(~sel),[],@nanmean);
		sel = isnan(dataStruct.x2) | isnan(dataStruct.y);
		a2		= accumarray(dataStruct.x2(~sel),dataStruct.y(~sel),[],@nanmean);
		sel = isnan(dataStruct.x3) | isnan(dataStruct.y);
		a3		= accumarray(dataStruct.x3(~sel),dataStruct.y(~sel),[],@nanmean);
		sel = isnan(dataStruct.x4) | isnan(dataStruct.y);
		a4		= accumarray(dataStruct.x4(~sel),dataStruct.y(~sel),[],@nanmean);
		sel = isnan(dataStruct.x5) | isnan(dataStruct.y);
		a5		= accumarray(dataStruct.x5(~sel),dataStruct.y(~sel),[],@nanmean);
		sel = isnan(dataStruct.x6) | isnan(dataStruct.y);
		a6		= accumarray(dataStruct.x6(~sel),dataStruct.y(~sel),[],@nanmean);
		sel = isnan(dataStruct.x7) | isnan(dataStruct.y);
		a7		= accumarray(dataStruct.x7(~sel),dataStruct.y(~sel),[],@nanmean);
		
		nChains		= 4;
		initsStruct = struct([]);
		for ii = 1:nChains
			initsStruct(ii).a0			= 0;
			initsStruct(ii).a1			= a1;
			initsStruct(ii).a2			= a2;
			initsStruct(ii).a3			= a3;
			initsStruct(ii).a4			= a4;
			initsStruct(ii).a5			= a5;
			initsStruct(ii).a6			= a6;
			initsStruct(ii).a7			= a7;
			initsStruct(ii).aMet0		= 0;
			initsStruct(ii).aMet1		= zeros(Nx2Lvl,1);
			initsStruct(ii).a0prior		= 0;
			initsStruct(ii).a1prior		= a1;
			initsStruct(ii).a2prior		= a2;
			initsStruct(ii).a3prior		= a3;
			initsStruct(ii).a4prior		= a4;
			initsStruct(ii).a5prior		= a5;
			initsStruct(ii).a6prior		= a6;
			initsStruct(ii).a7prior		= a7;
			initsStruct(ii).aMet1prior	= zeros(Nx2Lvl,1);
			initsStruct(ii).aMet0prior	= 0;
			initsStruct(ii).sigma		= nanstd(dataStruct.y)/2; % lazy
		end
		
		%% RUN THE CHAINS
		parameters		= {'b0','b1','b2','b3','b4','b5','b6','b7','bMet1','bMet0'...
			'b0prior','b1prior','b2prior','b3prior','b4prior','b5prior','b6prior','b7prior','bMet1prior','bMet0prior'...
			'mu',...
			}; % The parameter(s) to be monitored.
		burnInSteps		= 500;		% Number of steps to 'burn-in' the samplers.
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
		[samples] = pa_matjags(...
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
		
		% 		%% Check Rhat for convergence
		% 		names = fieldnames(stats.Rhat);
		% 		names = names(1:9);
		% 		bgrstat = [];
		% 		for nameIdx = 1:9
		% 			selrhat = any(any(squeeze(any(abs(stats.Rhat.(names{nameIdx})-1)>0.1))));
		% 			bgrstat = [bgrstat selrhat];
		% 		end
		% 		if any(bgrstat)
		% 			error('Rhat');
		% 		end
		%
		% 		%% Check Auto-correlation for thinning
		% 		acflag = false;
		% 		if acflag
		% 			figure(100)
		% 			names = fieldnames(samples);
		% 			names = names(1:9);
		% 			for nameIdx = 1:9
		% 				a = [samples.(names{nameIdx})];
		% 				ndims(a)
		% 				switch ndims(a)
		% 					case 2
		% 						a = a(1,:);
		% 						[C,lags] = xcorr(a,30,'coeff');
		% 						plot(lags,C,'-');
		% 						xlim([0 30])
		% 						title(C(32))
		% 						drawnow
		% 						if C(32)>0.4
		% 							error('AC')
		% 						end
		% 					case 3
		% 						a = squeeze(a(1,:,:));
		% 						[~,m] = size(a);
		% 						for mIdx = 1:m
		% 							[C,lags] = xcorr(squeeze(a(:,mIdx)),30,'coeff');
		% 							plot(lags,C,'-');
		% 							xlim([0 30])
		% 							title(C(32))
		% 							drawnow
		% 							if C(32)>0.4
		% 								mIdx
		% 								error('AC')
		% 							end
		% 						end
		% 					case 4
		% 						a = squeeze(a(1,:,:,:));
		% 						[~,m,n] = size(a);
		% 						for mIdx = 1:m
		% 							for nIdx = 1:n
		% 								[C,lags] = xcorr(squeeze(a(:,mIdx,nIdx)),30,'coeff');
		% 								plot(lags,C,'-');
		% 								xlim([0 30])
		% 								title(C(32))
		% 								drawnow
		% 								if C(32)>0.4
		% 									[mIdx nIdx]
		% 									error('AC')
		% 								end
		% 							end
		% 						end
		% 					case 5
		% 						a = squeeze(a(1,:,:,:,:));
		% 						[~,m,n,o] = size(a);
		% 						for mIdx = 1:m
		% 							for nIdx = 1:n
		% 								for oIdx = 1:o
		% 									[C,lags] = xcorr(squeeze(a(:,mIdx,nIdx,oIdx)),30,'coeff');
		% 									plot(lags,C,'-');
		% 									xlim([0 30])
		% 									title(C(32))
		% 									if C(32)>0.4
		% 										[mIdx nIdx oIdx]
		% 										error('AC')
		% 									end
		% 									drawnow
		% 								end
		% 							end
		% 						end
		% 				end
		%
		%
		% 			end
		% 		end
		%%
		% 		keyboard
		% 	return
		%% EXAMINE THE RESULTS
		% Extract b values,
		% and convert from standardized b values to original scale b values:
		b0			= samples.b0(:)*ySDorig + yMorig;
		chainLength = length(samples.b0);
		b1			= reshape(samples.b1,nChains*chainLength,Nx1Lvl)*ySDorig;
		b2			= reshape(samples.b2,nChains*chainLength,Nx2Lvl)*ySDorig;
		b3			= reshape(samples.b3,nChains*chainLength,Nx3Lvl)*ySDorig;
		b4			= reshape(samples.b4,nChains*chainLength,Nx4Lvl)*ySDorig;
		b5			= reshape(samples.b5,nChains*chainLength,Nx5Lvl)*ySDorig;
		b6			= reshape(samples.b6,nChains*chainLength,Nx6Lvl)*ySDorig;
		b7			= reshape(samples.b7,nChains*chainLength,Nx7Lvl)*ySDorig;
		bMet0		= reshape(samples.bMet0,nChains*chainLength,1)*ySDorig/metSD;
		bMet1			= reshape(samples.bMet1,nChains*chainLength,Nx2Lvl)*ySDorig/metSD;
		
		mu			= samples.mu*ySDorig + yMorig;
		
		b1prior		= reshape(samples.b1prior,nChains*chainLength,Nx1Lvl)*ySDorig;
		b2prior		= reshape(samples.b2prior,nChains*chainLength,Nx2Lvl)*ySDorig;
		b3prior		= reshape(samples.b3prior,nChains*chainLength,Nx3Lvl)*ySDorig;
		b4prior		= reshape(samples.b4prior,nChains*chainLength,Nx4Lvl)*ySDorig;
		b5prior		= reshape(samples.b5prior,nChains*chainLength,Nx5Lvl)*ySDorig;
		b6prior		= reshape(samples.b6prior,nChains*chainLength,Nx6Lvl)*ySDorig;
		b7prior		= reshape(samples.b7prior,nChains*chainLength,Nx7Lvl)*ySDorig;
		bMet0prior	= reshape(samples.bMet0prior,nChains*chainLength,1)*ySDorig/metSD;
		bMet1prior	= reshape(samples.bMet1prior,nChains*chainLength,Nx2Lvl)*ySDorig/metSD;
		
		%% Save
		% Averages
		paramb0(roiIdx,:)	= nanmean(b0);
		paramb1(roiIdx,:)	= nanmean(b1);
		paramb2(roiIdx,:)	= nanmean(b2);
		paramb3(roiIdx,:)	= nanmean(b3);
		paramb4(roiIdx,:)	= nanmean(b4);
		paramb5(roiIdx,:)	= nanmean(b5);
		paramb6(roiIdx,:)	= nanmean(b6);
		paramb7(roiIdx,:)	= nanmean(b7);
		parammet1(roiIdx,:)	= nanmean(bMet1);
		parammet0(roiIdx,:)	= nanmean(bMet0);
		
		% Samples
		samp(roiIdx).b0		= b0;
		samp(roiIdx).b1		= b1;
		samp(roiIdx).b2		= b2;
		samp(roiIdx).b3		= b3;
		samp(roiIdx).b4		= b4;
		samp(roiIdx).b5		= b5;
		samp(roiIdx).b6		= b6;
		samp(roiIdx).b7		= b7;
		samp(roiIdx).bMet1		= bMet1;
		samp(roiIdx).bMet0		= bMet0;
		samp(roiIdx).mu		= mu;
		samp(roiIdx).x1		= x1;
		samp(roiIdx).x2		= x2;
		samp(roiIdx).x3		= x3;
		samp(roiIdx).x4		= x4;
		samp(roiIdx).x5		= x5;
		samp(roiIdx).x6		= x6;
		samp(roiIdx).x7		= x7;
		samp(roiIdx).xMet		= xMet;
		
		%% Hypothesis testing
		% nominal comparisons
		[db1,bf,comp1,xlbl1,hdi]		= getcomparisons(b1,b1prior,x1names); % Main factor group
		BF1(roiIdx,:)	= bf;
		D1(roiIdx,:)	= mean(db1);
		HDI1(roiIdx,:,:)	= hdi;
		
		[db2,bf,comp2,xlbl2,hdi]		= getcomparisons(b2,b2prior,x2names); % Main factor stimulus
		BF2(roiIdx,:)	= bf;
		D2(roiIdx,:)	= mean(db2);
		HDI2(roiIdx,:,:)	= hdi;
		
		[db3,bf,comp3,xlbl3,hdi]		= getcomparisons(b3,b3prior,x3names); % Main factor: lateralization
		BF3(roiIdx,:)	= bf;
		D3(roiIdx,:)	= mean(db3);
		HDI3(roiIdx,:,:)	= hdi;
		
		[db4,bf,comp4,xlbl4,hdi]		= getcomparisons(b4,b4prior,x4names); % Main factor: lateralization
		BF4(roiIdx,:)	= bf;
		D4(roiIdx,:)	= mean(db4);
		HDI4(roiIdx,:,:)	= hdi;
		
% 		keyboard
		[db5,bf,comp5,xlbl5,hdi]		= getcomparisons(b5,b5prior,x5names); % Main factor: lateralization
		BF5(roiIdx,:)	= bf;
		D5(roiIdx,:)	= mean(db5);
		HDI5(roiIdx,:,:)	= hdi;
		
		x6names = {'1';'2';'3';'4'};
		[db6,bf,comp6,xlbl6,hdi]		= getcomparisons(b6,b6prior,x6names); % Main factor: lateralization
		BF6(roiIdx,:)	= bf;
		D6(roiIdx,:)	= mean(db6);
		HDI6(roiIdx,:,:)	= hdi;

		x7names = {'1';'2';'3'};
		[db7,bf,comp7,xlbl7,hdi]		= getcomparisons(b7,b7prior,x7names); % Main factor: lateralization
		BF7(roiIdx,:)	= bf;
		D7(roiIdx,:)	= mean(db7);
		HDI7(roiIdx,:,:)	= hdi;

		% metric comparison to 0
		[dbMet1,bf,hdi]		= get0comparisons(bMet1,bMet1prior); % Main factor phoneme score
		BFMet1(roiIdx,:)	= bf;
		DMet1(roiIdx,:)	= mean(dbMet1);
		HDIMet1(roiIdx,:,:)	= hdi;
		
		[dbMet0,bf,hdi]		= get0comparisons(bMet0,bMet0prior); % Main factor phoneme score
		BFMet0(roiIdx,:)	= bf;
		DMet0(roiIdx,:)	= mean(dbMet0);
		HDIMet0(roiIdx,:,:)	= hdi;
	end
	% parameters
	param.b0	= paramb0;	param.b1	= paramb1;	param.b2 = paramb2;	param.b3 = paramb3;
	param.b4	= paramb4;	param.b5	= paramb5;	param.b6	= paramb6;	param.b7	= paramb7;
	param.metM1	= parammet1;
	param.metM0	= parammet0;
	% differences
	d.D1		= D1;		d.D2		= D2;		d.D3		= D3;		d.D4		= D4;		d.D5		= D5;
	d.D6		= D6;	d.D7		= D7;
	d.BF1		= BF1;		d.BF2		= BF2;		d.BF3		= BF3;		d.BF4		= BF4;		d.BF5		= BF5;
		d.BF6		= BF6;d.BF7		= BF7;
		d.HDI1		= HDI1;		d.HDI2		= HDI2;		d.HDI3		= HDI3;		d.HDI4	=HDI4;	d.HDI5	=HDI5;
	d.HDI6	=HDI6;d.HDI7	=HDI7;
	d.comp1		= comp1;	d.comp2		= comp2;	d.comp3		= comp3;	d.comp4		= comp4;	d.comp5		= comp5;
	d.comp6		= comp6;d.comp7		= comp7;
	d.xlbl1		= xlbl1;	d.xlbl2		= xlbl2;	d.xlbl3		= xlbl3;	d.xlbl4		= xlbl4;	d.xlbl5		= xlbl5;
		d.xlbl6		= xlbl6;d.xlbl7		= xlbl7;
	
	d.DMet0		= DMet0;		d.DMet1		= DMet1;
	d.BFMet0		= BFMet0;		d.BFMet1		= BFMet1;
	
	pa_datadir;
	save allxxxanalysis d param samp
	
else
	load allxxxanalysis
	load petancova
end

keyboard

% %% Check Auto-correlation for thinning
% acflag = false;
% if acflag
% 	figure(100)
% 	names = fieldnames(samples);
% 	names = names(1:9);
% 	for nameIdx = 1:9
% 		a = [samples.(names{nameIdx})];
% 		ndims(a)
% 		switch ndims(a)
% 			case 2
% 				a = a(1,:);
% 				[C,lags] = xcorr(a,30,'coeff');
% 				plot(lags,C,'-');
% 				xlim([0 30])
% 				title(C(32))
% 				drawnow
% 				if C(32)>0.4
% 					error('AC')
% 				end
% 			case 3
% 				a = squeeze(a(1,:,:));
% 				[~,m] = size(a);
% 				for mIdx = 1:m
% 					[C,lags] = xcorr(squeeze(a(:,mIdx)),30,'coeff');
% 					plot(lags,C,'-');
% 					xlim([0 30])
% 					title(C(32))
% 					drawnow
% 					if C(32)>0.4
% 						mIdx
% 						error('AC')
% 					end
% 				end
% 			case 4
% 				a = squeeze(a(1,:,:,:));
% 				[~,m,n] = size(a);
% 				for mIdx = 1:m
% 					for nIdx = 1:n
% 						[C,lags] = xcorr(squeeze(a(:,mIdx,nIdx)),30,'coeff');
% 						plot(lags,C,'-');
% 						xlim([0 30])
% 						title(C(32))
% 						drawnow
% 						if C(32)>0.4
% 							[mIdx nIdx]
% 							error('AC')
% 						end
% 					end
% 				end
% 			case 5
% 				a = squeeze(a(1,:,:,:,:));
% 				[~,m,n,o] = size(a);
% 				for mIdx = 1:m
% 					for nIdx = 1:n
% 						for oIdx = 1:o
% 							[C,lags] = xcorr(squeeze(a(:,mIdx,nIdx,oIdx)),30,'coeff');
% 							plot(lags,C,'-');
% 							xlim([0 30])
% 							title(C(32))
% 							if C(32)>0.4
% 								[mIdx nIdx oIdx]
% 								error('AC')
% 							end
% 							drawnow
% 						end
% 					end
% 				end
% 		end
%
%
% 	end
% end
%
% keyboard
%% Get default image values
[col,img,indx,nindx,p,fname] = getdefimg;

% Regions of interest
[~,uroi,nroi] = getroi(data);

% Brain
if ~loadbrainflag
	[braincontour,bcright] = getbraincontour(data,p,fname,img,indx,nindx);
else
	load braincontour;
end

% Analysis
% b0flag		= true;
b1flag		= true;
b2flag		= true;
b3flag		= true;
b4flag		= true;

% b0flag		= false;
% b1flag		= false;
% b2flag		= false;
% b3flag		= false;
% b4flag		= false;
% b1b2flag	= false;

crit		= 3;
% keyboard

%%
% roi = 'MNI_Temporal_Sup_L_roi.mat';
% stm = 1;
% figure(100)
% subplot(132)
% plotcred(data,param,samp,[d.BF4],roi,stm,[75 95])
% xlim([75 95])
%
% return
%% Main factor group
close all
clc
% keyboard
%%
if b1flag
	braingraph1(data,d.D1,d.comp1,d.BF1,d.xlbl1,img,bcright,uroi,nroi,crit,indx,nindx,col,100)
end
% return
%% Main factor stimulus
if b2flag
	braingraph1(data,d.D2,d.comp2,d.BF2,d.xlbl2,img,bcright,uroi,nroi,crit,indx,nindx,col,200)
end

%% Main factor laterality
if b3flag
	braingraph1(data,d.D3,d.comp3,d.BF3,d.xlbl3,img,bcright,uroi,nroi,crit,indx,nindx,col,300)
end

%%
if b3flag
	braingraph1(data,d.D4,d.comp4,d.BF4,d.xlbl4,img,bcright,uroi,nroi,crit,indx,nindx,col,400)
end

%%
if b3flag
	braingraph1(data,d.D5,d.comp5,d.BF5,d.xlbl5,img,bcright,uroi,nroi,crit,indx,nindx,col,500)
end

%%
if b3flag
	braingraph1(data,d.D6,d.comp6,d.BF6,d.xlbl6,img,bcright,uroi,nroi,crit,indx,nindx,col,600)
end

%%
if b3flag
	braingraph1(data,d.D7,d.comp7,d.BF7,d.xlbl7,img,bcright,uroi,nroi,crit,indx,nindx,col,700)
end
%% Main factor phoneme score
if b4flag
	braingraph2(data,d.DMet0,1,d.BFMet0,x3names,img,bcright,uroi,nroi,crit,indx,nindx,col,1000)
end

%%
if b3flag
	braingraph1(data,d.DMet1,d.comp3,d.BFMet1,d.xlbl3,img,bcright,uroi,nroi,crit,indx,nindx,col,1100)
end
% return
%%
% write to table

savetable(1./d.BF1,d.D1,d.HDI1,crit,1,uroi,d.xlbl1);
savetable(1./d.BF2,d.D2,d.HDI2,crit,2,uroi,d.xlbl2);
savetable(1./d.BF3,d.D3,d.HDI3,crit,3,uroi,d.xlbl3);
savetable(1./d.BF4,d.D4,d.HDI4,crit,4,uroi,x2names);

savetable(1./d.BF12,d.D12,d.HDI12,crit,5,uroi,d.xlbl12);
savetable(1./d.BF13,d.D13,d.HDI13,crit,6,uroi,d.xlbl13);
savetable(1./d.BF23,d.D23,d.HDI23,crit,7,uroi,d.xlbl23);

savetable(1./d.BF123,d.D123,d.HDI123,crit,8,uroi,d.xlbl123);


return
%% Examples
% plotexample;
% roiIdx = selroi;
% 	plotexample(y,x1,x2,x3,xMet,...
% 			samp(roiIdx).b0,samp(roiIdx).b1,samp(roiIdx).b2,samp(roiIdx).b3,samp(roiIdx).b4,...
% 			paramb0(roiIdx,:),paramb1(roiIdx,:),paramb2(roiIdx,:),paramb3(roiIdx,:),paramb4(roiIdx,:,:),...
% 			[data(selroi).roi],BF1(roiIdx,:));

%%
x2		= data(selroi).stim(:); % stimulus
phi		= repmat(data(selroi).phoneme(:),5,1); % phoneme
sel		= ismember(x1,1:2) & ismember(x2,1:2) & y>30;
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
pho(:,1)	= gain(:,1).*nanmean(pa_logit(phi(sel)/100));
sel		= x2==2;
pho(:,2)	= gain(:,2).*nanmean(pa_logit(phi(sel)/100));
n	= numel(bias);
for ii = 1:n
	b = bias(ii) + nanmean(b1(ii,:)) + b2(ii,:)+pho(ii,:)-offset;
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
pho(1)	= nanmean(gain(1)*pa_logit(phi(sel)/100));
sel		= x2==2;
pho(2)	= nanmean(gain(2)*pa_logit(phi(sel)/100));
plot(1:2,bias+b1+b2+b1b2+pho-offset,'Color','k','LineWIdth',2)
hold on
sel = x2==1;
plot(x2(sel)+randn(sum(sel),1)/10,y(sel),'ko','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
plot(1,mean(y(sel)),'ro','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
sel = x2==2;
plot(x2(sel)+randn(sum(sel),1)/10,y(sel),'ks','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
plot(2,mean(y(sel)),'rs','MarkerSize',5,'MarkerFaceColor','w','LineWIdth',2)
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

function roitextxy(roi,indx,nindx)
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
	for zIndx = 1:nindx
		if any(indx(zIndx)==z1)
			% 			tmp		= squeeze(muimg1(:,:,indx(zIndx)));
			x = mean(x1);
			y = mean(y1);
			fname		=roiname(5:end-8);
			sel			= strfind(fname,'_');
			fname(sel)	= ' ';
			s = fname(end);
			fname		= fname(1:end-2);
			if strcmp(s,'R');
				text(x-(ceil(79/2)+2)+(ceil(79/2)+2)*(zIndx-1),y,fname,'HorizontalAlignment','center');
			end
		end
	end
	% 	for zIndx = 1:length(z1)
	% 		img(x1(zIndx),y1(zIndx),z1(zIndx)) = indx(kk);
	% 	end
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

function [roi,uroi,nroi,s] = getroi(data)
roi = [data.roi]';
a	= roi;
s	= a;
na	= numel(a);
for ii = 1:na
	b		= a{ii};
	b		= b(5:end-8);
	sel		= strfind(b,'_');
	b(sel)	= ' ';
	s{ii}	= b(end); % side
	if strncmpi(b,'Vermis',6)
		a{ii} = b;
		s{ii} = 'L';
	else
		a{ii}	= b(1:end-2);
	end
end
roi		= a;
uroi	= unique(roi);
nroi	= numel(uroi);

function [braincontour,bcright] = getbraincontour(data,p,fname,img,indx,nindx)
roifiles	= [data.roi];
img			= roicolourise(p,fname,roifiles,ones(length(roifiles),1),zeros(size(img)));
IMG			= [];
IMGr = [];
for zIndx = 1:nindx
	tmp		= squeeze(img(:,:,indx(zIndx)));
	IMG		= [IMG;tmp];
	tmp = tmp((ceil(79/2)+2):end,:);
	IMGr	= [IMGr;tmp];
end
braincontour = IMG;
bcright = IMGr;
pa_datadir
save braincontour braincontour bcright

function [col,img,indx,nindx,p,fname] = getdefimg
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

function createmodel(model)
% with cauchy
str = ['model {\r\n',...
	'\tfor ( i in 1:Ntotal ) {\r\n',...
	'\t\ty[i] ~ dnorm( mu[i],tau)\r\n',...
	'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + a3[x3[i]]  + a4[x4[i]]  + a5[x5[i]] +',...
	'a1a3[x1[i],x3[i]] + a2a3[x2[i],x3[i]] + a1a4[x1[i],x4[i]] + a2a4[x2[i],x3[i]] +',...
	'(b4[x2[i]])*xMet[i]\r\n',...
	'\t#Missing values\r\n',...
	'\t\t\tx1[i] ~ dnorm(mux1,taux1)\r\n',...
	'\t\t\tx2[i] ~ dnorm(mux2,taux2)\r\n',...
	'\t\t\tx3[i] ~ dnorm(mux3,taux3)\r\n',...
	'\t\t\tx4[i] ~ dnorm(mux4,taux4)\r\n',...
	'\t\t\tx5[i] ~ dnorm(mux5,taux5)\r\n',...
	'\t\t\txMet[i] ~ dnorm(muxMet,tauxMet)\r\n',...
	'\t}\r\n',...
	'\t#Vague priors on missing predictors,\r\n',...
	'\t#assuming predictor variances are equal\r\n',...
	'\ttaux1 ~ dgamma(0.001,0.001)\r\n',...
	'\tmux1 ~ dnorm(0,1.0E-12)\r\n',...
	'\ttaux2 ~ dgamma(0.001,0.001)\r\n',...
	'\tmux2 ~ dnorm(0,1.0E-12)\r\n',...
	'\ttaux3 ~ dgamma(0.001,0.001)\r\n',...
	'\tmux3 ~ dnorm(0,1.0E-12)\r\n',...
	'\ttaux4 ~ dgamma(0.001,0.001)\r\n',...
	'\tmux4 ~ dnorm(0,1.0E-12)\r\n',...
	'\ttaux5 ~ dgamma(0.001,0.001)\r\n',...
	'\tmux5 ~ dnorm(0,1.0E-12)\r\n',...
	'\ttauxMet ~ dgamma(0.001,0.001)\r\n',...
	'\tmuxMet ~ dnorm(0,1.0E-12)\r\n',...
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
	'\tfor (j3 in 1:Nx3Lvl) {a3[j3] ~ dnorm(0.0,lambda3) }\r\n',...
	'\tlambda3 ~ dchisqr(1)\r\n',...
	'\t#\r\n',...
	'\tfor (j4 in 1:Nx4Lvl) {a4[j4] ~ dnorm(0.0,lambda4) }\r\n',...
	'\tlambda4 ~ dchisqr(1)\r\n',...
	'\t#\r\n',...
	'\tfor (j5 in 1:Nx5Lvl) {a5[j5] ~ dnorm(0.0,lambda5) }\r\n',...
	'\tlambda5 ~ dchisqr(1)\r\n',...
	'\t#\r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\tb4[j2] ~ dnorm(0.0,lambdaMetI)\r\n',...
	'\t} \r\n',...
	'\tlambdaMetI ~ dchisqr(1)\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\ta1a3[j1,j3] ~ dnorm(0.0,lambda13)\r\n',...
	'\t} }\r\n',...
	'\tlambda13 ~ dchisqr(1)\r\n',...
	' \r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\ta2a3[j2,j3] ~ dnorm(0.0,lambda23)\r\n',...
	'\t} }\r\n',...
	'\tlambda23 ~ dchisqr(1)\r\n',...
	' \r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j4 in 1:Nx4Lvl ) {\r\n',...
	'\t\ta2a3[j1,j4] ~ dnorm(0.0,lambda14)\r\n',...
	'\t} }\r\n',...
	'\tlambda14 ~ dchisqr(1)\r\n',...
	' \r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) { for ( j4 in 1:Nx4Lvl ) {\r\n',...
	'\t\ta2a3[j2,j4] ~ dnorm(0.0,lambda24)\r\n',...
	'\t} }\r\n',...
	'\tlambda24 ~ dchisqr(1)\r\n',...
	' \r\n',...
	'\t# Convert a0,a1[],a2[],a1a2[,],etc to sum-to-zero b0,b1[],b2[],b1b2[,], etc :\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {for ( j3 in 1:Nx3Lvl ) {for ( j4 in 1:Nx4Lvl ) {for ( j5 in 1:Nx5Lvl ) {\r\n',...
	'\t\tm[j1,j2,j3,j4,j5] <- a0 + a1[j1] + a2[j2] + a3[j3]  + a4[j4]  + a5[j5] +',...
	'a1a3[j1,j3] + a2a3[j2,j3] + a1a4[j1,j4] + a2a4[j2,j4]\r\n',...
	'\t} } } } }\r\n',...
	'\tb0 <- mean( m[1:Nx1Lvl,1:Nx2Lvl,1:Nx3Lvl,1:Nx4Lvl,1:Nx5Lvl] )\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { b1[j1] <- mean( m[j1,1:Nx2Lvl,1:Nx3Lvl,1:Nx4Lvl,1:Nx5Lvl] ) - b0 }\r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) { b2[j2] <- mean( m[1:Nx1Lvl,j2,1:Nx3Lvl,1:Nx4Lvl,1:Nx5Lvl] ) - b0 }\r\n',...
	'\tfor ( j3 in 1:Nx3Lvl ) { b3[j3] <- mean( m[1:Nx1Lvl,1:Nx2Lvl,j3,1:Nx4Lvl,1:Nx5Lvl] ) - b0 }\r\n',...
	'\tfor ( j4 in 1:Nx4Lvl ) { b4[j4] <- mean( m[1:Nx1Lvl,1:Nx2Lvl,1:Nx3Lvl,j4,1:Nx5Lvl] ) - b0 }\r\n',...
	'\tfor ( j3 in 1:Nx5Lvl ) { b5[j5] <- mean( m[1:Nx1Lvl,1:Nx2Lvl,1:Nx3Lvl,1:Nx4Lvl.j5] ) - b0 }\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\tb1b3[j1,j3] <- mean( m[j1,1:Nx2Lvl,j3,1:Nx4Lvl,1:Nx5Lvl] ) - ( b0 + b1[j1] + mean( b2[1:Nx2Lvl]) + b3[j3] + mean( b4[1:Nx4Lvl]) + mean( b5[1:Nx5Lvl])  )  \r\n',...
	'\t} }\r\n',...
	'\t\tb2b3[j2,j3] <- mean( m[1:Nx2Lvl,j2,j3,1:Nx4Lvl,1:Nx5Lvl] ) - ( b0 + mean( b2[1:Nx2Lvl]) + b1[j1] + b3[j3] + mean( b4[1:Nx4Lvl]) + mean( b5[1:Nx5Lvl])  )  \r\n',...
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
	'\tfor (j3 in 1:Nx3Lvl) {a3prior[j3] ~ dnorm(0.0,lambda3prior) }\r\n',...
	'\tlambda3prior ~ dchisqr(1)\r\n',...
	'\t#\r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\tb4prior[j2] ~ dnorm(0.0,lambdaMetIprior)\r\n',...
	'\t} \r\n',...
	'\tlambdaMetIprior ~ dchisqr(1)\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\ta1a2prior[j1,j2] ~ dnorm(0.0,lambda12prior)\r\n',...
	'\t} }\r\n',...
	'\tlambda12prior ~ dchisqr(1)\r\n',...
	' \r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\ta1a3prior[j1,j3] ~ dnorm(0.0,lambda13prior)\r\n',...
	'\t} }\r\n',...
	'\tlambda13prior ~ dchisqr(1)\r\n',...
	' \r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\ta2a3prior[j2,j3] ~ dnorm(0.0,lambda23prior)\r\n',...
	'\t} }\r\n',...
	'\tlambda23prior ~ dchisqr(1)\r\n',...
	' \r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\ta1a2a3prior[j1,j2,j3] ~ dnorm(0.0,lambda123prior)\r\n',...
	'\t} } }\r\n',...
	'\tlambda123prior ~ dchisqr(1)\r\n',...
	' \r\n',...
	'\t# Convert a0,a1[],a2[],a1a2[,],etc to sum-to-zero b0,b1[],b2[],b1b2[,], etc :\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\tmprior[j1,j2,j3] <- a0prior + a1prior[j1] + a2prior[j2]  + a3prior[j3] + a1a2prior[j1,j2] + a1a3prior[j1,j3] + a2a3prior[j2,j3] + a1a2a3prior[j1,j2,j3]  \r\n',...
	'\t} } }\r\n',...
	'\tb0prior <- mean( mprior[1:Nx1Lvl,1:Nx2Lvl,1:Nx3Lvl] )\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { b1prior[j1] <- mean( mprior[j1,1:Nx2Lvl,1:Nx3Lvl] ) - b0prior }\r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) { b2prior[j2] <- mean( mprior[1:Nx1Lvl,j2,1:Nx3Lvl] ) - b0prior }\r\n',...
	'\tfor ( j3 in 1:Nx3Lvl ) { b3prior[j3] <- mean( mprior[1:Nx1Lvl,1:Nx2Lvl,j3] ) - b0prior }\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\tb1b2prior[j1,j2] <- mean( mprior[j1,j2,1:Nx3Lvl] ) - ( b0prior + b1prior[j1] + b2prior[j2] + mean( b3prior[1:Nx3Lvl] ))  \r\n',...
	'\t} }\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\tb1b3prior[j1,j3] <- mean( mprior[j1,1:Nx2Lvl,j3] ) - ( b0prior + b1prior[j1] + mean( b2prior[1:Nx2Lvl]) + b3prior[j3]  )  \r\n',...
	'\t} }\r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\tb2b3prior[j2,j3] <- mean( mprior[1:Nx1Lvl,j2,j3] ) - ( b0prior + mean( b1prior[1:Nx1Lvl]) + b2prior[j2] + b3prior[j3]  )  \r\n',...
	'\t} }\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\tb1b2b3prior[j1,j2,j3] <- mean( mprior[j1,j2,j3] ) - ( b0prior +  b1prior[j1] + b2prior[j2] + b3prior[j3]  + b1b2prior[j1,j2] + b1b3prior[j1,j3] + b2b3prior[j2,j3] )  \r\n',...
	'\t} } }\r\n',...
	'}\r\n'];
% Write the modelString to a file, using Matlab commands:
pa_datadir;
fid			= fopen(model,'w');
fprintf(fid,str);
fclose(fid);

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
	H0	= bprior(:,indx(cIdx,1))-bprior(:,indx(cIdx,2));
	bf(cIdx)	= pa_bayesfactor(H1,H0);
	db(:,cIdx)	= H1;
	HDI(:,cIdx)			= HDIofMCMC(H1,0.95);
	xlbl{cIdx}	= ['[' x1label{i1} ' - ' x1label{i2} ']'];
end

function [db,bf,indx,xlbl,HDI] = getxcomparisons(b,bprior,x1label,x2label)
% determine unique comparisons
[~,nb,nc]		= size(b); % number of factors
[indx1,indx2]	= meshgrid(1:nb,1:nc); % possible interactions
xindx			= [indx1(:) indx2(:)]; % interaction indices
nx				= size(xindx,1); % number of interactions

[indx1,indx2]	= meshgrid(1:nx,1:nx); % possible comparisons
indx			= [indx1(:) indx2(:)]; % interaction indices
indx			= unique(sort(indx,2),'rows'); % unique one-way comparisons
sel				= indx(:,1)==indx(:,2); % self-comparison not required for nominal factors
indx			= indx(~sel,:);
ncomp			= size(indx,1); % number of unique comparisons
bf				= NaN(1,ncomp);
xlbl			= cell(ncomp,1);
db				= NaN(size(b,1),ncomp);
HDI		= NaN(2,ncomp);
for cIdx = 1:ncomp
	H1			= b(:,xindx(indx(cIdx,1),1),xindx(indx(cIdx,1),2))-b(:,xindx(indx(cIdx,2),1),xindx(indx(cIdx,2),2));
	H0			= bprior(:,xindx(indx(cIdx,1),1),xindx(indx(cIdx,1),2))-bprior(:,xindx(indx(cIdx,2),1),xindx(indx(cIdx,2),2));
	bf(cIdx)	= pa_bayesfactor(H1,H0);
	xlbl{cIdx}	= ['[' x1label{xindx(indx(cIdx,1),1)} ' ' x2label{xindx(indx(cIdx,1),2)} '] - [' x1label{xindx(indx(cIdx,2),1)} ' ' x2label{xindx(indx(cIdx,2),2)} ']'];
	db(:,cIdx)	= H1;
	HDI(:,cIdx)			= HDIofMCMC(H1,0.95);
end

function [db,bf,indx,xlbl,HDI] = getxxxcomparisons(b,bprior,x1label,x2label,x3label)
% determine unique comparisons
[~,nb,nc,nd]		= size(b); % number of factors
[indx1,indx2,indx3]	= meshgrid(1:nb,1:nc,1:nd); % possible interactions
xindx			= [indx1(:) indx2(:) indx3(:)]; % interaction indices
nx				= size(xindx,1); % number of interactions

[indx1,indx2]	= meshgrid(1:nx,1:nx); % possible comparisons
indx			= [indx1(:) indx2(:)]; % interaction indices
indx			= unique(sort(indx,2),'rows'); % unique one-way comparisons

sel				= indx(:,1)==indx(:,2); % self-comparison not required for nominal factors
indx			= indx(~sel,:);

%% At least 2 of three interactions should be the same
a1		= xindx(indx(:,1),:);
a2		= xindx(indx(:,2),:);
sel		= sum(a1 == a2,2)==2;
indx	= indx(sel,:);
%%
ncomp			= size(indx,1); % number of unique comparisons
bf				= NaN(1,ncomp);
xlbl			= cell(ncomp,1);
db				= NaN(size(b,1),ncomp);
HDI		= NaN(2,ncomp);
for cIdx = 1:ncomp
	i1 = xindx(indx(cIdx,1),1);
	i2 = xindx(indx(cIdx,1),2);
	i3 = xindx(indx(cIdx,1),3);
	
	i4 = xindx(indx(cIdx,2),1);
	i5 = xindx(indx(cIdx,2),2);
	i6 = xindx(indx(cIdx,2),3);
	
	H1			= b(:,i1,i2,i3)-b(:,i4,i5,i6);
	H0			= bprior(:,i1,i2,i3)-bprior(:,i1,i2,i3);
	bf(cIdx)	= pa_bayesfactor(H1,H0);
	xlbl{cIdx}	= ['[' x1label{i1} ' ' x2label{i2} ' ' x3label{i3} '] - [' x1label{i4} ' ' x2label{i5} ' ' x3label{i6} ']'];
	db(:,cIdx)	= H1;
	HDI(:,cIdx)			= HDIofMCMC(H1,0.95);
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

function braingraph(data,b,comp,BF01,xlabel,img,braincontour,uroi,nroi,crit,indx,nindx,col,basefig)
BF		= 1./BF01;
ncomp	= size(comp,1);
for cIdx = 1:ncomp
	disp('Analyze');
	img		= zeros(size(img));
	mu		= struct([]);
	beta	= NaN(nroi,1);
	if any(BF(:,cIdx)>=crit)
		for roiIdx = 1:nroi
			beta(roiIdx)	= b(roiIdx,cIdx);
			a				= BF(roiIdx,cIdx)<crit;
			if a
				beta(roiIdx) = 0;
			end
		end
		% Reshape, so that for both left and right same factor is applied
		nroifiles	= numel(data);
		roifiles	= [data.roi];
		beta2		= NaN(nroifiles,1);
		for fIdx = 1:nroifiles
			fname		= roifiles{fIdx};
			fname		= fname(5:end-8);
			sel			= strfind(fname,'_');
			fname(sel)	= ' ';
			fname		= fname(1:end-2);
			sel			= strcmp(fname,uroi);
			beta2(fIdx) = beta(sel);
		end
		beta	= beta2;
		muimg1	= roicolourise2([data.roi],beta,img);
		muIMG1	= [];
		for zIndx = 1:nindx
			tmp		= squeeze(muimg1(:,:,indx(zIndx)));
			muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
		end
		mu(1).img	= muIMG1;
		IMG			= [mu(1).img];
		
		disp('-------- Graphics -----')
		figure(basefig+cIdx)
		colormap(col);
		imagesc(IMG');
		hold on
		contour(repmat(braincontour',1,1),1,'k');
		axis equal
		caxis([-10 10]);
		colorbar;
		set(gca,'YDir','normal');
		axis off;
		title(xlabel{cIdx});
		str = [mfilename xlabel{cIdx}];
		pa_datadir;
		print('-depsc','-painter',str);
		drawnow
	end
end

function braingraph1(data,b,comp,BF01,xlabel,img,braincontour,uroi,nroi,crit,indx,nindx,col,basefig)
BF		= 1./BF01;
ncomp	= size(comp,1);
for cIdx = 1:ncomp
	disp('Analyze');
	img		= zeros(size(img));
	mu		= struct([]);
	beta	= NaN(nroi,1);
	if any(BF(:,cIdx)>=crit)
		for roiIdx = 1:nroi
			beta(roiIdx)	= b(roiIdx,cIdx);
			a				= BF(roiIdx,cIdx)<crit;
			if a
				beta(roiIdx) = 0;
			end
		end
		% Reshape, so that for both left and right same factor is applied
		nroifiles	= numel(data);
		roifiles	= [data.roi];
		beta2		= NaN(nroifiles,1);
		s = char(beta2);
		for fIdx = 1:nroifiles
			fname		= roifiles{fIdx};
			fname		= fname(5:end-8);
			sel			= strfind(fname,'_');
			fname(sel)	= ' ';
			s(fIdx) = fname(end);
			if strncmpi(fname,'Vermis',6)
				s(fIdx) = 'L';
			else
				fname		= fname(1:end-2);
			end
			sel			= strcmp(fname,uroi);
			beta2(fIdx) = beta(sel);
		end
		beta	= beta2;
		s = s';
		sel = strfind(s,'L');
		beta(sel) = 0;
		% 		keyboard
		muimg1	= roicolourise2([data.roi],beta,img);
		muIMG1	= [];
		for zIndx = 1:nindx
			tmp		= squeeze(muimg1(:,:,indx(zIndx)));
			tmp = tmp((ceil(79/2)+2):end,:);
			muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
		end
		mu(1).img	= muIMG1;
		IMG			= [mu(1).img];
		
		disp('-------- Graphics -----')
		figure(basefig+cIdx)
		colormap(col);
		imagesc(IMG');
		hold on
		contour(repmat(braincontour',1,1),1,'k');
		axis equal
		caxis([-10 10]);
		colorbar;
		set(gca,'YDir','normal');
		axis off;
		title(xlabel{cIdx});
		roi = [data(beta~=0).roi];
		roitextxy(roi,indx,nindx);
		
		str = [mfilename xlabel{cIdx}];
		
		pa_datadir;
		print('-depsc','-painter',str);
		drawnow
	end
end

function braingraph2(data,b,comp,BF01,xlabel,img,braincontour,uroi,nroi,crit,indx,nindx,col,basefig)
BF		= 1./BF01;
ncomp	= size(comp,1);

for cIdx = 1:ncomp
	disp('Analyze');
	img		= zeros(size(img));
	mu		= struct([]);
	beta	= NaN(nroi,1);
	for roiIdx = 1:nroi
		beta(roiIdx) = b(roiIdx,cIdx);
		a			= BF(roiIdx,cIdx)<crit;
		if a
			beta(roiIdx) = 0;
		end
	end
	
	% Reshape, so that for both left and right same factor is applied
	nroifiles	= numel(data);
	roifiles	= [data.roi];
	beta2		= NaN(nroifiles,1);
	s = beta2;
	for fIdx = 1:nroifiles
		fname		= roifiles{fIdx};
		fname		= fname(5:end-8);
		sel			= strfind(fname,'_');
		fname(sel)	= ' ';
		s(fIdx) = fname(end);
		if strncmpi(fname,'Vermis',6)
			s(fIdx) = 'L';
		else
			fname		= fname(1:end-2);
		end
		sel			= strcmp(fname,uroi);
		beta2(fIdx) = beta(sel);
	end
	beta	= beta2;
	s = s';
	sel = strfind(s,'L');
	beta(sel) = 0;
	muimg1	= roicolourise2([data.roi],beta,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		tmp = tmp((ceil(79/2)+2):end,:);
		muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
	end
	mu(1).img	= muIMG1;
	IMG			= [mu(1).img];
	
	disp('-------- Graphics -----')
	figure(basefig+cIdx)
	colormap(col);
	imagesc(IMG');
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([-5 5]);
	colorbar;
	set(gca,'YDir','normal');
	axis off;
	str = ['Phoneme ' xlabel{cIdx}];
	title(str);
	drawnow
	str = [mfilename 'phi' str];
	pa_datadir;
	print('-depsc','-painter',str);
end


function savetable(bf,p,HDI,crit,sheet,uroi,xnames)

selbf	= bf>=crit;
n		= size(p,2);
for ii = 1:n
	if sum(selbf(:,ii))
		ltr = 1+(ii-1)*3;
		if ltr<27
			r1c1 = [char(64+ltr) '1'];
			r2c1 = [char(64+ltr) '2'];
			r3c1 = [char(64+ltr) '3'];
		else
			ltr = ltr-26;
			r1c1 = ['A' char(64+ltr) '1'];
			r2c1 = ['A' char(64+ltr) '2'];
			r3c1 = ['A' char(64+ltr) '3'];
		end
		ltr = 2+(ii-1)*3;
		if ltr<27
			r2c2 = [char(64+ltr) '2'];
			r3c2 = [char(64+ltr) '3'];
		else
			ltr = ltr-26;
			r2c2 = ['A' char(64+ltr) '2']
			r3c2 = ['A' char(64+ltr) '3'];
		end
		ltr = 3+(ii-1)*3;
		
		if ltr<27
			r2c3 = [char(64+ltr) '2'];
			r3c3 = [char(64+ltr) '3'];
		else
			ltr = ltr-26;
			r2c3 = ['A' char(64+ltr) '2'];
			r3c3 = ['A' char(64+ltr) '3'];
		end
		xlswrite('tablexall',xnames(ii),sheet,r1c1);
		xlswrite('tablexall',{'Brain region'},sheet,r2c1);
		xlswrite('tablexall',uroi(selbf(:,ii)),sheet,r3c1);
		xlswrite('tablexall',{'Beta (2.5/97.5%)'},sheet,r2c2);
		a = round(p(selbf(:,ii),ii)*10)/10;
		b = round(HDI(selbf(:,ii),1,ii)'*10)/10;
		c = round(HDI(selbf(:,ii)',2,ii)*10)/10;
		str = cell(sum(selbf(:,ii)),1);
		for jj = 1:sum(selbf(:,ii))
			str{jj} = [num2str(a(jj)) ' (' num2str(b(jj)) '/' num2str(c(jj)) ')'];
		end
		xlswrite('tablexall',str,sheet,r3c2);
		xlswrite('tablexall',{'Bayes factor'},sheet,r2c3);
		xlswrite('tablexall',round(bf(selbf(:,ii),ii)),sheet,r3c3);
	end
end

function plotexample(y,x1,x2,x3,phi,s0,s1,s2,s3,s4,p0,p1,p2,p3,p4,mu4,str,BF)

close all

%%
stp		= 25;
a		= s0;
b0	= a(1:stp:end); % credible bias
a		= s1;
b1		= a(1:stp:end,:); % credible group effect
a		= s2;
b2		= a(1:stp:end,:); % credible stim effect
a		= s3;
b3		= a(1:stp:end,:); % credible stim effect
a		= s4;
b4		= a(1:stp:end,:); % credible stim effect
gain	= mean(b4,2);
n	= numel(b0);
subplot(221)
for ii = 1:n
	b = b0(ii) + b1(ii,:) ;
	plot(1:3,b,'k-','Color',[.7 .7 .7],'LineWidth',1)
	hold on
end
b = p0 + p1 ;
plot(1:3,b,'k-','Color','k','LineWidth',3)
col = pa_statcolor(3,[],[],[],'def',1);
mrk = 'o';
sel = x1==1 & x2 ==1 ;
plot(x1(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==1 & x2 ==2 ;
plot(x1(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==1 & x2 ==3;
plot(x1(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

mrk = 's';
sel = x1==2 & x2 ==1 ;
plot(x1(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==2 & x2 ==2 ;
plot(x1(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==2 & x2 ==3;
plot(x1(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

mrk = '^';
sel = x1==3 & x2 ==1 ;
plot(x1(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==3 & x2 ==2 ;
plot(x1(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==3 & x2 ==3;
plot(x1(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

xlim([0 4])
% ylim([60 100])
axis square;
box off;
set(gca,'TickDir','out','XTick',[1 2 3],'XTickLabel',{'Pre','Post','NH'});
ylabel('[^{18}f]FDG (ml/dl/min)');
xlabel('Group');
sel = 1./BF>3;
pa_text(0.1,0.9,num2str(sel))
% str = ['Region: ' char(data(selroi).roi) ', stimulus: ' num2str(stmIdx)];
title(str)
drawnow


%%

sel = x1==1;
% mean(y(sel))
mu = accumarray(x1,y,[],@nanmean)

title(mu)
%%

%%
stp		= 25;
a		= s0;
b0	= a(1:stp:end); % credible bias
a		= s1;
b1		= a(1:stp:end,:); % credible group effect
a		= s2;
b2		= a(1:stp:end,:); % credible stim effect
a		= s3;
b3		= a(1:stp:end,:); % credible stim effect
a		= s4;
b4		= a(1:stp:end,:); % credible stim effect
gain	= mean(b4,2);
n	= numel(b0);
subplot(222)
for ii = 1:n
	b = b0(ii)  + b2(ii,:)  ;
	plot(1:3,b,'k-','Color',[.7 .7 .7],'LineWidth',1)
	hold on
end
b = p0 + p2  ;
plot(1:3,b,'k-','Color','k','LineWidth',3)
col = pa_statcolor(3,[],[],[],'def',1);
mrk = 'o';
sel = x1==1 & x2 ==1 ;
plot(x2(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==1 & x2 ==2 ;
plot(x2(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==1 & x2 ==3;
plot(x2(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

mrk = 's';
sel = x1==2 & x2 ==1 ;
plot(x2(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==2 & x2 ==2 ;
plot(x2(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==2 & x2 ==3;
plot(x2(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

mrk = '^';
sel = x1==3 & x2 ==1 ;
plot(x2(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==3 & x2 ==2 ;
plot(x2(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==3 & x2 ==3;
plot(x2(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

xlim([0 4])
% ylim([60 100])
axis square;
box off;
set(gca,'TickDir','out','XTick',[1 2 3],'XTickLabel',{'Rest','Video','Audiovideo'});
ylabel('[^{18}f]FDG (ml/dl/min)');
xlabel('Stimulus');
sel = 1./BF>3;
pa_text(0.1,0.9,num2str(sel))
% str = ['Region: ' char(data(selroi).roi) ', stimulus: ' num2str(stmIdx)];
title(str)
drawnow

%%
stp		= 25;
a		= s0;
b0	= a(1:stp:end); % credible bias
a		= s1;
b1		= a(1:stp:end,:); % credible group effect
a		= s2;
b2		= a(1:stp:end,:); % credible stim effect
a		= s3;
b3		= a(1:stp:end,:); % credible stim effect
a		= s4;
b4		= a(1:stp:end,:); % credible stim effect
gain	= mean(b4,2);
n	= numel(b0);
subplot(223)
for ii = 1:n
	b = b0(ii)  + b3(ii,:);
	plot(1:2,b,'k-','Color',[.7 .7 .7],'LineWidth',1)
	hold on
end
b = p0  + p3;
plot(1:2,b,'k-','Color','k','LineWidth',3)
col = pa_statcolor(3,[],[],[],'def',1);
mrk = 'o';

sel = x1==1 & x2 ==1 & x3==1;
plot(x3(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==1 & x2 ==2  & x3==1;
plot(x3(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==1 & x2 ==3 & x3==1;
plot(x3(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

mrk = 's';
sel = x1==2 & x2 ==1  & x3==1;
plot(x3(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==2 & x2 ==2  & x3==1;
plot(x3(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==2 & x2 ==3 & x3==1;
plot(x3(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

mrk = '^';
sel = x1==3 & x2 ==1  & x3==1;
plot(x3(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==3 & x2 ==2  & x3==1;
plot(x3(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==3 & x2 ==3 & x3==1;
plot(x3(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

%

sel = x1==1 & x2 ==1 & x3==2;
plot(x3(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==1 & x2 ==2  & x3==2;
plot(x3(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==1 & x2 ==3 & x3==2;
plot(x3(sel)+randn(sum(sel),1)/30-0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

mrk = 's';
sel = x1==2 & x2 ==1  & x3==2;
plot(x3(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==2 & x2 ==2  & x3==2;
plot(x3(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==2 & x2 ==3 & x3==2;
plot(x3(sel)+randn(sum(sel),1)/30,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

mrk = '^';
sel = x1==3 & x2 ==1  & x3==2;
plot(x3(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
sel = x1==3 & x2 ==2  & x3==2;
plot(x3(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
sel = x1==3 & x2 ==3 & x3==2;
plot(x3(sel)+randn(sum(sel),1)/30+0.15,y(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

xlim([0 3])
% ylim([60 100])
axis square;
box off;
set(gca,'TickDir','out','XTick',[1 2],'XTickLabel',{'Left','Right'});
ylabel('[^{18}f]FDG (ml/dl/min)');
xlabel('Stimulus');
sel = 1./BF>3;
pa_text(0.1,0.9,num2str(sel))
% str = ['Region: ' char(data(selroi).roi) ', stimulus: ' num2str(stmIdx)];
title(str)
drawnow
%

%%
% stp		= 25;
% a		= s0;
% b0	= a(1:stp:end); % credible bias
% a		= s1;
% b1		= a(1:stp:end,:); % credible group effect
% a		= s2;
% b2		= a(1:stp:end,:); % credible stim effect
% a		= s3;
% b3		= a(1:stp:end,:); % credible stim effect
stim = 1;
a		= s4;
whos s4
b4		= a(1:stp:end,:); % credible stim effect
gain	= b4;
whos gain mu4
% n	= numel(b0);
phi = pa_logistic(phi)*100;
x = 0:0.001:1.0;
p = pa_logit(x);
subplot(224)
for ii = 1:n
	fdg = gain(ii,stim)*p;
	% 	tmp = nanmean(b1b2(ii,:))+nanmean(b1(ii,:))+b2(ii);
	% 	plot(fdg+bias(ii)+tmp,pa_logistic(p+offset),'k-','Color',[.7 .7 .7],'LineWidth',1)
	
	b = b0(ii) + fdg ;
	plot(b,pa_logistic(p+mu4)*100,'k-','Color',[.7 .7 .7],'LineWidth',1)
	hold on
end
fdg = p4(stim)*p;
b = p0 +fdg;
plot(b,pa_logistic(p+mu4)*100,'k-','Color','k','LineWidth',3)
col = pa_statcolor(3,[],[],[],'def',1);
mrk = 'o';
sel = x1==1 & x2 ==stim ;
plot(y(sel),phi(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
% sel = x1==1 & x2 ==2 ;
% plot(y(sel),phi(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
% sel = x1==1 & x2 ==3;
% plot(y(sel),phi(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

mrk = 's';
sel = x1==2 & x2 ==stim ;
plot(y(sel),phi(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
% sel = x1==2 & x2 ==2 ;
% plot(y(sel),phi(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
% sel = x1==2 & x2 ==3;
% plot(y(sel),phi(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

mrk = '^';
sel = x1==3 & x2 ==stim ;
plot(y(sel),phi(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(3,:),'LineWIdth',1)
hold on
% sel = x1==3 & x2 ==2 ;
% plot(y(sel),phi(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(1,:),'LineWIdth',1)
% sel = x1==3 & x2 ==3;
% plot(y(sel),phi(sel),['k' mrk],'MarkerSize',5,'MarkerFaceColor',col(2,:),'LineWIdth',1)

% xlim([0 4])
ylim([-10 110])
mu = round(nanmean(y)/10)*10;
xax = [mu-10 mu+10]
xlim(xax);
axis square;
box off;
set(gca,'TickDir','out','XTick',0:5:200,'YTick',0:20:100);
xlabel('[^{18}f]FDG (ml/dl/min)');
ylabel('Phoneme score');
sel = 1./BF>3;
pa_text(0.1,0.9,num2str(sel))
% str = ['Region: ' char(data(selroi).roi) ', stimulus: ' num2str(stmIdx)];
title(str)
drawnow
