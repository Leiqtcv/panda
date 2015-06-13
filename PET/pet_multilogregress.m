function pet_multilogregress(checkConvergence)
% MILTILINREGRESSHYPERJAGS
%
% Multiple logistic regression
%
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij
% for 2 independent variables
close all
warning off;

%% THE MODEL.
str = ['model {\r\n',...
	'\tfor( i in 1 : nData ) {\r\n',...
	'\t\ty[i] ~ dbin( mu[i], n[i] )\r\n',...
	'\t\tmu[i] <- 1/(1+exp(-( b0 + inprod( b[] , x[i,] ))))\r\n',...
	'\t}\r\n',...
	'\tb0 ~ dnorm( 0 , 1.0E-12 )\r\n',...
	'\tfor ( j in 1 : nPredictors ) {\r\n',...
	'\t\tb[j] ~ dnorm( 0 , 1.0E-12 )\r\n',...
	'\t}\r\n',...
	'}\r\n',...
	];
% Write the modelString to a file, using Matlab commands:
fid			= fopen('model.txt','w');
fprintf(fid,str);
fclose(fid);

%% THE DATA.
dataSource = 'pet';
if nargin<1
	checkConvergence = false;
end

if strcmpi(dataSource,'pet')
	% Load
	
	fname = 'C:\MATLAB\PandA\DoingBayesianDataAnalysis\petdata.mat';
	if exist(fname,'file')
		load(fname)
	else
		
		load('E:\DATA\petdata')
	end
	area = 1;
	DAT
	
	pre		= [DAT(area).Dprerest DAT(area).Dprevideo];
	nh		= [DAT(area).DNHrest DAT(area).DNHvideo];
	post	= [DAT(area).Dpostrest DAT(area).Dpostvideo];
	F		= DAT(area).Fpost;
	Fnh		= DAT(area).FNH;
	
	x	= [pre; nh; post];
	y	= [F;Fnh;F];
	
	x	= pre;
	y	= F;
	
	% 	x	= post;
	% 	y	= F;
	%
	% 	x	= nh;
	% 	y	= Fnh;
	%
	% 	x	= [pre; post];
	% 	y	= [F; F];
	
	% 	x	= [DAT(area).Dprerest DAT(area).Dprevideo; DAT(area).DNHrest DAT(area).DNHvideo;];
	% 	y	= [DAT(area).Fpost; DAT(area).FNH;];
	% 	x	= [DAT(area).Dpostrest DAT(area).Dpostvideo; DAT(area).DNHrest DAT(area).DNHvideo;];
	% 	y	= [DAT(area).Fpost; DAT(area).FNH;];
	% 	x	= [DAT(area).Dprerest DAT(area).Dprevideo; DAT(area).Dpostrest DAT(area).Dpostvideo;];
	% 	y	= [DAT(area).Fpost; DAT(area).Fpost; ];
	sel = isnan(x(:,1)) | isnan(x(:,2)) ;
	x	= x(~sel,:);
	F = round(y(~sel));
	y	= round((y(~sel)/100*3*12));
	N = repmat(3*12,size(y));
	
	[nData,nPredictors]	= size(x);
	predictorNames = {'Rest','Video'};
	predictedName = 'Phoneme Score';
	
	close all
end
figure(1)
mrk		= ['o','s'];
col		= ['k','r'];
for ii	= 1:nPredictors
	plot(x(:,ii),100*y./N,['k' mrk(ii)],'MarkerFaceColor',col(ii),'MarkerEdgeColor','k');
	hold on
	coef	= glmfit(x,[y N],'binomial','link','logit');
% 	xi		= linspace(min(x(:,ii)),max(x(:,ii)),100)';
	xi		= linspace(95,120,100)';
	indx	= [1 2] ~= ii;
	yfit	= glmval(coef, [xi repmat(mean(x(:,indx)),size(xi))],'logit','size',3*12);
	plot(xi,100*yfit/(3*12),'LineWidth',2,'Color',col(ii));
end
axis square;
box off;
set(gca,'TickDir','out');
ylim([-0.1 1.1]*100);
title(predictorNames{ii})
xlabel('FDG (%)');
ylabel('Phoneme Score (%)');
pa_horline([0 100]);


