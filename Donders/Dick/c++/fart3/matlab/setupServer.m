%=========================================================================
%                           Setup connection
%=========================================================================
function err = setupServer(data)
    out(1) = 2;
    out(2) = data.Globals.TCPinit;
    result = mexServer(out);
    if (result == data.Globals.TCPinit)
        err = 0;
    else
        err = -1;   % error
    end
    if (result > 0)
        out(1) = 2;
        out(2) = data.Globals.TCPquery;
        result = mexServer(out);
        if (result == data.Globals.TCPquery)
            err = 0;
        else
            err = -1;   % error
        end
    end
end

