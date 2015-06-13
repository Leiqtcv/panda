function Spike = SPKaligncorr(Spike)
spikes			= [Spike.spikewave];
trial			= [Spike.trial];
WV				= [Spike.roughalign];
spikesmu		= nanmedian(WV,2);
[~,indx]		= max(spikesmu);
indx			= (indx+1-15):(indx+25);
if indx(1)<1
	indx = indx-indx(1)+1;
end
spikesmu	= spikesmu(indx);
sel			= ~isnan(spikesmu);
spikesmu	= spikesmu(sel);
% tmu			= 1:length(spikesmu);

[m,n] = size(spikes);
WV	  = NaN(m*3,n);
C = NaN(1,n);
% dT = NaN(1,n);
L = C;
for ii = 1:n
	wv			= spikes(:,ii);
	[c,lags]	= xcorr(spikesmu,wv,'none');
	[~,indx]	= max(c);
	C(ii)		= c(indx);
	indx		= lags(indx);
	WV(m+1+indx:m*2+indx,ii) = wv;
	L(ii) = indx;
% 	dT(ii) = 1000*indx/25;
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

figure
sel = ~isnan(mu);
subplot(121)
h = plot(T(sel,:),WV(sel,:),'k-');
set(h,'Color',[.5 1 .5]);
hold on
h = plot(t(sel,:),mu(sel,:),'k-');
set(h,'LineWidth',2,'Color',[0 .8 0]);
axis square

[TOT1,x1,y1] = SPKbubblegraph2(T(:),WV(:),0);
% s = nansum(TOT1);
% s = repmat(s,size(TOT1,1),1);
% TOT1 = TOT1./s;

subplot(122)
c = colormap('hot');
% b = c(:,[3 2 1]);
g = c(:,[3 1 2]);
contourf(x1,y1,sqrt(TOT1'),50);
shading flat
colormap(g);
axis square


%% Add Extra Information to Spike-struct
uTrial = unique(trial);
for ii		= 1:length(uTrial)
	indx	= ii;
	sel		= (trial == uTrial(indx));
	Spike(indx).spikewavexcorr	= WV(:,sel);
	Spike(indx).xcorrlag		= L(sel);
	Spike(indx).corrspiketime	= Spike(indx).spiketime+1000*L(sel)/25000;
	
% 	Spike(indx).spiketimexcorr = Spike(indx).spiketime+dT(sel);
end
