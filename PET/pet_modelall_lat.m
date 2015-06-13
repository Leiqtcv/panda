function pet_modelall_lat
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
loadflag		= false;
loadbrainflag	= true;
if ~loadflag
	if true
		createmodel(model);
	end
	%% THE DATA.
	% Load the data:
	pa_datadir;
	load('petancova')
	% 	roi = [data.roi]';
	% 	a	= roi;
	% 	s	= a;
	% 	na	= numel(a);
	% 	for ii = 1:na
	% 		b		= a{ii};
	% 		b		= b(5:end-8);
	% 		sel		= strfind(b,'_');
	% 		b(sel)	= ' ';
	% 		s{ii}	= b(end); % side
	% 		a{ii}	= b(1:end-2);
	% 	end
	% 	roi		= a;
	% 	uroi	= unique(roi);
	% % 	uside	= unique(s);
	% % 	sel		= strcmp(s,'L') | strcmp(s,'R');
	% 	nroi	= numel(uroi);
	% 	% 	[char(roi) num2str(sel)] % only vermis is not LR
	
	[roi,uroi,nroi] = getroi(data);
% 	param		= struct([]);
% paramb0
		paramb0	= NaN(nroi,1);
		paramb1	= NaN(nroi,3);
		paramb2	= NaN(nroi,3);
		paramb3	= NaN(nroi,2);
		paramb1b2	= NaN(nroi,3,3);
		paramb4	= NaN(nroi,3);
		parammetM	= NaN(nroi,1);
		
	dataStruct	= struct('y',[],'x1',[],'x2',[],'x3',[]);
% 	BF			= struct([]);
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
		
		xMet		=	[data(selroi).phoneme];
		xMet(1:5,:)	= NaN;
		xMet		= repmat(xMet,5,1); % phoneme score
		xMet		= xMet(:);
		
		x3			= ones(size(y));
		ny			= numel(y);
		x3(ny/2+1:end) = 2;
		

		% check
		% 		sel = x3==1;	[sum(sel) sum(~sel)	]
		
		%% Selection
		sel		= ismember(x1,1:3) & ismember(x2,1:3);
		y		= y(sel);
		x1		= x1(sel); % 'Pre-implant','Post-implant','NH'
		x2		= x2(sel); % 'Rest','Video','AV'
		xMet	= xMet(sel);
		x3		= x3(sel);
		
		xMet	= pa_logit(xMet/100); % convert to -inf to + inf scale
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
		
		a0			= nanmean(y);
		a1			= accumarray(x1,y,[],@nanmean)-a0;
		a2			= accumarray(x2,y,[],@nanmean)-a0;
		a3			= accumarray(x3,y,[],@nanmean)-a0;
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
		dataStruct.x3		= x3;
		dataStruct.xMet		= zMet;
		dataStruct.Ntotal	= Ntotal;
		dataStruct.Nx1Lvl	= Nx1Lvl;
		dataStruct.Nx2Lvl	= Nx2Lvl;
		dataStruct.Nx3Lvl	= Nx3Lvl;
		
		%% INTIALIZE THE CHAINS.
		a0			= nanmean(dataStruct.y);
		a1			= accumarray(dataStruct.x1,dataStruct.y,[],@nanmean)-a0;
		a2			= accumarray(dataStruct.x2,dataStruct.y,[],@nanmean)-a0;
		a3			= accumarray(dataStruct.x3,dataStruct.y,[],@nanmean)-a0;
		nChains		= 5;
		initsStruct = struct([]);
		for ii = 1:nChains
			initsStruct(ii).a0			= a0;
			initsStruct(ii).a1			= a1;
			initsStruct(ii).a2			= a2;
			initsStruct(ii).a3			= a3;
			initsStruct(ii).a1a2		= a1a2;
			initsStruct(ii).b4		= zeros(3,1);
			initsStruct(ii).a0prior		= a0;
			initsStruct(ii).a1prior		= a1;
			initsStruct(ii).a2prior		= a2;
			initsStruct(ii).a3prior		= a3;
			initsStruct(ii).a1a2prior	= a1a2;
			initsStruct(ii).sigma		= nanstd(dataStruct.y)/2; % lazy
			initsStruct(ii).b4prior	= zeros(3,1);
		end
		
		%% RUN THE CHAINS
		parameters		= {'b0','b1','b2','b3','b1b2','b4',...
			'b4prior','b0prior','b1prior','b2prior','b3prior','b1b2prior',...
			'sigma','lambda0','lambda1','lambda2','lamdaMet','mu'}; % The parameter(s) to be monitored.
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
		b3			= reshape(samples.b3,nChains*chainLength,Nx3Lvl);
		b1b2		=  reshape(samples.b1b2,nChains*chainLength,Nx1Lvl,Nx2Lvl);
		b4		= reshape(samples.b4,nChains*chainLength,Nx2Lvl);
		mu			= samples.mu;
		
		b1prior		= reshape(samples.b1prior,nChains*chainLength,Nx1Lvl);
		b2prior		= reshape(samples.b2prior,nChains*chainLength,Nx2Lvl);
		b3prior		= reshape(samples.b3prior,nChains*chainLength,Nx3Lvl);
		b1b2prior	= reshape(samples.b1b2prior,nChains*chainLength,Nx1Lvl,Nx2Lvl);
		b4prior	= reshape(samples.b4prior,nChains*chainLength,Nx2Lvl);
		
		% Convert from standardized b values to original scale b values:
		b0			= b0*ySDorig + yMorig;
		% 		b0			= b0*ySDorig + yMorig +metM;
		b1			= b1*ySDorig;
		b2			= b2*ySDorig;
		b3			= b3*ySDorig;
		b1b2		= b1b2*ySDorig;
		b4		= b4*ySDorig/metSD;
		
		b1prior		= b1prior*ySDorig;
		b2prior		= b2prior*ySDorig;
		b3prior		= b3prior*ySDorig;
		b1b2prior	= b1b2prior*ySDorig;
		b4prior	= b4prior*ySDorig/metSD;
		
		%% Save
		% Averages
		paramb0(roiIdx,:)	= nanmean(b0);
		paramb1(roiIdx,:)	= nanmean(b1);
		paramb2(roiIdx,:)	= nanmean(b2);
		paramb3(roiIdx,:)	= nanmean(b3);
		paramb1b2(roiIdx,:,:)	= squeeze(nanmean(b1b2));
		paramb4(roiIdx,:)	= squeeze(nanmean(b4));
		parammetM(roiIdx)	= metM;
		
		% Samples
		samp(roiIdx).b0		= b0;
		samp(roiIdx).b1		= b1;
		samp(roiIdx).b2		= b2;
		samp(roiIdx).b3		= b3;
		samp(roiIdx).b1b2	= b1b2;
		samp(roiIdx).b4		= b4;
		samp(roiIdx).mu		= mu;
