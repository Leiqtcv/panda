function TESTOM2012_pa_pet_monster_foneem
%% Initialization
close all force hidden
clear all

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

%% Post
files1 = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
files2 = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	};

getdat2(files1,files2);
function [Gmu,GEmu,namesmu] = getdat2(files1,files2)
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
subject		= [6 8 9 10 11 12];
subject		= [7 13 14 15 16];

f			= F(subject);
[s,indx]	= sort(f);

MU1			= [];
MU2			= [];
for ii = 1:n
	roiname		= roinames{ii};
	mu1			= pa_pet_getmeandata(files1,p,roiname);
	MU1			= [MU1 mu1];
	mu2			= pa_pet_getmeandata(files2,p,roiname);
	MU2			= [MU2 mu2];
end

%%
t = MU2(indx,:)-MU1(indx,:);
t = bsxfun(@minus, t, mean(t));
t = bsxfun(@minus, t', mean(t'))';
R = NaN(1,n);
P = R;
G = R;
GE = R;
for ii = 1:n
	cla
	x = s;
	y = t(:,ii);
	[r,p] = corrcoef(x,y);
	b = regstats(y,x,'linear','all');
	
	plot(x,y,'k.')
	axis square;
	lsline;
	str = [roinames{ii} ', r = ' num2str(r(2).^2,2) ', p = ' num2str(p(2),3) ];
	title(str)
	
	R(ii) = r(2);
	P(ii) = p(2);
	G(ii) = b.beta(2);
	GE(ii) = 1.96*b.tstat.se(2)./sqrt(numel(y));
% 	pause
end
figure(102);
subplot(221)
bar(R);
set(gca,'XTick',1:n,'XTickLabel',names);
rotateticklabel(gca,90);

subplot(222)
bar(P);
set(gca,'XTick',1:n,'XTickLabel',names);
rotateticklabel(gca,90);
pa_horline(0.05,'r-')

subplot(223)
bar(G);
set(gca,'XTick',1:n,'XTickLabel',names);
h = rotateticklabel(gca,90);
pa_horline(0.05,'r-')

figure(666)
errorbar(1:n,G,GE,'k.');
hold on
bar(G);

set(gca,'XTick',1:n,'XTickLabel',names);
rotateticklabel(gca,90);



%%
close all
figure(665)
subplot(221)
sel = side==1;
ns = sum(sel);
namesmu = names(sel);
subplot(221)
errorbar(1:ns,G(sel),GE(sel),'k.');
hold on
bar(G(sel));
set(gca,'XTick',1:ns,'XTickLabel',names(sel));
rotateticklabel(gca,90);

subplot(222)
sel2 = side==2;
subplot(222)
errorbar(1:ns,G(sel2),GE(sel2),'k.');
hold on
bar(G(sel2));
set(gca,'XTick',1:ns,'XTickLabel',names(sel2));
rotateticklabel(gca,90);

subplot(223)
subplot(223)
plot(G(sel),G(sel2),'ko');
axis square
pa_unityline;
lsline
% set(gca,'XTick',1:sum(sel2),'XTickLabel',names(sel2));
% rotateticklabel(gca,90);

figure(999)
Gmu = (G(sel)+G(sel2))/2;
GEmu = (GE(sel)+GE(sel2))/2;
errorbar(1:ns,Gmu,GEmu,'k.');
hold on
bar(Gmu);
set(gca,'XTick',1:ns,'XTickLabel',names(sel));
rotateticklabel(gca,90);
xlim([0 ns+1])

%%
% for ii = 1:n
% 	na
%%

%%
figure(103);

imagesc(t');
colorbar;
set(gca,'XTick',1:length(f),'XTickLabel',f(indx))
set(gca,'YTick',1:n,'YTickLabel',roinames);
caxis([-10 10])
caxis auto;



function [Gmu,GEmu,namesmu] = getdat(files)
cd('E:\DATA\KNO\PET\marsbar-aal');
d = dir('*.mat');
roinames = {d.name};
n = numel(roinames);
names = roinames;
side = NaN(1,n);
for ii = 1:n
	 name = roinames{ii};
	 name = name(5:end-8);
	 indx = findstr(name,'_');
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
p					= 'E:\DATA\KNO\PET\swdro files\';

F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02
subject		= [6 8 9 10 11 12];
f			= F(subject);
[s,indx]	= sort(f);

MU = [];
for ii = 1:n
	roiname	= roinames{ii};
	mu		= pa_pet_getmeandata(files,p,roiname);
	MU		= [MU mu];
end

%%
t = MU(indx,:);
t = bsxfun(@minus, t, mean(t));
t = bsxfun(@minus, t', mean(t'))';
R = NaN(1,n);
P = R;
G = R;
GE = R;
for ii = 1:n
	cla
	x = s;
	y = t(:,ii);
	[r,p] = corrcoef(x,y);
	b = regstats(y,x,'linear','all');
	
	plot(x,y,'k.')
	axis square;
	lsline;
	str = [roinames{ii} ', r = ' num2str(r(2).^2,2) ', p = ' num2str(p(2),3) ];
	title(str)
	
	R(ii) = r(2);
	P(ii) = p(2);
	G(ii) = b.beta(2);
	GE(ii) = 1.96*b.tstat.se(2)./sqrt(numel(y));
