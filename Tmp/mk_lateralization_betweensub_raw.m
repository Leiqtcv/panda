function [S] = mk_lateralization_betweensub_raw
% Enter subjects of lateralization ripple test
% Plot mean reaction time per velocity for all subjects togethers
% Plot mean reaction time per density for all subjects together
% Plot mean reaction per ripple for each protocol apart for all subjects
% together

clc
close all

d = 'C:\DATA\Ripple';
cd(d);

subnames = {'sub1' 'sub2' 'sub4' 'sub6' 'sub8' 'sub12' 'sub13' 'sub14'};
%subnames = {'sub2' 'sub4' 'sub12'}; %vrouwen
%subnames = {'sub1' 'sub6' 'sub8' 'sub13' 'sub14'}; %mannen

%% Get data for each subject apart
S       = struct([]); %structure for data all subjects together
nSub    = length(subnames);

for ii=1:nSub
    subname = subnames{ii};
     S(ii).sub = subname;
     % data mean rt per ripple
    [S(ii).R,S(ii).V,S(ii).D,S(ii).VD, S(ii).ND] = mk_lateralization_getdata_subject(subname);
end

close all hidden;
mk_plot(S);


function mk_plot(S)
nsub    = size(S,2);
vel     = S(1).ND.rr.v;
dens    = S(1).ND.rr.d;
nvel    = numel(vel);
ndens   = numel(dens);

%% Plot not detected per ripple
arr1 = zeros(nvel,ndens,nsub);
arr2 = zeros(nvel,ndens,nsub);
arr3 = zeros(nvel,ndens,nsub);
arr4 = zeros(nvel,ndens,nsub);

for ii =1:nsub
    arr1(:,:,ii) = [S(ii).ND.rr.ndt];
    arr2(:,:,ii) = [S(ii).ND.rl.ndt];
    arr3(:,:,ii) = [S(ii).ND.lr.ndt];
    arr4(:,:,ii) = [S(ii).ND.ll.ndt];
end

ndtrr = sum(arr1,3);
ndtrl = sum(arr2,3);
ndtlr = sum(arr3,3);
ndtll = sum(arr4,3);

%rr
figure(111)
imagesc(vel,dens, ndtrr');
axis square
c = colorbar;
ylabel(c, 'Not Detected, max 40','fontsize',16);
caxis([0 5*nsub])
set(gca,'YTick',[0 2 4 6 8], 'YTickLabel',fliplr(dens),'fontsize',14);
set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Density (cyc/oct)','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
str = 'Right ear, Right hand';
title(str,'fontsize',16);

str = 'all_ndt3d_rr';
print('-dpng', str)

%rl
figure(112)
imagesc(vel, dens, ndtrl');
axis square
c = colorbar;
ylabel(c, 'Not Detected, max 40','fontsize',16);
caxis([0 5*nsub])
set(gca,'YTick',[0 2 4 6 8], 'YTickLabel',fliplr(dens),'fontsize',14);
set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Density (cyc/oct)','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
str = 'Right ear, Left hand';
title(str,'fontsize',16);

str = 'all_ndt3d_rl';
print('-dpng', str)

%lr
figure(113)
imagesc(vel,dens, ndtlr');
axis square
c = colorbar;
ylabel(c, 'Not Detected, max 40','fontsize',16);
caxis([0 5*nsub])
set(gca,'YTick',[0 2 4 6 8], 'YTickLabel',fliplr(dens),'fontsize',14);
set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Density (cyc/oct)','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
str = 'Left ear, Right hand';
title(str,'fontsize',16);

str = 'all_ndt3d_lr';
print('-dpng', str)

%ll
figure(114)
imagesc(vel, dens, ndtll');
axis square
c = colorbar;
ylabel(c, 'Not Detected, max 40','fontsize',16);
caxis([0 5*nsub])
set(gca,'YTick',[0 2 4 6 8], 'YTickLabel',fliplr(dens),'fontsize',14);
set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Density (cyc/oct)','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
str ='Left ear, Left hand';
title(str,'fontsize',16);

str = 'all_ndt3d_ll';
print('-dpng', str)

%% Plot mean rt per ripple
arr1 = zeros(nvel,ndens,nsub);
arr2 = zeros(nvel,ndens,nsub);
arr3 = zeros(nvel,ndens,nsub);
arr4 = zeros(nvel,ndens,nsub);

for ii =1:nsub
    arr1(:,:,ii) = S(ii).VD.rr.mu;
    arr2(:,:,ii) = S(ii).VD.rl.mu;
    arr3(:,:,ii) = S(ii).VD.lr.mu;
    arr4(:,:,ii) = S(ii).VD.ll.mu;
end
murr = nanmean(arr1,3);
murl = nanmean(arr2,3); 
mulr = nanmean(arr3,3);
mull = nanmean(arr4,3);

%rr
figure(221)
imagesc(vel, dens, murr');
axis square
c = colorbar;
ylabel(c, 'Reaction Time','fontsize',16);
caxis([300 500])
set(gca,'YTick',[0 2 4 6 8], 'YTickLabel',fliplr(dens),'fontsize',14);
set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Density (cyc/oct)','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
str = 'Right ear, right hand';
title(str,'fontsize',16);

str = 'all_rt3d_rr';
print('-dpng', str)

%rl
figure(222)
imagesc(vel, dens, murl');
axis square
c = colorbar;
ylabel(c, 'Reaction Time','fontsize',16);
caxis([300 550])
set(gca,'YTick',[0 2 4 6 8], 'YTickLabel',fliplr(dens),'fontsize',14);
set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Density (cyc/oct)','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
str = 'Right ear, left hand';
title(str,'fontsize',16);

str = 'all_rt3d_rl';
print('-dpng', str)

%lr
figure(223)
imagesc(vel, dens, mulr');
axis square
c = colorbar;
ylabel(c, 'Reaction Time','fontsize',16);
caxis([300 550])
set(gca,'YTick',[0 2 4 6 8], 'YTickLabel',fliplr(dens),'fontsize',14);
set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Density (cyc/oct)','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
str = 'Left ear, right hand';
title(str,'fontsize',16);

str = 'all_rt3d_lr';
print('-dpng', str)

%ll
figure(224)
imagesc(vel, dens, mull');
axis square
c = colorbar;
ylabel(c, 'Reaction Time','fontsize',16);
caxis([300 500])
set(gca,'YTick',[0 2 4 6 8], 'YTickLabel',fliplr(dens),'fontsize',14);
set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Density (cyc/oct)','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
str = 'Left ear, left hand';
title(str,'fontsize',16);

str = 'all_rt3d_ll';
print('-dpng', str)
