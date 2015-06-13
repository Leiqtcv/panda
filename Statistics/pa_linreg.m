function stats = pa_linreg(X,y,B,varargin)
% PA_LINREG(X,y,B)
%
% Multiple linear regression of the form:
%  y = a+b1*X1 + b2*X2 + ... + bk*Xk
%
% Basically PA_LINREG performs REGSTATS, although significance and
% hypothesis testing of regression coefficients is performed on
% user-defined B.
%
% See also REGSATS

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

if nargin<3
	B = zeros(1,size(X,2)+1);
end
if size(B,1)>1
	B=B(:)';
end

if exist('regstats','file');
	meth=1;
else
	meth = 2;
	disp('- Sorry, you do not have the REGSTATS function of the statistics toolbox');
	disp('This function may produce an error');
end

switch meth
	case 1
		%% use regstats
		stats = regstats(y,X,'linear','all');
		%% Correct t and p-value
		t					= stats.tstat.beta-B'./stats.tstat.se;
		p					= 2*(tcdf(-abs(t), stats.tstat.dfe));
		%% Replace t and p-value in stats-structure
		stats.tstat.t		= t;
		stats.tstat.pval	= p;
		stats.tstat.beta0	= B;
		
	case 2 % DOES NOT WORK YET, INTENDED FOR THOSE THAT DO NOT HAVE STATISTICS TOOLBOX
		%% Add o to determine offset
		Z = ones(size(X,1),1);
		X = [X Z];
		
		%% Determine coefficients
		b		= (X\y)';
		
		[m,n]	= size(X);
		yhat	= X*b'; % average y
		e		= y - yhat; % error
		ssr		= e'*e; % residual sum of squares
		s2		= ssr/(m-n);
		
		
		%% Var/Cov Matrix of coeffs and std errors:
		Varb = s2*inv(X'*X);
		SEb = sqrt(diag(Varb))';
		% S=std(CB);
		
		%% Tests against a specific, user-supplied null (B) for each b individually
		t = (b-B)./(SEb);
		
		%% p-values for b=B, Since sigma is unknown beta is t-distributed
		p = (1-tcdf(abs(t),m-n))*2;
		
		stats.tstat.t		= t;
		stats.tstat.pval	= p;
		stats.tstat.beta	= b;
		stats.tstat.beta0	= B;
		stats.beta			= b;
end