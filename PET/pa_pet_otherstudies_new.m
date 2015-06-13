function pa_pet_otherstudies_new
close all
clear all


ourdata;


function ourdata
p					= 'E:\Backup\Nifti\';
cd(p)
[N,T] = xlsread('subjectdates.xlsx');

id = N(:,1);
dates = T(2:end,10:14);
ndates =  size(dates,2);
nsub = numel(id);
files = struct([]);
for ii = 1:nsub
	for jj = 1:ndates
		dat = dates{ii,jj};
		if ~isempty(dat) && ~strcmp(dat,'XXX');
			c = datevec(dat,'dd-mm-yyyy');
			fname = ['gwro_s' num2str(id(ii),'%07i') '-d' num2str(c(1),'%04i') num2str(c(2),'%02i') num2str(c(3),'%02i') '-mPET.img'];
			
			files(ii,jj).name = fname;
		end
		
	end
end

%% HG
if true
roifiles = {'MNI_Temporal_Sup_R_roi.mat';...
	'MNI_Temporal_Sup_L_roi.mat';...
	};
indx = +3;
[D1,Fs1,ID1] = plotdiff(files,roifiles,N,4,1,'ks',indx); % Post Rest
[D2,Fs2,ID2] = plotdiff(files,roifiles,N,1,1,'ko',indx); % Pre Rest
x = [Fs1; Fs2]; y = [D1; D2];
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
b.fstat
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D3,Fs3,ID3] = plotdiff(files,roifiles,N,5,2,'ks',indx);% Post Video
[D4,Fs4,ID4] = plotdiff(files,roifiles,N,2,2,'ko',indx);% Pre Video
x = [Fs3; Fs4]; y = [D3; D4];
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D5,Fs5,ID5] = plotdiff(files,roifiles,N,3,3,'ks',indx);% Post Video+Audio
x = Fs5; y = D5;
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);

figure(666+indx)
[~,IA,IB] = intersect(ID1,ID3);
x1 = Fs1(IA);
y1 = D3(IB)-D1(IA);
plot(x1,y1,'ks','Color',[.8 .8 .8],'markerFaceColor',[.8 .8 .8]);
hold on
[~,IA,IB] = intersect(ID2,ID4);
x2 = Fs2(IA);
y2 = D4(IB)-D2(IA);
plot(x2,y2,'ko','Color',[.8 .8 .8],'markerFaceColor',[.8 .8 .8]);
x = [x1;x2];
y = [y1;y2];
mu = nanmean(y);
sd= nanstd(y);

[~,IA,IB] = intersect(ID1,ID5);
x1 = Fs1(IA);
y1 = D5(IB)-D1(IA);
plot(Fs1(IA),D5(IB)-D1(IA),'ks','markerFaceColor','k');
hold on
[~,IA,IB] = intersect(ID2,ID5);
x2 = Fs2(IA);
y2 = D5(IB)-D2(IA);
plot(x2,y2,'ko','markerFaceColor','k');
axis square; box off;
xlim([-10 110]); ylim([-10 10]);
x = [x1;x2];
y = [y1;y2];
b = regstats(y,x);
h = pa_regline(b.beta,'k-');set(h,'LineWidth',2);
h = pa_horline(mu+2*sd,'k-');set(h,'LineWidth',2,'Color',[.8 .8 .8]);
h = pa_horline(mu-2*sd,'k-');set(h,'LineWidth',2,'Color',[.8 .8 .8]);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);


%% HG
roifiles = {'MNI_Heschl_R_roi.mat';...
	'MNI_Heschl_L_roi.mat';...
	};
