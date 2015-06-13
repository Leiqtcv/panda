function Y = pa_postmatchfun(beta,X)
% Y = PA_POSTMATCHFUN(BETA,X)
%
% Function: Y^2 = BETA^2*(1-X^2)
%
% Useful for functional relationship between accuracy/gain (X),
% pecision/variance (Y^2), and prior variance (BETA^2).
%
% See also PA_FITPRIOR

% (c) 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@neural-code.com

Y = beta.^2.*(1 - X.^2);
Y = sqrt(Y);
