%==================================================================
%                               Plot RA16 channels
%==================================================================
%
% This function plots the raw signals that are acquired by TDT system
% It plots quasi online data, and the real data that is stored in the
% buffer.
%

%% Init

% basic props
Nchan				= 8;
Tlimit				= 5;						% --- size history (sec)
StartTime			= now*100000;
ChanColLabel		= [
    0.2 0.2 0.2;
    1 0 0;
    1 1 0;
    .8 .8 .8;
    0 1 0;
    0 0 1;
    1 1 1;
    .8 .8 .8
    ];
LogHeadRange		= [1 1 1 1 1 1 1 1].*10;		% --- Range of loggerhead (Volt)
CalRange			= 90;						% --- Calibration range (degrees)
Fsamp				= 1017.25;					% --- Acquisition frequency (Hz)

% load NNetwork
if exist('GazeCalNetFile','var')==1 && exist('GazeNet','var')~=1
    if exist(GazeCalNetFile,'file') ==2
        GazeNet = load(GazeCalNetFile,'-mat');
        [d,GazeNetName]=fileparts(GazeCalNetFile);
    else
        GazeNetName = 'Not Exist';
    end
end
if exist('HeadCalNetFile','var')==1 && exist('HeadNet','var')~=1
    if exist(HeadCalNetFile,'file') ==2
        HeadNet = load(HeadCalNetFile,'-mat');
        [d,HeadNetName]=fileparts(HeadCalNetFile);
    else
        HeadNetName = 'Not Exist';
    end
