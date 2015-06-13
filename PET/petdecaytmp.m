function tmp
close all
clear all
clc


%% Decay
thalf   = 109.771; % half-time (min)
thalf   = thalf/(24*60); % half-time (days)
lambda  = log(2)/thalf; % decay constant (1/days)
dur     = 0:100; % min
dur     = dur/(24*60); %days
D       = exp(-lambda*dur);
dur     = dur*24*60; % min
subplot(221)
plot(dur,D,'k-','LineWidth',2);
xlabel('Time interval (min)');
axis square;
ylim([0 1]);
ylabel('Decay');

% %% Read data
% C1 = 8791535;
% A0 = 127.53;
% % '12:18:00';
% t0 = 12*60*60 + 18*60 + 0; %s
% t0 = t0/(60*60*24); % days
% % 12:51:16
% t1 = 12*60*60+51*60+16; %s
% t1 = t1/(60*60*24); % days
% D  = decayfun(C1,A0,t0,t1)
% 
% %% Read data
% C1 = 9101339;
% A0 = 127.53;
% % '12:29:00';
% t0 = 12*60*60 + 29*60 + 0; %s
% t0 = t0/(60*60*24); % days
% % 13:05:00
% t1 = 13*60*60+05*60+0; %s
% t1 = t1/(60*60*24); % days
% D  = decayfun(C1,A0,t0,t1)

%% Read all data
cd('C:\DATA\KNO\PET');
[N,T,R] = xlsread('conversion_1.xlsx');

%% Control
C1      = N(:,1);
A0      = N(:,3);
t0      = N(:,2);
t1      = N(:,4);

C = decayfun(C1,A0,t0,t1);
subplot(223)
plot(C1,C,'k.');
ax = axis;
mx = max(ax);
axis([0 mx 0 mx]);
axis square;
pa_unityline;

%% Visual
C1      = N(:,7);
A0      = N(:,9);
t0      = N(:,8);
t1      = N(:,10);

V = decayfun(C1,A0,t0,t1);
subplot(224)
plot(C1,V,'k.');
ax = axis;
mx = max(ax);
axis([0 mx 0 mx]);
axis square;
pa_unityline;

P = round(100*(V-C)./C);



function D = decayfun(C1,A0,t0,t1)
thalf   = 109.771; % half-time (min)
thalf   = thalf/(24*60); % half-time (days)
lambda  = log(2)/thalf; % decay constant (1/days)
dur     = t1-t0; % time interval (days)
D       = 100*C1./A0.*exp(-lambda.*dur);

% =B45*D45/100*EXP(-$C$58*(E45-C45))