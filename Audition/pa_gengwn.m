function [snd,Fs] = pa_gengwn(Dur, order, Fc, Fn, Fh, varargin)
% Generate Gaussian White Noise Stimulus
%
% GWN = PA_GENGWN (Dur, order, Fc, Fn, Fh)
%
% Generate Gaussian White Noise Stimulus, with
% Dur       - duration of sound (s)
% Order     - order of filter
% Fc        - low-pass cut-off Frequency
% Fn        - Nyquist Frequency
% Fh		- high-pass cutoff
%
% For example:
%   Dur		= 0.15;
%   stm		= pa_gengwn(Dur,100,20000,25000)
%   fname	= 'BB.wav';
%   pa_writewav(stm,fname);
%
% will generate a broad-band noise between 500 (default) and 20 kHz with
% duration 150 msec (7500 samples / (25000 samples/sec*2) *1000 m). The
% on- and offset ramp each contain 250 samples = 250/50000 sec = 5 msec.
% This noise will be stored in the WAV-file 'BB.wav'.
%
% See also PA_WRITEWAV, PA_LOWPASS, PA_HIGHPASS

% 2007 Marc van Wanrooij

%% Initialization
if nargin<5
    Fh          = 500;
end
if nargin<4
    Fn          = 48828.125/2; % TDT Nyquist sampling frequency (Hz)
end    
if nargin<3
    Fc          = 20000; % Hz
end    
if nargin<2; 
    order       = 500; % samples
end
if nargin<1
	Dur = 0.15;
end
N    = Dur*Fn*2; % samples
if order>N/6
	order = round(N/3)-2;
end
Fs = Fn*2;

%% Optional arguments
dspFlag       = pa_keyval('display',varargin);
if isempty(dspFlag)
	dspFlag	= 0;
end
plee       = pa_keyval('play',varargin);
if isempty(plee)
	plee	= 'n';
end

%% Create and Modify Signal
N				= round(N);
snd             = randn([N,1]);
% Low-pass filter
snd             = pa_lowpass(snd, Fc, Fn, order);
% High-pass filter
snd             = pa_highpass(snd, Fh, Fn, order);

%% Optional Graphics
if dspFlag
    figure;
    disp('>> GENGWN <<');
    subplot(211)
    plot(snd)
    xlabel('Sample number')
    ylabel('Amplitude (a.u.)');
    
    subplot(212);
    pa_getpower(snd,Fn*2,'display',1);
	xlim([50 22000])
end

%% Play
if strcmpi(plee,'y');
	sndplay = pa_envelope(snd',round(10*Fs/1000));
	p		= audioplayer(sndplay,Fs);
	playblocking(p);
end