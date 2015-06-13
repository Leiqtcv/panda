function pa_pet_grandmeanscale(file,varargin)
% PA_PET_GRANDMEANSCALE(FILE)
%
% Normalize PET volume image by the gobal mean.
%
% Optional arguments:
% 'display' - values 0 or 1
%
% See also SPM_GLOBAL

% 2012 Marc van Wanrooij
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
GX		= spm_global(V);
V		= V./GX*50;
nii.img = V;

%% Reset origin
fname = ['g' fname];
if ~isempty(pathstr)
fullfname = [pathstr filesep fname]
else
fullfname = fname
end
save_nii(nii, fullfname); % save the scan, give it a unique name
if dspflag
	view_nii(nii);
end

