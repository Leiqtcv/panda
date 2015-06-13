close all
clear all
fclose all;
HumanInit
Timeoffset = now;
%%
H=figure;
Hstop   = uicontrol('position',[0 0 40 20],'style','togglebutton','string','stop','Callback', 'RUN = 0;');
Hpause  = uicontrol('position',[40 0 40 20],'style','togglebutton','string','pause','Callback', 'PAUSE = PAUSE * -1;');
HchanGr = uibuttongroup('Position',[0 0.1 .1 .9]);
Hch = nan(8,1);
for I_c = 1:8
    Hch(I_c) = uicontrol('position',[0 10+30*(I_c-1) 50 30],'Style','Radio','String',['ch ' num2str(I_c)],'parent',HchanGr);
end
%%
% make figures
subplot(221); hold on;box on
hRA16   = plot(1,1,'.b');
hMCRO_2 = plot(1,1,'xr','markersize',4);
hT1     = title([{'b: RA16 | r: MicroCtrl'};{['RA16 Sig: 0 V']}]);

subplot(223); hold on;box on
hMCRO   = plot(1,1,'.r');
hRA16_2 = plot(1,1,'xb','markersize',4);
hT3     = title([{'b: RA16 | r: MicroCtrl'};{'MicroCtrl Sig: 0 '}]);

subplot(222); hold on;box on
hRA16MCRO   = plotyy(1,.001,1,.002);
hT2         = title([{'b: RA16 | g: MicroCtrl'};{['RA16 Sig: 0 V | MicroCtrl Sig: 0 ']}]);

subplot(224);hold on; box on; axis square
hReg        = plot([0 1],[0 2],'.');
htfit       = text(1,2,num2str(3));
hRegline    = plot([-1 2],[-1 3],'-');
hT4         = title('Gain: [] Bias: []');
xlabel('MicroCtrl Sig [ ]')
ylabel('RA16 Sig [V]')

% Initialize
RUN = 1;
PAUSE = 1;
c=0;
RA16_datavec=[];
RA16_timevec=[];
MCRO_datavec=[];
MCRO_timevec=[];
while RUN==1
    % 	subplot(221);cla
    % 	subplot(224);cla
    c=c+1;
    cChs = zeros(8,1);
    for I_c = 1:8
        if get(Hch(I_c),'value')==1
            cChs(I_c)=1;
        end
    end
    cCh = find(cChs);
    
    str             = micro_cmd(com,cmdADC,'');vec = str2num(str);fprintf('%s\n',str);
    MCRO_time       = vec(1);
    MCRO_timevec    = [MCRO_timevec;MCRO_time];
    MCRO_data       = vec(cCh+1)*10;
    MCRO_datavec    = [MCRO_datavec,MCRO_data];
    
    RA16_time       = now-Timeoffset;
    RA16_timevec    = [RA16_timevec;RA16_time];
    RA16_data       = RA16_1.GetTagVal(['CH_' num2str(cCh)]);
    RA16_data       = RA16_data*1618;
    RA16_datavec    = [RA16_datavec,RA16_data];
    
    if c > 200
        RA16_datavec=RA16_datavec(2:end);
        RA16_timevec=RA16_timevec(2:end);
        MCRO_datavec=MCRO_datavec(2:end);
        MCRO_timevec=MCRO_timevec(2:end);
    end
    
    
    set(hRA16,...
        'xdata',RA16_timevec,...
        'ydata',RA16_datavec)
    set(hMCRO_2,...
        'xdata',RA16_timevec,...
        'ydata',MCRO_datavec)
    set(hT1, ...
        'string',[{'b: RA16 (| r: MicroCtrl)'};{['RA16 Sig: ' sprintf('%+6.4f',RA16_data) ' V']}])
    set(get(hRA16,'parent'), ...
        'xlim',minmax(RA16_timevec')+[-1e-6 1e-6])
    drawnow
    
    set(get(hRA16MCRO(1),'children'),...
        'xdata',RA16_timevec,...
        'ydata',RA16_datavec)
    set(get(hRA16MCRO(2),'children'),...
        'xdata',RA16_timevec,...
        'ydata',MCRO_datavec)
    set(hT2, ...
        'string',[{'b: RA16 | g: MicroCtrl'};{['RA16 Sig: ' sprintf('%+6.4f',RA16_data) ' V | MicroCtrl Sig: ' sprintf('%+6.4f',MCRO_data) ' ']}])
    set(hRA16MCRO(1),...
        'xlim',minmax(RA16_timevec')+[-1e-6 1e-6],...
        'ylim',minmax(RA16_datavec)+[-.01 .01])
    set(hRA16MCRO(2),...
        'xlim',minmax(RA16_timevec')+[-1e-6 1e-6],...
        'ylim',minmax(MCRO_datavec)+[-.01 .01])
    drawnow
    
    set(hMCRO,...
        'xdata',MCRO_timevec,...
        'ydata',MCRO_datavec)
    set(hRA16_2,...
        'xdata',MCRO_timevec,...
        'ydata',RA16_datavec)
   set(hT3, ...
        'string',[{'(b: RA16 |) r: MicroCtrl'};{['MicroCtrl Sig: ' sprintf('%+6.4f',MCRO_data) ' ']}])
    set(get(hMCRO,'parent'), ...
        'xlim',minmax(MCRO_timevec')+[-1 1])
    drawnow
    
    set(hReg,...
        'xdata',MCRO_datavec, ...
        'ydata',RA16_datavec)
    p = polyfit(RA16_datavec,MCRO_datavec,1);
    set(htfit,...
        'position',[MCRO_datavec(end),RA16_datavec(end),0],...
        'string',num2str(p))
    X=minmax(MCRO_datavec);
    Y=feval(@(x) (x-p(2))/p(1),X);
    set(hRegline,...
        'xdata',X,...
        'ydata',Y)
    set(hT4, ...
        'string',['Gain: [' sprintf('%+6.4f',p(1)) '] Bais: [' sprintf('%+6.4f',p(2)) ']'])
    drawnow
    
    %	subplot(221)
    % 	p = [481  580];
    % 	X=MCRO_datavec;
    % 	Y=feval(@(x) (x-p(2))/p(1),X);
    % 	plot(RA16_timevec,Y,'.b')
    %	drawnow
    while PAUSE==-1
        drawnow
    end
end
%%
close(com)