function tmp
%% Clean
close all
clear all
clc

%% rate-code
n		= 1000; % number of time points
fr		= 60; % firing rate (Hz)
d		= n; % duration in ms
ntrials = 20; % number of trials
lambda	= fr/1000; % probability of a spike in 1 ms bin
rnd		= poissrnd(lambda,[d ntrials]); % number of spikes per bin according to poisson dist
T = struct([]);
for ii = 1:ntrials
	T(ii).spiketime = find(rnd(:,ii))'; % spike timings
end

fr		= 10; % firing rate (Hz)
d		= n; % duration in ms
ntrials = 20; % number of trials
lambda	= fr/1000; % probability of a spike in 1 ms bin
rnd		= poissrnd(lambda,[d ntrials]); % number of spikes per bin according to poisson dist
for ii = (ntrials+1):(ntrials*2)
	T(ii).spiketime = find(rnd(:,ii-ntrials))'; % spike timings
end

subplot(221)
pa_spk_rasterplot(T);

m = pa_spk_sdf(T(1:ntrials),'Fs',1000);
plot(1:length(m),m-100,'k-');
hold on
m = pa_spk_sdf(T((ntrials+1):(ntrials*2)),'Fs',1000);
plot(1:length(m),m-100,'k-','Color',[.7 .7 .7]);
box off
axis square;
set(gca,'TickDir','out','XTick',0:200:1000,'YTick',-100:20:40,'YTickLabel',[0:20:80 0:20:40]);
ylim([-110 80])
xlim([-100 1100]);
pa_horline(0,'k-');
str1 = getmetrics(T(1:ntrials),d,ntrials);
str2 = getmetrics(T((ntrials+1):(ntrials*2)),d,ntrials);
pa_text(0.1,0.9,str1)
pa_text(0.5,0.9,str2,'Color',[.7 .7 .7])
ylabel(['Firing rate (Hz) - Trial number']);


%% temporal-following, magnitude
clear all
n = 1000;
x = 1:1000;
f = 4;
fr = sin(2*pi*f*x/1000);
fr = fr-min(fr);
fr = fr/2*50;
%
% plot(x,y)
% function T = genspiketrain(fr,d,ntrials)
% fr = 50;
ntrials = 20;
lambda = fr/1000;
rnd = NaN(n,ntrials);
for indx = 1:n
	rnd(indx,:) = poissrnd(lambda(indx),[1 ntrials]);
end
% rnd(rnd>1) = 1;
T = struct([]);
for ii = 1:ntrials
	T(ii).spiketime = find(rnd(:,ii))';
end

subplot(222)
pa_spk_rasterplot(T);
hold on
m = pa_spk_sdf(T,'Fs',1000,'sigma',5);
plot(1:length(m),m-100,'k-');
box off
axis square;
set(gca,'TickDir','out','XTick',0:200:1000,'YTick',-100:20:40,'YTickLabel',[0:20:80 0:20:40]);
ylim([-110 60])
xlim([-100 1100]);
pa_horline(0,'k-');
ylabel(['Firing rate (Hz) - Trial number']);
str = getmetrics(T(1:ntrials),n,ntrials);
pa_text(0.1,0.9,str);

%% phase-locking
clear all
n = 1000;
x = 1:1000;
f = 4;
fr = sin(2*pi*f*x/1000);
fr = fr-min(fr);
fr = fr/2*80;
phi = f*mod(x/1000,1/f);

sel = phi>0.225 & phi<0.275;

% figure
% plot(x,phi,'k-')
% hold on
% plot(x(sel),phi(sel),'r.');
% return
sum(sel)
fr(~sel) = 1;
fr(sel) = 80;
%
% plot(x,y)
% function T = genspiketrain(fr,d,ntrials)
% fr = 50;
ntrials = 20;
lambda = fr/1000;
rnd = NaN(n,ntrials);
for indx = 1:n
	rnd(indx,:) = poissrnd(lambda(indx),[1 ntrials]);
end
% rnd(rnd>1) = 1;
T = struct([]);
for ii = 1:ntrials
	T(ii).spiketime = find(rnd(:,ii))';
end

