close all

cd('E:\Backup\Nifti')

subid = 4540719;
dat = {'20080709','20080715','20100324','20100407','20100322'};

subid = 5512113;
dat = {'20080729','20080722','20100507','20100511','20100317'};

n = numel(dat);
indx = 1:n;

IMG = [];
for ii = indx
	fname = ['s' num2str(subid) '-d' dat{ii} '-mCT.hdr'];
	nii = load_nii(fname,[],[],1);
	img = squeeze(nii.img(:,:,30));
	img = img-min(img(:))+1;
	img = log(img);
	
	IMG = [IMG;img];
end
figure(1)
colormap bone
imagesc(IMG');
axis equal
set(gca,'YDir','normal');
% axis off
title(num2str(subid));
% whos img
% for ii = indx
% 	x = ii*512-512/2;
% 	text(x,600,dat{ii},'HorizontalAlignment','center');
% end
IMG = [];
for ii = indx
	try
	fname = ['s' num2str(subid) '-d' dat{ii} '-mPET.hdr'];
	nii = load_nii(fname,[],[],1);
	img = squeeze(nii.img(:,:,30));
	sel = img<4000;
	img(sel) = NaN;

	IMG = [IMG;img];
	catch
	IMG = [IMG;NaN(size(img))];
	end
end
figure(2)
colormap hot
contour(IMG',10);
axis equal
set(gca,'YDir','normal');
% axis off
return
pa_datadir

figure(2)
print('-depsc','-painter',['PET' mfilename])

figure(1)
print('-depsc','-painter',['CT' mfilename])

return
fname = ['s' num2str(subid) '-d20080709-mPET.hdr'];
niiPET = load_nii(fname,[],[],1);


% return

PET = niiPET.img;
CT = niiCT.img;

n = size(PET,3);
colormap hot
for ii = 25
	
	figure(1)
	% 	clf
	
	img1 = squeeze(PET(:,:,ii));
	img2 = squeeze(CT(:,:,ii));
	
	figure(1)
	colormap hot
	sel = img1<5000;
	img1(sel) = NaN;
	% 	img1
	contour(img1',10);
	axis square;
	% 	shading flat
	
	figure(2)
	colormap bone
	img2 = img2-min(img2(:))+1;
	imagesc(log(img2'));
	axis square;
	title(ii)
	set(gca,'YDir','normal');
	% 	return
	drawnow
	pause(.1)
end

pa_datadir

figure(1)
print('-depsc','-painter',['PET' mfilename])

figure(2)
print('-depsc','-painter',['CT' mfilename])