close all
clear all
clc


%%
cd('E:\DATA\Test'); % go to data-directory
% load('test.mat')
% whos
% spike = spikep;
% spike = rmfield(spike,'spikewave');
% save examplecell spike;
load('examplecell'); % load data



figure
%% pa_spk_rasterplot(spike);
Ntrials		= length(spike); % Number of trials
Fs			= 1000; % Sampling frequency (Hz)
hold on;
for ii = 1:Ntrials % loop through every trial
	t = spike(ii).spiketime;	% determine spike timings (sample number) for each trial
	t = t/Fs*1000;				% spike times in (ms)
	for jj = 1:length(t) % and plot a line whenever a spike occurs
		line([t(jj) t(jj)],[ii-1 ii],'Color','k'); % at every trial line
	end
end
% Ticks and labels
ylim([0 Ntrials]);
set(gca,'TickDir','out');
xlabel('Time (ms)');
ylabel('Trial #');


% print('-depsc','pa_strf_raster');
% 
[s,sdf] = pa_spk_sdf(spike,'Fs',1000,'kernel','EPSP');

figure
subplot(211)
imagesc(sdf)

indx = 26;

y = sdf(26:29,:);
y = sum(y);
y = y./max(abs(y));

y = zeros(1,2500);
t = ceil([spike(indx:indx+1).spiketime]);
t
y(t) = 1;

Fs = 44100;
Y = resample(y,Fs,1000);
Y = Y./max(abs(Y));
% Y = Y/(2*std(Y));
v = spike(indx).stimvalues(5)
d = spike(indx).stimvalues(6)


[snd,ripFs] = pa_genripple(v,d,100,1000,500,'display',1);
z = round(zeros(1,300*ripFs/1000));
snd = [z snd];

z = round(zeros(1,700*ripFs/1000));
snd = [snd z];
SND = resample(snd,Fs,round(ripFs));
SND = SND./(10*max(SND));
whos SND Y
SND = SND(1:length(Y));
W = [Y; SND];
whos W
subplot(212)
plot(Y)
% wavplay(W',Fs)
wavplay(Y,Fs)

% snd = snd./(5*max(abs(snd)));
% wavplay(snd,ripFs);
% wavplay(y,1000)
% 
% figure
% plot(s,'k-','LineWidth',2)
% xlabel('Time (ms)');
% ylabel('Spike density (Hz)');
% 
% data = pa_spk_ripple2strf(spike,'shift',0);
% 
% pa_spk_plotstrf(data);