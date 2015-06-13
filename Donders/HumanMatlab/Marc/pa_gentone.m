function [stm,Fs] = pa_gentone(N, Freq, NEnvelope, Fs, grph)
% GENerate TONE Stimulus
%
% STM = GENTONE (<N>, <Freq>, <NEnvelope>, <Fs>, <grph>)
%
% Generate a sine-shaped tone, with
% N         - number of samples                 [7500]      samples
% Freq      - Frequency of tone                 [2000]      Hz
% NEnvelope - number of samples in envelope     [250]       samples
%             (head and tail are both 'NEnvelope')
% Fs        - Sample frequency                  [48828.125] Hz
% grph      - set to 1 to display stuff         [0]
%
%
% For example:
%   Sine440 = gentone(7324,440);
%   wavplay(Sine440,48828.125)
%   % Standard 150ms 440Hz tone
%
%   Sine3000 = gentone(7500,3000,7500/2,50000,1);   
%   wavplay(Sine3000,50000)
%   % 3kHz tone with onset and offset ramp with a sample rate of 50kHz. It 
%   % also produces an output screen of the generated tone in time and
%   % frequency domain.
%
% See also WRITEWAV, LOWPASSNOISE, HIGHPASSNOISE, GENGWN
%

% Copyright 2007
% Marc van Wanrooij

%% Initialization
if nargin<5
    grph = 1;
end
if nargin<4
%     Fn          = 25000; % Hz
    Fs          = 48828.125; % TDT Nyquist sampling frequency (Hz)
end    
if nargin<3; 
    NEnvelope   = 250; % samples
end
if nargin<2
    Freq          = 4000; % Hz
end    
if nargin<1
    N           = 7500; % samples
end

Fn = Fs/2;
%% Create and Modify Signal
sig             = cumsum(ones(1,N))-1;
sig             = sig/Fs;
sig             = sin(2*pi*Freq*sig);
% Envelope to remove click
stm             = pa_envelope (sig(:), NEnvelope);
%Reshape
stm             = stm(:)';

%% Optional Graphics
if grph
    figure;
    disp(['>> ' upper(mfilename) ' <<']);
    subplot(211)
    plot(stm)
    wavplay(stm,Fs);
    xlabel('Sample number')
    ylabel('Amplitude (a.u.)');
    
    Nfft = 2^10;
    Nnyq = Nfft/2;
    s = fft(stm,Nfft);
    s = abs(s);
    s = s(1:Nnyq);
    f = (0:(Nnyq-1))/(Nnyq)*Fn;
    subplot(212)
    loglog(f,s);
    set(gca,'Xtick',[1 2 4 6 12 24]*1000,'XtickLabel',[1 2 4 6 12 24]);
    xlabel('Frequency (Hz');
    ylabel('Amplitude (au)');
end