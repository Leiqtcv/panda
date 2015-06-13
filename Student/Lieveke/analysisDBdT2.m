function tmp
close all
clear all
clc
%% Single Sounds


cd('C:\DATA\Double\MW-DB-2010-07-30');
fname1			= 'C:\DATA\Double\MW-DB-2010-07-29\MW-DB-2010-07-29-0001';
fname2			= 'C:\DATA\Double\MW-DB-2010-07-30\MW-DB-2010-07-30-0001';

[Sac,Stim]=loadmat([fname1;fname2]);

indx = setdiff(1:800,Sac(:,1));


sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);

sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);

sel				= Stim2(:,11)==100;
Stimsingle		= Stim1(sel,:);
Sacsingle		= Sac(sel,:);

speakers = [130 120; 131 120;131 108;130 108;131 130;120 108];

figure(99)
for jj = 1:size(speakers,1)
	spk = speakers(jj,:);
	for ii = 1:4
		subplot(4,7,(jj-1)*4+ii)
		[x1,y1,a1,Seig1] = plotellipse(Sacsingle,Stimsingle,spk(1),'b');
		hold on
		[x2,y2,a2,Seig2] = plotellipse(Sacsingle,Stimsingle,spk(2),'r');
		plot([x1 x2],[y1 y2],'k-','LineWidth',1);
	end
end

%% Graphic Style
for jj = 1:6
	for ii = 1:4
	subplot(4,7,(ii-1)*7+jj)
	hold on
% 	axis square
% 	axis([-70 70 -70 70]);
	verline(0);
	horline(0);
% 	xlabel('Azimuth (deg)');
% 	ylabel('Elevation (deg)');
	box on
	end
end


%%
cd('C:\DATA\Double\MW-DB-2010-07-30');
fname1			= 'C:\DATA\Double\MW-DB-2010-07-29\MW-DB-2010-07-29-0001';
fname2			= 'C:\DATA\Double\MW-DB-2010-07-30\MW-DB-2010-07-30-0001';
fname3			= 'C:\DATA\Double\MW-DB-2010-07-30\MW-DB-2010-07-30-0002';
[Sac,Stim]=loadmat([fname1;fname2;fname3]);
% load(fname)
Sac			= firstsac(Sac);
% indx		= setdiff(1:420,Sac(:,1))
whos Sac

sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);
sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);


%% Double Sounds
sel				= Stim2(:,11)==100;
Stim1			= Stim1(~sel,:);
Stim2			= Stim2(~sel,:);
Sac				= Sac(~sel,:);

dT = Stim2(:,8)-Stim1(:,8);

X = [Stim1(:,11) Stim2(:,11) dT];
sel8	= X(:,1)==108 | X(:,2)==108;
sel20	= X(:,1)==120 | X(:,2)==120;
sel30	= X(:,1)==130 | X(:,2)==130;
sel31	= X(:,1)==131 | X(:,2)==131;

%%
% figure(99)
c		= colormap('jet');
indx	= round(linspace(1,64,7));
c		= c(indx,:);
lvl		= flipud(unique(dT))

% figure(99)
for jj = 1:size(speakers,1)
	spk = speakers(jj,:);
	for ii = 1:length(lvl)
		subplot(4,7,(jj-1)*4+ii)
		sel = (X(:,1) == spk(1) & X(:,2) == spk(2) & round(X(:,3))==lvl(ii));
		if sum(sel)
			h = plotellipsedouble(Sac,sel,c(ii,:));
			set(h,'FaceColor',c(ii,:),'EdgeColor','none');
		end
		
		sel = (X(:,1) == spk(2) & X(:,2) == spk(1) & X(:,3)==lvl(ii));
		if sum(sel)
			h = plotellipsedouble(Sac,sel,c(7-ii+1,:));
			set(h,'FaceColor',c(7-ii+1,:),'EdgeColor','none');
		end
	end
end
marc
print(mfilename,'-depsc2','-painter');

function int = correctlevel(loc)
for i = 1:length(loc)
	switch loc(i)
		case 109
			int(i) = 56.4450;
		case 120
			int(i) = 53.9945;
		case 130
			int(i) = 64.8689;
		case 131
			int(i) = 61.4274;
	end
	
end
whos int
int = int';

function h = plotellipsedouble(Sac,sel,col)

A	= Sac(sel,8);
E	= Sac(sel,9);
[x,y,a,Seig] = getellips(A,E);

h = plot(A,E,'k.','Color',col);
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
h	= ellipse(x,y,2*Seig(1),2*Seig(2),a,col);
hold on
box on
alpha(h,.4);
set(h,'EdgeColor','none');
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
