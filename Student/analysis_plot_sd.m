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
%% Right-side

V_oxy = squeeze(M(:,1,1));
V_deoxy = squeeze(M(:,1,3));
    
A_oxy = squeeze(M(:,3,1));
A_deoxy = squeeze(M(:,3,3));

AV_oxy = squeeze(M(:,2,1));
AV_deoxy = squeeze(M(:,2,3));

%% Left-side
V_oxy_L = squeeze(M(:,1,2));
V_deoxy_L = squeeze(M(:,1,4));
    
A_oxy_L = squeeze(M(:,3,2));
A_deoxy_L = squeeze(M(:,3,4));

AV_oxy_L = squeeze(M(:,2,2));
AV_deoxy_L = squeeze(M(:,2,4));

%% Graphics 

% Right-side
figure(1)
subplot(231)
plot(V_oxy,V_deoxy,'k.');
axis square;
box off
set(gca,'TickDir','out');
xlabel({'OHb Signal amplitude'})
ylabel({'HHb Signal amplitude'})
title('Visual responses OHb vs. HHb right')
hold on
pa_unityline
[~,p] = ttest (V_oxy,V_deoxy);
str1 = char(['p = ' num2str(p)]);
disp (str1);
text(0.05,0.35, str1);


subplot(232)
plot(A_oxy,A_deoxy,'k.');
axis square;
box off
set(gca,'TickDir','out');
xlabel({'OHb Signal amplitude'})
ylabel({'HHb Signal amplitude'})
title('Auditory responses OHb vs. HHb right')
hold on
pa_unityline
[~,p1] = ttest (A_oxy,A_deoxy);
str1 = char(['p = ' num2str(p1)]);
disp (str1);
text(0.05,0.35, str1);

subplot(233)
plot(AV_oxy,AV_deoxy,'k.');
axis square;
box off
set(gca,'TickDir','out');
xlabel({'OHb Signal amplitude'})
ylabel({'HHb Signal amplitude'})
title('Audiovisual responses OHb vs. HHb right')
hold on
pa_unityline
[~,p2] = ttest (AV_oxy,AV_deoxy);
str1 = char(['p = ' num2str(p2)]);
disp (str1);
text(0.05,0.35, str1);

   
% Left-side  

subplot(234)
plot(V_oxy_L,V_deoxy_L,'k.');
axis square;
box off
set(gca,'TickDir','out');
xlabel({'OHb Signal amplitude'})
ylabel({'HHb Signal amplitude'})
title('Visual responses OHb vs. HHb left')
hold on
pa_unityline
[~,p4] = ttest (V_oxy_L,V_deoxy_L);
str1 = char(['p = ' num2str(p4)]);
disp (str1);
text(0.05,0.45, str1);


subplot(235)
plot(A_oxy_L,A_deoxy_L,'k.');
axis square;
box off
set(gca,'TickDir','out');
xlabel({'OHb Signal amplitude'})
ylabel({'HHb Signal amplitude'})
title('Auditory responses OHb vs. HHb left')
hold on
pa_unityline
[~,p5] = ttest (A_oxy_L,A_deoxy_L);
str1 = char(['p = ' num2str(p5)]);
disp (str1);
text(0.05,0.35, str1);


subplot(236)
plot(AV_oxy_L,AV_deoxy_L,'k.');
axis square;
box off
set(gca,'TickDir','out');
xlabel({'OHb Signal amplitude'})
ylabel({'HHb Signal amplitude'})
title('Audiovisual responses OHb vs. HHb left')
hold on
pa_unityline
[h,p6] = ttest (AV_oxy_L,AV_deoxy_L);
str1 = char(['p = ' num2str(p6)]);
disp (str1);
text(0.05,0.35, str1);


