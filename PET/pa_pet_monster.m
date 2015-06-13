
%% Initialization
close all
clear all

p			= 'E:\DATA\KNO\PET\SWDRO files\';

%% -------------------- PRE HESCHL ---------------------------------
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
files		= {'swdro_s06-c-pre.img';'swdro_s08-c-pre.img';...
	'swdro_s09-c-pre.img';'swdro_s10-c-pre.img';...
	'swdro_s11-c-pre.img';'swdro_s12-c-pre.img';...
	};
mu_pre_control_heschl_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
mu_pre_control_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
files = {'swdro_s06-v-pre.img';'swdro_s08-v-pre.img';...
	'swdro_s09-v-pre.img';'swdro_s10-v-pre.img';...
	'swdro_s11-v-pre.img';'swdro_s12-v-pre.img';...
	};
mu_pre_vision_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
mu_pre_vision_heschl_left = pa_pet_getmeandata(files,p,roiname);

%% Temporal superior gyrus
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
files		= {'swdro_s06-c-pre.img';'swdro_s08-c-pre.img';...
	'swdro_s09-c-pre.img';'swdro_s10-c-pre.img';...
	'swdro_s11-c-pre.img';'swdro_s12-c-pre.img';...
	};
mu_pre_control_ts_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
mu_pre_control_ts_right = pa_pet_getmeandata(files,p,roiname);

files = {'swdro_s06-v-pre.img';'swdro_s08-v-pre.img';...
	'swdro_s09-v-pre.img';'swdro_s10-v-pre.img';...
	'swdro_s11-v-pre.img';'swdro_s12-v-pre.img';...
	};
mu_pre_vision_ts_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
mu_pre_vision_ts_left = pa_pet_getmeandata(files,p,roiname);

%% Calcarine
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
files		= {'swdro_s06-c-pre.img';'swdro_s08-c-pre.img';...
	'swdro_s09-c-pre.img';'swdro_s10-c-pre.img';...
	'swdro_s11-c-pre.img';'swdro_s12-c-pre.img';...
	};
mu_pre_control_cs_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
mu_pre_control_cs_right = pa_pet_getmeandata(files,p,roiname);

files = {'swdro_s06-v-pre.img';'swdro_s08-v-pre.img';...
	'swdro_s09-v-pre.img';'swdro_s10-v-pre.img';...
	'swdro_s11-v-pre.img';'swdro_s12-v-pre.img';...
	};
mu_pre_vision_cs_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
mu_pre_vision_cs_left = pa_pet_getmeandata(files,p,roiname);

%% ------------------------- POST -----------------------------%

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
files = {'swdro_s07-c-post.img';'swdro_s13-c-post.img';...
	'swdro_s14-c-post.img';'swdro_s15-c-post.img';...
	'swdro_s16-c-post.img';...
	};
mu_post_control_heschl_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
mu_post_control_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
files = {'swdro_s07-v-post.img';'swdro_s13-v-post.img';...
	'swdro_s14-v-post.img';'swdro_s15-v-post.img';...
	'swdro_s16-v-post.img';...
	};
mu_post_vision_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
mu_post_vision_heschl_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
files = {'swdro_s07-av-post.img';'swdro_s13-av-post.img';...
	'swdro_s14-av-post.img';'swdro_s15-av-post.img';...
	'swdro_s16-av-post.img';...
	};
mu_post_av_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
mu_post_av_heschl_left = pa_pet_getmeandata(files,p,roiname);


%% Temporal superior gyrus
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
files = {'swdro_s07-c-post.img';'swdro_s13-c-post.img';...
	'swdro_s14-c-post.img';'swdro_s15-c-post.img';...
	'swdro_s16-c-post.img';...
	};
mu_post_control_ts_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
mu_post_control_ts_right = pa_pet_getmeandata(files,p,roiname);

files = {'swdro_s07-v-post.img';'swdro_s13-v-post.img';...
	'swdro_s14-v-post.img';'swdro_s15-v-post.img';...
	'swdro_s16-v-post.img';...
	};
mu_post_vision_ts_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
mu_post_vision_ts_left = pa_pet_getmeandata(files,p,roiname);

files = {'swdro_s07-av-post.img';'swdro_s13-av-post.img';...
	'swdro_s14-av-post.img';'swdro_s15-av-post.img';...
	'swdro_s16-av-post.img';...
	};
