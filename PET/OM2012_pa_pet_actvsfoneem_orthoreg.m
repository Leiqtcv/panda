function OM2012_pa_pet_actvsfoneem_orthoreg
%% Initialization
close all force
clear all
p					= 'E:\DATA\KNO\PET\swdro files\';

%% Data
[mupre,~,g1pre,g2pre,~,g4pre]			= getpre(p);
[mupost,~,g1post,g2post,~,g4post]		= getpost(p);
[munormal,~,g1normal,g2normal]			= getnormal(p);

subplot(121)
plotfoneem2(mupre,g1pre,g2pre,g4pre,mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,{'Heschl';'TemSup'},{'Control';'Vision'});

pa_datadir;
print('-depsc',mfilename);


function plotfoneem2(mupre,g1pre,g2pre,g4pre,mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,roi,cond)


%% Phonemescores
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02

%% Pre-Implant
[muf,mum,sdm]	= getdat(mupre,g2pre,g4pre,g1pre,F,cond{1},roi);
b				= regstats(mum,muf,'linear',{'beta','rsquare','tstat','fstat'});
[~, P]			= fit_2D_data(muf, mum, 'no');
beta1			= P([2 1]);
str1			= ['Pre-CI: R^2 = ' num2str(b.rsquare,2) ', p = ' num2str(b.fstat.pval,2)];
plotdat(muf,mum,sdm,'ro');

%% Temporal Superior, V, Post-Implant

[muf,mum,sdm]	= getdat(mupost,g2post,g4post,g1post,F,cond{1},roi);
b				= regstats(mum,muf,'linear',{'beta','rsquare','tstat','fstat'});
[~, P]			= fit_2D_data(muf, mum, 'no');
beta2			= P([2 1]);
plotdat(muf,mum,sdm,'ks')
str2			= ['Post-CI: R^2 = ' num2str(b.rsquare,2) ', p = ' num2str(b.fstat.pval,2)];


%% Temporal Superior, V, Normal
sel		= strcmpi(g2normal,roi{1}) | strcmpi(g2normal,roi{2});
m		= munormal(sel);
c		= g1normal(sel);
sel2	= strcmpi(c,cond{1});
m		= m(sel2);
hold on
errorbar(100,mean(m),std(m)./sqrt(numel(m)),'kd','MarkerFaceColor','w','LineWidth',2,'MarkerSize',10);
axis square

axis([-10 110 70 100]) 
h = pa_regline(beta2','k-'); set(h,'LineWidth',2);
h = pa_regline(beta1','r-'); set(h,'LineWidth',2);
h		= pa_text(0.1,0.1,str2); set(h,'Color','k')
h		= pa_text(0.1,0.2,str1);set(h,'Color','r') 
box off;
xlabel('Phoneme score (%)');
ylabel('FDG'); 
set(gca,'XTick',0:20:100,'YTick',60:10:100);

%%
subplot(122)

%% Pre-Implant
[muf,mum,sdm]	= getdat(mupre,g2pre,g4pre,g1pre,F,cond{2},roi);
b				= regstats(mum,muf,'linear',{'beta','rsquare','tstat','fstat'});
str1			= ['Pre-CI: R^2 = ' num2str(b.rsquare,2) ', p = ' num2str(b.fstat.pval,2)];
[~, P]			= fit_2D_data(muf, mum, 'no');
beta1			= P([2 1]);
plotdat(muf,mum,sdm,'ro')

%% Temporal Superior, V, Post-Implant
[muf,mum,sdm]	= getdat(mupost,g2post,g4post,g1post,F,cond{2},roi);
b				= regstats(mum,muf,'linear',{'beta','rsquare','tstat','fstat'});
str2			= ['Post-CI: R^2 = ' num2str(b.rsquare,2) ', p = ' num2str(b.fstat.pval,2)];
[~, P]			= fit_2D_data(muf, mum, 'no');
beta2			= P([2 1]);
plotdat(muf,mum,sdm,'ks')

%% Temporal Superior, V, Normal
sel		= strcmpi(g2normal,roi{1}) | strcmpi(g2normal,roi{2});
m		= munormal(sel);
c		= g1normal(sel);
sel2	= strcmpi(c,cond{2});
m		= m(sel2);
hold on
errorbar(100,mean(m),std(m)./sqrt(numel(m)),'kd','MarkerFaceColor','w','LineWidth',2,'MarkerSize',10);
axis square

axis([-10 110 70 100]) 
h = pa_regline(beta2','k-'); set(h,'LineWidth',2);
h = pa_regline(beta1','r-'); set(h,'LineWidth',2);
h		= pa_text(0.1,0.1,str2); set(h,'Color','k')
h		= pa_text(0.1,0.2,str1);set(h,'Color','r') 
box off;
xlabel('Phoneme score (%)');
ylabel('FDG'); 
set(gca,'XTick',0:20:100,'YTick',60:10:100);

function [mupre,gpre,g1pre,g2pre,g3pre,g4pre] = getpre(p)
%% -------------------- PRE HESCHL ---------------------------------
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	};
[mu_pre_control_heschl_left,var_pre_control_heschl_left] = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
[mu_pre_control_heschl_right,var_pre_control_heschl_right] = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
files = {'gswdro_s06-v-pre.img';'gswdro_s08-v-pre.img';...
	'gswdro_s09-v-pre.img';'gswdro_s10-v-pre.img';...
	'gswdro_s11-v-pre.img';'gswdro_s12-v-pre.img';...
	};
[mu_pre_vision_heschl_right,var_pre_vision_heschl_right] = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
[mu_pre_vision_heschl_left,var_pre_vision_heschl_left] = pa_pet_getmeandata(files,p,roiname);

%% Temporal superior gyrus
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	};
[mu_pre_control_ts_left,var_pre_control_ts_left] = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
[mu_pre_control_ts_right,var_pre_control_ts_right] = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s06-v-pre.img';'gswdro_s08-v-pre.img';...
	'gswdro_s09-v-pre.img';'gswdro_s10-v-pre.img';...
	'gswdro_s11-v-pre.img';'gswdro_s12-v-pre.img';...
	};
[mu_pre_vision_ts_right,var_pre_vision_ts_right] = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
[mu_pre_vision_ts_left,var_pre_vision_ts_left] = pa_pet_getmeandata(files,p,roiname);

%% Calcarine
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	};
[mu_pre_control_cs_left,var_pre_control_cs_left] = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
[mu_pre_control_cs_right,var_pre_control_cs_right] = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s06-v-pre.img';'gswdro_s08-v-pre.img';...
	'gswdro_s09-v-pre.img';'gswdro_s10-v-pre.img';...
	'gswdro_s11-v-pre.img';'gswdro_s12-v-pre.img';...
	};
