close all;

F = [0 51 3 65 7 3 15 13.5 55 70 85 30];

%% read xlsfile
fname = 'E:\Backup\PET\Misc\Protocol\Phoneme.xls'; % location of xls-file containing phonemescores

[num,txt,raw] = xlsread(fname);
n		= size(num,2)-1; % number of subjects
col		= gray(n+6); % color map
T		= [];
P		= [];
id		= num(1,:);
num		= num(3:end,:);
for ii	= 1:n
	t	= num(:,1); % months
	p	= num(:,ii+1); % phoneme score
	sel = ~isnan(p); % remove nonexisting files
	t	= t(sel);
	p	= p(sel);
	plot(t,p*100,'d-','MarkerFaceColor','w','Color',[.8 .8 .8],'LineWidth',2); % plot percentage
	hold on
	T = [T;t];
	P = [P;p];
end
% Labels and stuff
ylim([0 100]);
xlim([0 28]);
axis square;
xlabel('Time after CI implantation (months)');
ylabel('Phoneme score (%)');
box off;

%% Printing/saving figure
pa_datadir; % go to DATA directory
print('-dpng',mfilename); % create a png-figure with filename pa_pet_phoneme

% figure;
% subplot(211)
hold on
[mu,se,xi] = pa_weightedmean(T,P*100,5,0:3:35,'wfun','boxcar');
hold on
sel = isnan(mu);
% pa_errorpatch(xi(~sel),mu(~sel)',se(~sel)','k');

plot(xi(~sel),mu(~sel)','ko-','LineWidth',2,'MarkerFaceColor','w');

% errorbar(xi(~sel),mu(~sel)',1.96*se(~sel)','ko-','LineWidth',2,'MarkerFaceColor','w');
sel = xi==12;
plot(xi(sel),mu(sel),'ko-','LineWidth',2,'MarkerFaceColor','w','MarkerSize',15);
% ylim([30 70]);
% xlim([3 25]);
% axis square;
xlabel('Time after CI implantation (months)');
ylabel('Phoneme score (%)');
box off;
% set(gca,'XScale','log');
% pa_verline(12);
% keyboard
% pa_horline(mean(F/100));
set(gca,'XTick',4:4:24,'Ytick',0:10:100);
%% Printing/saving figure
pa_datadir; % go to DATA directory
print('-depsc',mfilename); % create a png-figure with filename pa_pet_phoneme
