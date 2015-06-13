function [S] = mk_lateralization_betweensub_spectrotemporal
% Input: Subjects of hemisphere ripplequest experiment
% Output: structure S with output from mk_lateralization_getdata_subject 
%          for each listener

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
    [S(ii).R,S(ii).V,S(ii).D,S(ii).VD,S(ii).ND] = mk_lateralization_getdata_subject(subname);
end

close all hidden;
mk_plot(S);


function mk_plot(S)
% Plot mean reaction time - velocity for spectrotemporal modulations

col     = cool(4);
nsub    = size(S,2);
vel     = S(1).V.rr.v;
v       = vel;
nvel    = numel(v);
for i=1:numel(v)
    if v(i) < 0
        v(i) = -log2(abs(v(i)));
    end
    if v(i) == 0
        v(i) = 0;
    end
    if v(i) > 0 
        v(i) = log2(abs(v(i)));
    end
end

%rr
arr1 = NaN(nsub,nvel);
arr2 = NaN(nsub,nvel);
arr3 = NaN(nsub,nvel);
arr4 = NaN(nsub,nvel);

for ii =1:nsub
    arr1(ii,:) = S(ii).V.rr.mu0;
    arr2(ii,:) = S(ii).V.rr.mu1;
    arr3(ii,:) = S(ii).V.rr.mu2;
    arr4(ii,:) = S(ii).V.rr.mu4;
end

u0		= repmat(nanmean(arr1,2),1,size(arr1,2));
u1		= repmat(nanmean(arr2,2),1,size(arr2,2));
u2		= repmat(nanmean(arr3,2),1,size(arr3,2));
u4		= repmat(nanmean(arr4,2),1,size(arr4,2));

mu0     = nanmean(arr1);
se0     = nanstd(arr1-u0,[],1)./nsub;
mu1     = nanmean(arr2);
se1     = nanstd(arr2-u1,[],1)./nsub;
mu2     = nanmean(arr3);
se2     = nanstd(arr3-u2,[],1)./nsub;
mu4     = nanmean(arr4);
se4     = nanstd(arr4-u4,[],1)./nsub;
mu4rr   = mu4;
% se4rr   = se4;

figure(1)
errorbar(v,mu0,se0,'kv-','LineWidth',2,'MarkerFaceColor',col(1,:),'Color',col(1,:));
hold on
errorbar(v,mu1,se1,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(2,:));
hold on
errorbar(v,mu2,se2,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(3,:));
hold on
errorbar(v,mu4,se4,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(4,:));
hold on 
plot(v(1),mu1(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))
hold on 
plot(v(1),mu2(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))
hold on 
plot(v(1),mu4(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))

set(gca,'XTick',v,'XTickLabel',vel);
xlabel('Velocity (Hz)');
ylabel('Mean reaction time (ms)');
xlim([0 log2(128)]);
ylim([300 750]);
axis square;
title('Mean RT per velocity; Right Ear, Right Hand')
legend({'Density = 0';'Density = 1';'Density = 2';'Density = 4'});

str = 'all_lateralization_spectrotemporalrr';
print('-dpng', str)

%rl
arr1 = NaN(nsub,nvel);
arr2 = NaN(nsub,nvel);
arr3 = NaN(nsub,nvel);
arr4 = NaN(nsub,nvel);

for ii =1:nsub
    arr1(ii,:) = S(ii).V.rl.mu0;
    arr2(ii,:) = S(ii).V.rl.mu1;
    arr3(ii,:) = S(ii).V.rl.mu2;
    arr4(ii,:) = S(ii).V.rl.mu4;
end

u0		= repmat(nanmean(arr1,2),1,size(arr1,2));
u1		= repmat(nanmean(arr2,2),1,size(arr2,2));
u2		= repmat(nanmean(arr3,2),1,size(arr3,2));
u4		= repmat(nanmean(arr4,2),1,size(arr4,2));

mu0     = nanmean(arr1);
se0     = nanstd(arr1-u0,[],1)./nsub;
mu1     = nanmean(arr2);
se1     = nanstd(arr2-u1,[],1)./nsub;
mu2     = nanmean(arr3);
se2     = nanstd(arr3-u2,[],1)./nsub;
mu4     = nanmean(arr4);
se4     = nanstd(arr4-u4,[],1)./nsub;
mu4rl   = mu4;
% se4rl   = se4;

figure(2)
errorbar(v,mu0,se0,'kv-','LineWidth',2,'MarkerFaceColor',col(1,:),'Color',col(1,:));
hold on
errorbar(v,mu1,se1,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(2,:));
hold on
errorbar(v,mu2,se2,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(3,:));
hold on
errorbar(v,mu4,se4,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(4,:));
hold on 
plot(v(1),mu1(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))
hold on 
plot(v(1),mu2(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))
hold on 
plot(v(1),mu4(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))

set(gca,'XTick',v,'XTickLabel',vel);
xlabel('Velocity (Hz)');
ylabel('Mean reaction time (ms)');
xlim([0 log2(128)]);
ylim([300 750]);

