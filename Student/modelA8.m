function modelA8
% see also mixture: http://doingbayesiandataanalysis.blogspot.nl/2012/06/mixture-of-normal-distributions.html

close all
clear all
clc

% plotFlag = 'scat';
plotFlag = 'hist';
fnames = {'RG-GB-2013-09-24-0001';'RG-GB-2013-09-26-0001';'RG-GB-2013-09-30-0001';'RG-GB-2013-10-01-0001';...
	'RG-GB-2013-10-03-0001';'RG-GB-2013-10-07-0001';'RG-GB-2013-10-08-0001';'RG-GB-2013-10-11-0001';...
	'RG-GB-2013-10-14-0001';'RG-GB-2013-10-15-0001'...
	};
cond = [4 1 3 2 ...
	5 1 5 2 ...
	3 4 ...
	];

% fnames = {'RG-MtW-2013-10-07-0001';'RG-MtW-2013-10-08-0001';'RG-MtW-2013-10-10-0001';'RG-MtW-2013-10-11-0001';...
% 	'RG-MtW-2013-10-14-0001';'RG-MtW-2013-10-15-0001';'RG-MtW2-2013-10-15-0001';'RG-MtW-2013-10-16-0001';...
% 	'RG-MtW2-2013-10-16-0001';'RG-MtW-2013-10-17-0001'...
% 	};
% cond = [1 5 3 4 ...
% 	2 5 4 3 ...
% 	2 1 ...
% 	];

%      fnames = {'RG-NN-2013-09-26-0001';'RG-NN-2013-09-27-0001';'RG-NN-2013-09-30-0001';'RG-NN-2013-10-01-0001';...
%                   'RG-NN-2013-10-03-0001';'RG-NN-2013-10-08-0001';'RG-NN-2013-10-14-0001';'RG-NN-2013-10-17-0001';...
%                   'RG-NN2-2013-10-17-0001';'RG-NN-2013-10-18-0001'...
%             };
%         cond = [5 2 3 4 ...
%                       1 1 2 5 ...
%                       3 4 ...
%             ];
ucond = unique(cond);
ncond = numel(ucond);
xi = -90:5:90;
ni = numel(xi);

