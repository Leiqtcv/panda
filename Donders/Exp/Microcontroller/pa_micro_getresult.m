function [result,msg] = pa_micro_getresult(A)
% [RESULT,MSG] = PA_MICRO_GETRESULT(COM)
%
%

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com

pa_micro_globals;
[res cnt] = pa_micro_getvalues(A, cmdSaveTrial, '');
if (cnt == 3)
	[result msg] = serialport(6, [res(1) res(2) res(3)]);
else
	msg(1) = -5;
end

