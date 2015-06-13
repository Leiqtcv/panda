function kno_pet_figure2
% KNO_PET_FIGURE2
%
% Produce figure 2
% L.V. Straatman1, M.M. van Wanrooij1,2, L.F. de Geus-Oei3, E.P. Visser3, A.F.M. Snik1, J.J.S. Mulder1
%

%% Cleansing
close all
clear all
saveFlag = true;

% cd('E:\DATA\KNO\PET\marsbar-aal');
% load('MNI_Caudate_L_roi.mat');
% whos
% % mars_display_roi('display', roi)
% % mars_display_roi('display', roi_obj, structv, cmap)
% mars_rois2img('MNI_Caudate_L_roi.mat','tst');
% return
%%
p					= 'E:\DATA\KNO\PET\swdro files\';
files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	'gswdro_s06-v-pre.img';'gswdro_s08-v-pre.img';...
	'gswdro_s09-v-pre.img';'gswdro_s10-v-pre.img';...
	'gswdro_s11-v-pre.img';'gswdro_s12-v-pre.img';...
	'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img';...
	'gswdro_s01-v-normal.img';'gswdro_s02-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img';...
	};

nii = getavgscan(files,p);
img = nii.img;

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

[muD,sdD] = getavgdiff(files1,files2,p);
plotscan(muD,sdD,img,'pre',saveFlag)
plotnegscan(muD,sdD,img,'pre',saveFlag)


%% POST
files1 = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
files2 = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	};
[muD,sdD] = getavgdiff(files1,files2,p);
plotscan(muD,sdD,img,'post',saveFlag)
plotnegscan(muD,sdD,img,'post',saveFlag)

%% NORMAL
files1 = {'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'};
files2 = {'gswdro_s01-v-normal.img';'gswdro_s02-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img'};
[muD,sdD] = getavgdiff(files1,files2,p);
plotscan(muD,sdD,img,'normal',saveFlag)
plotnegscan(muD,sdD,img,'normal',saveFlag)

pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% POST
files1 = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	'gswdro_s01-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img'};
% files1 = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
% 	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
% 	'gswdro_s16-c-post.img';...
% 	'gswdro_s01-c-normal.img';'gswdro_s03-c-normal.img';...
% 	'gswdro_s04-c-normal.img'};

files2 = {'gswdro_s07-av-post.img';'gswdro_s13-av-post.img';...
	'gswdro_s14-av-post.img';'gswdro_s15-av-post.img';...
	'gswdro_s16-av-post.img';...
	'gswdro_s01-av-normal.img';'gswdro_s03-av-normal.img';...
	'gswdro_s04-av-normal.img'};
[muD,sdD] = getavgdiff(files1,files2,p);
plotscan(muD,sdD,img,'av',saveFlag)
plotnegscan(muD,sdD,img,'av',saveFlag)

pa_datadir;
print('-depsc','-painter','av');


function nii = getavgscan(files,p)
nfiles	= length(files);
IMG		= NaN(79,95,68,nfiles);
for ii = 1:nfiles
	fname	= [p files{ii}];
	nii		= load_nii(fname, [], 1);
	
	
	IMG(:,:,:,ii)	= nii.img;
end
mu		= squeeze(mean(IMG,4));
nii.img = mu;

function [muD,sdD,nii1] = getavgdiff(files1,files2,p)
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



function plotscan(muD,sdD,img,group,saveFlag)
close all
colormap jet
if saveFlag
	stepsize = 5;
else
	stepsize = 1;
end
for ii = 1:stepsize:size(muD,3)
	cla
	x = squeeze(img(:,:,ii))';
	subimage(x,gray(100))
	set(gca,'YDir','normal');
	hold on
	x = squeeze(muD(:,:,ii));
	s = squeeze(sdD(:,:,ii));
	
	x(x<1.5*s)    = NaN;
	x(x<2) = NaN;
	if any(~isnan(x(:)))
		contourf(x',-40:2.5:40);
		colorbar;
		caxis([0 30])
	end
	xlabel('X');
	ylabel('Y');
	title(['Positive, ' group ', Z = ' num2str(ii)]);
	drawnow
	if saveFlag
		pa_datadir
		print('-depsc','-painter',[mfilename '-' group '-Z-' num2str(ii)]);
	end
end

function plotnegscan(muD,sdD,img,group,saveFlag)
close all
colormap jet
if saveFlag
	stepsize = 5;
else
	stepsize = 1;
end
for ii = 1:stepsize:size(muD,3)
	cla
	x = squeeze(img(:,:,ii))';
	subimage(x,gray(100))
	set(gca,'YDir','normal');
	hold on
	x = squeeze(muD(:,:,ii));
	s = squeeze(sdD(:,:,ii));
	% 	x(x<1*s & x>-1*s)    = NaN;
	% 	x(x<2 & x>-2) = NaN;
	
	x(x>-1.5*s)    = NaN;
	x(x>-2) = NaN;
	x = abs(x);
	if any(~isnan(x(:)))
		contourf(x',-40:2.5:40);
		colorbar;
		caxis([0 20])
	end
	xlabel('X');
	ylabel('Y');
	title(['Negative, ' group ', Z = ' num2str(ii)]);
	drawnow
	if saveFlag
		
		pa_datadir
		print('-depsc','-painter',[mfilename '-' group '-Z-neg-' num2str(ii)]);
	end
end