[mu_pre_vision_cs_right,var_pre_vision_cs_right] = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
[mu_pre_vision_cs_left,var_pre_vision_cs_left] = pa_pet_getmeandata(files,p,roiname);

%%
mupre = [mu_pre_control_heschl_left; mu_pre_control_heschl_right;...
	mu_pre_vision_heschl_left; mu_pre_vision_heschl_right;...
	mu_pre_control_ts_left; mu_pre_control_ts_right;...
	mu_pre_vision_ts_left;mu_pre_vision_ts_right;...
	mu_pre_control_cs_left; mu_pre_control_cs_right;...
	mu_pre_vision_cs_left; mu_pre_vision_cs_right;...
	];

varpre = [var_pre_control_heschl_left; var_pre_control_heschl_right;...
	var_pre_vision_heschl_left; var_pre_vision_heschl_right;...
	var_pre_control_ts_left; var_pre_control_ts_right;...
	var_pre_vision_ts_left;var_pre_vision_ts_right;...
	var_pre_control_cs_left; var_pre_control_cs_right;...
	var_pre_vision_cs_left; var_pre_vision_cs_right;...
	]; %#ok<*NASGU>
g1pre = [repmat({'Control'},numel(mu_pre_control_heschl_left),1);...
repmat({'Control'},numel(mu_pre_control_heschl_right),1);...
repmat({'Vision'},numel(mu_pre_vision_heschl_right),1);...
repmat({'Vision'},numel(mu_pre_vision_heschl_right),1);...

repmat({'Control'},numel(mu_pre_control_ts_left),1);...
repmat({'Control'},numel(mu_pre_control_ts_right),1);...
repmat({'Vision'},numel(mu_pre_vision_ts_right),1);...
repmat({'Vision'},numel(mu_pre_vision_ts_right),1);...

repmat({'Control'},numel(mu_pre_control_cs_left),1);...
repmat({'Control'},numel(mu_pre_control_cs_right),1);...
repmat({'Vision'},numel(mu_pre_vision_cs_right),1);...
repmat({'Vision'},numel(mu_pre_vision_cs_right),1);...
	]; % Condition

g2pre = [repmat({'Heschl'},numel(mu_pre_control_heschl_left),1);...
repmat({'Heschl'},numel(mu_pre_control_heschl_right),1);...
repmat({'Heschl'},numel(mu_pre_vision_heschl_right),1);...
repmat({'Heschl'},numel(mu_pre_vision_heschl_right),1);...

repmat({'TemSup'},numel(mu_pre_control_ts_left),1);...
repmat({'TemSup'},numel(mu_pre_control_ts_right),1);...
repmat({'TemSup'},numel(mu_pre_vision_ts_right),1);...
repmat({'TemSup'},numel(mu_pre_vision_ts_right),1);...

repmat({'Calc'},numel(mu_pre_control_cs_left),1);...
repmat({'Calc'},numel(mu_pre_control_cs_right),1);...
repmat({'Calc'},numel(mu_pre_vision_cs_right),1);...
repmat({'Calc'},numel(mu_pre_vision_cs_right),1);...
	]; % Condition

