function Spike = SPKseparateclus(Spike,clus)
% SPKPLOTPEAKS(SPK)
%
% Plot two spike peaks against each other in BrainWare style
%

% (c) Marc van Wanrooij 2010
if nargin<2
	clus = 1;
end

for ii		= 1:length(Spike)
	cl		= Spike(ii).cluster;
	sel		= cl == clus;

	Spike(ii).cluster = cl(sel);
	
	tmp		= Spike(ii).spikewave;
	Spike(ii).spikewave = tmp(:,sel);
	
	tmp		= Spike(ii).spiketime;
	Spike(ii).spiketime = tmp(:,sel);

	tmp =	 Spike(ii).trial;
	Spike(ii).trial = tmp(:,sel);
end
