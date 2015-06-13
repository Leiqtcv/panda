function tmp
% PA_GENRIPPLE(VEL,DENS,MOD,DURDYN,DURSTAT)
%
% Generate a ripple stimulus with velocity (amplitude-modulation) VEL (Hz),
% density (frequency-modulation) DENS (cyc/oct), and a modulation depth MOD
% (0-1). Duration of the ripple stimulus is DURSTAT+DURRIP (ms), with the first
% DURSTAT ms no modulation occurring.
%
% These stimuli are parametrized naturalistic, speech-like sounds, whose
% envelope changes in time and frequency. Useful to determine
% spectro-temporal receptive fields.  Many scientists use speech as
% stimuli (in neuroimaging and psychofysical experiments), but as they are
% not parametrized, they are basically just using random stimulation (with
% random sentences).
%
% See also PA_GENGWN, PA_WRITEWAV

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

close all
clc

sdptf		= 0;
sdmtf		= 0;


[MTF,PTF,STRF] = getstrf(sdmtf,sdptf,1);
SNR = getsnr(STRF);
title(SNR)

sd = 0:0.01:2;
sd = repmat(sd,20,1);
sd = sd(:);
for ii = 1:length(sd)
	rnd = sd(ii)*randn(size(STRF));
	strf1 = STRF+rnd;

	rnd = sd(ii)*randn(size(STRF));
	strf2 = STRF+rnd;
	
	SNR(ii) = getsnr(strf1);
	r = corrcoef(strf1(:),strf2(:));
C(ii) = r(2);
end
figure

subplot(221)
x		= SNR;
y		= C;
sel = x>2.8;
x = x(sel);
y = y(sel);

plot(x,y,'k.');
hold on
axis square;
xlim([min(x) max(x)]);
ylim([min(y) max(y)]);
plot([min(x) max(x)],[min(y) max(y)],'k-','LineWidth',3);
xlabel('SNR');
ylabel('R');

sigma	= 0.5*std(x);
xi		= linspace(min(x),max(x),50);
mu		= pa_weightedmean(x,y,sigma,xi,'wfun','boxcar');
plot(xi,mu,'r-','LineWidth',3);

subplot(223)
x		= log(SNR);
y		= C;
sel = x>1.5;
x = x(sel);
y = y(sel);

plot(x,y,'k.');
hold on
axis square;
xlim([min(x) max(x)]);
ylim([min(y) max(y)]);
plot([min(x) max(x)],[min(y) max(y)],'k-','LineWidth',3);
xlabel('log(SNR)');
ylabel('R');

sigma	= 0.5*std(x);
xi		= linspace(min(x),max(x),50);
mu		= pa_weightedmean(x,y,sigma,xi,'wfun','boxcar');
plot(xi,mu,'r-','LineWidth',3);

subplot(222)
x		= SNR;
y		= C.^2;
sel = x>2.8;
x = x(sel);
y = y(sel);

plot(x,y,'k.');
hold on
axis square;
xlim([min(x) max(x)]);
ylim([min(y) max(y)]);
plot([min(x) max(x)],[min(y) max(y)],'k-','LineWidth',3);
xlabel('SNR');
ylabel('R^2');

sigma	= 0.5*std(x);
xi		= linspace(min(x),max(x),50);
mu		= pa_weightedmean(x,y,sigma,xi,'wfun','boxcar');
plot(xi,mu,'r-','LineWidth',3);

subplot(224)
x		= log(SNR);
y		= C.^2;
sel = x>1.5;
x = x(sel);
y = y(sel);

plot(x,y,'k.');
hold on
axis square;
xlim([min(x) max(x)]);
ylim([min(y) max(y)]);
plot([min(x) max(x)],[min(y) max(y)],'k-','LineWidth',3);
xlabel('log(SNR)');
ylabel('R^2');

sigma	= 0.5*std(x);
xi		= linspace(min(x),max(x),50);
mu		= pa_weightedmean(x,y,sigma,xi,'wfun','boxcar');
plot(xi,mu,'r-','LineWidth',3);


figure

% subplot(221)
x		= SNR;
y		= C;
sel = x>2.8;
x = x(sel);
y = y(sel);

plot(x,y,'k.');
hold on
axis square;
xlim([min(x) max(x)]);
ylim([min(y) max(y)]);
plot([min(x) max(x)],[min(y) max(y)],'k-','LineWidth',3);
xlabel('SNR');
ylabel('R');

sigma	= 0.5*std(x);
xi		= linspace(min(x),max(x),50);
mu		= pa_weightedmean(x,y,sigma,xi,'wfun','boxcar');
plot(xi,mu,'r-','LineWidth',3);
return
n = 1000;

figure;
SDPTF	= 0:10;
SDMTF	= 0:20;
R		= NaN(length(SDMTF),length(SDPTF),3);

