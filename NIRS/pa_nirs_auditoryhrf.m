function tmp
close all

cd('E:\MATLAB\PANDA\NIRS\Story (audio only)');

fname = '002.wav';
chan = 1;
fname = pa_fcheckext(fname,'wav');
[y,fs] = wavread(fname);

n = length(y);
t = (0:(n-1))/fs;
X = hilbert(y(:,chan));
X = 1.7*smooth(abs(X),1000);

figure
subplot(311)
plot(t,y(:,chan),'k-');
hold on
plot(t,X,'r-','LineWidth',2);
box off
xlim([0 max(t)]);
set(gca,'TickDir','out');

fd		= 10;
R		= fs/fd;
Xd		= decimate(X,R);
audhdr	= pa_nirs_hdrfunction(0.5,Xd);
subplot(313)
t = 1:length(Xd);
t = t/fd;
plot(t,Xd,'k-');
hold on
plot(t,audhdr,'r-');


% return
pa_plotspec(y(:,1),fs);
xlim([0 max(t)]);
set(gca,'TickDir','out');

print('-depsc','-painter',mfilename);


function pa_plotspec(snd,Fs)
% PA_PLOTSPEC(SND,FS)
% close all;
T = (1:length(snd))/Fs;

subplot(312)
nsamples	= length(snd);
t			= nsamples/Fs*1000;
dt			= 12.5;
nseg		= t/dt;
segsamples	= round(nsamples/nseg); % 12.5 ms * 50 kHz = 625 samples
noverlap	= round(0.6*segsamples); % 1/3 overlap
window		= segsamples+noverlap; % window size
nfft		= 1000;
spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');
% axis square;
% colorbar
cax = caxis;
caxis([0.7*cax(1) 1.1*cax(2)])
set(gca,'YTick',[1:8]*1000);
set(gca,'YTickLabel',[1:8]);
% set(gca,'YScale','log');
xlim([min(T) max(T)]);
ylim([500 8000]);
drawnow
xlabel('Time (s)');
ylabel('Frequency (kHz)');

box off
% colorbar
caxis([-95 -35])

col = colormap('gray');
col = 1-col;
colormap(col)



% linkaxes(ax,'x');