function pa_writewav(Signal,fname,ScalingFactor,Fsample,Nbits)
% Write a stimulus to WAV-file
%
% PA_WRITEWAV(Y,WAVEFILE,SCALINGFACTOR,FS,NBITS)
%
% Write a signal Y to WAVEFILE, scaling the signal by SCALINGFACTOR
% (default: 0.99).
% 
% Sampling frequency FS is by deault 48828.125 Hz (TDT system)
% Number of bits NBITS is by default 16 (max. TDT bit depth)
% 
% See also PA_GENGWN, PA_GENRIPPLE, WAVWRITE

% 2007 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
if nargin<3
    ScalingFactor = 0.99;
end
if nargin<4
  Fsample = 48828.125;  % TDT sampling frequency (Hz)
end;
if nargin<5
    Nbits = 16; % TDT maximal bit depth for WAVs
end
fname = pa_fcheckext(fname,'wav');

%% Minmax signal for amplifier
if ~isempty(ScalingFactor)
    Signal = ScalingFactor.*Signal./max(max(abs(Signal)));
end

%% Write
wavwrite(Signal,Fsample,Nbits,fname);