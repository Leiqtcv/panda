function pa_am_figure1

clc;
close all hidden;
clear all

cd('E:\DATA\Cortex\AMcells with tonespike');
% fnames = {'joe11311c02b00.mat';...
% 	'joe14512c01b00';...
% 	'joe14711c01b00';...
% 	'thor08411';...
% 	'thor09110';...
% 	};

fname = 'joe14711c01b00'; % worse
% fname = 'joe14512c01b00'; % Better rate & magnitude
% fname = 'joe11311c02b00.mat'; % worse timing, better rate & magnitude
% fname = 'thor09110'; % worse
fname = 'thor08411'; % worse
% fname = 'joe16015c01b00'; % worse timing, higher/worse rate, equal magnitude
% fname = 'joe12002c02b00';

% fname = 'joe17417c02b00';
% fname = 'joe5405c01b00';
% fname = 'joe15312c01b00';
% fname = 'thor087'; % worse
% fname = 'joe2105c01b00';

load(fname)
stim			= [spikeAMA.stimvalues];
mn = min([length(spikeAMA) length(behAM)]);

stim = stim(:,1:mn);
dur				= stim(3,:);
sel				= dur==500;
spikeAMA500		= spikeAMA(sel);
spikeAMA1000	= spikeAMA(~sel);
sum(sel)

behAMA500		= behAM(:,sel); %#ok<*NASGU,*NODEF>
behAMA1000		= behAM(:,~sel);

%% P
[VS,FR,periodSDF,xp,uMF,EV] = getmtf(spikeAMP);


subplot(234)
plotsdf(periodSDF,xp,uMF,'k');

subplot(231)
xi = logspace(log10(min(uMF)),log10(max(uMF)),200); 
yi = interp1(uMF,VS,xi,'spline');
h = semilogx(xi,smooth(yi,50),'k-');
set(h,'LineWidth',1,'MarkerFaceColor','w');
hold on
h = semilogx(uMF,VS,'ko');
set(h,'LineWidth',1,'MarkerFaceColor','w');


% subplot(231)
% yi = interp1(uMF,EV,xi,'spline');
% h = semilogx(xi,smooth(yi,50),'k-');
% set(h,'LineWidth',1,'MarkerFaceColor','w');
% hold on
% h = semilogx(uMF,EV,'ks','Color',[.7 .7 .7]);
% set(h,'LineWidth',1,'MarkerFaceColor','w');


subplot(232)
xi = logspace(log10(min(uMF)),log10(max(uMF)),200); 
yi = interp1(uMF,FR,xi,'spline');
h = semilogx(xi,smooth(yi,50),'k-');
set(h,'LineWidth',1,'MarkerFaceColor','w');
hold on
h = semilogx(uMF,FR,'ko');
hold on
set(h,'LineWidth',1,'MarkerFaceColor','w');
title(fname);

subplot(233)
xi = logspace(log10(min(uMF)),log10(max(uMF)),200); 
yi = interp1(uMF,VS.*FR,xi,'spline');
h = semilogx(xi,smooth(yi,50),'k-');
set(h,'LineWidth',1,'MarkerFaceColor','w');
hold on
h = semilogx(uMF,VS.*FR,'ko');
hold on
set(h,'LineWidth',1,'MarkerFaceColor','w');

%%
[VS,FR,periodSDF,xp,uMF,EV] = getmtf(spikeAMA500);
subplot(235)
plotsdf(periodSDF,xp,uMF,'r');

subplot(231)
xi = logspace(log10(min(uMF)),log10(max(uMF)),200); 
% xi = logspace(log10(min(uMF)),log10(max(uMF)),200);


yi = interp1(uMF,VS,xi,'spline');
h = semilogx(xi,smooth(yi,50),'r-');
set(h,'LineWidth',1,'MarkerFaceColor','w');
hold on
h = semilogx(uMF,VS,'ro');
set(h,'LineWidth',1,'MarkerFaceColor','w');

% yi = interp1(uMF,EV,xi,'spline');
% h = semilogx(xi,smooth(yi,50),'r-');
% set(h,'LineWidth',1,'MarkerFaceColor','w');
% hold on
% h = semilogx(uMF,EV,'ro');
% set(h,'LineWidth',1,'MarkerFaceColor','w','Color',[1 .7 .7]);

subplot(232)
xi = logspace(log10(min(uMF)),log10(max(uMF)),200); 
yi = interp1(uMF,FR,xi,'spline');
h = semilogx(xi,smooth(yi,50),'r-');
set(h,'LineWidth',1,'MarkerFaceColor','w');
hold on
h = semilogx(uMF,FR,'ro');
hold on
set(h,'LineWidth',1,'MarkerFaceColor','w');

