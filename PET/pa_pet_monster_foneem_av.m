function pa_pet_monster_foneem_av
%% Initialization
close all force
clear all
p					= 'E:\DATA\KNO\PET\swdro files\';

%% Data
[mupre,gpre,g1pre,g2pre,g3pre,g4pre]					= getpre(p);
[mupost,~,g1post,g2post,g3post,g4post]		= getpost(p);
[munormal,~,g1normal,g2normal]			= getnormal(p);

% keyboard
col = summer(5);

subplot(331)
h1 = plotfoneem(mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,'TemSup','Control',col(1,:),'o',0);
title('Temporal Superior Sulcus');

h2 = plotfoneem(mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,'TemSup','Vision',col(2,:),'s',0.1);

h3 = plotfoneem(mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,'TemSup','AV',col(3,:),'d',0.2);

legend([h1,h2,h3],{'Control','Vision','AV'});

subplot(332)
plotfoneem(mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,'Heschl','Control',col(1,:),'o',0);
title('Heschl''s Gyrus');

plotfoneem(mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,'Heschl','Vision',col(2,:),'s',0.1);

plotfoneem(mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,'Heschl','AV',col(3,:),'d',0.2);

subplot(333)
plotfoneem(mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,'Calc','Control',col(1,:),'o',0);
title('Calcarine Sulcus');

plotfoneem(mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,'Calc','Vision',col(2,:),'s',0.1);

plotfoneem(mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,'Calc','AV',col(3,:),'d',0.2);

%% Difference
subplot(334)
h3 = plotfoneem2(mupost,g1post,g2post,g3post,g4post,'TemSup','Control','AV','k','d',0.2);

subplot(335)
h3 = plotfoneem2(mupost,g1post,g2post,g3post,g4post,'Heschl','Control','AV','k','d',0.2);
title('AV-Control');

subplot(336)
h3 = plotfoneem2(mupost,g1post,g2post,g3post,g4post,'Calc','Control','AV','k','d',0.2);

subplot(337)
h3 = plotfoneem2(mupost,g1post,g2post,g3post,g4post,'TemSup','Vision','AV','k','d',0.2);

subplot(338)
h3 = plotfoneem2(mupost,g1post,g2post,g3post,g4post,'Heschl','Vision','AV','k','d',0.2);
title('AV-Vision');

subplot(339)
h3 = plotfoneem2(mupost,g1post,g2post,g3post,g4post,'Calc','Vision','AV','k','d',0.2);


pa_datadir;
print('-depsc',mfilename);

% keyboard

figure;
subplot(131)
h1 = plotfoneem2(mupost,g1post,g2post,g3post,g4post,'TemSup','Control','Vision','k','s',10);

subplot(132)
h2 = plotfoneem2(mupost,g1post,g2post,g3post,g4post,'Heschl','Control','Vision','k','s',10);
title('Vision-Control');
subplot(133)
h3 = plotfoneem2(mupost,g1post,g2post,g3post,g4post,'Calc','Control','Vision','k','s',0);


subplot(131)
h4 = plotfoneem2(mupre,g1pre,g2pre,g3pre,g4pre,'TemSup','Control','Vision','r','o',12,'Pre');

subplot(132)
h5 = plotfoneem2(mupre,g1pre,g2pre,g3pre,g4pre,'Heschl','Control','Vision','r','o',12,'Pre');
title('Vision-Control');
subplot(133)
h6 = plotfoneem2(mupre,g1pre,g2pre,g3pre,g4pre,'Calc','Control','Vision','r','o',2,'Pre');

legend([h3,h6],{'Post','Pre'});
function hp = plotfoneem(mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,roi,cond,col,mrk,off)

% F = [100 100 100 100 0 51 3 65 7 3 15 13.5 52 67 85 28];
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02


%% Temporal Superior, V, Post-Implant
sel		= strcmpi(g2post,roi);
m		= mupost(sel);
s		= g4post(sel);
c		= g1post(sel);
f		= F(s);
sel2	= strcmpi(c,cond);
m		= m(sel2);
f		= f(sel2);
hold on
hp = plot(f,m,mrk,'MarkerFaceColor','w','LineWidth',2,'MarkerSize',5,'Color',col);
axis square
b		= regstats(m,f,'linear',{'beta','rsquare','tstat','fstat'});
beta	= b.beta;
str2		= ['Post : R^2 = ' num2str(b.rsquare,2) ', F_{df='  num2str(b.fstat.dfe,2)  '} = ' num2str(b.fstat.f,2) ', p = ' num2str(b.fstat.pval,2)];

%% Temporal Superior, V, Normal
sel		= strcmpi(g2normal,roi);
m		= munormal(sel);
c		= g1normal(sel);
sel2	= strcmpi(c,cond);
m		= m(sel2);
hold on
errorbar(100-5+off*50,mean(m),std(m),mrk,'MarkerFaceColor','w','LineWidth',2,'MarkerSize',10,'Color',col);
axis square

axis([-10 110 50 110]) 
h = pa_regline(beta,'-'); set(h,'LineWidth',2,'Color',col);
h		= pa_text(0.1,0.1+off,str2); set(h,'Color',col)
box off;
xlabel('Phoneme score (%)');
ylabel('FDG'); 
% title({'Temporal Superior Sulcus';'Control'});
set(gca,'XTick',0:20:100,'YTick',60:10:100);

function hp = plotfoneem2(mupost,g1post,g2post,g3post,g4post,roi,cond1,cond2,col,mrk,off,txt)
if nargin<12
	txt = 'Post';
end
% F = [100 100 100 100 0 51 3 65 7 3 15 13.5 52 67 85 28];
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02

% keyboard
%% Temporal Superior, V, Post-Implant
sel		= strcmpi(g2post,roi);
m		= mupost(sel);
s		= g4post(sel);
l		= g3post(sel);
c		= g1post(sel);
f		= F(s);

sel2	= strcmpi(c,cond1);
m1		= m(sel2);
f1		= f(sel2);
s1		= s(sel2);
l1		= l(sel2);

sel3	= strcmpi(c,cond2);
m2		= m(sel3);
f2		= f(sel3);
s2		= s(sel3);
l2		= l(sel3);

d = m2-m1;
f = f1;
hold on
hp = plot(f,d,mrk,'MarkerFaceColor','w','LineWidth',2,'MarkerSize',5,'Color',col);
axis square
b		= regstats(d,f,'linear',{'beta','rsquare','tstat','fstat'});
beta	= b.beta;
str2		= [txt ': R^2 = ' num2str(b.rsquare,2) ', F_{df='  num2str(b.fstat.dfe,2)  '} = ' num2str(b.fstat.f,2) ', p = ' num2str(b.fstat.pval,2)];

% %% Temporal Superior, V, Normal
% sel		= strcmpi(g2normal,roi);
% m		= munormal(sel);
% c		= g1normal(sel);
% sel2	= strcmpi(c,cond);
% m		= m(sel2);
% hold on
% errorbar(100,mean(m),std(m),mrk,'MarkerFaceColor','w','LineWidth',2,'MarkerSize',10,'Color',col);
% axis square

axis([-10 110 -5 16]) 
h = pa_regline(beta,'-'); set(h,'LineWidth',2,'Color',col);
box off;
xlabel('Phoneme score (%)');
ylabel('FDG Difference'); 

h		= text(0,-3+off,str2); set(h,'Color',col)
set(gca,'XTick',0:20:100,'YTick',-5:5:10);

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
