function rip_fitcdf1
%% Clean
close all
clear all
clc
Par(1)		= .1; % decision level
Par(2)		= .1; % standard deviation of drift (units/sec)
Par(3)		= 1; % drift rate (units/sec)
Par(4)		= 0.100;  % indecision time
p.dt= 0.001;  %step size for simulations (seconds)

nSteps		= 600; %number of time steps

[Y,XI,RT,y,t]	= fun(Par);
data			= getdata;

figure
plot(XI,data,'-');
hold on
plot(XI,Y,'k-','linewidth',2);

n = size(data,1);
P = NaN(size(data));
p = struct([]);
for ii = 1:n
	disp(ii)
	tic;
	dat = data(ii,:);
	Par		= fitfun(dat,Par);
	p(ii).Par = Par;
	[Y,XI] = fun(Par);
	
% 	figure(666+ii)
% 	subplot(121)
% 	plot(XI,Y,'r-');
% 	hold on
% 	plot(XI,dat,'k-')
% 	
% 	subplot(122)
% 	plot(XI,gradient(Y),'r-');
% 	hold on
% 	plot(XI,gradient(dat),'k-')
% 	drawnow
	
	P(ii,:) = Y;
	toc
end
figure
imagesc(gradient(P)'); shading flat
axis square
colorbar
set(gca,'Ydir','normal');
a = [p.Par]
b = reshape(a',4,18);

figure
subplot(221)
plot(b(1,:));
axis square;

subplot(222)
plot(b(2,:));
axis square;

subplot(223)
plot(b(3,:));
axis square;

subplot(224)
plot(b(4,:));
axis square;



keyboard
function [Y,XI,RT,y,t] =  fun(Par)
%% Generative Model
% sX		= Par(:,1);
% sp		= Par(:,2);
% SX		= sX;
% SP		= sp;
% Slope	= (1./SX)./(1./SX+1./SP);
% STD		=  ((SP./(SX+SP))./(1./SX+1./SP));
% Y		= [Slope STD];

% p.a = .3;  %upper bound (correct answer)
% p.s = .3;   %standard deviation of drift (units/sec)
% p.u = 0.3; %drift rate (units/sec)
% p.dt		= .005;  %step size for simulations (seconds)

p.a = Par(1);
p.s = Par(2);
p.u = Par(3);
p.te = Par(4);
p.dt = 0.001;

nReps		= 1000; %number of staircases per simulation
nSteps		= 600; %number of time steps

dy			= p.u*p.dt + p.s*sqrt(p.dt)*randn(nSteps,nReps);
%The random walk is a cumulative sum of the steps (dy)
y			= cumsum(dy);

t			= p.dt:p.dt:p.dt*nSteps; %time vector for x-axis

indx		= y>p.a;
[~,indx]	= max(indx,[],1);

RT			= t(indx);
sel			= RT==p.dt;
RT(sel)		= 3;
RT = RT(~sel);
RT = RT+p.te;
RT = RT*1000;
xi = 0:600;

[Y,XI] = ksdensity(RT,xi,'function','cdf');

function Par	= fitfun(Y,Inipar)
if nargin<2
	Inipar(1)	= 10;
	Inipar(2)	= 10;
end
Par				= fminsearch(@errfun,Inipar,[],Y);

function err	=  errfun(Par,Y)
E = fun(Par);
% err				= norm(Y-E);
err = sum(((Y-E).^2)./E);

function data = getdata


subs	= [1 2 4 5 6 8 9 10 13 14 15 16 17 18 19 21];
nsubs	= numel(subs);
hands	= {'left';'right'};
nhand	= numel(hands);
ears	= {'left';'right';'both'};
near	= numel(ears);
sub = 5;
mod = 100;

pa_datadir;
load('rippledata');
Subject
V = [];
L = [];
% H = [];
E = [];
S = [];
M = [];
for ii = 1:nsubs
	for jj = 1:nhand
		for kk = 1:near
			vel = Subject(ii).hand(jj).ear(kk).velocity;
			lat = Subject(ii).hand(jj).ear(kk).reactiontime;
			md = Subject(ii).hand(jj).ear(kk).md;
			V = [V vel]; %#ok<*AGROW>
			L = [L lat];
			% 			H = [H repmat(jj,size(vel))];
			E = [E repmat(kk,size(vel))];
			S = [S repmat(ii,size(vel))];
			M = [M md];
		end
	end
end
sel = L<2900 & L>0 ;
L = L(sel);
S = S(sel);
% H = round(H(sel));
E = round(E(sel));
V = round(V(sel)*2)/2;
M  = round(M(sel));

Md = NaN(nsubs,9);
Mu = NaN(nsubs,9);
for ii = 1:nsubs
	figure(1)
	subplot(4,4,ii)
	sel		= ismember(E,1:4) & M==mod & S==ii;
	mu = plotreactvsvel(V(sel),L(sel),'k');
	hold on
	ylim([100 700])
	Md(ii,1:9) = mu(11:end);
	Mu(ii,1:9) = flipud(mu(1:9));
end
figure(2)
plot(Mu,Md,'k-','Color',[.7 .7 .7]);
	plot(Mu,Md,'-');
hold on
plot(Mu,Md,'ko','MarkerFaceColor','k','MarkerSize',7);
xlabel('Median reaction time for upward modulation (ms)');
ylabel('Median reaction time for downward modulation (ms)');
axis square;
box off
axis([100 600 100 600]);
axis square
h = pa_unityline('k:');set(h,'LineWidth',2);
set(gca,'XTick',100:100:600,'YTick',100:100:600);
% b = regstats(Md(:),Mu(:),'linear','all');
% h = pa_regline(b.beta,'k-');
% set(h,'Color',[.7 .7 .7],'LineWidth',2);
% [avg,xavg] = pa_runavg(Mu(:),Md(:));
% [mu,SE,XI] = pa_weightedmean(Mu(:),Md(:),10);
% plot(XI,mu,'k-','Color',[.7 .7 .7],'LineWidth',2);

%% subject
figure
sel		= ismember(E,1:4) & M==mod & S==sub;
V = V(sel);
L = L(sel);
uVel = sort([-pa_oct2bw(0.5,0:1:8) pa_oct2bw(0.5,0:1:8)]);
uVel = sort(uVel);
% V = 1./V;
nVel	= numel(uVel);
mu		= NaN(nVel,1);
sd		= mu;
YTick = 1:length(uVel);
xi = 0:600;
xih = 0:450;

col = jet(nVel);
fct = 0.006;
P = zeros(nVel,length(xi));
mxPindx = zeros(nVel,1);
prcL = zeros(nVel,3);
for ii = 1:nVel
	sel		= V==uVel(ii);
	if sum(sel)
		mu(ii) = median(L(sel));
		sd(ii) = std(L(sel));
		[D,XI] = ksdensity(L(sel),xi,'function','cdf');
		D = D./max(D);
		subplot(211);
		plot(XI,D+fct*ii,'Color',col(ii,:),'LineWidth',2);
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

% 		[H,xih] = ksdensity(L(sel),xih,'function','cumhazard');
% % 		[Dc,XI] = ksdensity(L(sel),xi,'function','cdf');
% % 		H = Dp./Dc;
% 		subplot(223);
% 		plot(xih,gradient(H),'Color',col(ii,:),'LineWidth',2);
% 		hold on
		end
		

	end
end
subplot(211)
ylim([0 fct*(nVel+5)]);

subplot(212)
% ylim([0 fct*(nVel+5)]);

figure
colormap jet
% pcolor(P);
% ci = linspace(0,max(P(:)),20);
% contourf(P,ci);
imagesc(gradient(P)');
hold on
contour(gradient(P)',3,'k');
plot(1:nVel,mxPindx,'w-','MarkerFaceColor','w');
% plot(1:nVel,prcL(:,1),'w-','MarkerFaceColor','w');
% plot(1:nVel,prcL(:,3),'w-','MarkerFaceColor','w');
set(gca,'Ydir','normal');
set(gca,'XTick',YTick,'XTickLabel',uVel,'Ydir','normal');
shading interp
pa_verline((nVel+1)/2,'w:');
axis square;
box off
xlabel('Modulation frequency (Hz)');
ylabel('Reaction time (ms)');
colorbar;
title('P');

data = P;
% shading interp;
function mu = plotreactvsvel(V,L,col)

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

