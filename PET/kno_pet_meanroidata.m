function kno_pet_meanroidata
% IMPORTANTE
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

%% Find al Regions
cd('E:\DATA\KNO\PET\marsbar-aal\');
d = dir('MNI_*.mat');
roifiles =  {d.name};
nfiles = numel(roifiles);
data = struct([]);
for roiIdx = 1:nfiles
	str = roifiles{roiIdx};
	disp(str)
	cd(p)
	% get mean
	
	%%
	sideCI = strcmp(T(2:end,5),'Right')+1; % 1 = Left
	sel = strcmp(T(2:end,5),'');
	sideCI(sel) = NaN;
	%%
% 	keyboard
	[D1,F1,SIR1]	= getstats(files,roifiles(roiIdx),N,1); % Pre rest
	[D2]			= getstats(files,roifiles(roiIdx),N,2);		% Pre video
	[D3]			= getstats(files,roifiles(roiIdx),N,3); % Pre rest
	D4				= getstats(files,roifiles(roiIdx),N,4);		% Pre video
	D5				= getstats(files,roifiles(roiIdx),N,5);		% Pre video
	
	F1(1:5) = NaN;
	D4(1:5) = D1(1:5);
	D5(1:5) = D2(1:5);
	
	
	FDG				= [D1 D2 D3 D4 D5];
	group			= [ones(size(D1)) ones(size(D2)) ones(size(D3))+1 ones(size(D4))+1 ones(size(D5))+1]; % pre = 1, post = 2
	group(1:5,:)	= 3; % normalhearing = 3
	stim			= [ones(size(D1)) ones(size(D2))+1 ones(size(D3))+2 ones(size(D4)) ones(size(D5))+1]; % 1 = rest, 2 = V, 3 = AV
	subject			= (1:length(D1))';
	
	data(roiIdx).FDG = FDG;
	data(roiIdx).group = group;
	data(roiIdx).stim = stim;
	data(roiIdx).subject = subject;
	data(roiIdx).phoneme = F1;
	data(roiIdx).SIR = SIR1;
	data(roiIdx).roi		= roifiles(roiIdx);
	data(roiIdx).CI		= sideCI;
	
	% 	keyboard
	% 	D3			= getstats(files,roifiles(roiIdx),N,1);		% Pre video
% 	F1(1:5) = 85;
% 	data(roiIdx).FDGrest	= [D1(6:end);D4(6:end);D1(1:5)];
% 	data(roiIdx).FDGvideo	= [D2(6:end);D5(6:end);D2(1:5)];
% 	data(roiIdx).FDGav		= [NaN(size(D1(6:end)));D3(6:end);D3(1:5)];
% 	data(roiIdx).group		= [ones(size(D1(6:end)));ones(size(D4(6:end)))+1;ones(size(D1(1:5)))+2];
% 	data(roiIdx).Phoneme	= [F1(6:end);F1(6:end);F1(1:5)];
% 	data(roiIdx).roi		= roifiles(roiIdx);
	
	
end

pa_datadir
save('petancova','data');

function [D,Fs,SIR] = getstats(files,roifiles,N,cond)
nroi	= numel(roifiles);
D		= 0;
nvoxels	= 5000;
n		= {files(1:end,cond).name};
for ii	= 1:nroi
	roiname	= ['E:\DATA\KNO\PET\marsbar-aal\' roifiles{ii}];
	FDG		= getvoxels(n,roiname,nvoxels);
	diff	= nanmean(FDG,2);
	D		= D+diff;
end
D		= D/nroi;
Fs		= N(1:end,6);
SIR = N(1:end,21);




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