subplot(121)
% plot3(x(:,1),x(:,2),y,'ko','MarkerEdgeColor','k','MarkerFaceColor',[.7 .7 1]);
C	= pa_statcolor(100,[],[],[],'def',10,'disp',false);
Cf	= C(F,:);
h	= scatter3(x(:,1),x(:,2),100*y./N,80,Cf,'filled');
set(h,'MarkerEdgeColor','k');
hold on
axis square;
grid on;
set(gca,'TickDir','out');
zlim([0 100]);

% Re-center data at mean, to reduce autocorrelation in MCMC sampling.
% Standardize (divide by SD) to make initialization easier.
[zx,Mx,SDx]				= zscore(x);
zy						= y; % y is not standardized; must be 0,1
dataStruct.x			= zx;
dataStruct.y			= zy; % BUGS does not treat 1-column mat as vector
dataStruct.n			= N;
dataStruct.nPredictors	= nPredictors;
dataStruct.nData		= nData;



%% INTIALIZE THE CHAINS.
b				= glmfit(x,[y N],'binomial','link','logit');
b				= glmfit(zx,[zy N],'binomial','link','logit');

b0Init			= b(1);
bInit			= b(2:3);

nChains			= 3;                   % Number of chains to run.
initsStruct		= struct([]);
for ii = 1:nChains
	initsStruct(ii).b0 = b0Init;
	initsStruct(ii).b = bInit;
end


%% RUN THE CHAINS
parameters		= {'b0','b'};		% The parameter(s) to be monitored.
% adaptSteps		= 1000;			% Number of steps to 'tune' the samplers.
burnInSteps		= 2000;			% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 50000;		% Total number of steps in chains to save.
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

% Convert to original scale:
a			= bsxfun(@times,zbSample,Mx./SDx);
b0Sample	= zb0Sample-sum(a,2);
bSample		= bsxfun(@rdivide,zbSample,SDx);

% Examine sampled values, z scale:
figure;
X		= [zb0Sample(:) zbSample];
[~,AX]	= plotmatrix(X);
set(get(AX(3,1),'XLabel'),'String','z\beta_0')
set(get(AX(3,2),'XLabel'),'String','z\beta_{weight}')
set(get(AX(3,3),'XLabel'),'String','z\beta_{height}')
set(get(AX(1,1),'YLabel'),'String','z\beta_0')
set(get(AX(2,1),'YLabel'),'String','z\beta_{weight}')
set(get(AX(3,1),'YLabel'),'String','z\beta_{height}')
% axis(AX(:),'square');

% Examine sampled values, original scale:
figure;
X		= [b0Sample(:) bSample];
[~,AX]	= plotmatrix(X);
set(get(AX(3,1),'XLabel'),'String','\beta_0')
set(get(AX(3,2),'XLabel'),'String','\beta_{weight}')
set(get(AX(3,3),'XLabel'),'String','\beta_{height}')
set(get(AX(1,1),'YLabel'),'String','\beta_0')
set(get(AX(2,1),'YLabel'),'String','\beta_{weight}')
set(get(AX(3,1),'YLabel'),'String','\beta_{height}')

% Display the posterior :
figure;
subplot(131)
plotPost(b0Sample,'xlab','\beta_0 Value','main',['logit(p(' predictedName '=1)) when predictors=0']);
for bIdx = 1:nPredictors
	subplot(1,3,bIdx+1)
	plotPost(bSample(:,bIdx),'xlab',['\beta_' num2str(bIdx) ' Value'],'compVal',0,'main',predictorNames{bIdx});
end