SS = struct([]);
X = [];
Y = [];
C = [];
coli = pa_statcolor(ncond,[],[],[],'def',1);
for ii = 1:ncond
	sel = cond == ucond(ii);
	c = cond(sel);
	n = numel(c);
	f = fnames(sel);
	SupSac = [];
	for jj = 1:n
		fname = f{jj};
		cd(['E:\DATA\RachelSync\Single\' fname(1:end-5)]);
		load(fname);
		tmp = pa_supersac(Sac,Stim,2,1);
		SupSac = [SupSac;tmp];
	end
	SupSac(:,9) = SupSac(:,9)/2;
	SS(ii).x = SupSac(:,24);
	SS(ii).y = SupSac(:,9);
	
	figure(666)
	subplot(3,2,ii)
	plot2dhist(SS(ii).x,SS(ii).y,xi)

	X = [X;SupSac(:,24)];
	Y = [Y;SupSac(:,9)];
	C = [C;repmat(ii,size(SupSac(:,9)))];
	
	muy = NaN(ni,1);
	for jj = 1:ni
		sel = round(SS(ii).x/5)*5==xi(jj);
		if sum(sel)
		muy(jj) = mean(SS(ii).y(sel));
		end
	end
	sel = isnan(muy);

	figure(667)
% 	subplot(3,2,ii)
tmp = muy(~sel)'-xi(~sel);
tmp = tmp-mean(tmp);
xtmp = xi(~sel);
ntmp = floor(numel(tmp)/2);
tmp = [tmp(ntmp+1) (-fliplr(tmp(1:ntmp))+tmp(ntmp+2:end))/2]
xtmp = xtmp((ntmp+1):end);
tmp = tmp-tmp(1);
	plot(xtmp,tmp,'ko-','Color',coli(ii,:));
	hold on
	
end
legend({'1';'2';'3';'4';'5'})
pa_horline;

x = X;
y = Y;
c = C;

figure
N		= hist3([x y],{xi xi});
col		= pa_statcolor(64,[],[],[],'def',6);
col		= col(:,[3 2 1]);
colormap(col)
% subplot(221)
% plot(x,y,'k.','Color',[.7 .7 .7]);
% axis square;
% axis([-90 90 -90 90])
% lsline;
% pa_unityline;
% box off
% set(gca,'TickDir','out');
% axis([-90 90 -90 90])
subplot(223);


switch plotFlag
	case 'hist'
plot2dhist(x,y,xi)
% 		imagesc(xi,xi,N')
% 		axis square
% 		box off
% 		set(gca,'TickDir','out','YDir','normal');
% 		axis([-90 90 -90 90])
% 		cax = caxis;
% 		caxis([0 cax(end)]);
% 		% colorbar
% 		pa_unityline;
	case 'scat'
		[X,Y] = meshgrid(xi,xi);
		X = X(:);
		Y = Y(:);
		N = N(:);
		sel =N>0;
		N = N(sel);
		Y = Y(sel);
		X = X(sel);
		N = 20*N./max(N);
		sz = N*5;
		sz(sz<10) = 10;

		
		h = scatter(Y,X,sz,N,'filled');
		set(h,'MarkerEdgeColor','k');
		axis square
		box off
		set(gca,'TickDir','out','YDir','normal');
		axis([-90 90 -90 90])
		cax = caxis;
		caxis([0 cax(end)]);
		% colorbar
		pa_unityline;
end

subplot(221)
N = hist(x,xi);
bar(xi,N,1,'FaceColor',col(round(end/2),:));
set(gca,'TickDir','out');
axis square;
box off
% [~,p] = kstest(x);
xlim([-90 90]);
% title(p)


subplot(224)
N = hist(y,xi);
barh(xi,N,1,'FaceColor',col(round(end/2),:));
set(gca,'TickDir','out');
axis square;
box off
% [~,p] = kstest(y);
% title(p)
ylim([-90 90]);


% Specify the data in a form that is compatible with model, as a structure:
[zx,mux,sdx] = zscore(x);
[zy,muy,sdy] = zscore(y);


% keyboard

%%
Ncond = max(c);
dataStruct.y		= y;
dataStruct.x		= x;
dataStruct.cond		= c;
dataStruct.Ndata    = numel(x);
dataStruct.Ncond    = Ncond;

% dataStruct.ncond    = 1;

% %% INTIALIZE THE CHAINS.
% y			= mean(dataStruct.y);
% x			= mean(dataStruct.x);

nChains		= 3;
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).tau_n     = 1./std(dataStruct.y);
	initsStruct(ii).tau_p     = 1./repmat(std(dataStruct.y),4,1);
% 	initsStruct(ii).mu     = repmat(std(dataStruct.y),4,1);
end

%% RUN THE CHAINS
parameters		= {'sigma_n','sigma_p','tau','mu'};	% The parameter(s) to be monitored.
% adaptSteps		= 1000;			% Number of steps to 'tune' the samplers.
burnInSteps		= 000;			% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 1000;		% Total number of steps in chains to save.
thinSteps		= 1;			% Number of steps to 'thin' (1=keep every step).
nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
	doparallel		= 1; % do not use parallelization
		if doparallel
			isOpen = matlabpool('size') > 0;
			if ~isOpen
				matlabpool open
			end
		end

pa_datadir;
fprintf( 'Running JAGS...\n' );
% [samples, stats, structArray] = matjags( ...
samples = matjags( ...
	dataStruct, ...                     % Observed data
	fullfile(pwd, 'modelA8mixt.txt'), ...    % File that contains model definition
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

%%
% keyboard

%%
noise = samples.sigma_n(:);
p = samples.sigma_p;
p = reshape(p,nChains*nIter,Ncond);

% noise = sqrt(noise);
% p = sqrt(p);

figure(2)
clf
subplot(121)
hist(noise)

subplot(122)
hist(p(:,1))

%%
figure(3)
clf
for ii = 1:Ncond
subplot(2,3,ii)
plotPost(p(:,ii))
% xlim([0 30]);
end

% subplot(122)
% plotPost(samples.sigma_p(:))

% keyboard

%% Prediction
% mu	= samples.mu;
% tau = samples.tau;
% 		v[j]		<- (pow(sigma_n,2) * pow(sigma_p[j],2)) / (pow(sigma_n,2) + pow(sigma_p[j],2))
% 		mu[i] <- pow(sigma_p[cond[i]],2)/(pow(sigma_n,2)+pow(sigma_p[cond[i]],2))*x[i]
figure(4)
clf
X = struct([]);
for ii = 1:Ncond
	V		= (p(:,ii).^2 .* noise.^2) ./ (p(:,ii).^2 + noise.^2);
	indx	= pa_rndval(1,numel(xi),[numel(noise) 1]);
	t = xi(indx)';
	X(ii).x = t;
	mu		=  p(:,ii).^2  ./ (p(:,ii).^2 + noise.^2) .* t;
	
	ypred	= mu+sqrt(V).*randn(numel(noise),1);
	
% 	plot(t,ypred,'.')
subplot(3,2,ii)
	plot2dhist(t,ypred,xi)
end


%%
figure
col = pa_statcolor(5,[],[],[],'def',1);
indx = 1:50;
p = [samples.sigma_p];
for ii = 1:5
% subplot(2,3,ii)
plot(squeeze(p(:,indx,ii))','Color',col(ii,:));
hold on
end
ylim([0 30])

p = [samples.sigma_n];
plot(squeeze(p(:,indx))','k-');

%%
keyboard
function plot2dhist(x,y,xi)

N		= hist3([x y],{xi xi});
col		= pa_statcolor(64,[],[],[],'def',6);
col		= col(:,[3 2 1]);
colormap(col)



		imagesc(xi,xi,N')
		axis square
		box off
		set(gca,'TickDir','out','YDir','normal');
		axis([-90 90 -90 90])
		cax = caxis;
		caxis([0 cax(end)]);
		% colorbar
		pa_unityline;
