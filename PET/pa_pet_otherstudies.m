function pa_pet_otherstudies
close all
clear all

theirdata;
ourdata;
ourlee2007data;
ourgreen2005data;

pa_datadir;
print('-depsc',mfilename);

function theirdata
cd('E:\DATA\KNO\PET\Others');
figure(1)
%% Green et al 2005
subplot(221)
hold on
load('Green2005-fig2.mat');
x1 = Data001(:,1);
y1 = Data001(:,2);
h1 = plot(x1,y1,'ko','MarkerFaceColor',[.8 .8 .8],'Color',[.8 .8 .8],'MarkerSize',3);
hold on

load('Green2005-fig3.mat');
x2 = Data002(:,1);
y2 = Data002(:,2);
h2 = plot(x2,y2,'ks','MarkerFaceColor',[.8 .8 .8],'Color',[.8 .8 .8],'MarkerSize',3);

axis([-10 110 -2 18]);
axis square;
box off
xlabel('Score (%)');
ylabel('[F^{18}]FDG uptake increase (%)');
title({['Green et. al. 2005, 2008:'];['18 adult postlingually-deafened CI users'];['while listening (re rest)']});
set(gca,'XTick',0:25:100);

b = regstats([y1; y2],[x1; x2]);
h = pa_regline(b.beta,'k-');
set(h,'Color',[.7 .7 .7],'LineWidth',2);

pa_text(0.9,0.1,{'HG','STG'});
% legend('A1 (Brodman 41)','AAA (Brodman 42/21/22)');
pa_text(0.05,0.95,'a');
%% Lee et al. 2001
subplot(222)
clear all
load('Lee2001-fig1.mat');
x = -Data001(:,1);
y = Data001(:,2);
plot(y,x,'ks','MarkerFaceColor',[.8 .8 .8],'Color',[.8 .8 .8],'MarkerSize',3);
axis([-10 110 -4000 500]);
axis square;
b = regstats(x,y);
h = pa_regline(b.beta,'k-');
set(h,'Color',[.7 .7 .7],'LineWidth',2);

box off
ylabel('# hypometabolic voxels (x100)');
set(gca,'YTick',-3500:500:0,'YTickLabel',(3500:-500:0)/100);
xlabel('Score (%)');
title({['Lee et. al. 2001:'];['10 prelingually deaf children during rest'];['(re normal-hearing adults)']});
set(gca,'XTick',0:25:100);
pa_text(0.1,0.1,{'STG'});
pa_text(0.05,0.95,'b');

%% Lee et al 2007a
subplot(223) 
load('Lee2007-fig3a.mat');
x1 = Data002(:,1);
y1 = Data002(:,2);
h1 = plot(x1,y1,'ko','MarkerFaceColor',[[.8 .8 .8]],'Color',[[.8 .8 .8]],'MarkerSize',3);
hold on


axis([-10 110 -12 12]);
axis square;
box off
xlabel('Score (%)');
ylabel('[F^{18}]FDG uptake (ml/dl/min)');
title({['Lee et. al. 2007: 22 prelingually-deafened children during rest']});
set(gca,'XTick',0:25:100);

b = regstats(y1,x1);
h = pa_regline(b.beta,'k-');
set(h,'Color',[.7 .7 .7],'LineWidth',2);

% legend('Left dorsolateral prefrontal');
pa_text(0.1,0.1,{'Left DL-PFC'});
pa_text(0.05,0.95,'c');
%% Lee et al 2007b
subplot(224) 
hold on
load('Lee2007-fig3b.mat');
x2 = Data003(:,1);
y2 = Data003(:,2);
h2 = plot(x2,y2,'ks','MarkerFaceColor',[.8 .8 .8],'Color',[.8 .8 .8],'MarkerSize',3);

load('Lee2007-fig3c.mat');
x3 = Data004(:,1);
y3 = Data004(:,2);
h3 = plot(x3,y3,'ks','MarkerFaceColor',[.8 .8 .8],'Color',[.8 .8 .8],'MarkerSize',3);

axis([-10 110 -12 12]);
axis square;
box off
xlabel('Score (%)');
ylabel('[F^{18}]FDG uptake (ml/dl/min)');

b = regstats([y2; y3],[x2; x3]);
h = pa_regline(b.beta,'k-');
set(h,'Color',[.7 .7 .7],'LineWidth',2);
set(gca,'XTick',0:25:100);

% legend('Right superior temporal sulcus','Right Heschls Gyrus');
pa_text(0.1,0.1,{'Right HG','Right STG'});

pa_text(0.05,0.95,'d');
%% Green et al 2008
subplot(221)
load('Green2008-fig2.mat');

y = Data005(:,2);
y = reshape(y,3,6);
m = y(2,:)
l = y(1,:);
u = y(3,:);