indx = +1;
[D1,Fs1,ID1] = plotdiff(files,roifiles,N,4,1,'ks',indx); % Post Rest
[D2,Fs2,ID2] = plotdiff(files,roifiles,N,1,1,'ko',indx); % Pre Rest
x = [Fs1; Fs2]; y = [D1; D2];
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
b.fstat
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D3,Fs3,ID3] = plotdiff(files,roifiles,N,5,2,'ks',indx);% Post Video
[D4,Fs4,ID4] = plotdiff(files,roifiles,N,2,2,'ko',indx);% Pre Video
x = [Fs3; Fs4]; y = [D3; D4];
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D5,Fs5,ID5] = plotdiff(files,roifiles,N,3,3,'ks',indx);% Post Video+Audio
x = Fs5; y = D5;
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);

figure(666+indx)
[~,IA,IB] = intersect(ID1,ID3);
x1 = Fs1(IA);
y1 = D3(IB)-D1(IA);
plot(x1,y1,'ks','Color',[.8 .8 .8],'markerFaceColor',[.8 .8 .8]);
hold on
[~,IA,IB] = intersect(ID2,ID4);
x2 = Fs2(IA);
y2 = D4(IB)-D2(IA);
plot(x2,y2,'ko','Color',[.8 .8 .8],'markerFaceColor',[.8 .8 .8]);
x = [x1;x2];
y = [y1;y2];
mu = nanmean(y);
sd= nanstd(y);

x = [x1;x2];
y = [y1;y2];
b = regstats(y,x);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);


[~,IA,IB] = intersect(ID1,ID5);
x1 = Fs1(IA);
y1 = D5(IB)-D1(IA);
plot(Fs1(IA),D5(IB)-D1(IA),'ks','markerFaceColor','k');
hold on
[~,IA,IB] = intersect(ID2,ID5);
x2 = Fs2(IA);
y2 = D5(IB)-D2(IA);
plot(x2,y2,'ko','markerFaceColor','k');
axis square; box off;
xlim([-10 110]); ylim([-10 10]);
x = [x1;x2];
y = [y1;y2];
b = regstats(y,x);
% str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
% title(str);
h = pa_regline(b.beta,'k-');set(h,'LineWidth',2);
h = pa_horline(mu+2*sd,'k-');set(h,'LineWidth',2,'Color',[.8 .8 .8]);
h = pa_horline(mu-2*sd,'k-');set(h,'LineWidth',2,'Color',[.8 .8 .8]);


%% HG
roifiles = {'MNI_Calcarine_R_roi.mat';...
	'MNI_Calcarine_L_roi.mat';...
	};
indx = +6;
[D1,Fs1,ID1] = plotdiff(files,roifiles,N,4,1,'ks',indx); % Post Rest
[D2,Fs2,ID2] = plotdiff(files,roifiles,N,1,1,'ko',indx); % Pre Rest
x = [Fs1; Fs2]; y = [D1; D2];
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
b.fstat
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D3,Fs3,ID3] = plotdiff(files,roifiles,N,5,2,'ks',indx);% Post Video
[D4,Fs4,ID4] = plotdiff(files,roifiles,N,2,2,'ko',indx);% Pre Video
x = [Fs3; Fs4]; y = [D3; D4];
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D5,Fs5,ID5] = plotdiff(files,roifiles,N,3,3,'ks',indx);% Post Video+Audio
x = Fs5; y = D5;
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);


figure(666+indx)
[~,IA,IB] = intersect(ID1,ID3);
x1 = Fs1(IA);
y1 = D3(IB)-D1(IA);
plot(x1,y1,'ks','Color',[.8 .8 .8],'markerFaceColor',[.8 .8 .8]);
hold on
[~,IA,IB] = intersect(ID2,ID4);
x2 = Fs2(IA);
y2 = D4(IB)-D2(IA);
plot(x2,y2,'ko','Color',[.8 .8 .8],'markerFaceColor',[.8 .8 .8]);
x = [x1;x2];
y = [y1;y2];


[~,IA,IB] = intersect(ID1,ID5);
x1 = Fs1(IA);
y1 = D5(IB)-D1(IA);
plot(x1,y1,'ks','markerFaceColor','k');
hold on
[~,IA,IB] = intersect(ID2,ID5);
x2 = Fs2(IA);
y2 = D5(IB)-D2(IA);
plot(x2,y2,'ko','markerFaceColor','k');
axis square; box off;
xlim([-10 110]); ylim([0 20]);

