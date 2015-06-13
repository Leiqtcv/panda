close all
clear all
clc
% Fs = 50000;
% dur = 10;
% nfft = 2^10;
% Fs = nfft/dur;
% x = linspace(0,10,nfft);
% y = 4*sin(2*pi*x);
% plot(x,y);
%
% figure
% pa_getpower(y,Fs,'display',1);
x= linspace(0,4,7);
freq = pa_oct2bw(700,x);


% freq = freq/1000;
subplot(221)
plot(freq/1000,'o-')
pa_horline(4)
pa_horline(2)

subplot(222)
plot(freq/1000,'o-')
pa_horline(4)
pa_horline(2)

loc = [-60:15:-15 15:15:60];
numel(loc)
Truns = numel(loc)*20
Pruns = numel(loc)*numel(freq)*3
Aruns = numel(loc)*numel(freq)*3

nfreq = numel(freq);
for ii = 1:nfreq
	Fs          = 48828.125; % Hz
	dur = 0.150;
	N = round(dur*Fs);
	NEnvelope = 250;
	order = 100;
	f = pa_oct2bw(freq(ii),[-1/3 1/3]);
	Fc = f(2);
	Fh = f(1);
	% N, NEnvelope, order, Fc, Fn, Fh, grph
	% figure
	gwn = pa_gengwn(N, NEnvelope, order, Fc, Fs/2, Fh,1);
	Nzero = zeros(1,978); %This will create a vector with 978 zeros
	gwn = [Nzero gwn]; %#ok<AGROW> %This “prepends” the zerovector to the Noise
	pa_datadir;
	fname = ['snd00' num2str(ii)];
	pa_writewav(gwn,fname)
end

Fs          = 48828.125; % Hz
dur = 0.150;
N = round(dur*Fs);
NEnvelope = 250;
order = 100;
% 	f = pa_oct2bw(freq(ii),[-1/3 1/3]);
Fc = 20000;
Fh = 500;
% N, NEnvelope, order, Fc, Fn, Fh, grph
% figure
gwn = pa_gengwn(N, NEnvelope, order, Fc, Fs/2, Fh,1);
Nzero = zeros(1,978); %This will create a vector with 978 zeros
gwn = [Nzero gwn]; %This “prepends” the zerovector to the Noise
pa_datadir;
fname = ['snd00' num2str(8)];
pa_writewav(gwn,fname)