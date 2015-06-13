function milestones_pet_individuals_figure

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

sub = '4549835';
fnamec		= ['gswro_s' sub '-d20100127-mPET.img'];
fnamev		= ['gswro_s' sub '-d20100129-mPET.img'];
fnameav		= ['gswro_s' sub '-d20100125-mPET.img'];

% sub = '7437191';
% fnamec		= ['gswro_s' sub '-d20080923-mPET.img'];
% fnamev		= ['gswro_s' sub '-d20080922-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20080922-mPET.img']; % == VISUAL

% sub = '4433787';
% fnamec		= ['gswro_s' sub '-d20080924-mPET.img'];
% fnamev		= ['gswro_s' sub '-d20080922-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20080923-mPET.img']; 


% sub = '0135401';
% fnamec		= ['gswro_s' sub '-d20081016-mPET.img'];
% fnamev		= ['gswro_s' sub '-d20081023-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20081030-mPET.img'];

% sub = '1327210'; % No existe
% fnamec		= ['gswro_s' sub '-d20081126-mPET.img'];
% fnamev		= ['gswro_s' sub '-d20081126-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20081125-mPET.img'];

colormap bone
indx = 1:5:66;
nindx = numel(indx);

nii		= load_nii(fnamec,[],[],1);
PETc	= nii.img;
nii		= load_nii(fnamev,[],[],1);
PETv	= nii.img;
nii		 = load_nii(fnameav,[],[],1);
PETav = nii.img;

IMGc  = [];
IMGv = [];
IMGav = [];
for ii = 1:nindx
	img1	= squeeze(PETc(:,:,indx(ii)));
	img2	= squeeze(PETv(:,:,indx(ii)));
	img3	= squeeze(PETav(:,:,indx(ii)));
	IMGc	= [IMGc;img1];
	IMGv	= [IMGv;img2];
	IMGav	= [IMGav;img3];
end
img1	= IMGc;
img2	= IMGv;
img3	= IMGav;

pet(1).img = img1;
pet(2).img = img2;
pet(3).img = img3;

%% Graphics
figure(1)
clf

x		= double(repmat(img1,1,2));
subimage(x',bone(100))
set(gca,'YDir','normal');
hold on

percthresh	= 10;
diffthresh = 60;
sel			= img1<diffthresh;
img1(sel)	= NaN;
Y = [];
for ii = 2:-1:1
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

contourf(Y',percthresh:30);
shading flat;
hold on


caxis([percthresh 30]);
colorbar
axis equal
title(sub);

% plotroi(p,fnamec,indx,nindx);

for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,95,str,'Color','w','HorizontalAlignment','center');
end

axis off

pa_datadir;
print('-depsc','-painter',[sub mfilename])

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
