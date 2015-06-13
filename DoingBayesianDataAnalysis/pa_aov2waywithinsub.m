function pa_aov2waywithinsub(dataSource,checkConvergence)
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
if nargin<1
	dataSource = 'Ex19.3';
% 	dataSource = 'lidwien';
% 	dirSource = 'C:\DATA\ProgramsDoingBayesianDataAnalysis';
end
if nargin<2
	checkConvergence = false;
end
close all
model = 'aov2waywithinsub.txt';

%% THE MODEL.
if ~exist(model,'file')
	str = ['model {\r\n',...
		'\tfor ( i in 1:Ntotal ) {\r\n',...
		'\t\ty[i] ~ dnorm( mu[i] , tau )\r\n',...
		'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + a1a2[x1[i],x2[i]] + aS[S[i]]\r\n',...
		'\t}\r\n',...
		'\t#\r\n',...
		'\ttau <- pow( sigma , -2 )\r\n',...
		'\tsigma ~ dunif(0,10) # y values are assumed to be standardized\r\n',...
		'\t#\r\n',...
		'\ta0 ~ dnorm(0,0.001) # y values are assumed to be standardized\r\n',...
		'\t#\r\n',...
		'\tfor ( j1 in 1:Nx1Lvl ) { a1[j1] ~ dnorm( 0.0 , a1tau ) }\r\n',...
		'\ta1tau <- 1 / pow( a1SD , 2 )\r\n',...
		'\ta1SD <- abs( a1SDunabs ) + .1\r\n',...
		'\ta1SDunabs ~ dt( 0 , 0.001 , 2 )\r\n',...
		'\t#\r\n',...
		'\tfor ( j2 in 1:Nx2Lvl ) { a2[j2] ~ dnorm( 0.0 , a2tau ) }\r\n',...
		'\ta2tau <- 1 / pow( a2SD , 2 )\r\n',...
		'\ta2SD <- abs( a2SDunabs ) + .1\r\n',...
		'\ta2SDunabs ~ dt( 0 , 0.001 , 2 )\r\n',...
		'\t#\r\n',...
		'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
		'\t\t\ta1a2[j1,j2] ~ dnorm( 0.0 , a1a2tau )\r\n',...
		'\t} }\r\n',...
		'\ta1a2tau <- 1 / pow( a1a2SD , 2 )\r\n',...
		'\ta1a2SD <- abs( a1a2SDunabs ) + .1\r\n',...
		'\ta1a2SDunabs ~ dt( 0 , 0.001 , 2 )\r\n',...
		'\t#\r\n',...
		'\tfor ( jS in 1:NSLvl ) { aS[jS] ~ dnorm( 0.0 , aStau ) }\r\n',...
		'\taStau <- 1/pow(aSSD,2)\r\n',...
		'\taSSD <- abs(aSSDunabs)+.1\r\n',...
		'\taSSDunabs ~ dt(0,0.001,2)\r\n',...
		'}\r\n',...
		];
	
	% Write the modelString to a file, using Matlab commands:
	fid			= fopen('aov2waywithinsub.txt','w');
	fprintf(fid,str);
	fclose(fid);
end

%% THE DATA.
% Load the data:
if strcmp(dataSource,'Ex19.3')
	y		= [101,102,103,105,104, 104,105,107,106,108, 105,107,106,108,109, 109,108,110,111,112]';
	x1	= [1,1,1,1,1, 1,1,1,1,1, 2,2,2,2,2, 2,2,2,2,2]';
	x2	= [1,1,1,1,1, 2,2,2,2,2, 1,1,1,1,1, 2,2,2,2,2]';
	S		= [1,2,3,4,5, 1,2,3,4,5, 1,2,3,4,5, 1,2,3,4,5]';
	x1names	= {'x1.1','x1.2'};
	x2names	= {'x2.1','x2.2'};
	Snames	= {'S1','S2','S3','S4','S5'};
	Ntotal	= length(y);
	Nx1Lvl	= length(unique(x1));
	Nx2Lvl	= length(unique(x2));
	NSLvl		= length(unique(S));
	x1contrast = [-1,1];
	x2contrast = [-1,1];
	x1x2contrast = []; % list( matrix( 1:(Nx1Lvl*Nx2Lvl) , nrow=Nx1Lvl ) )
