function ANOVAtwowayJAGSSTZ(dataSource,checkConvergence)
% ANOVATWOWAYJAGSSTZ
%
% Bayesian two-way anova
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

%% Clean
close all hidden
clc
% Specify data source:
if nargin<1
	dataSource = {'QianS2007','Salary','Random','Ex19.3'};
	dataSource = dataSource{2};
	dirSource = 'C:\Users\Marc van Wanrooij\Documents\R\ProgramsDoingBayesianDataAnalysis';
end
if nargin<2
	checkConvergence = false;
end

%% THE MODEL.

str = ['model {\r\n',...
	'\tfor ( i in 1:Ntotal ) {\r\n',...
	'\t\ty[i] ~ dnorm( mu[i] , tau )\r\n',...
	'\t\tmu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + a1a2[x1[i],x2[i]]\r\n',...
	'\t}\r\n',...
	' \r\n',...
	'\t#\r\n',...
	'\ttau <- 1 / pow( sigma , 2 )\r\n',...
	'\tsigma ~ dunif(0,10) # y values are assumed to be standardized\r\n',...
	'\t#\r\n',...
	'\ta0 ~ dnorm(0,0.001) # y values are assumed to be standardized\r\n',...
	'\t#\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { a1[j1] ~ dnorm( 0.0 , a1tau ) }\r\n',...
	'\ta1tau <- 1 / pow( a1SD , 2 )\r\n',...
	'\ta1SD ~ dgamma(1.01005,0.1005) # mode=0.1,sd=10.0\r\n',...
	'\t#\r\n',...
	'\tfor ( j2 in 1:Nx2Lvl ) { a2[j2] ~ dnorm( 0.0 , a2tau ) }\r\n',...
	'\ta2tau <- 1 / pow( a2SD , 2 )\r\n',...
	'\ta2SD ~ dgamma(1.01005,0.1005) # mode=0.1,sd=10.0\r\n',...
	'\t#\r\n',...
	'\tfor ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {\r\n',...
	'\t\ta1a2[j1,j2] ~ dnorm( 0.0 , a1a2tau )\r\n',...
	'\t} }\r\n',...
	'\ta1a2tau <- 1 / pow( a1a2SD , 2 )\r\n',...
	'\ta1a2SD ~ dgamma(1.01005,0.1005) # mode=0.1,sd=10.0\r\n',...
	' \r\n',...
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
	'}\r\n',...
	];

% Write the modelString to a file, using Matlab commands:
fid			= fopen('model.txt','w');
fprintf(fid,str);
fclose(fid);

return
%% THE DATA.


