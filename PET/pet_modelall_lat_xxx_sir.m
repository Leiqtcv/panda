function pet_modelall_lat_xxx
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
loadflag		= true;
% loadflag		= false;
loadbrainflag	= true;


%% Labels
x1names	= {'Pre-implant','Post-implant','Normal-hearing'};
x2names	= {'Rest','Video','Audio-Video'};
x3names	= {'Left','Right'};

if ~loadflag
	if true
		createmodel(model);
	end
	%% THE DATA.
	% Load the data:
	pa_datadir;
	load('petancova')
	[roi,uroi,nroi] = getroi(data);
	paramb0		= NaN(nroi,1); % bias
	paramb1		= NaN(nroi,3); % group
	paramb2		= NaN(nroi,3); % stimulus
	paramb3		= NaN(nroi,2); % laterality
	paramb1b2	= NaN(nroi,3,3); % group x stimulus
	paramb1b3	= NaN(nroi,3,2); % group x laterality
	paramb2b3	= NaN(nroi,3,2); % stimulus x laterality
	paramb4		= NaN(nroi,3); % phoneme (metric)
	parammetM	= NaN(nroi,1); % bias phoneme
	BF1			= NaN(nroi,3); D1 = BF1;
	BF2			= NaN(nroi,3); D2 = BF2;
	BF3			= NaN(nroi,1); D3 = BF3;
	BF4			= NaN(nroi,3); D4 = BF4;
	BF12		= NaN(nroi,36); D12 = BF12;
	BF13		= NaN(nroi,15); D13 = BF13;
	BF23		= NaN(nroi,15); D23 = BF23;
	
	dataStruct	= struct('y',[],'x1',[],'x2',[],'x3',[]);
	samp		= struct([]);
	for roiIdx = 1:nroi
		%% load regional data
		selroi		= strcmp(uroi(roiIdx),roi);
		disp([data(selroi).roi])
		% 		s(selroi)
		y			= [data(selroi).FDG];
		y(1:4,1:2)	= NaN;
		y(1:4,6:7)	= NaN;
		y			= y(:);
		
		x1			= [data(selroi).group]; % group
		x1(1:4,1:2) = NaN;
		x1(1:4,6:7) = NaN;
		x1			= x1(:);
		
		x2			= [data(selroi).stim]; % stimulus
		x2(1:4,1:2) = NaN;
		x2(1:4,6:7) = NaN;
		x2			= x2(:);
		
		xMet		=	[data(selroi).SIR];
		xMet(1:5,:)	= NaN;
		xMet		= repmat(xMet,5,1); % phoneme score
		xMet		= xMet(:);
		
		x3			= ones(size(y)); % laterality
		ny			= numel(y);
		x3(ny/2+1:end) = 2;
		
		%% Selection
		sel		= ismember(x1,1:3) & ismember(x2,1:3);
		y		= y(sel);
		x1		= x1(sel); % 'Pre-implant','Post-implant','NH'
		x2		= x2(sel); % 'Rest','Video','AV'
		xMet	= xMet(sel);
		x3		= x3(sel);
		
