function pa_am_allcells

clc;
close all hidden;
clear all

cd('E:\DATA\selected cells');
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
	
	try
		figure(1)
		subplot(121)
		cla;
		
		subplot(122)
		cla;
		
		figure(2)
		cla
		figure(1)
		getdata(spikeAMP,spikeAMA500,spikeAMA1000);
		pause
	end
end


function getdata(spikeAMP,spikeAMA500,spikeAMA1000)



% pa_spk_rasterplot(spikeAMp);
figure(1)
[P,A500,A1000] = sdfplot(spikeAMP,spikeAMA500,spikeAMA1000);

return

%% Oscillations baseline
n = size(P,1);
beta = 0;
gamma = 0;
for ii = 1:n
	p = P(ii,1:300);
	sel = ~isnan(p);
	p = p(sel);
	[F,PP] = pa_getpower(p,1000);
	
	p = A500(ii,1:300);
	sel = ~isnan(p);
	p = p(sel);
	[F,P500] = pa_getpower(p,1000);
	
	p = A1000(ii,1:300);
	sel = ~isnan(p);
	p = p(sel);
	[F,P1000] = pa_getpower(p,1000);
	
	beta = beta+P500-PP;
	gamma = gamma+P1000-PP;
end
beta		= beta/n;
gamma		= gamma/n;

figure(3)
plot(F,(smooth(beta,20)+smooth(gamma,20))/2,'r-','LineWidth',2,'Color',[.7 .7 .7]);
hold on
xlim([2 100]);
set(gca,'XTick',10.^(0:2),'XTickLabel',10.^(0:2));
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
axis square;


%% Oscillations static
n = size(P,1);
beta = 0;
gamma = 0;
for ii = 1:n
	p = P(ii,400:800);
	sel = ~isnan(p);
	p = p(sel);
	[F,PP] = pa_getpower(p,1000);
	
	p = A500(ii,400:800);
	sel = ~isnan(p);
	p = p(sel);
	[F,P500] = pa_getpower(p,1000);
	
	p = A1000(ii,400:800);
	sel = ~isnan(p);
	p = p(sel);
	[F,P1000] = pa_getpower(p,1000);
	
	

	beta = beta+P500-PP;
	gamma = gamma+P1000-PP;
end
beta		= beta/n;
gamma		= gamma/n;

figure(3)
plot(F,(smooth(beta,20)+smooth(gamma,20))/2,'r-','LineWidth',2,'Color','k');
hold on
xlim([2 100]);
set(gca,'XTick',10.^(0:2),'XTickLabel',10.^(0:2));
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
axis square;


%% Oscillations static
n = size(P,1);
beta = 0;
gamma = 0;
for ii = 1:n
	p = P(ii,800:1800);
	sel = ~isnan(p);
	p = p(sel);
	[F,PP] = pa_getpower(p,1000);
	
	p = A500(ii,800:1800);
	sel = ~isnan(p);
	p = p(sel);
	[F,P500] = pa_getpower(p,1000);
	
	p = A1000(ii,1300:2300);
	sel = ~isnan(p);
	p = p(sel);
	[F,P1000] = pa_getpower(p,1000);
	
	
	beta = beta+P500-PP;
	gamma = gamma+P1000-PP;
end
beta		= beta/n;
gamma		= gamma/n;

figure(3)
plot(F,(smooth(beta,20)+smooth(gamma,20))/2,'r-','LineWidth',2,'Color','r');
hold on
xlim([2 100]);
set(gca,'XTick',10:10:100,'XTickLabel',10:10:100);
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
axis square;
% ylim([0 7]);
legend({'Spontaneous','Unmodulated','Modulated'},'Location','SE');

function [P,A500,A1000] = sdfplot(spikeAMP,spikeAMA500,spikeAMA1000)
n = 3000;


