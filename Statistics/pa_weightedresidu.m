function [betai,sei,SDi,SCI95i,XI] = pa_weightedresidu(X,Y,Z,sigma,XI,varargin)
% [BETA,BETASD,SD,SDCI,XI] = PA_WEIGHTEDRESIDU(X,Y,Z,SIGMA,XI)
%
% Perform weighted regression (pa_weightedregress) and obtain 95%
% confidence intervals of the standard deviation of the residuals, through
% bootstrapping.
%
% Why would you ever want this?
% For example, this analysis is important in localization/targeting/aiming
% behavior. The slope (gain/BETA) tells you something about accuracy (are
% you on target on average?), while the standard deviation (SD) tells you
% something about precision (do you repeat the same/similar responses?).
% When you estimate these response parameters, you are probably also
% interested in the confidence of these estimates (BETASD, SDCI). 
%
% [BETA,BETASD,SD,SDCI,XI] = PA_WEIGHTEDRESIDU(...,'NBOOT',NBOOT)
% Optionally, you can provide the number of bootstrap samples NBOOT
% (default = 1000).
%
% Other optional inputs are as for PA_WEIGHTEDREGRESS
%
% See also PA_WEIGHTEDREGRESS, BOOTSTRP

% (c) 2011-04-26 Marc van Wanrooij
% E-mail: marcvanwanrooij@neural-code.com
% To do: change sd of gain to CI

%% Check input
if size(X,2)>1
    X=X';
    if size(X,2)>1
        error('X should be a vector');
    end
end
mx = size(X,1);
[m,n] = size(Y); % n = number of indepedent variables
if m~=mx
    Y = Y';
    [m,n] = size(Y); %#ok<ASGLU> % n = number of indepedent variables
end
if size(Z,2)>1
    Z   = Z';
    if size(Z,2)>1
        error('Z should be a vector');
    end
end
if nargin<5 % Set a default
    XI = linspace(min(X),max(X),20);
end
if size(XI,2)>1
    XI=XI';
    if size(XI,2)>1
        error('X should be a vector');
    end
end
%% Optional, undocumented type of fit:
% simple regression (default) or a robust fitting procedure
fittype         = pa_keyval('fittype',varargin);
if isempty(fittype)
    fittype = 'regstats';
end
wfun         = pa_keyval('wfun',varargin);
if isempty(wfun)
    wfun = 'gaussian';
end
nbin        = pa_keyval('nbin',varargin);
if isempty(nbin)
    nbin = 0;
end
etyp         = pa_keyval('etyp',varargin);
if isempty(etyp)
    etyp = 'analytic';
end
nboot         = pa_keyval('nboot',varargin);
if isempty(nboot)
    nboot = 1000;
end

%% Regression
[betai,sei,XI] = pa_weightedregress(X,Y,Z,sigma,XI,'fittype',fittype,'wfun',wfun,'nbin',nbin,'etyp',etyp);

%% Residuals
sel = isnan(betai);
g	= interp1(XI(~sel),betai(~sel),X,'linear','extrap');
Res = Z - g.*Y;

SD		=  NaN(length(XI),1);
SCI95	=  NaN(length(XI),2);
for ii   = 1:length(XI)
    SD(ii)		= getsd(Res,X,XI(ii),sigma);
	s			= bootstrp(nboot, @getsd ,Res,X,XI(ii),sigma);
	SCI95(ii,:) = prctile(s,[2.5 97.5]);
end


%% remove nans
% NaNs screw up interpolation
sel		= ~isnan(SD);
beta	= betai(sel,:);
se		= sei(sel,:);
SD		= SD(sel);
SCI95	= SCI95(sel,:);
xi		= XI(sel);

%% interpolate at XI
if numel(xi)>1 % to interpolate you should have at least 2 data points
    betai	= NaN(length(XI),size(beta,2));
    sei		= betai;
	
	for ii	= 1:size(beta,2)
		whos SCI95 xi SD XI
		
		betai(:,ii) = interp1(xi,beta(:,ii),XI,'linear');
		sei(:,ii)	= interp1(xi,se(:,ii),XI,'linear');
		
	end
	SDi	= interp1(xi,SD,XI,'linear');
	SCI95i(:,1)	= interp1(xi,SCI95(:,1),XI,'linear');
	SCI95i(:,2)	= interp1(xi,SCI95(:,2),XI,'linear');
else % Create some NaNs
    xi = XI;
    betai	= zeros(length(XI),size(beta,2));
    sei		= betai;
    SDi		= betai;
    SCI95i		= betai;
    
end

function S = getsd(X,T,cntr,rng)

w	= normpdf(T,cntr,rng);
sw	= sum(w);
V	= 0;
for k	= 1:length(X)
    V	= V+w(k)*(X(k))^2;
end
S		= sqrt(V/sw);
