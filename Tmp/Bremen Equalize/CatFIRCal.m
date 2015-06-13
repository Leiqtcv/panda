function CatFIRCal
% CatFIRCal -- Get the FIR coefficients for the free-field speakers
%   in the cat lab.

FIROrder= 1024;
NGolPts= 1024;
NRep= 1;
LoCut= 200;
HiCut= 25000;   % until march 26, 2010, these values were 500 and 30000
    % HiCut of 25000 gives 10 dB down at 40 kHz
FIRFile= 'c:\calibration\CatFIR';

DirectIncidence= 0; 

OldDir= pwd;
cd c:\Calibration;
eval('SpeakerTable');
cd (OldDir);

if DirectIncidence,
    SpeakerDirex= [2000 4000 5000 7000 20000 40000; 0 0 0 0 0 0];    % user for direct incidence of sound to mic
    MicDistance= 8; % if direct, assume we're at the far distance
else
    SpeakerDirex= [2000 4000 5000 7000 20000 40000; 1 1 2 2 10 23]; % 90 degree incidence
    MicDistance= 4;
end

% set up the ZBus

figure(100)
set(gcf,'position',[1 1 1 1])
ZBus = actxcontrol('ZBUS.x',[1 1 .01 .01]);
success = ZBus.ConnectZBUS('GB');
if ~success
    error('Failed to init ZBus');
end

% set up the RZ6 on the gigabit interface

RZ6= actxcontrol('RPco.X');
if ~success
   	error('Failed to init RZ6');
end

success = RZ6.ConnectRZ6('GB',1);
if ~success
   	error('Failed to connect RZ6');
end

% set up the MUX 
MUX= actxcontrol('RPco.X',[1 1 .01 .01]);            
if ~MUX.ConnectRP2('GB',1);        
    error('Failed to init RP2');
end
MUX.LoadCOF('k:\open\TDTPatch\Multiplexer\MUXSet.rcx');
MUX.Run;
MUXClear(MUX);
pause(.05);

DAC1FIR= [];
DAC2FIR= [];
DAC1Gain= [];
DAC2Gain= [];
DAC1STD= [];
DAC2STD= [];
DAC1SpecRange= [];
DAC2SpecRange= [];

% Do it

figure(2);  % for plotting the spectra and impulses

for DACNum= 1:2,
    if DACNum==1,
        if isfield(Cn,'DAC1SpkrTable'),
            SpkrVec= Cn.DAC1SpkrTable(:,1);
        else
            continue
        end
    else
        if isfield(Cn,'DAC2SpkrTable'),
            SpkrVec= Cn.DAC2SpkrTable(1:end-1,1);   
            % don't test last speaker number on DAC2, which is the null speaker
        else
            continue
        end
    end
    NSpkr= length(SpkrVec);

    for iSpkr= 1:NSpkr,

        ThisSpkr= SpkrVec(iSpkr);
        MUXClear(MUX);
        if DACNum==1 & ThisSpkr<=16,
            MUXSet(MUX,1,ThisSpkr);
        elseif DACNum==1 & ThisSpkr>16,
            MUXSet(MUX,2,ThisSpkr-16);
        else
            MUXSet(MUX,3,ThisSpkr); % use MUX device 3 for DAC2
        end
        pause(.05); % wait for MUX to settle
        disp(['Speaker: ',num2str(ThisSpkr)]);
        SpecSTD= 10;
        while SpecSTD>3,
            [FIRBuff, NoiseGain, Impulse, InitialCSpec, CSpec, SpecSTD, SpecRange]= ...
                RZ6CatGolay(RZ6,'doplot',1,'locut',LoCut,'hicut',HiCut,...
                'NGolPts',NGolPts,'NRep',NRep,'FIROrder',FIROrder,'DACChan',DACNum,...
                'SpeakerDirex',SpeakerDirex, 'MicDistance',MicDistance);
            if SpecSTD>3,   % if response really bad, try again
                disp('!!!!!!!!!!!!!!!!!!!!!!!!! Try again !!!!!!!!!!!!!!!!!!!!!!!!!!!')
            end
        end
        MUXClear(MUX);
        if DACNum==1,
            DAC1FIR(:,iSpkr)= FIRBuff;
            DAC1Gain(iSpkr)= NoiseGain;
            DAC1STD= [DAC1STD SpecSTD];
            DAC1SpecRange= [DAC1SpecRange SpecRange];
        else,
            DAC2FIR(:,iSpkr)= FIRBuff;
            DAC2Gain(iSpkr)= NoiseGain;
            DAC2STD= [DAC2STD SpecSTD];
            DAC2SpecRange= [DAC2SpecRange SpecRange];
        end      
    end
    
end

% summary plot

[~, LocSort1Idx]= sort(Cn.DAC1SpkrTable(:,2));

figure
DAC1Length= length(DAC1STD);
subplot(1,6,1)
barh(Cn.DAC1SpkrTable(LocSort1Idx,2),DAC1STD(LocSort1Idx));
set(gca,'xlim',[0 3],'ylim',[-180 180],'ytick',Cn.DAC1SpkrTable(LocSort1Idx,2),'yticklabel',Cn.DAC1SpkrTable(LocSort1Idx,2));
xlabel('STD')

subplot(1,6,2)
barh(Cn.DAC1SpkrTable(LocSort1Idx,2),DAC1Gain(LocSort1Idx), 'facecolor', 'r');
set(gca,'xlim',[0 .1],'ylim',[-180 180],'ytick',[]);
xlabel('Gain');

subplot(1,6,3)
barh(Cn.DAC1SpkrTable(LocSort1Idx,2),DAC1SpecRange(LocSort1Idx), 'facecolor', 'g');
set(gca,'xlim',[0 30],'ylim',[-180 180],'ytick',[]);
xlabel('SpecRange');

if isfield(Cn,'Cn.DAC2SpkrTable'),
    [~, LocSort2Idx]= sort(Cn.DAC2SpkrTable(:,2));
    subplot(1,6,4)
    barh(Cn.DAC2SpkrTable(LocSort2Idx,2),DAC2STD(LocSort2Idx));
    set(gca,'xlim',[0 3],'ylim',[-180 180],'ytick',Cn.DAC2SpkrTable(LocSort2Idx,2),'yticklabel',Cn.DAC2SpkrTable(LocSort2Idx,2));
    xlabel('STD')

    subplot(1,6,5)
    barh(Cn.DAC2SpkrTable(LocSort2Idx,2), DAC2Gain(LocSort2Idx), 'facecolor', 'r');
    set(gca,'xlim',[0 .1],'ylim',[-180 180],'ytick',[]);
    xlabel('Gain');

    subplot(1,6,6)
    barh(Cn.DAC2SpkrTable(LocSort2Idx,2),DAC2SpecRange(LocSort2Idx), 'facecolor', 'g');
    set(gca,'xlim',[0 30],'ylim',[-180 180],'ytick',[]);
    xlabel('SpecRange');
end

disp('########################')
disp(['Mean STD: ',num2str(mean(DAC1STD))])
disp('########################')

% save the data
save (FIRFile,'DAC1FIR', 'DAC2FIR', 'DAC1Gain', 'DAC2Gain');
