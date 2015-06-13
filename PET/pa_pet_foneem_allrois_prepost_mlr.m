function pa_pet_foneem_allrois_prepost_mlr
%% Initialization
close all force hidden
clear all
warning off;
%%
files1		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	};
% [Gc,GEc,nc] = getdat(files);
files2 = {'gswdro_s06-v-pre.img';'gswdro_s08-v-pre.img';...
	'gswdro_s09-v-pre.img';'gswdro_s10-v-pre.img';...
	'gswdro_s11-v-pre.img';'gswdro_s12-v-pre.img';...
	};
subject		= [6 8 9 10 11 12];
getdat(files1,files2,subject);
return
%% Post
files1 = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
files2 = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	};
subject		= [7 13 14 15 16];
 getdat(files1,files2,subject);

function [Gmu,GEmu,namesmu] = getdat(files1,files2,subject)
cd('E:\DATA\KNO\PET\marsbar-aal');
d			= dir('*.mat');
roinames	= {d.name};
n			= numel(roinames);
names		= roinames;
side		= NaN(1,n);
for ii = 1:n
	 name	= roinames{ii};
	 name	= name(5:end-8);
	 indx	= strfind(name,'_');
	 name(indx) = ' ';
	 if strcmp(name(end),'L')
		 side(ii) = 1;
	 elseif strcmp(name(end),'R')
		 side(ii) = 2;
	 else side(ii) = 0;
	 end
	 
	 names{ii} = name(1:end-1);
end

%%
p			= 'E:\DATA\KNO\PET\swdro files\';
F			= [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02

f			= F(subject);
[s,indx]	= sort(f);

loadFlag = false;
if~loadFlag
	MU1			= [];
	MU2			= [];
	for ii = 1:n
		roiname		= roinames{ii};
		mu1			= pa_pet_getmeandata(files1,p,roiname);
		MU1			= [MU1 mu1];
		mu2			= pa_pet_getmeandata(files2,p,roiname);
		MU2			= [MU2 mu2];
	end
	cd(p);
	foneem = f;
	save('petmean','MU1','MU2','names','foneem');
else
	cd(p)
	load('petmean')
end
%%
t = MU2(indx,:)-MU1(indx,:);
% t = MU1(indx,:);

% t = bsxfun(@minus, t, mean(t));
% t = bsxfun(@minus, t', mean(t'))';
R = NaN(1,n);
P = R;
G = R;
GE = NaN(2,n);

keyboard

%% PCA
close all
dat = MU1';
[coefs,score] = princomp(zscore(dat));
[NDIM, PROB, CHISQUARE] = barttest(dat,0.05);

vbls = int2str(s');
figure
for ii = 1:3
	indx = ii:ii+1;
	subplot(2,2,ii)
% 	biplot(coefs(:,indx),'scores',score(:,indx),'varlabels',vbls);
% 	biplot(coefs(:,indx),'varlabels',vbls);
	biplot(coefs(:,indx));
	
	hold on
	axis square
grid off
box off
axis off	
	drawnow
end



figure
subplot(122)
indx = 1:3;
biplot(coefs(:,indx),'scores',score(:,indx),...
	'varlabels',vbls);
hold on
box on

subplot(121)
indx = 1:2;
biplot(coefs(:,indx),'scores',score(:,indx),...
	'varlabels',vbls);
% biplot(coefs(:,indx),'varlabels',vbls);
hold on
% plot([0 -0.4],[0 0.1],'b-');
% plot(-0.4,0.1,'b.');
% text(-0.39,0.12,'homo');
axis square;
grid off
box on



