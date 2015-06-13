function kno_pet_figure2_glassbrain

% KNO_PET_FIGURE2
%
% Produce figure 2
% L.V. Straatman1, M.M. van Wanrooij1,2, L.F. de Geus-Oei3, E.P. Visser3, A.F.M. Snik1, J.J.S. Mulder1
%

%% Cleansing
close all
clear all
saveFlag = true;
warning off
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


%%

% %% ALL
% p					= 'E:\DATA\KNO\PET\swdro files\';
% files1		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
% 	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
% 	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
% 'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
% 	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
% 	'gswdro_s16-c-post.img';...	
% 	'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
% 	'gswdro_s04-c-normal.img'};
% files2		= {'gswdro_s06-v-pre.img';'gswdro_s08-v-pre.img';...
% 	'gswdro_s09-v-pre.img';'gswdro_s10-v-pre.img';...
% 	'gswdro_s11-v-pre.img';'gswdro_s12-v-pre.img';...
% 	'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
% 	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
% 	'gswdro_s16-v-post.img';...
% 	'gswdro_s01-v-normal.img';'gswdro_s02-v-normal.img';'gswdro_s03-v-normal.img';...
% 	'gswdro_s04-v-normal.img'};
% 
% [muD,sdD] = getavgdiff(files1,files2,p);
% figure(666)
% plotscan(muD,sdD,img,'pre',saveFlag)
% plotroi(p,files);
% set(gca,'YDir','reverse');
% pa_datadir;
% print('-depsc','-painter',[mfilename '1']);
% % return


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
figure(1)
plotscan(muD,sdD,img,'pre',saveFlag)
% return
plotroi(p,files);
set(gca,'YDir','reverse');
% pause;
pa_datadir;
print('-depsc','-painter',[mfilename '1']);
% return

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
figure(2)
plotscan(muD,sdD,img,'post',saveFlag)
plotroi(p,files);
set(gca,'YDir','reverse');
pa_datadir;

print('-depsc','-painter',[mfilename '2']);

%% NORMAL
files1 = {'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'};
files2 = {'gswdro_s01-v-normal.img';'gswdro_s02-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img'};
[muD,sdD] = getavgdiff(files1,files2,p);
figure(3)
plotscan(muD,sdD,img,'normal',saveFlag)
plotroi(p,files);
% pause;
set(gca,'YDir','reverse');
pa_datadir;
print('-depsc','-painter',[mfilename '3']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% POST
files1 = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
};

files2 = {'gswdro_s07-av-post.img';'gswdro_s13-av-post.img';...
	'gswdro_s14-av-post.img';'gswdro_s15-av-post.img';...
	'gswdro_s16-av-post.img';...
};
[muD,sdD] = getavgdiff(files1,files2,p);
figure(4)
plotscan(muD,sdD,img,'av',saveFlag)
plotroi(p,files);
set(gca,'YDir','reverse');
% pause;
pa_datadir;
print('-depsc','-painter',[mfilename '4']);


files1 = {'gswdro_s01-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img'};

files2 = {'gswdro_s01-av-normal.img';'gswdro_s03-av-normal.img';...
	'gswdro_s04-av-normal.img'};
[muD,sdD] = getavgdiff(files1,files2,p);
figure(5)
plotscan(muD,sdD,img,'av',saveFlag)
plotroi(p,files);
set(gca,'YDir','reverse');
% pause;
pa_datadir;
print('-depsc','-painter',[mfilename '5']);


function plotroi(p,files)
%%
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
roi_obj		= maroi(roiname);
fname		= [p files{1}];
[~,~,vXYZ]	= getdata(roi_obj, fname);
x1 = vXYZ(1,:);
y1 = vXYZ(2,:);
z1 = vXYZ(3,:);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
roi_obj		= maroi(roiname);
fname		= [p files{1}];
[~,~,vXYZ]	= getdata(roi_obj, fname);
x2 = vXYZ(1,:);
y2 = vXYZ(2,:);
z2 = vXYZ(3,:);

x = [x1 x2];
y = [y1 y2];
z = [z1 z2];

subplot(222)
hold on
X = [x; z];
[~,~,Cnt,cx,cy] = pa_countunique(X);
contour(cx,cy,Cnt,[2 100],'w','LineWidth',2);
[mx,indx] = max(Cnt(:));
text(cx(indx),cy(indx),'HG','Color','w','FontWeight','Bold','horizontalalignment','center','verticalalignment','middle');

subplot(221)
hold on
X = [y; z];
[~,~,Cnt,cx,cy] = pa_countunique(X);
contour(cx,cy,Cnt,[2 100],'w','LineWidth',2);
[mx,indx] = max(Cnt(:));
text(cx(indx),cy(indx),'HG','Color','w','FontWeight','Bold','horizontalalignment','center','verticalalignment','middle');

subplot(223)
X = [y;x];
[~,~,Cnt,cx,cy] = pa_countunique(X);
contour(cx,cy,Cnt,[2 100],'w','LineWidth',2);
[mx,indx] = max(Cnt(:));
text(cx(indx),cy(indx),'HG','Color','w','FontWeight','Bold','horizontalalignment','center','verticalalignment','middle');

