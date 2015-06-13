function pa_spk_am_ac_analysis

clc;
close all hidden;
clear all


% pa_spk_rasterplot(spikeAMp);
figure(1)
[P,A500,A1000] = sdfplot;
% keyboard

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
betastatic = beta;
gammastatic = gamma;

beta = beta-betastatic;
gamma = gamma-gammastatic;

figure(3)
plot(F,(smooth(beta,10)+smooth(gamma,10))/2,'r-','LineWidth',2,'Color',[.7 .7 .7]);
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
whos beta gamma betastatic gammastatic
indx = 1:length(betastatic);
beta = beta(indx)-betastatic;
gamma = gamma(indx)-gammastatic;
F = F(indx);
figure(3)
plot(F,(smooth(beta,10)+smooth(gamma,10))/2,'r-','LineWidth',2,'Color','r');
hold on
xlim([2 100]);
set(gca,'XTick',10:10:100,'XTickLabel',10:10:100);
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
axis square;
ylim([-7 7]);



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
beta = beta-betastatic;
gamma = gamma-gammastatic;

figure(3)
plot(F,(smooth(beta,10)+smooth(gamma,10))/2,'r-','LineWidth',2,'Color','k');
hold on
xlim([2 100]);
set(gca,'XTick',10.^(0:2),'XTickLabel',10.^(0:2));
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
axis square;

pa_verline(50);
legend({'Spontaneous','Modulated','Unmodulated'},'Location','SE');

function specplot
cd('E:\DATA\Cortex\gain selected cells')
load('thor08411.mat');


