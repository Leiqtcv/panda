%% Speaker on
arg1 = sprintf('%d;%d;1',speaker1,stimSnd1); % 1 - speaker on
arg2 = sprintf('%d;%d;1',speaker2,stimSnd2); % 1 - speaker on
RP2_1.SetTagVal('Level',level1);
RP2_2.SetTagVal('Level',level2);
a = micro_cmd(com,cmdSpeaker,arg1);
a = micro_cmd(com,cmdSpeaker,arg2);
%[RP2_1.GetTagVal('Level') RP2_2.GetTagVal('Level')]
%% start sound
% start Acq
zBus.zBusTrigB(0,1,4);
% start sound
zBus.zBusTrigA(0,0,0);
%%	Deselect speaker and set gain = 0
busy1 = RP2_1.GetTagVal('Play');
busy2 = RP2_2.GetTagVal('Play');
busy = any([busy1 busy2]);
while busy
busy1 = RP2_1.GetTagVal('Play');
busy2 = RP2_2.GetTagVal('Play');
busy = any([busy1 busy2]);
end
RP2_1.SetTagVal('Level',0);
RP2_2.SetTagVal('Level',0);
arg1 = sprintf('%d;%d;0',speaker1,stimSnd1); % 0 - speaker off
arg2 = sprintf('%d;%d;0',speaker2,stimSnd2); % 0 - speaker off
a = micro_cmd(com,cmdSpeaker,arg1);
a = micro_cmd(com,cmdSpeaker,arg2);
