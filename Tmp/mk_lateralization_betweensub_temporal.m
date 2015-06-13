function [S] = mk_lateralization_betweensub_temporal
% Input: Subjects of hemisphere ripplequest experiment
% Output: structure S with output from mk_lateralization_getdata_subject 
%          for each listener

clc;
close all

d = 'C:\DATA\Maarten\Ripples';
cd(d);

subnames = {'sub1' 'sub2' 'sub4' 'sub6' 'sub8' 'sub12' 'sub13' 'sub14'};

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
% Plot mean reaction time - velocity for pure temporal modulations (density = 0)

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

arr1 = NaN(nsub,nvel);
arr2 = NaN(nsub,nvel);
arr3 = NaN(nsub,nvel);
arr4 = NaN(nsub,nvel);

for ii = 1:nsub
    arr1(ii,:) = (S(ii).V.rr.mu0);
    arr2(ii,:) = (S(ii).V.rl.mu0);
    arr3(ii,:) = (S(ii).V.lr.mu0);
    arr4(ii,:) = (S(ii).V.ll.mu0);
end

urr		= repmat(nanmean(arr1,2),1,size(arr1,2));
url		= repmat(nanmean(arr2,2),1,size(arr2,2));
ulr		= repmat(nanmean(arr3,2),1,size(arr3,2));
ull		= repmat(nanmean(arr4,2),1,size(arr4,2));

murr    = nanmean(arr1);
serr	= nanstd(arr1-urr,[],1)./nsub;
murl    = nanmean(arr2);
serl	= nanstd(arr2-url,[],1)./nsub;
mulr    = nanmean(arr3);
selr	= nanstd(arr3-ulr,[],1)./nsub;
mull    = nanmean(arr4);
sell	= nanstd(arr4-ull,[],1)./nsub;

figure(1)
col = cool(4);
errorbar(v,murr,serr,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(1,:));
hold on
errorbar(v,murl,serl,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(2,:));
hold on
errorbar(v,mulr,selr,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(3,:));
hold on
errorbar(v,mull,sell,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(4,:));

set(gca,'XTick',v,'XTickLabel',vel);
xlabel('Velocity (Hz)');
ylabel('Mean reaction time (ms)');
xlim([0 log2(128)]);
axis square;
title('Mean RT per velocity, density = 0')
legend({'Right ear, right hand';'Right ear, left hand';'Left ear, right hand';'Left ear, left hand'});

str = 'all_lateralization_temporal';
print('-dpng', str)