g3pre = [repmat({'Left'},numel(mu_pre_control_heschl_left),1);...
repmat({'Right'},numel(mu_pre_control_heschl_right),1);...
repmat({'Left'},numel(mu_pre_vision_heschl_right),1);...
repmat({'Right'},numel(mu_pre_vision_heschl_right),1);...

repmat({'Left'},numel(mu_pre_control_heschl_left),1);...
repmat({'Right'},numel(mu_pre_control_heschl_right),1);...
repmat({'Left'},numel(mu_pre_vision_heschl_right),1);...
repmat({'Right'},numel(mu_pre_vision_heschl_right),1);...

repmat({'Left'},numel(mu_pre_control_heschl_left),1);...
repmat({'Right'},numel(mu_pre_control_heschl_right),1);...
repmat({'Left'},numel(mu_pre_vision_heschl_right),1);...
repmat({'Right'},numel(mu_pre_vision_heschl_right),1);...
	]; % Condition

g4pre = [1:numel(mu_pre_control_heschl_left),...
1:numel(mu_pre_control_heschl_left),...
1:numel(mu_pre_vision_heschl_left),...
1:numel(mu_pre_vision_heschl_left),...
1:numel(mu_pre_control_ts_left),...
1:numel(mu_pre_control_ts_left),...
1:numel(mu_pre_vision_ts_left),...
1:numel(mu_pre_vision_ts_left),...
1:numel(mu_pre_control_cs_left),...
1:numel(mu_pre_control_cs_left),...
1:numel(mu_pre_control_cs_left),...
1:numel(mu_pre_control_cs_left),...
]; % Condition

g4preindx	= [6 8 9 10 11 12];

g4pre		= g4preindx(g4pre);
gpre		= {g1pre g2pre g3pre g4pre};

function [mupost,gpost,g1post,g2post,g3post,g4post] = getpost(p)
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
files = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
mu_post_control_heschl_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
mu_post_control_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
files = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	};
mu_post_vision_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
mu_post_vision_heschl_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
files = {'gswdro_s07-av-post.img';'gswdro_s13-av-post.img';...
	'gswdro_s14-av-post.img';'gswdro_s15-av-post.img';...
	'gswdro_s16-av-post.img';...
	};
mu_post_av_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
mu_post_av_heschl_left = pa_pet_getmeandata(files,p,roiname);


%% Temporal superior gyrus
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
files = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
mu_post_control_ts_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
mu_post_control_ts_right = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	};
mu_post_vision_ts_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
mu_post_vision_ts_left = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s07-av-post.img';'gswdro_s13-av-post.img';...
	'gswdro_s14-av-post.img';'gswdro_s15-av-post.img';...
	'gswdro_s16-av-post.img';...
	};
mu_post_av_ts_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
mu_post_av_ts_right = pa_pet_getmeandata(files,p,roiname);

%% Calcarine
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
files = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
mu_post_control_cs_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
mu_post_control_cs_right = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	};
mu_post_vision_cs_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
mu_post_vision_cs_left = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s07-av-post.img';'gswdro_s13-av-post.img';...
	'gswdro_s14-av-post.img';'gswdro_s15-av-post.img';...
	'gswdro_s16-av-post.img';...
	};
mu_post_av_cs_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
mu_post_av_cs_right = pa_pet_getmeandata(files,p,roiname);


%%
mupost = [mu_post_control_heschl_left; mu_post_control_heschl_right;...
	mu_post_vision_heschl_left; mu_post_vision_heschl_right;...
	mu_post_av_heschl_left; mu_post_av_heschl_right;...
	mu_post_control_ts_left; mu_post_control_ts_right;...
	mu_post_vision_ts_left;mu_post_vision_ts_right;...
	mu_post_av_ts_left;mu_post_av_ts_right;...
	mu_post_control_cs_left; mu_post_control_cs_right;...
	mu_post_vision_cs_left; mu_post_vision_cs_right;...
	mu_post_av_cs_left; mu_post_av_cs_right;...
	];
