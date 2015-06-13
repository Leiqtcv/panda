function [sel,Y] = pa_between(X,A,B)
% SEL = PA_BETWEEN(X,A,B)
%
% Determine which values in X lie between A and B in selection vector
%
% [SEL,Y] = PA_BETWEEN(...) also outputs Y = X(SEL).

% (c) 2011 Marc van Wanrooij

%% Initialization
if nargin<2, A = 0; end
if nargin<3, B = 0; end
if size(X,1)>1 && size(X,2)>1
	X = X(:);
	disp('X should be a vector. X is vectorized');
end

sel = X>A & X<B;
if nargout>1, Y	= X(sel); end % Output only when asked for