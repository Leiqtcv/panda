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
	subject = 9; % so I will provide this default
end
if nargin<2 % the Number of INput ARGuments is 0
	cond = 'post'; % so I will provide this default
end
originc		= [64 68 27]; % S 13 14
originv		= [64 68 27]; % S 13 14
originav	= [64 68 27]; % S 13 14
threshdiff  = 10;

	
%% Some flags
origin_flag = true; % Correct for origin
decay_flag	= true; % Correct for decay
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

%% Import DICOM in SPM
% Open SPM and import
d = dir('*.img');
if isempty(d) % Check whether there is an img file that SPM can read
	str		= 'Please import data-files in SPM (convert DICOM to NIFTI).';
	disp(str);
	return
end
% Some defauls for now
FDG			= [126 126 126];
t1			= [0 0 0 12 22 00;...
	0 0 0 12 09 55;...
	0 0 0 12 06 45];
t2			= [0 0 0 13 02 00;...
	0 0 0 12 49 55;...
	0 0 0 12 46 45];


%% Check registry
% Open SPM and check registry
d	= dir('*.img');

%% Origin-reset
% It is best to reset the origin. If you don't then realigning won't work.
% Why this is, I don't know...
sel = strncmp('o_',{d.name},2);
if ~any(sel)
	str = 'If you haven''t checked registration, please do so now';
	disp(str);
	origin_flag = true;
end
if origin_flag
% 	origin	= [100 100 50]; % S 13 14
% 	origin	= [130 130 50]; % S 13 14
% 	origin	= [65 65 30]; % S 13 14

	fname	= [sstr num2str(subject) '-c-' cond '.img'];
	file	= [dname '\' fname];
	pa_pet_originset(file,originc,'display',1);
	
	fname	= [sstr num2str(subject) '-v-' cond '.img'];
	file	= [dname '\' fname];
	pa_pet_originset(file,originv,'display',1);
	
	fname	= [sstr num2str(subject) '-av-' cond '.img'];
	file	= [dname '\' fname];
	pa_pet_originset(file,originav,'display',1);
	return
end

%% Realign in SPM
% open SPM/PET and realign
% Do so for the re-originated 'o_' files (it might produce rubbish otherwise)


%% Correct for decay
% Why can't we use decay-function and times?
sel = strncmp('dro_',{d.name},4);
if ~any(sel)
	str = 'If you haven''t corrected for decay, please do so now';
	disp(str);
	decay_flag = true;
end
if decay_flag
	fname1	= ['ro_' sstr num2str(subject) '-c-' cond '.img'];
	fname2	= ['ro_' sstr num2str(subject) '-v-' cond '.img'];
	fname3	= ['ro_' sstr num2str(subject) '-av-' cond '.img'];
	files	= {[dname '\' fname1];...
		[dname '\' fname2];...
		[dname '\' fname3]};
	pa_pet_decaycorrect(files,t1,t2,FDG);
	return
end

% %% Co-register in SPM
% open SPM/PET and co-register: this is only required when you want to
% co-register an anatomical CT scan

%% Normalize
% SPM

%% Grand mean scaling
pa_pet_grandmeanscale(fname);
% GX = spm_global(V);

% pa_pet_meangrandscale(fname);
% GX = spm_global(V);

%% Smooth
% SPM
sel = strncmp('swdro_',{d.name},4);
if ~any(sel)
	str = 'Please smooth the data in SPM';
	disp(str);
	return
end

%% Comparison
if comp_flag
	files = {[dname '\swdro_' sstr num2str(subject) '-c-' cond];...
		[dname '\swdro_' sstr num2str(subject) '-v-' cond]};
	
	
	fnameControl	= files{1};
	fnameTest		= files{2};
	niiControl			= load_nii(fnameControl, [], 1); % load the scan
	niiTest				= load_nii(fnameTest, [], 1); % load the scan
	C = niiControl.img;
	T = niiTest.img;
	
	thresh		= 200;
	threshd		= 3500;
	threshdiff  = 10;
	
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
end
niiDiff
str = ['s' num2str(subject) 'diff'];
cd('E:\DATA\KNO\PET');
save(str,'niiDiff');
str = ['s' num2str(subject) 'control'];
save(str,'niiControl');

%% 
