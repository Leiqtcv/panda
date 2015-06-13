function p = pa_logistic(x)
% P = PA_LOGIT(X)
%
% The logistic or sigmoid function:
% P = 1/(1+exp(-X))
%
% See also PA_LOGIT, PA_PROBIT

% 2013 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

p = 1./(1+exp(-x));
