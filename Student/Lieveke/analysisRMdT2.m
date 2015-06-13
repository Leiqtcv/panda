function tmp
close all
clear all
clc
%% Single Sounds


cd('C:\DATA\Double\MW-RM-2010-08-03');
fname1			= 'C:\DATA\Double\MW-RM-2010-08-03\MW-RM-2010-08-03-0001';
fname2			= 'C:\DATA\Double\MW-RM-2010-08-03\MW-RM-2010-08-03-0002';
% speakers = [130 116; 131 116;131 109;130 109;131 130;116 109;112 130;112 131;112 116;112 109];
speakers = [130 116; 131 116;131 109;112 130;...
	112 116;131 130;116 109;...
	112 109;112 131;130 109;];

[Sac,Stim]	= loadmat([fname1;fname2]);
Sac			= firstsac(Sac);
indx = setdiff(1:250,Sac(:,1))

sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);
sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);

%% Double Sounds
dT = Stim2(:,8)-Stim1(:,8);
X = [Stim1(:,11) Stim2(:,11) dT];

uX = unique(X,'rows')

%% Graphic Style
[m,n]		= size(speakers);
lvl			= flipud(unique(dT))
[o,p]		= size(lvl);
figure(99)
c		= colormap('jet');
indx	= round(linspace(1,64,o*2-1));
c		= c(indx,:);


for jj = 1:m
	spk = speakers(jj,:);
	for ii =1:o
		lvl(ii)
		subplot(3,4,jj)
		sel = (X(:,1) == spk(1) & X(:,2) == spk(2) & round(X(:,3))==lvl(ii));
		if sum(sel)
			h = plotellipsedouble(Sac,sel,c(ii,:));
% 			set(h,'FaceColor',c(ii,:),'EdgeColor','none');
			x = unique([Stim1(sel,4) Stim2(sel,4)],'rows');
			y = unique([Stim1(sel,5) Stim2(sel,5)],'rows');
			plot(x,y,'ko-','MarkerFaceColor','w');
		end
		
		sel = (X(:,1) == spk(2) & X(:,2) == spk(1) & X(:,3)==lvl(ii));
		if sum(sel)
			h = plotellipsedouble(Sac,sel,c((o*2-1)-ii+1,:));
% 			set(h,'FaceColor',c((o*2-1)-ii+1,:),'EdgeColor','none');
			x = unique([Stim1(sel,4) Stim2(sel,4)],'rows');
			y = unique([Stim1(sel,5) Stim2(sel,5)],'rows');
			plot(x,y,'ko-','MarkerFaceColor','w');
		end
	end
	title(spk)
end

for jj = 1:10
	subplot(3,4,jj)
	hold on
	axis square
	axis([-70 70 -70 70]);
	axis equal
	verline(0);
	horline(0);
% 	xlabel('Azimuth (deg)');
% 	ylabel('Elevation (deg)');
	box off
	set(gca,'Xtick',-50:25:50,'YTick',-50:25:50);
end

marc
print(mfilename,'-depsc2','-painter');


function h = plotellipsedouble(Sac,sel,col)

A	= Sac(sel,8);
E	= Sac(sel,9);
[x,y,a,Seig] = getellips(A,E);

% h = plot(A,E,'k.','Color',col);
hold on
h	= ellipse(x,y,Seig(1),Seig(2),a,col);
hold on
alpha(h,.4);

function [x,y,a,Seig] = plotellipse(Sac,Stim,speaker,col)
sel = Stim(:,11)==speaker;
A	= Sac(sel,8);
E	= Sac(sel,9);
[x,y,a,Seig] = getellips(A,E);

% plot(A,E,'r.','Color',[.7 .7 .7])
% hold on
h	= ellipse(x,y,Seig(1),Seig(2),a,col);
hold on
box on
alpha(h,.4);
% set(h,'EdgeColor','none');
% ellipse(Xo,Yo,L,S,Phi,Sty)
%  draw an ellipse with long and short axes L and S
%  with orientation Phi (in deg) at point Xo,Yo.
%
%  Marc van Wanrooij

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
alpha(h,.4);
set(h,'EdgeColor',Sty,'LineWidth',2);

% wt = [0 180]*DTR;
% X   = Xo + L*cos(Phi)*cos(wt) - S*sin(Phi)*sin(wt);
% Y   = Yo + L*sin(Phi)*cos(wt) + S*cos(Phi)*sin(wt);
% plot(X,Y,'-','Color',Sty);
% 
% wt = [90 270]*DTR;
% X   = Xo + L*cos(Phi)*cos(wt) - S*sin(Phi)*sin(wt);
% Y   = Yo + L*sin(Phi)*cos(wt) + S*cos(Phi)*sin(wt);
% plot(X,Y,'-','Color',Sty);
