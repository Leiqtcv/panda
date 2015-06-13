function beta = pa_fitprior(Sigma,Slope,varargin)
% P = PA_FITPRIOR(SIGMA,SLOPE)
%
% Fit prior-variance (thorugh NLINFIT), predicted by (near)-optimal
% (bayesian) models, on localization response parameters SIGMA and SLOPE.
% SIGMA and SLOPE are usually acquired through linear regression on
% stimulus-response relations (e.g. PA_LOC, PA_PLOTLOC).
%
% A common SIGMA-SLOPE relationship is parabolic, with the prior's variance
% as free parameter (posterior-matching, e.g Van Wanrooij et al, 2012?).
%
% [BETA,SE,XI] = PA_WEIGHTEDREGRESS(...,'BETA0',BETA0)
% Optionally, you can provide the initial value for the prior variance
% coefficient (default: 10).
%
% See also NLINFIT, PA_LOC, PA_PLOTLOC

% (c) 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@neural-code.com


%% Initial prior
beta0         = pa_keyval('beta0',varargin);
if isempty(beta0)
    beta0 = 10; 
end

options		= statset('Robust','on');
beta		= nlinfit(Sigma,Slope,@pa_invparabolefun,beta0,options);
