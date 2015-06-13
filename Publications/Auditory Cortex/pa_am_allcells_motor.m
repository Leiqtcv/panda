function pa_am_allcells_motor

clc;
close all hidden;
clear all

% cd('E:\DATA\selected cells');
cd('E:\DATA\Cortex\AMcells with tonespike');
d = dir('*.mat');
fnames = {d.name};
nfiles = length(d);
k = 0;
muFR = NaN(nfiles,701);
lat = 1000;
for ii = 1:nfiles
	try
		fname = fnames{ii};
		load(fname)
		
		spike			= spikeAMA;
		indx			= [spike.trialorder];
		spike			= spike(indx);
		rt				= behAM(2,:);
		sel				= behAM(4,:)==lat;
		spike			= spike(sel);
		rt				= rt(sel);
		
		spikecontrol	= spikeAMP;
		
		[~,sdf]			= pa_spk_sdf(spike,'Fs',1000,'sigma',15);
		[~,sdfcontrol]	= pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',15);
		mfcntrl			= [spikecontrol.stimvalues];
		mfcntrl			= mfcntrl(5,:);
		ntrials			= size(sdf,1);
		mx				= 1900;
		M				= NaN(ntrials,mx);
		for jj = 1:ntrials
			cMF		= spike(jj).stimvalues(5); % current trial
			sel		= mfcntrl == cMF;
			s		= sdfcontrol(sel,:);
			s		= mean(s);
			M(jj,:) = sdf(jj,1:mx)-s(1:mx);
		end
		
		[s,indx]	= sort(rt);
		M			= M(indx,:);
		% 		M = M(:,800:1500);
		M			= pa_runavg(M,10);
		FR			= NaN(size(M,1),2501);
		n			= 0;
		for jj = -500:2000
			n			= n+1;
			indx		= round(s)+jj;
			sel			= indx<1;
			indx(sel)	= 1;
			sel			= indx>length(M);
			indx(sel)	= length(M);
			for kk = 1:size(M,1)
				FR(kk,n) = M(kk,indx(kk));
			end
		end
		whos FR
		R2 = NaN(size(M,2),1);
		for jj = 1:size(M,2)
			x = M(:,jj);
			r = corrcoef(s,x);
			R2(jj) = r(2);
		end
		
		figure(1)
		clf;
		subplot(121)
		imagesc(M)
		
		hold on
		axis square;
		set(gca,'YDir','normal');
		colorbar;
		plot(s-86,1:numel(s),'w-','LineWidth',2)
		plot(s+300+lat,1:numel(s),'w-','LineWidth',2)
		pa_verline([300 300+lat],'w--');
		caxis(0.9*[-max(abs(M(:))) max(abs(M(:)))]);
		title({num2str(ii);fname});
		xlabel('Time (ms)');
		ylabel('Trial');
		xlim([300+lat 1000+lat]);
		
		subplot(122)
		m = mean(FR);
		m = (m-min(m))./(max(m)-min(m));
		plot((-500:2000)-(300+lat),m,'k-','LineWidth',2)
		hold on
		axis square;
		pa_verline([-800 0],'k--');
		pa_horline(0);
		
		plot((1:length(R2))-1000,R2.^2,'r-','LineWidth',2)
		ylim([0 1]);
		% 		xlim([-400 50]);
		
		m = mean(FR);
		m = m(:,700:1400);
		muFR(ii,:) = m;
		% 		pause;
	end
end

%%
close all
figure
subplot(121)
sel = isnan(muFR(:,2));
a = muFR(~sel,:);
plot((1:length(a))-600,nanmean(a),'k-','LineWidth',2);
xlabel('Time (ms)');
ylabel('\mu_{\Delta Firing rate} (spikes/s)');
xlim([-600 100]);
axis square
box off
title('AM: A500 - P');
pa_verline(0);

%% svd
%%
close all
figure
ncells		= size(a,1);
[u,S,v]		= svd(a, 0);
EV			= v(:,1:4);  % the first 4 eigenvectors (3 are probably enough....)

subplot(221)
plot((1:size(a,2))-600,EV,'LineWidth',2);
axis square;
box off
xlim([-600 100]);
pa_verline(0);
legend({'1^{st}';'2^{nd}';'3^{rd}';'4^{th}'},'Location','NW')
xlabel('Time (ms)');
ylabel('Amplitude');

E = NaN(ncells,1);
E1 = E;
E2 = E;
E3 = E;
E4 = E;

subplot(222)
SD              = (diag(S));
SD = 100*SD./sum(SD);
SD = SD(1:10);
plot(SD,'ko-','MarkerFaceColor','w','LineWidth',2);

axis square
box off
ylim([0 100]);
xlabel('Singular value index');
ylabel('Variance explained');

for ii = 1:ncells
	E1(ii) =  dot(a(ii,:), EV(:,1));
	E2(ii) =  dot(a(ii,:), EV(:,2));
	E3(ii) =  dot(a(ii,:), EV(:,3));
	E4(ii) =  dot(a(ii,:), EV(:,3));
end
Nrep				= 10;
Nclust = 3;
K					= kmeans([E1 E2 E3 E4], Nclust, 'Start', 'cluster','rep',Nrep,'Emptyaction','singleton');
col = hsv(Nclust);
for ii = 1:Nclust
	sel = K == ii;
	subplot(223)
	hold on
	x = E1(sel,:);
	y = E2(sel,:);
	[MU,SD,A] = pa_ellipse(x,y);
	MU(1)
	h = pa_ellipseplot(MU,SD,A,'Color',col(ii,:));
	hold on
	axis square;
% 	axis([-6 6 -6 6]);
	pa_horline(0);
	pa_verline(0);
	xlabel('Coefficient 1');
	ylabel('Coefficient 2');
	
	subplot(224)
	hold on
	x = E2(sel,:);
	y = E3(sel,:);
	plot(x,y,'.','Color',col(ii,:));
	[MU,SD,A] = pa_ellipse(x,y);
	h = pa_ellipseplot(MU,SD,A,'Color',col(ii,:));
	hold on
	axis square;
% 	axis([-6 6 -6 6]);
	pa_horline(0);
	pa_verline(0);
	xlabel('Coefficient 3');
	ylabel('Coefficient 4');
end


for ii = 1:Nclust
	sel = K == ii;
	subplot(1,3,ii)
	hold on
	x = E1(sel,:);
	y = E2(sel,:);
	[MU,SD,A] = pa_ellipse(x,y);
	wv = MU(1)*EV(:,1) + MU(2)*EV(:,2) +M(3)*EV(:,3) +M(4)*EV(:,4);
	plot((1:size(a,2))-600,wv,'Color',col(ii,:))
	axis square;
	box off
% 	ylim([0 60])
xlim([-600 100]);
pa_verline(-86);
end
%%
keyboard

