function A4_reaction_time_analysis

%1) rection time vs gain
%2) RT vs sigma
%3) gain vs sigma
%4) reaction time distribution

close all
clear all
subject = 'HH'

switch subject
    case 'LJ'

cd 'C:\DATA\RG-LJ-2012-01-10'
return
load('Combined_DataLJall');
sel = abs(SS10(:,24))<12;
X = SS10(sel,5);
Y = SS10(sel,24);
Z = SS10(sel,9);
sigma = 20;
XI = 100:10:300;
% [beta,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);
[beta,betasd,sd,sdci,XI] = pa_weightedresidu(X,Y,Z,sigma,XI);
whos beta se
subplot(2,2,1);
plot(XI,beta,'k-','LineWidth',2);
ylim([0 1.5]);
xlabel('Reaction time (ms)');
ylabel('Gain');
xlim([min(XI) max(XI)]);

subplot(2,2,2);
plot(XI,sd,'k-','LineWidth',2);
ylim([0 20]);
xlabel('Reaction time (ms)');
ylabel('\sigma (deg)');
xlim([min(XI) max(XI)]);

subplot(2,2,3)
plot(sd,beta,'k.','LineWidth',2);
axis([0 20 0 1.5]);
ylabel('Gain');
xlabel('\sigma (deg)');

subplot(2,2,4)
hist(X,XI);
xlim([min(XI) max(XI)]);


    case 'HH'
       cd 'C:\DATA\RG-HH-2012-01-13'

load('Combined_DataHHall');
% SS      = [SS10;SS30;SS50];
SS      = [SS10];
sel     = abs(SS(:,24))<12;
X       = SS(sel,5);
Y       = SS(sel,24);
Z       = SS(sel,9);
sigma   = 30;
XI      = 0:10:600;
N       = hist(X,XI);

% [beta,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);
[beta,betasd,sd,sdci,XI] = pa_weightedresidu(X,Y,Z,sigma,XI);
sel = N<10;
beta(sel) = NaN;
sd(sel) = NaN;


whos beta se
subplot(2,2,1);
plot(XI,beta,'k-','LineWidth',2);
ylim([0 1.5]);
xlabel('Reaction time (ms)');
ylabel('Gain');
xlim([min(XI) max(XI)]);

subplot(2,2,2);
plot(XI,sd,'k-','LineWidth',2);
ylim([0 20]);
xlabel('Reaction time (ms)');
ylabel('\sigma (deg)');
xlim([min(XI) max(XI)]);

subplot(2,2,3)
plot(sd,beta,'k.','LineWidth',2);
axis([0 20 0 1.5]);
ylabel('Gain');
xlabel('\sigma (deg)');

subplot(2,2,4)
hist(X,XI);
xlim([min(XI) max(XI)]); 


    case 'MW'

cd 'C:\DATA\RG-MW-2012-01-19'
return
load('Combined_DataMWall');
sel = abs(SS10(:,24))<12;
X = SS10(sel,5);
Y = SS10(sel,24);
Z = SS10(sel,9);
sigma = 20;
XI = 100:10:300;
% [beta,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);
[beta,betasd,sd,sdci,XI] = pa_weightedresidu(X,Y,Z,sigma,XI);
whos beta se
subplot(2,2,1);
plot(XI,beta,'k-','LineWidth',2);
ylim([0 1.5]);
xlabel('Reaction time (ms)');
ylabel('Gain');
xlim([min(XI) max(XI)]);

subplot(2,2,2);
plot(XI,sd,'k-','LineWidth',2);
ylim([0 20]);
xlabel('Reaction time (ms)');
ylabel('\sigma (deg)');
xlim([min(XI) max(XI)]);

subplot(2,2,3)
plot(sd,beta,'k.','LineWidth',2);
axis([0 20 0 1.5]);
ylabel('Gain');
xlabel('\sigma (deg)');

subplot(2,2,4)
hist(X,XI);
xlim([min(XI) max(XI)]);


end