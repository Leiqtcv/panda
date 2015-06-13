close all
clear all

%% Read data
cd('/Users/marcw/DATA/Student/Guus/BB_LP_2015_04_10_results')

calfile = 'coil1test_Cal_10_4_2015';
load(calfile);


% actual speaker numbers
% separate for azimuth and elevation
% not random calibration
% DataCal, DataBB, DataLP perhaps not good for structure name -> use one
% name
tar		= [DataCal.StimulusLocation];
taraz	= tar(1:2:end);
tarel	= tar(2:2:end);


whos

plot(taraz,tarel,'o');
axis square;
axis([-100 100 -100 100]);
pa_plotfart;
box off;

%% Data
% Calibraton only have to be maximally 100 ms lang
% problems with first 7 samples (random things)
% outside 10V range
% sometimes movement
res = [DataCal.HeadMovement];
DataCal(1).HeadMovement


mures = nanmean(res(10:end,:));

mures1 = mures(1:4:end);
mures2 = mures(2:4:end);
mures3 = mures(3:4:end);

figure
% plot(res)

subplot(221)
plot(mures1)
hold on
plot(mures2)
plot(mures3)
axis square
box off

subplot(222)
plot(tarel,mures1,'o')
axis square

box off

figure
plot3(mures1,mures2,mures3,'.')
