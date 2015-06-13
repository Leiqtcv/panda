function check_cells_ADDvsMUL

%% Cleansing
clc;
close all hidden;
clear all hidden;

%% Data directories and filenames
cd('E:\DATA\No clustered data'); % Change this to suit your needs
thorfiles	= dir('thor*'); % for monkey Thor
joefiles	= dir('joe*'); % and for monkey Joe
files		= [thorfiles' joefiles'];

%% Flags
dispstim	= false;


%% Go through every cell
k         = 0;
n = length(files);
Dse = NaN(n,1);
D = Dse;
S = Dse;
H = D;
M = struct([]);
C = [];
Cp = [];
Ca = [];
for ii	= 1:n
	
	k  = k +1;
	fname		  = files(ii).name;
	disp(fname);
	load(fname);
	clear bf
	
	%% Separate active trials in two blocks
	P				= SpikeP;
	[A500,A1000,RT500,RT1000]			= separate2active(SpikeA,beh); % ripples
	clear spikeP spikeA beh
	
	PAM				= SpikeAMP;
	[A500AM,A1000AM,RT500AM,RT1000AM]    = separate2active(SpikeAMA,behAM); % AM
	clear SpikeP SpikeA beh
	
	%% Spike density function
	sd = 10;
	[~,sdfAM]          = pa_spk_sdf(PAM,'Fs',1000,'sigma',sd);
	[~,sdf500AM]      = pa_spk_sdf(A500AM,'Fs',1000,'sigma',sd);
	[~,sdf1000AM]     = pa_spk_sdf(A1000AM,'Fs',1000,'sigma',sd);
	[~,sdf]           = pa_spk_sdf(P,'Fs',1000,'sigma',sd);
	[~,sdf500]        = pa_spk_sdf(A500,'Fs',1000,'sigma',sd);
	[~,sdf1000]       = pa_spk_sdf(A1000,'Fs',1000,'sigma',sd);
	
	%% re RT
	[fr1,fr1b] = getfr(A500,sdf500,RT500,0);
	[fr2,fr2b] = getfr(A1000,sdf1000,RT1000,500);
	[fr3,fr3b] = getfr(A500AM,sdf500AM,RT500AM,0);
	[fr4,fr4b] = getfr(A1000AM,sdf1000AM,RT1000AM,500);
	FR	= [fr1;fr2;fr3;fr4];
	aFR	= [fr1b;fr2b;fr3b;fr4b];
	indx = 300:800;
	% 	pFR = [sdf(:,indx);sdfAM(:,indx);sdf500(:,indx);sdf500AM(:,indx);sdf1000(:,indx);sdf1000AM(:,indx)];
	pFR = [sdf(:,indx);sdfAM(:,indx);];
	
	
% 	keyboard
	
	% 	figure(1)
	% 	cla
	% 	plot(nanmean(fr1),'k-','Color',[.7 .7 .7])
	% 	hold on
	% 	plot(nanmean(fr2),'k-','Color',[.7 .7 .7])
	% 	plot(nanmean(fr3),'k-','Color',[.7 .7 .7])
	% 	plot(nanmean(fr4),'k-','Color',[.7 .7 .7])
	% 	plot(nanmean(FR),'k-','LineWidth',2)
	% 	ylim([0 200]);
	% 	title(fname);
	% 	box off
	% 	drawnow
	
	muFR	= nanmean(FR);
	mupFR	= nanmean(pFR);
	muaFR	= nanmean(aFR);

	muStat	= nanmean(pFR(300:end));
	% 		D(k) = max(FR(end-50:end))-min(muFR(1:50));
	
	D(k) = mean(muFR(end-10:end))-mean(muFR(1:50));
	
% 	keyboard
% 	[h,p] = ttest(muFR(end-10:end))-mean(muFR(1:50));
% 	h
	
	mx = nanmean(FR(:,end-10:end),2);
	mn = nanmean(FR(:,1:50),2);
	d = mx-mn;
	[p,h] = signrank(mx,mn);
H(k) = h;
	df = numel(d)-1;
	t = tinv(0.975,df);
	Dse(k) = t*nanstd(d)./sqrt(df+1);
	
	
	S(k) = nanmean(muStat);
	
	M(k).fr = FR;
% 	P(k).fr = pFR;
	C = [C; muFR];
	Cp = [Cp; mupFR];
	Ca = [Ca; muaFR];
	
end
% keyboard
%%
close all

%%
ustat	= 0:10:120;
nstat = numel(ustat);
s		= 20;
col		= pa_statcolor(nstat,[],[],[],'def',1);

rS = round(S/10)+1;
rS(rS>13) = 13;
uS = unique(rS)

figure(1)
subplot(121)
% lsline;
hold on
errorbar(S,D,Dse,'k.','Color',[.7 .7 .7])

ncells = numel(S);
for ii = 1:ncells
	plot(S(ii),D(ii),'ko','MarkerFaceColor',col(rS(ii),:));
end

sel = S<100;
b = regstats(D(sel),S(sel),'linear','beta');
h = refline(b.beta(2),b.beta(1));
set(h,'Color','k','LineWidth',2);
box off
xlim([-20 160])
ylim([-20 160])
axis square;
pa_unityline('k:');
set(gca,'TickDir','out','XTick',0:20:140,'YTick',0:20:140);
r = corrcoef(S,D);
r = r(2);
title(['r = ' num2str(r,2)])
xlabel('Passive static firing rate (spikes/s)');
ylabel('\Delta modulatory firing rate (spikes/s)');

%%
% keyboard

%%

t = (1:length(C))-151;
figure(1)
subplot(122)
hold on