mu_post_av_ts_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
mu_post_av_ts_right = pa_pet_getmeandata(files,p,roiname);

%% Calcarine
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
files = {'swdro_s07-c-post.img';'swdro_s13-c-post.img';...
	'swdro_s14-c-post.img';'swdro_s15-c-post.img';...
	'swdro_s16-c-post.img';...
	};
mu_post_control_cs_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
mu_post_control_cs_right = pa_pet_getmeandata(files,p,roiname);

files = {'swdro_s07-v-post.img';'swdro_s13-v-post.img';...
	'swdro_s14-v-post.img';'swdro_s15-v-post.img';...
	'swdro_s16-v-post.img';...
	};
mu_post_vision_cs_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
mu_post_vision_cs_left = pa_pet_getmeandata(files,p,roiname);

files = {'swdro_s07-av-post.img';'swdro_s13-av-post.img';...
	'swdro_s14-av-post.img';'swdro_s15-av-post.img';...
	'swdro_s16-av-post.img';...
	};
mu_post_av_cs_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
mu_post_av_cs_right = pa_pet_getmeandata(files,p,roiname);

%% ------------------------- normal -----------------------------%

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
files = {'swdro_s01-c-normal.img';'swdro_s02-c-normal.img';'swdro_s03-c-normal.img';...
	'swdro_s04-c-normal.img'};
mu_normal_control_heschl_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
mu_normal_control_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
files = {'swdro_s01-v-normal.img';'swdro_s02-v-normal.img';'swdro_s03-v-normal.img';...
	'swdro_s04-v-normal.img'};
mu_normal_vision_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
mu_normal_vision_heschl_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
files = {'swdro_s01-av-normal.img';'swdro_s03-av-normal.img';...
	'swdro_s04-av-normal.img'};
mu_normal_av_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
mu_normal_av_heschl_left = pa_pet_getmeandata(files,p,roiname);

%% Temporal superior gyrus
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
files = {'swdro_s01-c-normal.img';'swdro_s02-c-normal.img';'swdro_s03-c-normal.img';...
	'swdro_s04-c-normal.img'};
mu_normal_control_ts_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
mu_normal_control_ts_right = pa_pet_getmeandata(files,p,roiname);

files = {'swdro_s01-v-normal.img';'swdro_s02-v-normal.img';'swdro_s03-v-normal.img';...
	'swdro_s04-v-normal.img'};
mu_normal_vision_ts_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
mu_normal_vision_ts_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
files = {'swdro_s01-av-normal.img';'swdro_s03-av-normal.img';...
	'swdro_s04-av-normal.img'};
mu_normal_av_ts_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
mu_normal_av_ts_left = pa_pet_getmeandata(files,p,roiname);

%% Calcarine
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
files = {'swdro_s01-c-normal.img';'swdro_s02-c-normal.img';'swdro_s03-c-normal.img';...
	'swdro_s04-c-normal.img'};
mu_normal_control_cs_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
mu_normal_control_cs_right = pa_pet_getmeandata(files,p,roiname);

files = {'swdro_s01-v-normal.img';'swdro_s02-v-normal.img';'swdro_s03-v-normal.img';...
	'swdro_s04-v-normal.img'};
mu_normal_vision_cs_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
mu_normal_vision_cs_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
files = {'swdro_s01-av-normal.img';'swdro_s03-av-normal.img';...
	'swdro_s04-av-normal.img'};
mu_normal_av_cs_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
mu_normal_av_cs_left = pa_pet_getmeandata(files,p,roiname);

%% ---------------- GRAPHICS ---------------------------%
close all
%% V-C


VCpre		= mu_pre_vision_heschl_right./mu_pre_control_heschl_right;
VCpost		= mu_post_vision_heschl_right./mu_post_control_heschl_right;
VCnormal	= mu_normal_vision_heschl_right./mu_normal_control_heschl_right;
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M	= mu;
C	= ci95;

VCpre		= mu_pre_vision_ts_right./mu_pre_control_ts_right;
VCpost		= mu_post_vision_ts_right./mu_post_control_ts_right;
VCnormal	= mu_normal_vision_ts_right./mu_normal_control_ts_right;
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M	= [M;mu];
C	= [C;ci95];

