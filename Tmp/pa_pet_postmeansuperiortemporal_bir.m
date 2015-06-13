
%% Initialization
close all
clear all

%% Region of interest
% Superior Temporal gyrus / A1
roiname_a1_l = 'D:\DATA\marsbar-0.43[1]\marsbar-aal-0.2\MNI_Temporal_Sup_L_roi.mat';
roiname_a1_r = 'D:\DATA\marsbar-0.43[1]\marsbar-aal-0.2\MNI_Temporal_Sup_R_roi.mat';

%% Data directory
p = 'D:\DATA\PET\SWDRO files\';

%% Control condition
files = {'swdro_s07-c-post.img';'swdro_s13-c-post.img';...
	'swdro_s14-c-post.img';'swdro_s15-c-post.img';...
	'swdro_s16-c-post.img';...
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
title({'Control condition';'Superior Temporal gyrus'});
xlabel('Metabolic rate left hemisphere');
ylabel('Metabolic rate right hemisphere');
pa_unityline;
legend(h,'Post-implant','Location','NW');

%% Vision condition
files = {'swdro_s07-v-post.img';'swdro_s13-v-post.img';...
	'swdro_s14-v-post.img';'swdro_s15-v-post.img';...
	'swdro_s16-v-post.img';...
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
title({'Visual condition';'Superior Temporal gyrus'});
xlabel('Metabolic rate left hemisphere');
ylabel('Metabolic rate right hemisphere');
pa_unityline;
legend(h,'Post-implant','Location','NW');

%% Audiovisual condition
files = {'swdro_s07-av-post.img';'swdro_s13-av-post.img';...
	'swdro_s14-av-post.img';'swdro_s15-av-post.img';...
	'swdro_s16-av-post.img';...
	};
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
title({'Audiovisual condition';'Superior Temporal gyrus'});
xlabel('Metabolic rate left hemisphere');
ylabel('Metabolic rate right hemisphere');
pa_unityline;
legend(h,'Post-implant','Location','NW');


mu = [mean(mu_a1_l_v./mu_a1_l_c) mean(mu_a1_l_av./mu_a1_l_c) mean(mu_a1_r_v./mu_a1_r_c) mean(mu_a1_r_av./mu_a1_r_c)];
sd = [std(mu_a1_l_v./mu_a1_l_c) std(mu_a1_l_av./mu_a1_l_c) std(mu_a1_r_v./mu_a1_r_c) std(mu_a1_r_av./mu_a1_r_c)];
subplot(224)
h = pa_errorbar(mu',sd');
ax = [0.9*(min(mu)-max(sd)) 1.1*(max(mu)+max(sd))];
ylim(ax);
xlim([0 5]);
axis square;
set(gca,'XTick',[1 2 3 4],'XTickLabel',{'Vl';'AVl';'Vr';'AVr'});
ylabel('Average metabolic rate re. control');
title('Post-implantation');

%%
pa_datadir;
print('-dpng',mfilename);