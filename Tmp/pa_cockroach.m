close all
clear all

pa_datadir;
[y,fs] = aiffread('cockroach.aif');
y = double(y);
y = y./max(y);

subplot(221)
t = (0:length(y)-1)/fs;
plot(t,y,'k-');
hold on;
xlabel('Time (s)');
ylabel('Amplitude');
box off;
axis square;
thresh = 3*std(y);
pa_horline([-thresh thresh],'r-');

%%
sel		= abs(y)>thresh;
onset	= [0;diff(sel)]>0;
indx	= find(onset);
tspike	= t(indx);
sel		= [1 diff(tspike)]>3/1000;
indx	= indx(sel);

onset = zeros(size(y));
onset(indx) = 1;
% indx	= find(onset);
onset	= double(onset);
tspike	= t(indx);

nspikes = numel(tspike);
% subplot(221)
% plot(t,sel,'k-');


sigma		= 20*fs/1000;
winsize		= sigma*5;
x			= -winsize:winsize;
window		= normpdf(x,0,sigma);
winsize		= [winsize length(onset)+winsize-1];
convspike	= conv(onset,window);
sdf	= convspike(winsize(1):winsize(2));
[MSDF,SDF]	= pa_spk_sdf(tspike);
tsdf		= (0:length(t)-1)/fs;
sdf = sdf./max(sdf);
subplot(221)
plot(t,sdf-2,'r-','LineWidth',2);
ylim([-2.2 1.2]);

%%
spike = NaN(nspikes,89);
for ii = 1:nspikes
	sel = t<tspike(ii)+3/1000 & t>tspike(ii)-1/1000;
% 	sum(sel)
	spike(ii,:) = y(sel);
