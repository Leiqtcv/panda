close all
clear all
pa_datadir

freq = 1:15; % kHz
nfreq = numel(freq);
for ii = 1:nfreq
	snd = [];
snd = pa_gentone(freq(ii)*1000,1000*10);
snd = pa_ramp(snd);
snd = pa_fart_levelramp(snd);
if ii<10
fname = ['snd10' num2str(ii)]
else
fname = ['snd1' num2str(ii)]
end
pa_writewav(snd,fname);
plot(snd)
% pause
end