%
% % Load the data:
% if ( dataSource == 'QianS2007' ) {
%   fileNameRoot = paste( fileNameRoot , dataSource , sep='' )
%   datarecord = read.table( 'QianS2007SeaweedData.txt' , header=TRUE , sep=',' )
%   % Logistic transform the COVER value:
%   % Used by Appendix 3 of QianS2007 to replicate Ramsey and Schafer (2002).
%   datarecord.COVER = -log( ( 100 / datarecord.COVER ) - 1 )
%   y = as.numeric(datarecord.COVER)
%   x1 = as.numeric(datarecord.TREAT)
%   x1names = levels(datarecord.TREAT)
%   x2 = as.numeric(datarecord.BLOCK)
%   x2names = levels(datarecord.BLOCK)
%   Ntotal = length(y)
%   Nx1Lvl = length(unique(x1))
%   Nx2Lvl = length(unique(x2))
%   normalize = function( v ){ return( v / sum(v) ) }
%   x1contrastStruct = list(
%     f_Effect = normalize(x1names=='CONTROL'|x1names=='L') -
%                normalize(x1names=='f'|x1names=='Lf') ,
%     F_Effect = normalize(x1names=='f'|x1names=='Lf') -
%                normalize(x1names=='fF'|x1names=='LfF') ,
%     L_Effect = normalize(x1names=='CONTROL'|x1names=='f'|x1names=='fF') -
%                normalize(x1names=='L'|x1names=='Lf'|x1names=='LfF')
%   )
%   x2contrastStruct = NULL % list( vector(length=Nx2Lvl) )
%   x1x2contrastStruct = NULL % list( matrix( 1:(Nx1Lvl*Nx2Lvl) , nrow=Nx1Lvl ) )
% }
%
if strcmpi(dataSource,'Salary')
	% read data
	fname				= [dirSource filesep 'Salary.csv'];
	fid					= fopen(fname);
	C					= textscan(fid,'%q %q %f','delimiter', ',','HeaderLines',1); % %q = string with double quotes, % d = double, skip commas and header
	dataRecord.Org		= C{1};
	dataRecord.Post		= C{2};
	dataRecord.Salary	= C{3};
	
	y			= dataRecord.Salary;
	
	%   if ( F ) { % take log10 of salary
	%     y = log10( y )
	%     fileNameRoot = paste( fileNameRoot , 'Log10' , sep='' )
	%   }
	
	[x1names,~,x1] = unique(dataRecord.Org);
	[x2names,~,x2] = unique(dataRecord.Post);
	
	Ntotal		= length(y);
	Nx1Lvl		= numel(x1names);
	Nx2Lvl		= numel(x2names);
	x1contrastStruct.BFINvCEDP = strcmp('BFIN',x1names)-strcmp('CEDP',x1names);
	x1contrastStruct.CEDPvTHTR = strcmp('CEDP',x1names)-strcmp('THTR',x1names);
	
	x2contrastStruct.FT1vFT2 = strcmp('FT1',x2names)-strcmp('FT2',x2names);
	x2contrastStruct.FT2vFT3 = strcmp('FT2',x2names)-strcmp('FT3',x2names);
	
	a = strcmp('CHEM',x1names)-strcmp('THTR',x1names);
	b = strcmp('FT1',x2names)-strcmp('FT3',x2names);
	x1x2contrastStruct.CHEMvTHTRxFT1vFT3 = a*b';
	
	a = strcmp('BFIN',x1names)-normalize(~strcmp('BFIN',x1names));
	b = strcmp('FT1',x2names)-normalize(~strcmp('FT1',x2names));
	x1x2contrastStruct.BFINvOTHxFT1vOTH = a*b';
	
end

% if ( dataSource == 'Random' ) {
%   fileNameRoot = paste( fileNameRoot , dataSource , sep='' )
%   set.seed(47405)
%   ysdtrue = 3.0
%   a0true = 100
%   a1true = c( 2 , 0 , -2 ) % sum to zero
%   a2true = c( 3 , 1 , -1 , -3 ) % sum to zero
%   a1a2true = matrix( c( 1,-1,0, -1,1,0, 0,0,0, 0,0,0 ),% row and col sum to zero
%                      nrow=length(a1true) , ncol=length(a2true) , byrow=F )
%   npercell = 8
%   datarecord = matrix( 0, ncol=3 , nrow=length(a1true)*length(a2true)*npercell )
%   colnames(datarecord) = c('y','x1','x2')
%   rowidx = 0
%   for ( x1idx in 1:length(a1true) ) {
%     for ( x2idx in 1:length(a2true) ) {
%       for ( subjidx in 1:npercell ) {
%         rowidx = rowidx + 1
%         datarecord[rowidx,'x1'] = x1idx
%         datarecord[rowidx,'x2'] = x2idx
%         datarecord[rowidx,'y'] = ( a0true + a1true[x1idx] + a2true[x2idx]
%                                  + a1a2true[x1idx,x2idx] + rnorm(1,0,ysdtrue) )
%       }
%     }
%   }
%   datarecord = data.frame( y=datarecord[,'y'] ,
%                            x1=as.factor(datarecord[,'x1']) ,
%                            x2=as.factor(datarecord[,'x2']) )
%   y = as.numeric(datarecord.y)
%   x1 = as.numeric(datarecord.x1)
%   x1names = levels(datarecord.x1)
%   x2 = as.numeric(datarecord.x2)
%   x2names = levels(datarecord.x2)
%   Ntotal = length(y)
%   Nx1Lvl = length(unique(x1))
%   Nx2Lvl = length(unique(x2))
%   normalize = function( v ){ return( v / sum(v) ) }
%   x1contrastStruct = list(
%     X1_1v3 = (x1names=='1')-(x1names=='3')
%   )
%   x2contrastStruct =  list(
%     X2_12v34 = normalize(x2names=='1'|x2names=='2') -
%                normalize(x2names=='3'|x2names=='4')
%   )
%   x1x2contrastStruct = list(
%     IC_11v22 = outer(
%       (x1names=='1')-(x1names=='2') ,
%       (x2names=='1')-(x2names=='2')
%     ) ,
%     IC_23v34 = outer(
%       (x1names=='2')-(x1names=='3') ,
%       (x2names=='3')-(x2names=='4')
%     )
%   )
% }
%
% % Load the data:
% if ( dataSource == 'Ex19.3' ) {
%   fileNameRoot = paste( fileNameRoot , dataSource , sep='' )
%   y = c( 101,102,103,105,104, 104,105,107,106,108,
%          105,107,106,108,109, 109,108,110,111,112 )
%   x1 = c( 1,1,1,1,1, 1,1,1,1,1, 2,2,2,2,2, 2,2,2,2,2 )
%   x2 = c( 1,1,1,1,1, 2,2,2,2,2, 1,1,1,1,1, 2,2,2,2,2 )
%   % S = c( 1,2,3,4,5, 1,2,3,4,5, 1,2,3,4,5, 1,2,3,4,5 )
%   x1names = c('x1.1','x1.2')
%   x2names = c('x2.1','x2.2')
%   % Snames = c('S1','S2','S3','S4','S5')
%   Ntotal = length(y)
%   Nx1Lvl = length(unique(x1))
%   Nx2Lvl = length(unique(x2))
%   % NSLvl = length(unique(S))
%   normalize = function( v ){ return( v / sum(v) ) }
%   x1contrastStruct = list( X1.2vX1.1 = (x1names=='x1.2')-(x1names=='x1.1') )
%   x2contrastStruct = list( X2.2vX2.1 = (x2names=='x2.2')-(x2names=='x2.1') )
%   x1x2contrastStruct = NULL % list( matrix( 1:(Nx1Lvl*Nx2Lvl) , nrow=Nx1Lvl ) )
% }
%
%
%