% 	sum(sel)
% 	subplot(224)
% 	plot(spike)
% 	hold on
% 	drawnow
end
% subplot(224)
% plot(spike')


%%
[u,S,v]			= svd(spike, 0);
EV			= v(:,1:4);  % the first 4 eigenvectors (3 are probably enough....)
E = NaN(nspikes,1);
E1 = E;
E2 = E;
E3 = E;
E4 = E;

for ii = 1:nspikes
E1(ii) =  dot(spike(ii,:), EV(:,1));
E2(ii) =  dot(spike(ii,:), EV(:,2));
E3(ii) =  dot(spike(ii,:), EV(:,3));
E4(ii) =  dot(spike(ii,:), EV(:,3));
end
Nrep				= 10;
Nclust = 4;
K					= kmeans([E1 E2 E3 E4], Nclust, 'Start', 'cluster','rep',Nrep,'Emptyaction','singleton');
col = hsv(Nclust);
for ii = 1:Nclust
	sel = K == ii;
	subplot(222)
	hold on
	x = E1(sel,:);
	y = E2(sel,:);
	plot(x,y,'.','Color',col(ii,:));
	[MU,SD,A] = pa_ellipse(x,y);
	h = pa_ellipseplot(MU,SD,A,'Color',col(ii,:));
	hold on
	axis square;
	axis([-6 6 -6 6]);
	pa_horline(0);
	pa_verline(0);

	subplot(223)
hold on
	x = E1(sel,:);
	y = E3(sel,:);
	plot(x,y,'.','Color',col(ii,:));
	[MU,SD,A] = pa_ellipse(x,y);
	h = pa_ellipseplot(MU,SD,A,'Color',col(ii,:));
	hold on
	axis square;
	axis([-6 6 -6 6]);
	pa_horline(0);
	pa_verline(0);
	
	subplot(224)
hold on
	x = E2(sel,:);
	y = E3(sel,:);
	plot(x,y,'.','Color',col(ii,:));
	[MU,SD,A] = pa_ellipse(x,y);
	h = pa_ellipseplot(MU,SD,A,'Color',col(ii,:));
	hold on
	axis square;
	axis([-6 6 -6 6]);
	pa_horline(0);
	pa_verline(0);
end

whos eig
% Nspk		= size(waves,1);
% labels		= zeros(Nspk, 7);  % later we will separate the different labels
% for n				= 1:Nspk
% 	labels(n,1)		= WAVS(n,1);             % the trial number
% 	labels(n,2)		= WAVS(n,2);             % the spike onset sample re. -600 ms before gaze onset
% 	labels(n,3)		= dot(waves(n,:), EV(:,1));  % inner product waveform with the 4 eigenvectors
% 	labels(n,4)		= dot(waves(n,:), EV(:,2));
% 	labels(n,5)		= dot(waves(n,:), EV(:,3));
% 	labels(n,6)		= dot(waves(n,:), EV(:,4));
% 	spike_construct = labels(n,3) * EV(:,1) + labels(n,4)*EV(:,2) + labels(n,5)*EV(:,3) + labels(n,6)*EV(:,4);
% 	c				= corrcoef(spike_construct, waves(n,:));
% 	labels(n,7)		= c(2,1);    % correlation coefficient with reconstructed wave form
% end

%% Spike Graph
figure;
subplot(221);
time = (0:size(EV,1)-1)/fs*1000;
plot(time, EV,'linewidth',2);
legend('EV1','EV2','EV3','EV4');
xlabel('Time [ms]');
ylabel('Amplitude [a.u.]');
title('Eigenvectors Spikes');
axis square

subplot(222);
for k=1:size(S,1)
	plot(k, S(k,k), 'r.');
	hold on
end
xlabel('Rank');
ylabel('Singular value');
plot([0 50],[S(4,4), S(4,4)],'k--');
for k=1:4
	plot(k, S(k,k), 'ks','markerfacecolor','r','markersize',10);
end
axis square

%%

% keyboard
return
cd('C:\Users\Marc van Wanrooij\Documents\Bureacratie');

[n,t,r] = xlsread('Studenten.xlsx');
start = t(2:end,6);
stop = t(2:end,9);

startvec = NaN(length(start),1);
stopvec = startvec;
for ii = 1:length(start)
	a = start(ii);
	try
		a = datenum(a,'dd-mm-yy');
		
		startvec(ii) = a;
		
	end
	b = stop{ii}
	if strcmpi(b,'Nog bezig')
		b = date;
		try
			b = datenum(b);
			
			stopvec(ii) = b;
			
		end
	else
		try
			b = datenum(b,'dd-mm-yy');
			
			stopvec(ii) = b;
			
		end
	end
end
% startvec
% stopvec

ndays	= (stopvec-startvec)
nweeks	= ndays/7;
ndays	= nweeks*5;
nhours	= ndays*2;

V = [];
for ii = 1:length(startvec)
	vec = startvec(ii):stopvec(ii);
	V	= [V vec];
end
V		= V(~isnan(V));
uV		= unique(V);
N		= hist(V,uV);
indx	= ismember(mod(1:length(uV),7),1:5);
uV		= uV(indx);
N		= N(indx);
try
hp = pa_errorpatch(uV,zeros(size(uV)),2*smooth(N,20),'b');
set(hp,'EdgeColor','b','LineWidth',2);
hp = pa_errorpatch(uV,zeros(size(uV)),smooth(N,20),'r');
set(hp,'EdgeColor','r','LineWidth',2);
catch
plot(uV,N,'ko-','MarkerFaceColor','w');
end
a = datenum('01-09-2011','dd-mm-yy');
b = datenum('01-09-2012','dd-mm-yy');
xlim([a b]);
ylim([0 14]);
datetick('x',2);
pa_verline([a b])
xlabel('Datum');
ylabel('Aantal uur/dag');
% xt = get(gca,'XTick')
% set(gca,'XTick',linspace(min(xt),max(xt),(max(xt)-min(xt))/60))
box off
return
% subplot(121)
% x = 0:0.01:10;
% y = normpdf(x,5,3);
% plot(x,y);
%
% z = normpdf(x,6,1.5);
% hold on
% plot(x,z,'k-');
%
% FA = NaN(size(x));
% HIT = FA;
% for ii = 1:length(z)
% 	FA(ii) = sum(y(ii:end));
% 	HIT(ii) = sum(z(ii:end));
% end
% subplot(122)
% plot(FA/100,HIT/100);
% axis square;
% pa_unityline;
%
% FA = cumsum(y)./sum(y);
% HIT = cumsum(z)./sum(z);
% hold on
% plot(1-FA,1-HIT,'r-');
% return

% I = imread('phono.png');
% % I(I<200) = 20;
% imshow(I)

x = -100:1:100;
for ii = 1:.1:10;
	y = normpdf(x,0,2);
	z = normpdf(x,ii,ii);
	[y,z] = meshgrid(y,z);
	M = y.*z;
	contourf(M);
	shading flat;
	pause(.1);
	drawnow
end

return
Fs = 44100;

snd1 = pa_gengwn(0.500)';
snd2 = pa_genripple(.5,0,100,4000,500)';
snd1 = -pa_genripple(.5,0,100,4000,500)';
% snd1 = -snd2;

whos snd1 snd2
sndMatrix = [snd1 snd2];
whos sndMatrix
pa_wavplay(sndMatrix, Fs, 0, 'win');
