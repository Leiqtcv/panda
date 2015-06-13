close all
clear all
fclose all;
HumanInit
%%
HeadNet=load('D:\HumanMatlab\Tom\NET\headcoil.net','-mat');
%GazeNet=load('D:\HumanMatlab\Tom\NET\gazecoil.net','-mat');
% [str msg] = micro_NNMod(com, 0, [1 2 3], GazeNet.AzNet);
% [str msg] = micro_NNMod(com, 1, [1 2 3], GazeNet.ElNet);
[str msg] = micro_NNMod(com, 2, [5 6 7], HeadNet.hnetH);
[str msg] = micro_NNMod(com, 3, [5 6 7], HeadNet.vnetH);

%%
Led1 = STIMREC;
Led1.stim  = stimSky;
Led1.pos   = [3 3];
Led1.level = 100;
Led1.start = [0 0];
Led1.stop  = [1 0];
Led1.event = 999;

Led2 = STIMREC;
Led2.stim  = stimSky;
Led2.pos   = [3 2];
Led2.level = 100;
Led2.start = [1 0];
Led2.stop  = [1 1000];
Led2.event = 666;

Speed =  STIMREC;
Speed.stim = stimSpeed;
Speed.mode = 14;
Speed.pos = [60 0];
Speed.start = [0 500];
Speed.stop = [0 10000];
Speed.level = -15;
Speed.event = 1;

Rec = STIMREC;
Rec.stim  = stimRec;
Rec.start = [0 500];
Rec.stop = [666 0]; % stop recording @ reward, NOTE: 'cAcqDur' must be longer
Rec.bitNo = 4; %RA16 start

%%
ax = nan(4,1);
HFmain = figure;
ax(1) = subplot(221);hold on;title('head velocity')
ax(2) = subplot(223);hold on;title('head position')
ax(3) = subplot(222);hold on;title('Distance from target')
ax(4) = subplot(224);axis square;title('fit')
set(gcf,'position',[63   502   560   420])
linkaxes(ax([1 2 3]),'x')
cm = hsv(100);
I = 0;
for I_l=linspace(-27,1,100);
    I=I+1;
    TrialIx = 1;
    c=1;
    Speed.level = I_l;
    stims(c) = Led1;c=c+1;
    stims(c) = Led2;c=c+1;
    stims(c) = Speed;c=c+1;
    stims(c) = Rec;c=c+1;
    nStim = size(stims,2);
    
    micro_cmd(com, cmdNextTrial, '');
    micro_stims(com, nStim, stims);
    micro_cmd(com, cmdStartTrial, '');
    
    Nsamp = round(10000*1.01725);
    RA16_1.SetTagVal('Samples',Nsamp);
    
    %%
    figure(HFmain);
    subplot(221); xlim([0 10])
    tic;
    res = micro_getValues(com, cmdStateTrial, '');
    while res ~= statDoneTrial
        c=toc;
        %   disp(num2str(c));
        
        res = micro_getValues(com, cmdStateTrial, '');
        
        [str] = micro_cmd(com, cmdSpeed, '');
        disp(str)
        vec = str2num(lower(str));
        vec(isinf(vec) & vec < 0) = -1;
        vec(isinf(vec) & vec > 0) = 1;
        
        if ~isempty(vec)
            Slope = vec(1);
            Offset = vec(2);
            Time = vec(3:7);
            %Time = linspace(0,1,5);
            Angle = vec(8:12);
            dTime = diff(minmax(Time));%vec(13);
            
            
            subplot(221);
            plot(c,Slope,'.')
            subplot(222);
            plot(c+Time.*0.001,Angle,'.')
            
            P=polyfit(Time,Angle,1);
            disp(num2str(P))
            
            subplot(224);
            plot(Time,Angle,'.b')
            lsline
            
            subplot(221);
            plot(c, P(1),'xb')
            
            disp(['deg/s: ' num2str(1000/dTime *P(1))])
        end
        
        
        
        
            [str msg] = micro_NNSim(com,-1);%fprintf('-1: %s\n',str);
            vec = str2num(str);
            if ~isempty(vec)
                subplot(223);
                plot(c,vec(2:end),'.')
            end
        
    end
    %% result
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
    disp('========================================');
    disp(sprintf('Trial = %4d, ITI = %4d, Span = %d, Nstim = %d',TrialIx,ITI,span,num));
    disp('');
    
    % other rows
    TimeOut_ix = 9;
    Ton = nan(num,1);
    Toff = nan(num,1);
    status = nan(num,1);
    kind = nan(num,1);
    disp(sprintf(' stim   locat \t   start    stop  duration event'))
    for idx=1:num
        [res1] = result(idx+1,:);
        kind(idx)   = res1(1);
        status(idx) = res1(2);
        Ton(idx)    = res1(3);
        Toff(idx)   = res1(4);
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
    %%
    Cur_smp = RA16_1.GetTagVal('NPtsRead');
    data5 = RA16_1.ReadTagVEX('Data_5', 0, Cur_smp, 'F32', 'F64', 1);
    data6 = RA16_1.ReadTagVEX('Data_6', 0, Cur_smp, 'F32', 'F64', 1);
    data7 = RA16_1.ReadTagVEX('Data_7', 0, Cur_smp, 'F32', 'F64', 1);
    data = data5*1618;
    Az = sim(HeadNet.AzNet,[data5;data6;data7].*161.8);
    El = sim(HeadNet.ElNet,[data5;data6;data7].*161.8);
    vel = diff(hypot(Az,El))*1017.25;
    TrigOn = Toff(3)-Ton(3);
    TrigOn = TrigOn*1.01714;
    
    %     figure
    %     subplot(221)
    %     plot(data)
    %     subplot(223)
    %     plot(diff(data)*1017.25)
    %     subplot(222)
    %     plot(Az,El)
    %     axis equal
    %     subplot(224); hold on
    %     plot(vel)
    %     subplot(224)
    %     plot([TrigOn TrigOn],[-100 100],'-r')
    %%
    cla(ax(1))
    cla(ax(2))
    cla(ax(3))
    cla(ax(4))
    if exist('HFv','var')~=1
        HFv = figure; hold on
        set(gcf,'position',[695   510   560   420])
        subplot(211);hold on
        subplot(212);hold on
    else
        figure(HFv)
    end
    Smp = round(TrigOn);
    try
        subplot(211)
        P = mean(vel([-5:5]+Smp));
        h=plot(Speed.level,P,'.');
        subplot(212)
        h=plot(Speed.level,Az(Smp),'.');
        
    catch
        %skip
    end
end
%%
close(com)
