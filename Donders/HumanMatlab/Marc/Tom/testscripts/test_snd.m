RP2_1circuit = 'D:\HumanMatlab\V1\RCO&RPX\MatlabV1_tomsnd_rp2_varfilename.rco';
RP2_2circuit = 'D:\HumanMatlab\V1\RCO&RPX\MatlabV1_tomsnd_rp2_varfilename.rco';

%% Initialize
HumanInit
H = findobj('Tag','ActXWin');
figure(H)
zBus  = actxcontrol('zBus.x',[341 101 20 20]); % trigger
%%
type    = 'GWN';
Dur     = 150;
Filter  = [200 20000];
Y = genstim(type,Dur,Filter,Env,zeropad,Fs,FLAG_Play)
