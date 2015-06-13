function [str, msg] = pa_query(A, cmd)
% [STR,MSG] = PA_QUERY(A,CMD)
%
% See also PA_MICRO_CMD

% Dick Heeren
% 2013 Marc van Wanrooij
if (A.connected)
	serialport(1, cmd);
	pause(0.001);
	[s, msg] = serialport(2, '', A.timeout);
	if (msg(1) == 0)
		str = char(s);
	else
		% Timeout
		str = '';
		msg(1) = -1;
	end
else
	% Port not connected
	str = '';
	msg(1) = -1;
end

