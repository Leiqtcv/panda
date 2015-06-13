function [FIRBuff, NoiseGain, Impulse, CSpec1, CSpec2, SpecSTD, SpecRange]= RZ6CatGolay(RZ6,varargin)
% RZ6CatGolay -- Get a system response for one speaker using Golay codes
%   on an RZ6. Return FIR coefficients to flatten the response, the
%   Noise Gain, the impulse response of the corrected system, 
%   the complex system response of the original (uncorrected) system, and the 
%   response of the corrected system. Optionally display response.
%
%   Caller must connect the RZ6 and send the control name as the first arg.
%
%   Optional paired input arguements:
%       DoPlot: Plot raw and corrected impulse responses and spectra
%          [default 0]
%       SpeakerDirex: 2-row matrix of corner frequencies and dB
%           gain values to correct for speaker [default all 0 dB correction]
%       FIROrder:   Order of the FIR coefficients to be generated -- 
%           must match the TDT patch [default 500]
%       NGolPts: Number of points in each Golay code [default 4096]
%       NRep: Number of times to repeat the Golay codes [default 1]
%       HiCut: Upper cutoff frequency in Hz
%       LoCut: Lower cutoff frequency in Hz
%       DACChan: 1 or 2 (default 1)
%       MicDistance: distance from speakers to the mic in ft (default= 4)
%
%   USAGE: [FIRBuff, NoiseGain, Impulse, InitialCSpec, CSpec, SpecSTD]= RZ6CatGolay(RZ6)

DACChan= 1;
DoPlot= 0;
SpeakerDirex= [2000 4000 5000 7000 20000 40000; 1 1 2 2 10 23];
FIROrder= 850;
NGolPts= 1024;
NRep= 1;
HiCut= 35000;
LoCut= 500;
MicDistance= 4;

% parse the input arguements

for iarg= 1:2:nargin-1,   % assume an even number of varargs

    switch lower(varargin{iarg}),
        
    case 'dacchan',
        DACChan= varargin{iarg+1};
        
    case 'doplot',
        DoPlot= varargin{iarg+1};
        
    case 'speakerdirex',    % speaker directionality scalars
        SpeakerDirex= varargin{iarg+1};

    case 'firorder',
        FIROrder= varargin{iarg+1};
               
    case 'ngolpts',
        NGolPts= varargin{iarg+1};

    case 'nrep',
        NRep= varargin{iarg+1};

    case 'hicut',
        HiCut= varargin{iarg+1};
        
    case 'locut',
        LoCut= varargin{iarg+1};

    case 'micdistance',
        MicDistance= varargin{iarg+1};
        
    case 'backcompat',
        BackCompat= varargin{iarg+1};

    case ''
        
    otherwise,  % not a switch
                
        disp(sprintf('%s is not a valid switch!',varargin{iarg}));
        return

    end % end of switch

end % end of for iarg

VInMax= 1;
VRef= 3.6; % half inch mic gives 3.6 V p-2-p on the 20 dB setting on the preamp at Theory

RZ6.ClearCOF;
success = RZ6.LoadCOF('k:\open\tdtpatch\calibration\RZ6CatGolay.rcx');
if ~success
    error('Failed to load RZ6CatGolayCal COF');
end

RZ6.Run;

Fs= RZ6.GetSFreq;
Nyq= Fs/2;
DACTick= 1/Fs;  % in seconds
FreqAxis= Fs*(0:NGolPts-1)/NGolPts; % DC is at 1; Nyquist is at NGolPts/2 + 1;
PassBand= find(FreqAxis>=LoCut*1.1 & FreqAxis<=HiCut/1.1);  % get flat portion of passband
RecordDelayPts= FIROrder + ceil((MicDistance/1000)/DACTick); % wait for signal to propagate
%   through the FIR filter plus 4 ms for sound to propagate to mic

% Get the speaker directionality vector

