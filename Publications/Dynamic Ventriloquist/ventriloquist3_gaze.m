function ventriloquist3_gaze
close all
clear all
clc

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
end

eyeflag		= 0;
printflag	= 0;
legflag		= 0;
patchflag	= 0;
regflag		= 0;
robustflag	= 0;
S		= load(fname);
Sac		= S.Sac;
Stim	= S.Stim;
Sac		= pa_lastsac(Sac);
A	= pa_supersac(Sac,Stim,2,1);
Ei	= pa_supersac(Sac,Stim,0,2); Ei = Ei(:,24);
V	= pa_supersac(Sac,Stim,0,3);
%%
pa_datadir
load ventriloquist
% subs		= [1 2 3 4 6];
sub = 6;
sel		= Mod==3 & ismember(Subject,sub);
ss		= SS(sel,:);

%% Parameters
A		= ss;
V		= ss;
V(:,24) = V(:,34);
D		= (V(:,24)-A(:,24));
Hi		= ss(:,31); % Hs
Ei		= round(ss(:,32)); % Eh
% Ei		= ss(:,33); % Eh
Ei = round(Ei/15)*15;
RT		= ss(:,5);

A(:,9) = A(:,9)-mean(A(:,9)-A(:,24));
if regflag
	x = A(:,24);
	y = A(:,9);
	b = regstats(y,x,'linear','beta');
	A(:,9) = A(:,9)/b.beta(2);
end

figure(1)
hist(A(:,9)-Ei,-90:5:90)

figure(777)
subplot(2,6,1)
pa_plotloc(A);
xlabel('Sound location (deg)');
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


D = V(:,24)-A(:,24);
uD = unique(D);
nD = numel(uD);
uE = unique(Ei);
nE = numel(uE);
uD = fliplr(uD);

separablefig(D,Ei,uD,uE,nD,nE,A)


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

		try
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
return
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
which         = pa_keyval('which',varargin);
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

%% Plot
if isempty(which)
	if numel(unique(LocData(:,1)))>2
		if numel(unique(LocData(:,3)))>2
			subplot(121);
		end
		pa_loc(LocData(:,1), LocData(:,2),'az',range);
		%         xlabel('Stimulus azimuth (deg)');
		%         ylabel('Response azimuth (deg)');
		axis square
	end
	if numel(unique(LocData(:,3)))>2
		if numel(unique(LocData(:,1)))>2
			
			subplot(122);
		end
		pa_loc(LocData(:,3), LocData(:,4),'el',range);
		if numel(unique(LocData(:,1)))>2
			set(gca,'YAxisLocation','right');
		end
		%         xlabel('Stimulus elevation (deg)');
		%         ylabel('Response elevation (deg)');
		axis square
	end
elseif strcmpi(which,'az')
	pa_loc(LocData(:,1), LocData(:,2),which,range);
elseif strcmpi(which,'el')
	pa_loc(LocData(:,3), LocData(:,4),which,range);
end




function [corr,gain,gainerr,bias]=pa_loc(Xpoints,Ypoints,which,range,inc)

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

%% Initialization
if (nargin<3)
	which   = 'az';
end
if (nargin<4)
	range   = [-90 90 -90 90];
end
if (nargin<5)
	inc     = 30;
end
numpoints           = sum(Ypoints<range(1) | Ypoints>range(2));
if numpoints
	disp(['Warning: ' int2str(numpoints) ' points fall outside the specified range.']);
	disp('These points are still evaluated in the regression.');
end

%% Regression
b                           = robustfit(Xpoints,Ypoints);
gain                        = b(2);
bias                        = b(1);

Xpoint                      = [Xpoints ones(size(Xpoints))];
% b                           = regress(Ypoints,Xpoint);
% gain                        = b(1);
% bias                        = b(2);
b2                          = bootstrp(100,@regress,Ypoints,Xpoint);
gainerr                     = std(b2(1,:));
% biaserr                     = std(b2(2,:));
corr                        = corrcoef(Xpoints,Ypoints);
corr                        = corr(2);
corrpear                    = pa_pearson(Xpoints,Ypoints);

%% Text
switch which
	case 'az'
		mrkr = '.';
		if bias>0
			linstr              = ['\alpha_R = ' num2str(gain,2) '\alpha_T + ' num2str(bias,2) ];
		elseif bias<=0
			linstr              = ['\alpha_R = ' num2str(gain,2) '\alpha_T - ' num2str(abs(bias),2) ];
		end
	case 'el'
		mrkr = '.';
		if bias>0
			linstr              = ['\epsilon_R = ' num2str(gain,2) '\epsilon_T + ' num2str(bias,2)];
		elseif bias<0
			linstr              = ['\epsilon_R = ' num2str(gain,2) '\epsilon_T - ' num2str(abs(bias),2) ];
		end
end
corrstr                         = ['r^2 = ' num2str(corrpear^2,2)];

