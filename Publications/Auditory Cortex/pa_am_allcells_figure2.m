function pa_am_allcells_figure2

clc;
close all hidden;
clear all

% cd('E:\DATA\selected cells');
cd('E:\DATA\Cortex\AMcells with tonespike');
d = dir('*.mat');
fnames = {d.name};
nfiles = length(d);
for ii = 1:nfiles
	fname = fnames{ii};
	load(fname)
	stim = [spikeAMA.stimvalues];
	dur = stim(3,:);
	sel = dur==500;
	spikeAMA500 = spikeAMA(sel);
	spikeAMA1000 = spikeAMA(~sel);
	
% 	try
		figure(1)
		subplot(231)
		cla;
		title(fname);
		subplot(234)
		cla;
		subplot(232)
		cla;
		subplot(235)
		cla;
		subplot(233)
		cla;
		subplot(236)
		cla;
		[rayleighP,rayleighA500,rayleighA1000,MTFP,MTFA500,MTFA1000,uMF] = getdata(spikeAMP,spikeAMA500,spikeAMA1000);
		SS(ii) = any([rayleighP(2:end); rayleighA500(2:end); rayleighA1000(2:end)]>13.8);

		
		MTFpas(ii,:) = MTFP/mean(MTFP);
		MTFact500(ii,:) = MTFA500/mean(MTFP);
		MTFact1000(ii,:) = MTFA1000/mean(MTFP);
		drawnow
		pause(0.1)
		if SS(ii)
% 			pause
		end
% 	end
end
sum(SS)
%%
figure
% close all
% semilogx(uMF,MTF(SS,:))
% pa_errorpatch(uMF,mean(MTF(SS,:)),std(MTF(SS,:))./sqrt(sum(SS)));
mu = mean(MTFpas(SS,:));
se = std(MTFpas(SS,:))./sqrt(sum(SS));
errorbar(uMF,mu,se,'k-','LineWidth',2);
hold on
mu = mean(MTFact500(SS,:));
se = std(MTFact500(SS,:))./sqrt(sum(SS));
errorbar(uMF,mu,se,'r-','LineWidth',2);

mu = mean(MTFact1000(SS,:));
se = std(MTFact1000(SS,:))./sqrt(sum(SS));
errorbar(uMF,mu,se,'b-','LineWidth',2);

set(gca,'Xscale','log');
set(gca,'XTick',uMF,'XTickLabel',round(uMF));
pa_verline([17 57])
pa_horline([max(mu) max(mu)-(max(mu)-min(mu))/2]);
axis square;
box off

% keyboard

