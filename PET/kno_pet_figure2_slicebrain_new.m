function kno_pet_figure2_slicebrain_new

% KNO_PET_FIGURE2
%
% Produce figure 2
% L.V. Straatman1, M.M. van Wanrooij1,2, L.F. de Geus-Oei3, E.P. Visser3, A.F.M. Snik1, J.J.S. Mulder1
%

%% Cleansing
close all
clear all
warning off;
p					= 'E:\Backup\Nifti\';
cd(p)

[N,T,R] = xlsread('subjectdates.xlsx');

% keyboard

indx = 1:5:61;
nindx = numel(indx);


%%
id = N(:,1);
dates = T(2:end,10:14);
ndates =  size(dates,2);
nsub = numel(id);
for ii = 1:nsub
	for jj = 1:ndates
		dat = dates{ii,jj};
		if ~isempty(dat) && ~strcmp(dat,'XXX');
			c = datevec(dat,'dd-mm-yyyy');
			fname = ['gwro_s' num2str(id(ii),'%07i') '-d' num2str(c(1),'%04i') num2str(c(2),'%02i') num2str(c(3),'%02i') '-mPET.img'];
			nii = load_nii(fname,[],[],1);
			data(ii,jj).nii = nii;
		end
		
	end
end

clear N
IMG = 0;
n	= 0;
for ii = 6:nsub
	img = data(ii,1).nii;
	if ~isempty(img)
		img = img.img;
		sel = isnan(img);
		img(sel)=0;
		n = n+~sel;
		IMG = IMG+img;
	end
	
end
IMG = IMG./n;
prec = [];
for ii = 1:nindx
	img1	= squeeze(IMG(:,:,indx(ii)));
	prec	= [prec;img1];
end
N(1) = max(n(:));

IMG = 0;
n	= 0;
for ii = 6:nsub
	img = data(ii,2).nii;
	if ~isempty(img)
		img = img.img;
		sel = isnan(img);
		img(sel)=0;
		n = n+~sel;
		IMG = IMG+img;
	end
	
end
IMG = IMG./n;
prev = [];
for ii = 1:nindx
	img1	= squeeze(IMG(:,:,indx(ii)));
	prev	= [prev;img1];
end
N(2) = max(n(:));

IMG = 0;
n	= 0;
for ii = 6:nsub
	img = data(ii,4).nii;
	if ~isempty(img)
		img = img.img;
		sel = isnan(img);
		img(sel)=0;
		n = n+~sel;
		IMG = IMG+img;
	end
	
end
IMG = IMG./n;
postc = [];
for ii = 1:nindx
	img1	= squeeze(IMG(:,:,indx(ii)));
	postc	= [postc;img1];
end
N(3) = max(n(:));

IMG = 0;
n	= 0;
for ii = 6:nsub
	img = data(ii,5).nii;
	if ~isempty(img)
		img = img.img;
		sel = isnan(img);
		img(sel)=0;
		n = n+~sel;
		IMG = IMG+img;
	end
	
end
IMG = IMG./n;
postv = [];
for ii = 1:nindx
	img1	= squeeze(IMG(:,:,indx(ii)));
	postv	= [postv;img1];
end
N(4) = max(n(:));

IMG = 0;
n	= 0;
for ii = 6:nsub
	img = data(ii,3).nii;
	if ~isempty(img)
		img = img.img;
		sel = isnan(img);
		img(sel)=0;
		n = n+~sel;
		IMG = IMG+img;
	end
	
end
IMG = IMG./n;
postav = [];
for ii = 1:nindx
	img1	= squeeze(IMG(:,:,indx(ii)));
	postav	= [postav;img1];
end
N(5) = max(n(:));


%% Normal-hearing
nhindx = 1:5;
IMG = 0;
n	= 0;
for ii = nhindx(2:5)
	img = data(ii,1).nii;
	if ~isempty(img)
		img = img.img;

		sel = isnan(img);
		img(sel)=0;
		n = n+~sel;
		IMG = IMG+img;
	end
	
end
IMG = IMG./n;
nhc = [];
for ii = 1:nindx
	img1	= squeeze(IMG(:,:,indx(ii)));
	nhc	= [nhc;img1];
end
N(6) = max(n(:));


IMG = 0;
n	= 0;
for ii = nhindx
	img = data(ii,2).nii;
	if ~isempty(img)
		img = img.img;
		sel = isnan(img);
		img(sel)=0;
		n = n+~sel;
		IMG = IMG+img;
	end
	
