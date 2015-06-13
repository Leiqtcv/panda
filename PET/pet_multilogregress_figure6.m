function pet_multilogregress_figure6(checkConvergence)
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
	'#Logistic regression\r\n',...
	'\tfor( i in 1:nData ) {\r\n',...
	'\t\ty[i] ~ dbin( mu[i], n[i] )\r\n',...
	'\t\tmu[i] <- 1/(1+exp(-( b0 + inprod( b[] , x[i,] ))))\r\n',...
	'\t}\r\n',...
	'\t#Vague priors on betas\r\n',...
	'\tb0 ~ dnorm( 0 , 1.0E-12 )\r\n',...
	'\tfor (j in 1:nPredictors) {\r\n',...
	'\t\tb[j] ~ dnorm( 0 , 1.0E-12 )\r\n',...
	'\t}\r\n',...
	'#Missing values\r\n',...
	'\tfor( i in 1:nData ) {\r\n',...
	'\t\tfor ( j in 1 : nPredictors ) {\r\n',...
	'\t\t\tx[i,j] ~ dnorm(mux[j],tau)\r\n',...
	'\t\t}\r\n',...
	'\t}\r\n',...
	'\t#Vague priors on missing predictors,\r\n',...
	'\t#assuming predictor variances are equal\r\n',...
	'\ttau ~ dgamma(0.001,0.001)\r\n',...
	'\tfor (j in 1:nPredictors) {\r\n',...
	'\t\tmux[j] ~ dnorm(0,1.0E-12)\r\n',...
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
nArea = 3;
for areaIndx = 1:nArea
	if strcmpi(dataSource,'pet')
		% Load
		fname = 'C:\MATLAB\PandA\DoingBayesianDataAnalysis\petdata.mat';
		if exist(fname,'file')
			load(fname)
		else
			load('E:\DATA\petdata')
		end
		area	= areaIndx;
		
		pre		= [DAT(area).Dprerest DAT(area).Dprevideo nanmean(DAT(area).Dprevideo)+randn(size(DAT(area).Dprevideo))];
		nh		= [DAT(area).DNHrest DAT(area).DNHvideo DAT(area).DNHav];
		post	= [DAT(area).Dpostrest DAT(area).Dpostvideo DAT(area).Dpostav];
		F		= DAT(area).Fpost;
		Fnh		= DAT(area).FNH;
		
		x	= post;
		y	= F;
% 				x	= [pre;post;nh];
% 				y	= [F;F;Fnh];
		nSub = size(x,1);
		
		
		% 		sel	= isnan(x(:,1)) | isnan(x(:,2))  | isnan(x(:,3));
		% 		x	= x(~sel,:);
		% 		F	= round(y(~sel));
		% 		y	= round((y(~sel)/100*3*12));
		% 		N	= repmat(3*12,size(y));
		
		selMissing	= isnan(x(:,1)) | isnan(x(:,2))  | isnan(x(:,3));
		F	= round(y);
		y	= round((y/100*3*12));
		N	= repmat(3*12,size(y));
		
		[nData,nPredictors]	= size(x);
		predictorNames = {'Rest','Video','AV'};
		predictedName = 'Phoneme Score';
	end
	figure(666)
	mrk		= ['o','s','d'];
	col		= ['k','r','b'];
	for ii	= 1:nPredictors
		subplot(2,3,areaIndx)
		plot(x(~selMissing,ii),100*y(~selMissing)./N(~selMissing),['k' mrk(ii)],'MarkerFaceColor',col(ii),'MarkerEdgeColor','k');
		hold on
		coef	= glmfit(x(~selMissing,ii),[y(~selMissing) N(~selMissing)],'binomial','link','logit');
		xi		= linspace(90,130,100)';
		yfit	= glmval(coef, xi,'logit','size',3*12);
		plot(xi,100*yfit/(3*12),'LineWidth',2,'Color',col(ii));
	end
	% axis square;
	box off;
	set(gca,'TickDir','out');
	ylim([-0.1 1.1]*100);
	xlim([90 130]);
	title(predictorNames{ii})
	xlabel('FDG (%)');
	ylabel('Phoneme Score (%)');
	pa_horline([0 100]);
	
	C	= pa_statcolor(100,[],[],[],'def',10,'disp',false);
	Cf	= C(F,:);
	
	% Re-center data at mean, to reduce autocorrelation in MCMC sampling.
	% Standardize (divide by SD) to make initialization easier.
	zx = NaN(size(x));
	Mx = NaN(1,nPredictors);
	SDx = Mx;
	for predIndx = 1:nPredictors
		selMissing = isnan(x(:,predIndx));
		[zxt,Mxt,SDxt]				= zscore(x(~selMissing,predIndx));
		
		
		zx(~selMissing,predIndx) = zxt;
		Mx(predIndx) = Mxt;
		SDx(predIndx) = SDxt;
		
	end
	
	
	zy						= y; % y is not standardized; must be 0,1
	dataStruct.x			= zx;
	dataStruct.y			= zy; % BUGS does not treat 1-column mat as vector
	dataStruct.n			= N;
	dataStruct.nPredictors	= nPredictors;
	dataStruct.nData		= nData;
	
	%% INTIALIZE THE CHAINS.
	b				= glmfit(zx,[zy N],'binomial','link','logit');
	b0Init			= b(1)
	bInit			= b(2:4)
	
	nChains			= 3;                   % Number of chains to run.
	initsStruct		= struct([]);
	xInit			= zx;
	xInit(isnan(xInit)) = 0;
	for ii = 1:nChains
		initsStruct(ii).b0 = b0Init;
		initsStruct(ii).b = bInit;
