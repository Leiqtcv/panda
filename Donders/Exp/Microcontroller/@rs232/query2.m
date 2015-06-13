%
% query2: str = query(A, cmd);
%
function [str msg] = query2(A, cmd)
    if (A.connected)
        serialport(1, cmd);
        pause(0.001);
        [s msg] = serialport(2, '', A.timeout);
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

 