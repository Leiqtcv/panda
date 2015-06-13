function kno_pet_figure2_slicebrain_new_lateral

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

[N,T,R] = xlsread('subjectdates.xlsx');

% keyboard

indx = 11:5:71;
nindx = numel(indx);


%%
id = N(:,1);
clear N
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

IMG = 0;
n	= 0;
for ii = 6:nsub
	img = data(ii,1).nii;
	if ~isempty(img)
		n = n+1;
		img = img.img;
		IMG = IMG+img;
	end
	
end
IMG = IMG/n;
prec = [];
for ii = 1:nindx
	img1	= squeeze(IMG(indx(ii),:,:));
	prec	= [prec;img1];
end
N(1) = n;

IMG = 0;
n	= 0;
for ii = 6:nsub
	img = data(ii,2).nii;
	if ~isempty(img)
		n = n+1;
		img = img.img;
		IMG = IMG+img;
	end
	
end
IMG = IMG/n;
prev = [];
for ii = 1:nindx
	img1	= squeeze(IMG(indx(ii),:,:));
	prev	= [prev;img1];
end
N(2) = n;

IMG = 0;
n	= 0;
for ii = 6:nsub
	img = data(ii,4).nii;
	if ~isempty(img)
		n = n+1;
		img = img.img;
		IMG = IMG+img;
	end
	
end
IMG = IMG/n;
postc = [];
for ii = 1:nindx
	img1	= squeeze(IMG(indx(ii),:,:));
	postc	= [postc;img1];
end
N(3) = n;

IMG = 0;
n	= 0;
for ii = 6:nsub
	img = data(ii,5).nii;
	if ~isempty(img)
		n = n+1;
		img = img.img;
		IMG = IMG+img;
	end
	
end
IMG = IMG/n;
postv = [];
for ii = 1:nindx
	img1	= squeeze(IMG(indx(ii),:,:));
	postv	= [postv;img1];
end
N(4) = n;

IMG = 0;
n	= 0;
for ii = 6:nsub
	img = data(ii,3).nii;
	if ~isempty(img)
		n = n+1;
		img = img.img;
		IMG = IMG+img;
	end
	
end
IMG = IMG/n;
postav = [];
for ii = 1:nindx
	img1	= squeeze(IMG(indx(ii),:,:));
	postav	= [postav;img1];
end
N(5) = n;

pet(1).img = prec;
pet(2).img = prev;
pet(3).img = postc;
pet(4).img = postv;
pet(5).img = postav;

%% Graphics
figure(1)
clf
colormap bone

x		= double(repmat(prec,1,4));
subimage(x',bone(100))
set(gca,'YDir','normal');
hold on


percthresh	= 15;
diffthresh = 65;
sel			= prec<diffthresh;
prec(sel)	= NaN;
Y = [];
for ii = 4:-1:1
	img2 = pet(ii+1).img;
	sel			= img2<diffthresh;
	img2(sel)	= NaN;
	
	y			= (img2-prec)./prec*100;
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
caxis([percthresh 55])
colorbar
N
title(N')

axis equal;

pa_datadir;
print('-depsc','-painter',mfilename)