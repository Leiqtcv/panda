function [Z,mu,sigma] = pa_zscore(x,flag,dim)
% Z = PA_ZSCORE(X)
%
% Z-transform variable X:
%
% Z = (X-mean(X))./std(X)
%
% This is useful for multiple linear regression, when one wants to compare
% variables of different units. Regression coefficients obtained from
% z-transformed data are called partial regression coefficients (cf.
% correlation coefficient).
%
% The standard deviation is by default the sample standard deviation, with
% n-1 in the denominator.
%
% This function was later rewritten in the style of Matlab's ZSCORE, with
% the extra possibility of taking care of NaNs in the data.
%
% If you have the statistics toolbox:
% see also ZSCORE


% (c) 2011-04-27 Marc van Wanrooij
% E-mail: marcvanwanrooij@gmail.com
if nargin<2
	flag	= 0;
end
if nargin < 3
    % Figure out which dimension to work along.
    dim		= find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Compute X's mean and sd, and standardize it
mu		= nanmean(x,dim);
sigma	= nanstd(x,flag,dim);
z		= bsxfun(@minus,x, mu);
Z		= bsxfun(@rdivide, z, sigma);