function getbraincontour
close all

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
		end
	end
end

%%
V = imgflat;
X = 1:m2;
X = X';
Y = 1:m3;
% m =1090;
% n = 910;
% Xq = linspace(min(X),max(X),m)';
% Yq = linspace(min(Y),max(Y),n);
% [X,Y] = meshgrid(X,Y);
% X = X';
% Y = Y';
% [Xq,Yq] = meshgrid(Xq,Yq);
% Xq = Xq';
% Yq = Yq';
% Vq = interp2(X',Y',V',Xq',Yq','nearest');
% Vq = Vq';

%%
close all
col = hsv(nroi);
% Z = fliplr(V');
% I = ind2rgb(Z,col);
Z = fliplr(imgflat');
imagesc(Z)
% contourf(Z)
set(gca,'YDir','normal');
axis equal
colormap(col)


return
X = (Xq')*n/m3;
Y =(Yq')*m/m2;

[X,Y] = size(Z);
X = 1:X;
Y = 1:Y;

[X,Y] = meshgrid(X,Y);
X = X';
Y = Y';
% [Xq,Yq] = meshgrid(X,Y);
% X = Xq';
% Y = Yq';

for ii = 1:nroi
	sel = Z==ii;
% 	roifiles{ii}
	x = nanmedian(X(sel));
	y = nanmedian(Y(sel));
	str = roifiles{ii};
	str = str(5:end-10);
	sel = strfind(str,'_');
	str(sel) = [' '];
	sel = strncmpi(str,'Frontal',7);
	if sum(sel)
		str = ['F'  str(8:end)];
	end
	sel = strncmpi(str,'Temporal',8);
	if sum(sel)
		str = ['T'  str(9:end)];
	end
	sel = strncmpi(str,'Occipital',9);
	if sum(sel)
		str = ['O'  str(10:end)];
	end
	sel = strncmpi(str,'Cerebelum',9);
	if sum(sel)
		str = ['C'  str(10:end)];
	end
	text(x,y,str,'Color','k','HorizontalAlignment','center');
end
pa_datadir;
% print('-depsc','-painter',[mfilename]);



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
