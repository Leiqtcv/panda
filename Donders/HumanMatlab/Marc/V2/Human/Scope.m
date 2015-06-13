close all
clear all
fclose all;
HumanInit
Timeoffset = now;
%%
ChanColLabel		= [
    1 1 0;
    0 0 1;
    1 0 0;
    .8 .8 .8;
    .5 .5 .5;
    1 1 1;
    0 .7 0;
    .8 .8 .8
    ];
Npts = 100;
%%
H=figure;
Hstop   = uicontrol('position',[0 0 40 20],'style','togglebutton','string','stop','Callback', 'RUN = 0;');
Hpause  = uicontrol('position',[40 0 40 20],'style','togglebutton','string','pause','Callback', 'PAUSE = PAUSE * -1;');
HchanGr = uibuttongroup('Position',[0 0.1 .1 .9]);
Hch = nan(8,1);
for I_c = 1:8
    Hch(I_c) = uicontrol('position',[0 10+30*(I_c-1) 50 30],...
        'Style','checkbox',...
        'value',1,...
        'String',['ch ' num2str(I_c)],...
        'backgroundcolor',ChanColLabel(I_c,:),...
        'parent',HchanGr);
end
rect=get(0,'ScreenSize');
rect(2) = rect(2) + 28;
rect(4) = rect(4) - 28 - 40;
set(H,'position',rect,...
    'NumberTitle','off',...
    'name','-- Scope --     Blue = RA16     Red = Micro Controller')
%%
% make figures
AX = nan(8,1);
hRA16 = nan(8,1);
hMCRO = nan(8,1);
hT = nan(8,1);
iSP = [1 3 5 7 2 4 6 8];
for I_c = 1:8
    AX(I_c)     = subplot(4,2,iSP(I_c)); hold on;box on;grid on
    hRA16(I_c)  = plot(1,1,'.b');
    hMCRO(I_c)  = plot(1,1,'xr','markersize',4);
    hT(I_c)     = title(['CH' num2str(I_c) ': 0 V']);
    set(hT(I_c),'BackGroundColor',ChanColLabel(I_c,:))
end
subplot(428)
xlabel('Time [s]')
ylabel([{'Sig [V]'};{'b - RA16 r - MicroCtrl'};])
squeezesubplots(AX,.2)

% Initialize
RUN = 1;
PAUSE = 1;
Ipt=0;
RA16_datavec=[];
RA16_timevec=[];
MCRO_datavec=[];
MCRO_timevec=[];
while RUN==1
    Ipt=Ipt+1;
    cChs = zeros(8,1);
    for I_c = 1:8
        if get(Hch(I_c),'value')==1
            cChs(I_c)=1;
        end
    end
    cCh = find(cChs);
    
    str             = micro_cmd(com,cmdADC,'');vec = str2num(str);%fprintf('%s\n',str);
    MCRO_time       = vec(1);
    MCRO_timevec    = [MCRO_timevec,MCRO_time];
    MCRO_data       = nan(8,1);
    MCRO_data(cCh)  = vec(cCh+1)*10;
    MCRO_datavec    = [MCRO_datavec,MCRO_data];
    
    RA16_time       = (now-Timeoffset)*60000;
    RA16_timevec    = [RA16_timevec,RA16_time];
    RA16_data       = nan(8,1);
    for I_c = cCh'
        cRA16_data      = RA16_1.GetTagVal(['CH_' num2str(I_c)]);
        cRA16_data      = cRA16_data*1618;
        RA16_data(I_c,:)  = cRA16_data;
    end
    RA16_datavec    = [RA16_datavec,RA16_data];
    
    if Ipt > Npts
        RA16_datavec=RA16_datavec(:,2:end);
        RA16_timevec=RA16_timevec(:,2:end);
        MCRO_datavec=MCRO_datavec(:,2:end);
        MCRO_timevec=MCRO_timevec(:,2:end);
    end
    
    for I_c = cCh'
    set(hRA16(I_c),...
        'xdata',RA16_timevec,...
        'ydata',RA16_datavec(I_c,:))
    set(hMCRO(I_c),...
        'xdata',RA16_timevec,...
        'ydata',MCRO_datavec(I_c,:))
    set(hT(I_c), ...
        'string',['CH' num2str(I_c) ': ' sprintf('%+6.4f',RA16_data(I_c)) ' V'])
    set(get(hRA16(I_c),'parent'), ...
        'ylim',max(abs(minmax(RA16_datavec(I_c,:))))*[-1 1]+[-0.5 0.5],...
        'xlim',minmax(RA16_timevec)+[-1e-6 1e-6])
    end
    drawnow
    
    while PAUSE==-1
        drawnow
    end
end
%%
close(com)
close(findobj('tag','BitMonitor'))
close(findobj('tag','ActXWin'))
rect = rect+[+200 +200 -400 -400];
set(H,'position',rect);
