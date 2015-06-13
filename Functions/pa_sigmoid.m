function Y = pa_sigmoid(b,X)
% Y = PA_SIGMOID(B,X)
%
% Sigmoid function:
% Y = 1./(1+exp(-b(1).*X+b(2)));
%
% See also NLINFIT

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

Y = 1./(1+exp(-b(1).*X+b(2)));