g1post = [repmat({'Control'},numel(mu_post_control_heschl_left),1);...
repmat({'Control'},numel(mu_post_control_heschl_right),1);...
repmat({'Vision'},numel(mu_post_vision_heschl_right),1);...
repmat({'Vision'},numel(mu_post_vision_heschl_right),1);...
repmat({'AV'},numel(mu_post_av_heschl_right),1);...
repmat({'AV'},numel(mu_post_av_heschl_right),1);...

repmat({'Control'},numel(mu_post_control_ts_left),1);...
repmat({'Control'},numel(mu_post_control_ts_right),1);...
repmat({'Vision'},numel(mu_post_vision_ts_right),1);...
repmat({'Vision'},numel(mu_post_vision_ts_right),1);...
repmat({'AV'},numel(mu_post_av_ts_right),1);...
repmat({'AV'},numel(mu_post_av_ts_right),1);...

repmat({'Control'},numel(mu_post_control_cs_left),1);...
repmat({'Control'},numel(mu_post_control_cs_right),1);...
repmat({'Vision'},numel(mu_post_vision_cs_right),1);...
repmat({'Vision'},numel(mu_post_vision_cs_right),1);...
repmat({'AV'},numel(mu_post_av_cs_right),1);...
repmat({'AV'},numel(mu_post_av_cs_right),1);...
	]; % Condition

g2post = [repmat({'Heschl'},numel(mu_post_control_heschl_left),1);...
repmat({'Heschl'},numel(mu_post_control_heschl_right),1);...
repmat({'Heschl'},numel(mu_post_vision_heschl_right),1);...
repmat({'Heschl'},numel(mu_post_vision_heschl_right),1);...
repmat({'Heschl'},numel(mu_post_av_heschl_right),1);...
repmat({'Heschl'},numel(mu_post_av_heschl_right),1);...

repmat({'TemSup'},numel(mu_post_control_ts_left),1);...
repmat({'TemSup'},numel(mu_post_control_ts_right),1);...
repmat({'TemSup'},numel(mu_post_vision_ts_right),1);...
repmat({'TemSup'},numel(mu_post_vision_ts_right),1);...
repmat({'TemSup'},numel(mu_post_av_ts_right),1);...
repmat({'TemSup'},numel(mu_post_av_ts_right),1);...

repmat({'Calc'},numel(mu_post_control_cs_left),1);...
repmat({'Calc'},numel(mu_post_control_cs_right),1);...
repmat({'Calc'},numel(mu_post_vision_cs_right),1);...
repmat({'Calc'},numel(mu_post_vision_cs_right),1);...
repmat({'Calc'},numel(mu_post_av_cs_right),1);...
repmat({'Calc'},numel(mu_post_av_cs_right),1);...
	]; % Condition

g3post = [repmat({'Left'},numel(mu_post_control_heschl_left),1);...
repmat({'Right'},numel(mu_post_control_heschl_right),1);...
repmat({'Left'},numel(mu_post_vision_heschl_right),1);...
repmat({'Right'},numel(mu_post_vision_heschl_right),1);...
repmat({'Left'},numel(mu_post_av_heschl_right),1);...
repmat({'Right'},numel(mu_post_av_heschl_right),1);...

repmat({'Left'},numel(mu_post_control_heschl_left),1);...
repmat({'Right'},numel(mu_post_control_heschl_right),1);...
repmat({'Left'},numel(mu_post_vision_heschl_right),1);...
repmat({'Right'},numel(mu_post_vision_heschl_right),1);...
repmat({'Left'},numel(mu_post_av_heschl_right),1);...
repmat({'Right'},numel(mu_post_av_heschl_right),1);...

repmat({'Left'},numel(mu_post_control_heschl_left),1);...
repmat({'Right'},numel(mu_post_control_heschl_right),1);...
repmat({'Left'},numel(mu_post_vision_heschl_right),1);...
repmat({'Right'},numel(mu_post_vision_heschl_right),1);...
repmat({'Left'},numel(mu_post_av_heschl_right),1);...
repmat({'Right'},numel(mu_post_av_heschl_right),1);...
	]; % Condition

g4post = [1:numel(mu_post_control_heschl_left),...
1:numel(mu_post_control_heschl_left),...
1:numel(mu_post_vision_heschl_left),...
1:numel(mu_post_vision_heschl_left),...
1:numel(mu_post_av_heschl_left),...
1:numel(mu_post_av_heschl_left),...
1:numel(mu_post_control_ts_left),...
1:numel(mu_post_control_ts_left),...
1:numel(mu_post_vision_ts_left),...
1:numel(mu_post_vision_ts_left),...
1:numel(mu_post_av_ts_left),...
1:numel(mu_post_av_ts_left),...
1:numel(mu_post_control_cs_left),...
1:numel(mu_post_control_cs_left),...
1:numel(mu_post_vision_cs_left),...
1:numel(mu_post_vision_cs_left),...
1:numel(mu_post_av_cs_left),...
1:numel(mu_post_av_cs_left),...
]; % Condition

g4postindx	= [7 13 14 15 16];
g4post		= g4postindx(g4post);

