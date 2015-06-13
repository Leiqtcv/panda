%
% TDT3, 1 rack: RP2.1 en PA.5
%
circuitRP2 = 'C:\Dick\marcRipple.rco';
    
[zBus   err(1)] = ZBUS(1);              % number of racks
[RP2_1  err(2)] = RP2(1,circuitRP2);   
[PA5_1  err(3)] = PA5(1); 
RP2_1
ok = (sum(err) == 0);
%
% make sinus
%
maxSamples = 200000;        % TDT serial store source = 10^6
tone = zeros(1,maxSamples);
for i=1:maxSamples
    tone(i) = sin(2*pi*i/100);
end

%
% set attenuation
%
PA5_1.SetAtten(10);

for lp=1:10
%
disp('% load sound');
%
RP2_1.WriteTagV('WavData', 0, tone(1:maxSamples));
RP2_1.SetTagVal('WavCount',maxSamples-1);

%
% start sound
%
RP2_1.SoftTrg(1);

%
% do something useful
%
pause(2);
%
% stop sound
%
RP2_1.SetTagVal('WavCount',0);

%
% wait while busy
%
busy = RP2_1.GetTagVal('Busy');
cnt = 0;
while busy == 1
    cnt = cnt + 1;
    Busy = RP2_1.GetTagVal('Busy');
    fprintf('wait %3d\n',cnt);
end
%
%that's all
%
end