function pa_pet_analysis_example(subject,cond)
% PA_PET_ANALYSIS_EXAMPLE(SUBJECT)
%
% Analyse PET data of a single SUBJECT
% SUBJECT should be a number.
%
% See also PA_PET_ORIGINSET, PA_PET_XLSREAD_EXAMPLE, PA_PET_DECAYCORRECT

% 2012 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
% Clean-up
close all; % clear 
clc; % clear screen

%% ADJUST THESE PARAMETERS
% If experimenter did not supply a SUBJECT nr,
if nargin<1 % the Number of INput ARGuments is 0
	subject = 15; % so I will provide this default
end
if nargin<2 % the Number of INput ARGuments is 0
	cond = 'post'; % so I will provide this default
end
originc	= [64 68 27]; % S 13 14
originv	= [64 68 27]; % S 13 14
originav = [64 68 27]; % S 13 14
threshdiff  = 10;

	
%% Some flags
origin_flag = false; % Correct for origin
decay_flag	= false; % Correct for decay
comp_flag	= true; % compare two conditions

%% Visit the data directory
if subject>9
	sstr	= 's';
% 	dname	= pa_datadir(['\KNO\PET\S' num2str(subject)]); % this only works if the default DATA-directory is C:\DATA\KNO\PET\S
	dname = ['E:\DATA\KNO\PET\S' num2str(subject)];
	cd(dname)
else
	sstr	= 's0';
% 	dstr	= ['\KNO\PET\S' num2str(subject)];
% 	dname	= pa_datadir(dstr);
	dname = ['E:\DATA\KNO\PET\S' num2str(subject)];
	cd(dname)
end


	files = {[dname '\swdro_' sstr num2str(subject) '-c-' cond];...
		['E:\DATA\KNO\PET\SPM\spmT_0001.img']};
	
	
	fnameControl	= files{1};
	fnameTest		= files{2};
	niiControl			= load_nii(fnameControl, [], 1); % load the scan
	niiTest				= load_nii(fnameTest, [], 1); % load the scan
	C = niiControl.img;
	T = niiTest.img;

	T(T<2)    = 0;
	T(T>15) = 15;
	%% overlay?
	option.setvalue.idx = find(T);
	option.setvalue.val = T(option.setvalue.idx);
	option.useinterp = 1;
	% option.setviewpoint = [51      67      25];
	view_nii(niiControl,option);
