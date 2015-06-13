function pa_pet_monster_anova
%% Initialization
close all force
clear all
p					= 'E:\DATA\KNO\PET\swdro files\';

%% Data
[mupre,gpre,g1pre,g2pre,g3pre,g4pre]					= getpre(p);
[mupost,gpost,g1post,g2post,g3post,g4post]				= getpost(p);
[munormal,gnormal,g1normal,g2normal,g3normal,g4normal]	= getnormal(p);

%% Plots
activationplotleft(mupre,gpre,mupost,gpost,munormal,gnormal);
activationplotright(mupre,gpre,mupost,gpost,munormal,gnormal);
activationplotboth(mupre,gpre,mupost,gpost,munormal,gnormal);

figure(101)
colormap('autumn');
figure(102)
colormap('autumn');
figure(103)
colormap('autumn');

% %% Stats
% [pval,t,stats]		= anovan(mupre,gpre,'model','full','random',4,'varnames',{'Condition';'Area';'Laterality';'Subject'});
% [c,m,h,nms]			= multcompare(stats,'dimension',[1 2]);
% [nms num2cell(m)]
% 
% [pval,t,stats]		= anovan(mupost,gpost,'model','full','random',4,'varnames',{'Condition';'Area';'Laterality';'Subject'});
% [c,m,h,nms]			= multcompare(stats,'dimension',[1 2]);
% [nms num2cell(m)]
% 
% [pval,t,stats]		= anovan(munormal,gnormal,'model','full','random',4,'varnames',{'Condition';'Area';'Laterality';'Subject'});
% [c,m,h,nms]			= multcompare(stats,'dimension',[1 2]);
% [nms num2cell(m)]

figure
%% Stats
gpret = gpre([1 2 4]);
[~,~,stats]		= anovan(mupre,gpret,'model','interaction','random',3,'varnames',{'Condition';'Area';'Subject'});
[~,m,h,nms]			= multcompare(stats,'dimension',[1 2]); %#ok<*ASGLU>
[nms num2cell(m)] %#ok<*NOPRT>

gpostt = gpost([1 2 4]);
[pval,t,stats]		= anovan(mupost,gpostt,'model','interaction','random',3,'varnames',{'Condition';'Area';'Subject'});
[c,m,h,nms]			= multcompare(stats,'dimension',[1 2]);
[nms num2cell(m)]

gnormalt = gnormal([1 2 4]);
[pval,t,stats]		= anovan(munormal,gnormalt,'model','interaction','random',3,'varnames',{'Condition';'Area';'Subject'});
[c,m,h,nms]			= multcompare(stats,'dimension',[1 2]);
[nms num2cell(m)]


figure;
% Everything
g1 = [g1pre;g1post;g1normal]; % Condition
g2 = [g2pre;g2post;g2normal]; % ROI
g3 = [g3pre;g3post;g3normal]; % Laterality
g4 = [g4pre g4post g4normal]'; % Subject
g5 = [repmat({'Pre'},numel(g1pre),1);...
	repmat({'Post'},numel(g1post),1);...
	repmat({'normal'},numel(g1normal),1);...
	]; % Group
mu = [mupre;mupost;munormal]; % Activation

%% Combined Group effects
pval = anovan(mu,{g1 g2 g3 g4 g5},'model','interaction','random',4,'varnames',{'Condition';'Area';'Laterality';'Subject';'Group'}); %#ok<NASGU>

sel = strcmpi(g2,'Heschl');
[pval,t,stats]		= anovan(mu(sel),{g1(sel) g4(sel) g5(sel)},'model','interaction','random',2,'varnames',{'Condition';'Subject';'Group'});
[c,m,h,nms]			= multcompare(stats,'dimension',[1 3]);
[nms num2cell(m)]

sel = strcmpi(g2,'TemSup');
[pval,t,stats]		= anovan(mu(sel),{g1(sel) g4(sel) g5(sel)},'model','interaction','random',2,'varnames',{'Condition';'Subject';'Group'});
[c,m,h,nms]			= multcompare(stats,'dimension',[1 3]);
[nms num2cell(m)]