subplot(223)
pa_spk_rasterplot(T);
hold on
m = pa_spk_sdf(T,'Fs',1000,'sigma',5);
plot(1:length(m),m-100,'k-');
box off
axis square;
set(gca,'TickDir','out','XTick',0:200:1000,'YTick',-100:20:40,'YTickLabel',[0:20:80 0:20:40]);
ylim([-110 60])
xlim([-100 1100]);
pa_horline(0,'k-');
ylabel(['Firing rate (Hz) - Trial number']);
str = getmetrics(T(1:ntrials),n,ntrials);
pa_text(0.1,0.9,str);
hold on

%% trial similarity
clear all
n = 1000;
x = 1:1000;
f = 4;
fr = sin(2*pi*f*x/1000);
fr = fr-min(fr);
fr = fr/2*40;

fr2 = sin(2*pi*8*x/1000+0.1);
fr2 = fr2-min(fr2);
fr2 = fr2/2*40;

phi = f*mod(x/1000,1/f);

sel = phi>0.725 & phi<0.775;
frp = fr;
% figure
% plot(x,phi,'k-')
% hold on
% plot(x(sel),phi(sel),'r.');
% return
frp(~sel) = 0;
frp(sel) = 160;

fr = (fr+fr2+frp);
%
% plot(x,y)
% function T = genspiketrain(fr,d,ntrials)
% fr = 50;
ntrials = 20;
lambda = fr/1000;
rnd = NaN(n,ntrials);
for indx = 1:n
	rnd(indx,:) = poissrnd(lambda(indx),[1 ntrials]);
end
% rnd(rnd>1) = 1;
T = struct([]);
for ii = 1:ntrials
	T(ii).spiketime = find(rnd(:,ii))';
end


subplot(224)
pa_spk_rasterplot(T);
hold on
m = pa_spk_sdf(T,'Fs',1000,'sigma',5);
m = m/2;
plot(1:length(m),m-100,'k-');
box off
axis square;
set(gca,'TickDir','out','XTick',0:200:1000,'YTick',-100:20:40,'YTickLabel',[0:20:80 0:20:40]);
ylim([-110 60])
xlim([-100 1100]);
pa_horline(0,'k-');
ylabel(['Firing rate (Hz) - Trial number']);
str = getmetrics(T(1:ntrials),n,ntrials);
pa_text(0.1,0.9,str);
hold on

%% 
pa_datadir;
print('-depsc','-painter',mfilename);

function str = getmetrics(T,d,ntrials)
uMF			= 4;
Nbin		= 52;
ncomp		= 1;
xperiod		= linspace(0,1,Nbin);
nperiod		= floor(d/(1/uMF));
maxtime		= nperiod*(1/uMF);
P			= [];
P1			= [];
P2			= [];
for jj = 1:ntrials
	spktime = T(jj).spiketime/1000;
	sel			= spktime<=maxtime;
	spktime		= spktime(sel);
	spktime		= spktime*uMF;
	period		= mod(spktime,1);
	P			= [P period]; %#ok<AGROW>
	if jj<=ntrials/2
		P1			= [P1 period]; %#ok<AGROW>
	else
		P2			= [P2 period]; %#ok<AGROW>
	end
end
Nspikes		= hist(P,xperiod);
Nspikes		= Nbin*Nspikes/ntrials/(1/uMF)/uMF; % Convert to firing rate
X			= fft(Nspikes,Nbin)/Nbin;
rate		= abs(X(ncomp));
mag			= abs(X(ncomp+1));
vs			= mag/rate;
N1			= hist(P1,xperiod);
N1			= Nbin*N1/(ntrials/2)/(1/uMF)/uMF; % Convert to firing rate
N2			= hist(P2,xperiod);
N2			= Nbin*N2/(ntrials/2)/(1/uMF)/uMF; % Convert to firing rate
r			= corrcoef(N1,N2);
ts			= r(2);


str			= {['Rate = ' num2str(rate,'%1.0f')];...
	['Magnitude = ' num2str(mag,'%1.0f')];...
	['Vector strength = ' num2str(vs,'%1.2f')];...
	['Trial similarity = ' num2str(ts,'%1.2f')]};