%%
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
roi_obj		= maroi(roiname);
fname		= [p files{1}];
[~,~,vXYZ]	= getdata(roi_obj, fname);
x1 = vXYZ(1,:);
y1 = vXYZ(2,:);
z1 = vXYZ(3,:);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
roi_obj		= maroi(roiname);
fname		= [p files{1}];
[~,~,vXYZ]	= getdata(roi_obj, fname);
x2 = vXYZ(1,:);
y2 = vXYZ(2,:);
z2 = vXYZ(3,:);

x = [x1 x2];
y = [y1 y2];
z = [z1 z2];
subplot(222)
hold on
X = [x; z];
[~,~,Cnt,cx,cy] = pa_countunique(X);
contour(cx,cy,Cnt,[2 100],'r','LineWidth',2);
[mx,indx] = max(Cnt(:));
text(cx(indx),cy(indx),'STG','Color','r','FontWeight','Bold','horizontalalignment','center','verticalalignment','middle');


subplot(221)
hold on
X = [y; z];
[~,~,Cnt,cx,cy] = pa_countunique(X);
contour(cx,cy,Cnt,[2 100],'r','LineWidth',2);
[mx,indx] = max(Cnt(:));
text(cx(indx),cy(indx),'STG','Color','r','FontWeight','Bold','horizontalalignment','center','verticalalignment','middle');

subplot(223)
X = [y;x];
[~,~,Cnt,cx,cy] = pa_countunique(X);
contour(cx,cy,Cnt,[2 100],'r','LineWidth',2);
[mx,indx] = max(Cnt(:));
text(cx(indx),cy(indx),'STG','Color','r','FontWeight','Bold','horizontalalignment','center','verticalalignment','middle');

%%
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
roi_obj		= maroi(roiname);
fname		= [p files{1}];
[~,~,vXYZ]	= getdata(roi_obj, fname);
x1 = vXYZ(1,:);
y1 = vXYZ(2,:);
z1 = vXYZ(3,:);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
roi_obj		= maroi(roiname);
fname		= [p files{1}];
[~,~,vXYZ]	= getdata(roi_obj, fname);
x2 = vXYZ(1,:);
y2 = vXYZ(2,:);
z2 = vXYZ(3,:);

x = [x1 x2];
y = [y1 y2];
z = [z1 z2];

subplot(222)
hold on
X = [x; z];
[~,~,Cnt,cx,cy] = pa_countunique(X);
contour(cx,cy,Cnt,[2 100],'k','LineWidth',2);
[mx,indx] = max(Cnt(:));
text(cx(indx),cy(indx),'CS','Color','k','FontWeight','Bold','horizontalalignment','center','verticalalignment','middle');


subplot(221)
hold on
X = [y; z];
[~,~,Cnt,cx,cy] = pa_countunique(X);
contour(cx,cy,Cnt,[2 100],'k','LineWidth',2);
[mx,indx] = max(Cnt(:));
text(cx(indx),cy(indx),'CS','Color','k','FontWeight','Bold','horizontalalignment','center','verticalalignment','middle');

subplot(223)
X = [y;x];
[~,~,Cnt,cx,cy] = pa_countunique(X);
contour(cx,cy,Cnt,[2 100],'k','LineWidth',2);
[mx,indx] = max(Cnt(:));
text(cx(indx),cy(indx),'CS','Color','k','FontWeight','Bold','horizontalalignment','center','verticalalignment','middle');



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
muD		= squeeze(nanmean(IMG,4));
sdD		= squeeze(nanstd(IMG,[],4));

function  D = getdiff(nii1,nii2)
threshd		= 40;
IMG1		= nii1.img;
IMG2		= nii2.img;

% IMG2(IMG2<threshd)  = NaN;
% IMG1(IMG1<threshd)  = NaN;
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
clf
colormap hot
imgthresh = 1;
for ii = 1:3
	subplot(2,2,ii)
	x = squeeze(nanmean(img,ii))';
			if ii==3
			x=x';
		end
	subimage(x,gray(100))
	set(gca,'YDir','normal');
	hold on
	
	x = muD;
	x(x<1*sdD) = NaN;
% 	x(x<1) = NaN;

% 	x	= squeeze(nansum(x,ii))';
% 	x   = 50*x/max(x(:));
	x	= squeeze(nanmean(x,ii))';
	x(x<=imgthresh) = NaN;
	if any(~isnan(x(:)))
		if ii==3
			x=x';
		end
		contourf(x,imgthresh:.1:15);
		shading flat;
		colorbar;
		caxis([imgthresh 15])
		title(nanmean(sdD(~isnan(x))))
		
		N = nansum(x);
		N = 30*N./max(N)+1;
% 		whos N
% 		plot(N,'w')
	end
	set(gca,'XTick',0:20:100,'YTick',0:20:100);
	
end
if saveFlag
	pa_datadir;
	print('-depsc','-painter',[mfilename '-' group]);
end
% pause