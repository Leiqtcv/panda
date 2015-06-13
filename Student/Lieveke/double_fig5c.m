function double_fig5c
close all
clear all
clc
%% Single Sounds

sub = 'MA';
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
		fname1			= 'C:\DATA\Double\MW-DB-2010-08-27\MW-DB-2010-08-27-0002';
		fname2			= 'C:\DATA\Double\MW-DB-2010-08-25\MW-DB-2010-08-25-0002';
		[Sac,Stim]		= loadmat([fname1;]);
	case 'MA'
		fname1			= 'C:\DATA\Double\MW-MA-2010-09-02\MW-MA-2010-09-02-0001';
		fname2			= 'C:\DATA\Double\MW-MA-2010-09-02\MW-MA-2010-09-02-0002';
		[Sac,Stim]		= loadmat([fname1;fname2]);
	case 'RM'
		fname1			= 'C:\DATA\Double\MW-RM-2010-09-02\MW-RM-2010-09-02-0001';
		fname2			= 'C:\DATA\Double\MW-RM-2010-09-02\MW-RM-2010-09-02-0002';
		[Sac,Stim]		= loadmat([fname1;fname2]);
		
end
% [Sac,Stim]	= loadmat([fname8]);
Sac			= firstsac(Sac);
% Check whether every saccade was detected
indx		= setdiff(1:260,Sac(:,1))
% return
sel			= Stim(:,3)==3;
trial		= unique(Stim(sel,1));
sel			= ismember(Stim(:,3),2) & ismember(Stim(:,1),trial);
Stim1		= Stim(sel,:);

sel			= ismember(Stim(:,3),3);
Stim2		= Stim(sel,:);

sel = ismember(Sac(:,1),trial);
Sacdouble = Sac(sel,:);
Sacsingle = Sac(~sel,:);

sel			= ismember(Stim(:,3),2) & ~ismember(Stim(:,1),trial);
Stimsingle	= Stim(sel,:);

%% Analyse single
[~,Psingle]		= azel2fart(Stimsingle(:,4),Stimsingle(:,5));
sel			= Psingle==6;
Psingle(sel)		= 30;
sel			= Psingle==21;
Psingle(sel)		= 31;
uP = unique(Psingle);
for ii = 1:length(uP)
	subplot(2,3,ii)
	sel = Psingle==uP(ii);
	[~,x1,y1] = plotellipse(Sacsingle,sel,'r');
	hold on
	for jj = 1:length(uP)
		if ii~=jj
			sel = Psingle==uP(jj);
			[~,x2,y2] = plotellipse(Sacsingle,sel,'b');
			plot([x1 x2],[y1 y2],'k-');
		end
	end
end

for ii = 1:5
	subplot(2,3,ii)
	axis square
	axis([-50 50 -50 50]);
	horline;
	verline;
end



%% Double Sounds
dT			= Stim2(:,8)-Stim1(:,8);
[~,P1]		= azel2fart(Stim1(:,4),Stim1(:,5));
[~,P2]		= azel2fart(Stim2(:,4),Stim2(:,5));


sel			= P1==6;
P1(sel)		= 30;
sel			= P1==21;
P1(sel)		= 31;

sel			= P2==6;
P2(sel)		= 30;
sel			= P2==21;
P2(sel)		= 31;

c		= colormap('jet');
indx	= round(linspace(1,64,5));
c		= c(indx,:);
for ii = 1:length(uP)
	subplot(2,3,ii)
	for jj = 1:length(uP)
		if ii~=jj
			sel1 = P1==uP(ii) & P2==uP(jj) & dT==0 ;
			sel2 = P2==uP(ii) & P1==uP(jj) & dT==0 ;
			sel = sel1|sel2;
			[~,x2,y2] = plotellipse(Sacdouble,sel,'g');
		end
	end
end

for ii = 1:length(uP)
	subplot(2,3,ii)
	for jj = 1:length(uP)
		if ii~=jj
			sel1 = P1==uP(ii) & P2==uP(jj) & dT==98 ;
			sel2 = P2==uP(ii) & P1==uP(jj) & dT==98 ;
			[~,x2,y2] = plotellipse(Sacdouble,sel1,c(4,:));
			[~,x2,y2] = plotellipse(Sacdouble,sel2,c(2,:));
		end
	end
end
return

uP = unique(P);
udT = unique(dT);
c		= colormap('jet');
indx	= round(linspace(1,64,3));
c		= c(indx,:);
for ii = 1:length(uP)
	sel = P==uP(ii);
	for jj = 1:length(udT);
		figure(ii)
	sel = P==uP(ii) & dT==udT(jj);
	plotellipse(Sac,sel,c(jj,:));
	end
end
return
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
m			= size(bzz,2);
n = size(gwn,2);
[m n]
c		= colormap('jet');
indx	= round(linspace(1,64,o));
c		= c(indx,:);
for jj = 1:m
	for kk = 1:n
	for ii =1:o
% 		for ii =[1 3 5]
		spk1	= bzz(jj);
		spk2	= gwn(kk);
		if spk1~=spk2-100
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
		
		if ii == 1
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
	end
end

for kk = 1:n
for jj = 1:m
	for ii =1:o
% 		for ii =[1 3 5]
		spk1	= bzz(jj);
		spk2	= gwn(kk);
		if spk1~=spk2-100
		dt		= lvl(ii);
		
		if FigFlag
			figure(kk+5)
		else
			subplot(4,5,jj)
		end
		sel		= X(:,1) == spk1 & X(:,2) == spk2 & X(:,3)==dt;
		if sum(sel)
			plotellipse(Sac,sel,c(ii,:));
		end
		
		if ii == 1
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
	end
end

for jj = 1:10
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
h	= ellipse(x,y,.5*Seig(1),.5*Seig(2),a,col);
set(h,'FaceColor',col,'EdgeColor',col);
% % alpha(h,0);


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

