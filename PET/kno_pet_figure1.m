close all;

F = [0 51 3 65 7 3 15 13.5 55 70 85 30];

%% read xlsfile
fname = 'E:\Backup\PET\Misc\Protocol\Phoneme.xls'; % location of xls-file containing phonemescores

[num,txt,raw] = xlsread(fname);
n		= size(num,2)-1; % number of subjects
col		= gray(n+6); % color map
T		= [];
P		= [];
id		= num(1,2:end);
num		= num(3:end,:);
col = gray(n+2);
col2 = gray(n);
% subplot(221)
for ii	= 1:n
	t	= num(:,1); % months
	p	= num(:,ii+1); % phoneme score
	sel = ~isnan(p) & t<25; % remove nonexisting files
	t	= t(sel);
	p	= p(sel);
	plot(t,p*100,'d-','MarkerFaceColor',col2(ii,:),'Color','k','LineWidth',1); % plot percentage
	hold on
	[m,indx]=min(abs(t-14));
	plot(t(indx),p(indx)*100,'o-','MarkerFaceColor',col2(ii,:),'Color','k','LineWidth',2,'MarkerSize',10); % plot percentage
	
	text(t(indx),p(indx)*100+3,num2str(id(ii)),'HorizontalAlignment','center');
	T = [T;t];
	P = [P;p];
end
% Labels and stuff
ylim([0 100]);
xlim([0 25]);
axis square;
xlabel('Time after CI implantation (months)');
ylabel('Phoneme score (%)');
box off;
set(gca,'XTick',0:6:24);
pa_verline(12,'k:');


%% Printing/saving figure
pa_datadir; % go to DATA directory
print('-dpng',mfilename); % create a png-figure with filename pa_pet_phoneme
print('-depsc','-painter',mfilename); % create a png-figure with filename pa_pet_phoneme

%% 
% figure;
%% read xlsfile
% fname = 'E:\Backup\PET\Misc\Protocol\Phoneme.xls'; % location of xls-file containing phonemescores
fname = 'E:\Backup\anonPET\phoneem.xlsx';

[num,txt,raw] = xlsread(fname);


n		= size(num,2)-1; % number of subjects
col		= gray(n+6); % color map
T		= [];
P		= [];
id		= num(2:end,1)
num		= num(:,2:end)
col = jet(n+2);
col2 = jet(n);
% subplot(221)
for ii	= 1:n
	t	= num(1,:); % months
	p	= num(ii+1,:); % phoneme score
	sel = ~isnan(p) & t<25; % remove nonexisting files
	t	= t(sel);
	p	= p(sel);
	plot(t,p,'d-','MarkerFaceColor',col2(ii,:),'Color','k','LineWidth',1); % plot percentage
	hold on
	[m,indx]=min(abs(t-14));
	plot(t(indx),p(indx),'o-','MarkerFaceColor',col2(ii,:),'Color','k','LineWidth',2,'MarkerSize',10); % plot percentage
	
	text(t(indx),p(indx)+3,num2str(id(ii)),'HorizontalAlignment','center');
	T = [T;t'];
	P = [P;p'];
end
% Labels and stuff
ylim([0 100]);
xlim([0 25]);
axis square;
xlabel('Time after CI implantation (months)');
ylabel('Phoneme score (%)');
box off;
set(gca,'XTick',0:6:24);
pa_verline(12,'k:');

%%

% keyboard

%% Printing/saving figure
pa_datadir; % go to DATA directory
print('-dpng',mfilename); % create a png-figure with filename pa_pet_phoneme
print('-depsc','-painter',mfilename); % create a png-figure with filename pa_pet_phoneme

