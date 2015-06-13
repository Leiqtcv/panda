function logit = pa_logit(p,varargin)
% LOGIT = PA_LOGIT(P)
%
% The logit function is the inverse logistic function:
% log(P/1-P) defined for 0<P<1
%
% Optional:
% LOGIT = PA_LOGIT(P,'minP',VALUE)
% Provide a mininum value for P to deviate from 0 and 1 (default: 1e-6)
%
% See also PA_LOGISTIC, PA_PROBIT

% 2013 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com


if any(~(p>0 & p<1))
	if any(p<0 | p>1); % values outside [0,1]
		msgid	= 'PandA:pa_logit:pInvalidValue';
		errmsg	= 'Please provide a valid p-value between 0 and 1';
		error(msgid,errmsg);
	else % values inside [0,1] -> set to (0,1)
		msgid	= 'PandA:pa_logit:ValueUndefinedAtP';
		errmsg	= 'P-values set between 0 and 1';
		% 		msg = '
		v = pa_keyval('minP',varargin);
		if isempty(v)
			v		= 1e-6; % small value
		end
		sel		= p<v;
		p(sel)	= v;
		sel		= p>1-v;
		p(sel)	= 1-v;
		warning(msgid,errmsg);
	end
end
logit = log(p./(1-p));