% Specify the data in a form that is compatible with model, as a structure:
[z,yMorig,ySDorig]	= zscore(y);
dataStruct.y		= z;
dataStruct.x1		= x1;
dataStruct.x2		= x2;
dataStruct.Ntotal	= Ntotal;
dataStruct.Nx1Lvl	= Nx1Lvl;
dataStruct.Nx2Lvl	= Nx2Lvl;


%% INTIALIZE THE CHAINS.
a0			= mean(dataStruct.y);
a1			= accumarray(dataStruct.x1,dataStruct.y,[],@mean)-a0;
a2			= accumarray(dataStruct.x2,dataStruct.y,[],@mean)-a0;
[A1,A2]		= meshgrid(a1,a2);
linpred		= A1'+A2'+a0;
a1a2		= accumarray([dataStruct.x1 dataStruct.x2],dataStruct.y,[],@mean)-a0-linpred;

nChains		= 5;
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).a0		= a0;
	initsStruct(ii).a1		= a1;
	initsStruct(ii).a2		= a2;
	initsStruct(ii).a1a2	= a1a2;
	initsStruct(ii).sigma	= std(dataStruct.y)/2; % lazy
	initsStruct(ii).a1SD	= std(a1);
	initsStruct(ii).a2SD	= std(a2);
	initsStruct(ii).a1a2SD	= std(a1a2(:));
end

%% RUN THE CHAINS
parameters		= {'a0','a1','a2','a1a2','b0','b1','b2','b1b2','sigma','a1SD','a2SD','a1a2SD'};	% The parameter(s) to be monitored.
% adaptSteps		= 1000;			% Number of steps to 'tune' the samplers.
burnInSteps		= 2000;			% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 100000;		% Total number of steps in chains to save.
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
	'dic', 1, ...                       % Do the DIC?
	'monitorparams', parameters, ...     % List of latent variables to monitor
	'savejagsoutput' , 1 , ...          % Save command line output produced by JAGS?
	'verbosity' , 1 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
	'cleanup' , 0 );                    % clean up of temporary files?

