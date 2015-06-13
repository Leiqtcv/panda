function SPKplotpeaks(Spike)
% SPKPLOTPEAKS(SPK)
%
% Plot two spike peaks against each other in BrainWare style
%

% (c) Marc van Wanrooij 2010

spikes			= [Spike.spikewave];
moments			= [Spike.spiketime];

%% smoothing and removing offset
for ii  = 11:size(spikes,2)
% 	spikes(:,ii) = spikes(:,ii)-median(spikes(:,ii));	
	spikes(:,ii) = smooth(spikes(:,ii),3);
end

%% Determine Minimum and Maximum Peaks
[mx,mxindx] = max(spikes);
[mn,mnindx] = min(spikes);
sel			= mxindx>mnindx;

%% Plot first peak vs 2nd peak (exactly as BrainWare)
figure
c = colormap('hot');
% b = c(:,[3 2 1]);
g = c(:,[3 1 2]);

subplot(221)
plot(mn(sel),mx(sel),'k.');
hold on
plot(mx(~sel),mn(~sel),'r.');
axis square
xlabel('Amplitude First Peak');
ylabel('Amplitude Second Peak');
axis([min([mn mx]) max([mn mx]) min([mn mx]) max([mn mx])]);
pa_horline;
pa_verline;

%% Plot Maximum vs Minimum
subplot(222)
% plot(mn,mx,'k.','Color',[.9 .9 .9]);
[mu,sd,a,x,y] = pa_ellipse(mn,mx,'outlier',5);
[TOT,x,y] = SPKbubblegraph(x,y);
hold on
pa_ellipseplot(mu,2*sd,a);

axis([min(mn) max(mn) min(mx) max(mx)]);
xlabel('Amplitude Negative Peak');
ylabel('Amplitude Positive Peak');
axis square;


%%
A	= mx-mn;
stp = 10*std(A)/sqrt(numel(A));
% stp = std(A);
subplot(223)
n = min(A):stp:max(A);
N = hist(A,n);
h = bar(n,N,1);
set(h,'FaceColor','g');
axis square;
xlabel('Peak-Peak Amplitude');
ylabel('N');

% %% Hot-Style Map
% subplot(224)
% colormap(g);
% contourf(x,y,TOT',50);
% shading flat
% caxis([0 .5]);
% axis square
% xlabel('Amplitude Negative Peak');
% ylabel('Amplitude Positive Peak');