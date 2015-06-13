close all;
clear all
HumanInit
figure;
OK=true;
uicontrol('style','pushbutton','position',[10 10 100 100],'string','Stop Testing','Callback','OK=false;OK')
set(gcf,'position',[360 500 120 120])
set(gcf,'menubar','none','numberTitle','off')

%% test leds
%%%%%%%%%%%%%%%%%%%%%%%%
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
%%
close(com)
close all