%%
% close all
% Plot data with .5 level contours of believable logistic surfaces.
% The contour lines are best interpreted when there are only two predictors.
figure(1);
subplot(122)
hold on
axis square;
set(gca,'TickDir','out');
xlabel(predictorNames{1});
ylabel(predictorNames{2});
title('Phoneme score');
xl = minmax(x(:,1)');
yl = minmax(x(:,2)');
xl = [90 120];
yl = xl;
xlim(xl);
ylim(yl);
C	= pa_statcolor(100,[],[],[],'def',10,'disp',false);
Cf	= C(F,:);
h	= scatter(x(:,1),x(:,2),20*sqrt(y),Cf,'filled');
set(h,'MarkerEdgeColor','k');
% sel = y==1;
% text(x(sel,1),x(sel,2),'1')
% text(x(~sel,1),x(~sel,2),'0')


%%
% if false
if true
	x1 = 95:130;
	x2 = interp1(x(:,1),x(:,2),x1,'cubic');
	for p1idx = 1:(nPredictors-1)
		for p2idx = (p1idx+1):nPredictors
			% Some of the 50% level contours from the posterior sample.
			% We want:
			%	p(y=1) = m = 0.5
			% for:
			%	m = sig(b1*x1+b2*x2+b0)
			% since:
			%	logit(0.5)	= log(0.5/(1-0.5)) = 0
			%
			% for every x1, we get x2:
			%	b1*x1+b2*x2+b0	= 0
			%	b2*x2			= -b1*x1-b0
			%	x2				= -b1/b2*x-b0/b2
			for chainIdx = ceil(linspace(1,nChains*nIter,20))
				subplot(122)
				p = 0.5;
				p = log(p/(1-p));
				p = p/bSample(chainIdx,p2idx);
				a = p-(b0Sample(chainIdx))/bSample(chainIdx,p2idx);
				b = p-bSample(chainIdx,p1idx)/bSample(chainIdx,p2idx);
				h = refline(b,a);
				set(h,'LineWidth',1,'Color',[.7 .7 .7]);
				
				% 				subplot(221)
				%
				% 				tmp = bSample(chainIdx,1)*x1+bSample(chainIdx,2)*x2+b0Sample(chainIdx);
				% 				p = 3*12*1./(1+exp(-tmp));
				% 				hold on
				% 				plot(x1,p,'k-','Color',[.7 .7 .7])
				%
				% 				subplot(222)
				% 				hold on
				% 				plot(x2,p,'k-','Color',[.7 .7 .7])
			end
		end
	end
	
	x1 = 90:130;
	[x1,x2] = meshgrid(x1);
	tmp = mean(bSample(:,1))*x1+mean(bSample(:,2))*x2+mean(b0Sample);
	p = 100*1./(1+exp(-tmp));
	subplot(121)
	meshc(x1,x2,p);
	xlabel(predictorNames{1});
	ylabel(predictorNames{2});
	zlabel('Phoneme score');
	caxis([0 100])
	%
	% coef				= glmfit(x,y,'binomial','link','logit');
	subplot(122)
	coef	= glmfit(x,[y N],'binomial','link','logit');
	
	str = ['m = sig(' num2str(coef(2)) 'x_1 + ' num2str(coef(3)) 'x_2 + ' num2str(coef(1)) ')'];
	disp(str)
	a = -coef(1)/coef(3);
	b = -coef(2)/coef(3);
	% h = refline(b,a);
	set(h,'LineWidth',2,'Color','k');
	xlim(xl);
	ylim(yl);
	pa_unityline;
	
	% keyboard
	colormap(C);
	colorbar;
	caxis([0 100]);
	
else
	% return
	%% Posterior Y
	nx = 20;
	xi = linspace(90,120,nx);
	[x1,x2] = meshgrid(xi',xi');
	n = nChains*nIter;
	Y = NaN(n,nx,nx);
	for ii = 1:nChains*nIter
		tmp = bSample(ii,1)*x1+bSample(ii,2)*x2+b0Sample(ii);
		p = 1./(1+exp(-tmp));
		Y(ii,:,:) = tmp;
	end
	mu = squeeze(mean(Y));
	% figure
	contourf(x1,x2,100*mu,100)
	shading flat;
	% whos mu
	colormap(C);
	colorbar;
	caxis([0 100]);
end

figure(1)
pa_datadir;
print('-depsc','-painter',[mfilename num2str(area)]);

figure(4)
pa_datadir;
print('-depsc','-painter',[mfilename num2str(area) 'beta']);

