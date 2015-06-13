%% Clean
close all
clear all
clc

%% File and directory names
fnames = {'LR-1701-2013-09-30';'LR-1702-2013-09-30';'LR-1703-2013-10-14';...
	'LR-1704-2013-10-14';'LR-1705-2013-10-14';'LR-1706-2013-10-16';...
	'LR-1707-2013-10-16';'LR-1708-2013-10-17';'LR-1709-2013-10-17';...
	'LR-1710-2013-10-18';'LR-1711-2013-10-18';'LR-1712-2013-10-21';...
	'LR-1713-2013-10-23';'LR-1714-2013-10-23';'LR-1715-2013-10-28';...
	'LR-1716-2013-11-05';'LR-1717-2013-11-05';'LR-1718-2013-11-06';...
	'LR-1719-2013-11-07'}; % all subjects files
nfiles = numel(fnames); % How many files?
datfolder = '/Users/marcw/DATA/NIRS/Luuk/';
str = char(['Number of files: ' num2str(nfiles)],'Is this correct?'); % Check for number of files
disp(str);

%% Load data
P = struct([]); % Pool of subjects parameters
for ii = 1:nfiles
	fname   = fnames{ii}; % current filename
	d       = [datfolder fname(1:7)]; % Go to data folder
	cd(d)
	
	f = [fname '-param.mat']; % filename of parameter file
	load(f); % load
	P(ii).param = param; % put in structure
end

% P is nfiles x 1 structure with
% Field param:
% 1 - V
% 2 - AV
% 3 - A
% Field chan
% 1- OHb Right
% 2- OHb Left
% 3- HHb Right
% 4- HHb Left
% field max = maximum mean value

nmod    = 3; % sensory modality
nchan   = 4;

M = NaN(nfiles,nmod,nchan,356); % 406 is hardcore set
for ii = 1:nfiles
	for jj = 1:nmod
		for kk = 1:nchan
			tmp = P(ii).param(jj).chan(kk).mu;
			whos tmp
			M(ii,jj,kk,:) = tmp;
		end
	end
end

%% What do we want to know
% Lets pool every subject for all 3 modalities A,V and AV
nmod     = {'V','AV','A'};
chanlabel = {'OHb Left';'OHb Right';'HHb Left';'HHb Right'};
label = {'Right','Left'}; % Tx1/2, T4 (10/20 system) / Tx3/4, T3 (10/20 system)
col     = pa_statcolor(3,[],[],[],'def',1);
% col = ['r';'b';'g'];
col1     = pa_statcolor(3,[],[],[],'def',1);
col1 = col1([1 3 2],:);
col2     = pa_statcolor(3,[],[],[],'def',2);
col2 = col2([1 3 2],:);
for jj = 1:4
    h = NaN(3,1);
    for ii = 1:3
	A	= squeeze(M(:,ii,jj,:));
	
	mu = mean(A);
	[m,n] = size(A);
	se = std(A)./sqrt(m);
	
	time = (1:length(A))/10;
	
%         block				= [CHAN(jj).block.(char(sensmod(ii)))]'; % Dynamic field names!!
%         fd					= nirs.fsdown;
%         mu					= nanmean(block);
%         sd					= nanstd(block);
%         t					= (1:length(mu))/fd;
%         n					= size(block,1);
%         param(ii).chan(jj).mu		= mu;
%         param(ii).chan(jj).sd		= sd;
%         param(ii).chan(jj).se		= sd./sqrt(n);
%         param(ii).chan(jj).time		= t;
%         [param(ii).chan(jj).max,indx]	= max(mu);
%         param(ii).chan(jj).sdatmax  = sd(indx);
%         param(ii).chan(jj).snr      = max(mu)/sd(indx);
%         param(ii).chan(jj).maxt		= indx/fd-10; % remove first 10 ms = 100 samples before stimulus onset
%         param(ii).chan(jj).sensmodality	= sensmod{ii};
        figure(666)
		sb = mod(jj,2)+1;
		if sb==1
			col = col1;
		else
			col = col2;
			end
        subplot(1,2,sb)
        hold on
		mn = ((jj>2)-0.5)*0.3;
        h(ii) = pa_errorpatch(time+(ii-1)*45,mu-mn,se,col(ii,:));
		
		if mn<0
		t = (ii-1)*45;
		x = [t+10 t+10 t+30 t+30];
		y = [-mn 0.5 0.5 -mn];
		h = patch(x,y,col(ii,:));
		alpha(h,0.2);
		else
		t = (ii-1)*45;
		x = [t+10 t+10 t+30 t+30];
		y = [-0.5 -mn -mn -0.5];
		h = patch(x,y,col(ii,:));
		alpha(h,0.2);
		end
		xlim([-10 140]);

		pa_horline(mn,'k-');
    end
    ylim([-0.5 0.5]);
    box off
    axis square
    set(gca,'TickDir','out','XTick',[10 30 55 75 100 120],'XTickLabel',[0 20 0 20 0 20],...
		'YTick',[-0.45 -0.35 -0.25 -0.15 0.15 0.25 0.35 0.45],'YTickLabel',...
		[-0.3 -0.2 -0.1 0 0 0.1 0.2 0.3]);