b = regstats(y,x);
h = pa_regline(b.beta,'k-');set(h,'LineWidth',2,'Color',[.8 .8 .8]);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);

x = [x1;x2];
y = [y1;y2];
b = regstats(y,x);
% h = pa_regline(b.beta,'k-');set(h,'LineWidth',2);
mu = nanmean(y);
sd= nanstd(y);
h = pa_horline(mu+2*sd,'k-');set(h,'LineWidth',2,'Color','k');
h = pa_horline(mu-2*sd,'k-');set(h,'LineWidth',2,'Color','k');
return



%% HG
roifiles = {'MNI_Thalamus_R_roi';...
	'MNI_Thalamus_L_roi';...
	};
indx = +9;
[D1,Fs1,ID1] = plotdiff(files,roifiles,N,4,1,'ks',indx); % Post Rest
[D2,Fs2,ID2] = plotdiff(files,roifiles,N,1,1,'ko',indx); % Pre Rest
x = [Fs1; Fs2]; y = [D1; D2];
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
b.fstat
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D3,Fs3,ID3] = plotdiff(files,roifiles,N,5,2,'ks',indx);% Post Video
[D4,Fs4,ID4] = plotdiff(files,roifiles,N,2,2,'ko',indx);% Pre Video
x = [Fs3; Fs4]; y = [D3; D4];
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D5,Fs5,ID5] = plotdiff(files,roifiles,N,3,3,'ks',indx);% Post Video+Audio
x = Fs5; y = D5;
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);

figure(666+indx)
subplot(121)
[~,IA,IB] = intersect(ID1,ID3);
x1 = Fs1(IA);
y1 = D3(IB)-D1(IA);
plot(x1,y1,'ks');
hold on
[~,IA,IB] = intersect(ID2,ID4);
x2 = Fs2(IA);
y2 = D4(IB)-D2(IA);
plot(x2,y2,'ko');
axis square; box off;
xlim([-10 110]); ylim([-10 10]);

x = [x1;x2];
y = [y1;y2];
b = regstats(y,x);
pa_regline(b.beta,'k-');

subplot(122)
[~,IA,IB] = intersect(ID1,ID5);
x1 = Fs1(IA);
y1 = D5(IB)-D1(IA);
plot(Fs1(IA),D5(IB)-D1(IA),'ks');
hold on
[~,IA,IB] = intersect(ID2,ID5);
x2 = Fs2(IA);
y2 = D5(IB)-D2(IA);
plot(x2,y2,'ko');
axis square; box off;
xlim([-10 110]); ylim([-10 10]);
x = [x1;x2];
y = [y1;y2];
b = regstats(y,x);
pa_regline(b.beta,'k-');




end
%% HG
cd('E:\DATA\KNO\PET\marsbar-aal\');
d = dir('MNI_Cerebelum*.mat');
roifiles =  {d.name};
p					= 'E:\Backup\Nifti\';
cd(p)
indx = +12;
[D1,Fs1,ID1] = plotdiff(files,roifiles,N,4,1,'ks',indx); % Post Rest
[D2,Fs2,ID2] = plotdiff(files,roifiles,N,1,1,'ko',indx); % Pre Rest
x = [Fs1; Fs2]; y = [D1; D2];
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
b.fstat
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D3,Fs3,ID3] = plotdiff(files,roifiles,N,5,2,'ks',indx);% Post Video
[D4,Fs4,ID4] = plotdiff(files,roifiles,N,2,2,'ko',indx);% Pre Video
x = [Fs3; Fs4]; y = [D3; D4];
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D5,Fs5,ID5] = plotdiff(files,roifiles,N,3,3,'ks',indx);% Post Video+Audio
x = Fs5; y = D5;
b = regstats(y,x); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);