%% Graphics
h                           = plot(range([1 2]), range([3 4]), 'k-'); set(h,'LineWidth',1,'Color',[0.7 0.7 0.7]);
hold on;
% h                           = plot(range([1 2]), [0 0], 'k-'); set(h,'LineWidth',1,'Color',[0.7 0.7 0.7]);
% h                           = plot([0 0], range([3 4]), 'k-'); set(h,'LineWidth',1,'Color',[0.7 0.7 0.7]);
h                           = plot(range([1 2]), gain*range([1 2])+bias,'k--'); set(h,'LineWidth',2,'Color',[0.5 0.5 0.5]);
% h                           = plot(Xpoints, Ypoints, ['k' mrkr]); set(h,'MarkerSize', 5, 'LineWidth',2,'MarkerFaceColor','w');

uX = unique(Xpoints);
nX = numel(uX);
Y = NaN(size(uX));
Ysd = Y;
for ii = 1:nX
	sel = Xpoints == uX(ii);
	Y(ii) = mean(Ypoints(sel));
	Ysd(ii) = std(Ypoints(sel))/sqrt(sum(sel));
end

if sum(sel)>5
	h                           = errorbar(uX, Y, Ysd, 'ko'); set(h,'MarkerSize', 5, 'LineWidth',2,'MarkerFaceColor','w');
else
	h                           = plot(uX, Y, ['k' mrkr]); set(h,'MarkerSize', 5, 'LineWidth',2,'MarkerFaceColor','w');
end
axis(range);
axis square;
box on;
% grid on;
axis([-60 60 -60 60]);

bias = round(bias);
if bias>=0
linstr = ['Y = ' num2str(gain,2) 'X + ' num2str(round(bias),2)];
else
linstr = ['Y = ' num2str(gain,2) 'X - ' num2str(abs(round(bias)),2)];
end
pa_text(0.1,0.9,linstr);
% text(0,range(3)+10,linstr,'HorizontalAlignment','center')
% text(range(1)+10,range(4)-10,corrstr,'HorizontalAlignment','left')

%--------------- Graphic settings ----------------------%
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

function separablefig(D,Ei,uD,uE,nD,nE,A)
k = 1;
for ii = 1:nD
	k = k+1;
	sel = D == uD(ii);
	eye = A(sel,:);
	rt	= eye(:,5);
	
	figure(777)
	subplot(2,6,k)
	pa_plotloc(eye);
	axis([-60 60 -60 60]);
	plot([-50 50],[-50 50]+uD(ii),'k-','LineWidth',2);
	title(uD(ii));
	
	try
	sel = eye(:,24)<=0;
	x = eye(sel,24);
	y = eye(sel,9);
	b = regstats(y,x,'linear','beta');
	x_lim = [-50 0];
	X = [ones(size(x_lim))' x_lim'];
	Y = X*b.beta;
	plot(x_lim,Y,'r-','LineWidth',2);
	
	sel = eye(:,24)>=0;
	x = eye(sel,24);
	y = eye(sel,9);
	b = regstats(y,x,'linear','beta');
	x_lim = [0 50];
	X = [ones(size(x_lim))' x_lim'];
	Y = X*b.beta;
	plot(x_lim,Y,'r-','LineWidth',2);
	end
% 	x = eye(:,24);
% 	y = eye(:,9);
% 	xi = -90:5:90;
% 	[mu,se,xi] = pa_weightedmean(x,y,10,xi,'nboot',10);
% 	pa_errorpatch(xi',mu',se','r');
end

k = 1;

for jj = 1:nE
	k = k+1;
	sel = Ei==uE(jj);
	eye = A(sel,:);
	
	figure(777)
	subplot(2,6,k+6)
	pa_plotloc(eye);
	axis([-60 60 -60 60]);
	% 		plot([-50 50],[-50 50]+uD(ii),'k-','LineWidth',2);
	h = pa_horline(uE(jj),'k-'); set(h,'LineWidth',2);
	xlabel(uE(jj));
	sel = eye(:,24)==uE(jj);
	plot(uE(jj),mean(eye(sel,9)),'ro','LineWidth',2);
	
% 	pa_horline;
	try
	sel = eye(:,24)<=0;
	x = eye(sel,24);
	y = eye(sel,9);
	b = regstats(y,x,'linear','beta');
	x_lim = [-50 0];
	X = [ones(size(x_lim))' x_lim'];
	Y = X*b.beta;
	plot(x_lim,Y,'r-','LineWidth',2);
	
	sel = eye(:,24)>=0;
	x = eye(sel,24);
	y = eye(sel,9);
	b = regstats(y,x,'linear','beta');
	x_lim = [0 50];
	X = [ones(size(x_lim))' x_lim'];
	Y = X*b.beta;
	plot(x_lim,Y,'r-','LineWidth',2);
	end
% 		x = eye(:,24);
% 	y = eye(:,9);
% 	xi = -90:5:90;
% 	[mu,se,xi] = pa_weightedmean(x,y,10,xi,'nboot',10);
% 	pa_errorpatch(xi',mu',se','r');
end
