function rip_fitcdf3
%% Clean
close all
clear all
clc

% p.dt		= 0.001;  %step size for simulations (seconds)
% nSteps		= 600; %number of time steps



sub		= 3; % subject nr
mod		= 100; % modulation depth (%)
[RT,MF]	= getdata(sub,mod);


%%
%% Initial parameters (see also RIP_DIFFUSIONMODELEXAMPLE.M)
Par(1)	= .12; % decision level (units)
Par(2)	= .1; % standard deviation of drift (units/sec)
Par(3)	= 1.3; % drift rate (units/sec)
Par(4)	= 0.100;  % indecision time (sec)

uMF = unique(MF);
n	= size(uMF,2);
p	= 0.05:0.05:0.95;
O	= diff(p);
P	= NaN(n,numel(O));
par = struct([]);
for ii = 1:n
% 	disp(ii)
	tic;
	sel = MF==uMF(ii);
	rt = RT(sel);
	q	= quantile(rt,p);

	figure
	plotpar(q,p,Par)
	drawnow
	toc	
	
% 	Par		= fitfun(O,Par,q);
% 	par(ii).Par = Par;
% 	Y = fun(Par,q);
% 	P(ii,:) = Y;
% 	
% 	figure(666+ii)
% 	plot(q(1:end-1),cumsum(Y),'r-');
% 	hold on
% 	plot(q(1:end-1),cumsum(O));

	return
	pause
	
end
return
keyboard
figure
imagesc(cumsum(P)); shading flat
axis square
colorbar
set(gca,'Ydir','normal');
a = [par.Par]
b = reshape(a',4,18);

figure
subplot(221)
plot(b(1,:));
axis square;
ax = axis;
ylim([0 ax(4)]);

subplot(222)
plot(b(2,:));
axis square;
ax = axis;
ylim([0 ax(4)]);

subplot(223)
plot(b(3,:));
axis square;
ax = axis;
ylim([0 ax(4)]);

subplot(224)
plot(b(4,:));
axis square;
ax = axis;
ylim([0 ax(4)]);



keyboard

function Prop =  fun(Par,q)
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

p.a		= Par(1);
p.s		= Par(2);
p.u		= Par(3);
p.te	= Par(4);
xi		= 0:.5:2900;
p.dt	= unique(diff(xi))/1000;

nReps		= 20000; %number of staircases per simulation
nSteps		= numel(xi); %number of time steps

dy			= p.u*p.dt + p.s*sqrt(p.dt)*randn(nSteps,nReps);
%The random walk is a cumulative sum of the steps (dy)
y			= cumsum(dy);
t			= p.dt:p.dt:p.dt*nSteps; %time vector for x-axis

%% Reaction time
indx		= y>p.a;
[~,indx]	= max(indx,[],1);

RT			= t(indx);
sel			= RT==p.dt;
RT			= RT(~sel);
RT			= RT+p.te;
RT			= RT*1000;

nq			= numel(q);
n			= numel(RT);
Prop		= NaN(nq-1,1);
for ii = 1:nq-1
	sel		= RT>=q(ii) & RT<=q(ii+1);
	Prop(ii)	= sum(sel)./n;
end

function Par	= fitfun(O,Inipar,q)
opt			= optimset('MaxFunEvals',200*numel(Inipar)*4);
% opt = [];
Par			= fminsearch(@errfun,Inipar,opt,O,q);

function chisq	=  errfun(Par,O,q)
E		= fun(Par,q)';
chisq	= sum(((O-E).^2)./E); % err				= norm(Y-E);

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
sel = L<2900 & L>0 ;
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

YTick	= 1:length(uVel);
xi		= 0:10:2900;

col		= jet(nVel);
fct		= 0.006;
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
			
			% 		[H,xih] = ksdensity(L(sel),xih,'function','cumhazard');
			% % 		[Dc,XI] = ksdensity(L(sel),xi,'function','cdf');
			% % 		H = Dp./Dc;
			% 		subplot(223);
			% 		plot(xih,gradient(H),'Color',col(ii,:),'LineWidth',2);
			% 		hold on
		end
		
		
	end
end

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

function plotpar(q,p,Par)

dq		= diff(q);
dp		= diff(p)';
muq		= (q(1:end-1)+q(2:end))/2;
E		=  fun(Par,q);

subplot(211);
plot(muq,cumsum(dp),'ko-','MarkerFaceColor','w');
hold on;
plot(muq,cumsum(E),'r-')
xlim([100 500]);

subplot(212);
plot(muq,dp,'ko-','MarkerFaceColor','w');
hold on;
plot(muq,E,'ro-')
ylim([0 0.2])
xlim([100 500]);
whos dp E
chisq = sum((dp-E).^2./E);
title(chisq);