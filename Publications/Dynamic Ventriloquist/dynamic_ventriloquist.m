function dynamic_ventriloquist
close all
clear all
clc

%% Subject
subject = 5;
switch subject
	case 1
		cd('E:\DATA\Audiovisual\Audiovisual Reference Frame\MW-RG-2012-03-18'); % datadir
		fname = 'MW-RG-2012-03-18-0001';
	case 2
		cd('E:\DATA\Audiovisual\Audiovisual Reference Frame\MW-DM-2012-04-20');			% subject
		fname = 'MW-DM-2012-04-20-0001';
	case 3
		cd('E:\DATA\Audiovisual\Audiovisual Reference Frame\MW-RO-2012-04-25');			% subject
		fname = 'MW-RO-2012-04-25-0001';
	case 4
		cd('E:\DATA\Audiovisual\Audiovisual Reference Frame\MW-L1-2012-04-26');			% subject
		fname = 'MW-L1-2012-04-26-0001';
	case 5
		cd('E:\DATA\Audiovisual\Audiovisual Reference Frame\MW-RM-2012-04-26');			% subject
		fname = 'MW-RM-2012-04-26-0001';
	case 6
		cd('E:\DATA\Audiovisual\Audiovisual Reference Frame\MW-BK-2012-04-26');			% subject
		fname = 'MW-BK-2012-04-26-0001';
	case 7
		cd('E:\DATA\Audiovisual\Audiovisual Reference Frame\MW-LV-2012-05-01');			% subject
		fname = 'MW-LV-2012-05-01-0001';
	case 8
		cd('E:\DATA\Audiovisual\Audiovisual Reference Frame\MW-RE-2012-05-01');			% subject
		fname = 'MW-RE-2012-05-01-0001';
	case 9
		cd('E:\DATA\Audiovisual\Audiovisual Reference Frame\MW-JR-2012-05-01');			% subject
		fname = 'MW-JR-2012-05-01-0001';
end

%% Flags
eyeflag		= 1;
printflag	= 0;
legflag		= 0;
patchflag	= 1;
regflag		= 0;
robustflag	= 0;

%% Data
S		= load(fname);
Sac		= S.Sac;
Stim	= S.Stim;
Sac		= pa_lastsac(Sac);
A		= pa_supersac(Sac,Stim,2,1);
Ei	= pa_supersac(Sac,Stim,0,2); Ei = Ei(:,24);
V	= pa_supersac(Sac,Stim,0,3);
A(:,9) = A(:,9)-mean(A(:,9)-A(:,24));


figure(1)
subplot(221)
pa_plotloc(A);
[Ymu,Ysd,uX] = pa_loc(A(:,24), A(:,9),[-60 60 -60 60]);
xlabel('Sound location (deg)');
ylabel('Response location (deg)');
set(gca,'XTick',-50:25:50);
set(gca,'YTick',-50:25:50);
h = pa_unityline;
set(h,'LineStyle','-','Color',[.7 .7 .7]);
subplot(222)
hist(A(:,5),-100:20:1000);
axis square;
pa_verline(median(A(:,5)),'r-');
xlim([100 400]);
title(median(A(:,5)));
colormap gray
ylabel('N');
xlabel('Reaction time (ms)');

figure(777)
subplot(2,6,1)
DISP = A;
DISP(:,9) = DISP(:,24)-DISP(:,9);
DISP(:,24) = DISP(:,24)-V(:,24);

pa_plotloc(DISP);
xlabel('Audiovisual disparity (deg)');
ylabel('Response location (deg)');
set(gca,'XTick',-50:25:50);
set(gca,'YTick',-50:25:50);

ME = A;
ME(:,9) = ME(:,11);
ME(:,24) = ME(:,24)-Ei;

