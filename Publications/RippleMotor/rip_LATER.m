function rip_fitcdf3
%% Clean
close all
clear all
clc

% p.dt		= 0.001;  %step size for simulations (seconds)
% nSteps		= 600; %number of time steps
subs		= 1:16; % subject nr
nsubs = numel(subs);
mod		= 100; % modulation depth (%)

M = NaN(nsubs,19);
for ii = 1:nsubs
	sub = subs(ii);
	[m,s] = getrate(sub,mod);
	M(ii,:) = m;
	S(ii,:) = s;
end
% keyboard
%%
uMF = sort([pa_oct2bw(0.5,0:8) 0 -pa_oct2bw(0.5,0:8)]);
m	= nanmean(M)*1000;
msd = nanstd(M)*1000./sqrt(nsubs);
s	= nanmean(S)*1000;
ssd = nanstd(S)*1000./sqrt(nsubs);



figure(1)
clf
sel = uMF>0;
xt	= uMF(sel);
subplot(221)
errorbar(uMF(sel),m(sel),msd(sel),'ko-','MarkerFaceColor','w','LineWidth',2);
hold on

subplot(222)
errorbar(uMF(sel),s(sel),ssd(sel),'ko-','MarkerFaceColor','w','LineWidth',2);
hold on

sel = uMF<0;
subplot(221)
errorbar(abs(uMF(sel)),m(sel),msd(sel),'rs-','MarkerFaceColor','w','LineWidth',2);
axis square;
set(gca,'XTick',xt,'XTickLabel',xt,'XScale','log');
xlim([0.25 256]);
ylim([1 7]);
xlabel('Modulation frequency (Hz)');
ylabel('Rate \mu ');
box off

subplot(222)
errorbar(abs(uMF(sel)),s(sel),ssd(sel),'rs-','MarkerFaceColor','w','LineWidth',2);
axis square;
set(gca,'XTick',xt,'XTickLabel',xt,'XScale','log');
xlim([0.25 256]);
ylim([-1 5]);
xlabel('Modulation frequency (Hz)');
ylabel('Rate \sigma ');
box off

subplot(223)
seld = uMF>0;
selu = uMF<0;
[~,indxu] = sort(abs(uMF(selu)));
[~,indxd] = sort(abs(uMF(seld)));

Mu = M(:,selu)*1000;
Md = M(:,seld)*1000;
Mu = Mu(:,indxu);
Md = Md(:,indxd);

subplot(223)
[me,se,ae] = pa_ellipse(Mu(:),Md(:));
pa_ellipseplot(me,se,ae);
hold on
plot(Mu,Md,'ko','MarkerFaceColor','w')
axis([1 7 1 7]);
axis square;
pa_unityline;
box off;
xlabel('Rate \mu Upward modulation');
ylabel('Rate \mu Downward modulation');


%%

%%
uMF = sort([pa_oct2bw(0.5,0:8) 0 -pa_oct2bw(0.5,0:8)]);
m	= nanmean(M)*1000;
msd = nanstd(M)*1000./sqrt(nsubs);
s	= nanmean(S)*1000;
ssd = nanstd(S)*1000./sqrt(nsubs);



% figure(2)
% clf
sel = uMF>0;
xt	= uMF(sel);
x = uMF(sel);
y = m(sel);
z = msd(sel);
x = 1./x;
[x,indx] = sort(x);
y = y(indx);
z = z(indx);
subplot(224)
errorbar(x,y,z,'ko-','MarkerFaceColor','w','LineWidth',2);
hold on

sel = uMF<0;
x = abs(uMF(sel));
y = m(sel);
z = msd(sel);
x = 1./x;
[x,indx] = sort(x);
y = y(indx);
z = z(indx);
errorbar(x,y,z,'rs-','MarkerFaceColor','w','LineWidth',2);
axis square;
% xlim([0.25 256]);
ylim([1 7]);
xlabel('Modulation period (s)');
ylabel('Rate \mu ');
box off



function [MU,SD,uMF] = getrate(sub,mod)
[RT,MF]	= getdata(sub,mod);


%%
xi		= 0:5:2900;
XI = xi;
uMF = sort([pa_oct2bw(0.5,0:8) 0 -pa_oct2bw(0.5,0:8)]);
n	= size(uMF,2);
p	= 0.05:0.05:0.95;
close all
for ii = 1:n
	tic;
	sel		= MF==uMF(ii);
	if sum(sel)
	rt		= RT(sel);
	rtinv	= 1./rt;

	[Y,XI]	= ksdensity(rtinv,xi);
	
	mu	= mean(rtinv);
	sd	= std(rtinv);
	p	= normpdf(XI,mu,sd);
	p	= p./sum(p);
	
% 	figure(1)
% 	subplot(3,6,ii)
% 	h = bar(xi,y,1);
% 	set(h,'FaceColor',[.7 .7 .7],'EdgeColor','none');
% 	hold on
% 	plot(XI,Y,'k-');
% 	plot(XI,p,'r-');

