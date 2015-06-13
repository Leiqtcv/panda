function pa_prior_methodsfigure1

% Subtract Bias (Offset, which can be different for various blocks/sessies
% This removes noise (artificial variation when data is combined, e.g. in
% one set you start from +10 and another time you start at +3, when
% combining sets, the responses will be distributed largely. But when the
% offset is 0 in both, the distribution of responses can be combined, no
% artificial variation.

%% Initialization
close all
clear all
clc

%% Sessions subject MW
fnames = {'RG-MW-2011-12-02-0001';'RG-MW-2011-12-02-0002';'RG-MW-2011-12-02-0003';'RG-MW-2011-12-02-0004';...
	'RG-MW-2011-12-02-0005';'RG-MW-2011-12-02-0006';'RG-MW-2011-12-02-0007';'RG-MW-2011-12-02-0008';...
	'RG-MW-2011-12-08-0001';'RG-MW-2011-12-08-0002';'RG-MW-2011-12-08-0003';'RG-MW-2011-12-08-0004';...
	'RG-MW-2012-01-11-0001';'RG-MW-2012-01-11-0002';'RG-MW-2012-01-11-0003';'RG-MW-2012-01-11-0004';...
	'RG-MW-2012-01-12-0005';'RG-MW-2012-01-12-0006';'RG-MW-2012-01-12-0007';'RG-MW-2012-01-12-0008';...
	'RG-MW-2012-01-19-0001';'RG-MW-2012-01-19-0002';'RG-MW-2012-01-19-0003';'RG-MW-2012-01-19-0004';...
	}; % data-files
conditions = [3 2 3 1,...
	3 2 1 3,...
	2 3 1 3,...
	2 3 1 3,...
	3 1 3 2,...
	1 3 3 2
	]; % Sessions/condtions: 1 - 10 deg, 2 - 29 deg, 3 - 50 deg, 4 - 50 deg
rng = [10 30 50];
col = gray(3);
for ii = 3:-1:1
	sel = conditions==ii;
	
	fname	= fnames(sel);
	nfiles	= length(fname);
	SS		= []; 
	for jj = 1:nfiles
		file		= fname{jj};
		pa_datadir(['Prior\' file(1:end-5)]);
		S	= load(file); %load fnames(ii) = load('fnames(ii)');
		Sac			= S.Sac;
		Stim		= S.Stim;
		SupSac		= pa_supersac(Sac,Stim,2,1);
		SS			= [SS;SupSac]; %#ok<AGROW>
	end
	TarAz	= SS(:,23);
	TarEl	= SS(:,24);
	
	subplot(1,3,ii)
	h		= plot(TarAz,TarEl,'ko','MarkerFaceColor',[.7 .7 .7],'LineWidth',1,'MarkerSize',3);
	set(h,'MarkerFaceColor',col(ii,:));
	hold on
	h		= patch([-11 -11 11 11],[-11 11 11 -11],'k');
	alpha(h,0.1); set(h,'EdgeColor','none');

	h		= patch([-29 -29 29 29],[-29 29 29 -29],'k');
	alpha(h,0.1); set(h,'EdgeColor','none');
	
	h		= patch([-51 -51 51 51],[-51 51 51 -51],'k');
	alpha(h,0.1); set(h,'EdgeColor','none');

	axis([-60 60 -60 60]);
	axis square;
	xlabel('Target azimuth (deg)');
	if ii==1
		ylabel('Target elevation (deg)');
	end
	box off
	title(rng(ii))
	set(gca,'XTick',-50:25:50,'YTick',-50:25:50);
end
pa_datadir;
print('-depsc','-painter',mfilename);

