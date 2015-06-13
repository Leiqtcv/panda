function mon_analysis2

close all
clear all

% alldata

[y,xMet1,xMet2,x1] = getdata;
% x1 = x1;
% x1
% x1 = ones(size(y));

xMet1 = round(xMet1/10)*10;
y = round(y/10)*10;
xMet2 = round(xMet2/5)*5;
x = [xMet1 y];

whos x
[N,ux] = pa_countunique(x);

whos xMet1 y xMet2 N ux Cnt
figure(1)
scatter(ux(:,1),ux(:,2),N.*10,'filled','r');
axis square;
box off;
xlim([-100 100]);
ylim([-100 100]);
pa_unityline('k:');
set(gca,'TickDir','out','Xtick',-90:30:90,'Ytick',-90:30:90);
xlabel('Target azimuth (deg)');
ylabel('Response azimuth (deg)');

pa_datadir;
print('-depsc','-painter',mfilename);

% return
% figure(2)
% subplot(121)
% 
% x = pa_zscore(xMet1);
% x = round(x*4)/4;
% z = pa_zscore(y);
% u1 = unique(x);
% nu1 = numel(u1);
% mu = NaN(nu1,1);
% sd = mu;
% for ii = 1:nu1
% 	sel = x==u1(ii);
% 	mu(ii) = mean(z(sel));
% 	sd(ii) = std(z(sel));	
% end
% 
% errorbar(u1,mu,sd,'ko-','MarkerFaceColor','w');
% axis square;
% box off;
% xlim([-3 3]);
% ylim([-3 3]);
% pa_unityline('k:');
% pa_horline(0,'k:');
% set(gca,'TickDir','out','Xtick',-2:2,'Ytick',-2:2);
% xlabel('Target azimuth (deg)');
% ylabel('Response azimuth (deg)');
% 
% subplot(122)
% 
% x = pa_zscore(xMet2);
% x = round(x*4)/4;
% z = pa_zscore(y);
% u1 = unique(x);
% nu1 = numel(u1);
% mu = NaN(nu1,1);
% sd = mu;
% for ii = 1:nu1
% 	sel = x==u1(ii);
% 	mu(ii) = mean(z(sel));
% 	sd(ii) = std(z(sel));	
% end
% 
% errorbar(u1,mu,sd,'ko-','MarkerFaceColor','w');
% axis square;
% box off;
% xlim([-3 3]);
% ylim([-3 3]);
% pa_unityline('k:');
% pa_horline(0,'k:');
% set(gca,'TickDir','out','Xtick',-2:2,'Ytick',-2:2);
% xlabel('Head shadow + sound level (dB)');
% ylabel('Response azimuth (deg)');


% return
%%
model = 'model.txt';
pa_bayes_ancovamodel(model);

%%
Ntotal	= length(y);
Nx1Lvl	= length(unique(x1));