%%
% close all
% plot(MTFpas');
% %%
% dat = MTFpas';
% [coefs,score] = princomp(zscore(dat));
% % [NDIM, PROB, CHISQUARE] = barttest(dat,0.05);
% figure
% for ii = 1:3
% 	indx = ii:ii+1;
% 	subplot(2,2,ii)
% % 	biplot(coefs(:,indx),'scores',score(:,indx),'varlabels',vbls);
% 	biplot(coefs(:,indx));
% 	hold on
% 	axis square
% grid off
% box off
% axis off	
% 	drawnow
% end
% subplot(221)
% subplot(222)
% xlabel('Component 2');
% ylabel('Component 3');
% subplot(223)
% xlabel('Component 3');
% ylabel('Component 4');
function [rayleighP,rayleighA500,rayleighA1000,MTFP,MTFA500,MTFA1000,uMF] = getdata(spikeAMP,spikeAMA500,spikeAMA1000)
[rayleighP,rayleighA500,rayleighA1000,MTFP,MTFA500,MTFA1000,uMF] = sdfplot(spikeAMP,spikeAMA500,spikeAMA1000);

function [rayleighP,rayleighA500,rayleighA1000,MTFP,MTFA500,MTFA1000,uMF] = sdfplot(spikeAMP,spikeAMA500,spikeAMA1000)

%% PASSIVE
spike		= spikeAMP;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
col			= jet(nMF);
P			= [];
figure(1)
sigma		= 5;
winsize		= sigma*5;
t			= -winsize:winsize;
window		= normpdf(t,0,sigma);
x = -1:0.01:100;
M = 0;
VS = NaN(nMF,1);
VSsd = VS;
FR = VS;
FRsd = VS;
for ii		= 1:nMF
	sel		= modFreq==uMF(ii);
	spk		= spike(sel);
	ntrials = sum(sel);
	
	spk1	= [spk.spiketime]/1000; % spike times in s
	sel		= spk1>0.800 & spk1<1.500;
	spk1	= spk1(sel)-0.800;
	spk1	= spk1*uMF(ii);
	[N,xp]	= hist(spk1,x);
% 	xp = xp-25/1000*uMF(ii);
	convN	= conv(N,window);
	N = convN(1:end-winsize*2);
	N = 0.3* N/max(N);
	
	subplot(231)
	hp		= patch([xp(1) xp xp(end)],[0.3*ii N+0.3*ii 0.3*ii],'k');
	set(hp,'FaceColor','k');
	hold on
	xlim([0 9]);
	
		sel		= modFreq==uMF(ii);
	ntrials = sum(sel);
	vs = NaN(ntrials,1);
	fr = vs;
	for jj = 1:ntrials
		spktime		= spk(jj).spiketime/1000;
		sel			= spktime>0.800 & spktime<1.50;
		spktime		= spktime(sel)-0.800;
		spktime		= spktime*uMF(ii);
		period		= mod(spktime,1);
		period		= 2*pi*period;
		
		nspikes		= numel(spktime);
		vs(jj)		= (1/nspikes)*sqrt( sum(cos(period)).^2+sum(sin(period)).^2);
		fr(jj)		= nspikes/700*1000;
	end
	VS(ii)		= nanmean(vs);
	VSsd(ii)	= nanstd(vs)./sqrt(numel(vs))/2;
	FR(ii)		= nanmean(fr);
	FRsd(ii)	= nanstd(fr)./sqrt(numel(fr))/2;
end
% plot(25/1000*uMF+0.25,0.3*(1:length(uMF)),'k-','LineWidth',2)
% plot(25/1000*uMF+0.75,0.3*(1:length(uMF)),'k-','LineWidth',2)
% pa_verline(0:12);
rayleigh = VS.^2*2.*FR;


subplot(232)
errorbar(uMF,VS,VSsd,'ko-','LineWidth',2,'MarkerFaceColor','w');
hold on
axis square
ylim([0 1]);
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');
xlabel('Modulation frequency (Hz)');
ylabel('Vector strength');

subplot(235)
errorbar(uMF,FR,FRsd,'ko-','LineWidth',2,'MarkerFaceColor','w');
hold on
axis square
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');

subplot(233)
errorbar(uMF,VS.*FR,VSsd+FRsd,'ko-','LineWidth',2,'MarkerFaceColor','w');
hold on
axis square
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');

subplot(236)
plot(uMF,rayleigh,'k-','LineWidth',2,'MarkerFaceColor','w'); 
hold on
axis square
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');

rayleighP = rayleigh;
MTFP = VS.*FR;
%% AM500
spike = spikeAMA500;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
col			= jet(nMF);
A500 = [];
figure(1)
VS		= NaN(nMF,1);
VSsd	= VS;
FR		= VS;
FRsd	= VS;
for ii		= 1:nMF
	sel		= modFreq==uMF(ii);
	spk		= spike(sel);
	spk1	= [spk.spiketime]/1000; % spike times in s
	sel		= spk1>0.8 & spk1<1.5;
	spk1	= spk1(sel)-0.8;
	spk1	= spk1*uMF(ii);
	[N,xp]	= hist(spk1,x);
% 	xp = xp-2/uMF(ii);
	convN	= conv(N,window);
	N		= convN(1:end-winsize*2);
	N		= 0.3* N/max(N);

	sel		= modFreq==uMF(ii);
	ntrials = sum(sel);
	vs = NaN(ntrials,1);
	fr = vs;
	for jj = 1:ntrials
		spktime		= spk(jj).spiketime/1000;
		sel			= spktime>0.800 & spktime<1.50;
		spktime		= spktime(sel)-0.800;
		spktime		= spktime*uMF(ii);
		period		= mod(spktime,1);
		period		= 2*pi*period;
		
		nspikes		= numel(spktime);
		vs(jj)		= (1/nspikes)*sqrt( sum(cos(period)).^2+sum(sin(period)).^2);
		fr(jj)		= nspikes/700*1000;
	end
	VS(ii)		= nanmean(vs);
	VSsd(ii)	= nanstd(vs)./sqrt(numel(vs))/2;
	FR(ii)		= nanmean(fr);
	FRsd(ii)	= nanstd(fr)./sqrt(numel(fr))/2;
	
	subplot(234)
try
	hp		= patch([xp(1) xp xp(end)],[0.3*ii N+0.3*ii 0.3*ii],'k');
	set(hp,'FaceColor',col(end,:));
catch
	plot(xp,N+0.3*ii,'k-','LineWidth',2,'Color',col(end,:));
end
	
	hold on
	xlim([0 9]);
end
rayleigh = VS.^2*2.*FR;
rayleighA500 = rayleigh;
MTFA500 = VS.*FR;

subplot(232)
errorbar(uMF,VS,VSsd,'rs-','LineWidth',2,'MarkerFaceColor','w');
axis square
ylim([0 1]);
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');
xlabel('Modulation frequency (Hz)');
ylabel('Vector strength');

subplot(235)
errorbar(uMF,FR,FRsd,'rs-','LineWidth',2,'MarkerFaceColor','w');
hold on
axis square
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');


subplot(233)
errorbar(uMF,VS.*FR,VSsd+FRsd,'rs-','LineWidth',2,'MarkerFaceColor','w');
hold on
axis square
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');

subplot(236)
plot(uMF,VS.^2*2.*FR,'r-','LineWidth',2,'MarkerFaceColor','w'); 
hold on
axis square
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');

%% AM1000
spike = spikeAMA1000;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
col			= jet(nMF);
A1000 = [];
figure(1)
VS		= NaN(nMF,1);
VSsd	= VS;
FR		= VS;
FRsd	= VS;
for ii		= 1:nMF
	sel		= modFreq==uMF(ii);
	spk		= spike(sel);
	spk1	= [spk.spiketime]/1000; % spike times in s
	sel		= spk1>1.3 & spk1<2.0;
	spk1	= spk1(sel)-1.3;
	spk1	= spk1*uMF(ii);
	[N,xp]	= hist(spk1,x);
% 	xp = xp-25/1000*uMF(ii);
	convN	= conv(N,window);
	N		= convN(1:end-winsize*2);
	N		= 0.3* N/max(N);

	sel		= modFreq==uMF(ii);
	ntrials = sum(sel);
	vs = NaN(ntrials,1);
	fr = vs;
	for jj = 1:ntrials
		spktime		= spk(jj).spiketime/1000;
		sel			= spktime>1.300 & spktime<2.00;
		spktime		= spktime(sel)-1.300;
		spktime		= spktime*uMF(ii);
		period		= mod(spktime,1);
		period		= 2*pi*period;
		
		nspikes		= numel(spktime);
		vs(jj)		= (1/nspikes)*sqrt( sum(cos(period)).^2+sum(sin(period)).^2);
		fr(jj)		= nspikes/700*1000;
	end
	VS(ii)		= nanmean(vs);
	VSsd(ii)	= nanstd(vs)./sqrt(numel(vs))/2;
	FR(ii)		= nanmean(fr);
	FRsd(ii)	= nanstd(fr)./sqrt(numel(fr))/2;
	
	subplot(234)
	plot(xp,N+0.3*ii,'k-','LineWidth',2,'Color',col(1,:));
	
	hold on
	xlim([0 9]);
end
rayleigh = VS.^2*2.*FR;
rayleighA1000 = rayleigh;
MTFA1000 = VS.*FR;

subplot(232)
errorbar(uMF,VS,VSsd,'bs-','LineWidth',2,'MarkerFaceColor','w');
axis square
ylim([0 1]);
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');

subplot(235)
errorbar(uMF,FR,FRsd,'bs-','LineWidth',2,'MarkerFaceColor','w');
hold on
axis square
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');
% ylim([0 200]);


subplot(233)
errorbar(uMF,VS.*FR,VSsd+FRsd,'bs-','LineWidth',2,'MarkerFaceColor','w');
hold on
axis square
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');

subplot(236)
plot(uMF,VS.^2*2.*FR,'b-','LineWidth',2,'MarkerFaceColor','w'); 
hold on
axis square
set(gca,'XTick',uMF,'XTick',round(uMF),'Xscale','log');

subplot(231)
ylabel('Modulation frequency (Hz) /  Spike density');
xlabel('Period');

subplot(234)
ylabel('Modulation frequency (Hz) /  Spike density');
xlabel('Period');

subplot(232)
xlabel('Modulation frequency (Hz)');
ylabel('Vector strength');

subplot(235)
xlabel('Modulation frequency (Hz)');
ylabel('Firing rate (Hz)');

subplot(233)
xlabel('Modulation frequency (Hz)');
ylabel('Magnitude (spikes/sec)');


subplot(236)
xlabel('Modulation frequency (Hz)');
ylabel('Rayleigh');
pa_horline(13.8);

