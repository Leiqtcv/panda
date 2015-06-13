close all hidden
clear all hidden

colormap bone; % The colormap for the PET scans
cd('E:\Backup\Nifti'); % data directory
subname = 's5315951-d20081023-mPET';
% subname = 's0135401-d20081016-mPET';
% subname = 's1468337-d20120530-mPET';
subname = 's4433787-d20080922-mPET'; % subject

indx	= 9:3:46; % original slices
indx2	= 1:5:65; % evetual MNI-normalized slices
nindx	= numel(indx);
nindx2	= numel(indx2);
fname	= [subname '.hdr'];

%% Original scan
niiPET	= load_nii(fname,[],[],1);
PET		= niiPET.img;
IMG  = [];
for ii = 1:nindx
	img1	= squeeze(PET(:,:,indx(ii)));
	img1 = img1(50:end-33,42:end-33);
	IMG		= [IMG;img1]; %#ok<*AGROW>
	nimg = size(img1,1);
end
img1 = IMG;


%% Scan origin adjusted
fname	= ['o_' subname '.hdr'];
niiPET	= load_nii(fname,[],[],1);
PET		= niiPET.img;
IMG  = [];
for ii = 1:nindx
	img2	= squeeze(PET(:,:,indx(ii)));
	IMG = [IMG;img2];
end
img2 = IMG;


%% Scan realigned
fname	= ['ro_' subname '.hdr'];
niiPET	= load_nii(fname,[],[],1);
PET		= niiPET.img;
IMG  = [];
for ii = 1:nindx
	img3	= squeeze(PET(:,:,indx(ii)));
	IMG = [IMG;img3];
end
img3 = IMG;


%% Scan normalized to MNI
fname	= ['wro_' subname '.hdr'];
niiPET	= load_nii(fname,[],[],1);
PET		= niiPET.img;
IMG  = [];
for ii = 1:nindx2
	img4	= squeeze(PET(:,:,indx2(ii)));
	IMG = [IMG;img4];
end
img4 = IMG;


%% Scan global mean removed
fname	= ['gswro_' subname '.hdr'];
niiPET	= load_nii(fname,[],[],1);
PET		= niiPET.img;
IMG		= [];
for ii	= 1:nindx2
	img5	= squeeze(PET(:,:,indx2(ii)));
	IMG		= [IMG;img5];
end
img5 = IMG;

%% Plot
subplot(211)
imagesc(img1');
axis equal
c = colorbar;
caxis([0 12000])
set(c,'YTick',[0 5000 10000 15000]);
axis off

for ii = 1:nindx
	x = ii*nimg-nimg/2;
	str = round((indx(ii))*3);
	str = num2str(str);
	text(x,-10,str,'HorizontalAlignment','center');
end

%
% subplot(212)
% imagesc([img1';img2';img3']);
% axis equal
% c = colorbar;
% caxis([0 10000])
% set(c,'YTick',[0 5000 10000 15000]);
% axis off

subplot(212)
imagesc(img5');
axis equal
c = colorbar;
caxis([0 120])
set(c,'YTick',[0 50 100 150]);
for ii = 1:nindx2
	x = ii*79-79/2;
	str = round((indx2(ii))*2)-52;
	str = num2str(str);
	text(x,-10,str,'HorizontalAlignment','center');
	x =  ii*79;
	% 	pa_verline(x);
end
axis off
title(subname(2:8));


%% Print
pa_datadir;
print('-depsc','-painter',mfilename)