end
%% Open window and set Tags
HF = findobj('Tag','RA16Scope');
if isempty(HF)
    % main figure
    HF = figure;
    set(HF,'Tag','RA16Scope')
    set(HF,'UserData',['Time: ' datestr(StartTime/100000)])
    set(HF,...
        'Name','RA16Scope',...
        'NumberTitle','off',...
        'Color','k')
    
    
    % yt axes
    Haxis_yt        = nan(Nchan,1);
    HdataRawRA16_yt	= nan(Nchan,1);
    HdataBufRA16_yt	= nan(Nchan,1);
    HdataRawMicr_yt	= nan(Nchan,1);
    for I_ch = 1:Nchan
        Haxis_yt(I_ch) = subplot(Nchan,4,I_ch*4-3); hold on
        AxRect          = get(Haxis_yt(I_ch),'position');
        AxRect(1)       = AxRect(1)-.05;
        AxRect(3)       = AxRect(3)+.1;
        set(Haxis_yt(I_ch), ...
            'Tag',['YTAxesChan' num2str(I_ch)],...
            'xgrid','on',...
            'ygrid','on',...
            'xcolor',[.5 .5 .5],...
            'ycolor',[.5 .5 .5],...
            'Color',[.2 .2 .2],...
            'FontName','Helvetica',...
            'Fontsize',15,...
            'FontWeight','bold',...
            'Position',AxRect,...
            'ylim',[-1 1].*LogHeadRange(I_ch)*1.5,...
            'box','on')
        if I_ch ~= Nchan;
            set(Haxis_yt(I_ch),'XTickLabel',[]);
        end
        if I_ch == 1;
            title('YT plot','color','w')
        end
        if I_ch == Nchan;
            xlabel('Time [s]')
        end
        ylabel([{''};{['Ch ' num2str(I_ch)]}],'color',ChanColLabel(I_ch,:))
        
        % create empty handles for data
        HdataRawRA16_yt(I_ch) = plot(0,0);
        HdataBufRA16_yt(I_ch) = plot([0 1],[0 1]);
        HdataRawMicr_yt(I_ch) = plot(0,0);
        set(HdataRawRA16_yt(I_ch), ...
            'Tag',['YTDataChan' num2str(I_ch)],...
            'color','k', ....
            'Marker','s',...
            'linewidth',2)
        set(HdataBufRA16_yt(I_ch),...
            'Tag',['YTInStoreChan' num2str(I_ch)],...
            'color','w', ....
            'linewidth',1, ...
            'UserData','Time: 0')
        set(HdataRawMicr_yt(I_ch),...
            'Tag',['YTMicroChan' num2str(I_ch)],...
            'color','r', ....
            'Marker','o',...
            'linewidth',2)
    end
    squeezesubplots(Haxis_yt,.1)
    linkaxes(Haxis_yt,'x')
    
    
    % xy axes
    Haxis_xy = subplot(122); hold on;box on;axis square
    AxRect      = get(Haxis_xy,'position');
    AxRect(1)   = AxRect(1)-.15;
    AxRect(2)   = AxRect(2)-.135;
    AxRect(3)   = AxRect(3)+.20;
    AxRect(4)   = AxRect(4)+.2;
    set(Haxis_xy, ...
        'Tag','XYAxes', ...
        'xgrid','on',...
        'ygrid','on',...
        'zgrid','on',...
        'xcolor',[.5 .5 .5],...
        'ycolor',[.5 .5 .5],...
        'zcolor',[.5 .5 .5],...
        'Color',[.2 .2 .2],...
        'FontName','Helvetica',...
        'Fontsize',15,...
        'FontWeight','bold',...
        'box','on',...
        'Position',AxRect,...
        'xlim',[-1 1]*CalRange, ...
        'ylim',[-1 1]*CalRange)
    title(Haxis_xy,...
        [{'XY plot'};...
        {['\fontsize{8}Head CalFile: [' regexptranslate('escape',regexprep(HeadNetName,'_','\\_')) ']']};...
        {['\fontsize{8}Gaze CalFile: [' regexptranslate('escape',regexprep(GazeNetName,'_','\\_')) ']']}],...
        'color','w')
    xlabel('Azimuth')
    ylabel('Elevation')
    
    
    % create empty handles for data
    HdataRawRA16_xyGaze         = plot([0 1],[0 1],'parent',Haxis_xy);
    HdataRawRA16_xyHead         = plot([0 1],[0 1],'parent',Haxis_xy);
    HdataBufRA16_xyGaze         = plot([0 1],[0 1],'parent',Haxis_xy);
    HdataBufRA16_xyHead         = plot([0 1],[0 1],'parent',Haxis_xy);
    HdataCalAzEl_xyGaze         = plot(0,0,'parent',Haxis_xy);
    HdataCalAzEl_xyHead         = plot(0,0,'parent',Haxis_xy);
    HdataCalAzEl_xyGazeMicro    = plot(0,0,'parent',Haxis_xy);
    HdataCalAzEl_xyHeadMicro    = plot(0,0,'parent',Haxis_xy);
    set(HdataRawRA16_xyGaze, ...
        'Tag','XYGazeRaw',...
        'linewidth',1,...
        'color',[.4 .4 .4]);
    set(HdataRawRA16_xyHead,...
        'Tag','XYHeadRaw',...
        'linewidth',1,...
        'color',[.4 .4 0]);
    set(HdataBufRA16_xyGaze,...
        'Tag','XYGazeInStore',...
        'linewidth',2,...
        'color','w');
    set(HdataBufRA16_xyHead,...
        'Tag','XYHeadInStore',...
        'linewidth',2,...
        'color','y');
    set(HdataCalAzEl_xyGaze,...
        'Tag','XYGazeCur',...
        'marker','o',...
        'markersize',5,...
        'markeredgecolor','w');
    set(HdataCalAzEl_xyHead,...
        'Tag','XYHeadCur',...
        'marker','o',...
        'markersize',5,...
        'markeredgecolor','y');
    set(HdataCalAzEl_xyGazeMicro,...
        'Tag','XYGazeMicro',...
        'marker','s',...
        'markersize',3,...
        'markeredgecolor','w');
    set(HdataCalAzEl_xyHeadMicro,...
        'Tag','XYHeadMicro',...
        'marker','s',...
        'markersize',3,...
        'markeredgecolor','y');
    
    
    % plot ledsky on XY
    LEDSKY_RING     = [0,2,5,9,14,20,27,35,45];
    LEDSKY_SPOKE    = [60 30 0 330 300 : -30 : 90];
    SPOKES          = repmat(LEDSKY_SPOKE',1,numel(LEDSKY_RING));
    RINGS           = repmat(LEDSKY_RING,numel(LEDSKY_SPOKE),1);
    AZ              = RINGS.*cosd(SPOKES);
    EL              = RINGS.*sind(SPOKES);
    plot(AZ,EL,'sk','markeredgecolor','k','markerfacecolor',[0 1 0].*.5,'markersize',2,'parent',Haxis_xy);
    
    
    
    %% ui controls
    %Hui_rec             = uicontrol('style','togglebutton','units','normalized','position',[.90 0 .1 .05],'string','Rec','tag','RecButton');
    Hui_browseHeadCal   = uicontrol('style','togglebutton','units','normalized','position',[.70 0 .1 .05],'string','Set HeadCal','tag','HeadCalButton');
    Hui_browseGazeCal   = uicontrol('style','togglebutton','units','normalized','position',[.60 0 .1 .05],'string','Set GazeCal','tag','GazeCalButton');
    
else
    % reset Timer
    StartTime = get(HF,'UserData');
    StartTime = datenum(StartTime(7:end));
    StartTime = StartTime * 100000;
    
    
    % look for handles
    Haxis_yt        = nan(Nchan,1);
    HdataRawRA16_yt = nan(Nchan,1);
    HdataBufRA16_yt = nan(Nchan,1);
    HdataRawMicr_yt = nan(Nchan,1);
    for I_ch = 1:Nchan
        Haxis_yt(I_ch)          = findobj('Tag',['YTAxesChan' num2str(I_ch)]);
        HdataRawRA16_yt(I_ch)   = findobj('Tag',['YTDataChan' num2str(I_ch)]);
        HdataBufRA16_yt(I_ch)   = findobj('Tag',['YTInStoreChan' num2str(I_ch)]);
        HdataRawMicr_yt(I_ch)   = findobj('Tag',['YTMicroChan' num2str(I_ch)]);
    end
    Haxis_xy                    = findobj('Tag','XYAxes');
    HdataRawRA16_xyGaze         = findobj('Tag','XYGazeRaw');
    HdataRawRA16_xyHead         = findobj('Tag','XYHeadRaw');
    HdataBufRA16_xyGaze         = findobj('Tag','XYGazeInStore');
    HdataBufRA16_xyHead         = findobj('Tag','XYHeadInStore');
    HdataCalAzEl_xyGaze         = findobj('Tag','XYGazeCur');
    HdataCalAzEl_xyHead			= findobj('Tag','XYHeadCur');
    HdataCalAzEl_xyGazeMicro	= findobj('Tag','XYGazeMicro');
    HdataCalAzEl_xyHeadMicro	= findobj('Tag','XYHeadMicro');
    %Hui_rec                     = findobj('Tag','RecButton');
    Hui_browseHeadCal           = findobj('Tag','HeadCalButton');
    Hui_browseGazeCal           = findobj('Tag','GazeCalButton');
end



%% Read Data from TDT
CurTime = now*100000-StartTime;
if exist('RA16_1','var')==1
    RA16Active = RA16_1.GetTagVal('Active');
    Cur_smp = RA16_1.GetTagVal('NPtsRead');
else
    RA16Active = 0;
    Cur_smp = 0;
end
CUR_pt      = nan(Nchan,1);			% coarse online data
CUR_tr      = nan(Nchan,Cur_smp);	% real trace from TDT ram
CUR_micro   = nan(Nchan,1);         % ADconverted Micro controller data


% get current channel values and stored data
for I_ch = 1:Nchan
    CUR_chpt = ['CH_' num2str(I_ch)];
    CUR_chtr = ['Data_' num2str(I_ch)];
    if exist('RA16_1','var')==1
        cCUR_pt = RA16_1.GetTagVal(CUR_chpt);
    else
        cCUR_pt = NaN;
    end
    CUR_pt(I_ch) = tdt2volt(cCUR_pt,LogHeadRange(I_ch));
    if get(findobj('Tag',['SaveCh' num2str(I_ch)]),'value') == get(findobj('Tag',['SaveCh' num2str(I_ch)]),'max')
        if exist('RA16_1','var')==1
            CUR_tr(I_ch,:) = tdt2volt(RA16_1.ReadTagVEX(CUR_chtr, 0, Cur_smp, 'F32', 'F64', 1),LogHeadRange(I_ch));
        else
            CUR_tr(I_ch,:) = NaN;
        end
    else
        CUR_tr(I_ch,:) = NaN;
    end
end
%% Calibrate
HumanPlotRA16Channels_calgaze
HumanPlotRA16Channels_calhead

%% plot YT

% reset Timer (TimeOffset used for buffer plot)
if RA16Active == 1
    set(HdataBufRA16_yt(I_ch),'UserData',['Time: ' num2str(CurTime)])
end
TimeOffset = get(HdataBufRA16_yt(I_ch),'UserData');
TimeOffset = str2double(TimeOffset(6:end));


for I_ch = 1:Nchan
    % update data vectors
    T       = get(HdataRawRA16_yt(I_ch),'xdata');
    Y       = get(HdataRawRA16_yt(I_ch),'ydata');
    T       = [T,CurTime];
    Y       = [Y,CUR_pt(I_ch)];
    selT    = T>CurTime-Tlimit;
    Y       = Y(selT);
    T       = T(selT);
    
    % for raw freq
    if numel(T)>=2
        Dtime = diff(T);
    else
        Dtime = 1;
    end
    
    % update plot handles
    set(HdataRawRA16_yt(I_ch),'xdata',T,'ydata',Y);
    set(HdataRawMicr_yt(I_ch),'xdata',mean(T),'ydata',CUR_micro(I_ch));
    
    % clipping
    if any(abs(Y)>LogHeadRange(I_ch)+0.35);
        set(Haxis_yt(I_ch),'Color','r')
    elseif any(abs(Y)>LogHeadRange(I_ch));
        set(Haxis_yt(I_ch),'Color',[.6 0 0 ])
    else
        set(Haxis_yt(I_ch),'Color',[.2 .2 .2])
    end
    
    % update stored data
    T = [1:Cur_smp]./Fsamp;
    T = T-max(T)+TimeOffset;
    Y = CUR_tr(I_ch,:);
    
    % update plot handle
    if all(T<CurTime-Tlimit)
        set(HdataBufRA16_yt(I_ch),'xdata',nan,'ydata',nan); % to speed up loop
    else
        set(HdataBufRA16_yt(I_ch),'xdata',T,'ydata',Y);
    end
    
    % reset axis
    set(Haxis_yt(I_ch),'xlim',[CurTime-Tlimit CurTime]);
    
end

% xlabel
CurSec = rem(CurTime,60);
CurMin = round((CurTime - CurSec)/60);
clockstr = ['Time [s] + ' num2str(CurMin) ' min. @ ' sprintf('%4.2f - %4.2f ',1/min(Dtime),1/max(Dtime)) 'Hz'];
set(get(Haxis_yt(Nchan),'xLabel'), ...
    'string',clockstr)
Ttcklbl = num2str([get(Haxis_yt(Nchan),'xtick')-CurMin*60]');
set(Haxis_yt(Nchan),...
    'xtickLabel',Ttcklbl)

%% plot XY

% update raw data
A = get(HdataRawRA16_xyGaze,'xdata');
E = get(HdataRawRA16_xyGaze,'ydata');
A = [A,GazeCalAz_pt];
E = [E,GazeCalEl_pt];
set(HdataRawRA16_xyGaze,'xdata',A,'ydata',E);
set(HdataCalAzEl_xyGaze,'xdata',A(end),'ydata',E(end));
A = get(HdataRawRA16_xyHead,'xdata');
E = get(HdataRawRA16_xyHead,'ydata');
if numel(A)>20
    A = [A(2:end),HeadCalAz_pt];
    E = [E(2:end),HeadCalEl_pt];
else
    A = [A,HeadCalAz_pt];
    E = [E,HeadCalEl_pt];
end
set(HdataRawRA16_xyHead,'xdata',A,'ydata',E);
set(HdataCalAzEl_xyHead,'xdata',A(end),'ydata',E(end));

% update simulated data from Microcontroller
A = GazeCalAz_micro;
E = GazeCalEl_micro;
set(HdataCalAzEl_xyGazeMicro,'xdata',A,'ydata',E);
A = HeadCalAz_micro;
E = HeadCalEl_micro;
set(HdataCalAzEl_xyHeadMicro,'xdata',A,'ydata',E);

% update stored data
A=GazeCalAz_tr;
E=GazeCalEl_tr;
set(HdataBufRA16_xyGaze,'xdata',A,'ydata',E);
A=HeadCalAz_tr;
E=HeadCalEl_tr;
set(HdataBufRA16_xyHead,'xdata',A,'ydata',E);

% % set axis limits
% CurEcc = nan(2,2);
% A = get(HdataRawRA16_xyGaze,'xdata');
% E = get(HdataRawRA16_xyGaze,'ydata');
% CurEcc(1,:) = [A(end),E(end)];
% A = get(HdataRawRA16_xyHead,'xdata');
% E = get(HdataRawRA16_xyHead,'ydata');
% CurEcc(2,:) = [A(end),E(end)];
% AL = nan(1,2);
% AL(1) = min([-CalRange min(CurEcc(:,1))]);
% AL(2) = max([CalRange max(CurEcc(:,1))]);
% AL(1) = -CalRange;
% AL(2) = CalRange;
% EL = nan(1,2);
% EL(1) = min([-CalRange min(CurEcc(:,2))]);
% EL(2) = max([CalRange max(CurEcc(:,2))]);
% EL(1) = -CalRange;
% EL(2) = CalRange;
% set(Haxis_xy,'xlim',AL,'ylim',EL)
%% record
% Nframes = 33;
% if get(Hui_rec,'value')==get(Hui_rec,'max')
%     CurF = getframe(get(Haxis_xy,'parent'));
%     if ~exist('RA16Frames','var')==1
%         RA16Frames = repmat(CurF,1,Nframes);
%     else
%         RA16Frames = [RA16Frames(2:end),CurF];
%     end
% end
%% Browse for head or gaze calfile
FLAG_upload = false;
if get(Hui_browseHeadCal,'value')==get(Hui_browseHeadCal,'max')
    HeadCalNetFile = uigetfullfile([fileparts(HeadCalNetFile) filesep '*.net'],'HEAD net file');
    set(Hui_browseHeadCal,'value',get(Hui_browseHeadCal,'min'))
    if ~isstr(HeadCalNetFile)
        HeadCalNetFile = 'Not Exist';
    end
    [d,HeadNetName]=fileparts(HeadCalNetFile);
    h = get(Haxis_xy,'title');
    set(h,'string',...
        [{'XY plot'};...
        {['\fontsize{8}Head CalFile: [' regexptranslate('escape',regexprep(HeadNetName,'_','\\_')) ']']};...
        {['\fontsize{8}Gaze CalFile: [' regexptranslate('escape',regexprep(GazeNetName,'_','\\_')) ']']}])
    clear HeadNet
    FLAG_upload = true;
elseif get(Hui_browseGazeCal,'value')==get(Hui_browseGazeCal,'max')
    GazeCalNetFile = uigetfullfile([fileparts(GazeCalNetFile) filesep '*.net'],'GAZE net file');
    set(Hui_browseGazeCal,'value',get(Hui_browseGazeCal,'min'))
    if ~isstr(GazeCalNetFile)
        GazeCalNetFile = 'Not Exist';
    end
    [d,GazeNetName]=fileparts(GazeCalNetFile);
    h = get(Haxis_xy,'title');
    set(h,'string',...
        [{'XY plot'};...
        {['\fontsize{8}Head CalFile: [' regexptranslate('escape',regexprep(HeadNetName,'_','\\_')) ']']};...
        {['\fontsize{8}Gaze CalFile: [' regexptranslate('escape',regexprep(GazeNetName,'_','\\_')) ']']}])
    clear GazeNet
    FLAG_upload = true;
end

if FLAG_upload
    HumanInit_uploadNN
    FLAG_upload = false;
end