%% Rubbish / tried to get the SD
%  V_oxy_R   = squeeze(M(:,1,1,:));
%  AV_oxy_R  = squeeze(M(:,2,1,:));
%  A_oxy_R   = squeeze(M(:,3,1,:));
%        
%  V_oxy_L   = squeeze(M(:,1,2,:));
%  AV_oxy_L  = squeeze(M(:,2,2,:));
%  A_oxy_L   = squeeze(M(:,3,2,:));
%     
%  V_deoxy_R   = squeeze(M(:,1,3,:));
%  AV_deoxy_R  = squeeze(M(:,2,3,:));
%  A_deoxy_R   = squeeze(M(:,3,3,:));
%        
%  V_deoxy_L   = squeeze(M(:,1,4,:));
%  AV_deoxy_L  = squeeze(M(:,2,4,:));
%  A_deoxy_L   = squeeze(M(:,3,4,:));

%  %% Graphics
%     figure(1)
%     subplot(131)
%     str = ['k' mrk(ii)];
%     plot(A_oxy,A_deoxy,str,'MarkerFaceColor','w');
%     hold on
%    
    
%     subplot(132)
%     str = ['k' mrk(ii)];
%     plot(AV,A,str,'MarkerFaceColor','w');
%     hold on
%     
%     
%     subplot(133)
%     str = ['k' mrk(ii)];
%     plot(A_V,AV,str,'MarkerFaceColor','w');
%     hold on
    


% subplot(131)
% legend(label)
% axis square;
% box off
% set(gca,'TickDir','out');
% xlabel({'Concentration (\muM)'; 'Audiotory'})
% ylabel({'Visual'; 'Concentration (\muM)'})
% title('OHb (T3/Left and T4/Right)')
% pa_unityline('k:');
% 
% subplot(132)
% legend(label)
% axis square;
% box off
% set(gca,'TickDir','out');
% xlabel({'Concentration (\muM)'; 'Audiovisual'})
% ylabel({'Auditory'; 'Concentration (\muM)'})
% title('OHb (T3/Left and T4/Right)')
% pa_unityline('k:');
% 
% subplot(133)
% legend(label)
% axis square;
% box off
% set(gca,'TickDir','out');
% xlabel({'Concentration (\muM)'; 'Audiotory + Visual'})
% ylabel({'Audiovisual'; 'Concentration (\muM)'})
% title('OHb (T3/Left and T4/Right)')
% pa_unityline('k:');


% %% What do we want to know (2)
% 
% % Pooling of left and right, HHb
% 
% for ii = 3:4
%     V = squeeze(M(:,1,ii));
%     AV = squeeze(M(:,2,ii));
%     A = squeeze(M(:,3,ii));
%     A_V = A+V;
%     % Graphics
%     figure(2)
%     subplot(131)
%     str = ['k' mrk(ii)];
%     plot(A,V,str,'MarkerFaceColor','w');
%     hold on
%     
%     subplot(132)
%     str = ['k' mrk(ii)];
%     plot(AV,A,str,'MarkerFaceColor','w');
%     hold on
%     
%     subplot(133)
%     str = ['k' mrk(ii)];
%     plot(A_V,AV,str,'MarkerFaceColor','w');
%     hold on
%     
% end
% 
% subplot(131)
% legend(label)
% axis square;
% box off
% set(gca,'TickDir','out');
% xlabel({'Concentration (\muM)'; 'Audiotory'})
% ylabel({'Visual'; 'Concentration (\muM)'})
% title('HHb (T3/Left and T4/Right)')
% pa_unityline('k:');
% 
% subplot(132)
% legend(label)
% axis square;
% box off
% set(gca,'TickDir','out');
% xlabel({'Concentration (\muM)'; 'Audiovisual'})
% ylabel({'Auditory'; 'Concentration (\muM)'})
% title('HHb (T3/Left and T4/Right)')
% pa_unityline('k:');
% 
% subplot(133)
% legend(label)
% axis square;
% box off
% set(gca,'TickDir','out');
% xlabel({'Concentration (\muM)'; 'Audiotory + Visual'})
% ylabel({'Audiovisual'; 'Concentration (\muM)'})
% title('HHb (T3/Left and T4/Right)')
% pa_unityline('k:');
% 