for ii = 1:nstat
	w = normpdf(S,ustat(ii),s);
	w = w/sum(w);
	
	mC = bsxfun(@minus,C,S);
	
	wC = bsxfun(@times,mC,w);
	mu = sum(wC);
	
	plot(t,mu,'-','Color',col(ii,:),'LineWidth',2)
	drawnow
end
box off
xlim([-160 20])
ylim([0 80])
axis square;
set(gca,'TickDir','out','XTick',-140:20:20,'YTick',20:20:60);
xlabel('Time re bar release (ms)');
ylabel('Modulatory firing rate (spikes/s)');
colormap(col)
h = colorbar;

% keyboard
caxis([1 13])
set(h,'YTick',[])
subplot(121)
colormap(col)
colorbar
caxis([1 13])
set(h,'YTick',[])
pa_verline(0,'k:');
%%
% 	return
%%
keyboard
pa_datadir
print('-depsc','-painter',mfilename);

%%
t = (1:length(C))-151;

sel = t==0;
% bsxfun

figure(3)
subplot(133)
hold on

for ii = 1:nstat
	w = normpdf(S,ustat(ii),s);
	w = w/sum(w);
	
	mC = bsxfun(@minus,C,S);
	
	wC = bsxfun(@times,mC,w);
	mu = sum(wC);
	
	plot(t,mu-mu(sel),'-','Color',col(ii,:),'LineWidth',2)
	drawnow
end
box off
xlim([-10 60])
ylim([-10 100])
axis square;
set(gca,'TickDir','out','XTick',-0:10:50,'YTick',10:10:90);
xlabel('Time re bar release (ms)');
ylabel('Modulatory firing rate (spikes/s)');
colormap(col)
h = colorbar;
title('Active bar peak');
pa_horline(0,'k:');
pa_verline(0,'k:');
pa_datadir
print('-depsc','-painter',[mfilename '2']);

%%
t = (0:length(Cp)-1);

sel = t==0;
% bsxfun

figure(3)
subplot(131)
hold on

for ii = 1:nstat
	w = normpdf(S,ustat(ii),s);
	w = w/sum(w);
	
	mC = bsxfun(@minus,Cp,S);
	
	wC = bsxfun(@times,mC,w);
	mu = sum(wC);
	
	plot(t,mu-mu(sel),'-','Color',col(ii,:),'LineWidth',2)
% 	plot(t,mu,'-','Color',col(ii,:),'LineWidth',2)
	drawnow
end
box off
xlim([-10 60])
ylim([-10 100])
axis square;
set(gca,'TickDir','out','XTick',-0:10:50,'YTick',10:10:90);
xlabel('Time re sound onset (ms)');
ylabel('Modulatory firing rate (spikes/s)');
colormap(col)
h = colorbar;
title('Passive onset peak');
pa_horline(0,'k:');
pa_verline(0,'k:');


t = (0:length(Ca)-1)-300;

sel = t==0;
% bsxfun

figure(3)
subplot(132)
hold on

for ii = 1:nstat
	w = normpdf(S,ustat(ii),s);
	w = w/sum(w);
	
	mC = bsxfun(@minus,Ca,S);
	
	wC = bsxfun(@times,mC,w);
	mu = sum(wC);
	
	plot(t,mu-mu(sel),'-','Color',col(ii,:),'LineWidth',2)
% 	plot(t,mu,'-','Color',col(ii,:),'LineWidth',2)
	drawnow
end
box off
xlim([-10 60])
ylim([-10 100])
axis square;
set(gca,'TickDir','out','XTick',-0:10:50,'YTick',10:10:90);
xlabel('Time re  sound onset (ms)');
ylabel('Modulatory firing rate (spikes/s)');
colormap(col)
h = colorbar;
title('Active onset peak');
pa_horline(0,'k:');
pa_verline(0,'k:');

pa_datadir
print('-depsc','-painter',[mfilename '4']);
%%
function [S500,S1000,RT500,RT1000] = separate2active(spike,beh)
% Separate the spike-structure for an active block experiments in the 500
% and 1000 trials. Also separate behavior

%% Separate Spikes
stmat        = [spike.stimvalues];
ststat       = stmat(3,:);
sel500       = ststat==500;
S500         = spike(sel500);
for ii       = 1:length(S500)
	[m,n]          = size(S500(ii).trial);
	S500(ii).trial = repmat(ii,m,n);
	S500(ii).trial;
end

sel1000      = ststat==1000;
S1000        = spike(sel1000);
for ii              = 1:length(S1000)
	[m,n]           = size(S1000(ii).trial);
	S1000(ii).trial = repmat(ii,m,n);
	S1000(ii).trial;
end

%% Separate behavior
sel500	= beh(4,:)==500; %#ok<*NODEF>
reac	= beh(2,:);
RT500	= reac(sel500);
mn		= min(length(S500),length(RT500)); % sometimes the last trial is missing,
S500	= S500(1:mn);
RT500	= RT500(:,1:mn);

sel1000 = beh(4,:)==1000;
reac	= beh(2,:);
RT1000	= reac(sel1000);
mn		= min(length(S1000),length(RT1000));
S1000	= S1000(1:mn);
RT1000	= RT1000(:,1:mn);

function [fr,fr2] = getfr(strct,sdf,RT,shft)
n	              = numel(strct);
fr            = NaN(n,2500);
fr2            = NaN(n,2500);

for jj = 1:n
	a	= sdf(jj,:);
	if length(a) < 2500
		diff     = 2500 - length(a);
		dif      = NaN(1,diff);
		a        = [a dif];
	elseif length(a) > 2500
		a        = a(1:2500);
	end
	
	b	= circshift(a',-RT(jj)-shft);
	fr(jj,:) = b;
	fr2(jj,:) = a;
end

fr = fr(:,650:900);