%% PASSIVE
spike = spikeAMP;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
col			= jet(nMF);
P = [];
figure(1)
for ii		= 1:nMF
	
	sel = modFreq==uMF(ii);
	spk = spike(sel);
	[MSDF,sdf] = pa_spk_sdf(spk);
	t = 1:length(MSDF);
	MSDF = 0.1*MSDF/(2*std(MSDF));
	A			= 1+sin(2*pi*uMF(ii)*t/1000);
	
	
	A = A./max(A);
	A = A*0.1;
	A(1:800) = 0;
	A(1500:end) = 0;
	
	figure(1)
	subplot(121)
	
% 	plot(t,A+0.3*ii,'k-','Color',[.7 .7 .7]);
	hold on
	% 	plot(t,MSDF+0.3*ii,'k-','Color',col(ii,:),'LineWidth',2)

% 		plot(t,MSDF+0.3*ii,'k-','Color',[.8 .8 .8],'LineWidth',2)
	hp = patch([t(1) t t(end)],[0.3*ii MSDF+0.3*ii 0.3*ii],'k');
	set(hp,'FaceColor',[.8 .8 .8]);
% 	cedge = col(end,:)+0.2;
% 	cedge(cedge>1) = 1;
% 	set(hp,'EdgeColor',cedge,'LineWidth',2);

	
	subplot(122)
	% 	plot(t,A+0.2*ii,'k-','Color',[.7 .7 .7]);
	hold on
	% 	plot(t,MSDF+0.3*ii,'k-','Color',col(ii,:),'LineWidth',2)
% 	plot(t+500,MSDF+0.3*ii,'k-','Color',[.7 .7 .7],'LineWidth',2)
	hp = patch([t(1) t t(end)]+500,[0.3*ii MSDF+0.3*ii 0.3*ii],'k');
	set(hp,'FaceColor',[.8 .8 .8]);

	MSDF	= [MSDF NaN(1,n-length(MSDF))];
	P		= [P;MSDF];
	
	T	= 1/uMF(ii)*1000;
	fr	= MSDF(800:2300);
	t	= (1:length(fr));
	t	= round(mod(t,T));
	ut = unique(t);
	nt = length(ut);
	FR = NaN(nt,1);
	for jj = 1:nt
		sel = t==ut(jj);
		sum(sel)
		FR(jj) = nanmean(fr(sel));

	end
% 	figure(2)
% 	cla
% 	plot(ut,FR*100)
% 	hold on
% 	plot(1:length(A(800:1300)),A(800:1300));
% 	xlim([0 max(ut)]);
% 	drawnow
% 	pause
[mx(ii),indx] = max(FR*1000);
mx(ii) = median(FR*1000);
l = length(FR);
nfft			= 2^(nextpow2(l));

fftx = fft(FR,nfft);
% Calculate the numberof unique points
NumUniquePts	= ceil((nfft+1)/2);
% FFT is symmetric, throw away second half
fftx			= fftx(1:NumUniquePts);

amp	= abs(fftx)/l*1000;

mx(ii) = max(amp(3));
f		= (0:NumUniquePts-1)*1000/nfft;
[f(3) uMF(ii)]

end
% figure(1)
subplot(121)
plot((1./uMF)*1000+500+300,0.3*(1:length(uMF)),'ko-','MarkerFaceColor','w');
plot((2./uMF)*1000+500+300,0.3*(1:length(uMF)),'ko-','MarkerFaceColor','w');
plot((3./uMF)*1000+500+300,0.3*(1:length(uMF)),'ko-','MarkerFaceColor','w');
plot((4./uMF)*1000+500+300,0.3*(1:length(uMF)),'ko-','MarkerFaceColor','w');
plot((5./uMF)*1000+500+300,0.3*(1:length(uMF)),'ko-','MarkerFaceColor','w');
plot((6./uMF)*1000+500+300,0.3*(1:length(uMF)),'ko-','MarkerFaceColor','w');

