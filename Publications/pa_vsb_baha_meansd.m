

%% Initialization
close all
clear all
clc

%% Records / Protocol
cd('E:\DATA\KNO\vsb-baha');
fname			= 'Overzicht.xlsx';
[NUM,TXT,RAW] = xlsread(fname);
nfiles = size(TXT,1)-1; % number of files / subjects
dnames = TXT(2:nfiles+1,1); % directory names / subjects
cond		= TXT(1,2:end); % experimental condition
deafside	= TXT(2:nfiles+1,5); % deaf side
filenmbr = NUM(1:4,1:3); % file numbers / experimental condition
indxfiles = 1:nfiles;
id = 101;
% indxfiles = 4
%% Load data


col = jet(nfiles);
for jj = 1:3 % for every condition
	T = [];
	R = [];
	%% load target and response
	% 	try
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
		tar = round(tar/25)*25;
		uTar = unique(tar);
		nTar = numel(uTar);
		mu = NaN(nTar,1);
		sd = mu;
		for kk = 1:nTar
			sel = tar == uTar(kk);
			mu(kk) = mean(res(sel));
			sd(kk) = std(res(sel))./sqrt(sum(sel));
		end
		figure(1)
		subplot(2,3,jj)
		% 			errorbar(uTar,mu,sd,'ko-','LineWidth',2,'MarkerFaceColor',col(ii,:));
		plot(uTar,mu,'k-','LineWidth',1,'MarkerFaceColor','w','Color',[.7 .7 .7]);
		
		hold on
		axis([-90 90 -90 90]);
		axis square;
		pa_unityline;
		% 			pause
		
		T = [T uTar];
		R = [R mu];
		
	end
	errorbar(nanmean(T,2),nanmean(R,2),nanstd(R,[],2)./sqrt(size(R,2)),'ko-','LineWidth',2,'MarkerFaceColor','w');
	
	figure(2)
	subplot(1,3,jj)
	errorbar(nanmean(T,2),nanmean(R,2),nanstd(R,[],2)./sqrt(size(R,2)),'ko-','LineWidth',2,'MarkerFaceColor','w');
	
	hold on
	
end

% return

%% BAHA
nfiles = size(TXT,1)-1; % number of files / subjects
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
			tar = round(tar/25)*25;
			uTar = unique(tar);
			nTar = numel(uTar);
			mu = NaN(nTar,1);
			sd = mu;
			for kk = 1:nTar
				sel = tar == uTar(kk);
				mu(kk) = mean(res(sel));
				sd(kk) = std(res(sel))./sqrt(sum(sel));
			end
			figure(1)
			subplot(2,3,jj+3)
			% 			errorbar(uTar,mu,sd,'ko-','LineWidth',2,'MarkerFaceColor',col(ii,:));
			plot(uTar,mu,'k-','LineWidth',1,'MarkerFaceColor','w','Color',[.7 .7 .7]);
			
			hold on
			axis([-90 90 -90 90]);
			axis square;
			pa_unityline;
			% 			pause
			
			T = [T uTar];
			R = [R mu];
		end
	end
	errorbar(nanmean(T,2),nanmean(R,2),nanstd(R,[],2)./sqrt(size(R,2)),'ko-','LineWidth',2,'MarkerFaceColor','w');
	figure(2)
	subplot(1,3,jj)
	errorbar(nanmean(T,2),nanmean(R,2),nanstd(R,[],2)./sqrt(size(R,2)),'ro-','LineWidth',2,'MarkerFaceColor','w');
end

for ii = 1:3
	subplot(1,3,ii)
	box off;
	axis square;
	pa_unityline;
end