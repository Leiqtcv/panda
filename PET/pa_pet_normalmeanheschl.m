
%% Initialization
close all
clear all

%% Region of interest
% Hesch's gyrus / A1
roiname_a1_l = 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
roiname_a1_r = 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
% roiname_a1_l = 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
% roiname_a1_r = 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';

%% Data directory
p = 'E:\DATA\KNO\PET\SWDRO files\';

%% Control condition
files = {'swdro_s01-c-normal.img';'swdro_s03-c-normal.img';...
	'swdro_s04-c-normal.img'};
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
title({'Control condition';'Heschl''s gyrus'});
xlabel('Metabolic rate left hemisphere');
ylabel('Metabolic rate right hemisphere');
pa_unityline;
legend(h,'Normal','Location','NW');

%% Vision condition
files = {'swdro_s01-v-normal.img';'swdro_s03-v-normal.img';...
	'swdro_s04-v-normal.img'};
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
title({'Visual condition';'Heschl''s gyrus'});
xlabel('Metabolic rate left hemisphere');
ylabel('Metabolic rate right hemisphere');
pa_unityline;
legend(h,'Control','Location','NW');

%% Audiovisual condition
files = {'swdro_s01-av-normal.img';'swdro_s03-av-normal.img';...
	'swdro_s04-av-normal.img'};
nfiles		= length(files);
mu_a1_l_av	= NaN(nfiles,1);
mu_a1_r_av	= mu_a1_l_av;
for ii = 1:nfiles
	fname			= [p files{ii}];
	mu_a1_l_av(ii)	= pa_pet_roimean(fname,roiname_a1_l);
	mu_a1_r_av(ii)	= pa_pet_roimean(fname,roiname_a1_r);
end
mu_a1_l_av = mu_a1_l_av/1000;
mu_a1_r_av = mu_a1_r_av/1000;

subplot(223)
h = plot(mu_a1_l_av,mu_a1_r_av,'ko','MarkerFaceColor','w');
axis square
title({'Audiovisual condition';'Heschl''s gyrus'});
xlabel('Metabolic rate left hemisphere');
ylabel('Metabolic rate right hemisphere');
pa_unityline;
legend(h,'Control','Location','NW');


mu = 100*([mean(mu_a1_l_v./mu_a1_l_c) mean(mu_a1_l_av./mu_a1_l_c) mean(mu_a1_r_v./mu_a1_r_c) mean(mu_a1_r_av./mu_a1_r_c)]-1);
sd = 100*[std(mu_a1_l_v./mu_a1_l_c) std(mu_a1_l_av./mu_a1_l_c) std(mu_a1_r_v./mu_a1_r_c) std(mu_a1_r_av./mu_a1_r_c)];
sd = 1.96*sd./sqrt(nfiles); % 95% CI

subplot(224)
h = pa_errorbar(mu',sd');
ax = [0.9*(min(mu)-max(sd)) 1.1*(max(mu)+max(sd))];
ylim(ax);
xlim([0 5]);
axis square;
set(gca,'XTick',[1 2 3 4],'XTickLabel',{'Vl';'AVl';'Vr';'AVr'});
ylabel('Cortical activity re. control (%)');
title('Normal');

%%
pa_datadir;
print('-dpng',mfilename);