%     pa_verline(10,'k:');
%     pa_verline(30,'k:');
%     pa_horline(0,'k:');
    xlabel('Time (s)');
    ylabel('Relative O_2Hb HHb concentration (\muM)'); % What is the correct label/unit
%     legend(h,sensmod,'Location','NW');
    title(chanlabel{jj});
    % figure;
    % plot(t,block','k-','Color',[.7 .7 .7])
end

return
%%
pa_datadir;
print('-depsc','-painter',mfilename);
% return
% 
h = NaN(3,1);
for ii = 1:2
	V	= squeeze(M(:,1,ii,:));
	AV	= squeeze(M(:,2,ii,:));
	A	= squeeze(M(:,3,ii,:));
	
	muA = mean(A);
	[m,n] = size(A);
	sdA = std(A)./sqrt(m);
	
	time = (1:length(A))/10;
	subplot(2,2,ii);
	hold on
	h(3) = pa_errorpatch(time,muA,sdA,col(3,:));
	
	
	muV = mean(V);
	[m,n] = size(V);
	sdV = 1.96*std(V)./sqrt(m);
	
	time = (1:length(V))/10;
	subplot(2,2,ii);
	hold on
	h(1) = pa_errorpatch(time,muV,sdV,col(1,:));
	
	
	muAV = mean(AV);
	[m,n] = size(AV);
	sdAV = 1.96*std(AV)./sqrt(m);
	
	time = (1:length(AV))/10;
	subplot(2,2,ii);
	hold on
	h(2) = pa_errorpatch(time,muAV,sdAV,col(2,:));
	
	xlim([min(time) max(time)]);
	ylim([-0.2 0.4]);
	box off
	axis square
	set(gca,'TickDir','out');
	pa_verline(10,'k:');
	pa_verline(30,'k:');
	pa_horline(0,'k:');
	xlabel('Time (s)');
	ylabel('Concentration (\muM)'); % What is the correct label/unit
	legend (h,nmod,'Location','NW');
	title(chanlabel{ii});
end


%% What do we want to know (2)
nmod     = {'V','AV','A'};
chanlabel = {'OHb Left';'OHb Right';'HHb Left';'HHb Right'};
label = {'Right','Left'}; % Tx1/2, T4 (10/20 system) / Tx3/4, T3 (10/20 system)
col     = pa_statcolor(3,[],[],[],'def',1);
h = NaN(3,1);

for ii = 3:4
	V = squeeze(M(:,1,ii,:));
	AV = squeeze(M(:,2,ii,:));
	A = squeeze(M(:,3,ii,:));
	
	muA = mean(A);
	[m,n] = size(A);
	sdA = 1.96*std(A)./sqrt(m);
	
	time = (1:length(A))/10;
	subplot(2,2,ii);
	hold on
	h(3) = pa_errorpatch(time,muA,sdA,col(3,:));
	
	
	muV = mean(V);
	[m,n] = size(V);
	sdV = 1.96*std(V)./sqrt(m);
	
	time = (1:length(V))/10;
	subplot(2,2,ii);
	hold on
	h(1) = pa_errorpatch(time,muV,sdV,col(1,:));
	
	
	muAV = mean(AV);
	[m,n] = size(AV);
	sdAV = 1.96*std(AV)./sqrt(m);
	
	time = (1:length(AV))/10;
	subplot(2,2,ii);
	hold on
	h(2) = pa_errorpatch(time,muAV,sdAV,col(2,:));
	
	xlim([min(time) max(time)]);
	ylim([-0.2 0.4]);
	box off
	axis square
	set(gca,'TickDir','out');
	pa_verline(10,'k:');
	pa_verline(30,'k:');
	pa_horline(0,'k:');
	xlabel('Time (s)');
	ylabel('Concentration (\muM)'); % What is the correct label/unit
	legend (h,nmod,'Location','NW');
	title(chanlabel{ii});
end
