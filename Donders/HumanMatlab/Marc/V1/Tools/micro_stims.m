%
%
%
function [str msg] = micro_stims(A,nStim,stims)
    data = '';
    for n=1:nStim
        stim = micro_stim(stims(n));
        data = strvcat(data, stim);
    end
    [str msg] = serialport(5, data, get(A,'timeout'));
