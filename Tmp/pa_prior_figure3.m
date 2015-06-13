function pa_prior_figure3

%% SUPSAC_SL beinhaltet die Data von RG, PH, CK
% Jetzt probiere ich, diese Data zusammen zu analysieren

%% Initialization
close all
clear all
clc

figurel2s

%% Filenames
fnames = {'JR-RG-2012-04-06-0001';...
	'RG-JR-2012-04-26-0001';...
	'RG-PH-2012-04-13-0001';...
	'RG-PH-2012-04-23-0001';...
	'RG-CK-2012-04-13-0001';...
	'RG-CK-2012-04-23-0001';...
	'RG-TH-2012-04-27-0001';...
	'RG-EZ-2012-04-20-0001';...
	'RG-BK-2012-04-24-0001';...
	'RG-LJ-2012-04-25-0001';...
	'RG-EZ-2012-04-24-0001';...
	'RG-LK-2012-04-26-0001'}; %Short Long


SS = [];
for jj= 1:length(fnames)
	fname = fnames{jj};
	pa_datadir(['Prior\' fname(1:end-5)]);
	load(fname); %load fnames(ii) = load('fnames(ii)');
	SupSac      = pa_supersac(Sac,Stim,2,1);
	figure(2)
	subplot(4,4,jj)
	[G(jj,:),cntr,S(jj,:)] = plotss(SupSac);
	
	SS = [SS;SupSac];
end
[~,n]	= size(G);
muG1	= mean(G(:,1:n/2),2);
sel		= muG1>=1;
muG		= mean(G(sel,:));

[m,n]	= size(G(sel,:));
sdG		= std(G(sel,:))./sqrt(m);
muS		= mean(S(sel,:));

rng		= [repmat(10,n/2,1); repmat(45,n/2,1)]';
PredG	= 1-muS.^2./(rng).^2; % Better fit than std = block

figure(666)
subplot(132)
plot(cntr,PredG,'ko-','MarkerFaceColor','w','LineWidth',2,'Color',[.7 .7 .7]);
hold on
errorbar(cntr,muG,sdG,'ko-','MarkerFaceColor','w','LineWidth',2);

%%
[m,n]	= size(G);
muG1	= mean(G(:,1:n/2),2);
sel		= muG1<=1;
muG		= mean(G(sel,:));
[m,n]	= size(G(sel,:));
sdG		= std(G(sel,:))./sqrt(m);
muS		= mean(S(sel,:));

rng		= [repmat(10,n/2,1); repmat(45,n/2,1)]';
PredG	= 1-muS.^2./(rng).^2; % Better fit than std = block

subplot(133)
plot(cntr,PredG,'ko-','MarkerFaceColor','w','LineWidth',2,'Color',[.7 .7 .7]);
hold on
errorbar(cntr,muG,sdG,'ko-','MarkerFaceColor','w','LineWidth',2);


for ii = 1:3
	subplot(1,3,ii)
	box off;
	axis square;
	ylim([0.4 1.6]);
	xlim([0 510])
	pa_verline(250);
	if ii == 1
		xlabel('Trial number');
		ylabel('Response gain');
	end
	pa_text(0.05,0.95,char(96+ii))
	set(gca,'XTick',100:100:400,'YTick',0.5:0.25:1.5);
end

%%
pa_datadir;
print('-depsc','-painter',mfilename);

function [G,cntr,S]  = plotss(SS)

%% Correct for size
sel = ismember(SS(:,1),251:500);
x = SS(sel,24);
y = SS(sel,9);
b = regstats(y,x,'linear',{'beta','r'});
Glarge = b.beta(2);

sel = ismember(SS(:,1),251:500) & abs(SS(:,24))<=15;
x = SS(sel,24);
y = SS(sel,9);
b = regstats(y,x,'linear',{'beta','r'});
Gsmall = b.beta(2);

corrFactor = Gsmall/Glarge; % ciorrection factor
% corrFactor = 1;

rng = 1:25;
mx = max(rng);
cntr = 1:(500/mx);
G = NaN(size(cntr));
cindx = round(max(cntr)/2)+1;

for ii = cntr
	indx = rng+(ii-1)*mx;
	sel = ismember(SS(:,1),indx);
	sum(sel)
	x = SS(sel,24);
	y = SS(sel,9);
	b = regstats(y,x,'linear',{'beta','r'});
	G(ii) = b.beta(2);
	S(ii) = std(b.r);
	if ii>=cindx
		S(ii) = S(ii)*corrFactor;
	end
end
indx = round(max(cntr)/2)+1;
G(indx:end) = G(indx:end)*corrFactor;

mu = mean(G(indx:end));
% mu	= G(1);
G	= G./mu;
S	= S./mu;
cntr = cntr*mx;
plot(cntr,G,'ko-','MarkerFaceColor','w');
axis square;
pa_verline(max(cntr)/2);
hold on
plot(SS(:,24)/max(SS(:,24)));

function figurel2s

%% SUPSAC_SL beinhaltet die Data von RG, PH, CK
% Jetzt probiere ich, diese Data zusammen zu analysieren

%% Initialization
close all
clear all
clc

fnames = {'JR-RG-2012-04-06-0002';'RG-JR-2012-04-16-0001';'RG-PH-2012-04-17-0001';'RG-PH-2012-04-19-0001';'RG-CK-2012-04-17-0001';'RG-CK-2012-04-19-0001';'RG-TH-2012-04-13-0001';'RG-EZ-2012-04-19-0001';'RG-BK-2012-04-25-0001';'RG-LJ-2012-04-24-0001';'RG-EZ-2012-04-26-0001';'RG-LK-2012-04-24-0001'}; % Long Short

SS = [];
for jj= 1:length(fnames)
	fname = fnames{jj};
	pa_datadir(['Prior\' fname(1:end-5)]);
	load(fname); %load fnames(ii) = load('fnames(ii)');
	SupSac      = pa_supersac(Sac,Stim,2,1);
	
	subplot(4,4,jj)
	[G(jj,:),cntr,S(jj,:)] = plotss2(SupSac);
	
	SS = [SS;SupSac];
	
end
muG		= mean(G);
[m,n]	= size(G);
sdG		= std(G)./sqrt(m);
muS		= mean(S);

rng = [repmat(45,n/2,1); repmat(10,n/2,1)]';
PredG = 1-muS.^2./(rng).^2; % Better fit than std = block
figure(666)

subplot(131)
plot(cntr,PredG,'ko-','MarkerFaceColor','w','LineWidth',2,'Color',[.7 .7 .7]);
hold on
errorbar(cntr,muG,sdG,'ko-','MarkerFaceColor','w','LineWidth',2);
pa_verline(250)

axis square;
ylim([0.4 1.2]);
xlim([5 505])
pa_verline(250);
xlabel('Trial number');
ylabel('Response gain');
pa_datadir;
print('-depsc','-painter',mfilename);

% kalman

function [G,cntr,S]  = plotss2(SS)

%% Correct for size
sel = ismember(SS(:,1),1:250);
x = SS(sel,24);
y = SS(sel,9);
b = regstats(y,x,'linear',{'beta','r'});
Glarge = b.beta(2);

sel = ismember(SS(:,1),1:250) & abs(SS(:,24))<=15;
x = SS(sel,24);
y = SS(sel,9);
b = regstats(y,x,'linear',{'beta','r'});
Gsmall = b.beta(2);

corrFactor = Gsmall/Glarge; % correction factor: correct?

rng = 1:25;
mx = max(rng);
cntr = 1:(500/mx);
G = NaN(size(cntr));
for ii = cntr
	indx = rng+(ii-1)*mx;
	sel = ismember(SS(:,1),indx);
	x = SS(sel,24);
	y = SS(sel,9);
	b = regstats(y,x,'linear',{'beta','r'});
	G(ii) = b.beta(2);
	S(ii) = std(b.r);
end
indx		= round(max(cntr)/2);
G(1:indx)	= G(1:indx)*corrFactor;

mu		= mean(G(1:indx));
G		= G./mu;
S		= S./mu;
cntr	= cntr*mx;
plot(cntr,G,'ko-','MarkerFaceColor','w');
axis square;
pa_verline(max(cntr)/2);

