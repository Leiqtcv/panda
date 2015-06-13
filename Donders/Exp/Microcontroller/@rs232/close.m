%
% disconnect serial port com1
%
function A = close(A)
    if (A.connected)
        [x msg] = serialport(9,'');
        A.connected = false;
    else
        msg(1) = -1;
    end