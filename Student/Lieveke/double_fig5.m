function tmp
close all
clear all
clc
%% Single Sounds

sub = 'TG';
FigFlag = 1;

switch sub
	case 'TG'
		fname1			= 'C:\DATA\Double\MW-TG-2010-08-24\MW-TG-2010-08-24-0001';
		fname2			= 'C:\DATA\Double\MW-TG-2010-08-24\MW-TG-2010-08-24-0002';
		fname3			= 'C:\DATA\Double\MW-TG-2010-08-25\MW-TG-2010-08-25-0001';
		fname4			= 'C:\DATA\Double\MW-TG-2010-08-25\MW-TG-2010-08-25-0002';
		fname5			= 'C:\DATA\Double\MW-TG-2010-08-25\MW-TG-2010-08-25-0004';
		[Sac,Stim]	= loadmat([fname1;fname2;fname3;fname4;fname5]);
		
	case 'DB'
		
		fname1			= 'C:\DATA\Double\MW-DB-2010-08-25\MW-DB-2010-08-25-0001';
		fname2			= 'C:\DATA\Double\MW-DB-2010-08-25\MW-DB-2010-08-25-0002';
		fname3			= 'C:\DATA\Double\MW-DB-2010-08-26\MW-DB-2010-08-26-0001';
		fname4			= 'C:\DATA\Double\MW-DB-2010-08-26\MW-DB-2010-08-26-0002';
		[Sacic,Stimic]	= loadmat(fname3);
		sel				= ismember(Sacic(:,1),1:128); % Remove 129
		Sacic			= Sacic(sel,:);
		[Sac,Stim]		= loadmat([fname1;fname2;fname4]);
		Sacic(:,1)		= Sacic(:,1)+max(Sac(:,1));
		Stimic(:,1)		= Stimic(:,1)+max(Stim(:,1));
		Sac				= [Sac;Sacic];
		Stim			= [Stim;Stimic];
	case 'RM'
		fname1			= 'C:\DATA\Double\MW-RM-2010-08-03\MW-RM-2010-08-03-0001';
		fname2			= 'C:\DATA\Double\MW-RM-2010-08-03\MW-RM-2010-08-03-0002';
		fname3			= 'C:\DATA\Double\MW-RM-2010-08-06\MW-RM-2010-08-06-0002';
		fname4			= 'C:\DATA\Double\MW-RM-2010-08-06\MW-RM-2010-08-06-0004';
		fname5			= 'C:\DATA\Double\MW-RM-2010-08-24\MW-RM-2010-08-24-0001';
		fname6			= 'C:\DATA\Double\MW-RM-2010-08-24\MW-RM-2010-08-24-0002';
		fname7			= 'C:\DATA\Double\MW-RM-2010-08-26\MW-RM-2010-08-26-0001';
		fname8			= 'C:\DATA\Double\MW-RM-2010-08-26\MW-RM-2010-08-26-0001';
		[Sac,Stim]	= loadmat([fname1;fname2;fname3;fname4;fname5;fname6;fname7;fname8]);
		
end
% [Sac,Stim]	= loadmat([fname8]);
Sac			= firstsac(Sac);
% Check whether every saccade was detected
% indx		= setdiff(1:315,Sac(:,1))

sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);

sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);

%% Double Sounds
dT		= Stim2(:,8)-Stim1(:,8);
sel		= Stim1(:,11)>200 & Stim2(:,11)<200;
dT(sel)		= -dT(sel);
[t,P]		= azel2fart(Stim1(:,4),Stim1(:,5));
sel			= P==6;
P(sel)		=30;
sel			= P==21;
P(sel)		= 31;

a = Stim1(:,11);
b = Stim2(:,11);
c = a;
d = b;
sel = a>200;
c(sel) = b(sel);
d(sel) = a(sel);
X		= [c d dT P];


%% Graphic Style
lvl			= unique(dT);
[o,p]		= size(lvl);
bzz = [109 112 116 130 131];
gwn = [209 212 216 230 231];
[bzz,gwn] = meshgrid(bzz,gwn);
bzz = bzz(:);
gwn = gwn(:);
sel = bzz==gwn-100;
bzz = bzz(~sel);
gwn = gwn(~sel);

m			= size(bzz,1);

c		= colormap('jet');
indx	= round(linspace(1,64,o));
c		= c(indx,:);
n = 0;
for jj = 1:m
	for ii =1:o
% 		for ii =[1 3 5]
		spk1	= bzz(jj);
		spk2	= gwn(jj);
		dt		= lvl(ii);
		
		if FigFlag
			figure(jj)
		else
			subplot(4,5,jj)
		end
		sel		= X(:,1) == spk1 & X(:,2) == spk2 & X(:,3)==dt;
		if sum(sel)
			plotellipse(Sac,sel,c(ii,:));
		end
		
		if ii == 3
		sel = X(:,2)==100 & 100+X(:,4)==spk1;
			[~,x1,y1] = plotellipse(Sac,sel,'r');
			text(x1,y1,num2str(spk1));
		
		sel = X(:,2)==100 & 100+X(:,4)==spk2-100;
			[~,x2,y2] = plotellipse(Sac,sel,'b');
			plot([x1 x2],[y1 y2],'k-');
			text(x2,y2,num2str(spk2));
		end
	end
end


for jj = 1:20
	if FigFlag
		figure(jj)
	else
		subplot(4,5,jj)
	end
	hold on
	axis square
	axis([-70 70 -70 70]);
	% 		axis equal
	verline(0);
	horline(0);
	% 	xlabel('Azimuth (deg)');
	% 	ylabel('Elevation (deg)');
	box off
	% 	set(gca,'Xtick',-50:25:50,'YTick',-50:25:50);
	set(gca,'Xtick',[],'YTick',[]);
	
end


marc
print(mfilename,'-depsc2','-painter');


function [h,x,y] = plotellipse(Sac,sel,col,mrk)
if nargin<4
	mrk = 'o';
end
A				= Sac(sel,8);
E				= Sac(sel,9);
[x,y,a,Seig]	= getellips(A,E);

hold on
% plot(A,E,'k.','Color',col);
h = plot(x,y,['k' mrk],'MarkerFaceColor',col,'MarkerSize',5);
h	= ellipse(x,y,Seig(1),Seig(2),a,col);
set(h,'FaceColor',col,'EdgeColor',col);
% alpha(h,0);


function h = ellipse(Xo,Yo,L,S,Phi,Sty)
if nargin<6
	Sty = 'r-';
end
DTR = pi/180;
Phi = Phi*DTR;
wt  = (0:360).*DTR;
X   = Xo + L*cos(Phi)*cos(wt) - S*sin(Phi)*sin(wt);
Y   = Yo + L*sin(Phi)*cos(wt) + S*cos(Phi)*sin(wt);
h = patch(X,Y,Sty);
alpha(h,.4);
set(h,'EdgeColor',Sty,'LineWidth',.5);

