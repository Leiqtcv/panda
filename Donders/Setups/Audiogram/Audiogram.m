            %----------------------------------%
            %      A U D I O G R A M           %
            %      -----------------           %        
            % 10-11-2010   V 1.0   Dick Heeren %
            %----------------------------------%
%            
% In AudioCFG worden de volgende parameters gezet:
% De testfrequenties
% freq = [1000 500 250 125 2000 3000 4000 6000 8000 16000];
% duration = 2000;      duur van de toon
% startAtten = 60;      de trial 1000 Hz, start met deze verzwakking
% minAtten = 10;        minmale vezwakking, maximale geluidsterkte
% numHL = 2;            hoog/laag sequenties
% rndITI = 500;         random deel van de ITI (1000 + )
%
% path "C:\dick\Audiogram" moet bij matlab worden toegevoegd (addpath) 
% path "C:\dick\Audiogram\Matlab" wordt in deze functie toegevoegd
%
% swich == 1, knop is ingedrukt, toon gehoord
% verzwakking nieuwe toon is verzwakking vorige toon -30 dB
% behalve bij 1000 Hz, deze is altijd 60
%
% to do
% tekst op knop start/pause/idle/ready is niet duidelijk
%
function varargout = Audiogram(varargin)
% Last Modified by GUIDE v2.5 17-Nov-2010 14:24:37

eval('path(path,''C:\matlab\Audiogram\Matlab'')');

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Audiogram_OpeningFcn, ...
                   'gui_OutputFcn',  @Audiogram_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
function Audiogram_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSD>
    data = guidata(hObject);
    data.output = hObject;
    
    set(data.edit_date,'String',date);
    set(data.push_start,'Enable','off');
    set(data.push_start,'String','Idle');

    data.clock_time = 0;
    data.clock_step = 0.10;

    guidata(hObject, data);
function varargout = Audiogram_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
    varargout{1} = handles.output;
function push_start_Callback(hObject, eventdata, handles) 
    Audiogram_run(hObject);
function plots_init(hObject)
    data = guidata(hObject);

    data.Atten_Axis = axis(data.plot_Attenuation);
    data.Atten_Xas  = 'Trial number';
    data.Atten_Yas  = 'Attenuation (dB)';
    xlabel(data.plot_Attenuation,data.Atten_Xas);
    ylabel(data.plot_Attenuation,data.Atten_Yas);

    data.Audio_Axis = axis(data.plot_Audiogram);
    data.Audio_Xas  = 'Frequency [Hz]';
    data.Audio_Yas  = 'Detection Threshold (dB)';
    xlabel(data.plot_Audiogram,data.Audio_Xas);
    ylabel(data.plot_Audiogram,data.Audio_Yas);

    guidata(hObject, data);
function updatePlot_atten(handles)
    data = guidata(handles);
    
    i = data.plot_Attenuation_pnts;
    plot(data.plot_Attenuation,data.plot_Attenuation_x(1:i),data.plot_Attenuation_y(1:i));
    xlabel(data.plot_Attenuation,data.Atten_Xas);
    ylabel(data.plot_Attenuation,data.Atten_Yas);
    i = 10;
    while (i < data.tone_trial) 
        i = i + 10;
    end
    data.Atten_Axis = [0 i 0 120];
    xlim(data.plot_Attenuation,[data.Atten_Axis(1),data.Atten_Axis(2)]);
    ylim(data.plot_Attenuation,[data.Atten_Axis(3),data.Atten_Axis(4)]);
    set(data.plot_Attenuation,'XGrid','on');
    set(data.plot_Attenuation,'YGrid','on');
function updatePlot_audio(handles)
    data = guidata(handles);
    
    plot(data.plot_Audiogram,data.frequencies,data.plot_Audio_y,'or');
    xlabel(data.plot_Audiogram,data.Audio_Xas);
    ylabel(data.plot_Audiogram,data.Audio_Yas);
    xlim(data.plot_Audiogram,[data.Audio_Axis(1),data.Audio_Axis(2)]);
    ylim(data.plot_Audiogram,[data.Audio_Axis(3),data.Audio_Axis(4)]);
    set(data.plot_Audiogram,'XScale','log');
    set(data.plot_Audiogram,'XGrid','on');
    set(data.plot_Audiogram,'YGrid','on');
