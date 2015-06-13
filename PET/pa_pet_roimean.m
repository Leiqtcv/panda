function [mu,var] = pa_pet_roimean(fname,roiname)
% MU = PA_PET_ROIMEAN(FNAME,ROI)
%
% Obtain mean value from region of interest ROI (AAL)
%
% See also GET_MARSY, SUMMARY_DATA from MARSBAR, SPM

% 2012 Marc van Wanrooij
% e-mail: m.vanwanrooij@neural-code.com

if nargin<1
	fname		= 'E:\DATA\KNO\PET\SWDRO files\swdro_s15-v-post.img';
end
[path,fname,ext] = fileparts(fname);
cd(path);
fname = [fname ext];
if nargin<2
	roiname	= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
end
load(roiname);
marsY		= get_marsy(roi, fname, 'mean');
[mu,var]	= summary_data(marsY);