end

if strcmp(dataSource,'lidwien')
	pa_datadir
	
	N = xlsread('lidwien.xls');
	% subject = N(:,1);
	% cond = N(:,3);
	% group = N(:,2);
	% setup = N(:,4);
	% SNR = N(:,6);
	
	y			= [N(:,5);N(:,6)];
	x1			= N(:,3); % condition
	[~,~,x1]	= unique(x1);
	x1			= [x1;x1];
	x2			= N(:,4); % task
	[~,~,x2]	= unique(x2);
	x2			= [x2;x2];
	S			= N(:,1);
	S			= [S;S];
	x1names	= {'CI','CI&HA','CI&AGC'};
	x2names	= {'S0N90 Stationary','S0N90 Speech','S0NCI Speech','S0NHA Speech'};
	Snames	= {'S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','S11','S12','S13','S14','S15'};
	Ntotal	= length(y);
	Nx1Lvl	= length(unique(x1));
	Nx2Lvl	= length(unique(x2));
	NSLvl		= length(unique(S));
	x1contrast = [-1,1,0;-1,0,1;0,-1,1;];
	x2contrast = [-1,1/3,1/3,1/3;0,-1,1,0;0,-1,0,1;];
	x1x2contrast = reshape(1:Nx1Lvl*Nx2Lvl,Nx1Lvl,Nx2Lvl) % list( matrix( 1:(Nx1Lvl*Nx2Lvl) , nrow=Nx1Lvl ) )
	
	M = [-2 -1 -1;2 4 4;4 2 2;0 2 2]/1.5;
	
	col = pa_statcolor(64,[],[],[],'def',8);
	figure(666)
	colormap(col);
	subplot(131)
	imagesc(M)
	colorbar
	caxis([-3 3])
	axis square
	set(gca,'YDir','reverse','XTick',1:3,'XTickLabel',x1names,'YTick',1:4,'YTickLabel',x2names)
	title('Prediction');
end

[z,yMorig,ySDorig] = zscore(y);
% [yMorig ySDorig]

% yMorig = 0;
% ySDorig = 5;
% z = (y-yMorig)/ySDorig;
% return
dataStruct.y		= z;
dataStruct.x1		= x1;
dataStruct.x2		= x2;
dataStruct.S		= S;
dataStruct.Ntotal	= Ntotal;
dataStruct.Nx1Lvl	= Nx1Lvl;
dataStruct.Nx2Lvl	= Nx2Lvl;
dataStruct.NSLvl	= NSLvl;

%% INTIALIZE THE CHAINS.
a0			= mean(dataStruct.y);
a1			= accumarray(dataStruct.x1,dataStruct.y,[],@mean)-a0;
a2			= accumarray(dataStruct.x2,dataStruct.y,[],@mean)-a0;
aS			= accumarray(dataStruct.S,dataStruct.y,[],@mean)-a0;
[A1,A2]		= meshgrid(a1,a2);
linpred		= A1'+A2'+a0;
a1a2		= accumarray([dataStruct.x1 dataStruct.x2],dataStruct.y,[],@mean)-a0-linpred;
figure(666)
subplot(132)
imagesc((linpred+a1a2)')
colorbar
caxis([-3 3])
axis square
set(gca,'YDir','reverse','XTick',1:3,'XTickLabel',x1names,'YTick',1:4,'YTickLabel',x2names)
title('Likelihood');
% return
% keyboard
nChains		= 5;
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).a0		= a0;
	initsStruct(ii).a1		= a1;
	initsStruct(ii).a2		= a2;
	initsStruct(ii).aS		= aS;
	initsStruct(ii).a1a2	= a1a2;
	initsStruct(ii).sigma	= std(dataStruct.y)/2; % lazy
	initsStruct(ii).a1SDunabs	= std(a1);
	initsStruct(ii).a2SDunabs	= std(a2);
	initsStruct(ii).a1a2SDunabs	= std(a1a2(:));
	initsStruct(ii).aSSDunabs	= std(aS);
