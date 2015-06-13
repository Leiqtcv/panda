function com=skydemo
HumanInit
Hsky=figure;
set(gcf,'position',[360 500 230 120])
set(gcf,'menubar','none','numberTitle','off')
uicontrol('style','pushbutton','position',[10 10 100 100],'string','Start Sky Demo','Callback',{@startsky,Hsky,com})


function startsky(hObject, eventdata,H,com,OK)
micro_globals
figure(H)
hui = uicontrol('style','togglebutton','position',[120 10 100 100],'string','Stop Sky Demo');
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
