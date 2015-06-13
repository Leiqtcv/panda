function [str msg] = micro_NNSim(com,id)
    micro_globals;
    str = sprintf('$%d;%d',cmdNNSim,id);
    msg(2) = 0;
    [str msg] = query2(com, str);
