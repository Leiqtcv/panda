function xfilt = pa_nirs_bandpass(x, Fs, Fl, Fh)
% XFILT = PA_NIRS_BANDPASS(X,FS,FL,FH);
%
% Bandpass filter x X with a butterworth filter
% Default sampling rate FS = 10 Hz, low and high cutoff frequencies are
% 0.008 and 0.08 Hz.
%
% This effectively removes cardiac pulsations around 1 Hz, and arterial
% pressure / Mayer waves at 0.1 Hz.
%

% 2013 Marc van Wanrooij
% e: marcvanwanrooij@neural-code.com

%% Initialization
% Default values
if nargin < 4
    Fh	= 0.08;
end
if nargin < 3
    Fl	= 0.008;
end
if nargin < 2
    Fs	= 10;
end
n		= 3;
Fn		= Fs/2;
Wn		= [Fl Fh]/Fn;
ftype	= 'bandpass';
[b,a]	= butter(n,Wn,ftype);

%% Check row-colum order
[m,n]   = size(x);
[N,I]	= min([m n]);
M       = max([m n]);
if I == 2
   x = x';
end

%% Duplicates first and last values to reduce filter artifact
xfilt = NaN(N,M);
for ii = 1:N    
    begin		= x(1)*ones(1,M);
    fin			= x(end)*ones(1,M);
    t_x			= [begin x(ii,:) fin];    
    t_x			= filtfilt(b, a, t_x);
    t_x			= t_x(M+1:2*M);    
    xfilt(ii,:) = t_x;
end


