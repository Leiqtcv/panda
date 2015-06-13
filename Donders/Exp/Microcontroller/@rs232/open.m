%
% open serial port com1
%
function A = open(A)
    if (~A.connected)
        serialport(0,[A.baudrate,A.timeout]);
        A.connected = true;
    else
        error('Port already connected');
    end
