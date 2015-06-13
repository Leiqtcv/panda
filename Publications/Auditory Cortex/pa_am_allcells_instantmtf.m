function pa_am_allcells_mtf

clc;
close all hidden;
clear all

% cd('E:\DATA\selected cells');
cd('E:\DATA\Cortex\AMcells with tonespike');
d = dir('*.mat');
fnames = {d.name};
nfiles = length(d);
% nBin = 16;
tMTFP		= NaN(nfiles,15);
tMTFA500	= tMTFP;
tMTFA1000	= tMTFP;
rMTFP		= tMTFP;
rMTFA500	= tMTFP;
rMTFA1000	= tMTFP;
VSP			= tMTFP;
VSA500			= tMTFP;
VSA1000			= tMTFP;

N = 0;
for ii = 1:nfiles
	close all
	fname = fnames{ii};
	disp(fname)
	load(fname)
	stim = [spikeAMA.stimvalues];
	dur = stim(3,:);
	[spikeAMA1000,RT1000]	= seldur(spikeAMA,behAM,1000);
	[spikeAMA500,RT500]	= seldur(spikeAMA,behAM,500);
	
% 	[tMP,rMP,vsP,~,~,rayleighP]				= getmtf(spikeAMP);

% 	return
	[tMA500,rMA500,vsA500,~,~,rayleighA500]		= getmtf(spikeAMA500,RT500);
% 	[tMA1000,rMA1000,vsA1000,~,~,rayleighA1000]	= getmtf(spikeAMA1000);
% 	rayleigh = [rayleighP; rayleighA500; rayleighA1000];
% 	if any(rayleigh>13.8/2) % 13.8 = p=0.05
% 		% 	if all(rayleigh<13.8) % 13.8 = p=0.05
% 		tMTFP(ii,:)		= tMP;
% 		tMTFA500(ii,:)	= tMA500;
% 		tMTFA1000(ii,:) = tMA1000;
% 		
% 		rMTFP(ii,:)		= rMP;
% 		rMTFA500(ii,:)	= rMA500;
% 		rMTFA1000(ii,:) = rMA1000;
% 		
% 		VSP(ii,:)		= vsP;
% 		VSA500(ii,:)	= vsA500;
% 		VSA1000(ii,:) = vsA1000;
% 		N = N+1;
% 		
% 		
% 	end

	title(fname)
	pause
end


%% Single cells

% uMF		= pa_oct2bw(2,0:0.5:7);
% n		= length(uMF);
% uMFi	= pa_oct2bw(2,linspace(0,7,n*10));
% Y		= tMTFP;
% sel		= isnan(Y(:,1));
% Y		= Y(~sel,:);
% mx		= max(Y,[],2);
% Y		= bsxfun(@rdivide,Y,mx);
% Y		= 10*log10(Y);
% n		= size(Y,1);
% for ii = 1:n
% 	Yi		= interp(Y(ii,:),10);
% 	Yi		= smooth(Yi,50);
% 	plot(uMFi,Yi,'k-','Color',[.7 .7 .7]);
% end
% axis square
% box off
% set(gca,'TickDir','out','Xscale','log');
% xlim([1 256*2]);
% ylim([-16 1]);
% uMF = pa_oct2bw(2,0:0.5:7);
% set(gca,'XTick',uMF(1:2:end),'XTickLabel',round(uMF(1:2:end)));
% str = ['Passive tMTF: ' num2str(N) ' out of ' num2str(nfiles) ' cells'];
% title(str);
% ylabel('Firing rate (dB)');
% xlabel('Modulation frequency (Hz)')
% pa_horline(-3,'k:');


%%
figure(100)
subplot(131)
mtffigure(tMTFP,tMTFA500,tMTFA1000,N,nfiles,'tMTF')
ylim([-8 2])


subplot(132)
mtffigure(rMTFP,rMTFA500,rMTFA1000,N,nfiles,'rMTF')
ylim([-3 4])

subplot(133)
vsfigure(VSP,VSA500,VSA1000,N,nfiles,'vector strength')


pa_datadir;
print('-depsc','-painter',mfilename);

