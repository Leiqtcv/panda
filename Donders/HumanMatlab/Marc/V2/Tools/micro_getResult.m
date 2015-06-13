%
function [result msg] = micro_getResult(A)
    micro_globals;
    [res cnt] = micro_getValues(A, cmdSaveTrial, '');
    if (cnt == 3)
        [result msg] = serialport(6, [res(1) res(2) res(3)]);
    else
        msg(1) = -5;
    end
end
