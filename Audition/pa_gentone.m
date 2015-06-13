function [snd,Fs] = pa_gentone(Freq, dur, varargin)
% Generate TONE Stimulus
%
% STM = GENTONE (DUR, FREQ, NENV)
%
% Generate a sine-shaped tone, with
% dur       - duration                 [150]      ms
% Freq      - Frequency of tone                 [4000]      Hz
%
% PA_GENTONE(...,'PARAM1',val1,'PARAM2',val2) specifies optional
% name/value pairs. Parameters are:
% 'nenvelope' - number of samples in envelope     [250]       samples
%             (head and tail are both 'NEnvelope')
% 'Fs'			- Sample frequency                  [48828.125] Hz
% 'display'		- set to 1 to display stuff         [0]
% 'phase'		- set phase							[0]
%
%
% For example:
%   Sine440 = gentone(440,150);
%   wavplay(Sine440,48828.125)
%   % Standard 150ms 440Hz tone
%
%   Sine3000 = gentone(3000,150,'nenvelope',7200/2,'Fs',50000,'display',1);   
%   wavplay(Sine3000,50000)
%   % 3kHz tone with onset and offset ramp with a sample rate of 50kHz. It 
%   % also produces an output screen of the generated tone in time and
%   % frequency domain.
%
% See also WRITEWAV, LOWPASSNOISE, HIGHPASSNOISE, GENGWN
%

% Copyright 2007
% Marc van Wanrooij
%
% Modified 2012:
% - added pa_keyval utility
% - replaced sample with duration (ms)

%% Initialization
if nargin<1
    Freq          = 4000; % Hz
end    
if nargin<2
    dur           = 150; % samples
end
dspFlag         = pa_keyval('display',varargin);
if isempty(dspFlag)
	dspFlag			= 0;
end
plee         = pa_keyval('play',varargin);
if isempty(plee)
	plee			= false;
end
Fs         = pa_keyval('Fs',varargin);
if isempty(Fs)
    Fs          = 48828.125; % TDT Nyquist sampling frequency (Hz)
end
phi         = pa_keyval('phase',varargin);
if isempty(phi)
    phi          = 0; % radians
end
N		= round(dur/1000*Fs);
Fn		= Fs/2;

%% Create and Modify Signal
sig             = cumsum(ones(1,N))-1;
sig             = sig/Fs;
snd             = sin(2*pi*Freq*sig+phi);

%% Optional Graphics
if dspFlag
    figure;
    disp(['>> ' upper(mfilename) ' <<']);
    subplot(211)
    plot(snd)
    xlabel('Sample number')
    ylabel('Amplitude (a.u.)');
    
    Nfft = 2^10;
    Nnyq = Nfft/2;
    s = fft(snd,Nfft);
    s = abs(s);
    s = s(1:Nnyq);
    f = (0:(Nnyq-1))/(Nnyq)*Fn;
    subplot(212)
    loglog(f,s,'ko-','MarkerFaceColor','w');
    set(gca,'Xtick',[1 2 4 6 12 24]*1000,'XtickLabel',[1 2 4 6 12 24]);
    xlabel('Frequency (Hz');
    ylabel('Amplitude (au)');
end

if plee
	sndplay = pa_envelope(snd',round(10*Fs/1000));
	p		= audioplayer(sndplay,Fs);
	playblocking(p);
end