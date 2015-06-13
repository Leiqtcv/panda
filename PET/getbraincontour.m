function getbraincontour
close all

% Default
[~,img,indx,nindx,p,fname] = getdefimg;



%% Data
pa_datadir;
load('petancova')
% [roi,uroi,nroi] = getroi(data);

roifiles	= [data.roi];
img			= roicolourise(p,fname,roifiles,ones(length(roifiles),1),zeros(size(img)));
IMG			= [];
IMGr = [];
for zIndx = 1:nindx
	tmp		= squeeze(img(:,:,indx(zIndx)));
	IMG		= [IMG;tmp];
	tmp = tmp((ceil(79/2)+2):end,:);
	IMGr	= [IMGr;tmp];
end
braincontour = IMG;
bcright = IMGr;
% pa_datadir
% save braincontour braincontour bcright

		contour(repmat(braincontour',1,1),1,'k');

axis equal
box off
set(gca,'TickDir','out');

keyboard
%%

%%

function [col,img,indx,nindx,p,fname] = getdefimg
col		= pa_statcolor(100,[],[],[],'def',8);
if exist('E:\','dir')
	p		= 'E:\Backup\Nifti\';
else
	p = 'C:\DATA\KNO\PET\Nifti\';
end
fname	= 'gswro_s5834795-d20120323-mPET.img';
nii		= load_nii([p fname],[],[],1);
img		= nii.img;
indx	= 1:5:61;
nindx	= numel(indx);

function [img,indx] = roicolourise(p,files,roi,bf,img)
cd('E:\DATA\KNO\PET\marsbar-aal\');
nroi = numel(roi);
bf	= -log(bf);

% bf = round(bf/max(bf)*50)+50;
% 1-3-10-30-100
% No - Anecdotal - Moderate - Strong - Very - Extreme
levels	= log([1/100 1/100 1/30 1/10 1/3 1 3 10 30 100 100]);

nlevels = numel(levels);
% x		= repmat(bf,1,nlevels);
% x		= abs(bsxfun(@minus,x,levels));
% [~,indx] = min(x,[],2);

% n = numel(bf);
x = NaN(size(bf));
for ii = 2:nlevels-1
	sel = bf>=levels(ii) & bf<levels(ii+1);
	x(sel) = ii;
end
sel		= bf<levels(1);
x(sel)	= 1;
sel		= bf>=levels(end);
x(sel)	= nlevels;
indx	= x;
% indx = round(bf/max(bf)*50)+50;
for kk = 1:nroi
	roiname		= roi{kk};
	roi_obj		= maroi(roiname);
	fname		= [p files];
	[~,~,vXYZ]	= getdata(roi_obj, fname);
	x1 = vXYZ(1,:);
	y1 = vXYZ(2,:);
	z1 = vXYZ(3,:);
	for zIndx = 1:length(z1)
		img(x1(zIndx),y1(zIndx),z1(zIndx)) = indx(kk);
	end
end