mycorner= [0 SpeakerDirex(1,:) Fs-fliplr(SpeakerDirex(1,:)) Fs];
mydb= [0 SpeakerDirex(2,:) fliplr(SpeakerDirex(2,:)) 0];
SpeakerDrxVec= interp1(mycorner,mydb,FreqAxis)';
SpeakerDrxVec= 10.^(SpeakerDrxVec/20);

% Get the Golay codes, place them end to end, and duplicate to get NRep+1 reps

[AGol,BGol]= Golay(NGolPts);
GolBuff= [AGol(:);BGol(:)];
GolBuff= GolBuff*ones(1,NRep+1);
GolBuff= GolBuff(:);
GolBuff= GolBuff';    % make it a row vector
GolBuff(end)= 0;    % leave the DAC at 0
GolBuff(1)= 0;
GolBuffNPts= length(GolBuff);

RZ6.SetTagVal('BuffSize', GolBuffNPts);
RZ6.SetTagVal('ADCChan', 1);
if DACChan==1
    RZ6.SetTagVal('DAC1Enable', 1);
    RZ6.SetTagVal('DAC2Enable', 0);
else
    RZ6.SetTagVal('DAC1Enable', 0);
    RZ6.SetTagVal('DAC2Enable', 1);
end

RZ6.WriteTagVEX('GolBuff', 0, 'F32', GolBuff);

DACGain= 1; 
ADCMax= VInMax+1;   % this forces first loop

% initialize the FIR coefs
FIRAllPass= zeros(1,FIROrder+1);
FIRAllPass(FIROrder/2 + 1)= 1; %all-pass filter


RZ6.WriteTagV('FIRCoef', 0, FIRAllPass);  % download the FIR coefficients

% disable the biquad filters
RZ6.SetTagVal('BandPass',0);
RZ6.SetTagVal('AllPass',1);

% probe the uncorrected system

while ADCMax > VInMax || ADCMax<0.25*VInMax,  % loop until we get an ADCMax in range

    RZ6.SetTagVal('DACGain', DACGain);

    RZ6.SoftTrg(1);
    pause(0.05);
    while RZ6.GetTagVal('Active'),
            % hang while we're still recording
        pause(0.05);
    end

    % upload the data

    ADCBuff= RZ6.ReadTagV('ADCBuff', 0, GolBuffNPts); % get waveform data
    ADCMax= max(abs(ADCBuff));
    DACPeak= RZ6.GetTagVal('DACPeak');

    if ADCMax> VInMax,
        DACGain= DACGain/5;
    elseif ADCMax< 0.25*VInMax && DACPeak<9.9,
        DACGain= DACGain*2;
    elseif ADCMax< 0.25*VInMax &&  DACPeak>=9.9,
        disp('System Maxed Out in First Golay Test!');
        break
    else
        break;
    end

end

RZ6.Halt;

% get data from first-probe ADCBuff starting after RecordDelayPts

NADC= NRep*2*NGolPts;
ADCBuff= ADCBuff(RecordDelayPts:(RecordDelayPts+NADC-1));
if NRep>1
    ADCBuff= reshape(ADCBuff(:),2*NGolPts,NRep);
    ADCBuff= mean(ADCBuff,2);
end

% do the Golay analysis
[CSpec,Impulse]= GolayAnal(ADCBuff,AGol,BGol);

CSpec1= CSpec .* SpeakerDrxVec;    % correct for speaker directionality, then save complex spectrum of the original system
Impulse1= real(ifft(CSpec1));

% make the first (low-order) filter and download to RZ6

HannSize= FIROrder-1;
if ~rem(HannSize,2),    % Gotta be odd
    HannSize= HannSize-1;
end
HalfHann= floor(HannSize/2);

NImp= length(Impulse1);
[dum i]= max(Impulse1);
AugImp= [Impulse1 Impulse1];
if i<ceil(HannSize/2),
    i= i + NImp;