gpost = {g1post g2post g3post g4post};

function [munormal,gnormal,g1normal,g2normal,g3normal,g4normal] = getnormal(p)

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
files = {'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'};
mu_normal_control_heschl_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
mu_normal_control_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
files = {'gswdro_s01-v-normal.img';'gswdro_s02-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img'};
mu_normal_vision_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
mu_normal_vision_heschl_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
files = {'gswdro_s01-av-normal.img';'gswdro_s03-av-normal.img';...
	'gswdro_s04-av-normal.img'};
mu_normal_av_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
mu_normal_av_heschl_left = pa_pet_getmeandata(files,p,roiname);

%% Temporal superior gyrus
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
files = {'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'};
mu_normal_control_ts_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
mu_normal_control_ts_right = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s01-v-normal.img';'gswdro_s02-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img'};
mu_normal_vision_ts_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
mu_normal_vision_ts_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
files = {'gswdro_s01-av-normal.img';'gswdro_s03-av-normal.img';...
	'gswdro_s04-av-normal.img'};
mu_normal_av_ts_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
mu_normal_av_ts_left = pa_pet_getmeandata(files,p,roiname);

%% Calcarine
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
files = {'gswdro_s01-c-normal.img';'gswdro_s02-c-normal.img';'gswdro_s03-c-normal.img';...
	'gswdro_s04-c-normal.img'};
mu_normal_control_cs_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
mu_normal_control_cs_right = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s01-v-normal.img';'gswdro_s02-v-normal.img';'gswdro_s03-v-normal.img';...
	'gswdro_s04-v-normal.img'};
mu_normal_vision_cs_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
mu_normal_vision_cs_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
files = {'gswdro_s01-av-normal.img';'gswdro_s03-av-normal.img';...
	'gswdro_s04-av-normal.img'};
mu_normal_av_cs_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
mu_normal_av_cs_left = pa_pet_getmeandata(files,p,roiname);


%%
munormal = [mu_normal_control_heschl_left; mu_normal_control_heschl_right;...
	mu_normal_vision_heschl_left; mu_normal_vision_heschl_right;...
	mu_normal_av_heschl_left; mu_normal_av_heschl_right;...
	mu_normal_control_ts_left; mu_normal_control_ts_right;...
	mu_normal_vision_ts_left;mu_normal_vision_ts_right;...
	mu_normal_av_ts_left;mu_normal_av_ts_right;...
	mu_normal_control_cs_left; mu_normal_control_cs_right;...
	mu_normal_vision_cs_left; mu_normal_vision_cs_right;...
	mu_normal_av_cs_left; mu_normal_av_cs_right;...
	];
g1normal = [repmat({'Control'},numel(mu_normal_control_heschl_left),1);...
repmat({'Control'},numel(mu_normal_control_heschl_right),1);...
repmat({'Vision'},numel(mu_normal_vision_heschl_right),1);...
repmat({'Vision'},numel(mu_normal_vision_heschl_right),1);...
repmat({'AV'},numel(mu_normal_av_heschl_right),1);...
repmat({'AV'},numel(mu_normal_av_heschl_right),1);...

repmat({'Control'},numel(mu_normal_control_ts_left),1);...
repmat({'Control'},numel(mu_normal_control_ts_right),1);...
repmat({'Vision'},numel(mu_normal_vision_ts_right),1);...
repmat({'Vision'},numel(mu_normal_vision_ts_right),1);...
repmat({'AV'},numel(mu_normal_av_ts_right),1);...
repmat({'AV'},numel(mu_normal_av_ts_right),1);...

repmat({'Control'},numel(mu_normal_control_cs_left),1);...
repmat({'Control'},numel(mu_normal_control_cs_right),1);...
repmat({'Vision'},numel(mu_normal_vision_cs_right),1);...
repmat({'Vision'},numel(mu_normal_vision_cs_right),1);...
repmat({'AV'},numel(mu_normal_av_cs_right),1);...
repmat({'AV'},numel(mu_normal_av_cs_right),1);...
	]; % Condition

g2normal = [repmat({'Heschl'},numel(mu_normal_control_heschl_left),1);...
repmat({'Heschl'},numel(mu_normal_control_heschl_right),1);...
repmat({'Heschl'},numel(mu_normal_vision_heschl_right),1);...
repmat({'Heschl'},numel(mu_normal_vision_heschl_right),1);...
repmat({'Heschl'},numel(mu_normal_av_heschl_right),1);...
repmat({'Heschl'},numel(mu_normal_av_heschl_right),1);...

repmat({'TemSup'},numel(mu_normal_control_ts_left),1);...
repmat({'TemSup'},numel(mu_normal_control_ts_right),1);...
repmat({'TemSup'},numel(mu_normal_vision_ts_right),1);...
repmat({'TemSup'},numel(mu_normal_vision_ts_right),1);...
repmat({'TemSup'},numel(mu_normal_av_ts_right),1);...
repmat({'TemSup'},numel(mu_normal_av_ts_right),1);...

repmat({'Calc'},numel(mu_normal_control_cs_left),1);...
repmat({'Calc'},numel(mu_normal_control_cs_right),1);...
repmat({'Calc'},numel(mu_normal_vision_cs_right),1);...
repmat({'Calc'},numel(mu_normal_vision_cs_right),1);...
repmat({'Calc'},numel(mu_normal_av_cs_right),1);...
repmat({'Calc'},numel(mu_normal_av_cs_right),1);...
	]; % Condition