%%
% close all
col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);

figure(200)
subplot(132)
hold on
x = mean(rMTFP,2);
y = mean(rMTFA500,2);
[~,p,~,stats] = ttest(x,y);
str1 = ['Idle - Acting_{0.5}: t_{df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,2)];
plot(x,y,'kv','MarkerFaceColor',col(2,:),'MarkerSize',3);
x = mean(rMTFP,2);
y = mean(rMTFA1000,2);
[~,p,~,stats] = ttest(x,y);
str2 = ['Idle - Acting_{1.0}: t_{df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,2)];
plot(x,y,'k^','MarkerFaceColor',col(3,:),'MarkerSize',3);
axis square
box off
set(gca,'TickDir','out','XTick',0:50:250,'YTick',0:50:250);
axis([-10 260 -10 260]);
pa_unityline('k:');
xlabel('rMTF_{idle} (spikes/s)')
ylabel('rMTF_{acting_{0.5}} (spikes/s)')
pa_text(0.1,0.9,str1);
pa_text(0.1,0.8,str2);


figure(200)
subplot(131)
hold on
x = mean(tMTFP,2);
y = mean(tMTFA500,2);
[~,p,~,stats] = ttest(x,y);
str1 = ['Idle - Acting_{0.5}: t_{df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,2)];
plot(x,y,'kv','MarkerFaceColor',col(2,:),'MarkerSize',3);
x = mean(tMTFP,2);
y = mean(tMTFA1000,2);
[~,p,~,stats] = ttest(x,y);
str2 = ['Idle - Acting_{1.0}: t_{df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,2)];
plot(x,y,'k^','MarkerFaceColor',col(3,:),'MarkerSize',3);
axis square
box off
set(gca,'TickDir','out','XTick',0:10:40,'YTick',0:10:40);
axis([-10 50 -10 50]);
pa_unityline('k:');
ylabel('Firing rate (dB)');
xlabel('tMTF_{idle} (spikes/s)')
ylabel('tMTF_{acting_{0.5}} (spikes/s)')
pa_text(0.1,0.9,str1);
pa_text(0.1,0.8,str2);




figure(200)
subplot(133)
hold on
x = max(VSP,[],2);
y = max(VSA500,[],2);
[~,p,~,stats] = ttest(x,y);
str1 = ['Idle - Acting_{0.5}: t_{df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,2)];
plot(x,y,'kv','MarkerFaceColor',col(2,:),'MarkerSize',3);
x = max(VSP,[],2);
y = max(VSA1000,[],2);
[~,p,~,stats] = ttest(x,y);
str2 = ['Idle - Acting_{1.0}: t_{df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,2)];
plot(x,y,'k^','MarkerFaceColor',col(3,:),'MarkerSize',3);
axis square
box off
set(gca,'TickDir','out','XTick',0:0.2:1,'YTick',0:0.2:1);
axis([-0.1 1.1 -0.1 1.1]);
pa_unityline('k:');
ylabel('Firing rate (dB)');
xlabel('VS_{idle}')
ylabel('VS_{acting_{0.5}}')
pa_text(0.1,0.9,str1);
pa_text(0.1,0.8,str2);


pa_datadir;
print('-depsc','-painter',[mfilename 'comparison']);


%%
% keyboard

%%

%%
function [tM,rM,VS,Phi,uMF,rayleigh] = getmtf(spike,rt)
% Get temporal and rate codes / vector strength and firing rate
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
VS			= NaN(nMF,1);
d			= 0.700;
Nbin		= 16;
ncomp		= 1;
xperiod		= linspace(0,1,Nbin);
wnd = 250;
t = -250:25:0; % instant time
wnd = wnd/1000;
t = t/1000;
nt = numel(t);
tM			= NaN(nMF,nt);
rM			= tM;
Phi			= tM;

%% Baseline
%% Modulation
col = pa_statcolor(nMF,[],[],[],'def',1);
for ii		= 1:nMF
	sel		= modFreq==uMF(ii);
	spk		= spike(sel);
	react = rt(sel);
	dur		= spk(1).stimvalues(3)/1000;
	
	sel		= modFreq==uMF(ii);
	ntrials = sum(sel);
	P = [];
	T = [];
	R = [];
	nperiod = floor(d/(1/uMF(ii)));
	maxtime = nperiod*(1/uMF(ii));
	for jj = 1:ntrials
		spktime		= spk(jj).spiketime/1000;
		spktime		= spktime-0.300-dur;
		sel			= spktime<=maxtime;
		spktime		= spktime(sel);
		period		= spktime*uMF(ii);
		period		= mod(period,1);
		P			= [P period]; %#ok<AGROW>
		T			= [T spktime];
		R			= [R spktime-react(jj)];
	end
	%%
	
	for jj = 1:nt
		% 		if wnd<0.25;
		% 			wnd = 0.25;
		% 		end
				nperiod = wnd/uMF(ii);
		
		sel = T>=(t(jj)-wnd) & T<(t(jj)+wnd);
		Nspikes		= hist(P(sel),xperiod);
		Nspikes		= Nbin*Nspikes/ntrials; % Convert to firing rate
		
		X			= fft(Nspikes,Nbin)/Nbin;
		tM(ii,jj)		= abs(X(ncomp+1));
		Phi(ii,jj)		= angle(X(ncomp+1));
		rM(ii,jj)		= abs(X(ncomp+0));
		VS(ii,jj)		= tM(ii,jj)./rM(ii,jj);
	end
	
	% 	keyboard
% 	tM(ii,:) = smooth(tM(ii,:),50);
% 	rM(ii,:) = smooth(rM(ii,:),50);
% 	VS(ii,:) = smooth(VS(ii,:),50);
	
	%%
% 	figure(1)
% 	subplot(231)
% 	plot(t,tM(ii,:),'Color',col(ii,:));
% 	hold on
% 	str = num2str(round(uMF(ii)));
% 	
% 	title(str)
% 	axis square
% 	box off
% 	set(gca,'TickDir','out');
% 	
% 	subplot(232)
% 	plot(t,rM(ii,:),'Color',col(ii,:));
% 	hold on
% 	axis square
% 	box off
% 	set(gca,'TickDir','out');
% 	
% 	subplot(233)
% 	plot(t,VS(ii,:),'Color',col(ii,:));
% 	hold on
% 	ylim([-0.1 1.1]);
% 	axis square
% 	box off
% 	set(gca,'TickDir','out');
	
	% 	pause
	%%
end
rayleigh = (tM./rM).^2*2.*rM;

	figure(1)
	subplot(231)
	plot(t,mean(tM),'Color','k');
	hold on
	str = num2str(round(uMF(ii)));
	
	title(str)
	axis square
	box off
	set(gca,'TickDir','out');
	xlim([min(t) max(t)]);
	subplot(232)
	plot(t,mean(rM),'Color','k');
	hold on
	axis square
	box off
	set(gca,'TickDir','out');
	xlim([min(t) max(t)]);
	
	subplot(233)
	plot(t,mean(VS),'Color','k');
	hold on
	ylim([-0.1 1.1]);
	axis square
	box off
	set(gca,'TickDir','out');
	xlim([min(t) max(t)]);
	
col = pa_statcolor(64,[],[],[],'def',8);
colormap(col);
subplot(234)
contourf(t,pa_freq2bw(2,uMF),tM,50);
shading flat
set(gca,'Ydir','normal');
axis square
box off
set(gca,'TickDir','out');
	
subplot(235)
contourf(t,pa_freq2bw(2,uMF),rM,50);
shading flat
set(gca,'Ydir','normal');
axis square
box off
set(gca,'TickDir','out');

subplot(236)
contourf(t,pa_freq2bw(2,uMF),VS,50);
shading flat
set(gca,'Ydir','normal');
axis square
box off
set(gca,'TickDir','out');
caxis([0 1]);

function mtffigure(Y1,Y2,Y3,N,nfiles,str)

col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);

uMF		= pa_oct2bw(2,0:0.5:7);
n		= length(uMF);
uMFi	= pa_oct2bw(2,linspace(0,7,n*10));

Y		= nanmean(Y1);
mx		= nanmax(Y);
Y		= 20*log10(Y/mx);
plot(uMF,Y,'ko','MarkerFaceColor',col(1,:));
hold on
BW	= pa_freq2bw(2,uMF);
P	= polyfit(BW,Y,2);
BWi = pa_freq2bw(2,uMFi);
Yi	= polyval(P,BWi);
plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(1,:));

Y		= nanmean(Y2);
% mx		= nanmax(Y);
Y		= 20*log10(Y/mx);
plot(uMF,Y,'kv','MarkerFaceColor',col(2,:));
hold on
BW	= pa_freq2bw(2,uMF);
P	= polyfit(BW,Y,2);
BWi = pa_freq2bw(2,uMFi);
Yi	= polyval(P,BWi);
plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(2,:));

Y		= nanmean(Y3);
% mx		= nanmax(Y);
Y		= 20*log10(Y/mx);
plot(uMF,Y,'k^','MarkerFaceColor',col(3,:));
hold on
BW	= pa_freq2bw(2,uMF);
P	= polyfit(BW,Y,2);
BWi = pa_freq2bw(2,uMFi);
Yi	= polyval(P,BWi);
plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(3,:));


axis square
box off
set(gca,'TickDir','out','Xscale','log');
xlim([1 256*2]);
ylim([-6 4]);
uMF = pa_oct2bw(2,0:0.5:7);
set(gca,'XTick',uMF(1:2:end),'XTickLabel',round(uMF(1:2:end)));
str = ['Composite ' str ': ' num2str(N) ' out of ' num2str(nfiles) ' cells'];
title(str);
ylabel('Firing rate (dB)');
xlabel('Modulation frequency (Hz)')


function vsfigure(Y1,Y2,Y3,N,nfiles,str)

col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);

uMF		= pa_oct2bw(2,0:0.5:7);
n		= length(uMF);
uMFi	= pa_oct2bw(2,linspace(0,7,n*10));

Y		= nanmean(Y1);
h1 = plot(uMF,Y,'ko','MarkerFaceColor',col(1,:));
hold on
BW	= pa_freq2bw(2,uMF);
P	= polyfit(BW,Y,2);
BWi = pa_freq2bw(2,uMFi);
Yi	= polyval(P,BWi);
plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(1,:));