% 			keyboard
		%% Hypothesis testing
		% nominal comparisons
		[bf,comp1]		= getcomparisons(b1,b1prior); % Main factor group
		BF1(roiIdx,:)	= bf;

		[bf,comp2]		= getcomparisons(b2,b2prior); % Main factor stimulus
		BF2(roiIdx,:)	= bf;

		[bf,comp3]		= getcomparisons(b3,b3prior); % Main factor: lateralization
		BF3(roiIdx,:)	= bf;

		% metric comparison to 0
		bf				= get0comparisons(b4,b4prior); % Main factor phoneme score
		BF4(roiIdx,:)	= bf;

		% Interaction effects
		[bf,comp12]		= getcomparisons(b1b2,b1b2prior); % Main factor group
		BF12(roiIdx,:)	= bf;
		
	end
	
	param.b0 = paramb0; param.b1 = paramb1;	param.b2 = paramb2;	param.b3 = paramb3;
	param.b4 = paramb4;	param.b1b2 = paramb1b2;	param.metM	= parammetM;
	pa_datadir
	save allanalysis BF1 BF2 BF3 BF4 BF12 param samp comp1 comp2 comp3 comp12
	
else
	load allanalysis
	load petancova
	
end

%% Labels
x1names	= {'Pre-implant','Post-implant','Normal-hearing'};
x2names	= {'Rest','Video','Audio-Video'};
x3names	= {'Left','Right'};

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
b0flag		= true;
b1flag		= true;
b2flag		= true;
b3flag		= true;
b4flag		= true;
b1b2flag	= true;
% b0flag		= false;
% b1flag		= false;
% b2flag		= false;
% b3flag		= false;
% b4flag		= false;
% b1b2flag	= false;