g3normal = [repmat({'Left'},numel(mu_normal_control_heschl_left),1);...
repmat({'Right'},numel(mu_normal_control_heschl_right),1);...
repmat({'Left'},numel(mu_normal_vision_heschl_right),1);...
repmat({'Right'},numel(mu_normal_vision_heschl_right),1);...
repmat({'Left'},numel(mu_normal_av_heschl_right),1);...
repmat({'Right'},numel(mu_normal_av_heschl_right),1);...

repmat({'Left'},numel(mu_normal_control_heschl_left),1);...
repmat({'Right'},numel(mu_normal_control_heschl_right),1);...
repmat({'Left'},numel(mu_normal_vision_heschl_right),1);...
repmat({'Right'},numel(mu_normal_vision_heschl_right),1);...
repmat({'Left'},numel(mu_normal_av_heschl_right),1);...
repmat({'Right'},numel(mu_normal_av_heschl_right),1);...

repmat({'Left'},numel(mu_normal_control_heschl_left),1);...
repmat({'Right'},numel(mu_normal_control_heschl_right),1);...
repmat({'Left'},numel(mu_normal_vision_heschl_right),1);...
repmat({'Right'},numel(mu_normal_vision_heschl_right),1);...
repmat({'Left'},numel(mu_normal_av_heschl_right),1);...
repmat({'Right'},numel(mu_normal_av_heschl_right),1);...
	]; % Condition

g4normal = [1:numel(mu_normal_control_heschl_left),...
1:numel(mu_normal_control_heschl_left),...
1:numel(mu_normal_vision_heschl_left),...
1:numel(mu_normal_vision_heschl_left),...
1:numel(mu_normal_av_heschl_left),...
1:numel(mu_normal_av_heschl_left),...
1:numel(mu_normal_control_ts_left),...
1:numel(mu_normal_control_ts_left),...
1:numel(mu_normal_vision_ts_left),...
1:numel(mu_normal_vision_ts_left),...
1:numel(mu_normal_av_ts_left),...
1:numel(mu_normal_av_ts_left),...
1:numel(mu_normal_control_cs_left),...
1:numel(mu_normal_control_cs_left),...
1:numel(mu_normal_vision_cs_left),...
1:numel(mu_normal_vision_cs_left),...
1:numel(mu_normal_av_cs_left),...
1:numel(mu_normal_av_cs_left),...
]; % Condition

g4normalindx	= [1 2 3 4];
g4normal		= g4normalindx(g4normal);

gnormal = {g1normal g2normal g3normal g4normal};

function activationplotleft(mupre,gpre,mupost,gpost,munormal,gnormal) %#ok<*DEFNU>

M = [];
C = [];

%% VISION RE BASELINE

%% Normalize activation to baseline
% Create selection vector for VISION HESCHL LEFT
selpre		= strcmpi(gpre{1},'Vision') & strcmpi(gpre{2},'Heschl')  & strcmpi(gpre{3},'Left');
selpost		= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Left');
selnormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Left');
selbasepre	= strcmpi(gpre{1},'Control') & strcmpi(gpre{2},'Heschl')  & strcmpi(gpre{3},'Left');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Left');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Left');
VCpre		= mupre(selpre)./mupre(selbasepre);
VCpost		= mupost(selpost)./mupost(selbasepost);
VCnormal	= munormal(selnormal)./munormal(selbasenormal);
% percentage mean and std
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


%% Normalize activation to baseline
% Create selection vector for VISION TEMPORALE SUPERIOR LEFT
selpre		= strcmpi(gpre{1},'Vision') & strcmpi(gpre{2},'TemSup')  & strcmpi(gpre{3},'Left');
selpost		= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Left');
selnormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Left');
selbasepre	= strcmpi(gpre{1},'Control') & strcmpi(gpre{2},'TemSup')  & strcmpi(gpre{3},'Left');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Left');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Left');
VCpre		= mupre(selpre)./mupre(selbasepre);
VCpost		= mupost(selpost)./mupost(selbasepost);
VCnormal	= munormal(selnormal)./munormal(selbasenormal);
% percentage mean and std
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

