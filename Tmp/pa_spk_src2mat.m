function pa_spk_src2mat
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
    [numeric,txt,raw] = xlsread('Joe-data-all.xlsx');                      %('joe-data-all.xlsx');
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
    for i = 100:length(ux);
        i
        sel     = days == ux(i,1) & depth == ux(i,2);         % selection for same day and same depth
        fnames  = files(sel,:);                            % filenames for same name and depth
        behave  = behaviour(sel,:);
        exps    = experiments(sel,:);                         % experiments done for cell at same day and depth
        selnat  = strcmpi(exps,'natsounds');
        % 		selpass = strcmpi(exps,'seqripple2');
        % 		selact  = strcmpi(exps,'seqripple2handle100');
        % 		seltone = strcmpi(exps,'tonerough');
        both    = any(selnat);                  % & any(sel40);
        if both
            k = k+1;
            a  = char(fnames(selnat));
            
            fname = a(1,:);
            cd(f32);
            if length(fname)>13
                datfile = fname(1:6);
            elseif length(fname)==13
                datfile = fname(1:5);
            end
            
            cd([datfile,'experiment']);
            
            cfg.filename  = fname;
            
            [spike,cfg] = pa_spk_readsrc(cfg);
            [spikeJ] = makematfile(spike,cfg)
            
            cd('C:\DATABK\CORTEX\JoeMat');
            fnam = fcheckext(cfg.filename,'.mat');
            save(fnam,'spikeJ');
            
        end
    end
end
%% THOR

if animal==2;
    f32 = 'C:\DATABK\CORTEX\ThorData';
    f32rm = 'C:\DATABK\CORTEX\ThorData';
    xcl = 'C:\DATABK\CORTEX';
    cd(xcl);
    [NUMERIC,TXT,RAW] = xlsread('Thor-data-all.xlsx');                          %('Thor-data-all.xlsx');
    
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
    for i = 100:length(ux);
        i
        sel     = days == ux(i,1) & depth == ux(i,2);         % selection for same day and same depth
        fnames  = files(sel,:);                            % filenames for same name and depth
        behave  = behaviour(sel,:);
        exps    = experiments(sel,:);                         % experiments done for cell at same day and depth
        selnat  = strcmpi(exps,'natsound1');
        % 		selpass = strcmpi(exps,'seqripple2');
        % 		selact  = strcmpi(exps,'seqripple2handle100');
        % 		seltone = strcmpi(exps,'tonerough');
        both    = any(selnat);                  % & any(sel40);
        if both
            k = k+1;
            a  = char(fnames(selnat));
            
            fname = a(1,:);
            if length(fname)<15;
                cd(f32)
                cd(fname(1:7));
            else
                cd(f32rm);
                cd(fname(1:15));
            end
            
            cfg.filename  = fname;
            
            [spike,cfg] = pa_spk_readsrc(cfg);
            [spikeJ] = makematfile(spike,cfg)
            
            
            cd('C:\DATABK\CORTEX\ThorMat');
            fnam = fcheckext(cfg.filename,'.mat');
            save(fnam,'spikeJ');
            
        end
    end
end