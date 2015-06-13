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
for ii = 1:4
	V	= squeeze(M(:,2,ii));
	AV	= squeeze(M(:,3,ii));
	A	= squeeze(M(:,4,ii));
	%% Graphics
	figure(1)
	subplot(121)
	
	str = ['k' mrk(ii)];
	plot(A,V,str,'MarkerFaceColor',col(ii,:),'MarkerEdgeColor','k');
	hold on
	axis([-0.6 0.6 -0.6 0.6]);
	[~,p] = ttest (A,V);
	b = regstats(V,A,'linear','beta');
% 	h = pa_regline(b.beta,'k-');
% 	set(h,'Color',col(ii,:),'LineWidth',2);
	
	subplot(122)
	str = ['k' mrk(ii)];
	plot(A+V,AV,str,'MarkerFaceColor',col(ii,:),'MarkerEdgeColor','k');
	hold on
	axis([-0.6 0.6 -0.6 0.6]);
	b = regstats(AV,A+V,'linear','beta');
% 	h = pa_regline(b.beta,'k-');
% 	set(h,'Color',col(ii,:),'LineWidth',2);
	[~,p1] = ttest (AV,A);
end
subplot(121)
legend(label)
axis square;
box off
set(gca,'TickDir','out');
xlabel({'\beta_{audio} \Delta[XHb] (\muM)'})
ylabel({'\beta_{video} \Delta[XHb] (\muM)'})
axis([-0.6 0.6 -0.6 0.6]);
pa_unityline('k:');
pa_verline(0,'k:');
pa_horline(0,'k:');

subplot(122)
% legend(label)
axis square;
box off
set(gca,'TickDir','out');
xlabel({'\beta_{audio+video} \Delta[XHb] (\muM)'})
ylabel({'\beta_{av} \Delta[XHb] (\muM)'})
axis([-0.6 0.6 -0.6 0.6]);
pa_revline('k:');
pa_verline(0,'k:');
pa_horline(0,'k:');

pa_datadir;
print('-depsc',mfilename);
return
%% What do we want to know (2)

% Pooling of left and right, HHb

for ii = 3:4
	V = squeeze(M(:,1,ii));
	AV = squeeze(M(:,2,ii));
	A = squeeze(M(:,3,ii));
	A_V = A+V;
	% Graphics
	figure(2)
	subplot(131)
	str = ['k' mrk(ii)];
	plot(A,V,str,'MarkerFaceColor','w');
	hold on
	
	subplot(132)
	str = ['k' mrk(ii)];
	plot(AV,A,str,'MarkerFaceColor','w');
	hold on
	
	subplot(133)
	str = ['k' mrk(ii)];
	plot(A_V,AV,str,'MarkerFaceColor','w');
	hold on
	
end

subplot(131)
legend(label)
axis square;
box off
set(gca,'TickDir','out');
xlabel({'Concentration (\muM)'; 'Audiotory'})
ylabel({'Visual'; 'Concentration (\muM)'})
title('HHb (T3/Left and T4/Right)')
pa_unityline('k:');

subplot(132)
legend(label)
axis square;
box off
set(gca,'TickDir','out');
xlabel({'Concentration (\muM)'; 'Audiovisual'})
ylabel({'Auditory'; 'Concentration (\muM)'})
title('HHb (T3/Left and T4/Right)')
pa_unityline('k:');

subplot(133)
legend(label)
axis square;
box off
set(gca,'TickDir','out');
xlabel({'Concentration (\muM)'; 'Audiotory + Visual'})
ylabel({'Audiovisual'; 'Concentration (\muM)'})
title('HHb (T3/Left and T4/Right)')
pa_unityline('k:');

