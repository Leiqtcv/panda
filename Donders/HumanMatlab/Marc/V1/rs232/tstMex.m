%
%
%
micro_globals;
sLF = sprintf('\n');
%
%   reset, time out = 1000, baudrate = 115200
%
% [rsp msg] = rs232(0, [1000 115200]);
[rsp msg] = rs232(0, '');

str = sprintf('$%d',cmdReset);
[rsp msg] = query1(str);
str = sprintf('$%d',cmdInfo);
[rsp msg] = query1(str);
disp(rsp);
timeouts = 0;
    tic
for (i=1:100)
    str = sprintf('$%d',cmdSaveTrial);
    nError = 0;
    disp('========================================');
    [rsp msg] = query1(str);
    a = sscanf(rsp,'%d');
    s = size(a);
    if (s(1) == 3)
        str = sprintf('nStim=%d, T_ITI=%d, T_trial=%d',a(1),a(2),a(3));
        disp(str);
    else
        error = 'Missing values';
        nError = -1;
    end
    for (n=1:5)
        [rsp msg] = micro_getValues('', '');
        data(n,:) = rsp;
    end
%    [rsp msg] = micro_getValues('', '');
    disp(data);
    if (nError < 0)
        disp('****************************************');
        disp(error);
        pause(1);
    end
end
    toc
[rsp msg] = rs232(9,'');