end
IMG = IMG./n;
nhv = [];
for ii = 1:nindx
	img1	= squeeze(IMG(:,:,indx(ii)));
	nhv	= [nhv;img1];
end
N(7) = max(n(:));

IMG = 0;
n	= 0;
for ii = nhindx
	img = data(ii,3).nii;
	if ~isempty(img)
		img = img.img;
		whos img
		
		sel = isnan(img);
		img(sel)=0;
		n = n+~sel;
		IMG = IMG+img;
	end
	
end
IMG = IMG./n;
nhav = [];
for ii = 1:nindx
	img1	= squeeze(IMG(:,:,indx(ii)));
	nhav	= [nhav;img1];
end
N(8) = max(n(:));

%% Combine
pet(1).img = prec;
pet(2).img = prev;
pet(3).img = postc;
pet(4).img = postv;
pet(5).img = postav;
pet(6).img = nhc;
pet(7).img = nhv;
pet(8).img = nhav;

%% Graphics
figure(1)
clf
colormap bone

x		= double(repmat(nhc,1,7));
subimage(x',bone(100))
set(gca,'YDir','normal');
hold on


percthresh	= 10;
diffthresh = 60;
sel			= nhc<diffthresh;
nhc(sel)	= NaN;
Y = [];
for ii = [8 7 5 4 3 2 1]
	img2 = pet(ii).img;
	sel			= img2<diffthresh;
	img2(sel)	= NaN;
	
	y			= (img2-nhc)./nhc*100;
	y(y<=percthresh & y>=-percthresh) = NaN;
	
	Y = [Y y];	 %#ok<*AGROW>
end
colormap hot;

contourf(Y',percthresh:55);
shading flat;
hold on
caxis([percthresh 55])
colorbar

% contourf(Y',-25:-percthresh);
% shading flat;
% hold on
% caxis([-25 -percthresh])
% colorbar

% contourf(Y',-40:5:40);
% shading flat;
% hold on
% caxis([-40 40])
% colorbar

% title(N')


axis equal;

% plotroi(p,fname,indx,nindx);


% hot = [24.0 63.0 28.0];
% x = 5*79+hot(1);
% y = hot(2)+95*(1:6);
% plot(x,y,'ko','MarkerFaceColor','w');

%%
	for ii = 1:nindx
		str = round((indx(ii))*2)-52;
		str = num2str(str);
				text((ii-1)*79+79/2,3*95,str,'Color','w','HorizontalAlignment','center');
	end
%%

axis off
pa_datadir;
print('-depsc','-painter',mfilename)


%%
	%%
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
'E:\DATA\KNO\PET\marsbar-aal\MNI_Lingual_R_roi';...
	'E:\DATA\KNO\PET\marsbar-aal\MNI_Lingual_L_roi';...
'E:\DATA\KNO\PET\marsbar-aal\MNI_Occipital_Inf_L_roi';...
	'E:\DATA\KNO\PET\marsbar-aal\MNI_Occipital_Inf_R_roi';...
'E:\DATA\KNO\PET\marsbar-aal\MNI_Occipital_Mid_L_roi';...
	'E:\DATA\KNO\PET\marsbar-aal\MNI_Occipital_Mid_R_roi';...
'E:\DATA\KNO\PET\marsbar-aal\MNI_Occipital_Sup_L_roi';...
	'E:\DATA\KNO\PET\marsbar-aal\MNI_Occipital_Sup_R_roi';...
'E:\DATA\KNO\PET\marsbar-aal\MNI_Thalamus_L_roi';...
'E:\DATA\KNO\PET\marsbar-aal\MNI_Thalamus_R_roi';...
'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Mid_R_roi.mat';...
	'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Mid_L_roi.mat';...
'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Inf_R_roi.mat';...
	'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Inf_L_roi.mat';...	
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
col = jet(nroi);
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
			for jj = 1:7
				plot(x(k)+(ii-1)*79,y(k)+(jj-1)*95,'w-','LineWidth',1);
% 				plot(x(k)+(ii-1)*79,y(k)+(jj-1)*95-1,'k-','LineWidth',1);
				plot(x(k)+(ii-1)*79,y(k)+(jj-1)*95-1,'-','LineWidth',1,'Color',col(kk,:));
			end
		end
	end
end