Y		= nanmean(Y2);
h2 = plot(uMF,Y,'kv','MarkerFaceColor',col(2,:));
hold on
BW	= pa_freq2bw(2,uMF);
P	= polyfit(BW,Y,2);
BWi = pa_freq2bw(2,uMFi);
Yi	= polyval(P,BWi);
plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(2,:));

Y		= nanmean(Y3);
h3 = plot(uMF,Y,'k^','MarkerFaceColor',col(3,:));
hold on
BW	= pa_freq2bw(2,uMF);
P	= polyfit(BW,Y,2);
BWi = pa_freq2bw(2,uMFi);
Yi	= polyval(P,BWi);
plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(3,:));


axis square
box off
set(gca,'TickDir','out','Xscale','log');
xlim([1 256*2]);
ylim([-0.1 1.1]);
uMF = pa_oct2bw(2,0:0.5:7);
set(gca,'XTick',uMF(1:2:end),'XTickLabel',round(uMF(1:2:end)));
str = ['Composite ' str ': ' num2str(N) ' out of ' num2str(nfiles) ' cells'];
title(str);
ylabel('Vector strength');
xlabel('Modulation frequency (Hz)')
legend([h1 h2 h3],{'Idle','Acting 0.5','Acting 1.0'});


function [Spike,RT] = seldur(spike,beh,dur)
stim			= [spike.stimvalues];
durstat			= stim(3,:);
sel				= durstat == dur;
Spike			= spike(sel);
Spike			= rmfield(Spike,{'spikewave';'timestamp';'stimparams';'trialorder';'trial';'aborted'});

sel				= beh(4,:)==dur; %#ok<*NODEF>
rt				= beh(2,:);
RT				= rt(sel); % Check this
mn              = min(length(Spike),length(RT));
Spike			= Spike(1:mn);
RT				= RT(:,1:mn);