% 		initsStruct(ii).x = xInit;
	end
	
	%% RUN THE CHAINS
	parameters		= {'b0','b','x'};		% The parameter(s) to be monitored.
	% adaptSteps		= 1000;			% Number of steps to 'tune' the samplers.
	burnInSteps		= 2000;			% Number of steps to 'burn-in' the samplers.
	numSavedSteps	= 50000;		% Total number of steps in chains to save.
	thinSteps		= 1;			% Number of steps to 'thin' (1=keep every step).
	nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
	doparallel		= 0; % do not use parallelization
	fprintf( 'Running JAGS...\n' );
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
	
% 	keyboard
	%% Extract chain values:
	zb0Sample	= samples.b0(:);
	zbSample	= reshape(samples.b,nChains*nIter,nPredictors);
	
	% Convert to original scale:
	a			= bsxfun(@times,zbSample,Mx./SDx);
	b0Sample	= zb0Sample-sum(a,2);
	bSample		= bsxfun(@rdivide,zbSample,SDx);
	
	zxSample = reshape(samples.x,nChains*nIter,nSub,nPredictors);
	xSample = zxSample;
	for idx = 1:nPredictors
		xSample(:,:,idx) = zxSample(:,:,idx)*SDx(idx)+Mx(idx);
		mu = squeeze(median(xSample(:,:,idx)));
		for subIndx = 1:nSub

			if isnan(x(subIndx,idx))
				figure(666)
				subplot(2,3,areaIndx)
				hold on
				plot(mu(subIndx),100*y(subIndx)./N,mrk(idx),'Color',col(idx),'MarkerFaceColor','w');
			end
		end
	end	
	% % Examine sampled values, z scale:
	% figure;
	% X		= [zb0Sample(:) zbSample];
	% [~,AX]	= plotmatrix(X);
	% set(get(AX(3,1),'XLabel'),'String','z\beta_0')
	% set(get(AX(3,2),'XLabel'),'String','z\beta_{weight}')
	% set(get(AX(3,3),'XLabel'),'String','z\beta_{height}')
	% set(get(AX(1,1),'YLabel'),'String','z\beta_0')
	% set(get(AX(2,1),'YLabel'),'String','z\beta_{weight}')
	% set(get(AX(3,1),'YLabel'),'String','z\beta_{height}')
	% % axis(AX(:),'square');
	%
	% % Examine sampled values, original scale:
	% figure;
	% X		= [b0Sample(:) bSample];
	% [~,AX]	= plotmatrix(X);
	% set(get(AX(3,1),'XLabel'),'String','\beta_0')
	% set(get(AX(3,2),'XLabel'),'String','\beta_{weight}')
	% set(get(AX(3,3),'XLabel'),'String','\beta_{height}')
	% set(get(AX(1,1),'YLabel'),'String','\beta_0')
	% set(get(AX(2,1),'YLabel'),'String','\beta_{weight}')
	% set(get(AX(3,1),'YLabel'),'String','\beta_{height}')
	
	% Display the posterior :
	% figure;
	% subplot(131)
	% plotPost(b0Sample,'xlab','\beta_0 Value','main',['logit(p(' predictedName '=1)) when predictors=0']);
	subplot(2,3,areaIndx+3)
	plot(bSample(1:100:end,1),bSample(1:100:end,2),'.','Color','r');
	hold on
	plot(bSample(1:100:end,1),bSample(1:100:end,3),'.','Color','b');
	% 	plot(bSample(1:100:end,2),bSample(1:100:end,3),'o','MarkerFaceColor','g','MarkerEdgeColor','k');
	xlim([-2 2]);
	ylim([-2 2]);
	box off
	set(gca,'TickDir','out');
	xlabel('\beta_{Rest}');
	ylabel('\beta_{video}');
	pa_horline(0,'k:');
	pa_verline(0,'k:');
	pa_revline('k:');
	axis square;
	set(gca,'Xtick',-2:0.5:2,'YTick',-2:0.5:2);
	
	figure(667)
	subplot(2,3,areaIndx+3)
	plotPost(bSample(:,1));
	hold on
	xlim([-2 2]);
	ylim([-2 2]);
	box off
	set(gca,'TickDir','out');
	xlabel('\beta_{Rest}');
	ylabel('\beta_{video}');
	pa_horline(0,'k:');
	pa_verline(0,'k:');
	pa_revline('k:');
	axis square;
	set(gca,'Xtick',-2:0.5:2,'YTick',-2:0.5:2);
	
	figure(668)
	subplot(2,3,areaIndx+3)
	plotPost(bSample(:,2));
	hold on
	xlim([-2 2]);
	ylim([-2 2]);
	box off
	set(gca,'TickDir','out');
	xlabel('\beta_{Rest}');
	ylabel('\beta_{video}');
	pa_horline(0,'k:');
	pa_verline(0,'k:');
	pa_revline('k:');
	axis square;
	set(gca,'Xtick',-2:0.5:2,'YTick',-2:0.5:2);
	
	figure(669)
	subplot(2,3,areaIndx+3)
	plotPost(bSample(:,3));
	hold on
	xlim([-2 2]);
	ylim([-2 2]);
	box off
	set(gca,'TickDir','out');
	xlabel('\beta_{Rest}');
	ylabel('\beta_{video}');
	pa_horline(0,'k:');
	pa_verline(0,'k:');
	pa_revline('k:');
	axis square;
	set(gca,'Xtick',-2:0.5:2,'YTick',-2:0.5:2);
	
	% 	for bIdx = 1:nPredictors
	%
	% 		subplot(2,3,bIdx+3)
	%
	% 		plotPost(bSample(:,bIdx),'xlab',['\beta_' num2str(bIdx) ' Value'],'compVal',0,'main',predictorNames{bIdx});
	% 	end
	