errorbar(90,m(1),m(1)-l(1),u(1)-m(1),'ko-','MarkerFaceColor',[.7 .7 .7],'Color',[.7 .7 .7]);
errorbar(12.5,m(2),m(2)-l(2),u(2)-m(2),'ko-','MarkerFaceColor',[.7 .7 .7],'Color',[.7 .7 .7]);

errorbar(90,m(3),m(3)-l(3),u(3)-m(3),'ks-','MarkerFaceColor',[.7 .7 .7],'Color',[.7 .7 .7]);
errorbar(12.5,m(4),m(4)-l(4),u(4)-m(4),'ks-','MarkerFaceColor',[.7 .7 .7],'Color',[.7 .7 .7]);


function ourdata
p			= 'E:\DATA\KNO\PET\swdro files\';

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
nvoxels		= 2296;

files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	}; % prelingual deaf rest
Pre			= getvoxels(p,files,roiname,nvoxels);

files = {'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'}; % normal-hearing rest
NH			= getvoxels(p,files,roiname,nvoxels);
mu			= mean(NH);
D			= bsxfun(@minus,Pre,mu);
nhypo3		= sum(D<0,2);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
nvoxels		= 3141;

files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	}; % prelingual deaf rest
Pre			= getvoxels(p,files,roiname,nvoxels);

files = {'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'}; % normal-hearing rest
NH			= getvoxels(p,files,roiname,nvoxels);
mu			= mean(NH);
D			= bsxfun(@minus,Pre,mu);
nhypo4		= sum(D<0,2);

nhypo		= (nhypo3+nhypo4);
nhypopre = nhypo;

F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02
F = F([6 8 9 10 11 12]); %% Phonemescores
fpre = F;

figure(1)
subplot(222)
hold on
plot(F,-nhypo,'ko','MarkerFaceColor','k');


p			= 'E:\DATA\KNO\PET\swdro files\';

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
nvoxels		= 2296;

files		= {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	}; % prelingual deaf rest
Pre			= getvoxels(p,files,roiname,nvoxels);

files = {'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'}; % normal-hearing rest
NH			= getvoxels(p,files,roiname,nvoxels);
mu			= mean(NH);
D			= bsxfun(@minus,Pre,mu);
nhypo3		= sum(D<0,2);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
nvoxels		= 3141;

files		= {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	}; % prelingual deaf rest
Pre			= getvoxels(p,files,roiname,nvoxels);

files = {'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'}; % normal-hearing rest
NH			= getvoxels(p,files,roiname,nvoxels);
mu			= mean(NH);
D			= bsxfun(@minus,Pre,mu);
nhypo4		= sum(D<0,2);

nhypo		= (nhypo3+nhypo4);
nhypopost = nhypo;
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02
F = F([7 13 14 15 16]); %% Phonemescores
fpost = F;

figure(1)
subplot(222)
hold on
plot(F,-nhypo,'ks','MarkerFaceColor',[.7 .7 .7]);

y = -[nhypopre; nhypopost];
x = [fpre fpost];
b = regstats(y,x);
h = pa_regline(b.beta,'k-');
set(h,'LineWidth',2);

function ourlee2007data
p			= 'E:\DATA\KNO\PET\swdro files\';

% roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Frontal_Mid_Orb_L_roi.mat';
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Frontal_Mid_R_roi.mat';

files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	}; % prelingual deaf rest

[mu,var] = pa_pet_getmeandata(files,p,roiname);
mu = mu/2;
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02
F = F([6 8 9 10 11 12]); %% Phonemescores
x1 = F;
y1 = mu-mean(mu);

subplot(223) 
plot(x1,y1,'ko','MarkerFaceColor','k');
files		= {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	}; % prelingual deaf rest
[mu,var] = pa_pet_getmeandata(files,p,roiname);
mu
mu = mu/2;
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02
F = F([7 13 14 15 16]); %% Phonemescores
x2 = F;
y2 = mu-mean(mu);
subplot(223) 
plot(x2,y2,'ks','MarkerFaceColor',[.7 .7 .7]);


y = [y1;y2];
x = [x1 x2];
b = regstats(y,x);
h = pa_regline(b.beta,'k-');
set(h,'LineWidth',2);

%% Heschl
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';

files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	}; % prelingual deaf rest

[mu,var] = pa_pet_getmeandata(files,p,roiname);
% mu = mu/2;
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02
F = F([6 8 9 10 11 12]); %% Phonemescores
y1 = mu-mean(mu);
x1 = F;
subplot(224) 
plot(F,mu-mean(mu),'ko','MarkerFaceColor','k');

files		= {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	}; % prelingual deaf rest
[mu,var] = pa_pet_getmeandata(files,p,roiname);
% mu = mu/2;
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02
F = F([7 13 14 15 16]); %% Phonemescores
y2 = mu-mean(mu);
x2 = F;
subplot(224) 
plot(F,mu-mean(mu),'ks','MarkerFaceColor',[.7 .7 .7]);

%% Sup Temp Sulcus
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';