% 	pause
end
figure(102);
subplot(221)
bar(R);
set(gca,'XTick',1:n,'XTickLabel',names);
rotateticklabel(gca,90);

subplot(222)
bar(P);
set(gca,'XTick',1:n,'XTickLabel',names);
rotateticklabel(gca,90);
pa_horline(0.05,'r-')

subplot(223)
bar(G);
set(gca,'XTick',1:n,'XTickLabel',names);
h = rotateticklabel(gca,90);
pa_horline(0.05,'r-')

figure(666)
errorbar(1:n,G,GE,'k.');
hold on
bar(G);

set(gca,'XTick',1:n,'XTickLabel',names);
rotateticklabel(gca,90);



%%
close all
figure(665)
subplot(221)
sel = side==1;
ns = sum(sel);
namesmu = names(sel);
subplot(221)
errorbar(1:ns,G(sel),GE(sel),'k.');
hold on
bar(G(sel));
set(gca,'XTick',1:ns,'XTickLabel',names(sel));
rotateticklabel(gca,90);

subplot(222)
sel2 = side==2;
subplot(222)
errorbar(1:ns,G(sel2),GE(sel2),'k.');
hold on
bar(G(sel2));
set(gca,'XTick',1:ns,'XTickLabel',names(sel2));
rotateticklabel(gca,90);

subplot(223)
subplot(223)
plot(G(sel),G(sel2),'ko');
axis square
pa_unityline;
lsline
% set(gca,'XTick',1:sum(sel2),'XTickLabel',names(sel2));
% rotateticklabel(gca,90);

figure(999)
Gmu = (G(sel)+G(sel2))/2;
GEmu = (GE(sel)+GE(sel2))/2;
errorbar(1:ns,Gmu,GEmu,'k.');
hold on
bar(Gmu);
set(gca,'XTick',1:ns,'XTickLabel',names(sel));
rotateticklabel(gca,90);
xlim([0 ns+1])

%%
% for ii = 1:n
% 	na
%%

%%
figure(103);