%% EXAMINE THE RESULTS
if checkConvergence
	fnames = {'sigma','a1SD','a2SD','a1a2SD'};
	n		= numel(fnames);
	for ii = 1:n
		% thetaSample = reshape(mcmcChain,[numSavedSteps+1 nCoins]);
		ns = ceil(sqrt(n));
		figure(1)
		subplot(ns,ns,ii)
		s		= samples.(fnames{ii});
		s		= s(1:16667);
		s		= zscore(s);
		maxlag	= 100;
		[c,l]	= xcorr(s,maxlag,'coeff');
		h		= stem(l(maxlag:end),c(maxlag:end),'k-');
		xlim([-1 maxlag]);
		set(h,'MarkerEdgeColor','none');
		axis square;
		box off
		set(gca,'TickDir','out');
		str = fnames{ii};
		xlabel('Lag');
		ylabel('Autocorrelation');
		title(str);
		%   show( gelman.diag( codaSamples ) )
		%   effectiveChainLength = effectiveSize( codaSamples )
		%   show( effectiveChainLength )
	end
end


% Extract and plot the SDs:
sigmaSample		= [samples.sigma]*ySDorig;
a1SDSample		= [samples.a1SD]*ySDorig;
a2SDSample		= [samples.a2SD]*ySDorig;
a1a2SDSample	= [samples.a1a2SD]*ySDorig;

subplot(221);
plotPost(sigmaSample(:),'xlab','sigma','main','Cell SD','showMode',true);
subplot(222);
plotPost(a1SDSample(:),'xlab','a1SD','main','a1 SD','showMode',true);
subplot(223);
plotPost(a2SDSample(:),'xlab','a2SD','main','a2 SD','showMode',true);
subplot(224);
plotPost(a1a2SDSample(:),'xlab','a1a2SD','main','Interaction SD','showMode',true);

%% Extract b values:
b0Sample	= samples.b0(:);
b1Sample	= [samples.b1];
[m,n,p]		= size(b1Sample);
b1Sample	= reshape(b1Sample,m*n,p);
b2Sample	= [samples.b2];
[m,n,p]		= size(b2Sample);
b2Sample	= reshape(b2Sample,m*n,p);
b1b2Sample	= [samples.b1b2];
[m,n,p,o]		= size(b1b2Sample);
b1b2Sample	= reshape(b1b2Sample,m*n,p,o);

% Convert from standardized b values to original scale b values:
b0Sample	= b0Sample*ySDorig+yMorig;
b1Sample	= b1Sample*ySDorig;
b2Sample	= b2Sample*ySDorig;
b1b2Sample	= b1b2Sample*ySDorig;

%% Plot b values:
if Nx1Lvl<=6 && Nx2Lvl<=6
	subplot(4,5,1)
	plotPost(b0Sample,'xlab','\beta_0','main','Baseline');
	
	for x1idx = 1:dataStruct.Nx1Lvl
		subplot(4,5,x1idx+1);
		plotPost(b1Sample(:,x1idx),'xlab',['beta1_' num2str(x1idx)],'main',['x1:' x1names{x1idx}]);
	end
	
	for x2idx = 1:dataStruct.Nx2Lvl
		subplot(4,5,x2idx*5+1);
		plotPost( b2Sample(:,x2idx),'xlab',['beta2_' num2str(x2idx)],'main',['x2:' x1names{x2idx}]);
	end
	for x2idx = 1:dataStruct.Nx2Lvl
		for x1idx = 1:dataStruct.Nx1Lvl
			sb = x1idx+1+4*x2idx+1*x2idx;
			subplot(4,5,sb)
			plotPost(b1b2Sample(:,x1idx,x2idx),'xlab',['beta12_{' num2str(x1idx) ',' num2str(x2idx) '}'],...
				'main',['x1:' x1names{x1idx} ', x2:' x2names{x2idx}]);
		end
	end
