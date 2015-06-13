function [stm,Fs] = pa_gengwn(N, NEnvelope, order, Fc, Fn, Fh, grph)
% Generate Gaussian White Noise Stimulus
%
% GWN = PA_GENGWN (N, NEnvelope, order, Fc, Fn, Fh)
%
% Generate Gaussian White Noise Stimulus, with
% N         - number of samples
% NEnvelope - number of samples in ramping envelope
% Order     - order of filter
% Fc        - Cut-off Frequency
% Fn        - Nyquist Frequency
%
% For example:
%   N = 7500;
%   stm = pa_gengwn(N,250,100,20000,25000)
%   fname = 'BB.wav';
%   pa_writewav(stm,fname);
%
%
% will generate a broad-band noise between 20 (default) and 20 kHz with
% duration 150 msec (7500 samples / (25000 samples/sec*2) *1000 m). The
% on- and offset ramp each contain 250 samples = 250/50000 sec = 5 msec.
% This noise will be stored in the WAV-file 'BB.wav'.
%
% See also PA_WRITEWAV, PA_LOWPASS, PA_HIGHPASS
%

% Copyright 2007
% Marc van Wanrooij


%% Initialization
if nargin<7
    grph = 0;
end
if nargin<6
    Fh          = 500;
end
if nargin<5
    Fn          = 48828.125/2; % TDT Nyquist sampling frequency (Hz)
end    
if nargin<4
    Fc          = 20000; % Hz
end    
if nargin<3; 
    order       = 500; % samples
end
if nargin<2; 
    NEnvelope   = 250; % samples
end
if nargin<1
    N           = 0.15*Fn*2; % samples
end
if order>N/6
	order = round(N/3)-2;
end
	Fs = Fn*2;

%% Create and Modify Signal
N				= round(N);
stm             = randn([N,1]);
% Low-pass filter
stm             = pa_lowpass(stm, Fc, Fn, order);
% High-pass filter
stm             = pa_highpass(stm, Fh, Fn, order);

% Envelope to remove click
if NEnvelope>0
    stm       = pa_envelope(stm, NEnvelope);
end
%Reshape
stm             = stm(:)';

%% Optional Graphics
if grph
        figure;
%     home;
    disp('>> GENGWN <<');
    subplot(211)
    plot(stm)
    xlabel('Sample number')
    ylabel('Amplitude (a.u.)');
    
    subplot(212);
    pa_getpower(stm,Fn*2,'display',1);
	xlim([50 22000])
end