axis square;
title('Mean RT per velocity; Right Ear, Left Hand')
legend({'Density = 0';'Density = 1';'Density = 2';'Density = 4'});

str = 'all_lateralization_spectrotemporalrl';
print('-dpng', str)

%lr
arr1 = NaN(nsub,nvel);
arr2 = NaN(nsub,nvel);
arr3 = NaN(nsub,nvel);
arr4 = NaN(nsub,nvel);

for ii =1:nsub
    arr1(ii,:) = S(ii).V.lr.mu0;
    arr2(ii,:) = S(ii).V.lr.mu1;
    arr3(ii,:) = S(ii).V.lr.mu2;
    arr4(ii,:) = S(ii).V.lr.mu4;
end

u0		= repmat(nanmean(arr1,2),1,size(arr1,2));
u1		= repmat(nanmean(arr2,2),1,size(arr2,2));
u2		= repmat(nanmean(arr3,2),1,size(arr3,2));
u4		= repmat(nanmean(arr4,2),1,size(arr4,2));

mu0     = nanmean(arr1);
se0     = nanstd(arr1-u0,[],1)./nsub;
mu1     = nanmean(arr2);
se1     = nanstd(arr2-u1,[],1)./nsub;
mu2     = nanmean(arr3);
se2     = nanstd(arr3-u2,[],1)./nsub;
mu4     = nanmean(arr4);
se4     = nanstd(arr4-u4,[],1)./nsub;
mu4lr   = mu4;
% se4lr   = se4;

figure(3)
errorbar(v,mu0,se0,'kv-','LineWidth',2,'MarkerFaceColor',col(1,:),'Color',col(1,:));
hold on
errorbar(v,mu1,se1,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(2,:));
hold on
errorbar(v,mu2,se2,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(3,:));
hold on
errorbar(v,mu4,se4,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(4,:));
hold on 
plot(v(1),mu1(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))
hold on 
plot(v(1),mu2(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))
hold on 
plot(v(1),mu4(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))

set(gca,'XTick',v,'XTickLabel',vel);
xlabel('Velocity (Hz)');
ylabel('Mean reaction time (ms)');
xlim([0 log2(128)]);
ylim([300 750]);
axis square;
title('Mean RT per velocity; Left Ear, Right Hand')
legend({'Density = 0';'Density = 1';'Density = 2';'Density = 4'});

str = 'all_lateralization_spectrotemporallr';
print('-dpng', str)

%ll
arr1 = NaN(nsub,nvel);
arr2 = NaN(nsub,nvel);
arr3 = NaN(nsub,nvel);
arr4 = NaN(nsub,nvel);

for ii =1:nsub
    arr1(ii,:) = S(ii).V.ll.mu0;
    arr2(ii,:) = S(ii).V.ll.mu1;
    arr3(ii,:) = S(ii).V.ll.mu2;
    arr4(ii,:) = S(ii).V.ll.mu4;
end

u0		= repmat(nanmean(arr1,2),1,size(arr1,2));
u1		= repmat(nanmean(arr2,2),1,size(arr2,2));
u2		= repmat(nanmean(arr3,2),1,size(arr3,2));
u4		= repmat(nanmean(arr4,2),1,size(arr4,2));

mu0     = nanmean(arr1);
se0     = nanstd(arr1-u0,[],1)./nsub;
mu1     = nanmean(arr2);
se1     = nanstd(arr2-u1,[],1)./nsub;
mu2     = nanmean(arr3);
se2     = nanstd(arr3-u2,[],1)./nsub;
mu4     = nanmean(arr4);
se4     = nanstd(arr4-u4,[],1)./nsub;
mu4ll   = mu4;
% se4ll   = se4;

figure(4)
errorbar(v,mu0,se0,'kv-','LineWidth',2,'MarkerFaceColor',col(1,:),'Color',col(1,:));
hold on
errorbar(v,mu1,se1,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(2,:));
hold on
errorbar(v,mu2,se2,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(3,:));
hold on
errorbar(v,mu4,se4,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(4,:));
hold on 
plot(v(1),mu1(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))
hold on 
plot(v(1),mu2(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))
hold on 
plot(v(1),mu4(1),'v','MarkerSize',10,'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:))

set(gca,'XTick',v,'XTickLabel',vel);
xlabel('Velocity (Hz)');
ylabel('Mean reaction time (ms)');
xlim([0 log2(128)]);
ylim([300 750]);
axis square;
title('Mean RT per velocity; Left Ear, Left Hand')
legend({'Density = 0';'Density = 1';'Density = 2';'Density = 4'});

str = 'all_lateralization_spectrotemporalll';
print('-dpng', str)

mu4 = nanmean([mu4rr;mu4rl;mu4lr;mu4ll]);
figure(5)
plot(v,mu4)
set(gca,'XTick',v,'XTickLabel',vel);
xlabel('Velocity (Hz)');
ylabel('Mean reaction time (ms)');
xlim([0 log2(128)]);
ylim([300 750]);
title('Mean RT per velocity')
legend('Density = 4');

str = 'all_lateralization_spectrotemporald4';
print('-dpng', str)


