close all

pa_datadir;
hdr   = ft_read_header('p029_sort_final_01.nex');
spike = ft_read_spike('p029_sort_final_01.nex');
cfg              = [];
cfg.spikechannel = {'sig002a_wf', 'sig003a_wf'}; % select only the two single units
spike = ft_spike_select(cfg, spike);


cfg             = [];
cfg.fsample     = 40000;
cfg.interpolate = 1; % keep the density of samples as is
[wave, spikeCleaned] = ft_spike_waveform(cfg,spike);

for k = [1 2]
	figure(k)
	sel = squeeze(wave.dof(k,:,:))>1000; % only keep samples with enough spikes
	plot(wave.time(sel), squeeze(wave.avg(k,:,sel)),'k') % factor 10^6 to get microseconds
	hold on
	
	% plot the standard deviation
	plot(wave.time(sel), squeeze(wave.avg(k,:,sel))+sqrt(squeeze(wave.var(k,:,sel))),'k--')
	plot(wave.time(sel), squeeze(wave.avg(k,:,sel))-sqrt(squeeze(wave.var(k,:,sel))),'k--')
	
	axis tight
	set(gca,'Box', 'off')
	xlabel('time')
	ylabel('normalized voltage')
end

event = ft_read_event('p029_sort_final_01.nex');

cfg          = []; 
cfg.dataset  = 'p029_sort_final_01.nex';
cfg.trialfun = 'trialfun_stimon';
cfg = ft_definetrial(cfg);

cfg.timestampspersecond =  spike.hdr.FileHeader.Frequency; % 40000
spikeTrials = ft_spike_maketrials(cfg,spike);  

cfg                     = [];
hdr                     = ft_read_header('p029_sort_final_01.nex');
cfg.trl                 = [0 hdr.nSamples*hdr.TimeStampPerSample 0];
cfg.timestampspersecond =  spike.hdr.FileHeader.Frequency; % 40000
spike_notrials   = ft_spike_maketrials(cfg,spike); 

cfg       = [];
cfg.bins  = [0:0.0005:0.1]; % use bins of 0.5 milliseconds
cfg.param = 'coeffvar'; % compute the coefficient of variation (sd/mn of isis)
isih = ft_spike_isi(cfg,spikeTrials);

for k = [1 2] % only do for the single units
  cfg              = [];
  cfg.spikechannel = isih.label{k};
  cfg.interpolate  = 5; % interpolate at 5 times the original density
  cfg.window       = 'gausswin'; % use a gaussian window to smooth
  cfg.winlen       = 0.004; % the window by which we smooth has size 4 by 4 ms
  cfg.colormap     = jet(300); % colormap
  cfg.scatter      = 'no'; % do not plot the individual isis per spike as scatters
  figure, ft_spike_plot_isireturn(cfg,isih)
end
%%
cd('E:\DATA\Cortex\Original Dataset\JoeData\Joe67experiment');
fname = 'joe6707c01b00.src';
spike2					= ft_read_spike(fname);
% cfg              = [];
% cfg.spikechannel = {'sig002a_wf', 'sig003a_wf'}; % select only the two single units
% spike = ft_spike_select(cfg, spike);

cfg						= [];
cfg.fsample				= 48828.125;
cfg.interpolate			= 2; % keep the density of samples as is
[wave2, spikeCleaned2]	= ft_spike_waveform(cfg,spike2);

k = 1;

figure(3)
subplot(121)
sel = squeeze(wave2.dof(k,:,:))>1000; % only keep samples with enough spikes
t	= wave2.time(sel)*1e6;
mu	=  squeeze(wave2.avg(k,:,sel));
sd = sqrt(squeeze(wave2.var(k,:,sel)));
plot(t,mu,'k-') % factor 10^6 to get microseconds
hold on

pa_errorpatch(t,mu,sd);
% plot the standard deviation

axis square
axis tight
set(gca,'Box','off','TickDir','out')
xlabel('Time (\mus)')
ylabel('normalized voltage')

event2 = ft_read_event(fname);

%%
cfg          = []; 
cfg.dataset  = fname;
cfg.trialfun = 'trialfun_stimon';
cfg = ft_definetrial(cfg);