crit		= 3;
% keyboard
%% Main factor group
close all
clc
%%
if b1flag
	braingraph(data,param.b1,comp1,BF1,x1names,img,braincontour,uroi,nroi,crit,indx,nindx,col,100)
end

%% Main factor stimulus
if b2flag
	braingraph(data,param.b2,comp2,BF2,x2names,img,braincontour,uroi,nroi,crit,indx,nindx,col,200)
end

%% Main factor laterality
if b3flag
	braingraph(data,param.b3,comp3,BF3,x3names,img,braincontour,uroi,nroi,crit,indx,nindx,col,300)
end

% %% Interaction factor
% xlabel = {'Pre Rest','Post Rest','NH Rest','Pre Video','Post Video','NH Video','Pre AV','Post AV','NH AV'}
% if b1b2flag
% 	braingraph(data,param.b1b2,comp12,BF12,xlabel,img,braincontour,uroi,nroi,crit,indx,nindx,col)
% end

%% Main factor phoneme score
% braingraph2(data,b,comp,BF01,xlabel,img,braincontour,uroi,nroi,crit,indx,nindx,col,basefig)
if b4flag
	braingraph2(data,param.b4,(1:3)',BF4,x2names,img,braincontour,uroi,nroi,crit,indx,nindx,col,400)
end
	
%%
keyboard
return
%%
% write to table
pa_datadir;
selbf	= 1./[BF.q1]>=crit;
if sum(selbf)
	a	= [data(selbf).roi]';
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
	xlswrite('tableall',a,1,'A2');
	xlswrite('tableall',s,1,'B2');
	p	= NaN(nroi,2);
	for ii = 1:nroi
		p(ii,1)		= param(ii).b1(1);
		p(ii,2)		= param(ii).b1(2);
	end
	p	= p(:,2)-p(:,1);
	xlswrite('tableall',round(p(selbf)*10)/10,1,'C2');
	xlswrite('tableall',round(1./[BF(selbf).q1]'),1,'D2');
end
xlswrite('tableall',{'Brain region'},1,'A1');
xlswrite('tableall',{'Side'},1,'B1');
xlswrite('tableall',{'Beta'},1,'C1');
xlswrite('tableall',{'BF_{10}'},1,'D1');

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

a		= samp(selroi).b4;
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

gain	=  param(selroi).b4(stmIdx);
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
	'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + a3[x3[i]] + a1a2[x1[i],x2[i]] + (b4[x2[i]])*xMet[i]\r\n',...
	'\t#Missing values\r\n',...
	'\t\t\tx1[i] ~ dnorm(mux1,taux1)\r\n',...
	'\t\t\tx2[i] ~ dnorm(mux2,taux2)\r\n',...
	'\t\t\tx3[i] ~ dnorm(mux3,taux3)\r\n',...
	'\t\t\txMet[i] ~ dnorm(muxMet,tauxMet)\r\n',...
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
	'\tfor (j3 in 1:Nx3Lvl) {a3[j3] ~ dnorm(0.0,lambda3) }\r\n',...
	'\tlambda3 ~ dchisqr(1)\r\n',...
	'\t#\r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\tb4[j2] ~ dnorm(0.0,lambdaMetI)\r\n',...
	'\t}\r\n',...
	'\tlambdaMetI ~ dchisqr(1)\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\ta1a2[j1,j2] ~ dnorm(0.0,lambda12)\r\n',...
	'\t} }\r\n',...
	'\tlambda12 ~ dchisqr(1)\r\n',...
	' \r\n',...
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
	'\t# Convert a0,a1[],a2[],a1a2[,] to sum-to-zero b0,b1[],b2[],b1b2[,] :\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\tm[j1,j2,j3] <- a0 + a1[j1] + a2[j2]  + a3[j3] + a1a2[j1,j2]  \r\n',...
	'\t} } }\r\n',...
	'\tb0 <- mean( m[1:Nx1Lvl,1:Nx2Lvl,1:Nx3Lvl] )\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { b1[j1] <- mean( m[j1,1:Nx2Lvl,1:Nx3Lvl] ) - b0 }\r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) { b2[j2] <- mean( m[1:Nx1Lvl,j2,1:Nx3Lvl] ) - b0 }\r\n',...
	'\tfor ( j3 in 1:Nx3Lvl ) { b3[j3] <- mean( m[1:Nx1Lvl,1:Nx2Lvl,j3] ) - b0 }\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\tb1b2[j1,j2] <- mean( m[j1,j2,1:Nx3Lvl] ) - ( b0 + b1[j1] + b2[j2] + mean( b3[1:Nx3Lvl] ))  \r\n',...
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
	'\t# Convert a0,a1[],a2[],a1a2[,] to sum-to-zero b0,b1[],b2[],b1b2[,] :\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) { for ( j3 in 1:Nx3Lvl ) {\r\n',...
	'\t\tmprior[j1,j2,j3] <- a0prior + a1prior[j1] + a2prior[j2] + a3prior[j3] + a1a2prior[j1,j2]  \r\n',...
	'\t} } }\r\n',...
	'\tb0prior <- mean(mprior[1:Nx1Lvl,1:Nx2Lvl,1:Nx3Lvl])\r\n',...
	'\tfor (j1 in 1:Nx1Lvl) {b1prior[j1] <- mean(mprior[j1,1:Nx2Lvl,1:Nx3Lvl] ) - b0prior }\r\n',...
	'\tfor (j2 in 1:Nx2Lvl) {b2prior[j2] <- mean(mprior[1:Nx1Lvl,j2,1:Nx3Lvl] ) - b0prior }\r\n',...
	'\tfor (j3 in 1:Nx3Lvl) {b3prior[j3] <- mean(mprior[1:Nx1Lvl,1:Nx2Lvl,j3] ) - b0prior }\r\n',...
	'\tfor (j1 in 1:Nx1Lvl) {for ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\tb1b2prior[j1,j2] <- mean( mprior[j1,j2,1:Nx3Lvl] ) - ( b0prior + b1prior[j1] + b2prior[j2]+ mean( b3prior[1:Nx3Lvl] ) )  \r\n',...
	'\t} }\r\n',...
	'}\r\n',...
	];
% Write the modelString to a file, using Matlab commands:
pa_datadir;
fid			= fopen(model,'w');
fprintf(fid,str);
fclose(fid);

function [bf,indx] = getcomparisons(b,bprior)
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
for cIdx = 1:ncomp
	H1	= b(:,indx(cIdx,1))-b(:,indx(cIdx,2));
	H0	= bprior(:,indx(cIdx,1))-bprior(:,indx(cIdx,2));
	bf(cIdx)	= pa_bayesfactor(H1,H0);
end

function bf = get0comparisons(b,bprior)
[~,ncomp]	= size(b); % number of factors
bf = NaN(1,ncomp);
for cIdx = 1:ncomp
	H1	= b(:,cIdx);
	H0	= bprior(:,cIdx);
	bf(cIdx)	= pa_bayesfactor(H1,H0);
end

function braingraph(data,b,comp,BF01,xlabel,img,braincontour,uroi,nroi,crit,indx,nindx,col,basefig)
% 	comp	= comp1;
BF		= 1./BF01;
ncomp	= size(comp,1);
% 	xlabel	= x1names;

for cIdx = 1:ncomp
	disp('Analyze');
	img		= zeros(size(img));
	mu		= struct([]);
	beta	= NaN(nroi,1);
	for roiIdx = 1:nroi
		indx1 = comp(cIdx,1);
		indx2 = comp(cIdx,2);
		beta(roiIdx) = b(roiIdx,indx1)-b(roiIdx,indx2);
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
	caxis([-10 10]);
	colorbar;
	set(gca,'YDir','normal');
	axis off;
	str = [xlabel{indx1} '-' xlabel{indx2}];
	title(str);
	str = [mfilename str];
	pa_datadir;
	print('-depsc','-painter',str);
	drawnow
end

function braingraph2(data,b,comp,BF01,xlabel,img,braincontour,uroi,nroi,crit,indx,nindx,col,basefig)
% 	comp	= comp1;
BF		= 1./BF01;
ncomp	= size(comp,1);
% 	xlabel	= x1names;

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
	str = xlabel{cIdx};
	title(str);
	drawnow
	str = [mfilename 'phi' str];
	pa_datadir;
	print('-depsc','-painter',str);
end
