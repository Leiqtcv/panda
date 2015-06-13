close all
clear all
clc
warning off;
animal = 1;

if animal==1;
	
	
    % Joe's src-data is stored in:
    f32 = 'C:\DATABK\CORTEX\JoeData\';
    % Joe's protocol excel-file in:
    xcl = 'C:\DATABK\CORTEX\';
    cd(xcl);
    % Load Joe's filenames (which are incorrect, because some cells have
    % multiple files, because of reclustering).
    [numeric,txt,raw] = xlsread('Joe-data-all.xlsx');                       %('joe-data-all.xlsx');
	files           = txt(2:end,1); % 1st line is just title-row
	experiments     = txt(2:end,3); % type of experiments
	behaviour       = txt(2:end,2); % behaviour-file
	depth           = numeric(1:end,1); % depth of recording
	
	% Clustering, sorting, selecting spikes.
	%
	% How many clusters are there in the data. This has been observed by
	% Yoolla, and stored in the excel-file.
	cluster         = numeric(1:end,9);
	sel             = isnan(cluster);
	cluster(sel)    = 0;
	% The threshold has been observed by Yoolla.
	treshold        = numeric(1:end,10);
	sel             = isnan(treshold);
	treshold(sel)   = 0;
	
	% Recording "day"
	% Actually not the day, but the consecutive order of the recordings.
	% Get doubles from filename strings.
	days = nan(size(files));
	for i = 1:length(files)
		charfiles       = char(files(i));
		if length(charfiles)==13;
			days(i)          = str2double(charfiles(:,4:5));
		else
			days(i) = str2double(charfiles(:,4:6));
		end
	end
	
	% Recording order and depth determine a unique cell
	x	= [days depth];
	ux	= unique(x,'rows');
	% Initialization
	k		  = 0; % counter
	ALLRT500  = []; % reaction times for Active500
	ALLRT1000 = []; % reaction times for Active1000
	M500      = []; % mean reaction times for Active500
	M1000     = []; % mean reaction times for Active1000
	c         = 0;
	BFjoe  = [];
	for i = 1:length(ux);
		i;
		sel     = days == ux(i,1) & depth == ux(i,2);         % selection for same day and same depth
		fnames  = files(sel,:);                               % filenames for same name and depth
		behave  = behaviour(sel,:);
		exps    = experiments(sel,:);                         % experiments done for cell at same day and depth
		selpass = strcmpi(exps,'seqripple2');
		selact  = strcmpi(exps,'seqripple2handle100');
		seltone = strcmpi(exps,'tonerough');
		both    = any(selact) & any(selpass);                  % & any(sel40);
		if both
			k = k+1;		
	
     		a = char(fnames(selpass))
			tone = char(fnames(seltone));
			if length(a)>13
				hll = a(:,7:8);
			else
				hll = a(:,6:7);
			end
			
			spike = [];
			if size(hll,1) > 1;
				if str2double(hll(1,:))> str2double(hll(2,:)) || str2double(hll(1,:))< str2double(hll(2,:))
					for ii = 1:length(hll)
						fname        = a(ii,:);
						cd(f32);
						if length(fname)>13
							datfile = fname(1:6);
						elseif length(fname)==13
							datfile = fname(1:5);
						end
						
						cd([datfile,'experiment']);
						sel = strcmpi(files,fname);
						clus = cluster(sel);
						tresh = treshold(sel);
						cfg(ii).filename = (fname);
						
						[s,cfg] = pa_spk_readsrc(cfg(ii));
						
						if ~isempty(spike)
							trial       = [spike.trial];
							trial       = max(trial);
							trialorder  = [spike.trialorder];
							trialorder  = max(trialorder);
						else
							trial = 0;
							trialorder = 0;
						end
						b = size(s,2);
						for jj = 1:b
							s(jj).trial = s(jj).trial+trial;
							s(jj).trialorder= s(jj).trialorder+trialorder;
						end
						
						spike = [spike s];
					end
				else
					fname	= a(1,:);
					cd(f32);
					if length(fname)>13
						datfile = fname(1:6);
					elseif length(fname)==13
						datfile = fname(1:5);
					end
					cd([datfile,'experiment']);
					sel = strcmpi(files,fname);
					clus = cluster(sel);
					tresh = treshold(sel);
					cfg.filename = (fname);
					
					[spike,cfg] = pa_spk_readsrc(cfg);
				end
			else
				
				fname	= a(1,:);
				cd(f32);
				if length(fname)>13
					datfile = fname(1:6);
				elseif length(fname)==13
					datfile = fname(1:5);
				end
				cd([datfile,'experiment']);
				sel = strcmpi(files,fname);
				clus = cluster(sel);
				tresh = treshold(sel);
				cfg.filename = (fname);
				
				[spike,cfg] = pa_spk_readsrc(cfg);
			end
			
			[spikeP] = makematfile(spike,cfg,tresh,clus);
			
