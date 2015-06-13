function pa_am_allcells

clc;
close all hidden;
clear all

cd('E:\DATA\selected cells');
cd('E:\DATA\Cortex\AMcells with tonespike');
d = dir('*.mat');
fnames = {d.name};
nfiles = length(d);
k = 0;
for ii = 1:nfiles
	
	fname = fnames{ii};
	load(fname)
	
	mn			= min([size(spikeAMA,2) size(behAM,2)]);
	spikeAMA	= spikeAMA(:,1:mn);
	behAM		= behAM(:,1:mn);
	
	stim			= [spikeAMA.stimvalues];
	dur				= stim(3,:);
	sel				= dur==500;
	
	spikeAMA500		= spikeAMA(sel);
	spikeAMA1000	= spikeAMA(~sel);
	behAMA500		= behAM(:,sel); %#ok<*NASGU,*NODEF>
	behAMA1000		= behAM(:,~sel);
	
	[VSp,FRp,periodSDFp,Rp,xp,uMFp]							= getmtf(spikeAMP);
	[VSa500,FRa500,periodSDFa500,Ra500,xa500,uMFa500]		= getmtf(spikeAMA500);
	[VSa1000,FRa1000,periodSDFa1000,Ra1000,xa1000,uMFa1000]	= getmtf(spikeAMA1000);
	MIp			= getmi(spikeAMP);
	MIa500		= getmi(spikeAMA500);
	MIa1000		= getmi(spikeAMA1000);
	
% 	if true
% 	if any(Rp>13.8) || any(Ra500>13.8) || any(Ra1000>13.8)
try
		k = k+1;
		
		MI(k,:) = [MIp MIa500 MIa1000];
		VS(k,:) = [max(VSp) max(VSa500) max(VSa1000)];
		grph = false;
		if grph
		figure(1)
		clf;	%% P
		
		subplot(331)
		xi = logspace(log10(min(uMFp)),log10(max(uMFp)),200);
		yi = interp1(uMFp,VSp,xi,'spline');
		h = semilogx(xi,smooth(yi,50),'k-');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		hold on
		h = semilogx(uMFp,VSp,'ko');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		title(k);
		xi = logspace(log10(min(uMFa500)),log10(max(uMFa500)),200);
		% xi = logspace(log10(min(uMFa500)),log10(max(uMFa500)),200);
		yi = interp1(uMFa500,VSa500,xi,'spline');
		h = semilogx(xi,smooth(yi,50),'r-');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		hold on
		h = semilogx(uMFa500,VSa500,'ro');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		xi = logspace(log10(min(uMFa1000)),log10(max(uMFa1000)),200);
		yi = interp1(uMFa1000,VSa1000,xi,'spline');
		h = semilogx(xi,smooth(yi,50),'b-');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		hold on
		h = semilogx(uMFa1000,VSa1000,'bo');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		set(gca,'XTick',uMFp(1:2:end),'XTickLabel',round(uMFp(1:2:end)));
		axis square;
		box off
		ylim([0 1]);
		xlim([1 256*2]);
		ylabel('Vector strength');
		xlabel('Modulation Frequency (Hz)');
				
		
		subplot(332)
		xi = logspace(log10(min(uMFp)),log10(max(uMFp)),200);
		yi = interp1(uMFp,FRp,xi,'spline');
		h = semilogx(xi,smooth(yi,50),'k-');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		hold on
		h = semilogx(uMFp,FRp,'ko');
		hold on
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		title(fname);
		xi = logspace(log10(min(uMFa500)),log10(max(uMFa500)),200);
		yi = interp1(uMFa500,FRa500,xi,'spline');
		h = semilogx(xi,smooth(yi,50),'r-');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		hold on
		h = semilogx(uMFa500,FRa500,'ro');
		hold on
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		xi = logspace(log10(min(uMFa1000)),log10(max(uMFa1000)),200);
		yi = interp1(uMFa1000,FRa1000,xi,'spline');
		h = semilogx(xi,smooth(yi,50),'b-');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		hold on
		h = semilogx(uMFa1000,FRa1000,'bo');
		hold on
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		set(gca,'XTick',uMFp(1:2:end),'XTickLabel',round(uMFp(1:2:end)));
		axis square;
		box off
		% ylim([0 1]);
		xlim([1 256*2]);
		xlabel('Modulation Frequency (Hz)');
		ylabel('Firing rate (Hz)');
						
		subplot(333)
		xi = logspace(log10(min(uMFp)),log10(max(uMFp)),200);
		yi = interp1(uMFp,VSp.*FRp,xi,'spline');
		h = semilogx(xi,smooth(yi,50),'k-');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		hold on
		h = semilogx(uMFp,VSp.*FRp,'ko');
		hold on
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		xi = logspace(log10(min(uMFa500)),log10(max(uMFa500)),200);
		yi = interp1(uMFa500,VSa500.*FRa500,xi,'spline');
		h = semilogx(xi,smooth(yi,50),'r-');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		hold on
		h = semilogx(uMFa500,VSa500.*FRa500,'ro');
		hold on
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		xi = logspace(log10(min(uMFa1000)),log10(max(uMFa1000)),200);
		yi = interp1(uMFa1000,VSa1000.*FRa1000,xi,'spline');
		h = semilogx(xi,smooth(yi,50),'b-');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		hold on
		h = semilogx(uMFa1000,VSa1000.*FRa1000,'bo');
		hold on
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		set(gca,'XTick',uMFp(1:2:end),'XTickLabel',round(uMFp(1:2:end)));
		axis square;
		box off
		
		xlim([1 256*2]);
		ylabel('Magnitude');
		xlabel('Modulation Frequency (Hz)');
				
				
		%%
		subplot(334)
		plotsdf(periodSDFp,xp,uMFp,'k');
		title(num2str(MIp,2));

		subplot(335)
		plotsdf(periodSDFa500,xa500,uMFa500,'r');
		title(num2str(MIa500,2));
		
		subplot(336)
		plotsdf(periodSDFa1000,xa1000,uMFa1000,'b');
		title(num2str(MIa1000,2));
		
		%% Rayleigh
		subplot(337)
		h = semilogx(uMFp,Rp,'ko-','MarkerFaceColor','w');
		hold on
		h = semilogx(uMFa500,Ra500,'ro-','MarkerFaceColor','w');
		h = semilogx(uMFa1000,Ra1000,'bo-','MarkerFaceColor','w');
		set(h,'LineWidth',1,'MarkerFaceColor','w');
		hold on
		axis square;
		box off;
		pa_horline(13.8);
		
		subplot(338);
		plot(VSp,VSa500,'ro-','MarkerFaceColor','w');
		hold on
		plot(VSp,VSa1000,'bo-','MarkerFaceColor','w');
		axis([0 1 0 1]);
		axis square;
		pa_unityline;
		box off

		subplot(339);
		plot(FRp,FRa500,'ro-','MarkerFaceColor','w');
		hold on
		plot(FRp,FRa1000,'bo-','MarkerFaceColor','w');