end
CutImp= AugImp((i-HalfHann):(i+HalfHann));
CutImp= CutImp.*hanning(HannSize)';
mySpec= fft(CutImp);
iSpec= 1./mySpec;
MyMag= abs(iSpec(1:(HalfHann+1)));
RelFreq= [0:HalfHann]/(HalfHann);
iLo= find(RelFreq<LoCut/Nyq);
iLo= iLo(end);
iHi= find(RelFreq>HiCut/Nyq);
iHi= iHi(1);
t= iLo-(0:iLo-1);
t= t/iLo;
MyMag(1:iLo)= MyMag(1:iLo).*(1+cos(pi*t))/2;
t= (iHi:length(MyMag)) - iHi;
t= t/max(t);
MyMag(iHi:end)= MyMag(iHi:end).*(1+cos(pi*t))/2;
% MyMag(1)= 0; %MyMag(iLo)/100;
% MyMag(end)= 0; %MyMag(iHi)/100;
% MyMag([2:iLo iHi:end-1])= [];
% RelFreq([2:iLo iHi:end-1])= [];

FIRBuff= fir2(FIROrder, RelFreq, MyMag);
FIRBuff= 10*FIRBuff/sum(abs(FIRBuff)); % normalize by sum of abs FIRBuff 
%   and multiply by 10 to get reasonable gain

RZ6.Run;

RZ6.WriteTagV('FIRCoef', 0, FIRBuff);

% % enable the biquad filters
% RZ6.SetTagVal('BandPass',1);
% RZ6.SetTagVal('AllPass',0);
% RZ6.SetTagVal('LoCut',LoCut);
% RZ6.SetTagVal('HiCut',HiCut);

% 2nd probe, with the FIR filter in place

ADCMax= ADCMax+1;

while ADCMax > VInMax || ADCMax<0.25*VInMax,  % loop until we get an ADCMax in range

    RZ6.SetTagVal('DACGain', DACGain);

    RZ6.SoftTrg(1);
    pause(0.05);
    while RZ6.GetTagVal('Active'),
            % hang while we're still recording
        pause(0.05);
    end

    % upload the data

    ADCBuff= RZ6.ReadTagV('ADCBuff', 0, GolBuffNPts); % get waveform data
    ADCMax= max(abs(ADCBuff));
    DACPeak= RZ6.GetTagVal('DACPeak');

    if ADCMax> VInMax,
        DACGain= DACGain/5;
    elseif ADCMax< 0.25*VInMax && DACPeak<9.9,
        DACGain= DACGain*2;
    elseif ADCMax< 0.25*VInMax &&  DACPeak>=9.9,
        disp('System Maxed Out in First Golay Test!');
        break
    else
        break;
    end

end

RZ6.Halt;

% get data from second-probe ADCBuff starting after RecordDelayPts

NADC= NRep*2*NGolPts;
ADCBuff= ADCBuff(RecordDelayPts:(RecordDelayPts+NADC-1));
if NRep>1
    ADCBuff= reshape(ADCBuff(:),2*NGolPts,NRep);
    ADCBuff= mean(ADCBuff,2);
end

% do the Golay analysis
[CSpec,Impulse]= GolayAnal(ADCBuff,AGol,BGol);

CSpec2= CSpec .* SpeakerDrxVec;    % correct for speaker directionality, then save complex spectrum of the original system
Impulse2= real(ifft(CSpec2));

% Now play TDT Gauss Noise through this filter and get dBSPL

RZ6.Halt;
RZ6.ClearCOF;
success = RZ6.LoadCOF('k:\open\tdtpatch\calibration\RZ6CatNoiseLevel.rcx');

if ~success
   	error('Failed to load RZ6 Noise Level Circuit');
end
RZ6.Run;
Fs= RZ6.GetSFreq;
RZ6.WriteTagV('FIRCoef', 0, FIRBuff);
%RZ6.SetTagVal('BuffSize', GolBuffNPts);
RZ6.SetTagVal('BuffSize', 2*GolBuffNPts);   % 3/26/2010 try testing a sweet spot in middle of buffer
if DACChan==1,
    RZ6.SetTagVal('DAC1Enable',1);
    RZ6.SetTagVal('DAC2Enable',0);
