function OM2012_pa_pet_avgscans

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

[muD,sdD,nii] = getavgscan(files1,files2,p);

% return
viewscan(muD,sdD,nii);
% nii.img = sdD;
% view_nii(nii);
pa_datadir;
print('-depsc','-painter','pre');

%% POST
files1 = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
files2 = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	};
[muD,sdD,nii] = getavgscan(files1,files2,p);
viewscan(muD,sdD,nii);
pa_datadir;
print('-depsc','-painter','post');



%% NORMAL
files1 = {'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'};
files2 = {'gswdro_s01-v-normal.img';'gswdro_s02-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img'};
[muD,sdD,nii] = getavgscan(files1,files2,p);
viewscan(muD,sdD,nii);
pa_datadir;
print('-depsc','-painter','normal');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% POST
files1 = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	'gswdro_s01-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img'};
files1 = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	'gswdro_s01-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'};

files2 = {'gswdro_s07-av-post.img';'gswdro_s13-av-post.img';...
	'gswdro_s14-av-post.img';'gswdro_s15-av-post.img';...
	'gswdro_s16-av-post.img';...
	'gswdro_s01-av-normal.img';'gswdro_s03-av-normal.img';...
	'gswdro_s04-av-normal.img'};
[muD,sdD,nii] = getavgscan(files1,files2,p);
viewscan(muD,sdD,nii);
pa_datadir;
print('-depsc','-painter','av');




function [muD,sdD,nii1] = getavgscan(files1,files2,p)
nfiles	= length(files1);
nfiles2	= length(files2);
if nfiles~=nfiles2
	disp('Uh-Oh.');
	return
end
IMG		= NaN(79,95,68,nfiles);
for ii = 1:nfiles
	fname	= [p files1{ii}];
	nii1	= load_nii(fname, [], 1);
	
	fname	= [p files2{ii}];
	nii2	= load_nii(fname, [], 1);
	
	D				= getdiff(nii1,nii2);
	IMG(:,:,:,ii)	= D;
end
muD		= squeeze(mean(IMG,4));
sdD		= squeeze(std(IMG,[],4));
% threshd = 10;
% a = IMG(IMG>threshd)
% sdD = mean(a(:));


function  D = getdiff(nii1,nii2)
threshd		= 50; 
IMG1		= nii1.img;
IMG2		= nii2.img;

IMG2(IMG2<threshd)  = threshd;
IMG1(IMG1<threshd)  = threshd;

D			= (IMG2-IMG1)./IMG1;
D				= D*100;

niiDiff		= nii1;
niiDiff.img = D;

% %% overlay?
% option.setvalue.idx = find(D);
% option.setvalue.val = D(option.setvalue.idx);
% option.useinterp = 1;
% option.setcolorindex = 9;
% option.glblocminmax = [0 40];
% % option.setviewpoint = [51      67      25];
% view_nii(nii1,option);

function viewscan(muD,sdD,nii)
mxscl = 25;
mnscl = 5;
muD(muD<1*sdD)    = 0;
muD(muD<mnscl) = 0;
muD(muD>mxscl) = mxscl;

%% overlay?
option.setvalue.idx		= find(muD);
option.setvalue.val		= muD(option.setvalue.idx);
option.useinterp		= 1;
option.setcolorindex	= 9;
option.glblocminmax		= [mnscl mxscl];
% option.setviewpoint = [51      67      25];
  option.setviewpoint = [8      47      28];
view_nii(nii,option);
