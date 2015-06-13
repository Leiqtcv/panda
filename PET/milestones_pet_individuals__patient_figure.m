function milestones_pet_individuals_figure

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

sub = '4549835';
fnamec		= ['gswro_s' sub '-d20100127-mPET.img'];
fnamev		= ['gswro_s' sub '-d20100129-mPET.img'];
fnameav		= ['gswro_s' sub '-d20100125-mPET.img'];

% sub = '7437191';
% fnamec		= ['gswro_s' sub '-d20080923-mPET.img'];
% fnamev		= ['gswro_s' sub '-d20080922-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20080922-mPET.img']; % == VISUAL

% sub = '4433787';
% fnamec		= ['gswro_s' sub '-d20080924-mPET.img'];
% fnamev		= ['gswro_s' sub '-d20080922-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20080923-mPET.img']; 


% sub = '0135401';
% fnamec		= ['gswro_s' sub '-d20081016-mPET.img'];
% fnamev		= ['gswro_s' sub '-d20081023-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20081030-mPET.img'];

% sub = '1327210'; % No existe
% fnamec		= ['gswro_s' sub '-d20081126-mPET.img'];
% fnamev		= ['gswro_s' sub '-d20081126-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20081125-mPET.img'];

sub = '9909194';
fnamec		= ['gswro_s' sub '-d20081009-mPET.img'];
fnamev		= ['gswro_s' sub '-d20081007-mPET.img'];
fnamec2		= [];
fnamev2		= [];
fnameav		= [];

sub = '5315951';
fnamec2		= ['gswro_s' sub '-d20081030-mPET.img'];
fnamev2		= ['gswro_s' sub '-d20081023-mPET.img'];
fnamec		= [];
fnamev		= [];
fnameav		= ['gswro_s' sub '-d20081028-mPET.img'];

% 13-7-2009	14-7-2009			14-11-2011
sub = '5557469';
fnamec		= ['gswro_s' sub '-d20090713-mPET.img'];
fnamev		= ['gswro_s' sub '-d20090714-mPET.img'];
fnamec2		= [];
fnamev2		= [];
fnameav		= ['gswro_s' sub '-d20111114-mPET.img'];

% 11-4-2008	10-4-2008		16-6-2010	23-7-2009
sub = '5526880';
fnamec		= ['gswro_s' sub '-d20080411-mPET.img'];
fnamev		= ['gswro_s' sub '-d20080410-mPET.img'];
fnamev2		= [];
fnamec2		= ['gswro_s' sub '-d20100617-mPET.img'];
fnameav		= [];

% 9-7-2008	15-7-2008	24-3-2010	7-4-2010	22-3-2010
sub = '4540719';
fnamec		= ['gswro_s' sub '-d20080709-mPET.img'];
fnamev		= ['gswro_s' sub '-d20080715-mPET.img'];
fnamec2		= ['gswro_s' sub '-d20100407-mPET.img'];
fnamev2		= ['gswro_s' sub '-d20100322-mPET.img'];
fnameav		= ['gswro_s' sub '-d20100324-mPET.img'];

% 7540722	PRE	female	22-8-2008		15	23-2-1981	174	87	10-7-2008	14-7-2008					126	133			
sub = '7540722';
fnamec		= ['gswro_s' sub '-d20080710-mPET.img'];
fnamev		= ['gswro_s' sub '-d20080714-mPET.img'];
fnamec2		= [];
fnamev2		= [];
fnameav		= [];

% 5512113	PRE, POST	female	19-9-2008	Right	15	14-6-1986	167	65	29-7-2008	22-7-2008	7-5-2010	11-5-2010	17-3-2010	Nucleus	122	123	123	134	118
sub = '5512113';
fnamec		= ['gswro_s' sub '-d20080729-mPET.img'];
fnamev		= ['gswro_s' sub '-d20080722-mPET.img'];
fnamec2		= ['gswro_s' sub '-d20100511-mPET.img'];
fnamev2		= ['gswro_s' sub '-d20100317-mPET.img'];
fnameav		= ['gswro_s' sub '-d20100507-mPET.img'];
% fnameav		= [];

