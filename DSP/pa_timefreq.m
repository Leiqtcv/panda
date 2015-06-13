function [m,f,t] = pa_timefreq(x,fs)
% LFPTIMEFREQ(DATA)
%
% Plot time-frequency-graph of Local Field Potentials.
%
% 2010 Marc van Wanrooij

%% Simple
[m,f,t] = gettimefreq(x,fs);

%% baseline
mu = mean(m(:,700:end),2);
m = m-repmat(mu,1,size(m,2));

% mu = mean(m,2);
% m = m-repmat(mu,1,size(m,2));

%% Graphics
if nargout<1
pcolor(t,f,m)
shading flat
hold on
end

function [M,Freq,t] = gettimefreq(x,Fs)
% [M,F,T] = GETTIMEFREQ(X,FS)
%
% Get time-frequency representation of signal X sampled at FS Hz.
%
% 2009 Marc van Wanrooij

%% Default
x       = x(:);
fmax	= 150;
nfft    = 2^12;
wnd		= 2^8; % 256
% nfft    = 2^13;
% wnd		= 2^7; % 256
wnd		= round(Fs*wnd/1000); % samples
n		= length(x);
step	= 5;
t		= (1:step:(n-wnd));
nt		= length(t);
Freq	= ((1:(nfft/2))-1)/nfft*Fs;
sel		= Freq<fmax;
Freq	= Freq(sel);
nFbin	= sum(sel);
nTbin	= nt;
M		= zeros(nFbin,nTbin);
w		= hanning(wnd+1);

%% Get Power
for i		= 1:nt
	indx	= t(i):t(i)+wnd;
	sig		= x(indx);
	sig		= w.*sig;
	[f,mx]	= getpower(sig,Fs,nfft);
	sel		= f<fmax;
	M(:,i)	= mx(sel);
end
t			= t/Fs+(wnd/2)/Fs;
t           = round(t*1000); % ms

function [f,mx]=getpower(x,Fs,nfft)
% [F,MX] = GETPOWER(X,FS,DISP)
%
% Get power spectrum MX of signal X, sampled at FS Hz.
% DISP - plot power spectrum
%


% Sampling frequency
if nargin<2
	Fs = 50000;
end
if nargin<3
% Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
nfft			= 2^(nextpow2(length(x)));
end

% Time vector of 1 second
% Take fft, padding with zeros so that length(fftx) is equal to nfft
fftx			= fft(x,nfft);
% Calculate the numberof unique points
NumUniquePts	= ceil((nfft+1)/2);
% FFT is symmetric, throw away second half
fftx			= fftx(1:NumUniquePts);
% Take the magnitude of fft of x and scale the fft so that it is not a function of
% the length of x
mx				= abs(fftx)/length(x);
% Take the square of the magnitude of fft of x.
mx				= mx.^2;

% Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.
% The DC component and Nyquist component, if it exists, are unique and should not
% be mulitplied by 2.
if rem(nfft, 2) % odd nfft excludes Nyquist point
	mx(2:end)	= mx(2:end)*2;
else
	mx(2:end -1) = mx(2:end -1)*2;
end
% This is an evenly spaced frequency vector with NumUniquePts points.
f		= (0:NumUniquePts-1)*Fs/nfft;


mx		= 20*log10(mx);
% sel		= isinf(mx);
% mx(sel) = min(mx(~sel));