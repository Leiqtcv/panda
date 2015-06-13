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
			c = datevec(dat,'dd-mm-yyyy');
			fname = ['gswro_s' num2str(id(ii),'%07i') '-d' num2str(c(1),'%04i') num2str(c(2),'%02i') num2str(c(3),'%02i') '-mPET.img'];
			
			files(ii,jj).name = fname;
		end
		
	end
end

%% HG
for ii = 1:5
	cd(p)

	switch ii
		case 1
			roifiles = {'MNI_Temporal_Sup_R_roi.mat';...
				'MNI_Temporal_Sup_L_roi.mat';...
				};
		case 2
			roifiles = {'MNI_Heschl_R_roi.mat';...
				'MNI_Heschl_L_roi.mat';...
				};
		case 3
			roifiles = {'MNI_Calcarine_R_roi.mat';...
				'MNI_Calcarine_L_roi.mat';...
				};
		case 4
			cd('E:\DATA\KNO\PET\marsbar-aal\');
			d = dir('MNI_Cerebelum*.mat');
			roifiles =  {d.name};
			p					= 'E:\Backup\Nifti\';
			cd(p)
		case 5
			roifiles = {'MNI_Thalamus_R_roi';...
				'MNI_Thalamus_L_roi';...
				};
	end
	
	% Question 1
	% Is there cross-modal activity in pre-implants?
	[D4,F4]	= getstats(files,roifiles,N,4); % Post rest
	[D5]	= getstats(files,roifiles,N,5); % Post Video
	[D3]	= getstats(files,roifiles,N,3); % Post AV
	
	[D1,F1]	= getstats(files,roifiles,N,1); % Pre rest
	[D2]	= getstats(files,roifiles,N,2); % Pre Video
	

	[DNH3]		= getstatsNH(files,roifiles,N,3); % Post AV
	
	[DNH1,FNH1]	= getstatsNH(files,roifiles,N,1); % Pre rest
	[DNH2]		= getstatsNH(files,roifiles,N,2); % Pre Video

	figure(ii)
	subplot(121)
	hold on

	sel = F1>35;
	plot(D1(sel),D4(sel),'ko','MarkerFaceColor','r','Color','k');
	plot(D1(~sel),D4(~sel),'ks','MarkerFaceColor','b','Color','k');

	ylim([85 130])
	xlim([85 130]);
	box off
	axis square;
	xlabel('Pre (%)');
	ylabel('Post (%)');

	pa_unityline;
	title(roifiles{1});
	
	subplot(122)
	hold on

	sel = F1>35;
	plot(D2(sel),D5(sel),'ko','MarkerFaceColor','r','Color','k');
	plot(D2(~sel),D5(~sel),'ks','MarkerFaceColor','b','Color','k');
	
	
	ylim([85 130]);
	xlim([85 130]);
	pa_unityline;
	box off
	axis square;
	xlabel('Pre (%)');
	ylabel('Post (%)');
	
	
% 	
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