% Normalize, for JAGS MCMC sampling, e.g. to use cauchy(0,1) prior
[z,My,SDy]		= pa_zscore(y');
[z1,Mx1,SDx1]	= pa_zscore(xMet1');
[z2,Mx2,SDx2]	= pa_zscore(xMet2');
% z = y';
% z1 = xMet1';
% z2 = xMet2';


%% Data
dataStruct.y		= z';
dataStruct.x1		= x1;
dataStruct.xMet1	= z1';
dataStruct.xMet2	= z2';
dataStruct.Ntotal	= Ntotal;
dataStruct.Nx1Lvl	= Nx1Lvl;

%% INTIALIZE THE CHAINS
b = regstats(dataStruct.y,[dataStruct.xMet1 dataStruct.xMet2],'linear','beta');
aMet0 = b.beta(1);
aMet1 = b.beta(2);
aMet2 = b.beta(3);


nChains		= 4;
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).aMet0			= aMet0;
	initsStruct(ii).aMet1			= repmat(aMet1,9,1)';
	initsStruct(ii).aMet2			= repmat(aMet2,9,1)';
	initsStruct(ii).aMet0prior		= aMet0;
	initsStruct(ii).aMet1prior		= repmat(aMet1,9,1)';
	initsStruct(ii).aMet2prior		= repmat(aMet2,9,1)';
	initsStruct(ii).sigma			= nanstd(dataStruct.y)/2; % lazy
end

%% RUN THE CHAINS
parameters		= {'aMet0','aMet1','aMet2'}; % The parameter(s) to be monitored.
burnInSteps		= 1000;		% Number of steps to 'burn-in' the samplers.
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
[samples,stats,structArray] = pa_matjags(...
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

% keyboard

%%
figure
subplot(231)
plotPost(samples.aMet0(:));

subplot(232)
plotPost(samples.aMet1(:));
% xlim([0 1]);

subplot(233)
plotPost(samples.aMet2(:));
% xlim([0 1]);


% keyboard
%%
% close all
aMet0			= samples.aMet0;
		chainLength = length(samples.aMet0);
aMet1			= reshape(samples.aMet1,nChains*chainLength,Nx1Lvl);
aMet2			= reshape(samples.aMet2,nChains*chainLength,Nx1Lvl);

subplot(234)
hold on
col = pa_statcolor(Nx1Lvl,[],[],[],'def',2);
% col = jet(9);
for ii = 1:Nx1Lvl
% plot(aMet1,aMet2,'.');
 [MU,SD,A] = pa_ellipse(aMet1(:,ii),aMet2(:,ii));
 pa_ellipseplot(MU,SD,A,'Color',col(ii,:));
text(MU(1),MU(2),num2str(ii),'HorizontalAlignment','center');
end
xlim([-0.2 1.2]);
ylim([-0.2 1.2]);
axis square
box off
set(gca,'TickDir','out');
pa_revline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');

%%
subplot(235)
plotPost(samples.aMet1(:)*SDy/SDx1);
% xlim([0 1]);

subplot(236)
plotPost(samples.aMet2(:)*SDy/SDx2);
% xlim([0 5]);

return
figure
% subplot(121
n = numel(samples.aMet0(:));
for ii = 1:100:n
	b0 = (samples.aMet0(ii) * SDy + My - samples.aMet1(ii)*SDy*Mx1/SDx1 - samples.aMet2(ii)*SDy*Mx2/SDx2 );
	b1 = samples.aMet1(ii)*SDy/SDx1;
	b2 = samples.aMet2(ii)*SDy/SDx2;
ypred = b0 +b1*xMet1+b2*xMet2;
h = scatter(xMet1,ypred,30,xMet2,'filled');
ylim([-90 90]);
xlim([-90 90]);
hold on

h = scatter(xMet1,y,70,xMet2,'filled');
set(h,'MarkerEdgeColor','k');
axis square;
box off
set(gca,'TickDir','out');
ylim([-90 90]);
xlim([-90 90]);

% subplot(122)
hold on


% 	h = scatter(T,R,70,I,'filled');

end
axis square;
box off
set(gca,'TickDir','out');

function [y,x1,x2,s] = getdata


fnames	= {'bn01','cd01','gk01','ie01','jp03','ld01','po01','rh01','sb01'};
d		= {'l';'r';'r';'l';'r';'r';'r';'l';'r';};
con		= [0 1 0 1 1 1 0 1 1];

n  = numel(fnames);
gain = NaN(n,1);
B = NaN(n,9,2);
y = [];
x1 = [];
x2 = [];
s = [];
for ii = 1:9
	if strcmpi(fnames{ii},'rh01')
		SupSac = consider('rh01','adapt'); %#ok<*NASGU>
		splittom;
		HP		= BB;
		stim	= 'HP';
		% stim = 'BB';
		
	else
		SupSac  = consider(fnames{ii},d{ii});
		sel     = SupSac(:,26)==2;
		stim	= 'HP';
		% stim = 'BB';
		if sum(sel)==0
			sel     = SupSac(:,26)==2;
			stim = 'HP';
			
		end
		HP      = SupSac(sel,:);
	end
	R = HP(:,8);
	T = HP(:,23);
	d(ii)
	switch d{ii}
		case 'r'
			R = -R;
			T = -T;
	end
	I = 90+HP(:,25);
	minI = min(I);
	switch minI
		case 27
			I = I+3;
		case 32
			I = I-2;
		case 29
			I = I+1;
		otherwise
			I = HP(:,27);
	end
	
	
HSE = 9.7*sin(0.02*T+0.27);
y	= [y;R]; %#ok<*AGROW>
x1	= [x1;T];
x2	= [x2;I+HSE];
s = [s;repmat(ii,size(R))];
end





function mens(dirname,expname)

% MENS(DIRNAME,EXPNAME)
%
%   Jumps to the human data-directory, DIRNAME and EXPNAME are optional
%   parameters:
%
%   cd /data/auditief/marc/data/adaptmold/
%    OR
%   cd /data/auditief/marc/data/adaptmold/DIRNAME
%    OR
%   cd /data/auditief/marc/data/EXPNAME/DIRNAME
%
%   See also AAP, HRTF
%   Ereated by: Marcus
%   Ereated at: 04-10-2002

% First check if

if     nargin==0,
	cd(['E:\DATA\'])
elseif nargin==1
	cd(['E:\DATA\Monaural Localization\' dirname])
elseif nargin==2
	if ~strcmpi(expname,'plug') && ~strcmpi(expname,'owl');
		cd(['E:\DATA\Monaural Localization\' dirname])
	else
		k=strfind(dirname,'-');
		session = dirname(1:k(2)-1);
		cd(['E:\DATA\Monaural Localization\' session '\' dirname])
	end
end

function [SupSac]=consider(subject,exp,wie)
% SUPSAC = CONSIDER(SUBJECT,EXP,WIE)
%
% This function combines all Sac-matrices of one session, and makes use of
% the SUPERSAC-function (thereby adding STIM-information).
% SUBJECT should be the session's name according to convention.
% If the batch-file SPLIT is to be used afterwards (which is standard
% practice), SUPSAC should be written literally as 'SupSac' in the MATLAB
% forum.
% FIRSTSAC is also applied to the SUPSAC-matrix.
% EXPERIMENTER is the name (string) of the experimenter's personal directory on the
% data-disk 'Augustus' or 'R\auditief:' (default: marc).
%
% See also SUPERSAC, MENS
%
% Created by: Marcus
% Created at: 01-01-2002

wd   = cd;
if nargin==1,
	mens(subject)
elseif nargin ==2
	mens(subject,exp)
elseif nargin==3,
	if isunix
		eval(['cd /data/auditief/' wie '/data/' exp '/' subject])
	else
		eval(['cd r:\' wie '\data\' exp '\' subject])
	end
end

w    = what;
file = w.mat;
n    = size(file,1);


for i=1:n,
	matfile=file{i};
	loadstr=['s' num2str(i) '=load([matfile]);'];
	eval(loadstr)
	sacstr=['Sac' num2str(i) '=s' num2str(i) '.Sac;'];
	eval(sacstr)
	stimstr=['Stim' num2str(i) '=s' num2str(i) '.Stim;'];
	eval(stimstr)
end

Sac=Sac1;
Stim=Stim1;
for j=2:n,
	Sacstr1=['Sac' num2str(j) '(:,1)=Sac' num2str(j) '(:,1)+' ...
		' Stim(size(Stim,1),1);'];
	eval(Sacstr1);
	Sacstr=['Sac=[Sac;Sac' num2str(j) '];'];
	eval(Sacstr)
	Stimstr1=['Stim' num2str(j) '(:,1)=Stim' num2str(j) '(:,1)+' ...
		' Stim(size(Stim,1),1);'];
	eval(Stimstr1)
	Stimstr=['Stim=[Stim;Stim' num2str(j) '];'];
	eval(Stimstr)
end

cd(wd)

SupSac=supersac(Sac,Stim);
SupSac=firstsac(SupSac);

%
% if ispc
% 	dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' model ' &']);
% end