end

%% RUN THE CHAINS
parameters		= {'a0','a1','a2','a1a2','aS','sigma','a1SD','a2SD','a1a2SD','aSSD'};	% The parameter(s) to be monitored.
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
a1a2SDSample	= samples.a1a2SD(:);
aSSDSample		= samples.aSSD(:);

figure(1);
subplot(231)
plotPost(sigmaSample,'xlab','sigma','main','Cell SD','showMode',true);
subplot(232)
plotPost(a1SDSample,'xlab','a1SD','main','a1 SD','showMode',true);
subplot(233)
plotPost(a2SDSample,'xlab','a2SD','main','a2 SD','showMode',true)
subplot(234)
plotPost(a1a2SDSample,'xlab','a1a2SD','main','Interaction SD','showMode',true);
subplot(235)
plotPost(aSSDSample,'xlab','aSSD','main','aS SD','showMode',true)

% Extract a values:
a0Sample	= samples.a0(:);
chainLength = length(samples.a0);
a1Sample	= reshape(samples.a1,nChains*chainLength,Nx1Lvl);
a2Sample	= reshape(samples.a2,nChains*chainLength,Nx2Lvl);
a1a2Sample	= reshape(samples.a1a2,nChains*chainLength,Nx1Lvl,Nx2Lvl);
aSSample	= reshape(samples.aS,nChains*chainLength,NSLvl);


% Convert the a values to zero-centered b values.
% m12Sample is predicted cell means at every step in MCMC chain:
nSamples	= nIter*nChains;
m12Sample	= NaN(nSamples,Nx1Lvl,Nx2Lvl,NSLvl);
for stepIdx = 1:nSamples
	for a1idx = 1:Nx1Lvl
		for a2idx = 1:Nx2Lvl
			for aSidx = 1:NSLvl
				m12Sample(stepIdx,a1idx,a2idx,aSidx) = a0Sample(stepIdx)+a1Sample(stepIdx,a1idx)+a2Sample(stepIdx,a2idx)+a1a2Sample(stepIdx,a1idx,a2idx)+aSSample(stepIdx,aSidx);
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

% b1b2Sample is the interaction deflection, i.e., the difference
% between the cell means and the linear combination:
b1b2Sample = squeeze(mean(m12Sample-linpredSample,4));