subplot(2,6,7)
pa_plotloc(ME);
xlabel('Eye Motor Error');
ylabel('Response amplitude (deg)');
set(gca,'XTick',-50:25:50);
set(gca,'YTick',-50:25:50);
axis([-70 70 -70 70]);
pa_unityline;
hold on
x = unique([round(ME(:,24)/5)*5 round(A(:,24)/5)*5],'rows');
% whos x
% plot(x(:,1),x(:,2),'k.','LineWidth',2);
D = V(:,24)-A(:,24);
uD = unique(D);
nD = numel(uD);
uE = unique(Ei);
nE = numel(uE);
uD = fliplr(uD);

separablefig(D,Ei,uD,uE,nD,nE,A,uX,Ymu,Ysd)
% return

%%
figure(999)
subplot(131)
col = jet(nD);
for ii = 1:nD
	sel = D == uD(ii);
	x = A(sel,24);
	y = A(sel,9);
	
	% 	x = round(x/15)*15;
	
	ux = unique(x);
	nx = numel(ux);
	Y = ux;
	Ysd = Y;
	for jj = 1:nx
		sel = x == ux(jj);
		Y(jj) = mean(y(sel));
		Ysd(jj) = mean(y(sel))./sqrt(sum(sel));
	end
	% 	h(ii) = errorbar(ux,Y,Ysd,'o-','Color','k','MarkerFaceColor',col(ii,:));
	h(ii) = plot(ux,Y,'o-','Color','k','MarkerFaceColor',col(ii,:));
	hold on
end
axis square;
axis([-45 45 -45 45]);
pa_unityline('k-');
box off
xlabel('Target location (deg)');
ylabel('Response location (deg)');
title('S1');
pa_text(0.1,0.9,char(65+32));
set(gca,'XTick',-40:20:40,'YTick',-40:20:40);
title('Audiovisual disparity');
if legflag
	legend(h,num2str(uD),'Location','SE');
end
if patchflag
	patchplot;
end

subplot(132)
% pa_plotloc(A);
col = jet(nE);

for ii = 1:nE
	sel = Ei == uE(ii) & abs(A(:,24))<=100;
	x	= A(sel,24);
	y	= A(sel,9);
	ux	= unique(x);
	nx	= numel(ux);
	Y	= ux;
	Ysd = Y;
	for jj = 1:nx
		sel = x == ux(jj);
		Y(jj) = mean(y(sel));
		
		Ysd(jj) = mean(y(sel))./sqrt(sum(sel));
	end
	% 	h(ii) = errorbar(ux,Y,Ysd,'o-','Color','k','MarkerFaceColor',col(ii,:));
	h(ii) = plot(ux,Y,'o-','Color','k','MarkerFaceColor',col(ii,:));
	
	hold on
end
axis square;
axis([-45 45 -45 45]);
pa_unityline('k-');
box off
xlabel('Target location (deg)');
ylabel('Response location (deg)');
pa_text(0.1,0.9,char(66+32));
set(gca,'XTick',-40:20:40,'YTick',-40:20:40);
title('Eye position');
if legflag
	legend(h,num2str(uE),'Location','SE');
end
if patchflag
	patchplot
end
k = 0;
bias = NaN(nD,nE);

for ii = 1:nD
	for jj = 1:nE
		k = k+1;
		sel = D == uD(ii) & Ei==uE(jj);
		eye = A(sel,:);
		rt	= eye(:,5);
		
		figure(666)
		subplot(5,5,k)
		pa_plotloc(eye);
		sel = eye(:,24)==uE(jj);
		plot(uE(jj),mean(eye(sel,9)),'ro','LineWidth',2);
		axis([-60 60 -60 60]);
		plot([-50 50],[-50 50]+uD(ii),'k-','LineWidth',2);
		if eyeflag
			pa_verline(uE(jj));
			pa_horline(uE(jj));
			plot(uE(jj),uE(jj),'ro','MarkerFaceColor','w','LineWidth',2);
		end
		ylabel(uD(ii));
		xlabel(uE(jj));
		
		x = eye(:,24);
		y = eye(:,9);
		b = regstats(y,x,'linear','beta');
		bias(ii,jj) = b.beta(1);
		if robustflag
			b = robustfit(x,y); %#ok<*UNRCH>
			bias(ii,jj) = b(1);
		end
		RT(ii,jj) = median(rt);
	end
