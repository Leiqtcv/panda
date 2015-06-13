function Y = pa_nirs_hdrfunction(beta,X)
% Y = PA_NIRS_HDRFUNCTION(BETA,X)
%
%

if nargin<1
	beta = [1 1 1];
end
if nargin<2
	X = 1:1000;
end
%% Initilization
% Fs      = 10;
% gain    = beta(1);
% shift   = 0; % 2 sec response delay
% A		= 4.30; % peak time 4.5 s after stim
% B		= .75;
% N       = length(X); % samples
% dur     = 50; % sec

%%
% x       = 0:(1/Fs):dur; % sec
% x       = x - shift;
% y       = gampdf(x,A,B);
% Y       = conv(X,y);
% Y       = Y(1:N);
% Y       = gain.*Y/max(Y); % Amplitude


%% Hemodynamic impulse response
gain    = beta(1);
if numel(beta)>1
b1 = beta(2);
b2 = beta(3);
else
b1 = 1;
b2 = 1;
end
N       = length(X); % samples

Fs      = 10;
dur     = 50; % sec
xh       = 0:(1/Fs):dur; % sec
a1		= 6; % peak time 4.5 s after stim, shape
a2		= 16; % peak time 4.5 s after stim, shape
c		= 1/6;
y       = gampdf(xh,a1,b1)-c*gampdf(xh,a2,b2);
Y       = conv(X,y);
Y       = Y(1:N);
Y       = gain.*Y/max(Y); % Amplitude


% close all
% plot(X,Y);