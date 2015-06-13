function tmp(Freq, dur, varargin)
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
	dur           = 5000; % samples
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

function [val, remaining] = pa_keyval(key, varargin)

% PA_KEYVAL returns the value that corresponds to the requested key in a
% key-value pair list of variable input arguments
%
% Use as
%   [val] = pa_keyval(key, varargin)
%
% See also VARARGIN

% Undocumented option
%   [val] = pa_keyval(key, varargin, default)

% Copyright (C) 2005-2007, Robert Oostenveld
%
% This file was part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details. It is now used for PandA, see
% http://www.mbfys.ru.nl/~marcw/Spike/doku.php
%
%    PandA is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    PandA is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with PandA. If not, see <http://www.gnu.org/licenses/>.
%

% what to return if the key is not found
emptyval = [];

if nargin==3 && iscell(varargin{1})
  emptyval = varargin{2};
  varargin = varargin{1};
end

if nargin==2 && iscell(varargin{1})
  varargin = varargin{1};
end

if mod(length(varargin),2)
  error('optional input arguments should come in key-value pairs, i.e. there should be an even number');
end

% the 1st, 3rd, etc. contain the keys, the 2nd, 4th, etc. contain the values
keys = varargin(1:2:end);
vals = varargin(2:2:end);

% the following may be faster than cellfun(@ischar, keys)
valid = false(size(keys));
for i=1:numel(keys)
  valid(i) = ischar(keys{i});
end

if ~all(valid)
  error('optional input arguments should come in key-value pairs, the optional input argument %d is invalid (should be a string)', i);
end

hit = find(strcmpi(key, keys));
if isempty(hit)
  % the requested key was not found
  val = emptyval;
elseif length(hit)==1  
  % the requested key was found
  val = vals{hit};
else
  error('multiple input arguments with the same name');
end

if nargout>1
  % return the remaining input arguments with the key-value pair removed
  keys(hit) = [];
  vals(hit) = [];
  remaining = cat(1, keys(:)', vals(:)');
  remaining = remaining(:)';
end

function F = pa_oct2bw(F1,oct)
% F2 = PA_OCT2BW(F1,OCT)
%
% Determine frequency F2 that lies OCT octaves from frequency F1
%

% (c) 2011-05-06 Marc van Wanrooij
F = F1 .* 2.^oct;

function X = pa_envelope(X, N)
% PA_ENVELOPE(X,N)
%
% Smooth on- and offset (N samples) of signal X.
%
% PA_ENVELOPE(SIG, NENV)
%

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com


XLen = size(X,1);
if (XLen < 2*N)
	error('pandaToolbox:DSP:EnvelopeTooLong','Envelope length greater than signal');
else
	EnvOn	= sin(0.5*pi*(0:N)/N).^2;
	EnvOff	= fliplr(EnvOn);
	head	= 1:(N+1);
	tail	= (XLen-N):XLen;
	for i = 1:size(X,2)
		X(head,i) = EnvOn'.*X(head,i);
		X(tail,i) = EnvOff'.*X(tail,i);
	end;
end;

function pa_plotspec(snd,Fs)
% PA_PLOTSPEC(SND,FS)
% close all;
T = (1:length(snd))/Fs;
 subplot(221);
plot(T,snd,'k-')
ylabel('Amplitude (au)');
xlabel('Time (s)');
xlim([min(T) max(T)]);
hold on
axis square;

subplot(224)
pa_getpower(snd,Fs,'orientation','x');
set(gca,'XTick',[0.5 1 2 4 8 16]*1000);
set(gca,'XTickLabel',[0.5 1 2 4 8 16]);
ax = axis;
xlim(0.6*ax([1 2]));
xlim([100 20000])
set(gca,'XScale','log');
axis square;

subplot(223);
nsamples	= length(snd);
t			= nsamples/Fs*1000;
dt			= 5;
nseg		= t/dt;
segsamples	= round(nsamples/nseg); % 12.5 ms * 50 kHz = 625 samples
noverlap	= round(0.6*segsamples); % 1/3 overlap
window		= segsamples+noverlap; % window size
nfft		= 1000;
spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');
axis square;
% colorbar
cax = caxis;
caxis([0.7*cax(1) 1.1*cax(2)])
set(gca,'YTick',[0.5 1 2 4 8 16]*1000);
set(gca,'YTickLabel',[0.5 1 2 4 8 16]);
set(gca,'YScale','log');
xlim([min(T) max(T)]);
ylim([100 20000]);
drawnow
xlabel('Time (s)');

% linkaxes(ax,'x');