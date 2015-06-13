function Y = pa_gauss(b,X)
% Y = PA_GAUSS(B,X)
%
% Guassian function
% B consists of:
% 1 - Mean
% 2 - SD
% 3 - Amplitude
% 4 - Biass/offset
%
% See also NLINFIT, PA_HOWTOFITAGAUSS

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

mu		= b(1);
sigma	= b(2);
A		= b(3);
bias	= b(4);
Y		= A*exp( - (X-mu).^2 / (2*sigma^2)) + bias;