%% PASSIVE
spike = spikeAMp;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
P = [];
for ii		= 1:nMF
	
	sel = modFreq==uMF(ii);
	spk = spike(sel);
	MSDF = pa_spk_sdf(spk);
	
	
	[y,f,t,p] = spectrogram(MSDF,256,250,512,1000,'yaxis');
	p = 10*log10(abs(p));
	p = detrend(p','constant')';
	%       surf(t,f,p,'EdgeColor','none');
	%       axis xy; axis tight; colormap(jet); view(0,90);
	%       xlabel('Time');
	%       ylabel('Frequency (Hz)');
	%
	% axis square;
	% ylim([0 100]);
	% xlabel('Time (s)');
	% drawnow
	
	sel = f<80;
	p = p(sel,:);
	P = [P;p];
	
	
end
subplot(131)
surf(P,'EdgeColor','none');
axis xy; axis tight; colormap(jet); view(0,90);
xlabel('Time');
ylabel('Frequency (Hz)');
caxis([-10 20]);

%% PASSIVE
spike = AM500;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
P = [];
for ii		= 1:nMF
	
	sel = modFreq==uMF(ii);
	spk = spike(sel);
	MSDF = pa_spk_sdf(spk);
	
	
	[y,f,t,p] = spectrogram(MSDF,256,250,512,1000,'yaxis');
	p = 10*log10(abs(p));
	p = detrend(p','constant')';
	%       surf(t,f,p,'EdgeColor','none');
	%       axis xy; axis tight; colormap(jet); view(0,90);
	%       xlabel('Time');
	%       ylabel('Frequency (Hz)');
	%
	% axis square;
	% ylim([0 100]);
	% xlabel('Time (s)');
	% drawnow
	
	sel = f<80;
	p = p(sel,:);
	P = [P;p];
end
subplot(132)
surf(P,'EdgeColor','none');
axis xy; axis tight; colormap(jet); view(0,90);
xlabel('Time');
ylabel('Frequency (Hz)');
caxis([-10 20]);

%% PASSIVE
spike = AM1000;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
P = [];
for ii		= 1:nMF
	
	sel = modFreq==uMF(ii);
	spk = spike(sel);
	MSDF = pa_spk_sdf(spk);
	
	
	[y,f,t,p] = spectrogram(MSDF,256,250,512,1000,'yaxis');
	p = 10*log10(abs(p));
	p = detrend(p','constant')';
	%       surf(t,f,p,'EdgeColor','none');
	%       axis xy; axis tight; colormap(jet); view(0,90);
	%       xlabel('Time');
	%       ylabel('Frequency (Hz)');
	%
	% axis square;
	% ylim([0 100]);
	% xlabel('Time (s)');
	% drawnow
	
	sel = f<80;
	p = p(sel,:);
	P = [P;p];
end
subplot(133)
surf(P,'EdgeColor','none');
axis xy; axis tight; colormap(jet); view(0,90);
xlabel('Time');
ylabel('Frequency (Hz)');
caxis([-10 20]);

function [P,A500,A1000] = sdfplot
n = 3000;
cd('E:\DATA\Cortex\gain selected cells')
dir
load('thor08411.mat');
%% PASSIVE
spike = spikeAMp;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
col			= jet(nMF);
P = [];
for ii		= 1:nMF
	
	sel = modFreq==uMF(ii);
	spk = spike(sel);
	[MSDF,sdf] = pa_spk_sdf(spk);
	t = 1:length(MSDF);
	A			= 1+sin(2*pi*uMF(ii)*t/1000);
	A = A./max(A);
	A = A*0.1;
	A(1:800) = 0;
	A(1500:end) = 0;
	
	
	subplot(121)
	% 	plot(t,A+0.2*ii,'k-','Color',[.7 .7 .7]);
	hold on
	% 	plot(t,MSDF+0.3*ii,'k-','Color',col(ii,:),'LineWidth',2)
	plot(t,MSDF+0.3*ii,'k-','Color',[.7 .7 .7],'LineWidth',2)
	
	subplot(122)
	% 	plot(t,A+0.2*ii,'k-','Color',[.7 .7 .7]);
	hold on
	% 	plot(t,MSDF+0.3*ii,'k-','Color',col(ii,:),'LineWidth',2)
	plot(t+500,MSDF+0.3*ii,'k-','Color',[.7 .7 .7],'LineWidth',2)
	MSDF = [MSDF NaN(1,n-length(MSDF))];
	P = [P;MSDF];
end
box off
xlabel('Time (ms)');
set(gca,'YTick',0.3*(1:nMF),'YTickLabel',round(uMF));
set(gca,'XTick',[300 800 1500],'XTickLabel',[0 500 1200]);
grid on
xlim([0 1900]);
title('P');
% keyboard
%% AM500
spike = AM500;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
col			= jet(nMF);
A500 = [];
for ii		= 1:nMF
	
	sel = modFreq==uMF(ii);
	spk = spike(sel);
	[MSDF,sdf] = pa_spk_sdf(spk);
	t = 1:length(MSDF);
	A			= 1+sin(2*pi*uMF(ii)*t/1000);
	A = A./max(A);
	A = A*0.1;
	A(1:800) = 0;
	A(1500:end) = 0;
	
	subplot(121)
	% 	plot(t,A+0.2*ii,'k-','Color',[.7 .7 .7]);
	hold on
	plot(t,MSDF+0.3*ii,'k-','Color',col(ii,:),'LineWidth',2)
	MSDF = [MSDF NaN(1,n-length(MSDF))];
	whos MSDF
	A500 = [A500;MSDF];
end
box off
xlabel('Time (ms)');
set(gca,'YTick',0.3*(1:nMF),'YTickLabel',round(uMF));
set(gca,'XTick',[300 800 1500],'XTickLabel',[0 500 1200]);
grid on
xlim([0 1900]);
title('A500');
ylabel('Modulation frequency (Hz)');

%% AM1000
spike = AM1000;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
col			= jet(nMF);
A1000 = [];
for ii		= 1:nMF
	
	sel = modFreq==uMF(ii);
	spk = spike(sel);
	[MSDF,sdf] = pa_spk_sdf(spk);
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
title('A1000');

% function