figure(666+indx)
subplot(121)
[~,IA,IB] = intersect(ID1,ID3);
x1 = Fs1(IA);
y1 = D3(IB)-D1(IA);
plot(x1,y1,'ks');
hold on
[~,IA,IB] = intersect(ID2,ID4);
x2 = Fs2(IA);
y2 = D4(IB)-D2(IA);
plot(x2,y2,'ko');
axis square; box off;
xlim([-10 110]); ylim([-10 10]);

x = [x1;x2];
y = [y1;y2];
b = regstats(y,x);
pa_regline(b.beta,'k-');

subplot(122)
[~,IA,IB] = intersect(ID1,ID5);
x1 = Fs1(IA);
y1 = D5(IB)-D1(IA);
plot(Fs1(IA),D5(IB)-D1(IA),'ks');
hold on
[~,IA,IB] = intersect(ID2,ID5);
x2 = Fs2(IA);
y2 = D5(IB)-D2(IA);
plot(x2,y2,'ko');
axis square; box off;
xlim([-10 110]); ylim([-10 10]);
x = [x1;x2];
y = [y1;y2];
b = regstats(y,x);
pa_regline(b.beta,'k-');



%%
warning off %#ok<WNOFF>
for jj = [1 3 6 9 12]
	for ii=1:3
		figure(jj)
		subplot(1,3,ii)
		ylim([88 135]);
		xlim([-10 110]); ylim([-10 10]);
		axis square; box off;
		% lsline;
		set(gca,'XTick',0:25:100);
		pa_horline(100,'k-');
		
		pa_datadir;
print('-depsc','-painter',[mfilename num2str(jj)]);

	end
end

function [D,Fs,ID] = plotdiff(files,roifiles,N,cond,sb,mrk,fign)
nroi = numel(roifiles);
D = 0;
nvoxels		= 5000;
if nargin<6
	mrk = 'ko';
end
if nargin<7
	fign=1;
end
n		= {files(6:end,cond).name};
for ii = 1:nroi
	roiname		= 	['E:\DATA\KNO\PET\marsbar-aal\' roifiles{ii}];
	NHRest	= getvoxels({files(1:5,1).name},roiname,nvoxels); % Normal-hearing Rest
	mu		= mean(NHRest);
	FDG	= getvoxels(n,roiname,nvoxels); % Prelingual Rest
	diff	= bsxfun(@rdivide,FDG,mu);
	diff	= nanmean(diff,2)*100;
	D		= D+diff;
end
D = D./nroi;

F = N(6:end,6);
sel = true(size(F));
for ii = 1:numel(n)
	if ~isempty(n{ii})
		sel(ii) = true;
	else
		sel(ii) = false;
	end
end
F = F(sel);
n = n(sel);

figure(fign)
subplot(1,3,sb)
hold on
[Fs,indx] = sort(F);
D = D(indx);
n = n(indx);

sel = false(size(F));
ID = NaN(size(n));
for ii =1:numel(n)
	f = n{ii};
	sel(ii) = strcmp(f(7:13),'5512113');
	ID(ii) = str2double(f(7:13));
end
% D(sel) = D(sel);

plot(Fs,D,mrk,'MarkerFaceColor','w','LineWidth',1);
for ii =1:numel(n)
	f = n{ii};
	text(Fs(ii),D(ii),f(7:13));
end



function Y	= getvoxels(files,roiname,nvoxels)
roi_obj		= maroi(roiname);
nfiles		= numel(files);
% col = jet;
Y = NaN(nfiles,nvoxels);
k = 0;
for ii = 1:nfiles
	k = k+1;
	fname			= files{ii};
	if ~isempty(fname)
	y	= getdata(roi_obj, fname);

% 	if numel(y) < nvoxels
% 		
% 	disp([numel(y) nvoxels]);
% 	end
	Y(k,1:numel(y)) = y;
	end
end
sel = ~isnan(Y(:,1));
Y = Y(sel,:);



