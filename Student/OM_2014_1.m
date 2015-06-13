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
	'LR-1719-2013-11-07';'LR-1720-2013-11-12';'LR-1721-2013-11-21';}; % all subjects files
nfiles = numel(fnames); % How many files?
datfolder = 'C:\DATA\Studenten\Luuk\Raw data\';
datfolder = '/Users/marcw/DATA/NIRS/Luuk/';
str = char(['Number of files: ' num2str(nfiles)],'Is this correct?'); % Check for number of files
disp(str);

%% Load data
P = struct([]); % Pool of subjects parameters
for ii = 1:nfiles
	fname   = fnames{ii}; % current filename
	d       = [datfolder fname(1:7)]; % Go to data folder
	cd(d)
	
	f = [fname '-glm.mat']; % filename of parameter file
	load(f); % load
	whos
	P(ii).glm = nirsglm; % put in structure
end

% P is nfiles x 1 structure with
% Field B:
% 0 - Bias
% 1 - V
% 2 - AV
% 3 - A
% Field SE
% 1- OHb Right
% 2- OHb Left
% 3- HHb Right
% 4- HHb Left
% field max = maximum mean value

% keyboard
nmod    = 4; % sensory modality
nchan   = 4;

M = NaN(nfiles,nmod,nchan);
for ii = 1:nfiles
	for jj = 1:nmod
		for kk = 1:nchan
			M(ii,jj,kk) = P(ii).glm.b(kk,jj);
		end
	end
end

%% What do we want to know
% Let's pool left and right, OHb

mrk		= ['o';'s';'o';'s'];
label	= {'Right O_2Hb','Left O_2Hb','Right HHb','Left HHb'}; % Tx1/2, T4 (10/20 system) / Tx3/4, T3 (10/20 system)
col1     = pa_statcolor(2,[],[],[],'def',1);
col2     = pa_statcolor(2,[],[],[],'def',2);
col = [col1(1,:);col2(1,:);col1(2,:);col2(2,:)];
k = 0;
for ii = [1 3]
	V	= [squeeze(M(:,2,ii));squeeze(M(:,2,ii+1))];
	AV	= [squeeze(M(:,3,ii));squeeze(M(:,3,ii+1));];
	A	= [squeeze(M(:,4,ii));squeeze(M(:,4,ii+1))];

	mu = [mean(V) mean(A) mean(AV+A+V)];
	sd = [std(V) std(A) std(AV+A+V)];
	sd = sd./sqrt(numel(A));
whos mu sd
k = k+1;

subplot(2,1,k)
	pa_errorbar(mu',sd','bsize',0.8);
	% 	%% Graphics
% 	figure(1)
% 	subplot(121)
% 	
% 	str = ['k' mrk(ii)];
% 	plot(A,V,str,'MarkerFaceColor',col(ii,:),'MarkerEdgeColor','k');
% 	hold on
% 	axis([-0.6 0.6 -0.6 0.6]);
% 	[~,p] = ttest (A,V);
% 	b = regstats(V,A,'linear','beta');
% % 	h = pa_regline(b.beta,'k-');
% % 	set(h,'Color',col(ii,:),'LineWidth',2);
% 	
% 	subplot(122)
% 	str = ['k' mrk(ii)];
% 	plot(A+V,AV,str,'MarkerFaceColor',col(ii,:),'MarkerEdgeColor','k');
% 	hold on
% 	axis([-0.6 0.6 -0.6 0.6]);
% 	b = regstats(AV,A+V,'linear','beta');
% % 	h = pa_regline(b.beta,'k-');
% % 	set(h,'Color',col(ii,:),'LineWidth',2);
% 	[~,p1] = ttest (AV,A);
B(k).A = A;
B(k).V = V;
B(k).AV = AV;

axis square;							% publication-quality
box off;								% publication-quality
set(gca,'TickDir','out','TickLength',[0.005 0.025],...
	'XTick',1:3,...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('Modality','FontSize',12);		% always provide an label on the x-axis
ylabel('Response','FontSize',12);	% and on the y-axis


end

%%
idx = 1;
if idx==1
x = max([B(idx).A B(idx).V]')
else
x = min([B(idx).A B(idx).V]')
end	
x = x';
y = B(idx).AV+B(idx).A+B(idx).V;
figure(4);plot(x,y,'.')
pa_unityline;
[H,p] = ttest(x,y)

%%
figure(1)
print('-depsc','-painters',mfilename);
