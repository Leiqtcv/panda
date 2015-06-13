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
fname = 'joe14512c01b00'; % Better rate & magnitude
fname = 'joe11311c02b00.mat'; % worse timing, better rate & magnitude
fname = 'thor09110'; % worse
fname = 'thor08411'; % worse
fname = 'joe16015c01b00'; % worse timing, higher/worse rate, equal magnitude
fname = 'joe12002c02b00';
% 
fname = 'joe17417c02b00';
fname = 'joe5405c01b00';
fname = 'joe15312c01b00';
fname = 'joe2105c01b00';

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

getmtf(spikeAMP,'k');
getmtf(spikeAMA500,'r');
getmtf(spikeAMA1000,'b');


function [tM,rM,VS,Phi] = getmtf(spike,col)
% Get temporal and rate codes / vector strength and firing rate
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
sigma		= 5;
winsize		= sigma*5;
t			= -winsize:winsize;
window		= normpdf(t,0,sigma);
x			= -1:0.01:100;
VS			= NaN(nMF,1);
VSsd		= VS;
FR			= VS;
FRsd		= VS;
periodSDF			= NaN(nMF,length(x));
EV = VS;
d = 0.700;
Nbin = 16;
ncomp = 1;
xperiod = linspace(0,1,Nbin);
tM = NaN(nMF,1);
rM = tM;
Phi = tM;
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
	P = [];
	nperiod = floor(d/(1/uMF(ii)));
	maxtime = nperiod*(1/uMF(ii));
	for jj = 1:ntrials
		spktime		= spk(jj).spiketime/1000;
		sel			= spktime>0.300+dur & spktime<1.00+dur;
		spktime		= spktime(sel)-0.300-dur;
		sel= spktime<=maxtime;
		spktime = spktime(sel);
		spktime		= spktime*uMF(ii);
		period		= mod(spktime,1);
		
		nspikes		= numel(spktime);
		vs(jj)		= (1/nspikes)*sqrt( sum(cos(2*pi*period)).^2+sum(sin(2*pi*period)).^2);
		fr(jj)		= nspikes/700*1000;
		P = [P period];
	end
	
	
	%%
	Nspikes = hist(P,xperiod);

	X			= fft(Nspikes,Nbin)/Nbin;
	tM(ii)	= abs(X(ncomp+1));
	Phi(ii)	= angle(X(ncomp+1));
	rM(ii)	= abs(X(ncomp+0));
	VS(ii)		= nanmean(vs);

end
rayleigh = VS.^2*2.*rM;


% keyboard

%%
subplot(221)
semilogx(uMF,10*log10(tM./max(tM)),'k-','Color',col);
hold on
axis square
box off
set(gca,'TickDir','out');
xlim([1 256*2]);
title('tMTF | magnitude');
set(gca,'XTick',uMF(1:2:end),'XTickLabel',round(uMF(1:2:end)));

subplot(222)
semilogx(uMF,10*log10(rM./max(rM)),'k-','Color',col);
hold on
axis square
box off
set(gca,'TickDir','out');
xlim([1 256*2]);
title('rMTF | DC');
set(gca,'XTick',uMF(1:2:end),'XTickLabel',round(uMF(1:2:end)));

Phi = unwrap(Phi);
subplot(223)
plot(uMF,Phi,'k-','Color',col);
hold on
axis square
box off
set(gca,'TickDir','out');
xlim([0 258]);
title('\phi');
% set(gca,'XTick',uMF(1:2:end),'XTickLabel',round(uMF(1:2:end)));

subplot(224)
semilogx(uMF,tM./rM,'k-','Color',col);
hold on
semilogx(uMF,VS,'k-','Color',[.7 .7 .7]);
axis square
box off
set(gca,'TickDir','out');
xlim([1 256*2]);
ylim([-0.1 1.1]);
title('(tMTF/rMTF) | vector strength');
set(gca,'XTick',uMF(1:2:end),'XTickLabel',round(uMF(1:2:end)));