end
bias = bias-median(bias(:));
figure(999)
subplot(133)
imagesc(uD,uE,bias);
axis square;
mx = max(abs(bias(:)));
% caxis([-mx mx]);
caxis([-20 20]);
% colorbar
% colormap gray
hold on
set(gca,'XTick',uE,'YTick',uD);
xlabel('Eye position (deg)');
ylabel('Audiovisual disparity (deg)');
set(gca,'YAxisLocation','right');

for ii = 1:3
	subplot(1,3,ii)
	set(gca,'YDir','normal','TickDir','out');
	box off
end

% subplot(224)
% pcolor(uD,uE,bias)
if printflag
	pa_datadir
	print('-depsc','-painter',mfilename);
	
	colorbar
	print('-depsc','-painter',[mfilename 'bar']);
end
% return
%%

subplot(222)
x = -100:5:100;
y = A(:,9)-Ei;
hist(y,x);
pa_verline;
axis square;

subplot(223)
x = bias(:);
y = RT(:);
beta0 = [0.1 -10 200];
beta = nlinfit(x,y,@rtbias,beta0);

plot(x,y,'k.');
hold on
axis square;
x = -30:30;
ypred = rtbias(beta,x);
plot(x,ypred,'r-','LineWidth',2);
axis([-30 30 180 270]);
xlabel('Bias (deg)');
ylabel('Reaction time (ms)');

% axis([-30 30 100 500]);
% subplot(223)
% x = 100:20:1000;
% y = A(:,5);
% hist(y,x);
% pa_verline;
% axis square;
% xlim([100 500]);
% pa_verline(median(y));

subplot(224)
imagesc(uD,uE,RT);
axis square;
mx = max(abs(bias(:)));
% caxis([-mx mx]);
colorbar
% colormap gray
hold on
set(gca,'YDir','normal','TickDir','out');

function pa_plotloc(input,varargin)

% PA_PLOTLOC(INPUT)
%   Plots the response vs stimulus for azimuth and elevation.
%   INPUT should be either a (split-off of a) SupSac-file or
%   Location Data ([Stim_az Resp_az Stim_el Resp_el]).
%
% Optional input arguments:
% PA_PLOTLOC(...,'WHICH',WHICH)
%   Plot either azimuth ('az') or elevation ('el') is plotted. Default is
%   both.
% PA_PLOTLOC(...,'RANGE',RANGE)
%   RANGE is used to indicate the range of the stimuli.
%  Default value is [-60 60 -60 60].
%
% See also PA_LOC


% 2011  Marcus
% e-mail: marcvanwanrooij@neural-code.com

%% Optional arguments:
% simple regression (default) or a robust fitting procedure
range         = pa_keyval('range',varargin);
if isempty(range)
	range = [-90 90 -90 90];
end

%%
if (size(input,2)==4)
	LocData           = input;
else
	LocData          = input(:,[23 8 24 9]);
end

pa_loc(LocData(:,3), LocData(:,4),range);





function [Ymu,Ysd,uX] = pa_loc(Xpoints,Ypoints,range)

% [CORR,CORERR,GAIN,GAINERR,FITERR,LOCERR,BIAS,INSIGNERR] =
%            LOC(XPOINTS,YPOINTS,WHICH,RANGE,INC)
%
% LOC has a two-fold function:
%
% a) Plot X vs Y, usually Stimulus-azimuth vs Response-azimuth
% b) Performs linear regression on X and Y:
%        Y=aX+b
%    and returns Correlation, Gain (a), bias (b), their respective errors,
%    and the number of data points.
%
% RANGE states the range in which the Data-points can vary; a data-point
% with a larger range is discarded for further analysis in this m-function.
% This is necessary, especially when responses fall outside the unambiguous
% range created by the magnetic fields.
% RANGE is optional, as is INC, which is used for determining XTicks.
% Default value is [-60 60 -60 60].
% WHICH consists of 'az' or 'el', and is also optional.
%
%

