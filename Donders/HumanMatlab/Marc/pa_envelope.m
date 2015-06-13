function X = pa_envelope(X, N)
% PA_ENVELOPE(X,N)
%
% Smooth on- and offset (N samples) of signal X.
%
% PA_ENVELOPE(SIG, NENV)
%

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com


XLen = size(X,1);
if (XLen < 2*N)
	error('pandaToolbox:DSP:EnvelopeTooLong','Envelope length greater than signal');
else
	EnvOn	= sin(0.5*pi*(0:N)/N).^2;
	EnvOff	= fliplr(EnvOn);
	head	= 1:(N+1);
	tail	= (XLen-N):XLen;
	for i = 1:size(X,2)
		X(head,i) = EnvOn'.*X(head,i);
		X(tail,i) = EnvOff'.*X(tail,i);
	end;
end;
