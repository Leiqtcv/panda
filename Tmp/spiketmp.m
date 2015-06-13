close all
clear all
clc

d = 'C:\DATA\Cortex\Joe\Joe67';
cd(d);
fname			= 'r_6701e1.src';
[data,cfg]		= pa_spk_readsrc(fname);
%%
pa_spk_wavepeaks(data)

%%
% Spike = SPKalignpeaks(data,1)

%% Clustering
spikes	= [data.spikewave]';
% spikes = spikes(1:2000,:);
nspike	= length(spikes);
mu		= mean(spikes);
k		= 1;
S = zeros(size(spikes,1),1);
dsp = 0;
for ii	= 1:nspike
	if mod(ii,100)==1
		ii
	end
	indx = 1:20;
	% 	for ii = 1
	if dsp
		figure(666)
		clf
	end
	sw = spikes(ii,:);
	x = 1:length(sw);
	[XC,lag] = xcorr(mu,sw,5,'coef');
	[mx,lagindx] = max(XC);
	lagindx = lag(lagindx);
	
	if dsp
		subplot(222)
		plot(lag,XC,'k.-');
		pa_verline;
		pa_verline(lagindx,'r');
	end
	%% KALMANF
	if k
		s = [];
		% Define the system as a constant of 0 deg:
		s.x = 0;
		s.A = 1;
		% Define the brain to measure the location itself:
		s.H = 1;
		% Define a measurement error / sensory noise (stdev) of 15 deg:
		s.R = 5^2; % variance, hence stdev^2
		% Do not define any system input (control) functions:
		s.B = 0;
		s.u = 0;
		% Do not specify an initial state:
		s.x = nan;
		s.P = nan;
		s.K = NaN;
		% Generate random voltages and watch the filter operate.
		n	= length(sw);
		s.Q	= std(sw(20:end))^2;
		for t=1:n
			s(end).z		= sw(t); % create a measurement
			s(end+1)		= pa_kalman(s(end)); % perform a Kalman filter iteration
		end
		
			f = [s(2:end).x];
		if dsp
			subplot(221)
			plot(f,'g-','LineWidth',2);
			hold on
		end
	else
		f = sw;
	end
	
	if lagindx>0
		mu2 = mu([lagindx+1:end 1:lagindx]);
	elseif lagindx<0
		mu2 = mu([end+lagindx+1:end 1:end+lagindx]);
	else
		mu2 = mu;
		
	end
	
	b		= regstats(f(indx),mu2(indx),'linear','beta');
	mu2		= mu2*b.beta(2)+b.beta(1);
	d		= f(indx)-mu2(indx);
	sd		= std(d);
	
	if dsp
		subplot(221)
		plot(x,sw,'k-')
		hold on
		plot(x,mu2,'r-','LineWidth',2);
		plot(x,mu,'b-');
		
		
		% 	xlim([0 20]);
		ax = 2*[min(mu) max(mu)];
		ylim(ax);
		subplot(224)
		plot(f(indx),mu2(indx),'.');
		axis square
		pa_unityline;
		
		subplot(223)
		plot(d,'k-')
		title(sd)
		hold on
		
		ylim(ax);
		drawnow
		pause(.1)
	end
	if sd<5
	S(ii) = 1;
	end
end
sel = logical(S);
spikes2 = spikes;
spikes = spikes(sel,:);
% spikes = spikes2;

index	= 1:size(spikes,1);

save tst spikes index

wave_clus;
return
%%
figure
pa_spk_rasterplot(data);

[msdf,sdf]	= pa_spk_sdf(data);
sd			= std(sdf);
t			= 1:length(msdf);
mx			= max(msdf);
[m,n]		= size(sdf);

pa_errorpatch(t,0.7*m/mx*msdf,0.7*m/mx*sd,'r');


%%
figure
[XC,L,ISI] = pa_spk_corfun(data,'display',1);
