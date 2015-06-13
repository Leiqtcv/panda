function Y = pa_sigmoidfun(beta,X)
% Y = PA_SIGMOIDFUN(B,X)
%
% Sigmoid function:
% Y = 1./(1+exp(-b(1).*X+b(2)));
%
% See also NLINFIT, PA_SPK_PREDICT

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

Rpk = beta(1); % peak firing rate
Y = Rpk./( 1+exp( beta(2)*(X+beta(3)) ) );