% (c) 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@gmail.com


if (nargin<4)
	range   = [-90 90 -90 90];
end

%% Regression
% b                           = robustfit(Xpoints,Ypoints);
b = regstats(Ypoints,Xpoints,'linear','beta');
b = b.beta;
gain                        = b(2);
bias                        = b(1);

%% Mean
uX	= unique(Xpoints);
nX	= numel(uX);
Y	= NaN(size(uX));
Ysd = Y;
for ii = 1:nX
	sel		= Xpoints == uX(ii);
	Y(ii)	= mean(Ypoints(sel));
	Ysd(ii) = std(Ypoints(sel))/sqrt(sum(sel));
end
Ymu		= Y;

%% Graphics
% h   = plot(range([1 2]), range([3 4]), 'k-'); set(h,'LineWidth',1,'Color',[0.7 0.7 0.7]);
hold on;
h	= errorbar(uX, Y, Ysd, 'ko-'); set(h,'MarkerSize', 7, 'LineWidth',1,'MarkerFaceColor','w');
axis(range);
axis square;
box on;
axis([-60 60 -60 60]);

bias	= round(bias);
if bias>=0
	linstr = ['Y = ' num2str(gain,2) 'X + ' num2str(round(bias),2)];
else
	linstr = ['Y = ' num2str(gain,2) 'X - ' num2str(abs(round(bias)),2)];
end
pa_text(0.1,0.9,linstr);
set(gca, 'YTick', []);
set(gca, 'XTick', []);

function patchplot
ax = axis;
plot([ax(1) ax(2)],[ax(1)+20 ax(2)+20],'r-','LineWidth',2);
plot([ax(1) ax(2)],[ax(1)-20 ax(2)-20],'b-','LineWidth',2);
X = ax([1 2]);
x           = [X fliplr(X)];
y = [X+20  fliplr(X)];
hpatch           = patch(x,y,'r');
alpha(hpatch,0.3);
set(hpatch,'EdgeColor','none');
X = ax([1 2]);
x           = [X fliplr(X)];
y = [X-20  fliplr(X)];
hpatch           = patch(x,y,'b');
alpha(hpatch,0.3);
set(hpatch,'EdgeColor','none');

function Y = rtbias(beta,X)
Y = beta(1)*(X+beta(2)).^2+beta(3);

