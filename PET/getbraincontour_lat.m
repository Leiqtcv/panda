function imgflat = getbraincontour_lat

% Default
[~,img,~,~,p,fname] = getdefimg;



%% Data
pa_datadir;
load('petancova')
% [roi,uroi,nroi] = getroi(data);

%% Get roi
roifiles	= [data.roi];
nroi = numel(roifiles);
img			= roicolourise(p,fname,roifiles,zeros(size(img)));
%%
[m1,m2,m3] = size(img);
imgflat = zeros([m2,m3]);
for ii = 1:m2
	for jj = 1:m3
		tmp = squeeze(img(:,ii,jj));
		indx = find(tmp,1);
		if ~isempty(indx)
			imgflat(ii,jj) = tmp(indx);
			% 		imgflat(ii,jj) = mode(tmp(tmp>0));
		end
	end
end
% 		F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
% imgflat = conv2(double(imgflat),F,'same');

if nargout<1
	close all
	col = hsv(nroi);
	Z = fliplr(imgflat');
	imagesc(Z)
	set(gca,'YDir','normal');
	axis equal
	colormap(col)
end



function [col,img,indx,nindx,p,fname] = getdefimg
col		= pa_statcolor(100,[],[],[],'def',8);
if exist('E:\','dir')
	p		= 'E:\Backup\Nifti\';
else
	p = 'C:\DATA\KNO\PET\Nifti\';
end
fname	= 'gswro_s5834795-d20120323-mPET.img';

cd('E:\Backup\PET\Misc\Default')
fname = 'T1.nii';
nii		= load_nii([p fname],[],[],1);
img		= nii.img;
indx	= 1:5:61;
nindx	= numel(indx);

function img = roicolourise(p,files,roi,img)
cd('E:\DATA\KNO\PET\marsbar-aal\');
nroi = numel(roi);
for kk = 1:nroi
	roiname		= roi{kk};
	roi_obj		= maroi(roiname);
	fname		= [p files];
	[~,~,vXYZ]	= getdata(roi_obj, fname);
	x1 = vXYZ(1,:);
	y1 = vXYZ(2,:);
	z1 = vXYZ(3,:);
	for zIndx = 1:length(z1)
		img(x1(zIndx),y1(zIndx),z1(zIndx)) = kk;
	end
end
