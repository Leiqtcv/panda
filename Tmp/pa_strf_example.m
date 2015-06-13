close all
clear all
clc

pa_genripple(4,0,100,1000,500,'display',1);

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

print('-depsc','pa_strf_raster');

s = pa_spk_sdf(spike,'Fs',1000);

figure
plot(s,'k-','LineWidth',2)
xlabel('Time (ms)');
ylabel('Spike density (Hz)');

data = pa_spk_ripple2strf(spike,'shift',1);




pa_spk_plotstrf(data);
figure(200)
col = pa_statcolor(64,[],[],[],'def',8,'disp',false);
set(gca,'XTick',0:20:100,'YTick',0:0.5:2.5);
	
print('-depsc','-painter',[mfilename 'rgb']);

colormap(col);
print('-depsc','-painter',[mfilename 'hcl']);

