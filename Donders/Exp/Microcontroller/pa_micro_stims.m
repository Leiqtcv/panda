function [str,msg] = pa_micro_stims(A,nStim,stims)
% [STR,MSG] = PA_MICRO_STIMS(COM,NSTIM,STIMS)
%
% Send NSTIM multiple command arguments STIMS via the computer serial port
% COM, and store in microcontroller. 
%
% See also PA_MICRO_GLOBALS, PA_MICRO_STIM, RS232, PA_MICRO_INIT

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com


data = '';
for n=1:nStim
	stim = micro_stim(stims(n));
	data = strvcat(data, stim);
end
[str msg] = serialport(5, data, get(A,'timeout'));
