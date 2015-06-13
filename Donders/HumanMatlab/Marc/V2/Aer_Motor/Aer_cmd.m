%
% command
%
function [A msg] = Aer_cmd(A, cmd, arg)
    motor_globals;
    info(1) = get(A,'handle');
    info(2) = get(A,'speed');
    info(3) = get(A,'position');
    info(4) = get(A,'target');
    info(5) = get(A,'error');
    info(6) = get(A,'wait');
    info(7) = get(A,'busy');
    if (nargin == 2)
            switch cmd
                case {AerMoveHome,AerGetPosition,AerMoveTestDone}
                        [info msg] = Aer_motor(cmd, info);
                otherwise
                    msg(1) = -1;
                    msg(2) = -cmd;
            end
    else
        if (nargin == 3)
            switch cmd
                case AerInit
                        info(2) = arg(1);
                        [info msg] = Aer_motor(cmd, info);
                case AerMoveAbs
                        info(4) = arg(1);
                        [info msg] = Aer_motor(cmd, info);
                otherwise
                    msg(1) = -1;
                    msg(2) = -cmd;
            end
        else
            msg(1) = -2;
            msg(2) = -cmd;
        end
    end
    A = set(A,'handle',  info(1));
    A = set(A,'speed',   info(2));
    A = set(A,'position',info(3));
    A = set(A,'target',  info(4));
    A = set(A,'error',   info(5));
    A = set(A,'wait',    info(6));
    A = set(A,'busy',    info(7));
 
    
    