files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	}; % prelingual deaf rest

[mu,var] = pa_pet_getmeandata(files,p,roiname);
% mu = mu/2;
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02
F = F([6 8 9 10 11 12]); %% Phonemescores
y3 = mu-mean(mu);
x3 = F;
subplot(224) 
plot(F,mu-mean(mu),'ko','MarkerFaceColor','k');

files		= {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	}; % prelingual deaf rest
[mu,var] = pa_pet_getmeandata(files,p,roiname);
mu
% mu = mu/2;
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02
F = F([7 13 14 15 16]); %% Phonemescores
y4 = mu-mean(mu);
x4 = F;

subplot(224) 
plot(F,mu-mean(mu),'ks','MarkerFaceColor',[.7 .7 .7]);


y = [y1;y2;y3;y4];
x = [x1 x2 x3 x4];
b = regstats(y,x);
h = pa_regline(b.beta,'k-');
set(h,'LineWidth',2);

function ourgreen2005data
p			= 'E:\DATA\KNO\PET\swdro files\';

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';

files = {'gswdro_s07-av-post.img';'gswdro_s13-av-post.img';...
	'gswdro_s14-av-post.img';'gswdro_s15-av-post.img';...
	'gswdro_s16-av-post.img';...
	};
[muav1,var] = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
[muc1,var] = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';

files = {'gswdro_s07-av-post.img';'gswdro_s13-av-post.img';...
	'gswdro_s14-av-post.img';'gswdro_s15-av-post.img';...
	'gswdro_s16-av-post.img';...
	};
[muav2,var] = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
[muc2,var] = pa_pet_getmeandata(files,p,roiname);

muav = (muav1+muav2)/2;
muc = (muc1+muc2)/2;

mu	= 100*muav./muc-100;
F	= [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02
F	= F([7 13 14 15 16]); %% Phonemescores
y1 = mu;
x1 = F;
subplot(221)
plot(F,mu,'ko','MarkerFaceColor',[.7 .7 .7]);

%%
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';

files = {'gswdro_s07-av-post.img';'gswdro_s13-av-post.img';...
	'gswdro_s14-av-post.img';'gswdro_s15-av-post.img';...
	'gswdro_s16-av-post.img';...
	};
[muav1,var] = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
[muc1,var] = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';

files = {'gswdro_s07-av-post.img';'gswdro_s13-av-post.img';...
	'gswdro_s14-av-post.img';'gswdro_s15-av-post.img';...
	'gswdro_s16-av-post.img';...
	};
[muav2,var] = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
[muc2,var] = pa_pet_getmeandata(files,p,roiname);

muav = (muav1+muav2)/2;
muc = (muc1+muc2)/2;

mu = 100*muav./muc-100;
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02
F = F([7 13 14 15 16]); %% Phonemescores
y2 = mu;
x2 = F;

subplot(221)
plot(F,mu,'ks','MarkerFaceColor',[.7 .7 .7]);



y = [y1;y2];
x = [x1 x2];
b = regstats(y,x);
h = pa_regline(b.beta,'k-');
set(h,'LineWidth',2);
function Y	= getvoxels(p,files,roiname,nvoxels)
roi_obj		= maroi(roiname);
nfiles		= numel(files);
% col = jet;
Y = NaN(nfiles,nvoxels);
for ii = 1:nfiles
	fname			= [p files{ii}];
	y	= getdata(roi_obj, fname);
	Y(ii,:) = y;
end


function [mu,var] = pa_pet_getmeandata(files,p,roiname)

%% Region of interest
% Hesch's gyrus / A1
if nargin<3
roiname = 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
end
%% Data directory
if nargin<2
p = 'E:\DATA\KNO\PET\SWDRO files\';
end
if nargin<1
files = {'swdro_s01-c-normal.img';'swdro_s03-c-normal.img';...
	'swdro_s04-c-normal.img'};
end

%% Control condition
nfiles		= length(files);
mu	= NaN(nfiles,1);
var = mu;
for ii = 1:nfiles
	fname			= [p files{ii}];
	[mu(ii),var(ii)]	= pa_pet_roimean(fname,roiname);
end
% mu = mu/1000;




function [mu,var] = pa_pet_roimean(fname,roiname)
% MU = PA_PET_ROIMEAN(FNAME,ROI)
%
% Obtain mean value from region of interest ROI (AAL)
%
% See also GET_MARSY, SUMMARY_DATA from MARSBAR, SPM

% 2012 Marc van Wanrooij
% e-mail: m.vanwanrooij@neural-code.com

if nargin<1
	fname		= 'E:\DATA\KNO\PET\SWDRO files\swdro_s15-v-post.img';
end
[path,fname,ext] = fileparts(fname);
cd(path);
fname = [fname ext];
if nargin<2
	roiname	= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
end
load(roiname);
marsY		= get_marsy(roi, fname, 'mean');
[mu,var]	= summary_data(marsY);