% 		axis([0 1 0 1]);
		axis square;
		pa_unityline;
		box off
		
		%% Graphics
		drawnow
% 		pause;
		end
	end
end

% keyboard
%%
% close all
figure
subplot(121)
plot(MI(:,1),MI(:,2),'r.','MarkerFaceColor','w');
hold on
plot(MI(:,1),MI(:,3),'b.','MarkerFaceColor','w');
axis([0 3 0 3]);
axis square;
pa_unityline;
pa_horline(1);
pa_verline(1);
xlabel('Passive Mutual information (bits)');
ylabel('Active Mutual information (bits)');

a = [MI(:,1); MI(:,1)];
b = [MI(:,2); MI(:,3)];
d = [VS(:,2); VS(:,3)];
c = [VS(:,1); VS(:,1)];

X = [a b c d];

[idx,C] = kmeans(X, 3);
col = hsv(3);
for ii = 1:3
	x = X(idx==ii,1);
	y = X(idx==ii,2);
	plot(x,y,'.','Color',col(ii,:));
	[MU,SD,A] = pa_ellipse(x,y);
	h = pa_ellipseplot(MU,1.96*SD,A,'Color',col(ii,:));
end
box off


subplot(122)
plot(VS(:,1),VS(:,2),'r.','MarkerFaceColor','r');
hold on
plot(VS(:,1),VS(:,3),'b.','MarkerFaceColor','b');
axis([0 1 0 1]);
axis square;
pa_unityline;
xlabel('Passive Max. Vector strength');
ylabel('Active  Max. Vector strength');
box off