% 			bfrate
			cd('C:\DATABK\CORTEX\JoeMat\');
			fnam = fcheckext(cfg.filename,'.mat');
			save(fnam,'spikeP','spikeA','beh','bf','tw','bfrate');
			% 			pause
		end
	end
	keyboard
	close all;
	figure;
	subplot(121)
	n = sum(~isnan(ALLRT500(:,1)));
	X = (1:size(ALLRT500,2));
	Y = nanmedian(ALLRT500);
	Z = nanstd(ALLRT500)./sqrt(n);
	h1 = pa_errorpatch(X,Y,Z,'r');
	hold on
	n = sum(~isnan(ALLRT1000(:,1)));
	X = (1:size(ALLRT1000,2));
	Y = nanmedian(ALLRT1000);
	Z = nanstd(ALLRT1000)./sqrt(n);
	h2 = pa_errorpatch(X,Y,Z,'b');
	xlim([1 size(ALLRT500,2)]);
	ylim([0 600]);
	xlabel('recording sessions');
	ylabel('median reaction time');
	legend([h1,h2],{'Active 500';'Active 1000'});
	axis square;
	box off;
	
	subplot(122)
	stp = 5*round(std(ALLRT500)./sqrt(length(ALLRT500)));
	stp = 10;
	time  = -500:stp:1000;
	h500  = hist(ALLRT500,time);
	h500  = h500/sum(h500)*100;
	% 	h500   = smooth(h500,100);
	h1000  = hist(ALLRT1000,time);
	h1000   = h1000/sum(h1000)*100;
	% 	h1000  = smooth(h1000,100);
	plot(time,h500,'r-','linewidth',2);
	hold on
	plot(time,h1000,'b-','linewidth',2);
	hold off
	xlim([-500 1000]);
	% 	ylim([0 0.5]);
	xlabel('Time (ms) re. ripple onset');
	ylabel('Probability (%)');
	axis square;
	box off;
	
	cd('C:\all Data');
	save('Joe-reactiontimes','ALLRT500','ALLRT1000');
	
end
%% THOR

if animal==2;
	f32 = 'C:\all Data\ThorData\';
	f32rm = 'C:\all Data\Data\';
	xcl = 'C:\all Data\';
	cd(xcl);
	[NUMERIC,TXT,RAW] = xlsread('Copy of Thor-data.xlsx');                          %('Thor-data-all.xlsx');
	
	files           = TXT(2:end,1);
	experiments     = TXT(2:end,3);
	depth           = NUMERIC(1:end,2);
	behaviour       = TXT(2:end,2);
	
	shift           = NUMERIC(1:end,12);
	sel = isnan(shift);
	shift(sel) = 0;
	
	cluster         = NUMERIC(1:end,15);
	sel = isnan(cluster);
	cluster(sel) = 0;
	
	treshold       = NUMERIC(1:end,16);
	sel = isnan(treshold);
	treshold(sel) = 0;
	
	
	
	days = NaN(size(files));
	for i = 1:length(files)
		charfiles       = char(files(i));
		if length(charfiles)<15;
			days(i)          = str2double(charfiles(:,5:7));
		else
			days(i) = datenum(charfiles(:,6:15));
		end
	end
	
	X = [days depth];
	ux = unique(X,'rows');
	
	k = 0;
	ALLRT500  = [];
	ALLRT1000 = [];
	M500      = [];
	M1000     = [];
	
	for i = 1:190
		i
		graphflag = 1;
		sel     = days == ux(i,1) & depth == ux(i,2); % selection for same day and same depth
		fnames  = files(sel,:);          % filenames for same name and depth
		exps    = experiments(sel,:);     % experiments done for cell at same day and depth
		behave  = behaviour(sel,:);
		selpass = strcmpi(exps,'seqripple2');
		selact  = strcmpi(exps,'seqripple2handle100');
		seltone = strcmpi(exps,'tonerough');
		both    = any(selact) & any(selpass);
		
		if both
			k = k+1;
			
			ucll = char(fnames(selact));
			be   = char(behave(selact));
			
			spike   = [];
			tnumber = [];
			RT      = [];
			beh     = [];
			RW      = [];
			D       = [];
			for ii = 1:size(ucll,1);
				cllname    = ucll(ii,:);
				behavior   = be(ii,:);
				fname = cllname;
				if length(fname)<15;
					cd(f32)
					cd(fname(1:7));
				else
					cd(f32rm);
					cd(fname(1:15));
				end
				
				sel = strcmpi(files,fname);
				shft = shift(sel);
				clus = cluster(sel);
				tresh = treshold(sel);
				cfg(ii).filename   = (fname);
				cfg(ii).behaviour  = (behavior);
				
				[rt, TN, d, A, RV, RD, MD, rw] = ir_spk_readdat(cfg(ii).behaviour);
				if ~isempty(tnumber)
					trialnumber       = max(tnumber);
				else
					trialnumber       = 0;
				end
				
				g = size(rt,1);
				for gg = 1:g
					TN(gg) = TN(gg)+trialnumber;
				end
				TN = TN';
				rt = rt';
				rw = rw';
				d  = d';
				tnumber = [tnumber TN];
				RT      = [RT rt];
				RW      = [RW rw];
				D       = [D d];
				
				
				[s,cfg] = pa_spk_readsrc(cfg(ii));
				if ~isempty(spike)
					trial       = [spike.trial];
					trial       = max(trial);
					trialorder  = [spike.trialorder];
					trialorder  = max(trialorder);
				else
					trial = 0;
					trialorder = 0;
				end
				b = size(s,2);
				for jj = 1:b
					s(jj).trial = s(jj).trial+trial;
					s(jj).trialorder= s(jj).trialorder+trialorder;
				end
				
				spike = [spike s]; %#ok<*AGROW>
			end
			
			beh(2,:) = RT;
			beh(1,:) = tnumber;
			beh(3,:) = RW;
			beh(4,:) = D;
			
			[RT500,RT1000,m500,m1000] = separatereactiontime(RT,D);
			
			RTon500       = NaN(1,500);
			for ii   = 1:length(RT500)
				indx = RT500(ii);
				RTon500(ii) = indx;
			end
			
			RTon1000       = NaN(1,500);
			for jj   = 1:length(RT1000)
				indx = RT1000(jj);
				RTon1000(jj) = indx;
			end
			
			
			ALLRT500(:,k)    = RTon500;
			ALLRT1000(:,k)   = RTon1000;
			M500             = [M500 m500];
			M1000            = [M1000 m1000];
			
			
			[spikeA]        = makematfile(spike,cfg,tresh,clus);
			
			
			ucll= char(fnames(selpass))
			spike = [];
			for ii = 1:size(ucll,1);
				cllname = ucll(ii,:);
				fname = cllname;
				if length(fname)<15;
					cd(f32)
					cd(fname(1:7));
				else
					cd(f32rm);
					cd(fname(1:15));
				end
				sel = strcmpi(files,fname);
				shft = shift(sel);
				clus = cluster(sel);
				tresh = treshold(sel);
				cfg(ii).filename = (fname);
				
				[s,cfg] = pa_spk_readsrc(cfg(ii));
				
				if ~isempty(spike)
					trial       = [spike.trial];
					trial       = max(trial);
					trialorder  = [spike.trialorder];
					trialorder  = max(trialorder);
				else
					trial = 0;
					trialorder = 0;
				end
				b = size(s,2);
				for jj = 1:b
					s(jj).trial = s(jj).trial+trial;
					s(jj).trialorder= s(jj).trialorder+trialorder;
				end
				spike = [spike s];
			end
			
			[spikeP] = makematfile(spike,cfg,tresh,clus);
			tone  = char(fnames(seltone));
			if sum(seltone)> 0
				tone  = tone(1,:);
				fname = [tone '.f32'];
				
				if exist(fname,'file')
					[bf,tw,bfrate] = tuningwidth(fname,2,0);
				else
					bf       = NaN;
					tw       = NaN;
					bfrate   = NaN;
				end
			else
				bf       = NaN;
				tw       = NaN;
				bfrate   = NaN;
			end
			bfrate
			% 			figure;
			% 			time  = -500:1:1000;
			% 			h500  = hist(RTon500,time);
			% 			h500  = h500/sum(h500)*100;
			% 			h1000  = hist(RTon1000,time);
			% 			h1000  = h1000/sum(h1000)*100;
			% 			plot(time,h500,'r-','linewidth',2);
			% 			hold on
			% 			plot(time,h1000,'b-','linewidth',2);
			% 			hold off
			
			
			cd('C:\all Data\Tone\THOR');
			fnam = fcheckext(cfg.filename,'.mat');
			save(fnam,'spikeP','spikeA','beh','bf','tw','bfrate');
			% 									pause
		end
		
		
	end
	
	keyboard
	close all;
	figure;
	subplot(121)
	n = sum(~isnan(ALLRT500(:,1)));
	X = (1:size(ALLRT500,2));
	Y = nanmedian(ALLRT500);
	Z = nanstd(ALLRT500)./sqrt(n);
	h1 = pa_errorpatch(X,Y,Z,'r');
	hold on
	n = sum(~isnan(ALLRT1000(:,1)));
	X = (1:size(ALLRT1000,2));
	Y = nanmedian(ALLRT1000);
	Z = nanstd(ALLRT1000)./sqrt(n);
	h2 = pa_errorpatch(X,Y,Z,'b');
	xlim([1 size(ALLRT500,2)]);
	ylim([0 600]);
	xlabel('recording sessions');
	ylabel('mean reaction time');
	legend([h1,h2],{'Active 500';'Active 1000'});
	axis square;
	box off;
	
	subplot(122)
	figure;
	stp = 5*round(std(ALLRT500)./sqrt(length(ALLRT500)));
	stp = 10;
	time  = -500:stp:1000;
	h500  = hist(ALLRT500,time);
	h500  = h500/sum(h500)*100;
	h500   = smooth(h500,10);
	h1000  = hist(ALLRT1000,time);
	h1000   = h1000/sum(h1000)*100;
	h1000  = smooth(h1000,10);
	plot(time,h500,'r-','linewidth',2);
	hold on
	plot(time,h1000,'b-','linewidth',2);
	hold off
	xlim([-500 1000]);
	% 	ylim([0 0.5]);
	xlabel('Time (ms) re. ripple onset');
	ylabel('Probability (%)');
	axis square;
	box off;
	
	cd('C:\all Data');
	save('Thor-reactiontimes','ALLRT500','ALLRT1000');
	
end

%% Loading reaction time mat files

close all;
cd('C:\all Data');
load Joe-reactiontimes

ALLRT5001    = ALLRT500;
ALLRT10001   = ALLRT1000;

load Thor-reactiontimes

ALLRT5002    = ALLRT500;
ALLRT10002   = ALLRT1000;

% ALLRT500     = ALLRT5001+ALLRT5002;
% ALLRT1000    = ALLRT10001+ALLRT10002;

stp = 5*round(std(ALLRT500)./sqrt(length(ALLRT500)));
stp = 10;
time  = -500:stp:1000;

h5001  = hist(ALLRT5001,time);
h5001  = h5001/sum(h5001)*100;

h10001   = hist(ALLRT10001,time);
h10001   = h10001/sum(h10001)*100;

h5002  = hist(ALLRT5002,time);
h5002  = h5002/sum(h5002)*100;

h10002   = hist(ALLRT10002,time);
h10002   = h10002/sum(h10002)*100;

h500      = h5001+h5002;
h1000     = h10001+h10002;

figure;
h = area(time,h500); % Set BaseValue via argument
set(h,'FaceColor',[1 0 0.2],'EdgeColor',[1 0 0.2])
hold on
h = area(time,h5001); % Set BaseValue via argument
set(h,'FaceColor',[1 0 0],'EdgeColor',[1 0 0])
box off

figure;
h = area(time,h1000); % Set BaseValue via argument
set(h,'FaceColor',[0 0.3 1],'EdgeColor',[0 0.3 1])
hold on
h = area(time,h10001); % Set BaseValue via argument
set(h,'FaceColor',[0 0 1],'EdgeColor',[0 0 1])
box off



return

figure;
plot(time,h500,'r-','linewidth',2);
hold on
plot(time,h5001,'r-','linewidth',2);

hold off

xlim([-200 800]);
xlabel('Time (ms) re. ripple onset');
ylabel('Probability (%)');
axis square;
box off;

figure;
plot(time,h1000,'color','b','linewidth',2);
hold on
plot(time,h10001,'color','b','linewidth',2);
get(gca)
hold off

xlim([-200 800]);
% 	ylim([0 0.5]);
xlabel('Time (ms) re. ripple onset');
ylabel('Probability (%)');
axis square;
box off;
