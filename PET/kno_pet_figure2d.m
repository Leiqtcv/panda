function tmp
close all

cd('E:\Backup\anonPET');

%%
% file='kortstim.mp4';
% file1='vipmen1.wav'; %o/p file name
% info = mmfileinfo(file)
% audio = info.Audio
% video = info.Video
% 
% hmfr=video.MultimediaFileReader(file,'AudioOutputPort',true,'VideoOutputPort',false);
%  hmfw = video.MultimediaFileWriter(file1,'AudioInputPort',true,'FileFormat','WAV');
%  
%  keyboard
%% Video
fname = 'kortstim.mp4';
obj = VideoReader(fname);
cdata = read(obj,1);
imagesc(cdata)
axis equal
axis off
print('-dpng','-r600',mfilename);


% get(obj)
% info = mmfileinfo(fname)
% videoFReader = vision.VideoFileReader('kortstim.mp4','AudioOutputPort',true);
% videoPlayer = vision.VideoPlayer;

fname = pa_fcheckext(fname,'wav');
[y,fs] = wavread(fname);

n = length(y);
t = (0:(n-1))/fs;

figure
subplot(211)
plot(t,y(:,1),'k-');
box off
xlim([0 max(t)]);
set(gca,'TickDir','out');


pa_plotspec(y(:,1),fs);
xlim([0 max(t)]);
set(gca,'TickDir','out');

print('-depsc','-painter',mfilename);



function pa_plotspec(snd,Fs)
% PA_PLOTSPEC(SND,FS)
% close all;
T = (1:length(snd))/Fs;

subplot(212)
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