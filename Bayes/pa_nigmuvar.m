function [mu,var] = pa_nigmuvar(beta)
% [MU,VAR] = PA_NIGMUVAR(BETA)
%
% Determine expected mean MU and expected variance VAR according to
% parameters BETA of a Normal-InverseGamma (NIG) distribution. 
%
% See also http://en.wikipedia.org/wiki/Conjugate_prior
mu		= beta(2); % sample mean
a		= beta(3);
b		= beta(4);
% var		= b/a; % sample variance
var		= b/(a-1); % estimate sample variance