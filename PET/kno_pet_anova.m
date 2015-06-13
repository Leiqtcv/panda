function kno_pet_anova
close all hidden
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
			fname = ['gswro_s' num2str(id(ii),'%07i') '-d' num2str(c(1),'%04i') num2str(c(2),'%02i') num2str(c(3),'%02i') '-mPET.img'];
			
			files(ii,jj).name = fname;
		end
		
	end
end

%% HG
roifiles = {'MNI_Temporal_Sup_R_roi.mat';...
	'MNI_Temporal_Sup_L_roi.mat';...
	};
indx = +3;
[D1,Fs1,ID1] = plotdiff(files,roifiles,N,4,1,'ks',indx); % Post Rest
[D2,Fs2,ID2] = plotdiff(files,roifiles,N,1,1,'ko',indx); % Pre Rest
x = [Fs1; Fs2]; y = [D1; D2];
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
b.fstat
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D3,Fs3,ID3] = plotdiff(files,roifiles,N,5,2,'ks',indx);% Post Video
[D4,Fs4,ID4] = plotdiff(files,roifiles,N,2,2,'ko',indx);% Pre Video
x = [Fs3; Fs4]; y = [D3; D4];
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D5,Fs5,ID5] = plotdiff(files,roifiles,N,3,3,'ks',indx);% Post Video+Audio
x = Fs5; y = D5;
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);


%%
close all hidden
y	= [D1; D2; D3; D4; D5]; % score
G1	= [Fs1;Fs2;Fs3;Fs4;Fs5]; % phoneme score
G2	= [ID1; ID2; ID3; ID4; ID5]; % subject ID
G3	= [repmat(4,numel(D1),1); repmat(1,numel(D2),1); repmat(5,numel(D3),1); repmat(2,numel(D4),1); repmat(3,numel(D5),1)];
% G3 = 
g	= {G1, G3}

md = [[1 0];[0 1];...
	[1 1]]

% ;[0 0 0 1 0];[0 0 0 0 1];...
% 	[0 1 1 0 0];[0 1 0 1 0];[0 1 0 0 1];...
% 	[0 0 1 1 0];[0 0 1 0 1];...
% 	[0 0 0 1 1];...
% 	[0 1 1 1 0];[0 0 1 1 1];[0 1 0 1 1];[0 1 1 0 1];...
% 	[0 1 1 1 1];...
% 	]
[p,t,stats] = anovan(y,g,'continuous',1,'model',md,'varnames',{'Phoneme';'Condition'})

multcompare(stats,'dimension',2)

%%
keyboard

return
%% HG
roifiles = {'MNI_Heschl_R_roi.mat';...
	'MNI_Heschl_L_roi.mat';...
	};
indx = +1;
[D1,Fs1] = plotdiff(files,roifiles,N,4,1,'ks',indx); % Post Rest
[D2,Fs2] = plotdiff(files,roifiles,N,1,1,'ko',indx); % Pre Rest
x = [Fs1; Fs2]; y = [D1; D2];
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
b.fstat
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D3,Fs3] = plotdiff(files,roifiles,N,5,2,'ks',indx);% Post Video
[D4,Fs4] = plotdiff(files,roifiles,N,2,2,'ko',indx);% Pre Video
x = [Fs3; Fs4]; y = [D3; D4];
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D5,Fs5] = plotdiff(files,roifiles,N,3,3,'ks',indx);% Post Video+Audio
x = Fs5; y = D5;
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);


%% HG
roifiles = {'MNI_Calcarine_R_roi.mat';...
	'MNI_Calcarine_L_roi.mat';...
	};
indx = +6;
[D1,Fs1] = plotdiff(files,roifiles,N,4,1,'ks',indx); % Post Rest
[D2,Fs2] = plotdiff(files,roifiles,N,1,1,'ko',indx); % Pre Rest
x = [Fs1; Fs2]; y = [D1; D2];
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
b.fstat
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D3,Fs3] = plotdiff(files,roifiles,N,5,2,'ks',indx);% Post Video
[D4,Fs4] = plotdiff(files,roifiles,N,2,2,'ko',indx);% Pre Video
x = [Fs3; Fs4]; y = [D3; D4];
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D5,Fs5] = plotdiff(files,roifiles,N,3,3,'ks',indx);% Post Video+Audio
x = Fs5; y = D5;
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);