else
    RZ6.SetTagVal('DAC1Enable',0);
    RZ6.SetTagVal('DAC2Enable',1);
end

% enable the biquad filters

RZ6.SetTagVal('LoCut',LoCut);
RZ6.SetTagVal('HiCut',HiCut);

% probe the system with Gauss noise

GaussDACGain= 1; 
ADCMax= VInMax+1;

while ADCMax > VInMax || ADCMax<0.25*VInMax,

    RZ6.SetTagVal('DACGain', GaussDACGain);

    RZ6.SoftTrg(1);
    pause(0.05);
    while RZ6.GetTagVal('Active'),
            % hang while we're still recording
        pause(0.05);
    end

    % upload the data

%    ADCBuff= RZ6.ReadTagV('ADCBuff', 0, GolBuffNPts); % get waveform data
    ADCBuff= RZ6.ReadTagV('ADCBuff', 0, 2*GolBuffNPts); % get waveform data; see 3/26/2010 note above
    iSweet= round(GolBuffNPts/2) + (1:GolBuffNPts);
    ADCBuff= ADCBuff(iSweet);
    ADCMax= max(abs(ADCBuff));
    DACPeak= RZ6.GetTagVal('DACPeak');

    if ADCMax> VInMax,
        GaussDACGain= GaussDACGain/2;
    elseif ADCMax< 0.25*VInMax && DACPeak<9.9, % limit DACPeak to <9.9 to avoid clipping DAC
        GaussDACGain= GaussDACGain*2;
    elseif ADCMax< 0.25*VInMax && DACPeak>=9.9,
        disp('System Maxed Out in Gauss Test!');
        break
    else
       break;
    end
end

RZ6.Halt;

% get NGolPts points from ADCBuff

ADCBuff= ADCBuff(RecordDelayPts:(RecordDelayPts+NGolPts-1))';

% get the RMS

GaussSpec= abs(fft(ADCBuff)) .* SpeakerDrxVec;  % go to freq domain so we can do the speaker correction  
N= length(PassBand);
RMS= sqrt(sum(GaussSpec(PassBand).^2)/(N^2))/GaussDACGain;
NoiseGain= RMS/VRef;

if DoPlot,
    % display initial system response
    clf
    TimeAxis= 1000*[1:NGolPts]*DACTick;
    subplot(2,3,1); plot(TimeAxis,Impulse1)
    magspec= 20*log10(abs(CSpec1(1:NGolPts/2)));
    subplot(2,3,4); plot(FreqAxis(1:NGolPts/2)',magspec)
    set(gca,'xlim',[0 50000],'ylim',[20 70]);
    
    %... and first corrected spectrum and impulse response
    subplot(2,3,2); plot(TimeAxis,Impulse2);
    subplot(2,3,5);
    magspec= 20*log10(abs(CSpec2(1:NGolPts/2)));
    plot(FreqAxis(1:NGolPts/2)',magspec);    
    set(gca,'xlim',[0 50000],'ylim',[20 70]);
       
    SpecSTD= std(magspec(PassBand));
    SpecRange= max(magspec(PassBand))-min(magspec(PassBand));
    disp(sprintf('NoiseGain: %.3f, SD: %.3f, SpecRange: %.1f', NoiseGain, SpecSTD,SpecRange));
    %... and spectrum of Gauss noise thru corrected system
    subplot(2,3,6)
    magspec= 20*log10(GaussSpec(1:NGolPts/2)/(NoiseGain*GaussDACGain));
    plot(FreqAxis(1:NGolPts/2)',magspec);
    title(num2str(NoiseGain));
    set(gca,'xlim',[0 50000], 'ylim', [10 60]);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

return