%%-- Analyse Visual

function avam_v_analysebutton

clc
clear all
close all

filename = 'RG-MH-2015-01-09-0002';
%% -- COMBINE DATA SETS -- %%
% for pp = 1:length(subjects)
% 	subject = subjects{pp};
% 	
% 	if subject == 1
% 		pa_datadir('A9_Main\FM Control\RG-RG-2014-10-08')
% 		filenames = {'RG-RG-2014-10-08-0001';'RG-RG-2014-10-08-0002';'RG-RG-2014-10-10-0001';'RG-RG-2014-10-10-0002'};
% 	elseif subject == 2
% 		pa_datadir('A9_Main\FM Control\RG-PB-2014-10-14')
% 		filenames = {'RG-PB-2014-10-14-0005';'RG-PB-2014-10-14-0002';'RG-PB-2014-10-14-0003';'RG-PB-2014-10-14-0004'};
% 	end
% 	
% 	%-- Combine data-sets
% 	SD = [];
% 	cLogd = [];
% 	for hh = 1:length(filenames)
% 		filename = filenames{hh};
% 		% 		[SS,cLog] = clean_data(filename,subject);
% 		load(filename);
% 		SS = pa_supersac(Sac,Stim,2,1);
% 		[~,~,cLog]	 = pa_readcsv(filename);
% 		if saccade == 1
% 			%-- remove second saccade
% 			selrem = SS(:,2)>1;
% 			SS	   = SS(~selrem,:);
% 		elseif saccade == 2
% 			%-- choose second/last saccade
% 			untr = unique(SS(:,1));
% 			for gg = 1:length(untr)
% 				tr = untr(gg);
% 				tS  = SS(:,1)==tr;
% 				nrsac = sum(tS);
% 				sel = SS(:,1)~= tr | SS(:,1)== tr & SS(:,2)==nrsac;
% 				SS = SS(sel,:);
% 			end
% 		end
% 		
% 		%-- add missing trials
% 		SS	   = add_missing_trials3(SS,cLog);
%  		%-- clean data
% 		[SS,cLog] = clean_data(SS,cLog,subject,hh);
% 		
% 		
% 
% 		
% 		SD     = [SD;SS]; %#ok<*AGROW>
% 		cLogd  = [cLogd;cLog];
% 	end
% 	SS = SD;
% 	cLog = cLogd;

%% -- VISUAL ANALYSIS -- %%

%-- Get Reaction Time via button press--%
[e,c,cLog]     = pa_readcsv([filename '.csv']); %#ok<*ASGLU>
Nsamples	= c(1,6);					   % # of samples
Nchan		= e(:,8);
fname		= pa_fcheckext(filename,'dat');
dat			= pa_loaddat(fname,Nchan,Nsamples);

btn = squeeze(dat(:,:,4));

% -- get according visual information
int = cLog(:,2)==7;
intid =cLog(int,10);

% -- Buttonpresstime

for bb=1:size(btn,2);
    sel = btn(:,bb)>-0.002;
    RespTime = find(sel,1);
    if sum(sel) == 0;
        RespTime = NaN;
    end
    RT(bb) = RespTime;
end

RT = RT';

% - get matrix, intensity and onset dimlight

onset = cLog(:,2)==7;
onsetid =cLog(onset,[10 8]);

onsetid(:,3) = RT;
onsetid(:,4) = onsetid(:,3)-onsetid(:,2);

% - plot according to different intensities

uint = unique(onsetid(:,1));
for ii = 1:length(uint);
    sel = onsetid(:,1) == uint(ii);
    bla = onsetid(sel,4);
    figure(1);
    subplot(4,1,ii);
    hist(bla);
    xlabel('reaction time (ms)');
    ylabel(uint(ii));
    box off;
	axis square;
	axis([-400 1000 0 4]);
end



    

% 	%Plot
% 	tie = {'per. 15';'per. 136';'per. 258';'per. 379';'per. 500'};
% 	titel = tie{ii};
% 	figure(1)
% 	subplot(length(selall),1,ii)
% 	hist(RT(ii,:),11)
% 	box off
% 	axis square
% 	axis([-400 1000 0 4])
% 	ylabel(titel)
% 	if ii == length(selall)
% 		xlabel('reaction time (ms)')
% 	end
end
