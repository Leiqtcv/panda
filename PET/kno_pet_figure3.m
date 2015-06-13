function kno_pet_figure2_slicebrain_longitudinal5512113

% KNO_PET_FIGURE2
%
% Produce figure 2
% L.V. Straatman1, M.M. van Wanrooij1,2, L.F. de Geus-Oei3, E.P. Visser3, A.F.M. Snik1, J.J.S. Mulder1
%

%% Cleansing
close all
clear all
p					= 'E:\Backup\Nifti\';
cd(p)

fnamecpre		= 'gswro_s5512113-d20080729-mPET.img';
fnamevpre		= 'gswro_s5512113-d20080722-mPET.img';
fnamecpost		= 'gswro_s5512113-d20100511-mPET.img';
fnamevpost		= 'gswro_s5512113-d20100317-mPET.img';
fnameavpost		= 'gswro_s5512113-d20100507-mPET.img'; % FAKE: is really visual

% fnamecpre		= 'gswro_s5557469-d20090713-mPET.img';
% fnamevpre		= 'gswro_s5557469-d20090714-mPET.img';
% fnamecpost		= 'gswro_s5512113-d20100511-mPET.img';
% fnamevpost		= 'gswro_s5512113-d20100317-mPET.img';
% fnameavpost		= 'gswro_s5557469-d20111114-mPET.img'; % FAKE: is really visual

colormap bone
indx = 21:5:36;
nindx = numel(indx);

nii		= load_nii(fnamecpre,[],[],1);
PETcpre	= nii.img;
nii		= load_nii(fnamevpre,[],[],1);
PETvpre	= nii.img;
nii		= load_nii(fnamecpost,[],[],1);
PETcpost = nii.img;
nii		 = load_nii(fnamevpost,[],[],1);
PETvpost = nii.img;
nii		 = load_nii(fnameavpost,[],[],1);
PETavpost = nii.img;

IMGcpre  = [];
IMGvpre = [];
IMGcpost  = [];
IMGvpost = [];
IMGavpost = [];
for ii = 1:nindx
	img1	= squeeze(PETcpre(:,:,indx(ii)));
	img2	= squeeze(PETvpre(:,:,indx(ii)));
	img3	= squeeze(PETcpost(:,:,indx(ii)));
	img4	= squeeze(PETvpost(:,:,indx(ii)));
	img5	= squeeze(PETavpost(:,:,indx(ii)));
	IMGcpre	= [IMGcpre;img1];
	IMGvpre	= [IMGvpre;img2];
	IMGcpost	= [IMGcpost;img3];
	IMGvpost	= [IMGvpost;img4];
	IMGavpost	= [IMGavpost;img5];
end
img1	= IMGcpre;
img2	= IMGvpre;
img3	= IMGcpost;
img4	= IMGvpost;
img5	= IMGavpost;

pet(1).img = img1;
pet(2).img = img2;
pet(3).img = img3;
pet(4).img = img4;
pet(5).img = img5;

%% Graphics
figure(1)
clf

x		= double(repmat(img4,1,4));
subimage(x',bone(100))
set(gca,'YDir','normal');
hold on

percthresh	= 15;
diffthresh = 60;
sel			= img1<diffthresh;
img1(sel)	= NaN;
Y = [];
for ii = 4:-1:1
	img2 = pet(ii+1).img;
	sel			= img2<diffthresh;
	img2(sel)	= NaN;
	
	y			= (img2-img1)./img1*100;
	y(y<=percthresh & y>=-percthresh) = NaN;
	
	Y = [Y y];	 %#ok<*AGROW>
end
colormap hot;
% contourf(Y',percthresh:1:30);
% shading flat;
% caxis([percthresh/2 30]);

contourf(Y',percthresh:45);
shading flat;
hold on


caxis([percthresh 45]);
colorbar
axis equal
title(fnamecpre);

plotroi(p,fnamecpre,indx,nindx);

for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,3*95,str,'Color','w','HorizontalAlignment','center');
end

axis off

pa_datadir;
print('-depsc','-painter',mfilename)

function plotroi(p,files,indx,nindx)

cd('E:\DATA\KNO\PET\marsbar-aal\');
d = dir('*.mat');
roi =  {d.name};

d = dir('MNI_Cerebelum*.mat');
roi =  {d.name};

% d = dir('MNI_Insula*.mat');
% roi =  {d.name};

%%
roi = {'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';...
	'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';...
	'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';...
	'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';...
	'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';...
	'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';

	};

% MNI_Occipital_Sup_L_roi

% roi = {'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';...
% 	'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';...
% 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Mid_R_roi.mat';...
% 	'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Mid_L_roi.mat';...
% 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Inf_R_roi.mat';...
% 	'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Inf_L_roi.mat';...
% 	};

% roi = {'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';...
% 	'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';...
% 	'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';...
% 	'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';...
% };
nroi = numel(roi);
col = gray(nroi);
names = {'HG','HG','STG','STG','CS','CS'};
for kk = 1:nroi
	roiname		= roi{kk};
	roi_obj		= maroi(roiname);
	% 	keyboard
	fname		= [p files];
	[~,~,vXYZ]	= getdata(roi_obj, fname);
	x1 = vXYZ(1,:);
	y1 = vXYZ(2,:);
	z1 = vXYZ(3,:);
	
	for ii = 1:nindx
		sel = z1==indx(ii);
		if sum(sel)>3
			sum(sel)
			x = x1(sel);
			y = y1(sel);
			% 			contour(x,y);
			k = convhull(x,y);
			for jj = 1:4
% 				plot(x(k)+(ii-1)*79,y(k)+(jj-1)*95,'w-','LineWidth',1);
				% 				plot(x(k)+(ii-1)*79,y(k)+(jj-1)*95-1,'k-','LineWidth',1);
% 				plot(x(k)+(ii-1)*79,y(k)+(jj-1)*95-1,'-','LineWidth',1,'Color',col(kk,:));
				
				text(mean(x(k))+(ii-1)*79,mean(y(k))+(jj-1)*95-1,names{kk},'Color','k','HorizontalAlignment','center');
				
			end
		end
	end
end
