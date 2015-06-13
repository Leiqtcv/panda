close all
clear all
pa_datadir;
load('petancova')

p = data(1).phoneme;
p(1:5) = 100;
s = data(1).SIR;
g = data(1).group;
subplot(121)
sel = p~=100;
plot(p(sel),s(sel)+0.1*randn(size(s(sel))),'ko','MarkerFaceColor','w','LineWidth',2)
hold on
plot(p(~sel),s(~sel)+0.1*randn(size(s(~sel))),'ks','MarkerFaceColor','w','LineWidth',2)
axis square
box off
xlabel('Phoneme score (%)');
ylabel('Speech Intelligibility Rating');
xlim([-10 110]);
ylim([0 6])
set(gca,'TickDir','out','XTick',0:20:100,'YTick',1:5);
title('Speech perception and production');

%% NIRS
% close all
% clear all
pa_datadir;
p					= 'E:\DATA\NIRS\Hai Yin\';
cd(p)
[N,T] = xlsread('subjectdates.xlsx');

p = N(:,6);
s = repmat(5,size(p));
sel = p~=100;
plot(p(sel),s(sel)+0.1*randn(size(s(sel))),'kd','MarkerFaceColor','w','LineWidth',2)
plot(p(~sel),s(~sel)+0.1*randn(size(s(~sel))),'ks','MarkerFaceColor','w','LineWidth',2)

legend({'Prelingually deaf','Postlingually deaf','Normal-hearing'},'Location','SE');

pa_horline([1 5],'k:');
pa_datadir;
print('-depsc','-painter',mfilename);
