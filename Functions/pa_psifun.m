function y = pa_psifun(beta,x)
% Y = PA_PSIFUN(BETA,X)
%
% Psychometric function.
%
% This function takes the form of the cumulative gaussian distribution 
% function:
%
% 1/2[1+erf((x-mu)/(sqrt(2*sigma^2)))]
%
% with mu = BETA(1), sigma = BETA(2).
% 
%
% See also PA_PSIFIT

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

mu		= beta(1);
sigma	= beta(2);
x		= (x-mu)/(sqrt(2*sigma.^2));
y		= 1/2*(1+erf(x));