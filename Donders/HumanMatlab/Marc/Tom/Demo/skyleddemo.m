function com=skyleddemo
HumanInit
Hsky=figure;
set(gcf,'position',[300 100 230 120])
set(gcf,'menubar','none','numberTitle','off')
uicontrol('style','pushbutton','position',[10 10 100 50],'string','Start Sky Demo','Callback',{@startsky,Hsky,com})
uicontrol('style','pushbutton','position',[10 60 100 50],'string','All Sky','Callback',{@allsky,Hsky,com})

Hled=figure;
set(gcf,'position',[300 260 230 120])
set(gcf,'menubar','none','numberTitle','off')
uicontrol('style','pushbutton','position',[10 10 100 50],'string','Start Led Demo','Callback',{@startled,Hled,com})
uicontrol('style','pushbutton','position',[10 60 100 50],'string','All Led','Callback',{@allled,Hled,com})

Hskyled=figure;
set(gcf,'position',[300 420 230 120])
set(gcf,'menubar','none','numberTitle','off')
uicontrol('style','pushbutton','position',[10 10 100 50],'string','Start Sky&Led Demo','Callback',{@startskyled,Hskyled,com})
uicontrol('style','pushbutton','position',[10 60 100 50],'string','ALL Sky&Led','Callback',{@allskyled,Hskyled,com})

%%
function allsky(hObject, eventdata,H,com,OK)
micro_globals
figure(H)
hui = uicontrol('style','togglebutton','position',[120 10 100 100],'string','Stop');
OK = get(hui,'value') ~= get(hui,'max');
while OK == true
    Aspoke = 1:12;
    Aring =  1:7;
    for spoke = Aspoke
        for ring = Aring
            str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,1);
            micro_cmd(com,cmdStim,str);
        end
    end
    for spoke = Aspoke
        for ring = Aring
            str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,0,0);
            micro_cmd(com,cmdStim,str);
        end
    end
    
    OK = get(hui,'value') ~= get(hui,'max');
end
delete(hui)


%%
function startsky(hObject, eventdata,H,com,OK)
micro_globals
figure(H)
hui = uicontrol('style','togglebutton','position',[120 10 100 100],'string','Stop');
OK = get(hui,'value') ~= get(hui,'max');
while OK == true
    spoke = rand_num([1 12]);
    ring =  rand_num([1 7]);
    str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,1);
    micro_cmd(com,cmdStim,str);
    str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,0,0);
    micro_cmd(com,cmdStim,str);
    OK = get(hui,'value') ~= get(hui,'max');
end
delete(hui)

%%
function allled(hObject, eventdata,H,com,OK)
micro_globals
figure(H)
hui = uicontrol('style','togglebutton','position',[120 10 100 100],'string','Stop');
OK = get(hui,'value') ~= get(hui,'max');
while OK == true
    Aspeaker = [1:29 129:-1:101];
    for speaker = Aspeaker
        str = sprintf('%d;%d;%d;%d;%d',stimLed,0,speaker,255,1);
        micro_cmd(com,cmdStim,str);
    end
    for speaker = Aspeaker
        str = sprintf('%d;%d;%d;%d;%d',stimLed,0,speaker,0,0);
        micro_cmd(com,cmdStim,str);
    end
    OK = get(hui,'value') ~= get(hui,'max');
end
delete(hui)

%%
function startled(hObject, eventdata,H,com,OK)
micro_globals
figure(H)
hui = uicontrol('style','togglebutton','position',[120 10 100 100],'string','Stop');
OK = get(hui,'value') ~= get(hui,'max');
while OK == true
    speaker = rand_num([1 29]);
    str = sprintf('%d;%d;%d;%d;%d',stimLed,0,speaker,255,1);
    micro_cmd(com,cmdStim,str);
    str = sprintf('%d;%d;%d;%d;%d',stimLed,0,speaker,0,0);
    micro_cmd(com,cmdStim,str);
    speaker = rand_num([101 129]);
    str = sprintf('%d;%d;%d;%d;%d',stimLed,0,speaker,255,1);
    micro_cmd(com,cmdStim,str);
    str = sprintf('%d;%d;%d;%d;%d',stimLed,0,speaker,0,0);
    micro_cmd(com,cmdStim,str);
end
delete(hui)

%%
function allskyled(hObject, eventdata,H,com,OK)
micro_globals
figure(H)
hui = uicontrol('style','togglebutton','position',[120 10 100 100],'string','Stop');
OK = get(hui,'value') ~= get(hui,'max');
while OK == true
    Aspeaker = [1:29 129:-1:101];
    Aspoke = 1:12;
    Aring =  1:7;
    [gAspoke,gAring]=meshgrid(Aspoke,Aring);
    Nsky = numel(Aspoke)*numel(Aring);
    Nled = numel(Aspeaker);
    for Is = 1:Nsky
        Il = round(Nled/Nsky*Is);
        str = sprintf('%d;%d;%d;%d;%d',stimSky,gAspoke(Is),gAring(Is),255,1);
        micro_cmd(com,cmdStim,str);
        str = sprintf('%d;%d;%d;%d;%d',stimLed,0,Aspeaker(Il),255,1);
        micro_cmd(com,cmdStim,str);
    end
    for Is = 1:Nsky
        Il = round(Nled/Nsky*Is);
        str = sprintf('%d;%d;%d;%d;%d',stimSky,gAspoke(Is),gAring(Is),0,0);
        micro_cmd(com,cmdStim,str);
        str = sprintf('%d;%d;%d;%d;%d',stimLed,0,Aspeaker(Il),0,0);
        micro_cmd(com,cmdStim,str);
    end
    OK = get(hui,'value') ~= get(hui,'max');
end
delete(hui)

%%
function startskyled(hObject, eventdata,H,com,OK)
micro_globals
figure(H)
hui = uicontrol('style','togglebutton','position',[120 10 100 100],'string','Stop');
OK = get(hui,'value') ~= get(hui,'max');
while OK == true
    speaker = rand_num([1 29]);
    str = sprintf('%d;%d;%d;%d;%d',stimLed,0,speaker,255,1);
    micro_cmd(com,cmdStim,str);
    str = sprintf('%d;%d;%d;%d;%d',stimLed,0,speaker,0,0);
    micro_cmd(com,cmdStim,str);
    speaker = rand_num([101 129]);
    str = sprintf('%d;%d;%d;%d;%d',stimLed,0,speaker,255,1);
    micro_cmd(com,cmdStim,str);
    str = sprintf('%d;%d;%d;%d;%d',stimLed,0,speaker,0,0);
    micro_cmd(com,cmdStim,str);
    spoke = rand_num([1 12]);
    ring =  rand_num([1 7]);
    str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,1);
    micro_cmd(com,cmdStim,str);
    str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,0,0);
    micro_cmd(com,cmdStim,str);
    OK = get(hui,'value') ~= get(hui,'max');
    
end
delete(hui)