%% Normalize activation to baseline
% Create selection vector for VISION CALCARINE LEFT
selpre		= strcmpi(gpre{1},'Vision') & strcmpi(gpre{2},'Calc')  & strcmpi(gpre{3},'Left');
selpost		= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Left');
selnormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Left');
selbasepre	= strcmpi(gpre{1},'Control') & strcmpi(gpre{2},'Calc')  & strcmpi(gpre{3},'Left');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Left');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Left');
VCpre		= mupre(selpre)./mupre(selbasepre);
VCpost		= mupost(selpost)./mupost(selbasepost);
VCnormal	= munormal(selnormal)./munormal(selbasenormal);
% percentage mean and std
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


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
set(gca,'XTick',1:3,'XTickLabel',{'H';'T';'C'});


%% AV RE BASELINE
M = [];
C = [];

%% Normalize activation to baseline
% Create selection vector for VISION HESCHL LEFT
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Left');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Left');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Left');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Left');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


%% Normalize activation to baseline
% Create selection vector for AV TEMPORALE SUPERIOR LEFT
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Left');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Left');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Left');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Left');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

%% Normalize activation to baseline
% Create selection vector for AV CALCARINE LEFT
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Left');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Left');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Left');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Left');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
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
set(gca,'XTick',1:3,'XTickLabel',{'H';'T';'C'});

%% AV-Vision
M = [];
C = [];

%% Normalize activation to baseline
% Create selection vector for VISION HESCHL LEFT
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Left');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Left');
selbasepost	= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Left');
selbasenormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Left');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


%% Normalize activation to baseline
% Create selection vector for AV TEMPORALE SUPERIOR LEFT
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Left');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Left');
selbasepost	= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Left');
selbasenormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Left');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

%% Normalize activation to baseline
% Create selection vector for AV CALCARINE LEFT
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Left');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Left');
selbasepost	= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Left');
selbasenormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Left');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
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
set(gca,'XTick',1:3,'XTickLabel',{'H';'T';'C'});

figure(101)
for ii = 1:6
	subplot(3,2,ii)
	box off;
	ylim([-5 20]);
	pa_text(0.1,0.9,char(96+ii));
end

pa_datadir;
print('-depsc',[mfilename 'PET']);

function activationplotright(mupre,gpre,mupost,gpost,munormal,gnormal)

M = [];
C = [];

%% VISION RE BASELINE

%% Normalize activation to baseline
% Create selection vector for VISION HESCHL LEFT
selpre		= strcmpi(gpre{1},'Vision') & strcmpi(gpre{2},'Heschl')  & strcmpi(gpre{3},'Right');
selpost		= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Right');
selnormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Right');
selbasepre	= strcmpi(gpre{1},'Control') & strcmpi(gpre{2},'Heschl')  & strcmpi(gpre{3},'Right');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Right');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Right');
VCpre		= mupre(selpre)./mupre(selbasepre);
VCpost		= mupost(selpost)./mupost(selbasepost);
VCnormal	= munormal(selnormal)./munormal(selbasenormal);
% percentage mean and std
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


%% Normalize activation to baseline
% Create selection vector for VISION TEMPORALE SUPERIOR Right
selpre		= strcmpi(gpre{1},'Vision') & strcmpi(gpre{2},'TemSup')  & strcmpi(gpre{3},'Right');
selpost		= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Right');
selnormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Right');
selbasepre	= strcmpi(gpre{1},'Control') & strcmpi(gpre{2},'TemSup')  & strcmpi(gpre{3},'Right');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Right');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Right');
VCpre		= mupre(selpre)./mupre(selbasepre);
VCpost		= mupost(selpost)./mupost(selbasepost);
VCnormal	= munormal(selnormal)./munormal(selbasenormal);
% percentage mean and std
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

%% Normalize activation to baseline
% Create selection vector for VISION CALCARINE Right
selpre		= strcmpi(gpre{1},'Vision') & strcmpi(gpre{2},'Calc')  & strcmpi(gpre{3},'Right');
selpost		= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Right');
selnormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Right');
selbasepre	= strcmpi(gpre{1},'Control') & strcmpi(gpre{2},'Calc')  & strcmpi(gpre{3},'Right');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Right');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Right');
VCpre		= mupre(selpre)./mupre(selbasepre);
VCpost		= mupost(selpost)./mupost(selbasepost);
VCnormal	= munormal(selnormal)./munormal(selbasenormal);
% percentage mean and std
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


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
set(gca,'XTick',1:3,'XTickLabel',{'H';'T';'C'});


%% AV RE BASELINE
M = [];
C = [];

%% Normalize activation to baseline
% Create selection vector for VISION HESCHL Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Right');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Right');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Right');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Right');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


