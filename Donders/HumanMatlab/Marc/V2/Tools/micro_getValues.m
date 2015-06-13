function [ints cnt] = micro_getValues(A, cmd, arg)

[str msg] = micro_cmd(A, cmd, arg);

if (msg(1) == 0)
    [ints cnt] = sscanf(str, '%d');
else
    ints = 0;
    cnt  = -1;
end


