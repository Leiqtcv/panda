
function tmp
close all
clear all
clc

cd('C:\DATA\Double\MW-RM-2010-07-29');
fname1			= 'MW-RM-2010-07-29-0001';
fname2			= 'MW-RM-2010-07-29-0002';

[Sac,Stim]=loadmat([fname1;fname2]);
% load(fname)
% whos
indx = setdiff(1:800,Sac(:,1))


sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);

sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);

%% Single Sounds
sel				= Stim2(:,11)==100;
Stimsingle		= Stim1(sel,:);
Sacsingle		= Sac(sel,:);

%% Double Sounds
sel				= Stim2(:,11)==100;
Stim1double		= Stim1(~sel,:);
Stim2double		= Stim2(~sel,:);
Sacdouble		= Sac(~sel,:);

sel8 = Stim1double(:,11)==108 | Stim2double(:,11)==108;
sel20 = Stim1double(:,11)==120 | Stim2double(:,11)==120;
sel30 = Stim1double(:,11)==130 | Stim2double(:,11)==130;
sel31 = Stim1double(:,11)==131 | Stim2double(:,11)==131;

%%

figure(99)
subplot(231)
[x1,y1,a1,Seig1] = plotellipse(Sacsingle,Stimsingle,120);
[x2,y2,a2,Seig2] = plotellipse(Sacsingle,Stimsingle,130);
plot([x1 x2],[y1 y2],'r-','LineWidth',1);
plotellipsedouble(Sacdouble,sel20&sel30);
plotmodel(Sacsingle,Stimsingle,120,130)

subplot(232)
[x1,y1,a1,Seig1] = plotellipse(Sacsingle,Stimsingle,120);
[x2,y2,a2,Seig2] = plotellipse(Sacsingle,Stimsingle,131);
plot([x1 x2],[y1 y2],'r-','LineWidth',1);
plotellipsedouble(Sacdouble,sel20&sel31);
plotmodel(Sacsingle,Stimsingle,120,131)

subplot(234)
[x1,y1,a1,Seig1] = plotellipse(Sacsingle,Stimsingle,108);
[x2,y2,a2,Seig2] = plotellipse(Sacsingle,Stimsingle,130);
plot([x1 x2],[y1 y2],'r-','LineWidth',1);
plotellipsedouble(Sacdouble,sel8&sel30);
plotmodel(Sacsingle,Stimsingle,108,130)

subplot(235)
[x1,y1,a1,Seig1] = plotellipse(Sacsingle,Stimsingle,108);
[x2,y2,a2,Seig2] = plotellipse(Sacsingle,Stimsingle,131);
plot([x1 x2],[y1 y2],'r-','LineWidth',1);
plotellipsedouble(Sacdouble,sel8&sel31);
plotmodel(Sacsingle,Stimsingle,108,131)

subplot(236)
[x1,y1,a1,Seig1] = plotellipse(Sacsingle,Stimsingle,108);
[x2,y2,a2,Seig2] = plotellipse(Sacsingle,Stimsingle,120);
plot([x1 x2],[y1 y2],'r-','LineWidth',1);
plotellipsedouble(Sacdouble,sel20&sel8);
plotmodel(Sacsingle,Stimsingle,120,108)

subplot(233)
[x1,y1,a1,Seig1] = plotellipse(Sacsingle,Stimsingle,130);
[x2,y2,a2,Seig2] = plotellipse(Sacsingle,Stimsingle,131);
plot([x1 x2],[y1 y2],'r-','LineWidth',1);
plotellipsedouble(Sacdouble,sel30&sel31);
plotmodel(Sacsingle,Stimsingle,130,131)


for ii = 1:6
	subplot(2,3,ii)
	axis square
	axis([-90 90 -90 90]);
	verline(0);
	horline(0);
	xlabel('Azimuth (deg)');
	ylabel('Elevation (deg)');
	
end

marc
print('-depsc2','-painters',mfilename);
function plotgrid
plot([0 -90 0 90 0],[-90 0 90 0 -90],'k-','Color',[.7 .7 .7])

function [x,y,a,Seig] = plotellipse(Sac,Stim,speaker)
sel = Stim(:,11)==speaker;
A	= Sac(sel,8);
E	= Sac(sel,9);
[x,y,a,Seig] = getellips(A,E);

plot(A,E,'r.','Color',[1 .7 .7])
hold on
h	= ellipse(x,y,2*Seig(1),2*Seig(2),a,'r');

function plotellipsedouble(Sac,sel)
A	= Sac(sel,8);
E	= Sac(sel,9);
[x,y,a,Seig] = getellips(A,E);

plot(A,E,'k.','Color',[.7 .7 1])
hold on
h	= ellipse(x,y,2*Seig(1),2*Seig(2),a,'b');

function plotmodel(Sac,Stim,speaker1,speaker2)
% okay
sel = Stim(:,11)==speaker1;
A1	= Sac(sel,8);
E1	= Sac(sel,9);

sel = Stim(:,11)==speaker2;
A2	= Sac(sel,8);
E2	= Sac(sel,9);

[A1,A2] = meshgrid(A1,A2);
[E1,E2] = meshgrid(E1,E2);

A = (A1+A2)/2;
E = (E1+E2)/2;
A = A(:);
E = E(:);
[x,y,a,Seig] = getellips(A,E);

% plot(A,E,'k.','Color',[.7 .7 .7])
% hold on
h	= ellipse(x,y,2*Seig(1),2*Seig(2),a,'k');


