function pa_gentone(Freq, dur, varargin)
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
	dur           = 2000; % samples
end
grph         = pa_keyval('display',varargin);
if isempty(grph)
	grph			= 1;
end
Fs         = pa_keyval('Fs',varargin);
if isempty(Fs)
	Fs          = 50000; % TDT Nyquist sampling frequency (Hz)
end
nEnv         = pa_keyval('nenvelope',varargin);
if isempty(nEnv)
	nEnv          = 200; % samples
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
n = length(sig);

%% gauss
x = -n:-1;
y = normpdf(x,0,n/4);
y = y./max(y);

% x = 1:n;
% y = randn(size(x));
% y = smooth(cumsum(y),n/1);
% y = (y-min(y))./(max(y)-min(y));
% y = y-min(y);
% y = y';

x = 1:n;
y = x/max(x);


Freq2 = pa_oct2bw(2000,1.5*y);
Freq = pa_oct2bw(2000,-1*y);

snd             = sin(2.*pi.*Freq.*sig+phi);
snd2             = sin(2.*pi.*Freq2.*sig+phi);

indx = 30000:50000;
snd2a			= snd2(1:indx(1));
snd2a           = pa_envelope(snd2a(:), nEnv);
snd2(indx(1)-nEnv:indx(1)) = snd2a(end-nEnv:end);
snd2b			= snd2(indx(end):end);
snd2b           = pa_envelope(snd2b(:), nEnv);
snd2(indx(end)+1:indx(end)+nEnv) = snd2b(1:nEnv);

snd2(indx) = 0.*snd2(indx);
snd = snd+0.1*randn(size(sig));
snd2 = snd2+0.1*randn(size(sig));
whos snd
close all hidden;
subplot(221)
plot(x,y)

subplot(222)
plot(x,Freq)
% sig = sig2;
% Envelope to remove click

% % Low-pass filter
% snd             = pa_lowpass(snd, 16000, Fs/2, 50);
% % High-pass filter
% snd             = pa_highpass(snd, 100, Fs/2, 50);
% % Low-pass filter
% snd2             = pa_lowpass(snd2, 16000, Fs/2, 50);
% % High-pass filter
% snd2            = pa_highpass(snd2, 100, Fs/2, 50);


if nEnv>0
	snd             = pa_envelope (snd(:), nEnv);
	snd2             = pa_envelope (snd2(:), nEnv);
else
	snd = snd(:)';
	snd2 = snd2(:)';
end
snd		= snd-snd(1);
snd2 = snd2-snd2(1);


snd = [snd snd2];
% snd  = snd2;

whos snd
%Reshape
% snd             = snd(:)';

%% Optional Graphics
if grph
	p = audioplayer(snd', Fs);
	playblocking(p);
	%     wavplay(snd,Fs,'sync');
	snd = sum(snd,2);
	whos snd
	pa_plotspec(snd,Fs);
end