function [S] = mk_lateralization_betweensub_spectral
% Input: Subjects of hemisphere ripplequest experiment
% Output: structure S with output from mk_lateralization_getdata_subject 
%          for each listener

clc
close all

d = 'C:\DATA\Ripple';
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
% Plot mean reaction time - density for pure spectral modulations (velocity = 0)

nsub    = size(S,2);
d       = S(1).D.rr.d;
ndens   = numel(d);

% 0.5 = density 0
d(1)    = 0.5;

arr1 = NaN(nsub,ndens);
arr2 = NaN(nsub,ndens);
arr3 = NaN(nsub,ndens);
arr4 = NaN(nsub,ndens);

for ii =1:nsub
    arr1(ii,:) = S(ii).D.rr.mu0;
    arr2(ii,:) = S(ii).D.rl.mu0;
    arr3(ii,:) = S(ii).D.lr.mu0;
    arr4(ii,:) = S(ii).D.ll.mu0;
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

mu      = nanmean([murr;murl;mulr;mull]);

figure(1);
col = cool(4);
errorbar(d,murr,serr,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(1,:));
hold on
errorbar(d,murl,serl,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(2,:));
hold on
errorbar(d,mulr,selr,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(3,:));
hold on
errorbar(d,mull,sell,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(4,:));
hold on
plot(d,mu,'-','LineWidth',4,'MarkerFaceColor','w','Color','k');

set(gca,'XTick',d,'XTickLabel',[0 d(2:end)],'XScale','log');
xlim([0.9 5]);
%ylim([-10 150]);
xlabel('Density (cyc/oct)');
ylabel('Mean reaction time (ms)');
axis square;
title('Mean RT per density, velocity = 0')
legend({'Right ear, right hand';'Right ear, left hand';'Left ear, right hand';'Left ear, left hand'; 'Mean all conditions'});

str = 'all_lateralization_spectral';
print('-dpng', str)
