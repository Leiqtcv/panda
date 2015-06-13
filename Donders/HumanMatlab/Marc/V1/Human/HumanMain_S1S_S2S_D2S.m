%==================================================================
%								With target list
%==================================================================
% RemListFile = ['D:\Tom\HumanMatlab\Human\REMAINING' datestr(now,'yyyy-mm-dd') 'part1.mat'];
% save(RemListFile,'RemainTarList','-mat')
% close(com)
%%
cd('D:\HumanMatlab\Tom\DAT')
close all
clear all
fclose all;

%Experiment  =   'static 1 step';
%Experiment  =   'static 2 step';
Experiment  =   'dynamic 2 step';

% if strcmpi(Experiment,'continue')
%     RemListFile = ['D:\HumanMatlab\Tom\TrailList\REMAINING' datestr(now,'yyyy-mm-dd') 'part1.mat'];
% end
%%
% standard files
GazeCalNetFile  = 'not exist';
HeadCalNetFile  = 'D:\HumanMatlab\Tom\NET\headcoil.net';
DataDir         = 'D:\Tom\Dat\';

% Initialize
HumanInit

% create extra windows
HumanConsole
HumanUI_window
savefiles
HumanPlotRA16Channels
HumanPlotTarsInScoop

% position windows
positionallfigs

% set file names
DF          = askfilename;
cDatFile	= DF;
DataDir     = [cd filesep];
cLogFile	= [DF(1:end-4) '.log'];
HuiDatFile	= findobj('tag','DatFile');
HuiLogFile	= findobj('tag','LogFile');
set(HuiDatFile,'UserData',[DataDir cDatFile])
set(HuiLogFile,'UserData',[DataDir cLogFile])
savefiles

% toggle channel 8 off
HuiCh		= nan(8,1);
for I_ch = 1:8
    HuiCh(I_ch) = findobj('tag',['SaveCh' num2str(I_ch)]);
    if ismember(I_ch,[8]) % not data channels
        set(HuiCh(I_ch),'value',get(HuiCh(I_ch),'Min'))
    else
        set(HuiCh(I_ch),'value',get(HuiCh(I_ch),'Max'))
    end
end

%% select file with target

% FLAG_rndlist:         [1] Randomize list

switch Experiment
    case 'static 1 step'
        ListFile = 'D:\HumanMatlab\Tom\TrailList\Static1step.mat';
        CompleteTarList = load(ListFile);
        CompleteTarList = CompleteTarList.Targets;
    case 'static 2 step'
        ListFile = 'D:\HumanMatlab\Tom\TrailList\Static2step.mat';
        CompleteTarList = load(ListFile);
        CompleteTarList = CompleteTarList.Targets;
    case 'dynamic 2 step'
        ListFile = 'D:\HumanMatlab\Tom\TrailList\Static2step.mat';
        CompleteTarList = load(ListFile);
        CompleteTarList = CompleteTarList.Targets;
end
%% timing & stimulus props
FixDur          = [400 800]; %ms
Gap1Dur         = 50; %ms
Tar1Dur         = 50; %ms
Gap2Dur         = 50; %ms
Tar2Dur         = 50; %ms
FixInt          = 10; %perc.
Tar1Int         = 10; %perc.
Tar2Int         = 10; %perc.
VelCrit         = -15; % deg/s
PredictionDelay = 50;%ms
TrigDel         = 0; %ms
TTLDur          = 100; %ms
AcqDur          = 1500; %samples

Fsamp           = 1017.25; %RA16 samp freq

% create fix window
WinOffset       = [0 -1];
WinSize         = [4 4];
Xnet            = 0; % net ID
Ynet            = 1;
Xh              = 2; % hysteresis size
Yh              = 2;
WinProp         = [0,Xnet,Ynet,Xh*10,Yh*10]; % index is window no. use same in stims (win.index)
[str] = micro_cmd(com,cmdFixWnd,sprintf('%d %d %d %d %d',WinProp));
for I_w = 1:8
    WinProp         = [I_w,Xnet,Ynet,Xh*10,Yh*10]; % index is window no. use same in stims (win.index)
    [str] = micro_cmd(com,cmdFixWnd,sprintf('%d %d %d %d %d',WinProp));
end
%% put variables in UI window
set(HuiFixDurMin,'enable','on','string',num2str(FixDur(1)))
set(HuiFixDurMax,'enable','on','string',num2str(FixDur(2)))
set(HuiGap1Dur,'enable','on','string',num2str(Gap1Dur))
set(HuiGap2Dur,'enable','on','string',num2str(Gap2Dur))
set(HuiTar1Dur,'enable','on','string',num2str(Tar1Dur))
set(HuiTar2Dur,'enable','on','string',num2str(Tar2Dur))
set(HuiFixInt,'enable','on','string',num2str(FixInt))
set(HuiTar1Int,'enable','on','string',num2str(Tar1Int))
set(HuiTar2Int,'enable','on','string',num2str(Tar2Int))
set(HuiVelCrit,'enable','off','string',num2str(VelCrit))
set(HuiPredDel,'enable','off','string',num2str(PredictionDelay))
set(HuiTrigDel,'enable','off','string',num2str(TrigDel))
set(HuiTTLDur,'enable','off','string',num2str(TTLDur))
set(HuiAcqDur,'enable','off','string',num2str(AcqDur))

