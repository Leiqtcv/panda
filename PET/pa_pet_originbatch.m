function pa_pet_originbatch
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

dname = 'E:\Backup\Nifti\';
cd(dname);



%% Check registry
% Open SPM and check registry
d	= dir('*mPET.img');
n = numel(d);
origin1		= [64 68 27];
origin2	= [100 100 50]; % S 13 14

for ii = 1:n

	fname = d(ii).name
	nii = load_nii(fname,[],[],1);
	sz = nii.hdr.dime.dim;
	if sz(2)<150;
		origin = origin1;
	else
		origin = origin2;
	end
%% Origin-reset
% It is best to reset the origin. If you don't then realigning won't work.
% Why this is, I don't know...
% fname	= [sstr num2str(subject) '-' modal{1} '-' cond '.img'];
file	= [dname '\' fname]
pa_pet_originset(file,origin,'display',0);
% pause
end
