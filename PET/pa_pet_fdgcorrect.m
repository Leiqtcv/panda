function pa_pet_fdgcorrect(file,FDG,varargin)
% PA_PET_FDGCORRECT(FILE,FDG)
%
% Normalize PET volume image by the initial FDG value
%
% Optional arguments:
% 'display' - values 0 or 1
%
% See also LOAD_NII

% 2013 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.nl

%% Optional input
dspflag         = pa_keyval('display',varargin);
if isempty(dspflag)
	dspflag			= 0;
end
[pathstr,fname] = fileparts(file);

nii		= load_nii(file, [], 1); % load the scan
if dspflag
	view_nii(nii);
end

V		= nii.img;
V		= V./FDG;
nii.img = V;

%% Reset origin
fname = ['f' fname];
if ~isempty(pathstr)
fullfname = [pathstr filesep fname];
else
fullfname = fname;
end
save_nii(nii, fullfname); % save the scan, give it a unique name
if dspflag
	view_nii(nii);
end

