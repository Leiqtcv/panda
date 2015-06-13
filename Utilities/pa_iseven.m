function sel = pa_iseven(X)
% SEL = PA_ISEVEN(X) 
%
% Return selection vector for parity of X,
% 0 is odd, 1 even.
%
% See also PA_ISODD

% 2012 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

sel = (X - 2*floor(X/2)) == 0;
 