function Audiogram_init(hObject)
    data = guidata(hObject);

    set(data.push_init,'Enable','off');
    
    data.cum = 0;
    data.cfg_freq = [1000 500 250 125 2000 3000 4000 6000 8000 12000 16000];
    data.cfg_duration   = 2000;
    data.cfg_startAtten = 60;
    data.cfg_minAtten   = 10;
    data.cfg_numHL      = 3;
    data.cfg_rndITI     = 500;
    filename = get(data.edit_CFG,'String');
    if (exist(filename,'file'))
        load(filename,'config');
        data.cfg_freq       = config.freq;
        data.cfg_duration   = config.duration;
        data.cfg_startAtten = config.startAtten;
        data.cfg_minAtten   = config.minAtten;
        data.cfg_numHL      = config.numHL;
        data.cfg_rndITI     = config.rndITI;
        set(data.edit_CFG,'BackgroundColor','white');
        set(data.edit_CFG,'ForegroundColor','black');
    else
        set(data.edit_CFG,'BackgroundColor','red');
        set(data.edit_CFG,'ForegroundColor','white');
    end
    disp('Initialize .............');
    addPath=strcat('addpath(''',get(data.edit_mapMatlab,'String'),''')');
    evalin('base',addPath);
    circuitRP2 = strcat(get(data.edit_mapRCO,'String'),'\Rp2a.rco');

    disp('Initialize TDT .........');
%---Active X
    [zBus   err(1)] = ZBUS(1); %#ok<ASGLU> % number of racks
    [RP2_1  err(2)] = RP2(1,circuitRP2);
    [PA5_1  err(3)] = PA5(1); 
    data.RP2_1 = RP2_1;
    data.PA5_1 = PA5_1;
    data.tone_switch   = 0;
    data.tone_trial    = 1;
    data.tone_amp      = 10;
    data.tone_freq     = 0;         % index
    data.tone_atten    = data.cfg_minAtten;        
    data.tone_HL       = 0; 
    data.prestep       = -1;
    data.tone_duration = data.cfg_duration;
    data.tone_react    = 0;
    data.GoOn          = true;
    data.status        = 0;
%---Errors Load-Run
    error = sum(err);
    if (error ~= 0)
        str = sprintf('%2d',err(:));
        str = sprintf('Error: ZBus RP2(1) PA5(1) = %s',str);
        disp(str);
        disp(strcat('Map Matlab  = ',get(data.edit_mapMatlab,'String'))); 
        disp(strcat('RP2 circuit = ',circuitRP2)); 
        set(data.edit_info,'String','ERROR');
        set(data.push_start,'Enable','on');
        set(data.push_start,'String','Stop');
        guidata(hObject, data);
        return;
    else
        RP2_1.SoftTrg(1);
        RP2_1.SoftTrg(2);
        pause(0.01);
        RP2_1.SetTagVal('Amp',data.tone_amp);
    end

    data.frequencies = data.cfg_freq;

    disp('Initialize Plots .......');
    guidata(hObject, data);
    plots_init(hObject);

    data = guidata(hObject);
    set(data.push_init,'Enable','on');
    set(data.push_init,'String','Initialize');
    set(data.push_start,'String','Run');
    set(data.push_start,'Enable','on');
    set(data.edit_freq, 'String','Freq  =>');
    set(data.edit_atten,'String','Atten =>');
    set(data.edit_trial,'String','Trial =>');
    set(data.edit_react,'String','React =>');
    disp('Idle ...................');
    guidata(hObject, data);
function Audiogram_run(hObject)
    data = guidata(hObject);
    set(data.push_init,'Enable','off');
    switch get(data.push_start,'String')
        case ('Pause')
            disp('Pause ..................');
            set(data.push_start,'String','Run');
            set(data.push_start,'Enable','on');
        case ('Run')
            disp('Running ................');
            set(data.push_start,'String','Pause');
            set(data.push_start,'Enable','on');
    end
    guidata(hObject, data);
function push_init_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
    Audiogram_init(hObject);

    data = guidata(hObject);

    xlabel(data.plot_Attenuation,data.Atten_Xas);
    ylabel(data.plot_Attenuation,data.Atten_Yas);
    xlim(data.plot_Attenuation,[data.Atten_Axis(1),data.Atten_Axis(2)]);
    ylim(data.plot_Attenuation,[data.Atten_Axis(3),data.Atten_Axis(4)]);
    set(data.plot_Attenuation,'XGrid','on');
    set(data.plot_Attenuation,'YGrid','on');
     
    xlabel(data.plot_Audiogram,data.Audio_Xas);
    ylabel(data.plot_Audiogram,data.Audio_Yas);
    xlim(data.plot_Audiogram,[data.Audio_Axis(1),data.Audio_Axis(2)]);
    ylim(data.plot_Audiogram,[data.Audio_Axis(3),data.Audio_Axis(4)]);
    set(data.plot_Audiogram,'XScale','log');
    set(data.plot_Audiogram,'XGrid','on');
    set(data.plot_Audiogram,'YGrid','on');
    data.plot_Audio_y = data.frequencies;
    for i=1:size(data.frequencies,2)
        data.plot_Audio_y(i) = 0;
    end
    data.tmr = timer('TimerFcn',{@TmrFcn,hObject},'BusyMode','Queue',...
                     'ExecutionMode','FixedRate','Period',data.clock_step);

    guidata(hObject, data);

    start(data.tmr);
function rad_switch_Callback(hObject, eventdata, handles)
    data  = guidata(hObject);
    
    guidata(hObject,data);
function str = ClockTime(handles)
    data = guidata(handles);
    time = data.clock_time;
    
    h = fix(time/3600);
    m = fix((time-3600*h)/60);
    s = fix((time-3600*h-60*m));
    str=sprintf('Time  => %d:%d.%d',h,m,s);
function TmrFcn(src,event,handles)
    data = guidata(handles);
    
    data.clock_time = data.clock_time + data.clock_step;
    set(data.edit_info,'String',ClockTime(handles));
    data.tone_switch = data.RP2_1.GetTagVal('Switch');
    set(data.rad_switch,'Value',data.tone_switch);
    if (data.GoOn)
        switch (data.status)
            case 0
                data.tone_freq = data.tone_freq + 1;
                disp(['Next freq  ' num2str(data.frequencies(data.tone_freq)) ' Hz.......']);
                str = sprintf('Freq  => %d Hz',...
                              data.frequencies(data.tone_freq));
                set(data.edit_freq,'String',str);
                if (data.frequencies(data.tone_freq) == 1000)
                    data.tone_atten = data.cfg_startAtten;
                else
                    if (data.tone_atten ~= 10)
                       data.tone_atten = data.tone_atten - 30;
                    end
                end
                data.tone_step  = 10;
                data.tone_HL    =  0;
                data.numMinAtten = 0;
                data.numMaxAtten = 0;
                data.tone_trial =  0;
                data.status     =  1;
                data.plot_Attenuation_x(1) =  0;
                data.plot_Attenuation_y(1) = data.tone_atten;
                data.plot_Attenuation_pnts =  1;
            case 1
                if strcmp(get(data.push_start,'String'),'Pause')
                    data.tone_trial = data.tone_trial + 1;
                    str = sprintf('Trial => %d',data.tone_trial);
                    set(data.edit_trial,'String',str);
                    str = sprintf('Atten => %d dB',data.tone_atten);
                    set(data.edit_atten,'String',str);
                    data.PA5_1.SetAtten(data.tone_atten);
                    data.RP2_1.SetTagVal('Freq',...
                    data.frequencies(data.tone_freq));
                    data.RP2_1.SetTagVal('Duration',data.tone_duration);
                    data.RP2_1.SoftTrg(1);
                    data.status = 2; 
                end
            case 2
                react = data.RP2_1.GetTagVal('React');
                str = sprintf('React => %d',react);
                set(data.edit_react','String',str);
                if (data.tone_switch == 1)
                    if (data.prestep == 1)
                        data.tone_HL = 0;
                    else
                        if (data.tone_step < 10)
                            data.tone_HL = data.tone_HL + 1;
                        end
                    end
                    switch data.tone_step
                        case 10
                            data.tone_step = 5;
%                         case 5
%                             data.tone_step = 2;
                    end
                    data.prestep = 1;
                    data.status = 5;
                end
                if (react > data.tone_duration)
                    if (data.prestep == -1)
                        data.tone_HL = 0;
                    end
                    data.prestep = -1;
                    data.status = 3;
                end
            case 3
                n = data.plot_Attenuation_pnts+1;
                data.plot_Attenuation_x(n)   = data.tone_trial;
                data.plot_Attenuation_x(n+1) = data.tone_trial;
                data.plot_Attenuation_y(n) = data.plot_Attenuation_y(n-1);
                if (data.tone_atten > data.cfg_minAtten)
                    data.tone_atten = data.tone_atten - data.tone_step;
                else
                    data.numMinAtten = data.numMinAtten + 1;
                end
                data.plot_Attenuation_y(n+1) = data.tone_atten;
                data.plot_Attenuation_pnts = n + 1;
                data.numMaxAtten = 0;
                guidata(handles, data);
                updatePlot_atten(handles);
                data.RP2_1.SoftTrg(2);
                if (data.numMinAtten < 4)
                        data.status = 4;
                else
                    data.status = 6;
                 end
            case 4
                if (data.tone_switch == 0)
                    data.RP2_1.SoftTrg(2);
                    ITI = (1000 + rand()*data.cfg_rndITI)/1000;
                    pause(ITI);
                    data.status = 1;
                end
            case 5
                n = data.plot_Attenuation_pnts+1;
                data.plot_Attenuation_x(n)   = data.tone_trial;
                data.plot_Attenuation_x(n+1) = data.tone_trial;
                data.plot_Attenuation_y(n) = data.plot_Attenuation_y(n-1);
                if (data.tone_atten < 120)
                    data.tone_atten = data.tone_atten + data.tone_step;
                else
                    data.numMaxAtten = data.numMaxAtten + 1;
                end
                data.plot_Attenuation_y(n+1) = data.tone_atten;
                data.plot_Attenuation_pnts = n + 1;
                data.numMinAtten = 0;
                guidata(handles, data);
                updatePlot_atten(handles);
                data.RP2_1.SoftTrg(2);
                ITI = (500 + rand()*data.cfg_rndITI)/1000;
                pause(ITI);
                if (data.tone_HL == data.cfg_numHL)
                    data.status = 6;
                else if (data.numMaxAtten < 4)
                          data.status = 1;
                     else
                          data.status = 6;
                     end
                end
            case 6
                data.plot_Audio_y(data.tone_freq) = data.tone_atten;
                guidata(handles, data);
                updatePlot_audio(handles);
                data.status = 0;
                data.cum = data.cum  + data.tone_trial;
                if (data.tone_freq == size(data.frequencies,2)) 
                    data.GoOn = false;
                    set(data.push_start,'String','Ready');
                    % save data
                    Result.date = get(data.edit_date,'String');
                    Result.name = get(data.edit_name,'String');
                    Result.LR   = get(data.edit_LR,'String');
                    Result.rco  = get(data.edit_mapRCO,'String');
                    Result.cfg  = get(data.edit_CFG,'String');
                    Result.data = get(data.edit_data,'String');
                    Result.freq = data.frequencies;
                    Result.plt  = data.plot_Audio_y;
                    Result.cum  = data.cum;
                	save(get(data.edit_data,'String'),'Result');
                end
        end
    end
    guidata(handles, data);
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    data = guidata(hObject);
    try
        stop(data.tmr);
        data.RP2_1.SoftTrg(2);
	catch exception
		rethrow(exception)
    end
    delete(hObject);
function push_exit_Callback(hObject, eventdata, handles)
    data = guidata(hObject);
    try
        stop(data.tmr);
        data.RP2_1.SoftTrg(2);
	catch exception
		rethrow(exception)
    end
    close('all');
function push_print_Callback(hObject, eventdata, handles)
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'InvertHardcopy','off');
    print;
function push_next_Callback(hObject, eventdata, handles)
    data = guidata(hObject);
    data.status    = 0;
    data.tone_freq = 0;
    data.cum       = 0;
    data.GoOn      = true;
    set(data.push_start,'String','Run');
    guidata(hObject, data);

function edit_freq_Callback(hObject, eventdata, handles)
function edit_atten_Callback(hObject, eventdata, handles)
function edit_trial_Callback(hObject, eventdata, handles)
function edit_info_Callback(hObject, eventdata, handles)
function edit_mapRCO_Callback(hObject, eventdata, handles)
function edit_mapMatlab_Callback(hObject, eventdata, handles)
function edit_react_Callback(hObject, eventdata, handles)
function edit_data_Callback(hObject, eventdata, handles)
function edit_name_Callback(hObject, eventdata, handles)
function edit_date_Callback(hObject, eventdata, handles)
function edit_CFG_Callback(hObject, eventdata, handles)
function edit_LR_Callback(hObject, eventdata, handles)
function edit_freq_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function edit_atten_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function edit_trial_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function edit_info_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ... 
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function edit_mapRCO_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ... 
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function edit_mapMatlab_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function edit_data_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function edit_react_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function edit_name_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function edit_date_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function edit_CFG_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function edit_LR_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