box off
xlabel('Time (ms)');
set(gca,'YTick',0.3*(1:nMF),'YTickLabel',round(uMF));
set(gca,'XTick',[300 800 1500],'XTickLabel',[0 500 1200]);
grid on
xlim([0 1900]);
xlim([800 1500]);
title('P');

figure(2)
plot(uMF,mx,'ko-','MarkerFaceColor','w');
set(gca,'XScale','log');
set(gca,'XTick',uMF,'XTickLabel',round(uMF));
% keyboard

figure(1)
%% AM500
spike = spikeAMA500;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
col			= jet(nMF);
A500 = [];
	figure(1)

for ii		= 1:nMF
	
	sel = modFreq==uMF(ii);
	spk = spike(sel);
	[MSDF,sdf] = pa_spk_sdf(spk);
		MSDF = 0.1*MSDF/(2*std(MSDF));

	t = 1:length(MSDF);
	A			= 1+sin(2*pi*uMF(ii)*t/1000);
	A = A./max(A);
	A = A*0.1;
	A(1:800) = 0;
	A(1500:end) = 0;
	
	subplot(121)
	% 	plot(t,A+0.2*ii,'k-','Color',[.7 .7 .7]);
	hold on
	plot(t, MSDF+0.3*ii,'k-','Color',col(end,:),'LineWidth',2)
% 	hp = patch([t(1) t t(end)],[0.3*ii MSDF+0.3*ii 0.3*ii],'k');
% 	set(hp,'FaceColor',col(end,:));
% 	cedge = col(end,:)+0.2;
% 	cedge(cedge>1) = 1;
% 	set(hp,'EdgeColor',cedge,'LineWidth',2);
% 	get(hp)

	MSDF = [MSDF NaN(1,n-length(MSDF))];
	A500 = [A500;MSDF];
end
box off
xlabel('Time (ms)');
set(gca,'YTick',0.3*(1:nMF),'YTickLabel',round(uMF));
set(gca,'XTick',[300 800 1500],'XTickLabel',[0 500 1200]);
grid on
xlim([0 1900]);
xlim([800 1500]);

title('A500');
ylabel('Modulation frequency (Hz)');
% indx = find(uMF>4,1);
% h = pa_horline(0.3*(indx-0.5),'k-');set(h,'LineWidth',2);
% indx = find(uMF>13,1);
% h = pa_horline(0.3*(indx-0.5),'k-');set(h,'LineWidth',2);
% indx = find(uMF>30,1);
% h = pa_horline(0.3*(indx-0.5),'k-');set(h,'LineWidth',2);
% indx = find(uMF>70,1);
% h = pa_horline(0.3*(indx-0.5),'k-');set(h,'LineWidth',2);

% keyboard
% pa_horline(log2([10 30 70])*0.3,'r-');

%% AM1000
spike = spikeAMA1000;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
col			= jet(nMF);
A1000 = [];
	figure(1)
for ii		= 1:nMF
	
	sel = modFreq==uMF(ii);
	spk = spike(sel);
	[MSDF,sdf] = pa_spk_sdf(spk);
		MSDF = 0.1*MSDF/(2*std(MSDF));

	t = 1:length(MSDF);
	A			= 1+sin(2*pi*uMF(ii)*t/1000);
	A = A./max(A);
	A = A*0.1;
	A(1:800) = 0;
	A(1500:end) = 0;
	
	subplot(122)
	% 	plot(t,A+0.2*ii,'k-','Color',[.7 .7 .7]);
	hold on
	plot(t,MSDF+0.3*ii,'k-','Color',col(ii,:),'LineWidth',2)
	MSDF = [MSDF NaN(1,n-length(MSDF))];
	A1000 = [A1000;MSDF];
	
end
box off
xlabel('Time (ms)');
set(gca,'YTick',0.3*(1:nMF),'YTickLabel',round(uMF));
set(gca,'XTick',[300 1300 2000],'XTickLabel',[300 1300 2000]-300);
grid on
xlim([0 2400]);
xlim([1300 2000]);

title('A1000');

% function