imagesc(t');
colorbar;
set(gca,'XTick',1:length(f),'XTickLabel',f(indx))
set(gca,'YTick',1:n,'YTickLabel',roinames);
caxis([-10 10])
caxis auto;

function plotfoneem2(mupre,g1pre,g2pre,g4pre,mupost,g1post,g2post,g4post,munormal,g1normal,g2normal,roi,cond)

% F = [100 100 100 100 0 51 3 65 7 3 15 13.5 52 67 85 28];
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02

%% Pre-Implant
sel		= strcmpi(g2pre,roi{1}) | strcmpi(g2pre,roi{2});
m		= mupre(sel);
s		= g4pre(sel); % score
c		= g1pre(sel);
f		= F(s);
sel2	= strcmpi(c,cond{1});
m		= m(sel2);
f		= f(sel2);
s		= s(sel2);

us = unique(s);
ns = numel(us);
mum = NaN(ns,1);
sdm = mum;
muf = mum;
for ii = 1:ns
	sel = s == us(ii);
	mum(ii) = mean(m(sel));
	sdm(ii) = std(m(sel))./sqrt(sum(sel));
	muf(ii) = unique(f(sel));
end
[muf,indx] = sort(muf);
mum = mum(indx);
sdm = sdm(indx);

% plot(f,m,'ro','MarkerFaceColor','w','LineWidth',2,'MarkerSize',5);
errorbar(muf,mum,sdm,'ro','MarkerFaceColor','w','LineWidth',2,'MarkerSize',5);
hold on
b		= regstats(mum,muf,'linear',{'beta','rsquare','tstat','fstat'});
beta1	= b.beta;
[Err, P] = fit_2D_data(muf, mum, 'no');
beta1 = P([2 1]);

str1		= ['Pre-CI: R^2 = ' num2str(b.rsquare,2) ', p = ' num2str(b.fstat.pval,2)];

% b		= regstats(m,f,'linear',{'beta','rsquare','tstat','fstat'});
% beta1	= b.beta;
% h		= pa_regline(beta1,'k-'); set(h,'LineWidth',2);

% n = 1000;
% b = bootstrp(n,@regstats,m,f);
% Slope = NaN(n,1);
% Offset = Slope;
% for ii = 1:n
% 	Slope(ii) = b(ii).beta(2);
% 	Offset(ii) = b(ii).beta(1);
% end
% subplot(121)
% plot(Slope,Offset,'.')
% axis square;
% 
% subplot(122)
% hold on
% axis([0 100 50 100])
% for ii = 1:n
% 	pa_regline([Slope(ii) Offset(ii)]);
% end
% keyboard

%% Temporal Superior, V, Post-Implant
sel		= strcmpi(g2post,roi{1}) | strcmpi(g2post,roi{2});
m		= mupost(sel);
s		= g4post(sel);
c		= g1post(sel);
f		= F(s);
sel2	= strcmpi(c,cond{1});
m		= m(sel2);
f		= f(sel2);
s		= s(sel2);

us = unique(s);
ns = numel(us);
mum = NaN(ns,1);
sdm = mum;
muf = mum;
for ii = 1:ns
	sel = s == us(ii);
	mum(ii) = mean(m(sel));
	sdm(ii) = std(m(sel))./sqrt(sum(sel));
	muf(ii) = unique(f(sel));
end
[muf,indx] = sort(muf);
mum = mum(indx);
sdm = sdm(indx);
% plot(f,m,'ro','MarkerFaceColor','w','LineWidth',2,'MarkerSize',5);
errorbar(muf,mum,sdm,'ks','MarkerFaceColor','w','LineWidth',2,'MarkerSize',5);

hold on
% plot(f,m,'ks','MarkerFaceColor','w','LineWidth',2,'MarkerSize',5);
axis square
b		= regstats(mum,muf,'linear',{'beta','rsquare','tstat','fstat'});
beta2	= b.beta;
[Err, P] = fit_2D_data(muf, mum, 'no');
beta2 = P([2 1]);

str2		= ['Post-CI: R^2 = ' num2str(b.rsquare,2) ', p = ' num2str(b.fstat.pval,2)];

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
% title({'Temporal Superior Sulcus';'Control'});
set(gca,'XTick',0:20:100,'YTick',60:10:100);

%%%%%%%%%%%%%%%%%%
subplot(122)
% F = [100 100 100 100 0 51 3 65 7 3 15 13.5 52 67 85 28];
F = [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02

%% Pre-Implant
sel		= strcmpi(g2pre,roi{1}) | strcmpi(g2pre,roi{2});
m		= mupre(sel);
s		= g4pre(sel);
c		= g1pre(sel);
f		= F(s);
sel2	= strcmpi(c,cond{2});
m		= m(sel2);
f		= f(sel2);
s		= s(sel2);

us = unique(s);
ns = numel(us);
mum = NaN(ns,1);
sdm = mum;
muf = mum;
for ii = 1:ns
	sel = s == us(ii);
	mum(ii) = mean(m(sel));
	sdm(ii) = std(m(sel))./sqrt(sum(sel));
	muf(ii) = unique(f(sel));
end
[muf,indx] = sort(muf);
mum = mum(indx);
sdm = sdm(indx);

% plot(f,m,'ro','MarkerFaceColor','w','LineWidth',2,'MarkerSize',5);
errorbar(muf,mum,sdm,'ro','MarkerFaceColor','w','LineWidth',2,'MarkerSize',5);
hold on
b		= regstats(mum,muf,'linear',{'beta','rsquare','tstat','fstat'});
beta1	= b.beta;
str1		= ['Pre-CI: R^2 = ' num2str(b.rsquare,2) ', p = ' num2str(b.fstat.pval,2)];
[Err, P] = fit_2D_data(muf, mum, 'no');
beta1 = P([2 1]);


%% Temporal Superior, V, Post-Implant
sel		= strcmpi(g2post,roi{1}) | strcmpi(g2post,roi{2});
m		= mupost(sel);
s		= g4post(sel);
c		= g1post(sel);
f		= F(s);
sel2	= strcmpi(c,cond{2});
m		= m(sel2);
f		= f(sel2);
s		= s(sel2);

us = unique(s);
ns = numel(us);
mum = NaN(ns,1);
sdm = mum;
muf = mum;
for ii = 1:ns
	sel = s == us(ii);
	mum(ii) = mean(m(sel));
	sdm(ii) = std(m(sel))./sqrt(sum(sel));
	muf(ii) = unique(f(sel));
end
[muf,indx] = sort(muf);
mum = mum(indx);
sdm = sdm(indx);
% plot(f,m,'ro','MarkerFaceColor','w','LineWidth',2,'MarkerSize',5);
errorbar(muf,mum,sdm,'ks','MarkerFaceColor','w','LineWidth',2,'MarkerSize',5);

hold on
% plot(f,m,'ks','MarkerFaceColor','w','LineWidth',2,'MarkerSize',5);
axis square
b		= regstats(mum,muf,'linear',{'beta','rsquare','tstat','fstat'});
beta2	= b.beta;
str2		= ['Post-CI: R^2 = ' num2str(b.rsquare,2) ', p = ' num2str(b.fstat.pval,2)];
[Err, P] = fit_2D_data(muf, mum, 'no');
beta2 = P([2 1]);

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
% title({'Temporal Superior Sulcus';'Control'});
set(gca,'XTick',0:20:100,'YTick',60:10:100);
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


