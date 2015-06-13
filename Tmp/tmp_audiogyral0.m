
clc
close all hidden;
clear all hidden;

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

