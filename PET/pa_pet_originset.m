function pa_pet_originset(file,origin,varargin)
% PA_PET_ORIGINSET(FILE,ORIGIN)
%
% Set the origin of the brain data FILE (in NIFTI format)
%
% PA_PET_ORIGINSET(...,'PARAM1',val1,'PARAM2',val2) specifies optional
% name/value pairs. Parameters are:
%	'display'	- display the brain data before and after origin set. Options are:
%			- 0 (don't display, default)
%			- 1 (display)
%
% See also Jimmy Shen's nii Matlab toolbox.

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

%% Reset origin
nii.hdr.hist.originator(1:3) = origin; %reset the origin. 
fname = ['o_' fname];
save_nii(nii, [pathstr filesep fname]); % save the scan, give it a unique name
if dspflag
	view_nii(nii);
end

