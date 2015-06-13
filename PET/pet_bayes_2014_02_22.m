function pet_bayes_2014_02_22

%
% Bayesian ANCOVA on PET data
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij


% Check
% vermis
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
names.x1	= {'Deaf','Normal-hearing'};
names.x2	= {'Pre','Post'}; % NaN
names.x3	= {'No video','Video'};
names.x4	= {'No audio','audio'};
names.x5	= {'Left','Right'};
names.x6	= {'R','V','AV'};

if ~loadflag
	%% THE DATA.
	% Load the data:
	pa_datadir;
	load('petancova'); % from KNO_PET_MEANROIDATA
	[roi,uroi,nroi] = getroi(data);
	stats = struct('b0',[]);

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
		x6 = x3;
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
		xMet		= pa_logit(xMet/100); % convert to -inf to + inf scale
		
		% Combine
		x			= [x1 x2 x3 x4 x5 x6];
		
		% Selection
		sel		= isnan(y);
		y		= y(~sel);
		x		= x(~sel,:);
		xMet	= xMet(~sel);
		
		sel		= y<mean(y)-30; % remove unlikely FDG values, i.e. because of poor scan view
		y		= y(~sel);
		x		= x(~sel,:);
		xMet	= xMet(~sel);
		
		% Normalize, for JAGS MCMC sampling, e.g. to use cauchy(0,1) prior
		[z,yMorig,ySDorig]	= pa_zscore(y');
		[zMet,~,metSD]		= pa_zscore(xMet');
		
		%% Model
		Nnom = 5;
		% 		xmet = [3 4];
		% 		Nmet = numel(xmet);
		% 		createmodel(model,Nnom,xmet)
		Nmet = 1;
		xmet(1).Nom = [3 4];
		pa_bayes_modeldata(model,Nnom,Nmet, xmet)
		%% Data
		dataStruct = dataconstruct(y,z,zMet,x,Nnom);
		
		%%
% 		keyboard
		%% Initialize chains
		nChains		= 4;
		initsStruct = initconstruct(dataStruct,xmet,Nnom,nChains);
	
		%% Run sampling chains
		parameters		= {'b0','b1','b2','b3','b4','b5',...
			'bMet1','bMet0'...
			'b0prior','b1prior','b2prior','b3prior','b4prior','b5prior',...
			'bMet1prior','bMet0prior'...
			}; % The parameter(s) to be monitored.
		burnInSteps		= 2000;		% Number of steps to 'burn-in' the samplers.
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
		
		% 	check_sampling;

		%% EXAMINE THE RESULTS
		% Extract b values,
		% and convert from standardized b values to original scale b values:
		% b1 = reshape(b1,nCHains*chainLength,Nx1Level)*ySDorig
		samples = betaconvert(samples,dataStruct,Nnom,Nmet,xmet,ySDorig,yMorig,metSD,nChains);
		
		%% Statistics
		% Averages
		stats.b0(roiIdx).mu		= nanmean(samples.b0);
		for idx = 1:Nnom
			stats.(['b' num2str(idx)])(roiIdx).mu = nanmean(samples.(['b' num2str(idx)]));
		end
		stats.bMet0(roiIdx).mu	= nanmean(samples.bMet0);
		for idx = 1:Nmet
			stats.(['bMet' num2str(idx)])(roiIdx).mu = nanmean(samples.(['bMet' num2str(idx)]));
		end
		
		% Hypothesis testing
		% nominal comparisons
		for idx = 1:Nnom
			[db,bf,comp,xlbl,hd]	= getcomparisons(samples.(['b' num2str(idx)]),samples.(['b' num2str(idx) 'prior']),names.(['x' num2str(idx)])); % Main factor group
			stats.(['b' num2str(idx)])(roiIdx).Diff	= mean(db);
			stats.(['b' num2str(idx)])(roiIdx).BF		= bf;
			stats.(['b' num2str(idx)])(roiIdx).comp	= comp;
			stats.(['x' num2str(idx)])(roiIdx).label	= xlbl;
			stats.(['b' num2str(idx)])(roiIdx).HDI	= hd;
		end
		
		% Metric comparisons
% 				keyboard

		for idx = 1:Nmet
			b = samples.(['bMet' num2str(idx)]);
			bprior = samples.(['bMet' num2str(idx)]);
			b = squeeze(b(:,2,:));
			bprior = squeeze(bprior(:,2,:));
			
			[db,bf,comp,xlbl,hd]	= getcomparisons(b,bprior,names.x4); % Main factor group
			xlbl
			stats.(['bMet' num2str(idx)])(roiIdx).Diff	= mean(db);
			stats.(['bMet' num2str(idx)])(roiIdx).BF		= bf;
			stats.(['bMet' num2str(idx)])(roiIdx).comp	= comp;
			stats.(['xMet' num2str(idx)])(roiIdx).label	= xlbl;
			stats.(['bMet' num2str(idx)])(roiIdx).HDI		= hd;
		end
			
		[db,bf,hd]		= get0comparisons(samples.bMet0,samples.bMet0prior); % Main factor phoneme score
		idx = 0;
		stats.(['bMet' num2str(idx)])(roiIdx).mu	= mean(db);
		stats.(['bMet' num2str(idx)])(roiIdx).BF		= bf;
		stats.(['bMet' num2str(idx)])(roiIdx).HDI		= hd;
	end

	pa_datadir;
	save allxxxanalysis stats
	
else
	load allxxxanalysis
	load petancova
end

%% Get default image values
[col,img,indx,nindx,p,fname] = getdefimg;

% Regions of interest
[~,uroi,nroi] = getroi(data);

% Brain
if ~loadbrainflag
	[~,bcright] = getbraincontour(data,p,fname,img,indx,nindx);
else
	load braincontour;
end


crit		= 1;


% Main factor group
close all
clc
% keyboard
%%
keyboard

%%

braingraph0('Met0',data,stats,img,bcright,uroi,nroi,crit,indx,nindx,col)

%%

braingraph1('Met1',data,stats,img,bcright,uroi,nroi,crit,indx,nindx,col)
%%
for xIndx = 1:5
braingraph1(xIndx,data,stats,img,bcright,uroi,nroi,crit,indx,nindx,col)
end



%% Main factor phoneme score
	braingraph2(data,d.DMet0,1,d.BFMet0,x3names,img,bcright,uroi,nroi,crit,indx,nindx,col,1000)

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

% stats.diff			=  db;
% stats.bayesfactor	= bf;
% stats.indx			= indx;
% stats.xlbl			= xlbl;
% stats.HDI			= HDI;

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

function braingraph1(x,data,stats,img,braincontour,uroi,nroi,crit,indx,nindx,col)

%%
if isnumeric(x)
	basefig = x*100;
	x = num2str(x);
else
	basefig = int2str(x(end));
end
% braincontour = bcright;
str = ['b' x]
BF		= 1./[stats.(str).BF]';
b		= [stats.(str).Diff]';
xlabel	= [stats.(['x' x]).label];


ncomp	= size([stats.(['b' x]).comp],1);
for cIdx = 1:ncomp
	disp('Analyze');
	img		= zeros(size(img));
	mu		= struct([]);
	beta	= NaN(nroi,1);
	if ncomp == 1
		go = any(BF>=crit);
	else
		go = any(BF(:,cIdx)>=crit);
	end
	if go
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
		% 		roitextxy(roi,indx,nindx);
		
		str = [mfilename xlabel{cIdx}];
		
		pa_datadir;
		print('-depsc','-painter',str);
		drawnow
	end
end


function braingraph0(x,data,stats,img,braincontour,uroi,nroi,crit,indx,nindx,col)

%%
if isnumeric(x)
	basefig = x*100;
	x = num2str(x);
else
	basefig = int2str(x(end));
end
% braincontour = bcright;
str = ['b' x]
BF		= 1./[stats.(str).BF]';
b		= [stats.(str).mu]';


	disp('Analyze');
	img		= zeros(size(img));
	mu		= struct([]);
	beta	= NaN(nroi,1);
		go = any(BF>=crit);

	if go
		for roiIdx = 1:nroi
			beta(roiIdx)	= b(roiIdx);
			a				= BF(roiIdx)<crit;
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
		figure
		colormap(col);
		imagesc(IMG');
		hold on
		contour(repmat(braincontour',1,1),1,'k');
		axis equal
		caxis([-10 10]);
		colorbar;
		set(gca,'YDir','normal');
		axis off;
		roi = [data(beta~=0).roi];
		% 		roitextxy(roi,indx,nindx);
		
		str = [mfilename ];
		
		pa_datadir;
		print('-depsc','-painter',str);
		drawnow
	end
%%
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

function checksampling
%% Check Rhat for convergence
names = fieldnames(stats.Rhat);
names = names(1:9);
bgrstat = [];
for nameIdx = 1:9
	selrhat = any(any(squeeze(any(abs(stats.Rhat.(names{nameIdx})-1)>0.1))));
	bgrstat = [bgrstat selrhat];
end
if any(bgrstat)
	error('Rhat');
end

%% Check Auto-correlation for thinning
acflag = false;
if acflag
	figure(100)
	names = fieldnames(samples);
	names = names(1:9);
	for nameIdx = 1:9
		a = [samples.(names{nameIdx})];
		ndims(a)
		switch ndims(a)
			case 2
				a = a(1,:);
				[C,lags] = xcorr(a,30,'coeff');
				plot(lags,C,'-');
				xlim([0 30])
				title(C(32))
				drawnow
				if C(32)>0.4
					error('AC')
				end
			case 3
				a = squeeze(a(1,:,:));
				[~,m] = size(a);
				for mIdx = 1:m
					[C,lags] = xcorr(squeeze(a(:,mIdx)),30,'coeff');
					plot(lags,C,'-');
					xlim([0 30])
					title(C(32))
					drawnow
					if C(32)>0.4
						mIdx
						error('AC')
					end
				end
			case 4
				a = squeeze(a(1,:,:,:));
				[~,m,n] = size(a);
				for mIdx = 1:m
					for nIdx = 1:n
						[C,lags] = xcorr(squeeze(a(:,mIdx,nIdx)),30,'coeff');
						plot(lags,C,'-');
						xlim([0 30])
						title(C(32))
						drawnow
						if C(32)>0.4
							[mIdx nIdx]
							error('AC')
						end
					end
				end
			case 5
				a = squeeze(a(1,:,:,:,:));
				[~,m,n,o] = size(a);
				for mIdx = 1:m
					for nIdx = 1:n
						for oIdx = 1:o
							[C,lags] = xcorr(squeeze(a(:,mIdx,nIdx,oIdx)),30,'coeff');
							plot(lags,C,'-');
							xlim([0 30])
							title(C(32))
							if C(32)>0.4
								[mIdx nIdx oIdx]
								error('AC')
							end
							drawnow
						end
					end
				end
		end
		
		
	end
end

function  samples = betaconvert(samples,dataStruct,Nnom,Nmet,xmet,ySDorig,yMorig,metSD,nChains)
% Extract b values,
% and convert from standardized b values to original scale b values:
% b1 = reshape(b1,nCHains*chainLength,Nx1Level)*ySDorig


%%
chainLength			= length(samples.b0);
samples.b0			= samples.b0(:)*ySDorig + yMorig;
for idx = 1:Nnom
	samples.(['b' num2str(idx)]) = reshape(samples.(['b' num2str(idx)]),nChains*chainLength,dataStruct.(['Nx' num2str(idx) 'Lvl']))*ySDorig;
	samples.(['b' num2str(idx) 'prior']) = reshape(samples.(['b' num2str(idx) 'prior']),nChains*chainLength,dataStruct.(['Nx' num2str(idx) 'Lvl']))*ySDorig;
end
samples.bMet0		= reshape(samples.bMet0,nChains*chainLength,1)*ySDorig/metSD;
samples.bMet0prior	= reshape(samples.bMet0prior,nChains*chainLength,1)*ySDorig/metSD;
for idx = 1:Nmet
	
	samples.(['bMet' num2str(idx)]) = reshape(samples.(['bMet' num2str(idx)]),[nChains*chainLength,dataStruct.(['Nx' num2str(xmet(idx).Nom(1)) 'Lvl']),dataStruct.(['Nx' num2str(xmet(idx).Nom(2)) 'Lvl'])])*ySDorig/metSD;
	samples.(['bMet' num2str(idx) 'prior']) = reshape(samples.(['bMet' num2str(idx) 'prior']),[nChains*chainLength,dataStruct.(['Nx' num2str(xmet(idx).Nom(1)) 'Lvl']),dataStruct.(['Nx' num2str(xmet(idx).Nom(2)) 'Lvl'])])*ySDorig/metSD;
	
end

%%
function dataStruct = dataconstruct(y,z,zMet,x,Nnom)

dataStruct.y		= z';
dataStruct.xMet		= zMet;
dataStruct.Ntotal	= length(y);
for idx = 1:Nnom
	dataStruct.(['x' num2str(idx)])= x(:,idx);
	dataStruct.(['Nx' num2str(idx) 'Lvl'])	= length(unique(x(~isnan(x(:,idx)),idx)));
end

function initsStruct = initconstruct(dataStruct,xmet,Nnom,nChains)
initsStruct = struct([]);
for chain = 1:nChains
	initsStruct(chain).sigma	= nanstd(dataStruct.y)/2; % lazy
	initsStruct(chain).a0		= 0;
	
	% Only works for 2 nominal factors in Metric parameter
	initsStruct(chain).aMet1		= zeros(dataStruct.(['Nx' num2str(xmet(1).Nom(1)) 'Lvl'])	,dataStruct.(['Nx' num2str(xmet(1).Nom(2)) 'Lvl']));
	initsStruct(chain).aMet1prior	= zeros(dataStruct.(['Nx' num2str(xmet(1).Nom(1)) 'Lvl'])	,dataStruct.(['Nx' num2str(xmet(1).Nom(2)) 'Lvl']));
	initsStruct(chain).aMet0	= 0;
	initsStruct(chain).aMet0prior	= 0;
	
	for idx = 1:(Nnom)
		sel = isnan(dataStruct.(['x' num2str(idx)])) | isnan(dataStruct.y);
		initsStruct(chain).(['a' num2str(idx)])				= accumarray(dataStruct.(['x' num2str(idx)])(~sel),dataStruct.y(~sel),[],@nanmean);
		initsStruct(chain).(['a' num2str(idx) 'prior'])	= accumarray(dataStruct.(['x' num2str(idx)])(~sel),dataStruct.y(~sel),[],@nanmean);
	end
	
end