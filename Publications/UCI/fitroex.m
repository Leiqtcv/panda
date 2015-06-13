function [yfit,varargout] = fitroex(xin,yin,CF,parstart)
%
%	[yfit,stats] = fitroex(xin,yin,CF,[parstart])
%	
%	See also fminsearch
%
%	INPUT:
%	xin	 =	frequency axis [Hz]
%	yin	 =	thresholds [dB SPL]
%	CF	 =	characteristic frequency [Hz]
%	parstart =	gain and bias starting values
%				default: [1 0]
%
%	OUTPUT:
%	yfit	 =	( 1 + p*g  ) .* exp( -p*g );
%	stats	 =	Optional. Returns a structure containing 
%				  R^2, SSR, SSE, N and coefficients in 'Coef'
%				  Coef(1) = p
%
%	See also: WH Hartmann "Signals, Sounds, and Sensation" Chapter 10 pp. 246-248

if nargin < 4
	parstart	=	0;
end

global X Y

X	=	abs( (xin-CF) ./ CF );	%-- Normalization of frequency axis --%
Y	=	yin;

% opt	=	optimset('Display','notify','LevenbergMarquardt','on','Simplex','off');
opt	=	optimset('Display','notify','Algorithm','levenberg-marquardt','Simplex','off'); %-- Edited the way L-M is implemented in R2012a --%
[par,~,exitflag,output]	=	fminsearch(@getmse,parstart,opt);

%-- Calculate fit --%
yfit	=	( 1 + par(1).*X  ) .* exp( -par(1).*X );

%--					Calculation: Correlation Coefficient					--%
%--		see http://mathworld.wolfram.com/CorrelationCoefficient.html		--%
SSR	=	sum ((yfit - mean(Y)).^2);			%-- Sum of squared residuals	--%
SSE	=	sum ((yfit - Y).^2);				%-- Sum of squared errors		--%
R2	=	( SSR / (SSE+SSR) )^(1/2);			%-- Correlation Coefficient R^2	--%

stats			=	struct('R2',R2,'SSR',SSR,'SSE',SSE,'N',length(Y),'Coef',par);
varargout(1)	=	{stats};

if( exitflag ~= 1 )
	disp(output.message)
end

return

%-- Calculate mse for, in this case, a line --%
function mse = getmse(p)

global X Y
y	=	( 1 + p(1).*X  ) .* exp( -p(1).*X );
mse	=	sum( (y-Y).^2);						%-- Squared error --%
   
return