end
%   for ( x2idx in 1:dataStruct.Nx2Lvl ) {
%     for ( x1idx in 1:dataStruct.Nx1Lvl ) {
%       histinfo = plotPost( b1b2Sample[x1idx,x2idx,] ,
%                 xlab=bquote(beta*12[.(x1idx)*','*.(x2idx)]) ,
%                 main=paste('x1:',x1names[x1idx],', x2:',x2names[x2idx])  )
%     }
%   }
%   #saveGraph( file=paste(fileNameRoot,'b',sep='') , type='eps' )
% }
%
% % Display contrast analyses
% nContrasts = length( x1contrastStruct )
% if ( nContrasts > 0 ) {
%    nPlotPerRow = 5
%    nPlotRow = ceiling(nContrasts/nPlotPerRow)
%    nPlotCol = ceiling(nContrasts/nPlotRow)
%    openGraph(width=3.75*nPlotCol,height=2.5*nPlotRow)
%    layout( matrix(1:(nPlotRow*nPlotCol),nrow=nPlotRow,ncol=nPlotCol,byrow=T) )
%    par( mar=c(4,0.5,2.5,0.5) , mgp=c(2,0.7,0) )
%    for ( cIdx in 1:nContrasts ) {
%        contrast = matrix( x1contrastStruct[[cIdx]],nrow=1) % make it a row matrix
%        incIdx = contrast!=0
%        histInfo = plotPost( contrast %*% b1Sample , compVal=0 ,
%                 xlab=paste( round(contrast[incIdx],2) , x1names[incIdx] ,
%                             c(rep('+',sum(incIdx)-1),'') , collapse=' ' ) ,
%                 cex.lab = 1.0 ,
%                 main=paste( 'X1 Contrast:', names(x1contrastStruct)[cIdx] )  )
%    }
%    #saveGraph( file=paste(fileNameRoot,'x1Contrasts',sep='') , type='eps' )
% }
% %
% nContrasts = length( x2contrastStruct )
% if ( nContrasts > 0 ) {
%    nPlotPerRow = 5
%    nPlotRow = ceiling(nContrasts/nPlotPerRow)
%    nPlotCol = ceiling(nContrasts/nPlotRow)
%    openGraph(width=3.75*nPlotCol,height=2.5*nPlotRow)
%    layout( matrix(1:(nPlotRow*nPlotCol),nrow=nPlotRow,ncol=nPlotCol,byrow=T) )
%    par( mar=c(4,0.5,2.5,0.5) , mgp=c(2,0.7,0) )
%    for ( cIdx in 1:nContrasts ) {
%        contrast = matrix( x2contrastStruct[[cIdx]],nrow=1) % make it a row matrix
%        incIdx = contrast!=0
%        histInfo = plotPost( contrast %*% b2Sample , compVal=0 ,
%                 xlab=paste( round(contrast[incIdx],2) , x2names[incIdx] ,
%                             c(rep('+',sum(incIdx)-1),'') , collapse=' ' ) ,
%                 cex.lab = 1.0 ,
%                 main=paste( 'X2 Contrast:', names(x2contrastStruct)[cIdx] ) )
%    }
%    #saveGraph( file=paste(fileNameRoot,'x2Contrasts',sep='') , type='eps' )
% }
% %
% nContrasts = length( x1x2contrastStruct )
% if ( nContrasts > 0 ) {
%    nPlotPerRow = 5
%    nPlotRow = ceiling(nContrasts/nPlotPerRow)
%    nPlotCol = ceiling(nContrasts/nPlotRow)
%    openGraph(width=3.75*nPlotCol,height=2.5*nPlotRow)
%    layout( matrix(1:(nPlotRow*nPlotCol),nrow=nPlotRow,ncol=nPlotCol,byrow=T) )
%    par( mar=c(4,0.5,2.5,0.5) , mgp=c(2,0.7,0) )
%    for ( cIdx in 1:nContrasts ) {
%        contrast = x1x2contrastStruct[[cIdx]]
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
%                 compVal=0 ,  xlab=contrastLab , cex.lab = 0.75 ,
%                 main=paste( names(x1x2contrastStruct)[cIdx] ) )
%    }
%    #saveGraph( file=paste(fileNameRoot,'x1x2Contrasts',sep='') , type='eps' )
% }
%
% %==============================================================================
% % Do NHST ANOVA:
%
% theData = data.frame( y=y , x1=factor(x1,labels=x1names) ,
%                             x2=factor(x2,labels=x2names) )
% openGraph(width=7,height=7)
% interaction.plot( theData.x1 , theData.x2 , theData.y , type='b' )
% #saveGraph( file=paste(fileNameRoot,'DataPlot',sep='') , type='eps' )
% aovresult = aov( y ~ x1 * x2 , data = theData )
% cat('\n------------------------------------------------------------------\n\n')
% print( summary( aovresult ) )
% cat('\n------------------------------------------------------------------\n\n')
% print( model.tables( aovresult , type = 'effects', se = TRUE ) , digits=3 )
% cat('\n------------------------------------------------------------------\n\n')
%
% %==============================================================================

function n = normalize(v)
n = v/sum(v);
