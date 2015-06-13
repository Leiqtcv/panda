function simulate_add_vs_mult_AIC
close all
clear all
ntrials = 100;
minprob    = 1e-5;

x		= 1:1000;
f		= 10;
p		= sin(2*pi*f*x/1000)+2;
p		= p./max(p)/10;
td		= normpdf(x,250,144);
td		= cumsum(td);
td		= 2*td./max(td)+1;
td		= td./max(td)/10;
indx	= 1:500;


%% UNCOMMENT/CHANGE TO YOUR LIKING
% Padd		= p+td;
% or
Padd		= p.*td;

%%
nx			= numel(x);
Radd		= NaN(nx,ntrials);
for ii = 1:nx
	l = Padd(ii);
	Radd(ii,:) = poissrnd(l,[1 ntrials]);
end

nx			= numel(x);
Rp		= NaN(nx,ntrials);
for ii = 1:nx
	l = p(ii);
	Rp(ii,:) = poissrnd(l,[1 ntrials]);
end

ASDF = pa_spk_sdf(Radd','sigma',70);
PSDF = pa_spk_sdf(Rp','sigma',70);
ASDF5 = pa_spk_sdf(Radd','sigma',5);
PSDF5 = pa_spk_sdf(Rp','sigma',5);

rTDadd = ASDF-PSDF;
rTDmult = ASDF./PSDF;
rTDadd5 = ASDF5-PSDF5;
rTDmult5 = ASDF5./PSDF5;

figure(1)
subplot(333)
hold on
plot(x(indx),ASDF(indx),'r-')
plot(x(indx),ASDF5(indx),'Color',[.7 .7 .7])

subplot(331)
hold on
plot(x(indx),PSDF(indx),'r-')
plot(x(indx),PSDF5(indx),'Color',[.7 .7 .7])

subplot(332)
hold on
plot(x(indx),rTDadd(indx),'r-')
plot(x(indx),rTDadd5(indx),'Color',[1 .7 .7])

subplot(335)
hold on
plot(x(indx),rTDmult(indx),'b-')
plot(x(indx),rTDmult5(indx),'Color',[.7 .7 1])

figure(1)
subplot(331)
plot(x(indx),p(indx),'k-');
hold on
box off
ylim([0 0.3]);

subplot(332)
plot(x(indx),td(indx),'k-');
hold on
box off
ylim([0 0.3]);

subplot(333)
plot(x(indx),Padd(indx),'k-');
hold on
box off
ylim([0 0.3]);

predAdd = PSDF5+rTDadd;
predAdd(predAdd<minprob) = minprob;
predMult = PSDF5.*rTDmult;
predMult(predMult<minprob) = minprob;

subplot(333)
plot(x(indx),predAdd(indx),'r-','LineWidth',2);
hold on
plot(x(indx),predMult(indx),'b-','LineWidth',2);

box off
ylim([0 0.3]);

subplot(339)
R = Radd(indx,:);
plot(R)
SI = [];
for ii = 1:ntrials
spikeindx = find(R(:,ii)>0);
SI = [SI; spikeindx];
end
spikeindx = SI;

%% FINALLY, THE AIC
AIC = -2*sum(log10(predAdd(spikeindx)))
AIC = -2*sum(log10(predMult(spikeindx)))
