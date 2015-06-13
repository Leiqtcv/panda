function varargout = Monkey(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Monkey_OpeningFcn, ...
                   'gui_OutputFcn',  @Monkey_OutputFcn, ...cd
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
function Monkey_OpeningFcn(hObject, eventdata, handles, varargin)
    global tmpvalues tmpresults;
    data = guidata(hObject);
    tmpvalues  = zeros(1,10);
    tmpresults = zeros(1,10);
    %
    % TDT3, 1 rack: RP2.1 en PA.5
    %
    circuitRP2 = 'C:\Dick\Matlab\Monkey\include\ripple.rco';
    
    [data.zBus   err(1)] = ZBUS(1);              % number of racks
    [data.RP2_1  err(2)] = RP2(1,circuitRP2);   
    [data.PA5_1  err(3)] = PA5(1); 
    
    %
    % set attenuation
    %
    data.PA5_1.SetAtten(20);

    guidata(hObject, data);
% ====================================================================
function varargout = Monkey_OutputFcn(hObject, eventdata, handles) 
% ====================================================================
function execCommand(result)
    global tmpvalues tmpresults;
    for n = 1:tmpvalues(1)
        str = ['values(',int2str(n),')=',int2str(tmpvalues(n)),';'];
        evalin('base',str);
    end
    busy = evalin('base','busy');
    while busy == 1                 % wait previous command still busy
        busy = evalin('base','busy');
        pause(0);
    end
    evalin('base','cmd = 1.0');     % new command
%   evalin('base','cmd = 1.0;');    % weird, doesn't work with (;) !!!
    while busy == 0                 % wait until command is accepted
         busy = evalin('base','busy');
         pause(0);
    end
    evalin('base','cmd = 2.0');     % command accepted
    while busy == 1                 % wait command is finished
          busy = evalin('base','busy');
          pause(0);
    end
    evalin('base','cmd = 0.0');     % command finished

    if result == 1
          tmpresults(1) = evalin('base','results(1)');
          for n = 2:tmpresults(1)
            str = ['results(',int2str(n),')'];
            tmpresults(n) = evalin('base',str');
          end
    end
% ---------------------- E X P E R I M E N T -------------------------- %
%
% ripple parameters
% 1-	velocity   = velocity - modulation frequency
% 2-	modulation = modulation depth
% 3-	density    = density
% 4-	durStat    = duration of static part sound
% 5-	durDyn     = duration of dynamic part sound
% 6-	F0         = F0
% 7-	nTones     = number of tones
% 8-	nOct       = number of octaves (components = nTones*nOctaves
% 9-	PhiF0      = pahse F0 (radials)
%10-	statDyn    = 1-dynamic folloes static
%11-	freeze     = 1-keep component phases
%12-	rate       = 48828.125 Hz.
%
function pushbutton7_Callback(hObject, eventdata, handles)
    global tmpvalues tmpresults;
    data = guidata(hObject);
    number = str2num(get(data.edit7,'String'));
    useBar = get(data.checkbox1,'Value');
    preTime = [500 500];
    newTime = [500 500];
    hFile = fopen('C:\Dick\Matlab\Monkey.dat','w');
    fclose(hFile);
%     Max intensity werkt niet!!!!!
%     tmpvalues(1) = 3;
%     tmpvalues(2) = evalin('base','Globals.cmdMaxInt');
%     tmpvalues(3) = 0;     % max intensity
%     execCommand(1);
    for n=1:number
        [newTime pos] = getTrialInfo(useBar,preTime);
        evalin('base',['rippleParams(4) = ',num2str(newTime(1))]);
        evalin('base',['rippleParams(5) = ',num2str(newTime(2))]);
        evalin('base','rippleNew = 1');
        str = ['Trial = ',num2str(n),' of ',num2str(number)];
        set(data.edit8,'String',str);
        str = ['Taget = ',num2str(preTime(1)),' + ',num2str(preTime(2)),' mSec'];
        set(data.edit9,'String',str);
        str = ['Ring = ',num2str(pos(1)),', spoke = ',num2str(pos(2))];
        set(data.edit10,'String',str);
        preTime = newTime;
        tmpvalues(1) = 4;
        tmpvalues(2) = evalin('base','Globals.cmdNextTrial');
        tmpvalues(3) = 100;     % ITI mSec
        nStims = evalin('base','nStims');
        tmpvalues(4) = nStims;
        execCommand(1);
        %
        % load sound
        %
        data.RP2_1.SoftTrg(1);
        mm = evalin('base','rippleSound(1)');
        data.RP2_1.WriteTagV('WavData', 0, evalin('base',['rippleSound(2:',num2str(mm),')']));
        data.RP2_1.SetTagVal('WavCount',mm-2);
        %
        % save last trial
        %
        hFile = fopen('C:\Dick\Matlab\Monkey.dat','a');
        mm = evalin('base','nStims');
        kk = evalin('base','maxParam');
        tt = evalin('base','results(2)');
        fprintf(hFile,'%5d %0.2f %3d %3d\r\n',n, tt, mm, kk);
        for m=1:mm
            str = ['curTrial(',num2str(m),',:)'];
            fprintf(hFile,'%5d',evalin('base',str));
            fprintf(hFile,'\r\n');
        end
        fclose(hFile);
    end
% ---------------------- P I O - T E S T ------------------------------ %
function pushbutton5_Callback(hObject, eventdata, handles)
    global tmpvalues tmpresults;
    data = guidata(hObject);
    t0  = tic;
    sec =  str2double(get(data.edit6,'String'));
    if sec == 0
        sec = 10;
    end
    lp = sec;
    outputPIO    = 0;
    while lp > 0
        busy = 1;
        while busy > 0
            busy = evalin('base','busy');
            pause(0);
        end
%
        tmpvalues(1) = 2;
        tmpvalues(2) = evalin('base','Globals.cmdGetPIO');
        execCommand(1);
        val = round(tmpresults(3));
        bit = 1;
        if (bitand(val,bit) > 0)                    % bit 0
            set(data.radiobutton13,'value',1);
        else
            set(data.radiobutton13,'value',0);
        end
        bit = bitshift(bit,1);
        if (bitand(val,bit) > 0)                    % bit 1
            set(data.radiobutton12,'value',1);
        else
            set(data.radiobutton12,'value',0);
        end
        bit = bitshift(bit,1);
        if (bitand(val,bit) > 0)                    % bit 2
            set(data.radiobutton11,'value',1);
        else
            set(data.radiobutton11,'value',0);
        end
        bit = bitshift(bit,1);
        if (bitand(val,bit) > 0)                    % bit 3
            set(data.radiobutton10,'value',1);
        else
            set(data.radiobutton10,'value',0);
        end
        bit = bitshift(bit,1);
        if (bitand(val,bit) > 0)                    % bit 4
            set(data.radiobutton9,'value',1);
        else
            set(data.radiobutton9,'value',0);
        end
        bit = bitshift(bit,1);
        if (bitand(val,bit) > 0)                    % bit 5
            set(data.radiobutton8,'value',1);
        else
            set(data.radiobutton8,'value',0);
        end
        bit = bitshift(bit,1);
        if (bitand(val,bit) > 0)                    % bit 6
            set(data.radiobutton7,'value',1);
        else
            set(data.radiobutton7,'value',0);
        end
        bit = bitshift(bit,1);
        if (bitand(val,bit) > 0)                    % bit 7
            set(data.radiobutton6,'value',1);
        else
            set(data.radiobutton6,'value',0);
        end

        value = outputPIO; 
        if get(data.radiobutton21,'value') > 0      % bit 0
            value = bitor(value,1); 
        else
            value = bitand(value,bitxor(255,1));
        end
        if get(data.radiobutton20,'value') > 0      % bit 1
            value = bitor(value,2); 
        else
            value = bitand(value,bitxor(255,2));
        end
        if get(data.radiobutton19,'value') > 0      % bit 2
            value = bitor(value,4); 
        else
            value = bitand(value,bitxor(255,4));
        end
        if get(data.radiobutton18,'value') > 0      % bit 3
            value = bitor(value,8); 
        else
            value = bitand(value,bitxor(255,8));
        end
        if get(data.radiobutton17,'value') > 0      % bit 4
            value = bitor(value,16); 
        else
            value = bitand(value,bitxor(255,16));
        end
        if get(data.radiobutton16,'value') > 0      % bit 5
            value = bitor(value,32); 
        else
            value = bitand(value,bitxor(255,32));
        end
        if get(data.radiobutton15,'value') > 0      % bit 6
            value = bitor(value,64); 
        else
            value = bitand(value,bitxor(255,64));
        end
        if get(data.radiobutton14,'value') > 0      % bit 7
            value = bitor(value,128); 
        else
            value = bitand(value,bitxor(255,128));
        end
        outputPIO = bitand(value, 255);
        tmpvalues(1) = 3;
        tmpvalues(2) = evalin('base','Globals.cmdSetPIO');
        tmpvalues(3) = outputPIO;
        execCommand(1);
%
        lp = (sec-floor(toc(t0)));
        set(data.edit6,'String',num2str(lp));
        pause(0.01);
    end
    tmpvalues(1) = 3;
    tmpvalues(2) = evalin('base','Globals.cmdSetPIO');
    tmpvalues(3) = 0;
    execCommand(1);
    guidata(hObject, data);
% ---------------------- S K Y - T E S T ------------------------------ %
function radiobutton1_Callback(hObject, eventdata, handles)
    data = guidata(hObject);
    if get(data.radiobutton1,'Value') == 0
        set(data.radiobutton1,'Value',0);
        set(data.radiobutton2,'Value',1);
    else
        set(data.radiobutton1,'Value',1);
        set(data.radiobutton2,'Value',0);
    end
    guidata(hObject, data);
function radiobutton2_Callback(hObject, eventdata, handles)
    data = guidata(hObject);
    if get(data.radiobutton2,'Value') == 0
        set(data.radiobutton1,'Value',1);
        set(data.radiobutton2,'Value',0);
    else
        set(data.radiobutton1,'Value',0);
        set(data.radiobutton2,'Value',1);
    end
    guidata(hObject, data);
function pushbutton1_Callback(hObject, eventdata, handles)
    global tmpvalues tmpresults;
    data = guidata(hObject);
    busy = 1;
    while busy > 0
        busy = evalin('base','busy');
        pause(0);
    end
    tmpvalues(1) = 4;
    tmpvalues(2) = evalin('base','Globals.cmdTestLeds');
    tmpvalues(3) = get(data.radiobutton1,'Value');
    n = str2num(get(data.edit3,'String'));
    if size(n,1) == 0
        set(data.edit3,'String','500');
        n = 500;
    end
    tmpvalues(4) = n;
    guidata(hObject, data);
    execCommand(0);
% ---------------------- L E D - T E S T ------------------------------ %
function radiobutton3_Callback(hObject, eventdata, handles)
    data = guidata(hObject);
    if get(data.radiobutton3,'Value') == 0
        set(data.radiobutton3,'Value',0);
        set(data.radiobutton4,'Value',1);
    else
        set(data.radiobutton3,'Value',1);
        set(data.radiobutton4,'Value',0);
    end
    guidata(hObject, data);
function radiobutton4_Callback(hObject, eventdata, handles)
    data = guidata(hObject);
    if get(data.radiobutton4,'Value') == 0
        set(data.radiobutton3,'Value',1);
        set(data.radiobutton4,'Value',0);
    else
        set(data.radiobutton3,'Value',0);
        set(data.radiobutton4,'Value',1);
    end
    guidata(hObject, data);
function pushbutton3_Callback(hObject, eventdata, handles)
    global tmpvalues tmpresults;
    data = guidata(hObject);
    busy = 1;
    while busy > 0
        busy = evalin('base','busy');
        pause(0);
    end
    tmpvalues(1) = 5;
    tmpvalues(2) = evalin('base','Globals.cmdLedOff');
    tmpvalues(3) = str2num(get(data.edit4,'String'));    % ring
    tmpvalues(4) = str2num(get(data.edit5,'String'));    % spoke
    tmpvalues(5) = get(data.radiobutton3,'Value');       % color
    guidata(hObject, data);
    execCommand(0);
function pushbutton4_Callback(hObject, eventdata, handles)
    global tmpvalues tmpresults;
    data = guidata(hObject);
    busy = 1;
    while busy > 0
        busy = evalin('base','busy');
        pause(0);
    end
    tmpvalues(1) = 5;
    tmpvalues(2) = evalin('base','Globals.cmdLedOn');
    tmpvalues(3) = str2num(get(data.edit4,'String'));    % ring
    tmpvalues(4) = str2num(get(data.edit5,'String'));    % spoke
    tmpvalues(5) = get(data.radiobutton3,'Value');       % color
    guidata(hObject, data);
    execCommand(0);
% ------------------------- E X I T ----------------------------------- %
function pushbutton2_Callback(hObject, eventdata, handles)
    evalin('base','ready = 1');
    evalin('base','rippleNew = -1');
    pause(1);
    close all;
% --------------------------------------------------------------------- %
function pushbutton2_KeyPressFcn(hObject, eventdata, handles)
function edit3_Callback(hObject, eventdata, handles)
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit4_Callback(hObject, eventdata, handles)
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit5_Callback(hObject, eventdata, handles)
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function radiobutton6_Callback(hObject, eventdata, handles)
function radiobutton7_Callback(hObject, eventdata, handles)
function radiobutton8_Callback(hObject, eventdata, handles)
function radiobutton9_Callback(hObject, eventdata, handles)
function radiobutton10_Callback(hObject, eventdata, handles)
function radiobutton11_Callback(hObject, eventdata, handles)
function radiobutton12_Callback(hObject, eventdata, handles)
function radiobutton13_Callback(hObject, eventdata, handles)
function radiobutton14_Callback(hObject, eventdata, handles)
function radiobutton15_Callback(hObject, eventdata, handles)
function radiobutton16_Callback(hObject, eventdata, handles)
function radiobutton17_Callback(hObject, eventdata, handles)
function radiobutton18_Callback(hObject, eventdata, handles)
function radiobutton19_Callback(hObject, eventdata, handles)
function radiobutton20_Callback(hObject, eventdata, handles)
function radiobutton21_Callback(hObject, eventdata, handles)
function edit6_Callback(hObject, eventdata, handles)
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit7_Callback(hObject, eventdata, handles)
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit8_Callback(hObject, eventdata, handles)
function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit9_Callback(hObject, eventdata, handles)
function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function checkbox1_Callback(hObject, eventdata, handles)
function edit10_Callback(hObject, eventdata, handles)
function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --------------------------------------------------------------------- %
