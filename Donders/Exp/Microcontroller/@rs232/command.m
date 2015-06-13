%
function [ret msg] = command(A, cmd, timeout)
     if (A.connected)
        [s msg] = query2(A, cmd);
%         [s msg] = serialport(1, cmd);
%        if (msg(1) == 0)
%             pause(0.001);
%            [s msg] = serialport(2, '', timeout);
            if (msg(1) == 0)
                ret = char(s);
            else
                % Read serial port, timeout
                ret = '';
            end
%         else
%             % Write serial port
%         end
     else
        % Port not connected
        ret = '';
        msg(1) = -1;
    end

 