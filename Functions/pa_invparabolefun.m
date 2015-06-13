function Y = pa_invparabolefun(beta,X)
% Y = PA_INPARABOLEFUN(BETA,X)
%
% Function: Y = 1-X^2/BETA^2
%
% Useful for functional relationship between accuracy/gain (Y),
% pecision/variance (X^2), and prior variance (BETA^2).
%
% See also PA_FITPRIOR

% (c) 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@neural-code.com

Y = 1 - X.^2/beta.^2;
