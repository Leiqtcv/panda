close all;
clear all;

%% Load data
cd('E:\MATLAB\PANDA\Donders');
[num,txt,raw] = xlsread('maskersdB.xlsx');

%% Distribute
Intensity	= num(2:end,1); % as indicated in Matlab experimental m-file
Frequency	= num(1,2:end); % sound frequency (Hz)
soundlevel	= num(2:end,2:end); % measured sound level by B&K (dB SPL / dB A)

%% A-weighting
sel					= Frequency<1000; % Which frequencies are measured A-weighted?
soundlevel(:,sel)	= soundlevel(:,sel)-repmat(pa_aweight(Frequency(sel)),size(soundlevel,1),1); % is this correct


%% Regression
whos Intensity soundlevel
x = repmat(Intensity,1,size(soundlevel,2));
y = soundlevel;
x = x(:);
y = y(:);

sel = ~isnan(y) & x>45 & x<75;
y = y(sel);
x = x(sel);
b = regstats(y,x);

% %% Interpolation
% x = Intensity;
% y = Frequency;
% [x,y] = meshgrid(x,y);
% x = x';
% y = y';
% z = soundlevel;
%
% x = x(:);
% y = y(:);
% z = z(:);
% sel = isnan(z);
% x = x(~sel);
% y = y(~sel);
% z = z(~sel);
%
% XI = Intensity;
% YI = Frequency;
% [XI,YI] =  meshgrid(XI,YI);
%
% ZI = griddata(x,y,z,XI,YI,'linear');
% % ZI = interp2(x,y,z,XI,YI,'*linear');
% soundlevel = ZI';

%% Graphics
subplot(121)
plot(Intensity,soundlevel,'k-','Color',[.7 .7 .7]);
hold on
muSL	= nanmean(soundlevel,2);
errorbar(Intensity,muSL,nanstd(soundlevel,[],2),'ko-','LineWidth',2,'MarkerFaceColor','w');
axis square;
box off;
xlabel('FART Level');
ylabel('Sound Level (dBA)');
h = pa_regline(b.beta,'r-');
set(h,'LineWidth',2);
str = ['Sound Level = ' num2str(b.beta(2),2) ' FART level - ' num2str(abs(round(b.beta(1))))];
title(str)
pa_verline(45)
pa_verline(75)
ylim([25 95]);
xlim([30 95]);

%% Graphics
subplot(122)
semilogx(Frequency,soundlevel,'k-','Color',[.7 .7 .7]);
hold on
semilogx(Frequency,nanmean(soundlevel),'ko-','LineWidth',2,'MarkerFaceColor','w');
axis square;
box off;
xlabel('Sound Frequency (Hz)');
ylabel('Sound Level (dBA)');
set(gca,'Xscale','log','XTick',pa_oct2bw(125,0:1:7),'XTicklabel',pa_oct2bw(125,0:1:7)); % set tick marks, and logaritmic axis
xlim([100 16000]);

%% print
pa_datadir; % save in C:\DATA directory
print('-depsc','-painter',mfilename); % save as color eps withe filename same as this m-file