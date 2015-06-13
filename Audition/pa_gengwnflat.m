function [snd,Fs] = pa_gengwnflat(N, order, Fc, Fn, Fh, varargin)
% Generate Gaussian White Noise Stimulus by defining a flat Magnitude
% spectrum and a random phase.
%
%
% See also PA_GENGWN, PA_WRITEWAV
%

% 2007 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com


%% Initialization

if nargin<5
	Fh          = 500;
end
if nargin<4
	Fn          = 48828.125/2; % TDT Nyquist sampling frequency (Hz)
end
if nargin<3
	Fc          = 20000; % Hz
	Fc = min([Fc Fn]);
end
if nargin<2;
	order       = 500; % samples
end
if nargin<1
	N           = 0.15*Fn*2; % samples
end
Fs = Fn*2;

%% Optional arguments
dspFlag       = pa_keyval('display',varargin);
if isempty(dspFlag)
	dspFlag	= 1;
end
plee       = pa_keyval('play',varargin);
if isempty(plee)
	plee	= 'n';
end

%% Create and Modify Signal
NFFT = 2^(nextpow2(N));
M   = repmat(100,NFFT/2,1);
M   = [M;fliplr(M)];
P   = (rand(NFFT/2,1)-0.5)*2*pi;
P   = [P;fliplr(P)];

R = M.*cos(P);
I = M.*sin(P);
S = complex(R,I);

snd = ifft(S,'symmetric');

% Low-pass filter
snd             = pa_lowpass(snd, Fc, Fn, order);
% High-pass filter
snd             = pa_highpass(snd, Fh, Fn, order);

%% Optional Graphics
if dspFlag
	figure;
	disp('>> GENGWN <<');
	subplot(211);
	plot(snd);
	xlabel('Sample number');
	ylabel('Amplitude (a.u.)');

	
	subplot(212)
	pa_getpower(snd,Fn*2,'display',1);
	xlim([50 22000])
end

%% Play
if strcmpi(plee,'y');
	sndplay = pa_envelope(snd',round(10*Fs/1000));
	p		= audioplayer(sndplay,Fs);
	playblocking(p);
end
