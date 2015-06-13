function tmp
close all
clear all
clc
%% Single Sounds


cd('C:\DATA\Double\MW-DB-2010-07-30');
fname1			= 'C:\DATA\Double\MW-DB-2010-07-29\MW-DB-2010-07-29-0001';
fname2			= 'C:\DATA\Double\MW-DB-2010-07-30\MW-DB-2010-07-30-0001';
hvname1		= fcheckext(fname1,'.hv');
hvname2		= fcheckext(fname2,'.hv');
% Load Data

[H1,V1]		= loadraw(hvname1,2,1500);
[H2,V2]		= loadraw(hvname2,2,1500);
H			= [H1 H2];
V			= [V1 V2];
[Sac,Stim]	= loadmat([fname1;fname2]);

sel			= ismember(Stim(:,3),2);
Stim1		= Stim(sel,:);

sel			= ismember(Stim(:,3),3);
Stim2		= Stim(sel,:);

sel				= Stim2(:,11)==100;
Stimsingle		= Stim1(sel,:);
Sacsingle		= Sac(sel,:);
Hsingle			= H(:,sel);
Vsingle			= V(:,sel);

speakers = [...
	130 120;...
	131 130;...
	131 120;...
	130 108;...
	120 108;...
	131 108;...
	];


figure(1)
speakers = [130 120];
speakers = [131 108];

for ii = 1:2
	if ii == 1
		col= 'k';
		colp = [.7 .7 .7];
	else
		col= 'k';
		colp = [.7 .7 .7];
	end
	
	sel = Stimsingle(:,11)==speakers(ii);
	A = Sacsingle(sel,8);
	E = Sacsingle(sel,9);
	[x,y,a,Seig] = getellips(A,E);
	
	H	= Hsingle(1:1200,sel);
	H	= H-repmat(H(1,:),size(H,1),1);
	V	= Vsingle(1:1200,sel);
	V	= V-repmat(V(1,:),size(V,1),1);
	t = (1:size(H,1))/1017*1000; % ms
	muV = mean(V,2);
	muH = mean(H,2);
	
	subplot(3,3,ii)
	plot(H,V,'k-','Color',col);
	hold on
% 	plot(muH,muV,'k-','LineWidth',3,'Color',colp);
	h	= ellipse(x,y,2*Seig(1),2*Seig(2),a,col); alpha(h,.4);
	% 	set(h,'EdgeColor','none');
	
	axis square
	axis([-20 60 -60 20]);
	xlabel('Azimuth (deg)');
	ylabel('Elevation (deg)');
	horline(0);
	verline(0);
	if ii == 1
		title('Single Speaker 1');
	else
		title('Single Speaker 2');
	end	
	box off
	
	subplot(3,3,ii+3)
	hv = plot(t,V,'k-','Color',[.7 .7 .7]);
	hold on
% 	plot(t,muV,'k-','Color',[.3 .3 .3],'LineWidth',2);
	
	hh = plot(t,H,'k-');
% 	plot(t,muH,'k-','Color',[.7 .7 .7],'LineWidth',2);
	axis square
	ylim([-40 70]);
	xlim([0 1200]);
	xlabel('Time (ms)');
	ylabel('Location (deg)');
	h		= [hh(1);hv(1)];
	str		= {'Azimuth';'Elevation'};
	if ii == 1
		legend(h,str,'Location','NW');
	else
		legend(h,str,'Location','SW');
	end
		box off

end

%%
cd('C:\DATA\Double\MW-DB-2010-07-30');
fname1			= 'C:\DATA\Double\MW-DB-2010-07-29\MW-DB-2010-07-29-0001';
fname2			= 'C:\DATA\Double\MW-DB-2010-07-30\MW-DB-2010-07-30-0001';
hvname1		= fcheckext(fname1,'.hv');
hvname2		= fcheckext(fname2,'.hv');
[H1,V1]		= loadraw(hvname1,2,1500);
[H2,V2]		= loadraw(hvname2,2,1500);
H			= [H1 H2];
V			= [V1 V2];
[Sac,Stim]		= loadmat([fname1;fname2]);

Sac			= firstsac(Sac);

sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);
sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);


%% Double Sounds
sel				= Stim2(:,11)==100;
Stim1			= Stim1(~sel,:);
Stim2			= Stim2(~sel,:);
Sac				= Sac(~sel,:);
H				= H(1:1200,~sel);
V				= V(1:1200,~sel);

dT = Stim2(:,8)-Stim1(:,8);
X = [Stim1(:,11) Stim2(:,11) dT]

sel = X(:,1)==speakers(1) & X(:,2)==speakers(2) | X(:,1)==speakers(2) & X(:,2)==speakers(1);
A = Sac(sel,8);
E = Sac(sel,9);
[x,y,a,Seig] = getellips(A,E);
H	= H(:,sel);
H	= H-repmat(H(1,:),size(H,1),1);
V	= V(:,sel);
V	= V-repmat(V(1,:),size(V,1),1);
t = (1:size(H,1))/1017*1000; % ms
muV = mean(V,2);
muH = mean(H,2);

subplot(3,3,3)
plot(H,V,'k-');
hold on
% plot(muH,muV,'k-','Color','k','LineWidth',3);
	h	= ellipse(x,y,2*Seig(1),2*Seig(2),a,'k'); alpha(h,.4);

axis square
axis([-20 60 -60 20]);
xlabel('Azimuth (deg)');
ylabel('Elevation (deg)');
horline(0);
verline(0);
title('Double Speaker 1 & 2');
	box off

subplot(3,3,6)
hv = plot(t,V,'k-','Color',[.7 .7 .7]);
hold on
% plot(t,muV,'k-','Color',[.3 .3 .3],'LineWidth',2);

hh = plot(t,H,'k-');
% plot(t,muH,'k-','Color',[.7 .7 .7],'LineWidth',2);
axis square
ylim([-40 70]);
xlim([0 1200]);
xlabel('Time (ms)');
ylabel('Location (deg)');
h		= [hh(1);hv(1)];
str		= {'Azimuth';'Elevation'};
	box off

marc
print(mfilename,'-depsc2','-painters');
function h = ellipse(Xo,Yo,L,S,Phi,Sty)
if nargin<6
	Sty = 'r-';
end
DTR = pi/180;
Phi = Phi*DTR;
wt  = (0:360).*DTR;
X   = Xo + L*cos(Phi)*cos(wt) - S*sin(Phi)*sin(wt);
Y   = Yo + L*sin(Phi)*cos(wt) + S*cos(Phi)*sin(wt);
% h	= plot(X,Y,Sty,'LineWidth',2);


h = patch(X,Y,Sty);
set(h,'EdgeColor',Sty,'LineWidth',2);

