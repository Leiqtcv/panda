function [dPrime,beta,C] = pa_dprime(pHit,pFalse,Npresent,Nabsent)

%
% D = PA_DPRIME(PHIT,PFALSE)
% 
% Calculate d-prime from signal-detection theory. D-prime is a sensitivity measure.
%
% PHIT is the proportion of "Hits": P(Yes|Signal), PFALSE is the proportion
% of "False Alarms": P(Yes|Noise). PHIT and PFALSE values lie between
% 0 and 1.
%
% Optionally: D = PA_DPRIME(PHIT,PFALSE,TRIALPRESENT,TRIALABSENT)
% If PHIT equals 1, PHIT is set to 1-(1/2*TRIALPRESENT), or if PFALSE
% equals 0, PFALSE is set to 1/(2*TRIALSABSENT).
%
% [D,BETA,C] = PA_DPRIME(PHIT,PFALSE)
% 
% Additonal output of criterion values BETA and C can be given.
%
% This function requires MATLAB's Statistical Toolbox.
% See also NORMINV

% 2013 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization & Default settings
if nargin>2
	pMax = (Npresent-1)/Npresent;
	pMin = 1/Npresent;
	if pHit>pMax
		pHit = pMax;
	end
	if pHit<pMin
		pHit = pMin;
	end
end
if nargin>3
	pMax = (Nabsent-1)/Nabsent;
	pMin = 1/Nabsent;
	if pFalse>pMax
		pFalse = pMax;
	end
	if pFalse<pMin
		pFalse = pMin;
	end
end

%% Z scores
zHit	= norminv(pHit) ;
zFalse		= norminv(pFalse) ;

%% d-prime
dPrime	= zHit - zFalse ;

%% If requested, calculate BETA
if nargout==2
	beta	= exp((zFalse^2 - zHit^2)/2);
end

%% and C
if nargout==3
	C		= -.5 * (zHit + zFalse);
end
