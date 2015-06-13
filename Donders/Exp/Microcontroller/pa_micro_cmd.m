function [str, msg] = pa_micro_cmd(A, cmd, arg)
% [STR, MSG] = PA_MICRO_CMD(COM,CMD,ARG)
%
% Communicate with / send command CMD to the microcontroller via the RS232
% computer serial port COM, with additional arguments ARG.
%
% See also PA_MICRO_GLOBALS, PA_MICRO_STIM, RS232

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com

if (isempty(cmd))
    [str msg] = query2(A, sprintf(''));
else
    if (isempty(arg))
        CMD = sprintf('$%d',cmd);
    else
        CMD = sprintf('$%d;%s',cmd,arg);
    end
    [str msg] = query2(A, CMD);
end
