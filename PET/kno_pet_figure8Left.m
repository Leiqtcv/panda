function kno_pet_figure8
close all hidden
clear all hidden


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
			c					= datevec(dat,'dd-mm-yyyy');
			fname				= ['gswro_s' num2str(id(ii),'%07i') '-d' num2str(c(1),'%04i') num2str(c(2),'%02i') num2str(c(3),'%02i') '-mPET.img'];
			files(ii,jj).name	= fname;
		end
		
	end
end

%% Colorspace

ncol	= 100;
l		= linspace(0,1,ncol);
pow		= 2;
fl		= l.^pow;
max(fl)
Cmax	= 100;
Lmax	= 100;
Lmin	= 30;
H		= 200;
H		= repmat(H,1,ncol);
C		= zeros(1,ncol)+fl*Cmax;
L		= Lmax-fl*(Lmax-Lmin);
LCH		= [L;C;H]';
RGB		= colorspace('RGB<-LCH',LCH);


for ii = 1:3
	cd(p)
	switch ii
		case 1
			roifiles = {'MNI_Temporal_Sup_L_roi.mat';...
				};
		case 2
			roifiles = {'MNI_Heschl_L_roi.mat';...
				};
		case 3
			roifiles = {'MNI_Calcarine_L_roi.mat';...
				};
		case 4
			cd('E:\DATA\KNO\PET\marsbar-aal\');
			d = dir('MNI_Cerebelum*.mat');
			roifiles =  {d.name};
			p					= 'E:\Backup\Nifti\';
			cd(p)
		case 5
			roifiles = {'MNI_Thalamus_L_roi';...
				};
	end
	
	%% Pre
	[D1,F1]		= getstats(files,roifiles,N,1); % Pre rest
	[D2]		= getstats(files,roifiles,N,2); % Pre Video
	[F1,indx]	= sort(F1);
	D1			= D1(indx);
	D2			= D2(indx);
	sel			= isnan(D1) | isnan(D2);
	
	figure(ii)
	subplot(131)
	hold on
	plot(D1(~sel),D2(~sel),'k-');
	n = numel(D1);
	for jj = 1:n
		cindx = ceil(F1(jj));
		plot(D1(jj),D2(jj),'ko','MarkerFaceColor',RGB(cindx,:),'Color','k','MarkerSize',7,'LineWidth',1);
		drawnow
	end
	
	%% Post
	[D4,F4]		= getstats(files,roifiles,N,4); % Pre rest
	[D5]		= getstats(files,roifiles,N,5); % Pre Video
	[F4,indx]	= sort(F4);
	D4			= D4(indx);
	D5			= D5(indx);
	sel			= isnan(D4) | isnan(D5);
	
	figure(ii)
	subplot(132)
	hold on
	plot(D4(~sel),D5(~sel),'k-');
	n = numel(D4);
	for jj = 1:n
		cindx = ceil(F4(jj));
		plot(D4(jj),D5(jj),'ko','MarkerFaceColor',RGB(cindx,:),'Color','k','MarkerSize',7,'LineWidth',1);
		drawnow
	end

	%% NH
	[DNH1,FNH1]	= getstatsNH(files,roifiles,N,1); % Pre rest
	[DNH2]		= getstatsNH(files,roifiles,N,2); % Pre Video
	[FNH1,indx]	= sort(FNH1);
	DNH1			= DNH1(indx);
	DNH2			= DNH2(indx);
	sel			= isnan(DNH1) | isnan(DNH2);
	
	figure(ii)
	for kk = 1:2
		subplot(1,3,kk)
		hold on
		plot(DNH1(~sel),DNH2(~sel),'k--');
		n = numel(DNH1);
		for jj = 1:n
			cindx = ceil(FNH1(jj));
			plot(DNH1(jj),DNH2(jj),'ks','MarkerFaceColor',RGB(cindx,:),'Color','k','MarkerSize',7,'LineWidth',1);
			drawnow
		end
	end
	
		%% Post
	[D4,F4]		= getstats(files,roifiles,N,4); % Pre rest
	D3			= getstats(files,roifiles,N,3); % Post AV
	[F4,indx]	= sort(F4);
	D4			= D4(indx);
	D3			= D3(indx);
	sel			= isnan(D3) | isnan(D4);
	
	figure(ii)
	subplot(133)
	hold on
	plot(D4(~sel),D3(~sel),'k-');
	n = numel(D4);
	for jj = 1:n
		cindx = ceil(F4(jj));
		plot(D4(jj),D3(jj),'ko','MarkerFaceColor',RGB(cindx,:),'Color','k','MarkerSize',7,'LineWidth',1);
		drawnow
	end
	
	%% NH
	[DNH1,FNH1]	= getstatsNH(files,roifiles,N,1); % NH AV
	[DNH3]		= getstatsNH(files,roifiles,N,3); % Pre Video
	[FNH1,indx]	= sort(FNH1);
	DNH1			= DNH1(indx);
	DNH3			= DNH3(indx);
	sel			= isnan(DNH1) | isnan(DNH3);
	
	figure(ii)
		subplot(1,3,3)
		hold on
		plot(DNH1(~sel),DNH3(~sel),'k--');
		n = numel(DNH1);
		for jj = 1:n
			cindx = ceil(FNH1(jj));
			plot(DNH1(jj),DNH3(jj),'ks','MarkerFaceColor',RGB(cindx,:),'Color','k','MarkerSize',7,'LineWidth',1);
			drawnow
		end
% 	return
	%% Labels
	figure(ii)
	for jj = 1:3
		subplot(1,3,jj)
		ylim([85 130])
	xlim([85 130]);
	box off
	axis square;
	xlabel('Rest (%)');
	ylabel('Video (%)');
	pa_unityline('k:');
	pa_horline(100,'k:');
	pa_verline(100,'k:');
	set(gca,'TickDir','out','XTick',90:10:120,'YTick',90:10:120);
		pa_text(0.1,0.9,char(64+jj));
	
	title(roifiles{1});
	end
	%% Print
	pa_datadir;
	print('-depsc','-painter',[mfilename num2str(ii)]);
end


function [D,Fs] = getstats(files,roifiles,N,cond)
nroi	= numel(roifiles);
D		= 0;
nvoxels	= 5000;
n		= {files(6:end,cond).name};
for ii	= 1:nroi
	roiname		= 	['E:\DATA\KNO\PET\marsbar-aal\' roifiles{ii}];
	NHRest	= getvoxels({files(1:5,1).name},roiname,nvoxels);
	mu		= nanmean(NHRest);
	
	FDG		= getvoxels(n,roiname,nvoxels);
	diff	= bsxfun(@rdivide,FDG,mu);
	% 	diff = FDG;
	diff	= nanmean(diff,2)*100;
	D		= D+diff;
end

D	= D./nroi;

Fs		= N(6:end,6);

function [D,Fs] = getstatsNH(files,roifiles,N,cond)
nroi	= numel(roifiles);
D		= 0;
nvoxels	= 5000;
n		= {files(1:5,cond).name};
for ii	= 1:nroi
	roiname		= 	['E:\DATA\KNO\PET\marsbar-aal\' roifiles{ii}];
	NHRest	= getvoxels({files(1:5,1).name},roiname,nvoxels);
	mu		= nanmean(NHRest);
	
	FDG		= getvoxels(n,roiname,nvoxels);
	diff	= bsxfun(@rdivide,FDG,mu);
	% 	diff = FDG;
	diff	= nanmean(diff,2)*100;
	D		= D+diff;
end

D	= D./nroi;

Fs		= N(1:5,6);


function Y	= getvoxels(files,roiname,nvoxels)
roi_obj	= maroi(roiname);
nfiles	= numel(files);
Y		= NaN(nfiles,nvoxels);
k		= 0;
for ii	= 1:nfiles
	k	= k+1;
	fname			= files{ii};
	if ~isempty(fname)
		y	= getdata(roi_obj, fname);
		Y(k,1:numel(y)) = y;
	end
end
% sel = ~isnan(Y(:,1));
% Y	= Y(sel,:);



