function beta = pa_nigupdatestep(beta,x)
% BETA = PA_NIGUPDATESTEP(BETA,X)
%
% Update parameters BETA of a Normal-InverseGamma (NIG) distribution. 
%
% E.g.:
%
% for ii = 2:n
% 	beta(ii,:)			= pa_nigupdatestep(beta(ii-1,:),x(ii));
% 	[mu(ii),var(ii)]	= pa_nigmuvar(beta(ii,:));
% end
%
% See also:
% http://en.wikipedia.org/wiki/Conjugate_prior
% http://www.cs.ubc.ca/~murphyk/Papers/bayesGauss.pdf

%% Prior
V		= beta(1);
m		= beta(2);
a		= beta(3);
b		= beta(4);

%% Posterior
Vu		= V+1;
mu		= (V*m+x)/Vu;
au		= a+1/2;
bu		= b+( m^2/V+x^2-mu^2/Vu )/2;
beta	= [Vu mu au bu];
