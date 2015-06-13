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
fnameavpost		= 'gswro_s5512113-d20100317-mPET.img'; % FAKE: is really visual

colormap bone
indx = 1:5:61;
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

percthresh	= 10;
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

contourf(Y',percthresh:55);
shading flat;
hold on


caxis([percthresh 55]);
colorbar
axis equal
title(fnamecpre);

pa_datadir;
print('-depsc','-painter',mfilename)