%% Normalize activation to baseline
% Create selection vector for AV TEMPORALE SUPERIOR Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Right');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Right');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Right');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Right');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

%% Normalize activation to baseline
% Create selection vector for AV CALCARINE Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Right');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Right');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Right');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Right');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
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
set(gca,'XTick',1:3,'XTickLabel',{'H';'T';'C'});

%% AV-Vision
M = [];
C = [];

%% Normalize activation to baseline
% Create selection vector for VISION HESCHL Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Right');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Right');
selbasepost	= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Heschl')  & strcmpi(gpost{3},'Right');
selbasenormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Heschl')  & strcmpi(gnormal{3},'Right');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


%% Normalize activation to baseline
% Create selection vector for AV TEMPORALE SUPERIOR Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Right');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Right');
selbasepost	= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'TemSup')  & strcmpi(gpost{3},'Right');
selbasenormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'TemSup')  & strcmpi(gnormal{3},'Right');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

%% Normalize activation to baseline
% Create selection vector for AV CALCARINE Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Right');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Right');
selbasepost	= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Calc')  & strcmpi(gpost{3},'Right');
selbasenormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Calc')  & strcmpi(gnormal{3},'Right');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
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
set(gca,'XTick',1:3,'XTickLabel',{'H';'T';'C'});

figure(102) 
for ii = 1:6
	subplot(3,2,ii)
	box off;
	ylim([-5 20]);
	pa_text(0.1,0.9,char(96+ii));
end

pa_datadir;
print('-depsc',[mfilename 'PET']);

function plotdat(muf,mum,sdm,mrk)

N = 50;
hold on
axis square
n = numel(mum);
p = NaN(n,2);
for ii = 1:n
	R = binornd(N,muf(ii)/100,1000,1);
	R = R*100/N;
	
	p(ii,:) = prctile(R,[2.5 97.5]);
% 	plot([p(ii,1) p(ii,2)],[mum(ii) mum(ii)],[mrk(1) '-'],'LineWidth',1);
	hold on
	
	Mu = [muf(ii) mum(ii)];
	b = p(ii,2)-muf(ii);
	a = muf(ii)-p(ii,1);
	c = a+b;
	SD = [c/2 sdm(ii)];
	a = a/c*2;
	b = b/c*2;
	x = a-b;
	h = drawOval(Mu,SD,x,'Color',mrk(1));
	
end
% errorbar(muf,mum,sdm,mrk,'MarkerFaceColor','w','LineWidth',1,'MarkerSize',5);
plot(muf,mum,mrk,'MarkerFaceColor','w','LineWidth',1,'MarkerSize',5);

function [muf,mum,sdm] = getdat(mupre,g2pre,g4pre,g1pre,F,cond,roi)

sel		= strcmpi(g2pre,roi{1}) | strcmpi(g2pre,roi{2});
m		= mupre(sel);
% v		= varpre(sel);
s		= g4pre(sel); % score
c		= g1pre(sel);
f		= F(s);
sel2	= strcmpi(c,cond);
m		= m(sel2);
% v		= v(sel2);
f		= f(sel2);
s		= s(sel2);

us		= unique(s);
ns		= numel(us);
mum		= NaN(ns,1);
sdm		= mum;
muf		= mum;
for ii	= 1:ns
	sel		= s == us(ii);
	mum(ii) = mean(m(sel));
	sdm(ii) = 1.96*std(m(sel))./sqrt(sum(sel));
	muf(ii) = unique(f(sel));
end
[muf,indx]	= sort(muf);
mum			= mum(indx);
sdm			= sdm(indx);

function h = drawOval(Mu,SD,x,varargin)
% PA_ELLIPSEPLOY(MU,SD,A)
%
%  draw an ellipse with long and short axes SD(1) and SD(2)
%  with orientation A (in deg) at point Mu(1),Mu(2).
%
% see also PA_ELLIPSE

% 2011  Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

if nargin<1
	Mu = [0 0];
	SD = [1 1];
end
%% Initialization
col         = pa_keyval('Color',varargin);
if isempty(col)
    col = 'k';
end
Xo	= Mu(1);
Yo	= Mu(2);
Xr	= SD(1);
Yr	= SD(2);
DTR = pi/180;

%% Ellipse
wt  = (0:.1:360).*DTR;
X   = cos(wt);
Y   = sin(wt);

% % x&2/a^2+y^2*t(x)/b^2=1
t = 1./(1-x*X);
% t = exp(x*X);
Y = Y.*t;

X = Xr*(X-x/2)+Xo;
Y = Yr*Y+Yo;
%% Graphics
h = patch(X,Y,col);
hold on
alpha(h,.2);
set(h,'EdgeColor','w','LineWidth',2);

