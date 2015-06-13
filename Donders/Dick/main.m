%
% create ripple
%
% GenerateSeqRipple7, H.Versnel/Pascal Dephi, was used as an example
%
% Main
%
tic;
% parameters
freqMod    =     7;         % ?? 10*binfact
ampl       =   100;         % ?? modulation depth
nTone      =   120;         % number of components
nP         = 35100;         % 
nFlat      = 33650;         % target-static
nFFT       = 16384;         % 2^14
DARate     =    20;         % 20 K
rev        = false;         % static followed by dynamic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ergens anders gedefinieerd
%
specWidth  = 120;
specWidth  = specWidth/20;
freqRipple = 0;
freq0      = 350;
binFact    = 2*16384*(20/1000000);
phiC       = zeros(1,nTone);
if nTone > 1
    dFreq = specWidth/(nTone-1);
else
    dFreq = 0;
end
XF = zeros(1,nTone);
for i=1:nTone
    XF(i)   = round(freq0*2^((i-1)*dFreq)*binFact);
    phiC(i) = 2*pi*rand;
end
phasM      = zeros(1,nTone);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Buffers
XF1 = zeros(1,nTone);       % side Fc-Fm
XF2 = zeros(1,nTone);       % side Fc+Fm
phasM1 = zeros(1,nTone);    % phases side Fc-Fm
phasM2 = zeros(1,nTone);    % phases side Fc+Fm
phiM   = zeros(1,nTone);    % help array to compute phases
phiC2  = zeros(1,nTone);    % phases of side components

% variables
% int ntemp
% int nRep
% double ampC               % amplitude central component
% double ampM               %    side component
% double mindex             % ??
% double fact1              % ??
% double phi0               % phase component 0

ntemp = nFlat;
if rev == true              % static follows dynamic
    nFlat = nP;
    nP    = ntemp;
end

nRep = fix(0.5*nP/nFFT);    % number of buffers for stimulus duration
                            % can be removed later on
hDepth = ampl/200;          % set half of modulation                          
ampC = 1-hDepth;            % for 100% = 0.5
ampM = 0.5*hDepth;          %          = 0.25
mindex = hDepth/(1-hDepth); %          = 1.0
fac1 = sqrt(1+0.5*(mindex^2)); %       = 1.2247
if mindex == 0
    phi0 = asin((fac1-1)/mindex);
else
    phi0 = pi/2;
end
    
phiFac = pi*(nFlat/nFFT);   % 6.4513

for i=1:nTone
    phiC2(i) = phiC(i)+phiFac*XF(i);  % correct component phases
end

for i=1:nTone
    phiM(i) = 2*pi*freqRipple*dFreq*i+phi0;
    XF1(i) = XF(i)-freqMod;
    XF2(i) = XF(i)+freqMod;
    phasM1(i) = phiC2(i)+0.5*pi-phiM(i);
    phasM2(i) = 2*phiC2(i)-phasM1(i);
 end

SndWave   = ones(1,nP);     % buffer for sound wave form

cReal = zeros(1,nFFT);  % buffer
cImag = zeros(1,nFFT);  % buffer

% polar -> rectangular
[rXF1,iXF1] = pol2cart(ampM,phasM1);
[rXF,iXF]   = pol2cart(ampM,phasM);
[rXF2,iXF2] = pol2cart(ampM,phasM2);
% complex add
for i=1:nTone
    m  = XF(i);
    m1 = XF1(i);
    m2 = XF2(i);
    cReal(m)  = cReal(m) +rXF(i);
    cReal(m1) = cReal(m1)+rXF1(i);
    cReal(m2) = cReal(m2)+rXF2(i);
    cImag(m)  = cImag(m) +iXF(i);
    cImag(m1) = cImag(m1)+iXF1(i);
    cImag(m2) = cImag(m2)+iXF2(i);
end

spec = complex(cReal, cImag);

SndWave = abs(ifft(spec));
mn = mean(SndWave);
SndWave = SndWave - mn;

SndWave = [SndWave, SndWave];
SndWave = [SndWave, SndWave];
SndWave = [SndWave, SndWave];

plot(SndWave);
wavwrite(SndWave,50000,'c:\dick.wav');
toc;