% 		xMet	= pa_logit(xMet/100); % convert to -inf to + inf scale
		sel		= y<30; % remove unlikely FDG values, i.e. because of poor scan view
		y(sel)	= NaN;
		
		%%
		Ntotal	= length(y);
		Nx1Lvl	= length(unique(x1));
		Nx2Lvl	= length(unique(x2));
		Nx3Lvl	= length(unique(x3));
		
		% Normalize, for JAGS MCMC sampling, e.g. to use cauchy(0,1) prior
		[z,yMorig,ySDorig]	= pa_zscore(y');
		[zMet,metM,metSD]	= pa_zscore(xMet');
		
		%% Data
		dataStruct.y		= z';
		dataStruct.x1		= x1;
		dataStruct.x2		= x2;
		dataStruct.x3		= x3;
		dataStruct.xMet		= zMet;
		dataStruct.Ntotal	= Ntotal;
		dataStruct.Nx1Lvl	= Nx1Lvl;
		dataStruct.Nx2Lvl	= Nx2Lvl;
		dataStruct.Nx3Lvl	= Nx3Lvl;
		
		%% INTIALIZE THE CHAINS.
		group = {dataStruct.x1 dataStruct.x2 dataStruct.x3};
		[P,~,stats] = anovan(dataStruct.y,group,'model','interaction','display','off');
		disp(P)
		a0 = stats.coeffs(1);
		a1 = stats.coeffs(2:4);
		a2 = stats.coeffs(5:7);
		a3 = stats.coeffs(8:9);
		a1a2 = stats.coeffs(10:18); a1a2 = reshape(a1a2,Nx1Lvl,Nx2Lvl);
		a1a3 = stats.coeffs(19:24); a1a3 = reshape(a1a3,Nx1Lvl,Nx3Lvl);
		a2a3 = stats.coeffs(25:30); a2a3 = reshape(a2a3,Nx2Lvl,Nx3Lvl);
		
		nChains		= 5;
		initsStruct = struct([]);
		for ii = 1:nChains
			initsStruct(ii).a0			= a0;
			initsStruct(ii).a1			= a1;
			initsStruct(ii).a2			= a2;
			initsStruct(ii).a3			= a3;
			initsStruct(ii).a1a2		= a1a2;
			initsStruct(ii).a1a3		= a1a3;
			initsStruct(ii).a2a3		= a2a3;
			initsStruct(ii).b4			= zeros(3,1);
			initsStruct(ii).a0prior		= a0;
			initsStruct(ii).a1prior		= a1;
			initsStruct(ii).a2prior		= a2;
			initsStruct(ii).a3prior		= a3;
			initsStruct(ii).a1a2prior	= a1a2;
			initsStruct(ii).a1a3prior	= a1a3;
			initsStruct(ii).a2a3prior	= a2a3;
			initsStruct(ii).b4prior		= zeros(3,1);
			initsStruct(ii).sigma		= nanstd(dataStruct.y)/2; % lazy
		end
		
		%% RUN THE CHAINS
		parameters		= {'b0','b1','b2','b3','b4',...
			'b1b2','b1b3','b2b3',...
			'b0prior','b1prior','b2prior','b3prior','b4prior',...
			'b1b2prior','b1b3prior','b2b3prior',...
			'sigma','mu'}; % The parameter(s) to be monitored.
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
		samples = matjags(...
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
		% Extract b values,
		% and convert from standardized b values to original scale b values:
		b0			= samples.b0(:)*ySDorig + yMorig;
		chainLength = length(samples.b0);
		b1			= reshape(samples.b1,nChains*chainLength,Nx1Lvl)*ySDorig;
		b2			= reshape(samples.b2,nChains*chainLength,Nx2Lvl)*ySDorig;
		b3			= reshape(samples.b3,nChains*chainLength,Nx3Lvl)*ySDorig;
		b4			= reshape(samples.b4,nChains*chainLength,Nx2Lvl)*ySDorig/metSD;
		b1b2		= reshape(samples.b1b2,nChains*chainLength,Nx1Lvl,Nx2Lvl)*ySDorig;
		b1b3		= reshape(samples.b1b3,nChains*chainLength,Nx1Lvl,Nx3Lvl)*ySDorig;
		b2b3		= reshape(samples.b2b3,nChains*chainLength,Nx2Lvl,Nx3Lvl)*ySDorig;
		mu			= samples.mu*ySDorig + yMorig;
		
		b1prior		= reshape(samples.b1prior,nChains*chainLength,Nx1Lvl)*ySDorig;
		b2prior		= reshape(samples.b2prior,nChains*chainLength,Nx2Lvl)*ySDorig;
		b3prior		= reshape(samples.b3prior,nChains*chainLength,Nx3Lvl)*ySDorig;
		b4prior		= reshape(samples.b4prior,nChains*chainLength,Nx2Lvl)*ySDorig/metSD;
		b1b2prior	= reshape(samples.b1b2prior,nChains*chainLength,Nx1Lvl,Nx2Lvl)*ySDorig;
		b1b3prior	= reshape(samples.b1b3prior,nChains*chainLength,Nx1Lvl,Nx3Lvl)*ySDorig;
		b2b3prior	= reshape(samples.b2b3prior,nChains*chainLength,Nx2Lvl,Nx3Lvl)*ySDorig;
		
		%% Save
		% Averages
		paramb0(roiIdx,:)	= nanmean(b0);
		paramb1(roiIdx,:)	= nanmean(b1);
		paramb2(roiIdx,:)	= nanmean(b2);
		paramb3(roiIdx,:)	= nanmean(b3);
		paramb4(roiIdx,:,:)	= squeeze(nanmean(b4));
		parammetM(roiIdx)	= metM;
		paramb1b2(roiIdx,:,:)	= squeeze(nanmean(b1b2));
		paramb1b3(roiIdx,:,:)	= squeeze(nanmean(b1b3));
		paramb2b3(roiIdx,:,:)	= squeeze(nanmean(b2b3));
		% Samples
		% 		samp(roiIdx).b0		= b0;
		% 		samp(roiIdx).b1		= b1;
		% 		samp(roiIdx).b2		= b2;
		% 		samp(roiIdx).b3		= b3;
		% 		samp(roiIdx).b4		= b4;
		% 		samp(roiIdx).b1b2	= b1b2;
		% 		samp(roiIdx).b1b3	= b1b3;
		% 		samp(roiIdx).b2b3	= b2b3;
		samp(roiIdx).mu		= mu;
		
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
		
		% metric comparison to 0
		[db4,bf,hdi]		= get0comparisons(b4,b4prior); % Main factor phoneme score
		BF4(roiIdx,:)	= bf;
		D4(roiIdx,:)	= mean(db4);
		HDI4(roiIdx,:,:)	= hdi;
		
		% Interaction effects
		[db12,bf12,comp12,xlbl12,hdi] = getxcomparisons(b1b2,b1b2prior,x1names,x2names);
		BF12(roiIdx,:)	= bf12;
		D12(roiIdx,:)	= mean(db12);
		HDI12(roiIdx,:,:)	= hdi;
		
		[db13,bf13,comp13,xlbl13,hdi] = getxcomparisons(b1b3,b1b3prior,x1names,x3names);
		BF13(roiIdx,:)	= bf13;
		D13(roiIdx,:)	= mean(db13);
		HDI13(roiIdx,:,:)	= hdi;
		
		[db23,bf23,comp23,xlbl23,hdi] = getxcomparisons(b2b3,b2b3prior,x2names,x3names);
		BF23(roiIdx,:)	= bf23;
		D23(roiIdx,:)	= mean(db23);
		HDI23(roiIdx,:,:)	= hdi;
		
	end
	% parameters
	param.b0	= paramb0;	param.b1	= paramb1;	param.b2 = paramb2;	param.b3 = paramb3;
	param.b4	= paramb4;	param.metM	= parammetM;
	param.b1b2	= paramb1b2;	param.b1b3 = paramb1b3;	param.b2b3 = paramb2b3;
	% differences
	d.D1		= D1;		d.D2		= D2;		d.D3		= D3;		d.D4		= D4;
	d.D12		= D12;		d.D13		= D13;		d.D23		= D23;
	d.BF1		= BF1;		d.BF2		= BF2;		d.BF3		= BF3;		d.BF4		= BF4;
	d.BF12		= BF12;		d.BF13		= BF13;		d.BF23		= BF23;
	d.HDI1		= HDI1;		d.HDI2		= HDI2;		d.HDI3		= HDI3;		d.HDI4	=HDI4;
	d.HDI12		= HDI12;		d.HDI13		= HDI13;		d.HDI23		= HDI23;
	d.comp1		= comp1;	d.comp2		= comp2;	d.comp3		= comp3;
	d.comp12	= comp12;	d.comp13	= comp13;	d.comp23	= comp23;
	d.xlbl1		= xlbl1;	d.xlbl2		= xlbl2;	d.xlbl3		= xlbl3;
	d.xlbl13	= xlbl13;	d.xlbl12	= xlbl12;	d.xlbl23	= xlbl23;
	pa_datadir;
	save allxsiranalysis d param samp
	
else
	load allxsiranalysis
	load petancova
	
end

%% Get default image values
[col,img,indx,nindx,p,fname] = getdefimg;

%% Regions of interest
[~,uroi,nroi] = getroi(data);

%% Brain
if ~loadbrainflag
	braincontour = getbraincontour(data,p,fname,img);
else
	load braincontour;
end

%% Analysis
% b0flag		= true;
b1flag		= true;
b2flag		= true;
b3flag		= true;
b4flag		= true;
b1b2flag	= true;
b0flag		= false;
b1flag		= false;
b2flag		= false;
b3flag		= false;
% b4flag		= false;
b1b2flag	= false;

crit		= 3;
% keyboard
%% Main factor group
close all
clc
% keyboard
%%
if b1flag
	braingraph(data,d.D1,d.comp1,d.BF1,d.xlbl1,img,braincontour,uroi,nroi,crit,indx,nindx,col,100)
end

%% Main factor stimulus
if b2flag
	braingraph(data,d.D2,d.comp2,d.BF2,d.xlbl2,img,braincontour,uroi,nroi,crit,indx,nindx,col,200)
end

%% Main factor laterality
if b3flag
	braingraph(data,d.D3,d.comp3,d.BF3,d.xlbl3,img,braincontour,uroi,nroi,crit,indx,nindx,col,300)
end

%% Interaction factor
if b1b2flag
	braingraph(data,d.D12,d.comp12,d.BF12,d.xlbl12,img,braincontour,uroi,nroi,crit,indx,nindx,col,500)
end

%% Interaction factor
if b1b2flag
	braingraph(data,d.D13,d.comp13,d.BF13,d.xlbl13,img,braincontour,uroi,nroi,crit,indx,nindx,col,600)
end

%% Interaction factor
if b1b2flag
	braingraph(data,d.D23,d.comp23,d.BF23,d.xlbl23,img,braincontour,uroi,nroi,crit,indx,nindx,col,700)
end

%% Main factor phoneme score
if b4flag
	braingraph2(data,d.D4,(1:3)',d.BF4,x2names,img,braincontour,uroi,nroi,crit,indx,nindx,col,400)
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

%%
% keyboard

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

function [roi,uroi,nroi] = getroi(data)
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
	a{ii}	= b(1:end-2);
end
roi		= a;
uroi	= unique(roi);
nroi	= numel(uroi);

function braincontour = getbraincontour(data,p,fname,img)
roifiles	= [data.roi];
img			= roicolourise(p,fname,roifiles,ones(length(roifiles),1),zeros(size(img)));
IMG			= [];
for zIndx = 1:nindx
	tmp		= squeeze(img(:,:,indx(zIndx)));
	IMG		= [IMG;tmp];
end
whos IMG
braincontour = IMG;
pa_datadir
save braincontour braincontour

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
	'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + a3[x3[i]] + a1a2[x1[i],x2[i]] + a1a3[x1[i],x3[i]] + a2a3[x2[i],x3[i]] + (b4[x2[i]])*xMet[i]\r\n',...
	'\t#Missing values\r\n',...
	'\t\t\tx1[i] ~ dnorm(mux1,taux1)\r\n',...
	'\t\t\tx2[i] ~ dnorm(mux2,taux2)\r\n',...
	'\t\t\tx3[i] ~ dnorm(mux3,taux3)\r\n',...
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
	'\tfor ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\tb4[j2] ~ dnorm(0.0,lambdaMetI)\r\n',...
	'\t} \r\n',...
	'\tlambdaMetI ~ dchisqr(1)\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\ta1a2[j1,j2] ~ dnorm(0.0,lambda12)\r\n',...
	'\t} }\r\n',...
	'\tlambda12 ~ dchisqr(1)\r\n',...
	' \r\n',...
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
	'\t# Convert a0,a1[],a2[],a1a2[,],etc to sum-to-zero b0,b1[],b2[],b1b2[,], etc :\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\tm[j1,j2,j3] <- a0 + a1[j1] + a2[j2]  + a3[j3] + a1a2[j1,j2] + a1a3[j1,j3] + a2a3[j2,j3]  \r\n',...
	'\t} } }\r\n',...
	'\tb0 <- mean( m[1:Nx1Lvl,1:Nx2Lvl,1:Nx3Lvl] )\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { b1[j1] <- mean( m[j1,1:Nx2Lvl,1:Nx3Lvl] ) - b0 }\r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) { b2[j2] <- mean( m[1:Nx1Lvl,j2,1:Nx3Lvl] ) - b0 }\r\n',...
	'\tfor ( j3 in 1:Nx3Lvl ) { b3[j3] <- mean( m[1:Nx1Lvl,1:Nx2Lvl,j3] ) - b0 }\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\tb1b2[j1,j2] <- mean( m[j1,j2,1:Nx3Lvl] ) - ( b0 + b1[j1] + b2[j2] + mean( b3[1:Nx3Lvl] ))  \r\n',...
	'\t} }\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\tb1b3[j1,j3] <- mean( m[j1,1:Nx2Lvl,j3] ) - ( b0 + b1[j1] + mean( b2[1:Nx2Lvl]) + b3[j3]  )  \r\n',...
	'\t} }\r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\tb2b3[j2,j3] <- mean( m[1:Nx1Lvl,j2,j3] ) - ( b0 + mean( b1[1:Nx1Lvl]) + b2[j2] + b3[j3]  )  \r\n',...
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
	'\t}\r\n',...
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
	'\t# Convert a0,a1[],a2[],a1a2[,],etc to sum-to-zero b0,b1[],b2[],b1b2[,], etc :\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\tmprior[j1,j2,j3] <- a0prior + a1prior[j1] + a2prior[j2]  + a3prior[j3] + a1a2prior[j1,j2] + a1a3prior[j1,j3] + a2a3prior[j2,j3]  \r\n',...
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
			r2c2 = [char(64+ltr) '2']
			r3c2 = [char(64+ltr) '3']
		else
			ltr = ltr-26;
			r2c2 = ['A' char(64+ltr) '2']
			r3c2 = ['A' char(64+ltr) '3']
		end
		ltr = 3+(ii-1)*3;
		
		if ltr<27
			r2c3 = [char(64+ltr) '2']
			r3c3 = [char(64+ltr) '3']
		else
			ltr = ltr-26;
			r2c3 = ['A' char(64+ltr) '2']
			r3c3 = ['A' char(64+ltr) '3']
		end
		xlswrite('tablexsirall',xnames(ii),sheet,r1c1);
		xlswrite('tablexsirall',{'Brain region'},sheet,r2c1);
		xlswrite('tablexsirall',uroi(selbf(:,ii)),sheet,r3c1);
		xlswrite('tablexsirall',{'Beta (2.5-97.5%)'},sheet,r2c2);
		a = round(p(selbf(:,ii),ii)*10)/10;
		b = round(HDI(selbf(:,ii),1,ii)'*10)/10;
		c = round(HDI(selbf(:,ii)',2,ii)*10)/10;
		str = cell(sum(selbf(:,ii)),1);
		for jj = 1:sum(selbf(:,ii))
			str{jj} = [num2str(a(jj)) ' (' num2str(b(jj)) '-' num2str(c(jj)) ')'];
		end
		xlswrite('tablexsirall',str,sheet,r3c2);
		xlswrite('tablexsirall',{'Bayes factor'},sheet,r2c3);
		xlswrite('tablexsirall',round(bf(selbf(:,ii),ii)),sheet,r3c3);
	end
end