% % 2369736	POST	female	9-2-2008	Left	63	15-4-1964	XXX	XXX			26-3-2012	29-3-2012	20-3-2012	Advanced Bionics, 90k Helix			126	126	126
% sub = '2369736';
% fnamec		= [];
% fnamev		= [];
% fnamec2		= ['gswro_s' sub '-d20120329-mPET.img'];
% fnamev2		= ['gswro_s' sub '-d20120320-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20120326-mPET.img'];
% 
% % 2859436	POST	female	16-11-2008	Right	85	21-8-1988	XXX	XXX			14-2-2012	13-2-2012	17-2-2012	Cochlear freedom Contour Advance			122	112	127
% sub = '2859436';
% fnamec		= [];
% fnamev		= [];
% fnamec2		= ['gswro_s' sub '-d20120213-mPET.img'];
% fnamev2		= ['gswro_s' sub '-d20120217-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20120214-mPET.img'];
% 
% % 1468337	POST	female	29-9-2008	Right	35	11-2-1965	XXX	XXX			30-5-2012	13-6-2012	6-6-2012	Advanced Bionics: 90k Helix 			XXX	XXX	XXX
% sub = '1468337';
% fnamec		= [];
% fnamev		= [];
% fnamec2		= ['gswro_s' sub '-d20120606-mPET.img'];
% fnamev2		= ['gswro_s' sub '-d20120613-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20120530-mPET.img'];
% 
% % 5834795	POST	female	XXX	Right	85	XXX	XXX	XXX			16-3-2012	13-4-2012	23-3-2012	XXX			123	122	123
% sub = '5834795';
% fnamec		= [];
% fnamev		= [];
% fnamec2		= ['gswro_s' sub '-d20120413-mPET.img'];
% fnamev2		= ['gswro_s' sub '-d20120323-mPET.img'];
% fnameav		= ['gswro_s' sub '-d20120316-mPET.img'];


fnames = {fnamec fnamev fnamec2 fnamev2 fnameav};


colormap bone
indx = 1:5:66;
nindx = numel(indx);

% if ~isempty(fnamec)
for ii = 1:5
	fname = fnames{ii};
	if ~isempty(fname)
		nii		= load_nii(fname,[],[],1);
		img = nii.img;
	else
		img = zeros(79,95,68);
	end
	IMG = [];
	for jj = 1:nindx
		tmp = squeeze(img(:,:,indx(jj)));
		IMG = [IMG;tmp];
	end
	pet(ii).img = IMG;
end




%% Graphics
figure(1)
clf

% x		= double(repmat(pet(1).img,1,4));
x = double([pet(5:-1:1).img]);
subimage(x',bone(100))
set(gca,'YDir','normal');
hold on


percthresh	= 10;
diffthresh = 60;
if ~isempty(fnames{1})
img1 = pet(1).img;
else
	img1 = pet(3).img;
end
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

contourf(Y',percthresh:30);
shading flat;
hold on


caxis([percthresh 30]);
colorbar
axis equal
title(sub);

% plotroi(p,fnamec,indx,nindx);

for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,95,str,'Color','w','HorizontalAlignment','center');
end

axis off

pa_datadir;
print('-depsc','-painter',[sub mfilename])

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
col = gray(nroi);
names = {'HG','HG','STG','STG','CS','CS'};
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
			for jj = 1:4
% 				plot(x(k)+(ii-1)*79,y(k)+(jj-1)*95,'w-','LineWidth',1);
				% 				plot(x(k)+(ii-1)*79,y(k)+(jj-1)*95-1,'k-','LineWidth',1);
% 				plot(x(k)+(ii-1)*79,y(k)+(jj-1)*95-1,'-','LineWidth',1,'Color',col(kk,:));
				
				text(mean(x(k))+(ii-1)*79,mean(y(k))+(jj-1)*95-1,names{kk},'Color','k','HorizontalAlignment','center');
				
			end
		end
	end
end
