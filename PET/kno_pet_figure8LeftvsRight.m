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
			roifilesL = {'MNI_Temporal_Sup_L_roi.mat'};
			roifilesR = {'MNI_Temporal_Sup_R_roi.mat'};
		case 2
			roifilesL = {'MNI_Heschl_L_roi.mat'};
			roifilesR = {'MNI_Heschl_R_roi.mat'};
		case 3
			roifilesL = {'MNI_Calcarine_L_roi.mat'};
			roifilesR = {'MNI_Calcarine_R_roi.mat'};
		case 4
			cd('E:\DATA\KNO\PET\marsbar-aal\');
			d = dir('MNI_Cerebelum*.mat');
			roifiles =  {d.name};
			p					= 'E:\Backup\Nifti\';
			cd(p)
		case 5
			roifiles = {'MNI_Thalamus_R_roi';...
				};
	end
	
	%% Pre
	figure(ii)
	subplot(231)
	hold on
	plotdat(files,roifilesL,roifilesR,N,1,RGB)
	plotdatNH(files,roifilesL,roifilesR,N,1,RGB)
	
	subplot(232)
	hold on
	plotdat(files,roifilesL,roifilesR,N,2,RGB)
	plotdatNH(files,roifilesL,roifilesR,N,2,RGB)
	
	subplot(236)
	hold on
	plotdat(files,roifilesL,roifilesR,N,3,RGB)
	plotdatNH(files,roifilesL,roifilesR,N,3,RGB)
	
	subplot(234)
	hold on
	plotdat(files,roifilesL,roifilesR,N,4,RGB)
	plotdatNH(files,roifilesL,roifilesR,N,1,RGB)
	
	subplot(235)
	hold on
	plotdat(files,roifilesL,roifilesR,N,5,RGB)
	plotdatNH(files,roifilesL,roifilesR,N,2,RGB)
	
	
	
	
	%
	% 		%% Post
	% 	[D4,F4]		= getstats(files,roifiles,N,4); % Pre rest
	% 	D3			= getstats(files,roifiles,N,3); % Post AV
	% 	[F4,indx]	= sort(F4);
	% 	D4			= D4(indx);
	% 	D3			= D3(indx);
	% 	sel			= isnan(D3) | isnan(D4);
	%
	% 	figure(ii)
	% 	subplot(133)
	% 	hold on
	% 	plot(D4(~sel),D3(~sel),'k-');
	% 	n = numel(D4);
	% 	for jj = 1:n
	% 		cindx = ceil(F4(jj));
	% 		plot(D4(jj),D3(jj),'ko','MarkerFaceColor',RGB(cindx,:),'Color','k','MarkerSize',7,'LineWidth',1);
	% 		drawnow
	% 	end
	%
	% 	%% NH
	% 	[DNH1,FNH1]	= getstatsNH(files,roifiles,N,1); % NH AV
	% 	[DNH3]		= getstatsNH(files,roifiles,N,3); % Pre Video
	% 	[FNH1,indx]	= sort(FNH1);
	% 	DNH1			= DNH1(indx);
	% 	DNH3			= DNH3(indx);
	% 	sel			= isnan(DNH1) | isnan(DNH3);
	%
	% 	figure(ii)
	% 		subplot(1,3,3)
	% 		hold on
	% 		plot(DNH1(~sel),DNH3(~sel),'k--');
	% 		n = numel(DNH1);
	% 		for jj = 1:n
	% 			cindx = ceil(FNH1(jj));
	% 			plot(DNH1(jj),DNH3(jj),'ks','MarkerFaceColor',RGB(cindx,:),'Color','k','MarkerSize',7,'LineWidth',1);
	% 			drawnow
	% 		end
	% % 	return
	%% Labels
	figure(ii)
	plotlabels(roifilesL);
	
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



function plotdat(files,roifilesL,roifilesR,N,cond,RGB)
[D1L,F1]	= getstats(files,roifilesL,N,cond); % Pre rest
[D1R]		= getstats(files,roifilesR,N,cond); % Pre rest
[F1,indx]	= sort(F1);
D1L			= D1L(indx);
D1R			= D1R(indx);
sel			= isnan(D1L) | isnan(D1R);


plot(D1L(~sel),D1R(~sel),'k-');
n = numel(D1L);
for jj = 1:n
	cindx = ceil(F1(jj));
	plot(D1L(jj),D1R(jj),'ko','MarkerFaceColor',RGB(cindx,:),'Color','k','MarkerSize',7,'LineWidth',1);
	drawnow
end


function plotlabels(roifiles)
for jj = 1:6
	subplot(2,3,jj)
	ylim([85 130])
	xlim([85 130]);
	box off
	axis square;
	xlabel('Left (%)');
	ylabel('Right (%)');
	pa_unityline('k:');
	pa_horline(100,'k:');
	pa_verline(100,'k:');
	set(gca,'TickDir','out','XTick',90:10:120,'YTick',90:10:120);
	pa_text(0.1,0.9,char(64+jj));
	str = roifiles{1}
	title(str);
end

function plotdatNH(files,roifilesL,roifilesR,N,cond,RGB)
[DNH1L,FNH1]	= getstatsNH(files,roifilesL,N,cond); % Pre rest
[DNH1R,FNH1]	= getstatsNH(files,roifilesR,N,cond); % Pre rest

[FNH1,indx]	= sort(FNH1);
DNH1L			= DNH1L(indx);
DNH1R			= DNH1R(indx);
sel			= isnan(DNH1L) | isnan(DNH1R);


hold on
plot(DNH1L(~sel),DNH1R(~sel),'k--');
n = numel(DNH1L);
for jj = 1:n
	cindx = ceil(FNH1(jj));
	plot(DNH1L(jj),DNH1R(jj),'ks','MarkerFaceColor',RGB(cindx,:),'Color','k','MarkerSize',7,'LineWidth',1);
	drawnow
end
