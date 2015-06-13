%
% Overloaded function query: ret = query(A, str);
%
function [ret msg] = query(A, cmd)
    if (A.connected)
        rs232(1, cmd);
        pause(0.001);
        [s msg] = rs232(2, '');
        if (msg(0) == 0)
            ret = char(s);
        else
            error('Timeout');
            ret = '';
        end
    else
        error('Port not connected');
        ret = '';
    end

 