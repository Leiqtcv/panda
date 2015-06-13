
clc
close all hidden;
clear all hidden;

mm2deg = 90/45.65; % deg/mm
mu = [23.991 23.638 20.11 8.116;24.59 24.365 23.179 17.887; 21.263 19.807 8.228 5.36; 24.976 24.746 21.145 7.107]*mm2deg;
sd = [2.618 2.448 8.287 19.859;  2.199 3.129 3.888 15.815; 3.934 5.236 11.912 5.948; 2.649 2.261 9.17 16.729]*mm2deg;

col = jet(4);
for ii = 1:4
	h(ii) = loglog(mu(ii,:),sd(ii,:),'ko-','MarkerFaceColor',col(ii,:),'Color',col(ii,:));
	hold on
	loglog(mu(ii,:),sd(ii,:),'ko','MarkerFaceColor',col(ii,:));
end
% plot([0 55],[55 0],'k-')
axis square;
xlim([7 60]);
ylim([2.5 200]);
pa_verline(45);
pa_verline(10);
box off
set(gca,'XTick',10:10:50,'XTickLabel',10:10:50)
set(gca,'YTick',0:10:50,'YTickLabel',0:10:50)
xlabel('Median (deg)');
ylabel('IQR (deg)');
legend(h,{'Asyn S0M0';'Syn S0M0';'Asyn S0M80';'Asyn S0M0'},'Location','SW');

mulog = mu(:);
sel = mulog>25;
mulog = log10(mu);
sdlog = log10(sd(:));
b = regstats(sdlog(sel),mulog(sel));
x = log10(5:60);
y = b.beta(2)*x+b.beta(1);
x = 10.^x;
y = 10.^y;
loglog(x,y,'k-');

mulog = mu(:);
sel = mulog<25;
mulog = log10(mu);
sdlog = log10(sd(:));
b = regstats(sdlog(sel),mulog(sel));
x = log10(5:60);
y = b.beta(2)*x+b.beta(1);
x = 10.^x;
y = 10.^y;
loglog(x,y,'k-');

pa_verline(27.2);
return
%% VECTORS
figure;
theta	= -180:10:180;

% u		= 20;
% rot		= u*sind(theta);
u		= -0.9;
rot		= u*theta; % linear underestimation
k		= 5;
trans	= -(k*cosd(90-abs(theta)));
v		= -45;
thetaworld	= v*sind(theta); % linear underestimation
% v		= 0.05;
% thetaworld	= v*theta; % linear underestimation


% k = 0.05;
% trans = -abs(k*theta);
% trans = zeros(size(theta));
subplot(121)
plot(theta,rot,'k-','LineWidth',2);
axis([-150 150 -90 90]);
pa_horline;
axis square;

subplot(122)
plot(theta,trans,'k-','LineWidth',2);
axis([-150 150 -10 10]);
pa_horline;
axis square;

%% Head-fixed task, head-fixed speaker
T			= abs(trans); % remove direction
% 1
o			= T.*sind(theta);
a			= T.*cosd(theta);
% 2
thetaprime	= theta+rot;
odprime		= a.*tand(thetaprime);
oprime		= o-odprime;
oprime		= -oprime; % introduce direction
figure(666);
subplot(121)
plot(theta,oprime,'b-','LineWidth',1,'Color',[.7 .7 1]);
hold on
plot(theta,oprime,'bo','LineWidth',2,'MarkerFaceColor','w');
axis([-180 180 -10 10]);
axis square;
title('Head-fixed speakers, head-fixed task');


%% World-fixed task, head-fixed speaker
T			= abs(trans); % remove direction
% 1
oworld		= a./tand(90-thetaworld);
oworld		= o-oworld;
oworld = -oworld;
figure(666);
subplot(121)
plot(theta,oworld,'r-','LineWidth',1,'Color',[1 .7 .7]);
hold on
plot(theta,oworld,'ro','LineWidth',2,'MarkerFaceColor','w');
axis([-180 180 -10 10]);
axis square;
title('Head-fixed speakers, head-fixed task');



%% Head-fixed task, world-fixed speaker
T			= abs(trans); % remove direction
oprime		= T.*tand(thetaprime);
oprime = -oprime;
figure(666);
subplot(122)
plot(theta,oprime,'b-','LineWidth',1,'Color',[.7 .7 1]);
hold on
plot(theta,oprime,'bo','LineWidth',2,'MarkerFaceColor','w');
axis([-180 180 -10 10]);
axis square;
title('Head-fixed speakers, head-fixed task');

%% World-fixed task, head-fixed speaker
T			= abs(trans); % remove direction
% 1
oworld		= T.*tand(thetaworld);
oworld = -oworld;
figure(666);
subplot(122)
plot(theta,oworld,'r-','LineWidth',1,'Color',[1 .7 .7]);
hold on
plot(theta,oworld,'ro','LineWidth',2,'MarkerFaceColor','w');
axis([-180 180 -10 10]);
axis square;
title('Head-fixed speakers, head-fixed task');

% %%
% k		= 5;
% u		= -20;
% rot		= u*sind(theta);
% trans	= -(k*cosd(90-abs(theta)));
% T			= abs(trans); % remove direction
% % 1
% o			= T.*sind(theta);
% a			= T.*cosd(theta);
% % 2
% thetaprime	= theta+rot;
% odprime		= a.*tand(thetaprime);
% oprime		= o-odprime;
% oprime		= -oprime; % introduce direction
% figure(666);
% subplot(221)
% plot(theta,oprime,'k-','LineWidth',1,'Color',[1 .7 .7]);
% hold on
% plot(theta,oprime,'ro','LineWidth',2,'MarkerFaceColor','w');
% axis([-180 180 -10 10]);
% axis square;
% title('Head-fixed speakers, head-fixed task');

