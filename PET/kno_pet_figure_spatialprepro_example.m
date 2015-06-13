close all

colormap bone
cd('E:\Backup\Nifti')
subname = 's5315951-d20081023-mPET';
subname = 's0135401-d20081016-mPET';
subname = 's1468337-d20120530-mPET';
subname = 's4433787-d20080922-mPET';
% subname = pa_fcheckexist([]);
indx = 5:5:50;
indx2 = 5:5:65;
nindx = numel(indx);
nindx2 = numel(indx2);
fname	= [subname '.hdr'];
niiPET	= load_nii(fname,[],[],1);
PET		= niiPET.img;
whos PET
IMG  = [];
for ii = 1:nindx
	img1	= squeeze(PET(:,:,indx(ii)));
	IMG = [IMG;img1];
end
img1 = IMG;


fname	= ['o_' subname '.hdr'];
niiPET	= load_nii(fname,[],[],1);
PET		= niiPET.img;
IMG  = [];
for ii = 1:nindx
	img2	= squeeze(PET(:,:,indx(ii)));
	IMG = [IMG;img2];
end
img2 = IMG;

fname	= ['ro_' subname '.hdr'];
niiPET	= load_nii(fname,[],[],1);
PET		= niiPET.img;
IMG  = [];
for ii = 1:nindx
	img3	= squeeze(PET(:,:,indx(ii)));
	IMG = [IMG;img3];
end
img3 = IMG;



fname	= ['wro_' subname '.hdr'];
niiPET	= load_nii(fname,[],[],1);
PET		= niiPET.img;
IMG  = [];
for ii = 1:nindx2
	img4	= squeeze(PET(:,:,indx2(ii)));
	IMG = [IMG;img4];
end
img4 = IMG;



fname	= ['gswro_' subname '.hdr'];
niiPET	= load_nii(fname,[],[],1);
PET		= niiPET.img;
IMG  = [];
for ii = 1:nindx2
	img5	= squeeze(PET(:,:,indx2(ii)));
	IMG = [IMG;img5];
end
img5 = IMG;
% img1 = [img1 img3];
% img4 = [img4 img5];
img4 = img5;
subplot(211)
imagesc(img1');
axis equal
colorbar
for ii = 1:nindx
	x = ii*128-128/2;
	text(x,-10,num2str(indx(ii)),'HorizontalAlignment','center');
	x =  ii*128;
% 	pa_verline(x);
end
axis off

subplot(212)
imagesc(img4');
axis equal
colorbar
for ii = 1:nindx2
	x = ii*79-79/2;
	text(x,-10,num2str(indx2(ii)),'HorizontalAlignment','center');
	x =  ii*79;
% 	pa_verline(x);
end
axis off
title(subname);


pa_datadir

figure(1)
print('-depsc','-painter',mfilename)