%%
pred = squeeze(mean(squeeze(mean(linpredSample,4))+b1b2Sample,1));
predsd = 1./(squeeze(std(squeeze(mean(linpredSample,4))+b1b2Sample)).^2);
predsd = round(predsd-min(predsd(:)))+1
figure(666)
subplot(133)
imagesc(pred')
hold on
for ii = 1:3
	for jj = 1:4
		plot(ii,jj,'s','MarkerFaceColor','w','MarkerEdgeColor','k','MarkerSize',predsd(ii,jj));
	end
end
colorbar
caxis([-3 3])
axis square
set(gca,'YDir','reverse','XTick',1:3,'XTickLabel',x1names,'YTick',1:4,'YTickLabel',x2names)
title('Posterior');

%%
% Convert from standardized b values to original scale b values:
b0Sample	= b0Sample*ySDorig + yMorig;
b1Sample	= b1Sample*ySDorig;
b2Sample	= b2Sample*ySDorig;
bSSample	= bSSample*ySDorig;
b1b2Sample	= b1b2Sample*ySDorig;

% Plot b values:
figure(2)
histinfo = plotPost(b0Sample,'xlab','\beta_0','main','Baseline');
figure(3)
for x1idx = 1:Nx1Lvl
	subplot(1,Nx1Lvl,x1idx)
	histinfo = plotPost(b1Sample(:,x1idx),'xlab','\beta_1','main',['x1:' x1names{x1idx}]);
end
figure(4)
for x2idx = 1:Nx2Lvl
	subplot(1,Nx2Lvl,x2idx)
	histinfo = plotPost(b2Sample(:,x2idx),'xlab','\beta_2','main',['x2:' x2names{x2idx}]);
end

figure(5)
for x1idx = 1:Nx1Lvl
	for x2idx = 1:Nx2Lvl
		subplot(Nx1Lvl,Nx2Lvl,(x1idx-1)*Nx2Lvl+x2idx)
		histinfo = plotPost(squeeze(b1b2Sample(:,x1idx,x2idx)),'xlab','\beta_{12}','main',['x1:' x1names{x1idx} ', x2:' x2names{x2idx}]);
	end
end
% return
% Display contrast analyses
nContrasts = size(x1contrast,1);
figure(6)
if nContrasts>0
	for cIdx = 1:nContrasts
		subplot(1,nContrasts,cIdx)
		contrast = x1contrast(cIdx,:);
		
		incIdx	= contrast~=0;
		d = [contrast*b1Sample']';
		histInfo = plotPost(d,'compVal',0,'xlab',[num2str(contrast(incIdx)) x1names{incIdx} '+' num2str(sum(incIdx)-1)],'main',['X1 Contrast:']);
	end
end

nContrasts = size(x2contrast,1);
figure(7)
if nContrasts>0
	for cIdx = 1:nContrasts
		subplot(1,nContrasts,cIdx)
		contrast = x2contrast(cIdx,:); % make it a row matrix
		incIdx	= contrast~=0;
		histInfo = plotPost([contrast*b2Sample']','compVal',0,'xlab',[num2str(contrast(incIdx)) x2names{incIdx} '+' num2str(sum(incIdx)-1)],'main',['X2 Contrast:']);
	end
end


nContrasts = size(x1x2contrast)
% if ( nContrasts > 0 ) {
%    nPlotPerRow = 5
%    nPlotRow = ceiling(nContrasts/nPlotPerRow)
%    nPlotCol = ceiling(nContrasts/nPlotRow)
%    openGraph(3.75*nPlotCol,2.5*nPlotRow)
%    layout( matrix(1:(nPlotRow*nPlotCol),nrow=nPlotRow,ncol=nPlotCol,byrow=T) )
%    par( mar=c(4,0.5,2.5,0.5) , mgp=c(2,0.7,0) )
%    for ( cIdx in 1:nContrasts ) {
%        contrast = x1x2contrastList[[cIdx]]
%        contrastArr = array( rep(contrast,chainLength) ,
%                             dim=c(NROW(contrast),NCOL(contrast),chainLength) )
%        contrastLab = ''
%        for ( x1idx in 1:Nx1Lvl ) {
%          for ( x2idx in 1:Nx2Lvl ) {
%            if ( contrast[x1idx,x2idx] != 0 ) {
%              contrastLab = paste( contrastLab , '+' ,
%                                   signif(contrast[x1idx,x2idx],2) ,
%                                   x1names[x1idx] , x2names[x2idx] )
%            }
%          }
%        }
%        histInfo = plotPost( apply( contrastArr * b1b2Sample , 3 , sum ) ,
%                 compVal=0  , xlab=contrastLab , cex.lab = 0.75 ,
%                 main=paste( names(x1x2contrastList)[cIdx] ) )
%    }
%    saveGraph(file=paste(fileNameRoot,'x1x2Contrasts',sep=''),type='eps')
% }
%
% %==============================================================================
% % Do NHST ANOVA:
%
% theData = data.frame( y=y , x1=factor(x1,labels=x1names) ,
%                             x2=factor(x2,labels=x2names) )
% openGraph(width=7,height=7)
% interaction.plot( theData$x1 , theData$x2 , theData$y , type='b' )
% saveGraph(file=paste(fileNameRoot,'DataPlot',sep=''),type='eps')
% aovresult = aov( y ~ x1 * x2 , data = theData )
% cat('\n------------------------------------------------------------------\n\n')
% print( summary( aovresult ) )
% cat('\n------------------------------------------------------------------\n\n')
% print( model.tables( aovresult , type = 'effects', se = TRUE ) , digits=3 )
% cat('\n------------------------------------------------------------------\n\n')
%
% %==============================================================================