sel = strcmpi(g2,'Calc');
[pval,t,stats]		= anovan(mu(sel),{g1(sel) g4(sel) g5(sel)},'model','interaction','random',2,'varnames',{'Condition';'Subject';'Group'});
[c,m,h,nms]			= multcompare(stats,'dimension',[1 3]);
[nms num2cell(m)]

% keyboard

function [mupre,gpre,g1pre,g2pre,g3pre,g4pre] = getpre(p)
%% -------------------- PRE HESCHL ---------------------------------
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	};
mu_pre_control_heschl_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
mu_pre_control_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_R_roi.mat';
files = {'gswdro_s06-v-pre.img';'gswdro_s08-v-pre.img';...
	'gswdro_s09-v-pre.img';'gswdro_s10-v-pre.img';...
	'gswdro_s11-v-pre.img';'gswdro_s12-v-pre.img';...
	};
mu_pre_vision_heschl_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Heschl_L_roi.mat';
mu_pre_vision_heschl_left = pa_pet_getmeandata(files,p,roiname);

%% Temporal superior gyrus
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	};
mu_pre_control_ts_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_R_roi.mat';
mu_pre_control_ts_right = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s06-v-pre.img';'gswdro_s08-v-pre.img';...
	'gswdro_s09-v-pre.img';'gswdro_s10-v-pre.img';...
	'gswdro_s11-v-pre.img';'gswdro_s12-v-pre.img';...
	};
mu_pre_vision_ts_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Temporal_Sup_L_roi.mat';
mu_pre_vision_ts_left = pa_pet_getmeandata(files,p,roiname);

%% Calcarine
roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
files		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	};
mu_pre_control_cs_left = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_R_roi.mat';
mu_pre_control_cs_right = pa_pet_getmeandata(files,p,roiname);

files = {'gswdro_s06-v-pre.img';'gswdro_s08-v-pre.img';...
	'gswdro_s09-v-pre.img';'gswdro_s10-v-pre.img';...
	'gswdro_s11-v-pre.img';'gswdro_s12-v-pre.img';...
	};
mu_pre_vision_cs_right = pa_pet_getmeandata(files,p,roiname);

roiname		= 'E:\DATA\KNO\PET\marsbar-aal\MNI_Calcarine_L_roi.mat';
mu_pre_vision_cs_left = pa_pet_getmeandata(files,p,roiname);

%%
mupre = [mu_pre_control_heschl_left; mu_pre_control_heschl_right;...
	mu_pre_vision_heschl_left; mu_pre_vision_heschl_right;...
	mu_pre_control_ts_left; mu_pre_control_ts_right;...
	mu_pre_vision_ts_left;mu_pre_vision_ts_right;...
	mu_pre_control_cs_left; mu_pre_control_cs_right;...
	mu_pre_vision_cs_left; mu_pre_vision_cs_right;...
	];
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

gpre = {g1pre g2pre g3pre g4pre};

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
]+10; % Condition

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
]+20; % Condition
gnormal = {g1normal g2normal g3normal g4normal};

function activationplotleft(mupre,gpre,mupost,gpost,munormal,gnormal)

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

function activationplotboth(mupre,gpre,mupost,gpost,munormal,gnormal)

M = [];
C = [];

%% VISION RE BASELINE

