%% Run pa_nirs_parameters_LR 
% To get al parameters once, stored in -param.mat

%By Marc van Wanrooij, 2013

%% Clean all
clear all
close all
clc

%% Run al subjects
pp = 1:21; % Number of subjects
npp = numel(pp);
datadir = 'E:\DATA\Studenten\Luuk\Raw data\';
datadir = 'C:\DATA\Studenten\Luuk\Raw data\';
datadir = 'E:\DATA\Studenten\Luuk\Raw data\';

% d = 'E:\DATA\Studenten\Luuk\Raw data\LR-1721';

for ii = 1:npp
    cd(datadir)
    str = ['LR-17' num2str(pp(ii),'%02i')];
    cd(str);
    fnames = dir('*.mat');
%     fname = 'LR-1719-2013-11-07-';

    fname = [str '-' fnames(1).name(9:18) '-'];
%     lr_figure3(fname)
    lr_figure5(fname)
	title(fnames(1).name)
%     pause;
end


