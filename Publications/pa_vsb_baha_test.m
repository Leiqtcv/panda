

%% Initialization
close all
clear all
clc

%% Records / Protocol
cd('E:\DATA\KNO\vsb-baha');
fname			= 'Overzicht.xlsx';
[NUM,TXT,RAW] = xlsread(fname);

nfiles = size(TXT)-1; % number of files / subjects
dnames = TXT(2:nfiles+1,1); % directory names / subjects
cond		= TXT(1,2:end); % experimental condition
deafside	= TXT(2:nfiles+1,5); % deaf side
filenmbr = NUM(1:4,1:3); % file numbers / experimental condition
indxfiles = 1:nfiles;
id = 101;
% indxfiles = 4
%% Load data
for jj = 1:3 % for every condition
	T = [];
	R = [];
	%% load target and response
	try
		for ii = indxfiles % per subject
			cd('E:\DATA\KNO\vsb-baha');
			cd(dnames{ii});
			fname = [dnames{ii} '-000' num2str(filenmbr(ii,jj))];
			load(fname);
			SupSac = pa_supersac(Sac,Stim,2,1);
			sel = SupSac(:,30) == id;
			SupSac = SupSac(sel,:);
			
			tar = SupSac(:,23);
			res = SupSac(:,8);
			if ~strcmp(deafside{ii},'R')
				tar = -tar;
				res = -res;
			end
			tar = round(tar/5)*5;
			uTar = unique(tar);
			nTar = numel(uTar);
			for kk = 1:nTar
				sel = tar == uTar(kk);
			end
			T = [T;tar];
			R = [R;res];
			
		end
		%% Graphics
		subplot(2,3,jj)
		pa_bubbleplot(T,R,jj,15);
		axis([-100 100  -100 100])
		axis square;
		set(gca,'XTick',-60:30:60,'YTick',-60:30:60);
		xlabel('Target azimuth (deg)');
		ylabel('Response azimuth (deg)');
		
		b = regstats(R,T,'linear','beta');
		h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
		title(cond{jj});
	end
end
% return

%% BAHA
nfiles = size(TXT)-1; % number of files / subjects
dnames = TXT(2:nfiles+1,6); % directory names / subjects
cond		= TXT(1,2:end); % experimental condition
deafside	= TXT(2:nfiles+1,10); % deaf side
filenmbr = NUM(1:4,6:8); % file numbers / experimental condition
indxfiles = 1:nfiles;
% indxfiles = 1

%% Load data
for jj = 1:3 % for every condition
	T = [];
	R = [];
	%% load target and response
	try
		for ii = indxfiles % per subject
			cd('E:\DATA\KNO\vsb-baha');
			cd(dnames{ii});
			fname = [dnames{ii} '-000' num2str(filenmbr(ii,jj))];
			load(fname);
			SupSac = pa_supersac(Sac,Stim,2,1);
			sel = SupSac(:,30) == id;
			SupSac = SupSac(sel,:);
			
			tar = SupSac(:,23);
			res = SupSac(:,8);
			if ~strcmp(deafside{ii},'R')
				tar = -tar;
				res = -res;
			end
			T = [T;tar];
			R = [R;res];
			
		end
		%% Graphics
		subplot(2,3,jj+3)
		pa_bubbleplot(T,R,jj,15);
		axis([-100 100  -100 100])
		axis square;
		set(gca,'XTick',-60:30:60,'YTick',-60:30:60);
		xlabel('Target azimuth (deg)');
		ylabel('Response azimuth (deg)');
		
		b = regstats(R,T,'linear','beta');
		h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
		title(cond{jj});
	end
end