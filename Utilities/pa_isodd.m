function sel = pa_isodd(X)
% SEL = PA_ISODD(X) 
%
% Return selection vector for parity of X,
% 1 is odd, 0 even.
%
% See also PA_ISEVEN

% 2012 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

sel = (X - 2*floor(X/2)) ~= 0;
 
