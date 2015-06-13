function mu = pa_pet_getmeandata(files,p,roiname)

%% Region of interest
% Hesch's gyrus / A1
if nargin<3
roiname = 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
end
%% Data directory
if nargin<2
p = 'E:\DATA\KNO\PET\SWDRO files\';
end
if nargin<1
files = {'swdro_s01-c-normal.img';'swdro_s03-c-normal.img';...
	'swdro_s04-c-normal.img'};
end

%% Control condition
nfiles		= length(files);
mu	= NaN(nfiles,1);
for ii = 1:nfiles
	fname			= [p files{ii}];
	mu(ii)	= pa_pet_roimean(fname,roiname);
end
mu = mu/1000;