%%
	[Y,XI]	= ksdensity(rt,xi);
	Y		= Y./sum(Y);
	y		= hist(rt,xi);
	y		= y./sum(y);
	
simrtinv = mu+sd.*randn(20000,1);	
simrt = 1./simrtinv;
		[simY,simXI]	= ksdensity(simrt,XI);
simY = simY./sum(simY);

% figure(2)
% 	subplot(3,6,ii)
% 	h = bar(xi,y,1);
% 	set(h,'FaceColor',[.7 .7 .7],'EdgeColor','none');
% 	hold on
% 	plot(XI,Y,'k-');
% 	plot(simXI,simY,'r-');
% xlim([100 600]);

P(ii,:) = simY;
	else 
		mu = NaN;
		sd = NaN;
	end
Par(ii).mu = mu;
Par(ii).sd = sd;
end


figure
pcolor(uMF,xi,P'); shading flat
hold on
contour(uMF,xi,P',3,'w');

axis square
colorbar
set(gca,'Ydir','normal');
% return
m = [Par.mu]*1000;
s = [Par.sd]*1000;

figure
sel = uMF>0;
xt	= uMF(sel);
subplot(121)
semilogx(uMF(sel),m(sel),'ko-','MarkerFaceColor','w');
hold on

subplot(122)
semilogx(uMF(sel),s(sel),'ko-','MarkerFaceColor','w');
hold on

sel = uMF<0;
subplot(121)
semilogx(abs(uMF(sel)),m(sel),'rs-','MarkerFaceColor','w');
axis square;
set(gca,'XTick',xt,'XTickLabel',xt);
xlim([0.25 256]);
ylim([0 8]);
xlabel('Modulation frequency (Hz)');
ylabel('mean Rate');

subplot(122)
semilogx(abs(uMF(sel)),s(sel),'rs-','MarkerFaceColor','w');
axis square;
set(gca,'XTick',xt,'XTickLabel',xt);
xlim([0.25 256]);
ylim([0 8]);
xlabel('Modulation frequency (Hz)');
ylabel('std Rate');

MU = [Par.mu];
SD = [Par.sd];




function [L,V] = getdata(sub,mod)


subs	= [1 2 4 5 6 8 9 10 13 14 15 16 17 18 19 21];
nsubs	= numel(subs);
hands	= {'left';'right'};
nhand	= numel(hands);
ears	= {'left';'right';'both'};
near	= numel(ears);


pa_datadir;
load('rippledata');
Subject
V = []; % velocity
L = []; % latency
% H = [];
E = []; % ear
S = []; % subject
M = []; % modulation depth
for ii = 1:nsubs
	for jj = 1:nhand
		for kk = 1:near
			vel = Subject(ii).hand(jj).ear(kk).velocity;
			lat = Subject(ii).hand(jj).ear(kk).reactiontime;
			md = Subject(ii).hand(jj).ear(kk).md;
			V = [V vel]; %#ok<*AGROW>
			L = [L lat];
			E = [E repmat(kk,size(vel))];
			S = [S repmat(ii,size(vel))];
			M = [M md];
		end
	end
end
sel = L<2900 & L>80 ;
L	= L(sel);
S	= S(sel);
E	= round(E(sel));
V	= round(V(sel)*2)/2;
M	= round(M(sel));

%% subject
figure
sel		= ismember(E,1:4) & M==mod & S==sub;
V		= V(sel);
L		= L(sel);
uVel	= sort([-pa_oct2bw(0.5,0:1:8) pa_oct2bw(0.5,0:1:8)]);
uVel	= sort(uVel);
nVel	= numel(uVel);
mu		= NaN(nVel,1);
sd		= mu;

xi		= 0:10:2900;

col		= jet(nVel);
P		= zeros(nVel,length(xi));
mxPindx = zeros(nVel,1);
prcL	= zeros(nVel,3);
for ii = 1:nVel
	sel		= V==uVel(ii);
	if sum(sel)
		mu(ii) = median(L(sel));
		sd(ii) = std(L(sel));
		[D,XI] = ksdensity(L(sel),xi,'function','cdf');
		% 		D = D./max(D);
		subplot(211);
		plot(XI,D,'Color',col(ii,:),'LineWidth',2);
		% 		D= D./sum(D);
		hold on
		n = sum(sel);
		title(n);
		P(ii,:) = D;
		[~,mxPindx(ii)] = max(D);
		prcL(ii,:) = prctile(L(sel),[25 50 75]);
		% 		if ismember(ii,18:-2:12 )
		if ismember(ii,1:2:7 )
			
			subplot(212);
			plot(XI,D,'Color',col(ii,:),'LineWidth',2);
			hold on
			
		end
		
		
	end
end