for ii = 1:3
	x = X(idx==ii,3);
	y = X(idx==ii,4);
	plot(x,y,'.','Color',col(ii,:));
	[MU,SD,A] = pa_ellipse(x,y);
	h = pa_ellipseplot(MU,1.96*SD,A,'Color',col(ii,:));
end

% a = [VS(:,1); VS(:,1)];
% b = [VS(:,2); VS(:,3)];
% X = [a b];
% 
% [idx,C] = kmeans(X, 3);
% col = hsv(3);
% for ii = 1:3
% 	x = X(idx==ii,1);
% 	y = X(idx==ii,2);
% 	plot(x,y,'.','Color',col(ii,:));
% 	
% 	[MU,SD,A] = pa_ellipse(x,y);
% 	h = pa_ellipseplot(MU,1.96*SD,A,'Color',col(ii,:));
% end
% box off

% plot(C(:,1),C(:,2),'*');

%% REACTION TIME
% getreact(spikeAMA1000,behAMA1000);
return
figure
subplot(331)
pa_spk_rasterplot(spikeAMP);
axis square;
xlim([800 1500]);

subplot(332)
pa_spk_rasterplot(spikeAMA500);
axis square;
xlim([800 1500]);

subplot(333)
pa_spk_rasterplot(spikeAMA1000);
axis square;
xlim([1300 2000]);

function [VS,FR,periodSDF,rayleigh,xp,uMF] = getmtf(spike)
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
end
rayleigh = VS.^2*2.*FR;


function MI = getmi(spike)
%% Mutual information
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
N			= NaN(nMF,5);
for ii		= 1:nMF
	sel		= modFreq==uMF(ii);
	spk		= spike(sel);
	dur		= spk(1).stimvalues(3)/1000;

	sel		= modFreq==uMF(ii);
	ntrials = sum(sel);
	vs		= NaN(ntrials,1);
	fr		= vs;
	for jj = 1:ntrials
		spktime		= spk(jj).spiketime/1000;
		sel			= spktime>0.300+dur & spktime<1.00+dur;
		spktime		= spktime(sel)-0.300-dur;
		
		nspikes		= numel(spktime);
		N(ii,jj) = nspikes;
	end
end
pX = 1/nMF;

R = N;
R = (R-min(R(:)))./(max(R(:))-min(R(:)));
R = round(R*nMF)./nMF;


r = unique(R);
pR = hist(R(:),r);
pR = pR./sum(pR);


X = uMF;
nX = nMF;
uR = unique(R);
nR = numel(uR);

Pxr = NaN(nX,nR);
Px = Pxr;
Pr = Pxr;

for ii = 1:nX
	for jj = 1:nR
		sel = X==uMF(ii);
		selr = R(sel,:)==uR(jj);
		Pxr(ii,jj) = sum(selr);
		Px(ii,jj) = 1/nMF;
		Pr(ii,jj) = pR(jj);
	end
end
Pxr = Pxr./sum(Pxr(:));

MI = nansum(nansum(Pxr.*log2(Pxr./(Px.*Pr))));

function plotsdf(SDF,xp,uMF,col)
if nargin<4
	col = 'k';
end
for ii = 1:size(SDF,1);
	hp		= patch([xp(1) xp xp(end)],[0.3*ii 0.25*SDF(ii,:)+0.3*ii 0.3*ii],col);
	set(hp,'FaceColor',col);
	
	% plot(xp,0.4*SDF(ii,:)+0.3*ii,col);
	
	
	% 	hp		= patch([xp(1) xp xp(end)],[0.3*ii 0.4*SDF(ii,:)+0.3*ii 0.3*ii],col);
	% 	set(hp,'FaceColor',col);
	
	hold on
	xlim([0 9]);
end

% for ii = 1:size(SDF,1);
% plot(xp,0.4*SDF(ii,:)+0.3*ii,'w','LineWidth',1);
% end
axis square;
box off
ylabel('Modulation frequency (Hz) /  Spike density');
xlabel('Period');
set(gca,'YTick',0.3*(1:2:length(uMF)),'YTickLabel',round(uMF(1:2:end)));
set(gca,'XTick',1:9);
plot(20*uMF/1000,0.3*(1:length(uMF)),col,'LineWidth',2);
plot(700*uMF/1000,0.3*(1:length(uMF)),col,'LineWidth',2);

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
