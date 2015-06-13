function pa_doublepolar3
%% Initialization
close all
clear all
clc

figure
plot_db;

print('-depsc','-painter',mfilename);
function plot_db

%% Normal
figure(1)
sdaz		= 10;
sdel		= 20;
taz			= -90:10:90;
tel			= -90:10:90;
[taz,tel]	= meshgrid(taz,tel);
taz			= taz(:);
tel			= tel(:);
sel = (abs(taz)+abs(tel))<=90;
taz = taz(sel);
tel= tel(sel);

raz		= taz + sdaz * randn(size(taz))+6;
rel		= tel + sdel * randn(size(tel))+2;
sel		= (abs(raz)+abs(rel))<=90;
taz		= taz(sel);
tel		= tel(sel);
raz		= raz(sel);
rel		= rel(sel);

tht               = (real(asind(sind(taz)./cosd(tel)))); % Removed "round" Jan 2009
thr               = (real(asind(sind(raz)./cosd(rel)))); % Removed "round" Jan 2009
sel = abs(tht)<90;
tht = tht(sel);
thr = thr(sel);
tel = tel(sel);
rel = rel(sel);
taz = taz(sel);
raz = raz(sel);

subplot(232)

pa_loc(taz,raz);

subplot(133)
x = -90:10:90;
N = hist(raz-taz,x);
stairs(x,N,'k-','LineWidth',2);
hold on

% pa_loc(tel,rel);
xlim([-90 90]);

subplot(231)
plot(raz,rel,'k.');
axis square;
axis([-90 90 -90 90]);


% [tht,phit] = pa_azel2fart(taz,tel);
% [thr,phir] = pa_azel2fart(raz,rel);



subplot(235)
pa_loc(tht,thr);
axis auto

subplot(133)
N = hist(thr-tht,x);
stairs(x,N,'k-','Color',[.7 .7 .7],'LineWidth',2);
% pa_loc(tel,rel);
% axis auto
xlim([-90 90]);
axis square
box off
subplot(234)
plot(thr,rel,'k.');
axis square;
axis([-90 90 -90 90]);

for ii = [1 2 4 5]
	subplot(2,3,ii)
	set(gca,'XTick',-60:30:60,'YTick',-60:30:60);
	box off
	pa_text(0.1,0.9,char(96+ii));
end
return


%% Mold
figure(2)
sdaz		= 10;
sdel		= 15;
taz			= -90:15:90;
tel			= -90:15:90;
[taz,tel]	= meshgrid(taz,tel);
taz			= taz(:);
tel			= tel(:);
sel = (abs(taz)+abs(tel))<=90;
taz = taz(sel);
tel= tel(sel);

raz		= taz + sdaz * randn(size(taz))+6;
rel		= 40 + sdel * randn(size(tel))+2;
sel		= (abs(raz)+abs(rel))<=90;
taz		= taz(sel);
tel		= tel(sel);
raz		= raz(sel);
rel		= rel(sel);

tht               = (real(asind(sind(taz)./cosd(tel)))); % Removed "round" Jan 2009
thr               = (real(asind(sind(raz)./cosd(rel)))); % Removed "round" Jan 2009
sel = abs(tht)<90 ;
tht = tht(sel);
thr = thr(sel);
tel = tel(sel);
rel = rel(sel);
taz = taz(sel);
raz = raz(sel);

subplot(231)
pa_loc(taz,raz);

subplot(232)
pa_loc(tel,rel);

subplot(233)
plot(raz,rel,'k.');
axis square;
axis([-90 90 -90 90]);


% [tht,phit] = pa_azel2fart(taz,tel);
% [thr,phir] = pa_azel2fart(raz,rel);



subplot(234)
pa_loc(tht,thr);
axis auto

subplot(235)
pa_loc(tel,rel);
axis auto

subplot(236)
plot(thr,rel,'k.');
axis square;
axis([-90 90 -90 90]);

for ii = 1:6
	subplot(2,3,ii)
	set(gca,'XTick',-60:30:60,'YTick',-60:30:60);
	box off
	pa_text(0.1,0.9,char(96+ii));
end
