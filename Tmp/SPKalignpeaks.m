function Spike = SPKalignpeaks(Spike,GraphFlag)
% SPKPLOTPEAKS(SPK)
%
% Plot two spike peaks against each other in BrainWare style
%
% (c) Marc van Wanrooij 2010

if nargin<2
	GraphFlag = 1;
end

spikes			= [Spike.spikewave];
trial			= [Spike.trial];

WV		= NaN(size(spikes));
for ii	= 1:size(spikes,2)
	wvs = spikes(:,ii);
	wv	= smooth(wvs,4);
	wv  = wv-median(wv);
	WV(:,ii) = wv;
end

mu	= nanmedian(WV,2);
MU	= repmat(mu,1,size(WV,2));
DF	= nanmean(WV-MU);
DF	= repmat(DF,size(WV,1),1);
WV	= WV-DF;
t	= (1:size(WV,1));
t	= 1000*t/25;
t	= t';
T	= repmat(t,1,size(WV,2));

if GraphFlag
	
	figure;
	subplot(221)
	plot(T,WV,'k-','Color',[.5 1 .5]);
	hold on
	plot(t,mu,'g-','LineWidth',2,'Color',[0 .8 0]);
	ylim([-30 30]);
	axis square;
	drawnow
	xlabel('Time (ms)');
	ylabel('Amplitude (au)');
	title('Unaligned Cluster');
	
	
	[TOT1,x1,y1] = SPKbubblegraph2(T(:),WV(:),0);
	
	subplot(223)
	c = colormap('hot');
% 	b = c(:,[3 1 1]);
	g = c(:,[3 1 2]);
	contourf(x1,y1,sqrt(TOT1'),50);
	shading flat
	colormap(g);
	axis square
end

[m,n] = size(spikes);
WV		= NaN(m*2,n);
for ii	= 1:n
	wvs = spikes(:,ii);
	wv	= smooth(wvs,4);
	wv  = wv-median(wv);
	[~,indx]	= max(wv);
	WV((m+1-indx):(m*2-indx),ii) = wv;
end
mu	= nanmedian(WV,2);
MU	= repmat(mu,1,size(WV,2));
DF	= nanmean(WV-MU);
DF	= repmat(DF,size(WV,1),1);
WV	= WV-DF;
t	= (1:size(WV,1));
t	= 1000*t/25;
t	= t';
T	= repmat(t,1,size(WV,2));

if GraphFlag
	subplot(222)
	plot(T,WV,'k-','Color',[.5 1 .5]);
	hold on
	plot(t,mu,'g-','LineWidth',2,'Color',[0 .8 0]);
	ylim([-30 30]);
	axis square;
	drawnow
	xlabel('Time (ms)');
	ylabel('Amplitude (au)');
	title('Aligned Cluster');
	
	
	[TOT1,x1,y1] = SPKbubblegraph2(T(:),WV(:),0);
	
	subplot(224)
	contourf(x1,y1,sqrt(TOT1'),50);
	shading flat
	colormap(g);
	axis square
end

%% Add Extra Information to Spike-struct
uTrial = unique(trial);
for ii		= 1:length(uTrial)
	indx	= ii;
	sel		= (trial == uTrial(indx));
	Spike(indx).roughalign = WV(:,sel);
end
