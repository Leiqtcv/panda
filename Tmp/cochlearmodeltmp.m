close all hidden;
clear all hidden;
clc;

% fs = 50000;
% numChannels = 8;

fcoefs = MakeERBFilters(16000,10,100);

y = ERBFilterBank([1 zeros(1,511)], fcoefs);
resp = 20*log10(abs(fft(y')));
freqScale = (0:511)/512*16000;
semilogx(freqScale(1:255),resp(1:255,:));
axis([100 16000 -60 0])
xlabel('Frequency (Hz)');
ylabel('Filter Response (dB)');

figure(2)
Fs		= 15000;
% Fs = 48828
nchan	= round(log2(Fs/2/100)*3); % 1/3
fcoefs	= MakeERBFilters(Fs,nchan,100);
Freq	= pa_oct2bw(100,(0:nchan-1)/3);
rip		= pa_genripple(0,-1/3,100,1000,500,'freq',Fs,'meth','fft');
coch	= ERBFilterBank(rip, fcoefs);
t		= (0:length(coch)-1)./Fs*1000;

for ii	= 1:size(coch,1)
	c	= max(coch(ii,:),0);
	c	= filter(1,[1 -.99],c);
	coch(ii,:) = pa_runavg(c,1000);
% 		coch(ii,:) = c;

% if ii<20
% 	subplot(122)
% 	hold on
% 	plot(t,coch(ii,:)+ii,'k-');
% end
end
subplot(121)
imagesc(t,Freq,coch);
axis square;
set(gca,'YDir','normal');
colorbar
% ylim([0 10000]);
subplot(122)
plot(t,coch,'-');

axis square;

pa_verline(500);