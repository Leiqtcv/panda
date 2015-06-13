function pa_pet_cutimage(file,varargin)
% PA_PET_CUTIMAGE(FILE,ORIGIN)
% DOES NOT WORK
%
% Resize the brain data FILE (in NIFTI format)
%
% PA_PET_CUTIMAGE(...,'PARAM1',val1,'PARAM2',val2) specifies optional
% name/value pairs. Parameters are:
%	'display'	- display the brain data before and after origin set. Options are:
%			- 0 (don't display, default)
%			- 1 (display)
%
% See also Jimmy Shen's nii Matlab toolbox.

% 2013 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.nl

%% Optional input
dspflag         = pa_keyval('display',varargin);
if isempty(dspflag)
	dspflag			= false;
end
if nargin<1
	file = [];
	pa_fcheckexist(file);
end
[pathstr,fname] = fileparts(file);

nii		= load_nii(file, [], 1); % load the scan
if dspflag
	view_nii(nii);
end

%% Cut image
mu = round((200+1)/2);
range = 128/2;
indx = mu-range+1:mu+range;
img = nii.img;
p = img(indx,indx,76-53:75);
whos p
nii.img = p;
nii.hdr.dime.dim = [3 128 128 53 1 1 1 1];
fname = ['c' fname];
save_nii(nii, [pathstr filesep fname]); % save the scan, give it a unique name
if dspflag
	view_nii(nii);
end


