function kno_pet_figure6
close all
clear all


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
	
	[DNH4,FNH4]	= getstatsNH(files,roifiles,N,4); % Post rest
	[DNH5]	= getstatsNH(files,roifiles,N,5); % Post Video
	[DNH3]	= getstatsNH(files,roifiles,N,3); % Post AV
	
	[DNH1,FNH1]	= getstatsNH(files,roifiles,N,1); % Pre rest
	[DNH2]	= getstatsNH(files,roifiles,N,2); % Pre Video

	figure(ii)
	subplot(121)
	hold on
	plot(D1,F1,'ko','MarkerFaceColor',[.5 .5 1],'Color',[.7 .7 .7]);
	plot(D2,F1,'ko','MarkerFaceColor',[1 .5 .5],'Color',[.7 .7 .7]);

	plot(DNH1,FNH1,'ks','MarkerFaceColor',[.5 .5 1],'Color',[.7 .7 .7]);
	plot(DNH2,FNH1,'ks','MarkerFaceColor',[1 .5 .5],'Color',[.7 .7 .7]);

	nanmean(DNH2)
	nanmean(FNH1)
	plot(nanmean(DNH1),nanmean(FNH1),'ks-','MarkerFaceColor','b','Color','k','MarkerSize',10);
	plot(nanmean(DNH2),nanmean(FNH1),'ks-','MarkerFaceColor','r','Color','k','MarkerSize',10);

	sel = F1>35;
	x = [nanmean(D1(sel)) nanmean(D2(sel))];
	y = [nanmean(F1(sel)) nanmean(F1(sel))];
	plot(x,y,'k-','LineWidth',2);
	plot(nanmean(D1(sel)),nanmean(F1(sel)),'ko','MarkerFaceColor','b','Color','k','MarkerSize',10);
	plot(nanmean(D2(sel)),nanmean(F1(sel)),'ko','MarkerFaceColor','r','Color','k','MarkerSize',10);
	
	plot(nanmean(D1(~sel)),nanmean(F1(~sel)),'ko','MarkerFaceColor','b','Color','k','MarkerSize',10);
	plot(nanmean(D2(~sel)),nanmean(F1(~sel)),'ko','MarkerFaceColor','r','Color','k','MarkerSize',10);
	ylim([0 100])
	xlim([85 130]);
	box off
	axis square;
	xlabel('Metabolic activity re normal-hearing rest (%)');
	ylabel('Phoneme score (%)');
	pa_horline(35,'k:');
	pa_verline(100,'k:');
	title(roifiles{1});
	
	subplot(122)
	hold on
	plot(D4,F4,'ko','MarkerFaceColor',[.5 .5 1],'Color',[.5 .5 1]);
	plot(D5,F4,'ko','MarkerFaceColor',[1 .5 .5],'Color',[1 .5 .5]);
	plot(D3,F4,'ko','MarkerFaceColor',[.5 1 .5],'Color',[.5 1 .5]);
	
	plot(DNH1,FNH1,'ks','MarkerFaceColor',[.5 .5 1],'Color',[.5 .5 1]);
	plot(DNH2,FNH1,'ks','MarkerFaceColor',[1 .5 .5],'Color',[1 .5 .5]);
	plot(DNH3,FNH1,'ks','MarkerFaceColor',[.5 1 .5],'Color',[.5 1 .5]);

	plot(nanmean(DNH1),nanmean(FNH1),'ks-','MarkerFaceColor','b','Color','k','MarkerSize',10);
	plot(nanmean(DNH2),nanmean(FNH1),'ks-','MarkerFaceColor','r','Color','k','MarkerSize',10);
	plot(nanmean(DNH3),nanmean(FNH1),'ks-','MarkerFaceColor','g','Color','k','MarkerSize',10);

	sel = F4>35;
	plot(nanmean(D4(sel)),nanmean(F4(sel)),'ko-','MarkerFaceColor','b','Color','k','MarkerSize',10);
	plot(nanmean(D5(sel)),nanmean(F4(sel)),'ko-','MarkerFaceColor','r','Color','k','MarkerSize',10);
	plot(nanmean(D3(sel)),nanmean(F4(sel)),'ko-','MarkerFaceColor','g','Color','k','MarkerSize',10);
	
	plot(nanmean(D4(~sel)),nanmean(F4(~sel)),'ko-','MarkerFaceColor','b','Color','k','MarkerSize',10);
	plot(nanmean(D5(~sel)),nanmean(F4(~sel)),'ko-','MarkerFaceColor','r','Color','k','MarkerSize',10);
	plot(nanmean(D3(~sel)),nanmean(F4(~sel)),'ko-','MarkerFaceColor','g','Color','k','MarkerSize',10);
	
	ylim([0 100]);
	xlim([85 130]);
	pa_horline(35,'k:');
	pa_verline(100,'k:');
	box off
	axis square;
	xlabel('Metabolic activity re normal-hearing rest (%)');
	ylabel('Phoneme score (%)');
	
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



