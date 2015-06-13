function [muy,sdy,ux] = pa_ygivenx(x,y,varargin)
% [MU,SD,UX] = PA_YGIVENX(X,Y)
%
% Determine mean MU and standard deviation SD of Y for every unique value
% UX of X

% 2013 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
var = pa_keyval('var',varargin);
if isempty(var)
	var = 'std';
end

%% Analyze
x	= round(x); % for Matlab-precision purposes it is best to round some
ux	= unique(x); % unique values of x
nx	= numel(ux); % number of unique values of x

%% And loop
muy = NaN(nx,1); % initialization of vector containing mean y
sdy = muy;
for ii = 1:nx
	sel = x==ux(ii);
	muy(ii) = mean(y(sel));
	sdy(ii) = std(y(sel));
	switch var
		case 'std'
			% do nothing
		case 'se' % standard error = sd/sqrt(N)
			sdy(ii) = sdy(ii)./sqrt(sum(sel));
		case 'ci' % needs to be fixed, for now 1.96*se, only holds for large N
			sdy(ii) = 1.96*sdy(ii)./sqrt(sum(sel));
	end
end


