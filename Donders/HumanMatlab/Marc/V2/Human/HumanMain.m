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

Experiment  =   'DMIcalibration';
Experiment  =   'StaticDoubleStep';

% if strcmpi(Experiment,'continue')
%     RemListFile = ['D:\HumanMatlab\Tom\TrailList\REMAINING' datestr(now,'yyyy-mm-dd') 'part1.mat'];
% end
%%
% standard files
HeadCalNetFile  = 'D:\HumanMatlab\Tom\NET\LinearHead.net';
GazeCalNetFile  = 'D:\HumanMatlab\Tom\NET\LinearCoil.net';
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

% FLAG_fix_is_T1:       [1] First target is fixation and not (0,0)
% FLAG_rndlist:         [1] Randomize list

FLAG_fix_is_T1 = 0;
switch Experiment
    case 'DMIcalibration'
        ListFile = 'D:\HumanMatlab\Tom\TrailList\DMIcalibration.mat';
        CompleteTarList = load(ListFile);
        CompleteTarList = CompleteTarList.IJkRoosTars;
    case 'StaticDoubleStep'
        ListFile = 'D:\HumanMatlab\Tom\TrailList\DoubleStep6002010-02-18.mat';
        CompleteTarList = load(ListFile);
        CompleteTarList = reshape(CompleteTarList.Mtx,21,[])';
end
%% timing & stimulus props
FixDur          = [600 1100]; %ms
Gap1Dur         = 50; %ms
Tar1Dur         = 50; %ms
Gap2Dur         = 50; %ms
Tar2Dur         = 50; %ms
FixInt          = 10; %perc.
Tar1Int         = 10; %perc.
Tar2Int         = 10; %perc.
VelCrit         = 100; % deg/s
PredictionDelay = 50;%ms
TrigDel         = 10; %ms
TTLDur          = 100; %ms

