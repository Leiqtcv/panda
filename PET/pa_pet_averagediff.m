function pa_pet_averagediff
home;
clear all;
close all;

cd('E:\DATA\KNO\PET');

load('s13diff')
s13diff = niiDiff;

load('s14diff')
s14diff = niiDiff;

load('s15diff')
s15diff = niiDiff;


% load('s12diff')
% s12diff = niiDiff;


%% Control image
load('s15control')
s15control = niiControl;

%% PET
D = (s13diff.img+s14diff.img+s15diff.img)/3;
D(D>20) = 0;
% niiControl			= load_nii('PET2', [], 1); % load the scan

%% overlay?
option.setvalue.idx = find(D);
option.setvalue.val = D(option.setvalue.idx);
option.useinterp = 1;
% option.setviewpoint = [51      67      25];
view_nii(niiControl,option);
