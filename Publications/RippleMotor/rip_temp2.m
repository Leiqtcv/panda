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
mu = NaN(nsubs,1);
for ii = 1:nsubs
	sel = S==ii;
	mu(ii) = median(L(sel));
	L(sel) = L(sel)-mu(ii);
end
%% all
figure(1)
densplot(L,'k',0,'true');
vel		= abs(V);
uVel	= unique(vel);
nVel	= numel(uVel);
col		= jet(nVel);
mu		= NaN(nVel,1);
Dmax	= mu;
yt		= (1:nVel)*0.01;

for ii = 1:nVel
	sel		= V==uVel(ii);
	figure(2)
	subplot(121)
	[D,XI]		= densplot(L(sel),col(ii,:),yt(ii));
	% 	mu(ii) = mode(round(L(sel)/10)*10);
	mu(ii) = median(L(sel));
	
	[Dmax(ii),indx] = max(D);
	plot([XI(indx) XI(indx)],[yt(ii) yt(ii)+Dmax(ii)],'Color',col(ii,:));
	% 	plot([XI(indx)+1000/uVel(ii) XI(indx)+1000/uVel(ii)],[yt(ii) yt(ii)+0.01]);
	% 	plot([XI(indx)+250/uVel(ii) XI(indx)+250/uVel(ii)],[yt(ii) yt(ii)+0.01]);
	% 	plot([XI(indx)+500/uVel(ii) XI(indx)+500/uVel(ii)],[yt(ii) yt(ii)+0.01]);
	% 	plot([XI(indx)+750/uVel(ii) XI(indx)+750/uVel(ii)],[yt(ii) yt(ii)+0.01]);
	
	figure(3)
	sel = D>2*1e-3;
	% plot(D(sel)+0.05*ii,XI(sel),'Color',col(ii,:));
	hold on
	% plot(-D(sel)+0.05*ii,XI(sel),'Color',col(ii,:));
	X = [0.05*ii D(sel)+0.05*ii 0.05*ii 0.05*ii -D(sel)+0.05*ii 0.05*ii]';
	mn = min(XI(sel));
	mx = max(XI(sel));
	
	Y = [mn XI(sel) mx mn XI(sel) mx]';
	% whos X Y
	% [Y,indx] = sort(Y);
	% X = X(indx);
	h = patch(X',Y',col(ii,:));
	alpha(h,0.4);
	set(h,'EdgeColor',col(ii,:));
	
end

figure(2)
plot(mu,Dmax+yt','ko-','MarkerFaceColor','w')
xlim([-500 2000]);
set(gca,'YTick',yt);
% grid on
box off
axis square

subplot(122)
plot(uVel,mu,'ko-','MarkerFaceColor','w');
box off
axis square
set(gca,'XScale','log','XTick',uVel,'XTickLabel',uVel);
xlim([0.25 256]);

figure(3)
Xtick = 0.05*(1:length(mu));
plot(Xtick,mu,'ko-','MarkerFaceColor','w','LineWidth',2);

axis square;
box off
ylim([-200 600]);
ylabel('Reaction time (ms)');
xlabel('Modulation frequency (Hz)');
set(gca,'XTick',Xtick','XTickLabel',uVel);
pa_datadir;
print('-depsc','-painter',[mfilename 'all']);

%%
mod = 100;

uVel = sort([-pa_oct2bw(0.5,0:1:8) 0 pa_oct2bw(0.5,0:1:8)]);
nVel	= numel(uVel);
mu		= NaN(nVel,1);
sd		= mu;
XTick	= 1:length(uVel);
for ii = 1:nVel
	sel			= V==uVel(ii) & E==1 & H==1 & M==mod;
	mu(ii)		= median(L(sel));
	sd(ii)		= 1.96*std(L(sel))./sqrt(sum(sel));
	
end
figure(4)
errorbar(XTick,mu,sd,'ro-','MarkerFaceColor','w');
hold on

mu		= NaN(nVel,1);
sd		= mu;
for ii = 1:nVel
	sel			= V==uVel(ii) & E==2 & H==2  & M==mod;
	mu(ii)		= mean(L(sel));
	sd(ii)		= 1.96*std(L(sel))./sqrt(sum(sel));
	
end
figure(4)
errorbar(XTick,mu,sd,'ko-','MarkerFaceColor','w');
hold on


mu		= NaN(nVel,1);
sd		= mu;
for ii = 1:nVel
	sel			= V==uVel(ii) & E==1 & H==2  & M==mod;
	mu(ii)		= mean(L(sel));
	sd(ii)		= 1.96*std(L(sel))./sqrt(sum(sel));
	
end
figure(4)
errorbar(XTick,mu,sd,'gd-','MarkerFaceColor','w');
hold on

mu		= NaN(nVel,1);
sd		= mu;
for ii = 1:nVel
	sel			= V==uVel(ii) & E==2 & H==1  & M==mod;
	mu(ii)		= mean(L(sel));
	sd(ii)		= 1.96*std(L(sel))./sqrt(sum(sel));
	
end
figure(4)
errorbar(XTick,mu,sd,'cd-','MarkerFaceColor','w');
hold on


box off
set(gca,'XTick',XTick,'XTickLabel',uVel);
box off
xlim([0 length(uVel)+1]);
pa_verline((length(uVel)+1)/2);


P		= NaN(nVel,1);

selm = M==mod;
sele2 = E==2;
selh2 = H==2;
sele1 = E==1;
selh1 = H==1;
for ii = 1:nVel
	selv = V==uVel(ii);
	
	sel2		= selv & sele2 & selh2  & selm;
	sel1		= selv & sele1 & selh1  & selm;
	% 		[p,t] = tutest(L(sel1), L(sel2));
	[h,p] = kstest2(L(sel1), L(sel2));
	
% 	[h,p] = ttest2(L(sel1), L(sel2));
	P(ii) = p;
	if p<0.05
		plot(XTick(ii),mu(ii)+20,'kh');
	end
end
P
ylim([-100 200]);
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