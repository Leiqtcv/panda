
%% Initialization
close all
clear all

%% Region of interest
% Superior temporal gyrus / A1
roiname_a1_l = 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
roiname_a1_r = 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';

%% Data directory
p = 'E:\DATA\KNO\PET\SWDRO files\';

%% Pre-implant condition
files = {'swdro_s06-c-pre.img';'swdro_s08-c-pre.img';...
	'swdro_s09-c-pre.img';'swdro_s10-c-pre.img';...
	'swdro_s11-c-pre.img';'swdro_s12-c-pre.img';...
	};
nfiles		= length(files);
mu_a1_l_c	= NaN(nfiles,1);
mu_a1_r_c	= mu_a1_l_c;
for ii = 1:nfiles
	fname			= [p files{ii}];
	mu_a1_l_c(ii)	= pa_pet_roimean(fname,roiname_a1_l);
	mu_a1_r_c(ii)	= pa_pet_roimean(fname,roiname_a1_r);
end
mu_a1_l_c = mu_a1_l_c/1000;
mu_a1_r_c = mu_a1_r_c/1000;

subplot(221)
h = plot(mu_a1_l_c,mu_a1_r_c,'ko','MarkerFaceColor','w');
axis square
title({'Control condition';'Superior temporal gyrus'});
xlabel('Metabolic rate left hemisphere');
ylabel('Metabolic rate right hemisphere');
pa_unityline;
legend(h,'Pre-implant','Location','NW');

%% Vision condition
files = {'swdro_s06-v-pre.img';'swdro_s08-v-pre.img';...
	'swdro_s09-v-pre.img';'swdro_s10-v-pre.img';...
	'swdro_s11-v-pre.img';'swdro_s12-v-pre.img';...
	};
nfiles		= length(files);
mu_a1_l_v	= NaN(nfiles,1);
mu_a1_r_v	= mu_a1_l_v;
for ii = 1:nfiles
	fname			= [p files{ii}];
	mu_a1_l_v(ii)	= pa_pet_roimean(fname,roiname_a1_l);
	mu_a1_r_v(ii)	= pa_pet_roimean(fname,roiname_a1_r);
end
mu_a1_l_v = mu_a1_l_v/1000;
mu_a1_r_v = mu_a1_r_v/1000;

subplot(222)
h = plot(mu_a1_l_v,mu_a1_r_v,'ko','MarkerFaceColor','w');
axis square
title({'Visual condition';'Superior temporal gyrus'});
xlabel('Metabolic rate left hemisphere');
ylabel('Metabolic rate right hemisphere');
pa_unityline;
legend(h,'Pre-implant','Location','NW');




mu = [mean(mu_a1_l_v./mu_a1_l_c) mean(mu_a1_r_v./mu_a1_r_c)];
sd = [std(mu_a1_l_v./mu_a1_l_c) std(mu_a1_r_v./mu_a1_r_c) ];
subplot(224)
h = pa_errorbar(mu',sd');
ax = [0.95*(min(mu)-max(sd)) 1.05*(max(mu)+max(sd))];
ylim(ax);
xlim([0 3]);
axis square;
set(gca,'XTick',[1 2],'XTickLabel',{'Vl';'Vr'});
ylabel('Average metabolic rate re. Control');
title({'Pre-implant';'Superior temporal gyrus'});

%%
pa_datadir;
print('-dpng',mfilename);