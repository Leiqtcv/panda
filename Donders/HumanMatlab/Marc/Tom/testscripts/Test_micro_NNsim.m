close all
clear all
fclose all;
HeadCalNetFile  = 'D:\HumanMatlab\Tom\NET\headcoil.net';
HumanInit
%%
str = micro_cmd(com,cmdADC,'');
vec = str2num(str);
fprintf('%s\n',str);

[str msg] = micro_NNSim(com,-1);fprintf('-1: %s\n',str);
[str msg] = micro_NNSim(com,0);fprintf(' 0: %s\n',str);
[str msg] = micro_NNSim(com,1);fprintf(' 1: %s\n',str);
[str msg] = micro_NNSim(com,2);fprintf(' 2: %s\n',str);
[str msg] = micro_NNSim(com,3);fprintf(' 3: %s\n',str);
[str msg] = micro_NNSim(com,4);fprintf(' 4: %s\n',str);