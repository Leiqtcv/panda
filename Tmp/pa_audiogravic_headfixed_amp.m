clear all
close all

theta = -180:180;
k = -5;  % deg, negative indicates downwards pull
T = k.*cosd(90-abs(theta)); % deg
A = T.*sind(theta);

figure(1)
plot(theta,T,'k','LineWidth',2);
axis square;
xlabel('Body roll (deg)');
box off
ylabel('Translation (deg)');
ylim([-10 10]);
xlim([-130 130])

pa_verline([-90 90]);
pa_horline(0);

figure(2)
plot(theta,A,'k-','LineWidth',2);
ylim([-10 10])
xlim([-130 130])
axis square;
pa_verline([-90 90]);
pa_horline(0);
box off
xlabel('Body roll (deg)');

% 
% pa_datadir;
% print('-depsc','-painter',[mfilename 'head']);


theta = -180:180;
k = -5;  % deg, negative indicates downwards pull
T = k.*cosd(90-abs(theta)); % deg
A = T.*tand(theta);

figure(1)
plot(theta,T,'k','LineWidth',2);
axis square;
xlabel('Body roll (deg)');
box off
ylabel('Translation (deg)');
ylim([-10 10]);
xlim([-130 130])

pa_verline([-90 90]);
pa_horline(0);

figure(2)
hold on
plot(theta,A,'r-','LineWidth',2);
ylim([-10 10])
xlim([-130 130])
axis square;
pa_verline([-90 90]);
pa_horline(0);
box off
xlabel('Body roll (deg)');


% pa_datadir;
% print('-depsc','-painter',[mfilename 'world']);

%%

theta = -180:180;
t = -5;  % deg, negative indicates downwards pull
r = 0.9;

A = t*cosd(90-abs(theta)).*tand(r*theta);

figure
plot(theta,A,'k-','LineWidth',2);
ylim([-10 10])
xlim([-130 130])
axis square;
pa_verline([-90 90]);
pa_horline(0);
box off
xlabel('Body roll (deg)');