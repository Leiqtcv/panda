function [str, msg] = pa_micro_cmd(A, cmd, arg)
% [STR, MSG] = PA_MICRO_CMD(A,CMD,ARG)
%
% Give a command to the microcontroller.
%
% See also PA_MICRO_QUERY

% Dick Heeren
% 2013 Marc van Wanrooij

if (isempty(cmd))
	[str, msg] = pa_micro_query(A, sprintf(''));
else
	if (isempty(arg))
		CMD = sprintf('$%d',cmd);
	else
		CMD = sprintf('$%d;%s',cmd,arg);
	end
	[str, msg] = pa_micro_query(A, CMD);
end
