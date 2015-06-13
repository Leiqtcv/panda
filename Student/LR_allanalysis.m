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

M = NaN(nfiles,nmod,nchan);
for ii = 1:nfiles
    for jj = 1:nmod
        for kk = 1:nchan
            M(ii,jj,kk) = P(ii).param(jj).chan(kk).max;
        end
    end
end

%% What do we want to know
% Let's pool left and right, OHb

mrk = ['o';'s';'o';'s'];
label = {'Right','Left'}; % Tx1/2, T4 (10/20 system) / Tx3/4, T3 (10/20 system)

for ii = 1:2 
    V = squeeze(M(:,1,ii));
    AV = squeeze(M(:,2,ii));
    A = squeeze(M(:,3,ii));
    A_V = A+V;
    %% Graphics
    figure(1)
    subplot(131)
    str = ['k' mrk(ii)];
    plot(A,V,str,'MarkerFaceColor','w');
    hold on
    [~,p(ii)] = ttest (A,V);
    
    subplot(132)
    str = ['k' mrk(ii)];
    plot(AV,A,str,'MarkerFaceColor','w');
    hold on
    [~,p1(ii)] = ttest (AV,A);
    
    subplot(133)
    str = ['k' mrk(ii)];
    plot(A_V,AV,str,'MarkerFaceColor','w');
    hold on
   [~,p2(ii)] = ttest (A_V,AV);

   
    
end
subplot(131)
legend(label)
axis square;
box off
set(gca,'TickDir','out');
xlabel({'Concentration (\muM)'; 'Audiotory'})
ylabel({'Visual'; 'Concentration (\muM)'})
title('OHb (T3/Left and T4/Right)')
pa_unityline('k:');

subplot(132)
legend(label)
axis square;
box off
set(gca,'TickDir','out');
xlabel({'Concentration (\muM)'; 'Audiovisual'})
ylabel({'Auditory'; 'Concentration (\muM)'})
title('OHb (T3/Left and T4/Right)')
pa_unityline('k:');

subplot(133)
legend(label)
axis square;
box off
set(gca,'TickDir','out');
xlabel({'Concentration (\muM)'; 'Audiotory + Visual'})
ylabel({'Audiovisual'; 'Concentration (\muM)'})
title('OHb (T3/Left and T4/Right)')
pa_unityline('k:');


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