%% HG
roifiles = {'MNI_Thalamus_R_roi';...
	'MNI_Thalamus_L_roi';...
	};
indx = +9;
[D1,Fs1] = plotdiff(files,roifiles,N,4,1,'ks',indx); % Post Rest
[D2,Fs2] = plotdiff(files,roifiles,N,1,1,'ko',indx); % Pre Rest
x = [Fs1; Fs2]; y = [D1; D2];
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
b.fstat
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D3,Fs3] = plotdiff(files,roifiles,N,5,2,'ks',indx);% Post Video
[D4,Fs4] = plotdiff(files,roifiles,N,2,2,'ko',indx);% Pre Video
x = [Fs3; Fs4]; y = [D3; D4];
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D5,Fs5] = plotdiff(files,roifiles,N,3,3,'ks',indx);% Post Video+Audio
x = Fs5; y = D5;
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);




%% HG
cd('E:\DATA\KNO\PET\marsbar-aal\');
d = dir('MNI_Cerebelum*.mat');
roifiles =  {d.name};
p					= 'E:\Backup\Nifti\';
cd(p)
indx = +12;
[D1,Fs1] = plotdiff(files,roifiles,N,4,1,'ks',indx); % Post Rest
[D2,Fs2] = plotdiff(files,roifiles,N,1,1,'ko',indx); % Pre Rest
x = [Fs1; Fs2]; y = [D1; D2];
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
b.fstat
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D3,Fs3] = plotdiff(files,roifiles,N,5,2,'ks',indx);% Post Video
[D4,Fs4] = plotdiff(files,roifiles,N,2,2,'ko',indx);% Pre Video
x = [Fs3; Fs4]; y = [D3; D4];
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);
[D5,Fs5] = plotdiff(files,roifiles,N,3,3,'ks',indx);% Post Video+Audio
x = Fs5; y = D5;
b = regstats(x,y); h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
str = {['Y = ' num2str(b.beta(2),3) 'X + ' num2str(b.beta(1),3)];['R^2 = ' num2str(b.rsquare,2) ', F = ' num2str(b.fstat.f,3) ', p = ' num2str(b.fstat.pval,3)]};
title(str);


%%
warning off %#ok<WNOFF>
for jj = [1 3 6 9 12]
	for ii=1:3
		figure(jj)
		subplot(1,3,ii)
		xlim([88 135]);
		ylim([-10 110]);
		axis square;
		% lsline;
		set(gca,'YTick',0:25:100);
		pa_verline(100,'k-');
		
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
	[FDG,ID]	= getvoxels(n,roiname,nvoxels); % Prelingual Rest
	diff	= bsxfun(@rdivide,FDG,mu);
	diff	= nanmean(diff,2)*100;
	D		= D+diff;
end
ID
col = gray(numel(n));

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
col = col(sel,:);

figure(fign)
subplot(1,3,sb)
hold on
[Fs,indx] = sort(F);
D = D(indx);
n = n(indx);
ID = ID(indx);
col = col(indx,:);
sel = false(size(F));
for ii =1:numel(n)
	f = n{ii};
	sel(ii) = strcmp(f(7:13),'5512113');
end
% D(sel) = D(sel);
% col = col(sel,:);
for ii =1:numel(n)
plot(D(ii),Fs(ii),mrk,'MarkerFaceColor',col(ii,:),'LineWidth',2);
	f = n{ii};
	text(D(ii),Fs(ii)+1,f(7:13),'HorizontalAlignment','center');
end
		xlim([88 135]);
		ylim([-10 110]);

function [Y,ID]	= getvoxels(files,roiname,nvoxels)
roi_obj		= maroi(roiname);
nfiles		= numel(files);
% col = jet;
Y = NaN(nfiles,nvoxels);
k = 0;
ID = NaN(nfiles,1);
for ii = 1:nfiles
	k = k+1;
	fname			= files{ii};
	if ~isempty(fname)
	y	= getdata(roi_obj, fname);

% 	if numel(y) < nvoxels
% 		
% 	disp([numel(y) nvoxels]);
% 	end
	id = fname(8:14)
	Y(k,1:numel(y)) = y;
	ID(k,:) = str2double(id);
	end
end
sel = ~isnan(Y(:,1));
Y = Y(sel,:);
ID = ID(sel);


