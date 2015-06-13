function [ints,cnt] = pa_micro_getvalues(A,cmd,arg)
% [N, CNT] = PA_MICRO_GETVALUES(COM,CMD,ARG)
%
%

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com

[str,msg] = pa_micro_cmd(A,cmd,arg);
if (msg(1) == 0)
    [ints cnt] = sscanf(str, '%d');
else
    ints = 0;
    cnt  = -1;
end