return
theta = -30;
Phi = theta+90;
L = 1.2;
S = 1;
wt  = (0:.1:360);
X   = L*cosd(Phi)*cos(wt) - S*sind(Phi)*sin(wt);
Y   = L*sind(Phi)*cos(wt) + S*cosd(Phi)*sin(wt);

xhead = [0 0];
yhead = [-5 5];
[xhead,yhead] = pa_2drotate(xhead,yhead,theta);
xhead2 = [-5 5];
yhead2 = [0 0];
[xhead2,yhead2] = pa_2drotate(xhead2,yhead2,theta);

plot(X,Y,'k-');
hold on
plot(xhead,yhead,'k--');
plot(xhead2,yhead2,'k--');
plot(0,0,'kh','MarkerFaceColor','k','MarkerSize',20);
plot(0,0.01*theta,'rh','MarkerFaceColor','r','MarkerSize',20);
axis([-3 3 -3 3]);
axis square;
pa_verline(0);

%% GRAVITATIONAL TRANSLATION

%% Distance to auditory median plane, head-fixed speakers
theta	= -90:90;
alpha	= theta;
k		= 0.05;
s		= k*alpha;
sgn		= sign(alpha);
o		= sgn.*s.*sind(alpha);
figure
subplot(221)
plot(theta,-o,'k-','LineWidth',2);
hold on
axis square;
title('Head-task, head-speakers')
ylim([-5 5]);
pa_horline;

%% Distance to earth-gravity, head-fixed speakers
theta	= -90:90;
o		= zeros(size(theta));
subplot(222)
plot(theta,-o,'k-','LineWidth',2);
hold on
axis square;
title('World-task, head-speakers')
ylim([-5 5]);
pa_horline;
%% Distance to auditory median plane, world-fixed speakers
theta	= -90:90;
alpha	= theta;
k		= 0.05;
s		= k*alpha;
sgn		= sign(alpha);
a		= sgn.*s.*cosd(alpha);

alpha = 90-theta;
s = a;
a		= s.*cosd(alpha);
subplot(223)
plot(theta,a,'k-','LineWidth',2);
hold on
axis square;
title('Head-task, world-speakers')
ylim([-5 5]);
pa_horline;
%% Distance to earth-gravity, world-fixed speakers
theta	= -90:90;
alpha = theta;

a		= zeros(size(theta));
subplot(224)
plot(theta,o,'k-','LineWidth',2);
hold on
axis square;
title('World-task, World-speakers')
ylim([-5 5]);
pa_horline;

%% HEAD ROTATION

%% Distance to auditory median plane, head-fixed speakers
theta	= -90:90;
o		= zeros(size(theta));

subplot(221)
plot(theta,-o,'r-','LineWidth',2);
axis square;
title('Head-task, head-speakers')
%% Distance to earth-gravity, head-fixed speakers
theta	= -90:90;
o		= zeros(size(theta));
subplot(222)
plot(theta,-o,'r-','LineWidth',2);
axis square;
title('World-task, head-speakers')

%% Distance to auditory median plane, world-fixed speakers
theta	= -90:90;
o		= zeros(size(theta));
subplot(223)
plot(theta,-o,'r-','LineWidth',2);
axis square;
title('Head-task, world-speakers')
%% Distance to earth-gravity, world-fixed speakers
theta	= -90:90;
o		= zeros(size(theta));
subplot(224)
plot(theta,-o,'r-','LineWidth',2);
axis square;
title('World-task, World-speakers')



%% ROTATION & TRANSLATION

%% Distance to auditory median plane, head-fixed speakers
theta	= -130:1:130;
alpha	= theta;
k		= .05;
s		= k*alpha;
sgn		= sign(alpha);

r = 25;
alpha = theta-r.*sind(theta);
o		= sgn.*s.*sind(alpha);

subplot(221)
plot(theta,-o,'g-','LineWidth',2);
hold on
axis square;
title('Head-task, head-speakers')
ylim([-5 5]);
xlim([-130 130])
pa_horline;
pa_verline(-120:30:120);
%% Distance to earth-gravity, head-fixed speakers
theta	= -90:90;
o		= zeros(size(theta));
subplot(222)
plot(theta,-o,'g-','LineWidth',2);
hold on
axis square;
title('World-task, head-speakers')
ylim([-5 5]);
pa_horline;
%% Distance to auditory median plane, world-fixed speakers
theta	= -90:90;
alpha	= theta;
k		= 0.05;
s		= k*alpha;
sgn		= sign(alpha);
a		= sgn.*s.*cosd(alpha);

alpha = 90-theta;
s = a;
a		= s.*cosd(alpha);
subplot(223)
plot(theta,a,'g-','LineWidth',2);
hold on
axis square;
title('Head-task, world-speakers')
ylim([-5 5]);
pa_horline;
%% Distance to earth-gravity, world-fixed speakers
theta	= -90:90;
alpha = theta;

a		= zeros(size(theta));
subplot(224)
plot(theta,o,'g-','LineWidth',2);
hold on
axis square;
title('World-task, World-speakers')
ylim([-5 5]);
pa_horline;