end
pa_datadir;

figure(666)
print('-depsc','-painter',[mfilename]);

figure(667)
print('-depsc','-painter',[mfilename '2']);

figure(668)
print('-depsc','-painter',[mfilename '3']);

return
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



function [postSummary,histInfo] = plotPost(paramSampleVec, varargin)
% PLOTPOST(P)
%
% plot MCMC parameter sample vector P
%
% POSTSUMMARY = PLOTPOST(P)
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij


%% Check arguments
% At least this is better in R
% Override defaults of hist function, if not specified by user
if nargin<1
	paramSampleVec = 1;
end
credMass	= pa_keyval('credMass', varargin); if isempty(credMass), credMass = 0.95; end;
showMode	= pa_keyval('showMode', varargin); if isempty(showMode), showMode = false; end;
showCurve	= pa_keyval('showCurve', varargin); if isempty(showCurve), showCurve = false; end;
compVal		= pa_keyval('compVal', varargin);
ROPE		= pa_keyval('ROPE', varargin);
yaxt		= pa_keyval('yaxt', varargin);
ylab		= pa_keyval('ylab', varargin);
xlab		= pa_keyval('xlab', varargin); if isempty(xlab), xlab = 'Parameter'; end;
xl			= pa_keyval('xlim', varargin); if isempty(xl), xl = minmax([compVal; paramSampleVec]'); end;
main		= pa_keyval('main', varargin);
col			= pa_keyval('col', varargin); if isempty(col), col = [.7 .7 .7]; end;
breaks		= pa_keyval('breaks', varargin);
% HDItextPlace = pa_keyval('HDItextPlace', varargin); if isempty(HDItextPlace), HDItextPlace = 0.7; end;
% border		= pa_keyval('border', varargin); if isempty(border), border='w'; end;

%% Determine interesting parameters
postSummary.mean	= mean(paramSampleVec);
postSummary.median	= median(paramSampleVec);
[mcmcDensity.y,mcmcDensity.x] = ksdensity(paramSampleVec);
[~,indx]			= max(mcmcDensity.y);
postSummary.mode	= mcmcDensity.x(indx);
HDI					= HDIofMCMC(paramSampleVec,credMass);
postSummary.hdiMass = credMass;
postSummary.hdiLow	= HDI(1);
postSummary.hdiHigh	= HDI(2);

%% Plot histogram.
hold on
if isempty(breaks)
	by=(HDI(2)-HDI(1))/18;
	breaks = unique([min(paramSampleVec):by:max(paramSampleVec) max(paramSampleVec)]);
	breaks = linspace(-2,2,100);
end

N					= histc(paramSampleVec,breaks);
db					= mean(diff(breaks));
histInfo.N			= N;
histInfo.density	= 0.25*N./db/sum(N);
if ~showCurve
	h = bar(breaks,histInfo.density,'style','histc');
	delete(findobj('marker','*')); % Matlab bug?
	set(h,'FaceColor',col,'EdgeColor','w');
end
if showCurve
	[densCurve.y,densCurve.x] = ksdensity(paramSampleVec);
	h = plot(densCurve.x, densCurve.y,'b-');
	set(h,'Color',col,'LineWidth',2);
end
xlabel(xlab);
ylabel(ylab);
box off
xlim(xl);
title(main);

cenTendHt	= 0.9*nanmax(histInfo.density);
cvHt		= 0.7*nanmax(histInfo.density);
ROPEtextHt	= 0.55*nanmax(histInfo.density);

% Display mean or mode:
if ~showMode
	str			= ['mean = ' num2str(postSummary.mean,'%g')];
	text(postSummary.mean,cenTendHt,str,'HorizontalAlignment','center');
else
	[~,indx]	= max(mcmcDensity.y);
	modeParam	= mcmcDensity.x(indx);
	str			= ['mode = ' num2str(postSummary.mode,'%g')];
	text(modeParam, cenTendHt, str,'HorizontalAlignment','center');
end

%% Display the comparison value.
if ~isempty(compVal)
	cvCol = [0 .3 0];
	pcgtCompVal = round(100*sum(paramSampleVec>compVal)/length(paramSampleVec)); % percentage greater than
	pcltCompVal = 100 - pcgtCompVal; % percentage lower than
	plot([compVal compVal],[0.96*cvHt 0],'k-','Color',cvCol,'LineWidth',2);
	str = [num2str(pcltCompVal) '% < ' num2str(compVal,3) ' < ' num2str(pcgtCompVal) '%'];
	text(compVal,cvHt,str,'HorizontalAlignment','center','Color',cvCol);
	postSummary.compVal = compVal;
	postSummary.pcGTcompVal = sum(paramSampleVec>compVal)/length(paramSampleVec);
end
%% Display the ROPE.
if ~isempty(ROPE)
	ropeCol = [.5 0 0];
	pcInROPE = sum(paramSampleVec>ROPE(1) & paramSampleVec<ROPE(2))/length(paramSampleVec);
	plot(ROPE([1 1]),[0 0.96*ROPEtextHt],':','LineWidth',2,'Color',ropeCol);
	plot(ROPE([2 2]),[0 0.96*ROPEtextHt],':','LineWidth',2,'Color',ropeCol);
	
	str = [num2str(round(100*pcInROPE)) '% in ROPE'];
	text(mean(ROPE),ROPEtextHt,str,'Color',ropeCol,'HorizontalAlignment','center');
	
	postSummary.ROPElow		= ROPE(1);
	postSummary.ROPEhigh	= ROPE(2);
	postSummary.pcInROPE	= pcInROPE;
end
%% Additional stuff: To make Matlab figure look more like R figure
ax		= axis;
yl		= ax([3 4]);
ydiff	= yl(2)-yl(1);
yl		= [yl(1)-ydiff/20 yl(2)];
ylim(yl);
set(gca,'TickDir','out');
axis square;

%% Display the HDI.
plot(HDI,[0 0],'k-','LineWidth',4);
str = [num2str(100*credMass,'%g') '% HDI'];
text(mean(HDI),ydiff/20+ydiff/20,str,'HorizontalAlignment','center');
str = num2str(HDI(1),'%g');
text(HDI(1),ydiff/20,str,'HorizontalAlignment','center');
str = num2str(HDI(2),'%g');
text(HDI(2),ydiff/20,str,'HorizontalAlignment','center');



