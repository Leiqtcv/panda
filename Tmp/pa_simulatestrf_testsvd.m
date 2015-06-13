function pa_simulatestrf_testsvd

close all hidden
clear all hidden
clc

sdptf		= 1;
sdmtf		= 10;


[MTF,PTF,STRF]	= getstrf(sdmtf,sdptf,1);



function [MTF,PTF,STRF] = getstrf(sdmtf,sdptf,dsp)
%% PTF
vel		= 3;
dens	= 1;
mod		= 100; % Percentage (0-100%)
Fs		= 100;
mod		= mod/100; % Gain (0-1)
nTime	= 5;
time	= ((1:nTime)-1)/Fs; % Time (sec)

nFreq   = 11;
FreqNr  = 0:1:nFreq-1;
Oct     = FreqNr/20;                   % octaves above the ground frequency
oct		= repmat(Oct',1,nTime); % Octave

%% Generating the ripple
% Create amplitude modulations completely dynamic without static
A		= NaN(nTime,nFreq);
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

if dsp
	
	subplot(232);
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
	
	subplot(231);
	imagesc(MTF')
	axis square;
	
end
%% STRF
C		= MTF.*exp(1i*PTF);
STRF	= compstrf(C);
if dsp
	subplot(233);
	imagesc(STRF)
	axis square;
end
col = pa_statcolor(64,[],[],[],'def',8,'disp',false);
colormap(col);

%% svd
[u,S,v] = svd(MTF);

% keyboard
lambda = diag(S,0);

figure(2)
subplot(131)
imagesc(u);
axis square;

subplot(132)
imagesc(S);
axis square;

subplot(133)
imagesc(v);
axis square;

figure(3)
subplot(221)
plot(lambda,'ko-','MarkerFaceColor','w');
axis square;

subplot(223)
evector = v(:,1);
x = mean(MTF);
y = -evector*lambda(1);
x = x./max(x);
y = y./max(y);
plot(x,'k-');
hold on
plot(y,'r-','LineWidth',2);

subplot(224)
evector = u(:,1);
x = mean(MTF,2);
y = -evector*lambda(1);
x = x./max(x);
y = y./max(y);
plot(x,'k-');
hold on
plot(y,'r-','LineWidth',2);

%% Reconstruct MTF

S2		= zeros(size(S));
S2(1)	= S(1);
rMTF	= u*S2*v';
if dsp
	figure(1)
	subplot(234);
	imagesc(rMTF')
	axis square;
end

%% STRF
C		= rMTF.*exp(1i*PTF);
rSTRF	= compstrf(C);
if dsp
	figure(1)
	subplot(236);
	imagesc(rSTRF)
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