function separablefig(D,Ei,uD,uE,nD,nE,A,uX,Ymu,Ysd)
k = 1;
X = [];
Y = [];
for ii = 1:nD
	k = k+1;
	sel = D == uD(ii);
	eye = A(sel,:);
	Dsel = D(sel);
	
	figure(777)
	subplot(2,6,k)
	[mu,~,x] = pa_loc(eye(:,24), eye(:,9),[-60 60 -60 60]);
	[~,ia,ib] = intersect(x,uX);
	V = x+uD(ii);
	PD = abs(round(V(ia)-Ymu(ib)));
	xi = x(ia);
	mui = mu(ia);
	PDi = PD(ia);
	Vi = V(ia);
	[xi mui Vi Ymu(ib) PDi];
	PDi = PDi+1;
	max(PDi)
	col = gray(40);
	n = numel(xi);
	
	for jj = 1:n
		plot(xi(jj),mui(jj),'ko','MarkerFaceColor',col(PDi(jj),:));
	end
	axis([-60 60 -60 60]);
	plot([-60 60],[-60 60]+uD(ii),'k-','LineWidth',2);
	title(uD(ii));
	
	% 	sel = eye(:,24)<=0;
	% 	x = eye(sel,24);
	% 	y = eye(sel,9);
	% 	b = regstats(y,x,'linear','beta');
	% 	x_lim = [-60 0];
	% 	X = [ones(size(x_lim))' x_lim'];
	% 	Y = X*b.beta;
	% 	plot(x_lim,Y,'r-','LineWidth',2);
	%
	% 	sel = eye(:,24)>=0;
	% 	x = eye(sel,24);
	% 	y = eye(sel,9);
	% 	b = regstats(y,x,'linear','beta');
	% 	x_lim = [0 60];
	% 	X = [ones(size(x_lim))' x_lim'];
	% 	Y = X*b.beta;
	% 	plot(x_lim,Y,'r-','LineWidth',2);
	
	% 	x = eye(:,24);
	% 	y = eye(:,9);
	% 	xi = -90:5:90;
	% 	[mu,se,xi] = pa_weightedmean(x,y,10,xi,'nboot',10);
	% 	pa_errorpatch(xi',mu',se','r');
	
	plot(uX,Ymu,'k-','Color',[.7 .7 .7],'LineWidth',2);
	
	figure(777)
	subplot(2,6,1)
	[~,ia,ib] = intersect(x,uX);
	V = x+uD(ii);
	PD = round(V(ia)-Ymu(ib));
	% 	PD = round(V(ia)-x(ia));
	xi	= x(ia);
	mui = mu(ia);
	PDi = PD(ia);
	Vi	= V(ia);
	PDi = PDi+1;
	% 	plot(PDi,-Ymu(ib)+mu,'k.');
	% 	hold on
	
	X = [X;PDi];
% 	X = [X;uD(ii)];
	
	Y = [Y;-Ymu(ib)+mu];
	
end

xi = -40:10:40;
[mu,se,xi] = pa_weightedmean(X,Y,5,xi,'nboot',100);
% pa_errorpatch(xi',mu',se','r');
whos mu xi se
% errorbar(xi,mu,mean(se,2),'ko-','MarkerFaceColor','w');
axis([-30 30 -30 30]);
axis square;
pa_horline;
% 	pa_verline;
pa_unityline;

figure(1)
subplot(223)
hist(abs(X),0:5:40);
% 	X
num = sum(abs(X)<10)
den = length(X)
N = num/den*100;
md = round(mean(abs(X)));
pa_verline(md,'r-');
pa_verline(10,'b-');
title(N);
axis square;

k = 1;
for jj = 1:nE
	k = k+1;
	sel = Ei==uE(jj);
	eye = A(sel,:);
	
	figure(777)
	subplot(2,6,k+6)
	[mu,~,x] = pa_loc(eye(:,24), eye(:,9),[-60 60 -60 60]);
	
	axis([-60 60 -60 60]);
	% 		plot([-50 50],[-50 50]+uD(ii),'k-','LineWidth',2);
	h = pa_horline(uE(jj),'k-'); set(h,'LineWidth',2);
	xlabel(uE(jj));
	sel = eye(:,24)==uE(jj);
	plot(uE(jj),mean(eye(sel,9)),'ro','LineWidth',2);
	
	% 	pa_horline;
	
	sel = eye(:,24)<=0;
	x = eye(sel,24);
	y = eye(sel,9);
	b = regstats(y,x,'linear','beta');
	x_lim = [-60 0];
	X = [ones(size(x_lim))' x_lim'];
	Y = X*b.beta;
	plot(x_lim,Y,'r-','LineWidth',2);
	
	sel = eye(:,24)>=0;
	x = eye(sel,24);
	y = eye(sel,9);
	b = regstats(y,x,'linear','beta');
	x_lim = [0 60];
	X = [ones(size(x_lim))' x_lim'];
	Y = X*b.beta;
	plot(x_lim,Y,'r-','LineWidth',2);
	
	% 		x = eye(:,24);
	% 	y = eye(:,9);
	% 	xi = -90:5:90;
	% 	[mu,se,xi] = pa_weightedmean(x,y,10,xi,'nboot',10);
	% 	pa_errorpatch(xi',mu',se','r');
end