%% Normalize activation to baseline
% Create selection vector for VISION HESCHL LEFT
selpre		= strcmpi(gpre{1},'Vision') & strcmpi(gpre{2},'Heschl');
selpost		= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Heschl');
selnormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Heschl');
selbasepre	= strcmpi(gpre{1},'Control') & strcmpi(gpre{2},'Heschl');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Heschl');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Heschl');
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
selpre		= strcmpi(gpre{1},'Vision') & strcmpi(gpre{2},'TemSup');
selpost		= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'TemSup');
selnormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'TemSup');
selbasepre	= strcmpi(gpre{1},'Control') & strcmpi(gpre{2},'TemSup');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'TemSup') ;
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'TemSup');
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
selpre		= strcmpi(gpre{1},'Vision') & strcmpi(gpre{2},'Calc') ;
selpost		= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Calc') ;
selnormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Calc');
selbasepre	= strcmpi(gpre{1},'Control') & strcmpi(gpre{2},'Calc');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Calc');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Calc');
VCpre		= mupre(selpre)./mupre(selbasepre);
VCpost		= mupost(selpost)./mupost(selbasepost);
VCnormal	= munormal(selnormal)./munormal(selbasenormal);
% percentage mean and std
mu			= 100*([mean(VCpre) mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpre)/sqrt(numel(VCpre)) std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


figure(103) 
subplot(3,2,1)
pa_errorbar(M',C');
axis square;
% legend({'Heschl G';'Temp Sup G';'Calcarine S'});
set(gca,'XTick',1:3,'XTickLabel',{'Pre';'Post';'Normal'});
ylabel('Cortical activation (%)');
title('Vision re Baseline');

subplot(3,2,2)
pa_errorbar(M,C);
axis square;
colormap('gray');
% legend({'Pre';'Post';'Normal'});
title('Vision re Baseline');
set(gca,'XTick',1:3,'XTickLabel',{'H';'T';'C'});


%% AV RE BASELINE
M = [];
C = [];

%% Normalize activation to baseline
% Create selection vector for VISION HESCHL Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Heschl');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Heschl');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Heschl') ;
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Heschl');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
whos mu mub
VCnormal	= mu./mub([1 3 4 5 7 8]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


%% Normalize activation to baseline
% Create selection vector for AV TEMPORALE SUPERIOR Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'TemSup');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'TemSup');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'TemSup');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'TemSup');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4 5 7 8]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

%% Normalize activation to baseline
% Create selection vector for AV CALCARINE Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Calc') ;
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Calc');
selbasepost	= strcmpi(gpost{1},'Control') & strcmpi(gpost{2},'Calc');
selbasenormal	= strcmpi(gnormal{1},'Control') & strcmpi(gnormal{2},'Calc');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4 5 7 8]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];



M			= [[0 0 0]' M];
C			= [[0 0 0]' C];


figure(103) 
subplot(3,2,3)
pa_errorbar(M',C');
axis square;
% legend({'Heschl G';'Temp Sup G';'Calcarine S'});
set(gca,'XTick',1:3,'XTickLabel',{'Pre';'Post';'Normal'});
ylabel('Cortical activation (%)');
title('Audiovisual re Baseline');

subplot(3,2,4)
pa_errorbar(M,C);
axis square;
colormap('gray');
% legend({'Pre';'Post';'Normal'});
title('Audiovisual re Baseline');
set(gca,'XTick',1:3,'XTickLabel',{'H';'T';'C'});

%% AV-Vision
M = [];
C = [];

%% Normalize activation to baseline
% Create selection vector for VISION HESCHL Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Heschl');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Heschl');
selbasepost	= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Heschl');
selbasenormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Heschl');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4 5 7 8]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];


%% Normalize activation to baseline
% Create selection vector for AV TEMPORALE SUPERIOR Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'TemSup');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'TemSup');
selbasepost	= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'TemSup');
selbasenormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'TemSup');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4 5 7 8]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];

%% Normalize activation to baseline
% Create selection vector for AV CALCARINE Right
selpost		= strcmpi(gpost{1},'AV') & strcmpi(gpost{2},'Calc');
selnormal	= strcmpi(gnormal{1},'AV') & strcmpi(gnormal{2},'Calc');
selbasepost	= strcmpi(gpost{1},'Vision') & strcmpi(gpost{2},'Calc');
selbasenormal	= strcmpi(gnormal{1},'Vision') & strcmpi(gnormal{2},'Calc');
VCpost		= mupost(selpost)./mupost(selbasepost);
mu			= munormal(selnormal);
mub			= munormal(selbasenormal);
VCnormal	= mu./mub([1 3 4 5 7 8]); % Check this!
% percentage mean and std
mu			= 100*([mean(VCpost) mean(VCnormal)]-1);
sem			= 100*([std(VCpost)/sqrt(numel(VCpost)) std(VCnormal)/sqrt(numel(VCnormal))]);
ci95		= 1.96*sem;
M			= [M;mu];
C			= [C;ci95];



M			= [[0 0 0]' M];
C			= [[0 0 0]' C];

figure(103) 
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

figure(103) 
for ii = 1:6
	subplot(3,2,ii)
	box off;
	ylim([-5 20]);
	pa_text(0.1,0.9,char(96+ii));
end

pa_datadir;
print('-depsc',[mfilename 'PET']);