subplot(233)
xi = logspace(log10(min(uMF)),log10(max(uMF)),200); 
yi = interp1(uMF,VS.*FR,xi,'spline');
h = semilogx(xi,smooth(yi,50),'r-');
set(h,'LineWidth',1,'MarkerFaceColor','w');
hold on
h = semilogx(uMF,VS.*FR,'ro');
hold on
set(h,'LineWidth',1,'MarkerFaceColor','w');


%%
[VS,FR,periodSDF,xp,uMF,EV] = getmtf(spikeAMA1000);
subplot(236)
plotsdf(periodSDF,xp,uMF,'b');


subplot(231)
xi = logspace(log10(min(uMF)),log10(max(uMF)),200); 
yi = interp1(uMF,VS,xi,'spline');
h = semilogx(xi,smooth(yi,50),'b-');
set(h,'LineWidth',1,'MarkerFaceColor','w');
hold on
h = semilogx(uMF,VS,'bo');
set(h,'LineWidth',1,'MarkerFaceColor','w');

% subplot(231)
% xi = logspace(log10(min(uMF)),log10(max(uMF)),200); 
% yi = interp1(uMF,EV,xi,'spline');
% h = semilogx(xi,smooth(yi,50),'b-');
% set(h,'LineWidth',1,'MarkerFaceColor','w');
% hold on
% h = semilogx(uMF,EV,'bo');
% set(h,'LineWidth',1,'MarkerFaceColor','w','Color',[.7 .7 1]);

subplot(232)
xi = logspace(log10(min(uMF)),log10(max(uMF)),200); 
yi = interp1(uMF,FR,xi,'spline');
h = semilogx(xi,smooth(yi,50),'b-');
set(h,'LineWidth',1,'MarkerFaceColor','w');
hold on
h = semilogx(uMF,FR,'bo');
hold on
set(h,'LineWidth',1,'MarkerFaceColor','w');

subplot(233)
xi = logspace(log10(min(uMF)),log10(max(uMF)),200); 
yi = interp1(uMF,VS.*FR,xi,'spline');
h = semilogx(xi,smooth(yi,50),'b-');
set(h,'LineWidth',1,'MarkerFaceColor','w');
hold on
h = semilogx(uMF,VS.*FR,'bo');
hold on
set(h,'LineWidth',1,'MarkerFaceColor','w');



%% Graphics
subplot(232)
set(gca,'XTick',uMF(1:2:end),'XTickLabel',round(uMF(1:2:end)));
axis square;
box off
% ylim([0 1]);
xlim([1 256*2]);
xlabel('Modulation Frequency (Hz)');
ylabel('Firing rate (Hz)');


subplot(231)
set(gca,'XTick',uMF(1:2:end),'XTickLabel',round(uMF(1:2:end)));
axis square;
box off
ylim([0 1]);
xlim([1 256*2]);
ylabel('Vector strength');
xlabel('Modulation Frequency (Hz)');

subplot(233)
set(gca,'XTick',uMF(1:2:end),'XTickLabel',round(uMF(1:2:end)));
axis square;
box off

xlim([1 256*2]);
ylabel('Magnitude');
xlabel('Modulation Frequency (Hz)');


%% REACTION TIME
% getreact(spikeAMA1000,behAMA1000);
return
figure
subplot(231)
pa_spk_rasterplot(spikeAMP);
axis square;
xlim([800 1500]);

subplot(232)
pa_spk_rasterplot(spikeAMA500);
axis square;
xlim([800 1500]);

subplot(233)
pa_spk_rasterplot(spikeAMA1000);
axis square;
xlim([1300 2000]);

function [VS,FR,periodSDF,xp,uMF,EV] = getmtf(spike)
% Get temporal and rate codes / vector strength and firing rate
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
sigma		= 5;
winsize		= sigma*5;
t			= -winsize:winsize;
window		= normpdf(t,0,sigma);
x			= -1:0.01:200;
VS			= NaN(nMF,1);
VSsd		= VS;
FR			= VS;
FRsd		= VS;
periodSDF			= NaN(nMF,length(x));
EV = VS;
for ii		= 1:nMF
	sel		= modFreq==uMF(ii);
	spk		= spike(sel);
	dur		= spk(1).stimvalues(3)/1000;
	spk1	= [spk.spiketime]/1000; % spike times in s
	sel		= spk1>0.300+dur & spk1<1.000+dur;
	spk1	= spk1(sel)-0.300-dur;
	spk1	= spk1*uMF(ii);
	[N,xp]	= hist(spk1,x);
	convN	= conv(N,window);
	N		= convN(1:end-winsize*2);
	N		= N/max(N);
	
	
	sel		= modFreq==uMF(ii);
	ntrials = sum(sel);
	vs		= NaN(ntrials,1);
	fr		= vs;
	for jj = 1:ntrials
		spktime		= spk(jj).spiketime/1000;
		sel			= spktime>0.300+dur & spktime<1.00+dur;
		spktime		= spktime(sel)-0.300-dur;
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
	periodSDF(ii,:)		= N;

	xpm = mod(xp,1);
