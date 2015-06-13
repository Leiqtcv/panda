function tmp

clear all
close all
clc

xt = -45:15:45;
[xt,yt] = meshgrid(xt,xt);
xt = xt(:);
yt = yt(:);
xt = 30*randn(100,1);
yt = 30*randn(100,1);

xr = xt+3*randn(size(xt));
yr = 80./(1+exp(-0.12*yt))-45;
N = normpdf(xt,0,50);
N = N./max(N);
yr = yr.*N;
yr = yr+5*randn(size(yt));
% plot(xt,yt);
% return
% yr = yt+5*randn(size(yt));

figure
subplot(221)
plot(xt,yt,'k.');
axis square;
axis([-70 70 -70 70]);

subplot(222)
plot(xr,yr,'k.');
hold on
axis square;
axis([-70 70 -70 70]);

n = length(xt);
ym = NaN(size(xt));
xm = ym;
for ii = 1:n
	X = sqrt( (xt-xt(ii)).^2+(yt-yt(ii)).^2 );
	Y = yr;
	ym(ii) = getmean(X,Y,0,10);
	
	figure(2)
	clf
	subplot(221)
	plot(xt,yt,'k.');
	hold on
	plot(xt(ii),yt(ii),'ro','LineWidth',2);
	
	axis square;
	axis([-70 70 -70 70]);
	title(ii)
	
	subplot(222)
	plot(xr,yr,'k.');
	hold on
	plot(xr(ii),yr(ii),'ro','LineWidth',2);
	axis square;
	axis([-70 70 -70 70]);
	title(ym(ii));
	
	subplot(224)
	plot(yt,yr,'k.');
	hold on
	plot(yt(ii),yr(ii),'ro','LineWidth',2);
	axis square;
	axis([-70 70 -70 70]);
	pa_unityline;
		
	subplot(223)
	hist(X,0:5:200)
	
	drawnow
	
	
	% 	Y = xr;
	% 	xm(ii) = pa_weightedmean(X,Y,0,5);
end

figure
plot3(xt,yt,ym,'.');
grid on

%%
% Construct the interpolant
x = xt;
y = yt;
z = ym;
F = TriScatteredInterp(x,y,z);

% Evaluate the interpolant at the locations (qx, qy), qz
%    is the corresponding value at these locations.
ti = -45:1:45;
[qx,qy] = meshgrid(ti,ti);
qz = F(qx,qy);
contourf(qx,qy,qz,100); 
hold on; 
% plot3(x,y,z,'ko');
shading flat
axis square;
axis([min(x) max(x) min(y) max(y)]);
caxis([min(y) max(y)]);
colorbar
% keyboard

function [mu,xi] = getmean(X,Y,XI,sigma)
% initialization of matrices
mu      = NaN(length(XI),1); % regression coefficients
xi		= NaN(size(XI)); % wfuned average x-parameter
for ii   = 1:length(XI)
    w1		= normpdf(X,XI(ii),sigma); % Gaussian wfuning for one column
    sw		= nansum(w1); % normalization factor
    xi(ii)	= nansum(w1.*X)./sw;
    xi(ii) = XI(ii);
    y		= w1.*Y./sw;
    sel		= X>=XI(ii)-sigma  & X<=xi(ii)+sigma;
        mu(ii) = nansum(y);
end