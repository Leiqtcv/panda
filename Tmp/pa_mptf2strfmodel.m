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

sdptf		= 10;
sdmtf		= 10;


[MTF1,PTF1,STRF1] = getstrf(sdmtf,sdptf,1);

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
colorbar;

subplot(222)
plot(SDPTF,Rstrf(1,:),'.-');
xlabel('SD noise in PTF');
axis square


%
% subplot(223)
% plot(Rmtf,Rstrf,'.')
% axis([0 1 0 1]);
% lsline
function [MTF,PTF,STRF] = getstrf(sdmtf,sdptf,dsp)
%% PTF
vel = 3;

dens = 1;

mod = 100; % Percentage (0-100%)



Fs = 30;
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
MTF = MTF-min(MTF(:));

MTF = 10*MTF;
MTF = MTF+sdM*randn(size(MTF));
% MTF = MTF-min(MTF(:));
if dsp
	
	subplot(131);
	imagesc(MTF')
	axis square;
	title([max(MTF(:)) min(MTF(:)) mean(MTF(:))]);
end
%% STRF
C		= MTF.*exp(1i*PTF);
STRF	= compstrf(C);
if dsp
	subplot(133);
	imagesc(STRF)
	axis square;
	colorbar;
end
title([max(STRF(:)) min(STRF(:))])

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
