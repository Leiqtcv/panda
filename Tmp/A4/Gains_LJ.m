close all
clear all


pa_datadir RG-LJ-2011-12-14
open 'GainLJ.fig'
hold on

pa_datadir RG-LJ-2011-12-21
open 'GainLJ2.fig'

pa_datadir RG-LJ-2012-01-10
open 'GainLJ3.fig'

pa_datadir RG-LJ-2012-01-17
open 'GainLJall.fig'

%% Wenn ich den Code haette fuer jedes Bild, koennte ich den benutzen.
%% Bisher kann ich nur alle Bilder laden, aber nicht alle als subplots in
%% einem Bild (generate code, via file, aber wie?)
%% Dass muss ich hinkriegen, moechte ja auch alle correlaties pro condities
%% im verlauf nebeneinander haben, Uebersicht