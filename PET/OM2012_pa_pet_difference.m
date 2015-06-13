function OM2012_pa_pet_difference

close all
clear all

%% PRE
p					= 'E:\DATA\KNO\PET\swdro files\';
files1		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	};
files2		= {'gswdro_s06-v-pre.img';'gswdro_s08-v-pre.img';...
	'gswdro_s09-v-pre.img';'gswdro_s10-v-pre.img';...
	'gswdro_s11-v-pre.img';'gswdro_s12-v-pre.img';...
	};

niiControl	= getavgscan(files1,p);
niiVision	= getavgscan(files2,p);
getdiff(niiControl,niiVision);



%% POST
files1 = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
files2 = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	};
niiControl	= getavgscan(files1,p);
niiVision	= getavgscan(files2,p);
getdiff(niiControl,niiVision);


%% NORMAL
files1 = {'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'};
files2 = {'gswdro_s01-v-normal.img';'gswdro_s02-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img'};
niiControl	= getavgscan(files1,p);
niiVision	= getavgscan(files2,p);
getdiff(niiControl,niiVision);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% POST
files1 = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	'gswdro_s01-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img'};

files2 = {'gswdro_s07-av-post.img';'gswdro_s13-av-post.img';...
	'gswdro_s14-av-post.img';'gswdro_s15-av-post.img';...
	'gswdro_s16-av-post.img';...
	'gswdro_s01-av-normal.img';'gswdro_s03-av-normal.img';...
	'gswdro_s04-av-normal.img'};
niiControl	= getavgscan(files1,p);
niiVision	= getavgscan(files2,p);
getdiff(niiControl,niiVision);



function nii = getavgscan(files,p)
nfiles	= length(files);
IMG		= NaN(79,95,68,nfiles);
for ii = 1:nfiles
	fname = [p files{ii}];
	nii = load_nii(fname, [], 1);
	a = nii.img;
	IMG(:,:,:,ii) = a;
end
mu				= squeeze(mean(IMG,4));
nii.img	= mu;

function  D = getdiff(nii1,nii2)
threshdiff	= 5;
threshd		= 50; 
IMG1		= nii1.img;
IMG2		= nii2.img;

IMG2(IMG2<threshd)  = threshd;
IMG1(IMG1<threshd)  = threshd;

D			= (IMG2-IMG1)./IMG1;
D			= D*100;
D(D<threshdiff)    = 0;

niiDiff		= nii1;
niiDiff.img = D;

%% overlay?
option.setvalue.idx = find(D);
option.setvalue.val = D(option.setvalue.idx);
option.useinterp = 1;
option.setcolorindex = 9;
option.glblocminmax = [0 40];
% option.setviewpoint = [51      67      25];
view_nii(nii1,option);
