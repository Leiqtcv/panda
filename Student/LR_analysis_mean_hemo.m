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
datfolder = 'Z:\Student\Luuk van de Rijt\Data\Raw data\';
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

M = NaN(nfiles,nmod,nchan,406); % 406 is hardcore set
for ii = 1:nfiles
    for jj = 1:nmod
        for kk = 1:nchan
            tmp = P(ii).param(jj).chan(kk).mu;            
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
h = NaN(3,1);
for ii = 1:2 
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