for jj = 1:length(SDMTF)
	for kk = 1:length(SDPTF)
		
		for ii = 1:n
			[jj kk ii]
			sdmtf = SDMTF(jj);
			sdptf = SDPTF(kk);
			[MTF,PTF,STRF] = getstrf(sdmtf,sdptf,0);
			
			r = corrcoef(MTF(:),MTF1(:));
			Rmtf(ii) = r(2);
			
			r = corrcoef(STRF(:),STRF1(:));
			Rstrf(ii) = r(2);
			
			r = corrcoef(PTF(:),PTF1(:));
			Rptf(ii) = r(2);
			
		end
		R(jj,kk,1) = median(Rmtf);
		R(jj,kk,2) = median(Rptf);
		R(jj,kk,3) = median(Rstrf);
	end
end

figure
subplot(131)
hist(Rmtf,0:0.05:1)
axis square;
title(median(Rmtf));
xlabel('R MTF');
ylabel('N');

subplot(132)
hist(Rmtf,0:0.05:1)
axis square;
title(median(Rmtf));
xlabel('R PTF');

subplot(133)
hist(Rstrf,0:0.05:1)
axis square;
title(median(Rstrf));
xlabel('R STRF');


figure
subplot(221)
Rstrf = squeeze(R(:,:,3));
imagesc(SDMTF,SDPTF,Rstrf');
ylabel('SD noise in PTF');
xlabel('SD noise in MTF');
axis square;

subplot(223)
plot(SDMTF,Rstrf(:,1),'.-');
xlabel('SD noise in MTF');
axis square

subplot(222)
plot(SDPTF,Rstrf(1,:),'.-');
xlabel('SD noise in PTF');
axis square

keyboard
% 
% subplot(223)
% plot(Rmtf,Rstrf,'.')
% axis([0 1 0 1]);
% lsline

function SNR = getsnr(STRF)
S = max(STRF(:));
N = STRF(:,5:10);
N = std(N(:));
SNR = S./N;
function [MTF,PTF,STRF] = getstrf(sdmtf,sdptf,dsp)
%% PTF
vel = 3;

dens = 1;

mod = 100; % Percentage (0-100%)



Fs = 100;
tic
mod			= mod/100; % Gain (0-1)
nTime = 5;
time		= ((1:nTime)-1)/Fs; % Time (sec)

nFreq   = 11;
FreqNr  = 0:1:nFreq-1;
Oct     = FreqNr/20;                   % octaves above the ground frequency
oct		= repmat(Oct',1,nTime); % Octave

%% Generating the ripple
% Create amplitude modulations completely dynamic without static
A = NaN(nTime,nFreq);
for ii = 1:nTime
	for jj = 1:nFreq
		A(ii,jj)      = 1 + mod*sin(2*pi*vel*time(ii) + 2*pi*dens*oct(jj)+0.5*pi);
	end
end

sd		= sdptf;
sdP		= sd/(2*pi);
sd		= sdmtf;
sdM		= sd/10;

PTF		= A;
PTF		= PTF-min(PTF(:));
PTF		= PTF./max(PTF(:));
PTF		= 2*pi*(PTF-0.5);
PTF		= PTF+sdP*randn(size(PTF));
% PTF = rem(PTF,1.01*pi);

if dsp

subplot(132);
imagesc(PTF')
axis square;
end
%% MTF
x = linspace(1,5,5);
y = normpdf(x,3,2);
y = y./max(y);
MTF = repmat(y,11,1)';

x = linspace(1,11,11);
y = normpdf(x,3,10);
y = y./max(y);
MTF2 = repmat(y',1,5)';
MTF = MTF.*MTF2;

MTF = 10*MTF;
MTF = MTF+sdM*randn(size(MTF));
% MTF = MTF-min(MTF(:));
if dsp

subplot(131);
imagesc(MTF')
axis square;

end
%% STRF
C		= MTF.*exp(1i*PTF);
STRF	= compstrf(C);
if dsp
	subplot(133);
imagesc(STRF)
axis square;	
end
function strf = compstrf(cplxq12,nw,no)
%  STRF = COMPSTRF(CPLXQ12,NW,NO)
%
% Obtain spectrotemporal receptive field STRF from the complex transfer
% function for quadrants 1 and 2 CPLXQ12, for w>0, entire omega range.

% Huib Versnel, version 26-7-'00
if nargin < 3
	no=1;
end;
if nargin < 2
	nw=1;
end;
s				= size(cplxq12,2);
stat			= zeros(1,s);
cplxq34			= conj(fliplr(flipud(cplxq12)));
cplxtotal		= [cplxq34;stat;cplxq12];
cplxtot1		= conj(fliplr(flipud(fftshift(cplxtotal(2:end,2:end)))));
cplxstrf		= ifft2(cplxtot1*(nw*no));	%inverse Fourier transform
strf			= real(fliplr(cplxstrf).');