Fsamp           = 1017.25; %RA16 samp freq
MinMaxStep      = minmax(CompleteTarList(:,1)')-1; %zero is single step

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
set(HuiFixDurMin,'string',num2str(FixDur(1)))
set(HuiFixDurMax,'string',num2str(FixDur(2)))
set(HuiGap1Dur,'string',num2str(Gap1Dur))
set(HuiGap2Dur,'string',num2str(Gap2Dur))
set(HuiTar1Dur,'string',num2str(Tar1Dur))
set(HuiTar2Dur,'string',num2str(Tar2Dur))
set(HuiFixInt,'string',num2str(FixInt))
set(HuiTar1Int,'string',num2str(Tar1Int))
set(HuiTar2Int,'string',num2str(Tar2Int))
set(HuiVelCrit,'string',num2str(VelCrit))
set(HuiPredDel,'string',num2str(PredictionDelay))
set(HuiTrigDel,'string',num2str(TrigDel))
set(HuiTTLDur,'string',num2str(TTLDur))

% set(HuiWinX,'string',num2str(WinSize(1)))
% set(HuiWinY,'string',num2str(WinSize(2)))
% set(HuiHistX,'string',num2str(Xh),'enable','off')
% set(HuiHistY,'string',num2str(Yh),'enable','off')
% set(HuiOffsetX,'string',num2str(WinOffset(1)))
% set(HuiOffsetY,'string',num2str(WinOffset(2)))

%% make standard stimuli
HumanMakeStdStim_DMIcalib
%% Start paradigm
RUN = 1;
TimeOut_Errors = zeros(1,9); % for debugging
TrialIx = 0;
RewCount = 0;
RemainTarList = CompleteTarList;
while RUN == 1
    TrialIx = TrialIx +  1;
    set(Hcons(4),'string',sprintf('Tr:%3.0f Rew:%3.0f perc:%3.0f',TrialIx,RewCount,RewCount/TrialIx*100))

    %% apply current trial props
    % Select a Tar Sequence from remaining list
    if FLAG_rndlist == 1
        IxTarList = rand_num([1 size(RemainTarList,1)]);
    else
        IxTarList = 1;
    end
    CurTarList = RemainTarList(IxTarList,:);

    % extract Nstep (0 = single step)
    if FLAG_fix_is_T1 == 1
        Nstep = CurTarList(1)-2;
    else
        Nstep = CurTarList(1)-1;
    end

    % extract target positions
    Rngs = CurTarList([2:2:21]);
    Spks = CurTarList([3:2:21]);
    sel = Rngs==0 & Spks == 0;
    Rngs = Rngs(~sel);
    Spks = Spks(~sel);
%     Rngs  = cumsum(ones(1,numel(Spks)))+1;
%     Spks  = ones(1,numel(Spks))*3;

    [A,E]=sky2azel(Rngs,Spks);
    set(HCurTar,'xdata',A,'ydata',E)

    % position fixation target
    if FLAG_fix_is_T1 == 1
        cRng = Rngs(1);
        cSpk = Spks(1);
        SkyFix1.pos			=[cSpk cRng];
        SkyFix2.pos			=[cSpk cRng];
    end

    % position step targets
    if Nstep ~= 0
        for I_st = Nstep:-1:1
            if FLAG_fix_is_T1 == 1
                cRng = Rngs(I_st+1);
                cSpk = Spks(I_st+1);
            else
                cRng = Rngs(I_st);
                cSpk = Spks(I_st);
            end
            SkyTar(I_st).pos = [cSpk cRng];
        end
    end

    % position last target
    if FLAG_fix_is_T1 == 1
        cRng = Rngs(Nstep+2);
        cSpk = Spks(Nstep+2);
    else
        cRng = Rngs(Nstep+1);
        cSpk = Spks(Nstep+1);
    end
    SkyTarLast.pos			=[cSpk cRng];

    % position step windows and last window
    cWinOffset = [str2double(get(HuiOffsetX,'string')) str2double(get(HuiOffsetY,'string'))];
    for I_st = 1:Nstep
        Spks = SkyTar(I_st).pos(1);
        Rngs = SkyTar(I_st).pos(2);
        [A,E] = sky2azel(Rngs,Spks);
        Win(I_st).pos = [A E]+cWinOffset;
    end
    Spks = SkyTarLast.pos(1);
    Rngs = SkyTarLast.pos(2);
    [A,E] = sky2azel(Rngs,Spks);
    WinLast.pos = [A E]+cWinOffset;

    % size windows
    WinWidth = [str2double(get(HuiWinX,'string')) str2double(get(HuiWinY,'string'))];
    WinLast.width = WinWidth;
    for I_st = 1:Nstep
        Win(I_st).width = WinWidth;
    end

    % duration fixation
    cFixDur = [str2double(get(HuiFixDurMin,'string')) str2double(get(HuiFixDurMax,'string'))];
    cFixDur = rand_num(cFixDur);
    SkyFix2.stop(2) = cFixDur;
    
    % duration targets
    cTarDur = str2double(get(HuiTarDur,'string'));
%     SkyTarLast.stop(2) = cTarDur;
%     for I_st = 1:Nstep
%         SkyTar(I_st).stop(2) = cTarDur;
%     end
    
    % duration windows
    WinLast.stop(2) = cTarDur;
    for I_st = 1:Nstep
        Win(I_st).stop(2) = cTarDur;
    end

    % fixation duration inside window
    cWinDelay = str2double(get(HuiWinDel,'string'));
    WinLast.delay = cWinDelay;
    for I_st = 1:Nstep
        Win(I_st).delay = cWinDelay;
    end

    % duration reward
    cRewDur = str2double(get(HuiRewDur,'string'));
    Rew.stop(2) = cRewDur;

    % Response window:
    % Prediction delay
    % Bar2.stop(2) = str2double(get(HuiPredDel,'string'));
    % here tar duration

    % Acquisition duration
    cAcqDur = cFixDur + cTarDur;
    Nsamp = round(cAcqDur/1000*Fsamp);
    RA16_1.SetTagVal('Samples',Nsamp);

    % Intesities
    cTarInt = str2double(get(HuiTarInt,'string'));
    SkyTarLast.level = cTarInt;
    for I_st = 1:Nstep
        SkyTar(I_st).level = cTarInt;
    end
    
    % Events
    SkyTarLast.start(1)=100+Nstep;
    SkyTarLast.stop=[4 0];
    WinLast.start(1)=100+Nstep;
    WinLast.stop(1)=100+Nstep;

    set(Hcons(3),'string',sprintf('Rng:%2.0f Spk:%2.0f\nNstep:%2.0f\nListSize:%3.0f',cRng,cSpk,Nstep+1,size(RemainTarList,1)))

    %% load and start micro controller
    % prepare
    c=1; clear stims
    stims(c) = Bar0;c=c+1;
    stims(c) = Bar1;c=c+1;
    stims(c) = SkyFix1;c=c+1;
    stims(c) = SkyFix2;c=c+1;
    for I_st = 1:Nstep
        stims(c) = SkyTar(I_st);c=c+1;
    end
    stims(c) = SkyTarLast;c=c+1;
    for I_st = 1:Nstep
        stims(c) = Win(I_st);c=c+1;
    end
    stims(c) = WinLast;c=c+1;
    stims(c) = Rew;c=c+1;
    stims(c) = Rec;c=c+1;

%     disp(Win(1));disp(SkyTar(1))
%     disp(Win(2));disp(SkyTar(2))
%     disp(WinLast);disp(SkyTarLast)
    
    
    % Activate microcontroller for this trial
    TimeOut_ix = 1; % if time out occurs, this is the index
    micro_cmd(com, cmdNextTrial, ''); % New Trial
    
    % put trial in microcontroller
    TimeOut_ix = 2;
    nStim = size(stims,2);
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
            Spk = Pos(1);
            Rng = Pos(2);
            level = [stims(sel).level]/255;
            level = level(1);

            if Spk == 0
                A=0;E=0;
            else
                [A,E]=sky2azel(Rng,Spk);
            end
            set(Htar,'xdata',A,'ydata',E)

            if Spk == 0 && Rng == 1
                set(Htar,'marker','o','markeredgecolor','r','markerfacecolor','r','markersize',15,'linewidth',2)
            else
                set(Htar,'marker','o','markeredgecolor','g','markerfacecolor','g','markersize',15,'linewidth',2)
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
        MonkeyPlotRA16ChannelsFinal
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
        if strcmpi(deblank(stimNames(kind(idx),:)),'rew') && status(idx) ~= statError
            RewCount = RewCount +1;
        end
        if get(HuiDispStuff,'value')==1
            str = (sprintf('%2d %s[%2d,%2d]\t (%5d -> %5d = %5d) %3d',...
                idx,stimNames(kind(idx),:),stims(idx).pos(1),stims(idx).pos(2),Ton(idx),Toff(idx),Toff(idx)-Ton(idx),stims(idx).event));
            switch kind(idx)
                case {stimBar, stimSky, stimLas, stimFixWnd}
                    str = [str sprintf('[%s]',statNames(status(idx),:))];
            end
            disp(str)
            str = [sprintf('%2d %s',idx,stimNames(kind(idx),:)) repmat(' ',1,round(Ton(idx)/500)) repmat('#',1,round((Toff(idx)-Ton(idx))/500))];
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
    %% future use:
    %save('U:\Tom van Grootel\DATA_STUFF\frames.mat','Frames')
    % 		%% if time out occurs, abort
    % 		% place index
    % 		TimeOut_Errors(TimeOut_ix) = TimeOut_Errors(TimeOut_ix) + 1;
    % % 		CMD = sprintf('$%d',cmdAbort);
    % %
    % % 		% abort trial
    % % 		res2 = 0;
    % % 		while (res2(1) ~= -998)
    % % 			fprintf(com1,CMD);
    % % 			str = fscanf(com1);
    % % 			if ~isempty(str)
    % % 				res2 = str2num(str);
    % % 				disp(str)
    % % 				disp('- - - - -')
    % % 			end
    % % 		end
    % % 		% handle all time outs, can be 8
    % % 		str = '-998';
    % % 		while (length(str > 0))
    % % 	        str = micro_getValues( '', '');
    % % 		end
    % % 		lastwarn('');
    % %
    % % 		% put current trail back into list
    % % 		RemainTarList = [RemainTarList;CurTarList]
    % % 		disp(['Tar to go: ' num2str(size(RemainTarList,1))])
    %
    % 	fprintf('We are in catch mode\n')
    % 	lastwarn
    % 	fprintf('%.0f  ',TimeOut_Errors);
    % 	fprintf('\n')
    % 	lastwarn('');
    % 	lasterror('reset');
    %	end
    %	fprintf('%.0f  ',TimeOut_Errors);
    %	fprintf('\n')
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
