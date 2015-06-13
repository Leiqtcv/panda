function pa_nigupdatetest
% Updating mean and variance of the likelihood of a target distribution
close all
clear all
clc

figure(1);
sineprior;

figure(2);
boxcarprior;

function boxcarprior
%% Prior
n		= 500; % number of trials/measurements
V		= 100; % corresponds to number of measurements that prior is based on
m		= 0; % average likelihood
a		= 5; % shape prior
b		= 40^2*(a-1); %skewness prior
x		= 1:n; % time
sl		= 10;

sd		= [repmat(5,1,n/2) repmat(40,1,n/2)];
x		= 0+sd.*randn(1,n);
betai	= [V m a b];

%% Updating
beta		= NaN(n,4);
beta(1,:)	= betai;
var			= NaN(n,1);
mu			= var;
for ii = 2:n
	beta(ii,:)			= pa_nigupdatestep(beta(ii-1,:),x(ii));
	[mu(ii),var(ii)]	= pa_nigmuvar(beta(ii,:));
end
sp		= sqrt(var);
gain	= getgain(sp,sl);

subplot(231)
plot(mu,'k-','LineWidth',2);
ylim([-10 10]);
h	= pa_horline(0,'k-'); set(h,'Color',[.7 .7 .7]);
axis square;

subplot(232)
plot(abs(x),'k-','Color',[.9 .9 .9])
hold on
plot(sd,'k-','Color',[.7 .7 .7],'LineWidth',2);
plot(sqrt(var),'k-','LineWidth',2);
axis square;
mx = 1.2*max(sd);
ylim([0 mx]);

subplot(233)
plot(gain','k-','LineWidth',2);
ylim([0 1]);
axis square;

x		= 1:n; % time
sd		= [repmat(40,1,n/2) repmat(5,1,n/2)];
x		= m+sd.*randn(1,n);
betai	= [V m a b];

%% Updating
beta		= NaN(n,4);
beta(1,:)	= betai;
var			= NaN(n,1);
mu			= var;
for ii = 2:n
	beta(ii,:)			= pa_nigupdatestep(beta(ii-1,:),x(ii));
	[mu(ii),var(ii)]	= pa_nigmuvar(beta(ii,:));
end
sp		= sqrt(var);
gain	= getgain(sp,sl);

subplot(234)
plot(mu,'k-','LineWidth',2);
ylim([-10 10]);
h	= pa_horline(0,'k-'); set(h,'Color',[.7 .7 .7]);
axis square;
xlabel('Trial');
ylabel('Mean');

subplot(235)
plot(abs(x),'k-','Color',[.9 .9 .9])
hold on
plot(sd,'k-','Color',[.7 .7 .7],'LineWidth',2);
plot(sqrt(var),'k-','LineWidth',2);
axis square;
mx = 1.2*max(sd);
ylim([0 mx]);
xlabel('Trial');
ylabel('Variance');

subplot(236)
plot(sd./max(sd),'k-','Color',[.7 .7 .7],'LineWidth',2);
hold on
plot(gain','k-','LineWidth',2);
ylim([0 1]);
axis square;
xlabel('Trial');
ylabel('Gain');

function sineprior
%% Prior
n		= 500; % number of trials/measurements
V		= 100; % corresponds to number of measurements that prior is based on
m		= 0; % average likelihood
a		= 5; % shape prior
b		= 40^2*(a-1); %skewness prior
x		= 1:n; % time
sl		= 10;

%% Sine
freq	= 0.001; % 1 cycle per 100 trials
sd		= 40*sin(2*pi*freq*x+0*pi).^2+5;
x		= 0+sd.*randn(1,n);
betai	= [V m a b];

%% Updating
beta		= NaN(n,4);
beta(1,:)	= betai;
var			= NaN(n,1);
mu			= var;
for ii = 2:n
	beta(ii,:)			= pa_nigupdatestep(beta(ii-1,:),x(ii));
	[mu(ii),var(ii)]	= pa_nigmuvar(beta(ii,:));
end
sp		= sqrt(var);
gain	= getgain(sp,sl);


subplot(231)
plot(mu,'k-','LineWidth',2);
ylim([-10 10]);
h	= pa_horline(0,'k-'); set(h,'Color',[.7 .7 .7]);
axis square;

subplot(232)
plot(abs(x),'k-','Color',[.9 .9 .9])
hold on
plot(sd,'k-','Color',[.7 .7 .7],'LineWidth',2);
plot(sqrt(var),'k-','LineWidth',2);
axis square;
mx = 1.2*max(sd);
ylim([0 mx]);

subplot(233)
plot(gain','k-','LineWidth',2);
ylim([0 1]);
axis square;

%% Sine
x		= 1:n; % time
freq	= 0.01; % 1 cycle per 100 trials
sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
x		= m+sd.*randn(1,n);
betai	= [V m a b];

%% Updating
beta		= NaN(n,4);
beta(1,:)	= betai;
var			= NaN(n,1);
mu			= var;
for ii = 2:n
	beta(ii,:)			= pa_nigupdatestep(beta(ii-1,:),x(ii));
	[mu(ii),var(ii)]	= pa_nigmuvar(beta(ii,:));
end
sp		= sqrt(var);
gain	= getgain(sp,sl);

subplot(234)
plot(mu,'k-','LineWidth',2);
ylim([-10 10]);
h	= pa_horline(0,'k-'); set(h,'Color',[.7 .7 .7]);
axis square;
xlabel('Trial');
ylabel('Mean');

subplot(235)
plot(abs(x),'k-','Color',[.9 .9 .9])
hold on
plot(sd,'k-','Color',[.7 .7 .7],'LineWidth',2);
plot(sqrt(var),'k-','LineWidth',2);
axis square;
mx = 1.2*max(sd);
ylim([0 mx]);
xlabel('Trial');
ylabel('Variance');

subplot(236)
plot(sd./max(sd),'k-','Color',[.7 .7 .7],'LineWidth',2);
hold on
plot(gain','k-','LineWidth',2);
ylim([0 1]);
axis square;
xlabel('Trial');
ylabel('Gain');

function gain = getgain(sp,sl)
gain = sp.^2./(sp.^2+sl.^2);