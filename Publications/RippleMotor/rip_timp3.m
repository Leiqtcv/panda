function tmp
%% Clean
close all
clear all

subs	= [1 2 4 5 6 8 9 10 13 14 15 16 17 18 19 21];
nsubs	= numel(subs);
hands	= {'left';'right'};
nhand	= numel(hands);
ears	= {'left';'right';'both'};
near	= numel(ears);

pa_datadir;
load('rippledata');
Subject
V = [];
L = [];
H = [];
E = [];
S = [];
M = [];
for ii = 1:nsubs
	for jj = 1:nhand
		for kk = 1:near
			vel = Subject(ii).hand(jj).ear(kk).velocity;
			lat = Subject(ii).hand(jj).ear(kk).reactiontime;
			md = Subject(ii).hand(jj).ear(kk).md;
			V = [V vel];
			L = [L lat];
			H = [H repmat(jj,size(vel))];
			E = [E repmat(kk,size(vel))];
			S = [S repmat(ii,size(vel))];
			M = [M md];
		end
	end
end
sel = L<2900 & L>0 ;
L = L(sel);
S = S(sel);
H = round(H(sel));
E = round(E(sel));
V = round(V(sel)*2)/2;
M  = round(M(sel));


mod = 100;
for ii = 1:nsubs
	subplot(4,4,ii)
	sel		= ismember(E,1:4) & M==mod & S==ii;
	plotreactvsvel(V(sel),L(sel),'k')
	hold on
	ylim([100 700])
end


%% subject
figure
sub = 1;
mod = 100;
	sel		= ismember(E,1:4) & M==mod & S==sub;
V = V(sel);
L = L(sel);
uVel = sort([-pa_oct2bw(0.5,0:1:8) 0 pa_oct2bw(0.5,0:1:8)]);
uVel = sort(uVel);
% V = 1./V;
nVel	= numel(uVel);
mu		= NaN(nVel,1);
sd		= mu;
XTick = 1:length(uVel);
xi = -1000:5:4000;
for ii = 1:nVel
	sel		= V==uVel(ii);
	mu(ii) = median(L(sel));
	sd(ii) = std(L(sel));
	[D,XI] = ksdensity(L(sel),xi);
% subplot(4,4,ii);
plot(XI,D+0.002*ii);
hold on
n = sum(sel);
title(n);
end

function plotreactvsvel(V,L,col)

uVel = sort([-pa_oct2bw(0.5,0:1:8) 0 pa_oct2bw(0.5,0:1:8)]);
uVel = sort(uVel);
% V = 1./V;
nVel	= numel(uVel);
mu		= NaN(nVel,1);
sd		= mu;
XTick = 1:length(uVel);
for ii = 1:nVel
	sel		= V==uVel(ii);
	mu(ii) = median(L(sel));
	sd(ii) = std(L(sel));
	
end
errorbar(XTick,mu,sd,'o-','MarkerFaceColor','w','Color',col);
hold on
set(gca,'XTick',XTick,'XTickLabel',uVel);
pa_verline(round(length(uVel)/2));

function [D,XI] = densplot(L,col,raise,barFlag)
if nargin<4
	barFlag = false;
end
%% Density
xi = -1000:5:4000;
[D,XI] = ksdensity(L,xi);
D = D./sum(D);
if barFlag
	[N,xi] = hist(L,xi);
	N = N./sum(N);
	bar(xi,N,1,'FaceColor',[.7 .7 .7],'EdgeColor','none');
end
hold on
plot(XI,D+raise,'k-','LineWidth',2,'Color',col);
xlim([-1000 4000]);
xlabel('Reaction time (ms)');
ylabel('P');
box off;
axis square;