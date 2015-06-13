function pettmp
close all
clear all
clc

% subject = 'Raamsdonk';
subject = 'Tewinkellondon';
% FDG = [126 126 126];
% t1 = [0 0 0 12 22 00;...
% 	0 0 0 12 09 55;...
% 	0 0 0 12 06 45];
% t2 = [0 0 0 13 02 00;...
% 	0 0 0 12 49 55;...
% 	0 0 0 12 46 45];

% subject = 'VanWieringen';
FDG = [112 127 122];
t1 = [0 0 0 12 12 32;...
	0 0 0 12 09 15;...
	0 0 0 12 40 00];
t2 = [0 0 0 12 52 32;...
	0 0 0 12 49 15;...
	0 0 0 12 49 15];


% %% Origin-reset
% origin = [101 104 41];
% file = ['C:\DATA\KNO\PET\CI\' subject '\SPM\Control.img'];
% pa_pet_originset(file,origin,'display',1);
% 
% file = ['C:\DATA\KNO\PET\CI\' subject '\SPM\Vision.img'];
% pa_pet_originset(file,origin,'display',1);
% 
% file = ['C:\DATA\KNO\PET\CI\' subject '\SPM\AV.img'];
% pa_pet_originset(file,origin,'display',1);
% return

% %% Realign in SPM
% % open SPM/PET and realign

% %% Correct for decay
% files = {['C:\DATA\KNO\PET\CI\' subject '\SPM\rro_Control.img'];...
% 	['C:\DATA\KNO\PET\CI\' subject '\SPM\rro_Vision.img'];...
% 	['C:\DATA\KNO\PET\CI\' subject '\SPM\rro_AV.img']};
% 
% pa_pet_decaycorrect(files,t1,t2,FDG);
% return

% %% Co-register in SPM
% % open SPM/PET and realign

%%

files = {['C:\DATA\KNO\PET\CI\' subject '\SPM\drro_Control.img'];...
	['C:\DATA\KNO\PET\CI\' subject '\SPM\drro_AV.img']};

fnameControl	= files{1};
fnameTest		= files{2};
niiControl			= load_nii(fnameControl, [], 1); % load the scan
niiTest				= load_nii(fnameTest, [], 1); % load the scan
C = niiControl.img;
T = niiTest.img;

thresh		= 200;
threshd		= 3500;
threshdiff  = 20;

%% Everything above 0
T(T<thresh)  = thresh;
C(C<thresh)  = thresh;


%% Image back into nii
niiTest.img  = T;
niiControl.img  = C;


%% View
view_nii(niiControl);
view_nii(niiTest);


%% Difference
C = niiControl.img;
T = niiTest.img;
 
T(T<threshd)  = threshd;
C(C<threshd)  = threshd;
 
D =(T-C)./C;
 
% D(isnan(D)) = nanmin(D(:));
% D(isinf(D)) = nanmin(D(:));
D      = D*100;
D(D<threshdiff)    = 0;
 
figure
x = min(D(:)):max(D(:));
hist(D(:),x);
ylim([0 9000]);
xlim([-50 50]);
niiDiff    = niiControl;
niiDiff.img = D;
 
%% overlay?
option.setvalue.idx = find(D);
option.setvalue.val = D(option.setvalue.idx);
option.useinterp = 1;
% option.setviewpoint = [51      67      25];
view_nii(niiControl,option);
 