%% make standard stimuli
HumanMakeStdStim_S1S_S2S_D2S

%% Start paradigm
RUN = 1;
TimeOut_Errors = zeros(1,9); % for debugging
TrialIx = 0;
RemainTarList = CompleteTarList;
while RUN == 1
    TrialIx = TrialIx +  1;
    set(Hcons(4),'string',sprintf('[%s] Tr:%3.0f/%3.0f',Experiment,TrialIx,size(RemainTarList,1)))
    
    %% apply current trial props
    % Select a Tar Sequence from remaining list
    %IxTarList = 1; % always first
    IxTarList = rand_num([1 size(RemainTarList,1)]); % random
    CurTarList = RemainTarList(IxTarList,:);
    
    % extract Nstep (0 = single step)
    Nstep = CurTarList(1)-1;
    
    % extract target positions
    Rngs = CurTarList([2:2:21]);
    Spks = CurTarList([3:2:21]);
    Rngs = Rngs(1:Nstep+1);
    Spks = Spks(1:Nstep+1);
    [A,E]=sky2azel(Rngs,Spks);
    set(HCurTar,'xdata',A,'ydata',E)
    
    % position target 1
    cRng = Rngs(1);
    cSpk = Spks(1);
    SkyTar1.pos			= [cSpk cRng];
    
    % position target 2
    if Nstep+1>=2
        cRng = Rngs(2);
        cSpk = Spks(2);
        SkyTar2.pos			= [cSpk cRng];
    end
    
    % position goal of speed
    switch Experiment
        case  'static 1 step'
        case 'static 2 step'
        case 'dynamic 2 step'
            cRng = Rngs(end-1);
            cSpk = Spks(end-1);
            [A,E]=sky2azel(cRng,cSpk);
            Speed.pos               = [A E];
    end
    
    % Change Events
    switch Experiment
        case  'static 1 step'
            SkyTar1.event = 4;
        case 'static 2 step'
            SkyTar1.event = 5;
            SkyTar2.start(1) = 5;
            SkyTar2.stop(1) = 5;
            SkyTar2.event = 4;
        case 'dynamic 2 step'
            SkyTar1.event = 5;
            SkyTar2.start(1) = 6;
            SkyTar2.stop(1) = 6;
            SkyTar2.event = 4;
    end
    
    % Change timing
    cFixDurMinMax   = [str2double(get(HuiFixDurMax,'string')) str2double(get(HuiFixDurMin,'string'))];
    cFixDur         = rand_num(cFixDurMinMax);
    cTar1Dur        = str2double(get(HuiTar1Dur,'string'));
    cTar2Dur        = str2double(get(HuiTar2Dur,'string'));
    cGap1Dur        = str2double(get(HuiGap1Dur,'string'));
    cGap2Dur        = str2double(get(HuiGap2Dur,'string'));
    cTrigDel        = str2double(get(HuiTrigDel,'string'));
    cVelCrit        = str2double(get(HuiVelCrit,'string'));
    switch Experiment
        case  'static 1 step'
            SkyFix.stop(2)      = cFixDur;
            SkyTar1.start(2)    = cGap1Dur;
            SkyTar1.stop(2)     = cGap1Dur+cTar1Dur;
        case 'static 2 step'
            SkyFix.stop(2)      = cFixDur;
            SkyTar1.start(2)    = cGap1Dur;
            SkyTar1.stop(2)     = cGap1Dur+cTar1Dur;
            SkyTar2.start(2)    = cGap2Dur;
            SkyTar2.stop(2)     = cGap2Dur+cTar2Dur;
        case 'dynamic 2 step'
            SkyFix.stop(2)      = cFixDur;
            SkyTar1.start(2)    = cGap1Dur;
            SkyTar1.stop(2)     = cGap1Dur+cTar1Dur;
            Speed.start(2)      = cGap1Dur+cTar1Dur;
            Speed.level         = cVelCrit;
            SkyTar2.start(2)    = cTrigDel;
            SkyTar2.stop(2)     = cTrigDel+cTar2Dur;
    end
    % todo: velocity on off
    
    % Acquisition duration
    if Nstep+1>=2
        cAcqDur = 1200;
    else
        cAcqDur = 1000;
    end
    Nsamp = round((cGap1Dur + cTar1Dur + cGap2Dur + cTar2Dur + cAcqDur)/1000*Fsamp);
    RA16_1.SetTagVal('Samples',Nsamp);
    Rec.stop(2) = cAcqDur;
    set(HuiAcqDur,'string',num2str(Nsamp));
    
    
    set(Hcons(3),'string',sprintf('ListSize:%3.0f\n    [R, S]\nT1: [%1.0f,%2.0f]\nT2: [%1.0f,%2.0f]\nFixDur: %4.0f',size(RemainTarList,1),fliplr(SkyTar1.pos),fliplr(SkyTar2.pos),cFixDur))
    
    %% load and start micro controller
    % prepare
    c=1; clear stims
    switch Experiment
        case  'static 1 step'
            stims(c) = Bar0;c=c+1;
            stims(c) = Bar1;c=c+1;
            stims(c) = Bar2;c=c+1;
            stims(c) = SkyFix;c=c+1;
            stims(c) = SkyTar1;c=c+1;
            stims(c) = Vib;c=c+1;
            stims(c) = Rec;c=c+1;
        case 'static 2 step'
            stims(c) = Bar0;c=c+1;
            stims(c) = Bar1;c=c+1;
            stims(c) = Bar2;c=c+1;
            stims(c) = SkyFix;c=c+1;
            stims(c) = SkyTar1;c=c+1;
            stims(c) = SkyTar2;c=c+1;
            stims(c) = Vib;c=c+1;
            stims(c) = Rec;c=c+1;
        case 'dynamic 2 step'
            stims(c) = Bar0;c=c+1;
            stims(c) = Bar1;c=c+1;
            stims(c) = Bar2;c=c+1;
            stims(c) = SkyFix;c=c+1;
            stims(c) = SkyTar1;c=c+1;
            stims(c) = SkyTar2;c=c+1;
            stims(c) = Speed;c=c+1;
            stims(c) = Vib;c=c+1;
            stims(c) = Rec;c=c+1;
    end
    
    % Activate microcontroller for this trial
    TimeOut_ix = 1; % if time out occurs, this is the index
    micro_cmd(com, cmdNextTrial, ''); % New Trial
    
    % put trial in microcontroller
    nStim = size(stims,2);
    TimeOut_ix = 2;
    micro_stims(com, nStim, stims);
    
    % start trial
    TimeOut_ix = 3;
    micro_cmd(com, cmdStartTrial, '');
    
    %% loop untill trial is done
    TimeOut_ix = 4;
    res = micro_getValues(com, cmdStateTrial, '');
    while res ~= statDoneTrial
        % state of trial
        TimeOut_ix = 5;
        State = micro_cmd(com, cmdState, '');
        State = sscanf(State, '%d');
        
        % plot state in console
        ConsStr = stimNames([stims.stim],:);
        ConsStr = [char(ConsStr) repmat(double(' :'),size(ConsStr,1),1)];
        sState = ones(size(ConsStr,1),1)*double('999 ');
        sState(1:numel(State),:) = eval(['[' sprintf('''%3.0f '';',State) ']']);
        sState = [sState(1:numel(State),:)  statNamesStims(State+1,:)];
        cConsStr = [ConsStr sState];
        set(Hcons(1),'string',cConsStr)
        
        % plot targets
        sel = State == 1 & ismember([stims.stim],[stimSky])';
        if any(sel)
            Pos = [stims(sel).pos];
            Spk = Pos(1:2:end);
            Rng = Pos(2:2:end);
            level = [stims(sel).level]/255;
            level = level(end);
            
            if Spk == 0
                A=0;E=0;
            else
                [A,E]=sky2azel(Rng,Spk);
            end
            set(Htar,'xdata',A,'ydata',E)
            
            sel = Spk == 0 & Rng == 1;
            if any(sel)
                set(Htar,'markeredgecolor','r','markerfacecolor','r')
            else
                set(Htar,'markeredgecolor','g')
            end
            set(Htar,'markerfacecolor',[0 1 0]*level)
        end
        
        % plot window
        sel = State == 1 & ismember([stims.stim],[stimFixWnd])';
        if any(sel)
            C = [stims(sel).pos];
            R = [stims(sel).width];
            [X,Y] = rect2patch(C,R);
            set(Hwnd1,'xdata',X,'ydata',Y)
            [X,Y] = rect2patch(C,R-[Xh Yh]);
            set(Hwnd2,'xdata',X,'ydata',Y)
        end
        
        % plot channels of RA16, TDT state and IO bits
        TimeOut_ix = 6;
        HumanPlotRA16Channels
        TDTmonitor
        IObitsmonitor
        savefiles
        
        % is ready?
        TimeOut_ix = 7;
        res = micro_getValues(com, cmdStateTrial, '');
    end
    
    %% Trial is Done: Results
    TimeOut_ix = 8;
    [result msg] = micro_getResult(com);
    disp(sprintf('Time span %d mSec',msg(2)));
    nError = msg(1);
    if (nError >= 0)
        disp(result);
    else
        disp('****************************************');
        disp(sprintf('Error: %d',nError));
        %pause(1);
    end
    
    % first row
    res = result(1,[1:3]);
    num  = res(1);
    ITI  = res(2);
    span = res(3);
    if get(HuiDispStuff,'value')==1
        disp('========================================');
        disp(sprintf('Trial = %4d, ITI = %4d, Span = %d, Nstim = %d',TrialIx,ITI,span,num));
        disp('');
    else
        if round(TrialIx/20)==TrialIx/20
            clc
        end
    end
    
    % other rows
    TimeOut_ix = 9;
    Ton = nan(num,1);
    Toff = nan(num,1);
    status = nan(num,1);
    kind = nan(num,1);
    if get(HuiDispStuff,'value')==1
        disp(sprintf(' stim   locat \t   start    stop  duration event'))
    end
    for idx=1:num
        [res1] = result(idx+1,:);
        kind(idx)   = res1(1);
        status(idx) = res1(2);
        Ton(idx)    = res1(3);
        Toff(idx)   = res1(4);
        if get(HuiDispStuff,'value')==1
            str = (sprintf('%2d %s[%2d,%2d]\t (%5d -> %5d = %5d) %3d',...
                idx,stimNames(kind(idx),:),stims(idx).pos(1),stims(idx).pos(2),Ton(idx),Toff(idx),Toff(idx)-Ton(idx),stims(idx).event));
            switch kind(idx)
                case {stimBar, stimSky, stimLas, stimFixWnd}
                    str = [str sprintf('[%s]',statNames(status(idx),:))];
            end
            disp(str)
            str = [sprintf('%2d %s',idx,stimNames(kind(idx),:)) repmat(' ',1,round(Ton(idx)/500)) repmat('-',1,round((Toff(idx)-Ton(idx))/500))];
            disp(str)
        end
    end
    
    %
    NsampStore=RA16_1.GetTagVal('Samples');
    
    % output result to console
    correct = ~any(ismember(status,statError)) && any(ismember(status,statDone));
    if correct == 1
        set(Hcons(5),'string','Correct','BackGroundColor','g')
    else
        set(Hcons(5),'string','Incorrect','BackGroundColor','r')
    end
    
    %% Save data
    % put variables in LOG mtx
    % NB: Use results from MicroController, not the variables set
    LOG = LOGREC;
    LOG.Trial = TrialIx;
    LOG.NsampSet = NsampStore;
    LOG.StimNames = stimNames(kind,:);
    LOG.Ton = Ton;
    LOG.Toff = Toff;
    LOG.Status = statNames(status,:);
    LOG.Correct = correct;
    LOG.TarPos = reshape([stims.pos],2,[])';
    LOG.Level = [stims.level]'/2.55;
    LOG.stim = stims;
    
    % Store TDT buffer in file and save LOG info
    saveTDT
    set(Hcons(2),'string',['Save Duration: ' sprintf('%5.2f',Savedur*1000)])
    
    %% update target list to choose from
    if correct == 1
        sel = ones(size(RemainTarList,1),1);
        sel(IxTarList) = 0;
        RemainTarList = RemainTarList(sel==1,:);
        if get(HuiDispStuff,'value')==1
            disp(['Tar to go: ' num2str(size(RemainTarList,1))])
        end
    end
    if isempty(RemainTarList)
        RUN = 0;
    end
end
%% finalize

% save window positions
clear WP*
CurField = 'WPConsole';
HF = findobj('Tag',CurField(3:end));
CurPos = get(HF,'position');
eval([CurField '=CurPos;'])
CurField = 'WPUserInterface';
HF = findobj('Tag',CurField(3:end));
CurPos = get(HF,'position');
eval([CurField '=CurPos;'])
CurField = 'WPTargets';
HF = findobj('Tag',CurField(3:end));
CurPos = get(HF,'position');
eval([CurField '=CurPos;'])
CurField = 'WPBitMonitor';
HF = findobj('Tag',CurField(3:end));
CurPos = get(HF,'position');
eval([CurField '=CurPos;'])
CurField = 'WPActXWin';
HF = findobj('Tag',CurField(3:end));
CurPos = get(HF,'position');
eval([CurField '=CurPos;'])
CurField = 'WPSaveFiles';
HF = findobj('Tag',CurField(3:end));
CurPos = get(HF,'position');
eval([CurField '=CurPos;'])
CurField = 'WPRA16Scope';
HF = findobj('Tag',CurField(3:end));
CurPos = get(HF,'position');
eval([CurField '=CurPos;'])
save('D:\HumanMatlab\V1\windowpositions.mat','WP*');
%% close port
close(com)
close all
HumanRepairLog(LogFile)