VCpre		= mu_pre_vision_cs_right./mu_pre_control_cs_right;
VCpost		= mu_post_vision_cs_right./mu_post_control_cs_right;
VCnormal	= mu_normal_vision_cs_right./mu_normal_control_cs_right;
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M	= [M;mu];
C	= [C;ci95];

figure(101)
subplot(3,2,1)
pa_errorbar(M',C');
axis square;
legend({'Heschl G';'Temp Sup G';'Calcarine S'});
set(gca,'XTick',1:3,'XTickLabel',{'Pre';'Post';'Normal'});
ylabel('Cortical activation (%)');
title('Vision re Baseline');

subplot(3,2,2)
pa_errorbar(M,C);
axis square;
colormap('gray');
legend({'Pre';'Post';'Normal'});
title('Vision re Baseline');
set(gca,'XTick',1:3,'XTickLabel',{'Heschl G';'Temp Sup G';'Calcarine S'});

%% AV-C

AVCpost		= mu_post_av_heschl_right./mu_post_control_heschl_right;
AVCnormal	= mu_normal_av_heschl_right./mu_normal_control_heschl_right([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= mu;
C			= ci95;

AVCpost		= mu_post_av_ts_right./mu_post_control_ts_right;
AVCnormal	= mu_normal_av_ts_right./mu_normal_control_ts_right([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

AVCpost		= mu_post_av_cs_right./mu_post_control_cs_right;
AVCnormal	= mu_normal_av_cs_right./mu_normal_control_cs_right([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


M			= [[0 0 0]' M];
C			= [[0 0 0]' C];


figure(101)
subplot(3,2,3)
pa_errorbar(M',C');
axis square;
legend({'Heschl G';'Temp Sup G';'Calcarine S'});
set(gca,'XTick',1:3,'XTickLabel',{'Pre';'Post';'Normal'});
ylabel('Cortical activation (%)');
title('Audiovisual re Baseline');

subplot(3,2,4)
pa_errorbar(M,C);
axis square;
colormap('gray');
legend({'Pre';'Post';'Normal'});
title('Audiovisual re Baseline');
set(gca,'XTick',1:3,'XTickLabel',{'Heschl G';'Temp Sup G';'Calcarine S'});

%% AV-V

AVCpost		= mu_post_av_heschl_right./mu_post_vision_heschl_right;
AVCnormal	= mu_normal_av_heschl_right./mu_normal_vision_heschl_right([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= mu;
C			= ci95;

AVCpost		= mu_post_av_ts_right./mu_post_vision_ts_right;
AVCnormal	= mu_normal_av_ts_right./mu_normal_vision_ts_right([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

AVCpost		= mu_post_av_cs_right./mu_post_vision_cs_right;
AVCnormal	= mu_normal_av_cs_right./mu_normal_vision_cs_right([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

M			= [[0 0 0]' M];
C			= [[0 0 0]' C];

figure(101)
subplot(3,2,5)
pa_errorbar(M',C');
axis square;
legend({'Heschl G';'Temp Sup G';'Calcarine S'});
set(gca,'XTick',1:3,'XTickLabel',{'Pre';'Post';'Normal'});
ylabel('Cortical activation (%)');
title('Audiovisual re Vision');

subplot(3,2,6)
pa_errorbar(M,C);
axis square;
colormap('gray');
legend({'Pre';'Post';'Normal'});
title('Audiovisual re Vision');
set(gca,'XTick',1:3,'XTickLabel',{'Heschl G';'Temp Sup G';'Calcarine S'});

figure(101)
for ii = 1:6
	subplot(3,2,ii)
	box off;
	ylim([-2 16]);
	pa_text(0.1,0.9,char(96+ii));
end

pa_datadir;
print('-depsc',[mfilename 'PET']);


%% ---------------- LEFT --------------------------------







%% V-C


VCpre		= mu_pre_vision_heschl_left./mu_pre_control_heschl_left;
VCpost		= mu_post_vision_heschl_left./mu_post_control_heschl_left;
VCnormal	= mu_normal_vision_heschl_left./mu_normal_control_heschl_left;
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M	= mu;
C	= ci95;

VCpre		= mu_pre_vision_ts_left./mu_pre_control_ts_left;
VCpost		= mu_post_vision_ts_left./mu_post_control_ts_left;
VCnormal	= mu_normal_vision_ts_left./mu_normal_control_ts_left;
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M	= [M;mu];
C	= [C;ci95];

VCpre		= mu_pre_vision_cs_left./mu_pre_control_cs_left;
VCpost		= mu_post_vision_cs_left./mu_post_control_cs_left;
VCnormal	= mu_normal_vision_cs_left./mu_normal_control_cs_left;
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M	= [M;mu];
C	= [C;ci95];

figure(102)
subplot(3,2,1)
pa_errorbar(M',C');
axis square;
legend({'Heschl G';'Temp Sup G';'Calcarine S'});
set(gca,'XTick',1:3,'XTickLabel',{'Pre';'Post';'Normal'});
ylabel('Cortical activation (%)');
title('Vision re Baseline');

subplot(3,2,2)
pa_errorbar(M,C);
axis square;
colormap('gray');
legend({'Pre';'Post';'Normal'});
title('Vision re Baseline');
set(gca,'XTick',1:3,'XTickLabel',{'Heschl G';'Temp Sup G';'Calcarine S'});

%% AV-C

AVCpost		= mu_post_av_heschl_left./mu_post_control_heschl_left;
AVCnormal	= mu_normal_av_heschl_left./mu_normal_control_heschl_left([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= mu;
C			= ci95;

AVCpost		= mu_post_av_ts_left./mu_post_control_ts_left;
AVCnormal	= mu_normal_av_ts_left./mu_normal_control_ts_left([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

AVCpost		= mu_post_av_cs_left./mu_post_control_cs_left;
AVCnormal	= mu_normal_av_cs_left./mu_normal_control_cs_left([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


M			= [[0 0 0]' M];
C			= [[0 0 0]' C];


figure(102)
subplot(3,2,3)
pa_errorbar(M',C');
axis square;
legend({'Heschl G';'Temp Sup G';'Calcarine S'});
set(gca,'XTick',1:3,'XTickLabel',{'Pre';'Post';'Normal'});
ylabel('Cortical activation (%)');
title('Audiovisual re Baseline');

subplot(3,2,4)
pa_errorbar(M,C);
axis square;
colormap('gray');
legend({'Pre';'Post';'Normal'});
title('Audiovisual re Baseline');
set(gca,'XTick',1:3,'XTickLabel',{'Heschl G';'Temp Sup G';'Calcarine S'});

%% AV-V

AVCpost		= mu_post_av_heschl_left./mu_post_vision_heschl_left;
AVCnormal	= mu_normal_av_heschl_left./mu_normal_vision_heschl_left([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= mu;
C			= ci95;

AVCpost		= mu_post_av_ts_left./mu_post_vision_ts_left;
AVCnormal	= mu_normal_av_ts_left./mu_normal_vision_ts_left([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

AVCpost		= mu_post_av_cs_left./mu_post_vision_cs_left;
AVCnormal	= mu_normal_av_cs_left./mu_normal_vision_cs_left([1 3 4]);
mu			= 100*([mean(AVCpost) mean(AVCnormal)]-1);
sem			= 100*([std(AVCpost)/sqrt(numel(AVCpost)) std(AVCnormal)/sqrt(numel(AVCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

M			= [[0 0 0]' M];
C			= [[0 0 0]' C];

figure(102)
subplot(3,2,5)
pa_errorbar(M',C');
axis square;
legend({'Heschl G';'Temp Sup G';'Calcarine S'});
set(gca,'XTick',1:3,'XTickLabel',{'Pre';'Post';'Normal'});
ylabel('Cortical activation (%)');
title('Audiovisual re Vision');

subplot(3,2,6)
pa_errorbar(M,C);
axis square;
colormap('gray');
legend({'Pre';'Post';'Normal'});
title('Audiovisual re Vision');
set(gca,'XTick',1:3,'XTickLabel',{'Heschl G';'Temp Sup G';'Calcarine S'});

figure(102)
for ii = 1:6
	subplot(3,2,ii)
	box off;
	ylim([-2 16]);
	pa_text(0.1,0.9,char(96+ii));
end

pa_datadir;
print('-depsc',[mfilename 'PET']);

for ii = 1:6
figure(101)
	subplot(3,2,ii)
	colormap summer

figure(102)
	subplot(3,2,ii)
	colormap summer
end
