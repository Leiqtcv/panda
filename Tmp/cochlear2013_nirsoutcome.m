close all
clear all
pa_datadir;
p					= 'E:\DATA\NIRS\Hai Yin\';
cd(p)
[N,T] = xlsread('subjectdates.xlsx');

phi = N(:,6);

% 
% load('petancova')
% 
% p = data(1).phoneme;
% p(1:5) = 100;
% s = data(1).SIR;
% g = data(1).group;
% whos p f
% subplot(121)
% plot(p,s+0.1*randn(size(s)),'ko','MarkerFaceColor','w','LineWidth',2)
% axis square
% box off
% xlabel('Phoneme score (%)');
% ylabel('SIR');
% xlim([-10 110]);
% ylim([0 6])
% set(gca,'TickDir','out','XTick',0:20:100,'YTick',1:5);
% title('Speech perception and production of prelingually deaf');
% pa_horline([1 5],'k:');
% 
% pa_datadir;
% print('-depsc','-painter',mfilename);

