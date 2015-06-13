function nynke_check_cal(calname,locname,d)
% NYNKE_CHECK_CAL(CALNAME,LOCNAME,DIR)
%
% Check whether range of calibration experiment DIR\CALNAME is sufficient
% for localization responses in DIR\LOCNAME
%
% See also PA_LOADDAT

%% Localization experiment
if nargin<3
    d = 'D:\DATA\Static localisation\NN-01-2013-11-04';
end
cd(d);
nchan       = 8;
nsample     = 1500;
ntrials     = 462;
if nargin<2
locname = 'NN-01-2013-11-04-0001';
end
dat         = pa_loaddat(locname,nchan,nsample,ntrials);

H = squeeze(dat(:,:,1))/2;
V = squeeze(dat(:,:,2))/2;
F = squeeze(dat(:,:,3))/2;

subplot(221)
plot(H,V,'r.');
hold on
axis square
box off
set(gca,'TickDir','out');
xlabel('Horizontal field (V)');
ylabel('Vertical field (V)');

subplot(222)
plot(H,F,'r.');
hold on
axis square
box off
set(gca,'TickDir','out');
xlabel('Horizontal field (V)');
ylabel('Frontal field (V)');

subplot(223)
plot(V,F,'r.');
hold on
axis square
box off
set(gca,'TickDir','out');
xlabel('Vertical field (V)');
ylabel('Frontal field (V)');

subplot(224)
plot3(H,V,F,'r.');
hold on
axis equal
box off
set(gca,'TickDir','out');
xlabel('Horizontal field (V)');
ylabel('Vertical field (V)');
zlabel('Frontal field (V)');
grid on

%% Calibration experiment
if nargin<3
    d = 'D:\DATA\';
end
cd(d);

% [H,V]   = pa_loadraw('NN-01-20
nchan       = 8;
nsample     = 100;
ntrials     = 83;
if nargin<1
    calname = 'skycalibrationtest';
end
dat         = pa_loaddat(calname,nchan,nsample,ntrials);

H = squeeze(dat(:,:,1));
V = squeeze(dat(:,:,2));
F = squeeze(dat(:,:,3));

subplot(221)
plot(H,V,'k.');
hold on
axis square
box off
set(gca,'TickDir','out');
xlabel('Horizontal field (V)');
ylabel('Vertical field (V)');

subplot(222)
plot(H,F,'k.');
hold on
axis square
box off
set(gca,'TickDir','out');
xlabel('Horizontal field (V)');
ylabel('Frontal field (V)');

subplot(223)
plot(V,F,'k.');
hold on
axis square
box off
set(gca,'TickDir','out');
xlabel('Vertical field (V)');
ylabel('Frontal field (V)');

subplot(224)
plot3(H,V,F,'k.');
hold on
axis equal
box off
set(gca,'TickDir','out');
xlabel('Horizontal field (V)');
ylabel('Vertical field (V)');
zlabel('Frontal field (V)');
grid on


