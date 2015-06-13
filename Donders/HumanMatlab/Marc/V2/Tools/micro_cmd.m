function [str msg] = micro_cmd(A, cmd, arg)

if (isempty(cmd))
    [str msg] = query2(A, sprintf(''));
else
    if (isempty(arg))
        CMD = sprintf('$%d',cmd);
    else
        CMD = sprintf('$%d;%s',cmd,arg);
    end
    [str msg] = query2(A, CMD);
end
