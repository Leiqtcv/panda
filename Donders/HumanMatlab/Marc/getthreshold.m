%% Get threshold for hearing signals in maskers
%This script analyses data retrieved from pa_fart_tdt_getresponse and gives
% the mean threshold for the last 6 reversals (trialswitches)
%% close all
close all
clear all
clc
%% load data
load('MD-PB-2012-10-08-0002.mat')
T = P(1).par.T; %timing of first interval maskers
F = P(1).par.F/1000; %frequencies of first interval maskers (kHz)
correctresp = [R.correct];	%get correct responses
signallevels = [P.signallevel];	%get all signallevels.

figure
plot(signallevels)


%% Get threshold
dcrit = abs(diff(correctresp));				%get diffrences between correctresponses (trial switches)
trialswitch = find(dcrit>0.1)+1;			%get position of trialswitch
revs = signallevels(trialswitch(1:end-1))	%get signal level of trialswitches
threshold = mean(revs(end-5:end))			%get signal threshold, mean of last 6 reversals.



