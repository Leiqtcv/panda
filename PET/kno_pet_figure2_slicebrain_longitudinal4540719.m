function kno_pet_figure2_slicebrain_longitudinal4540719

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

fnamecpre		= 'gwro_s4540719-d20080709-mPET.img';
fnamevpre		= 'gwro_s4540719-d20080715-mPET.img';
fnamecpost		= 'gwro_s4540719-d20100407-mPET.img';
fnamevpost		= 'gwro_s4540719-d20100322-mPET.img';
fnameavpost		= 'gwro_s4540719-d20100324-mPET.img';

colormap bone
indx = 1:5:66;
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

disp('-----------');
mean(img1(:))
mean(img2(:))
mean(img3(:))
mean(img4(:))
mean(img5(:))

pet(1).img = img1;
pet(2).img = img2;
pet(3).img = img3;
pet(4).img = img4;
pet(5).img = img5;

%% Graphics
figure(1)
clf
x		= double(repmat(img1,1,4));
x = x/max(x(:))*130;
subimage(x',bone(100))
set(gca,'YDir','normal');
hold on

percthresh	= 15;
diffthresh = 65;
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
colormap jet;
% contourf(Y',percthresh:1:30);
% shading flat;
% caxis([percthresh/2 30]);

% contourf(Y',percthresh:35);
contourf(Y',[-35:5:-percthresh percthresh:5:35]);
% shading flat;
hold on


caxis([-35 35]);
colorbar
axis equal
title(fnamecpre);

pa_datadir;
print('-depsc','-painter',mfilename)