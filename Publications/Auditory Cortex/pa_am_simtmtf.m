function tmp
close all
clear all

d		= 700;
uMF		= pa_oct2bw(2,0:0.5:7);
nMF = numel(uMF)
Nbin		= 52;
ncomp		= 1;
xperiod		= linspace(0,1,Nbin);
ntrials = 20;
fr		= 50;
nbootstrp = 1e4;
tMTF	= NaN(nMF,nbootstrp);
tsMTF = tMTF;
for kk = 1:nbootstrp;
	for ii		= 1:nMF
		nperiod = floor(d/(1/uMF(ii)));
		maxtime = nperiod*(1/uMF(ii));
		P = [];
		P1 = [];
		P2 = [];
		T = genspiketrain(fr,d,ntrials);
		for jj = 1:ntrials
			spktime = T(jj).spiketime/1000;
			sel			= spktime<=maxtime;
			spktime		= spktime(sel);
			spktime		= spktime*uMF(ii);
			period		= mod(spktime,1);
			P			= [P period]; %#ok<AGROW>
			if jj<=ntrials/2
			P1			= [P1 period]; %#ok<AGROW>
			else
			P2			= [P2 period]; %#ok<AGROW>
			end
		end
		Nspikes		= hist(P,xperiod);
		Nspikes		= Nbin*Nspikes/ntrials/(1/uMF(ii))/nperiod; % Convert to firing rate
		X			= fft(Nspikes,Nbin)/Nbin;
		tMTF(ii,kk)	= abs(X(ncomp+1));
		q(ii,kk)	= abs(X(ncomp+1))/sum(abs(X((ncomp+1):end)));
		
		N1		= hist(P1,xperiod);
		N1		= Nbin*N1/(ntrials/2)/(1/uMF(ii))/nperiod; % Convert to firing rate
		N2		= hist(P2,xperiod);
		N2		= Nbin*N2/(ntrials/2)/(1/uMF(ii))/nperiod; % Convert to firing rate
		
		r = corrcoef(N1,N2);
		
		tsMTF(ii,kk) = r(2);
	end
end

tMTF
% 

p = prctile(tMTF',[2.5 50 99.9]);
whos p
subplot(121)
plot(uMF,tMTF,'k-','Color',[.7 .7 .7]);
hold on
plot(uMF,p(2,:),'k-','LineWidth',2);
plot(uMF,p(3,:),'k-','LineWidth',2);
set(gca,'Xscale','log','XTick',uMF(1:2:end),'XTickLabel',uMF(1:2:end))

p = prctile(q',[2.5 50 99.9]);
whos p
subplot(122)
plot(uMF,q,'k-','Color',[.7 .7 .7]);
hold on
plot(uMF,p(2,:),'k-','LineWidth',2);
plot(uMF,p(3,:),'k-','LineWidth',2);
set(gca,'Xscale','log','XTick',uMF(1:2:end),'XTickLabel',uMF(1:2:end))

pa_datadir
p = p(3,:);
save(mfilename,'p');

%%
p = prctile(tsMTF',[2.5 50 99.9]);
figure(2)
plot(uMF,tsMTF,'k-','Color',[.7 .7 .7]);
hold on
plot(uMF,p(2,:),'k-','LineWidth',2);
plot(uMF,p(3,:),'k-','LineWidth',2);
set(gca,'Xscale','log','XTick',uMF(1:2:end),'XTickLabel',uMF(1:2:end))
title(max(p(3,:)))
% p = prctile(q',[2.5 50 99.9]);
% whos p
% subplot(122)
% plot(uMF,q,'k-','Color',[.7 .7 .7]);
% hold on
% plot(uMF,p(2,:),'k-','LineWidth',2);
% plot(uMF,p(3,:),'k-','LineWidth',2);
% set(gca,'Xscale','log','XTick',uMF(1:2:end),'XTickLabel',uMF(1:2:end))

pa_datadir
p = p(3,:);
% save(mfilename,'p');

%%
% keyboard
function T = genspiketrain(fr,d,ntrials)
lambda = fr/1000;
rnd = poissrnd(lambda,[d ntrials]);
% rnd(rnd>1) = 1;
T = struct([]);
for ii = 1:ntrials
T(ii).spiketime = find(rnd(:,ii))';
end
% bar(rnd)