% 	periodSDF(ii,:)
	uMF(ii)
% 	%%
% 	t = 1-0.3;
% 	np = t*uMF(ii)';
% 	np = floor(np);
% 	indx = find(xp==np);
% 	a = periodSDF(ii,1:indx);
% 	na = length(a);
% 	n1 = np;
% 	n2 = floor(na/np);
% 	indx = n1*n2;
% 	b = reshape(a(1:indx),n1,n2);
% 	if ~isempty(b)
% 		[u,s,v] = svd(b);
% % 		figure(1)
% % 		subplot(121)
% % 		plot(b');
% % 		
% % 		subplot(122)
% % 		plot(v(:,1))
% 		ev=diag(s)/sum(diag(s));
% 		ev = ev(1);
% % 		title(ev(1))
% 	else ev = NaN;
% 	end
% 	EV(ii)		= ev;	
	%%
% 	keyboard
% drawnow
% pause(.5)
end
rayleigh = VS.^2*2.*FR;

function plotsdf(SDF,xp,uMF,col)
if nargin<4
	col = 'k';
end
for ii = 1:size(SDF,1);
x = xp/uMF(ii);
	hp		= patch([x(1) x x(end)],[0.3*ii 0.25*SDF(ii,:)+0.3*ii 0.3*ii],col);
	set(hp,'FaceColor',col);
	
	% plot(xp,0.4*SDF(ii,:)+0.3*ii,col);
	
	
	% 	hp		= patch([xp(1) xp xp(end)],[0.3*ii 0.4*SDF(ii,:)+0.3*ii 0.3*ii],col);
	% 	set(hp,'FaceColor',col);
	
	hold on
% 	xlim([0 9]);
end

% for ii = 1:size(SDF,1);
% plot(xp,0.4*SDF(ii,:)+0.3*ii,'w','LineWidth',1);
% end
axis square;
box off
ylabel('Modulation frequency (Hz) /  Spike density');
xlabel('Period');
% set(gca,'YTick',0.3*(1:2:length(uMF)),'YTickLabel',round(uMF(1:2:end)));
% set(gca,'XTick',1:9);
% plot(20*uMF/1000,0.3*(1:length(uMF)),col,'LineWidth',2);
% plot(700*uMF/1000,0.3*(1:length(uMF)),col,'LineWidth',2);
xlim([0 0.7]);
function getreact(spike,beh)
% Get temporal and rate codes / vector strength and firing rate
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
sigma		= 20;
winsize		= sigma*5;
t			= -winsize:winsize;
window		= normpdf(t,0,sigma);
x			= -300:1:300;

for ii		= 1:nMF
	sel		= modFreq==uMF(ii);
	spk		= spike(sel);
	rt		= beh(2,sel);
	dur		= spk(1).stimvalues(3);
	
	for jj = 1:numel(rt)
		spk(jj).spiketime = spk(jj).spiketime-rt(jj)-89-300-dur;
		% 		spk(jj).spiketime
	end
	spk1	= [spk.spiketime]; % spike times in s
	sel		= spk1>-300 & spk1<300;
	spk1	= spk1(sel);
	[N,xp]	= hist(spk1,x);
	convN	= conv(N,window);
	N		= convN(1:end-winsize*2);
	% 	N		= N/max(N);
	
	%
	% 	sel		= modFreq==uMF(ii);
	% 	ntrials = sum(sel);
	% 	vs		= NaN(ntrials,1);
	% 	fr		= vs;
	% 	for jj = 1:ntrials
	% % 		spktime		= spk(jj).spiketime/1000;
	% 		spktime		= spk(jj).spiketime-rt(jj)/1000-dur-0.3;
	%
	% 		sel			= spktime>-0.300 & spktime<0.3;
	% 		spktime		= spktime(sel);
	%
	% 		nspikes		= numel(spktime);
	% 		vs(jj)		= (1/nspikes)*sqrt( sum(cos(period)).^2+sum(sin(period)).^2);
	% 		fr(jj)		= nspikes/700*1000;
	% 	end
	% 	VS(ii)		= nanmean(vs);
	% 	VSsd(ii)	= nanstd(vs)./sqrt(numel(vs))/2;
	% 	FR(ii)		= nanmean(fr);
	% 	FRsd(ii)	= nanstd(fr)./sqrt(numel(fr))/2;
		periodSDF(ii,:)		= N;
	
end
	figure(666)
	plot(mean(periodSDF))
	hold on
	pa_verline(300);
	xlim(300+[-100 100]);
