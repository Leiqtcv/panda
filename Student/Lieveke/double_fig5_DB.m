function tmp
close all
clear all
clc
%% Single Sounds


fname1			= 'C:\DATA\Double\MW-DB-2010-08-25\MW-DB-2010-08-25-0001';
fname2			= 'C:\DATA\Double\MW-DB-2010-08-25\MW-DB-2010-08-25-0002';
fname3			= 'C:\DATA\Double\MW-DB-2010-08-26\MW-DB-2010-08-26-0001';
fname4			= 'C:\DATA\Double\MW-DB-2010-08-26\MW-DB-2010-08-26-0002';
% Incorrect files
% For MW-DB-2010-08-26: data saved until trial 129, csv until 128 (and
% first lines of 129)
[Sacic,Stimic]	= loadmat(fname3);
sel = ismember(Sacic(:,1),1:128); % Remove 129
Sacic = Sacic(sel,:);

%% Correct
[Sac,Stim]	= loadmat([fname1;fname2;fname4]);
Sacic(:,1) = Sacic(:,1)+max(Sac(:,1));
Stimic(:,1) = Stimic(:,1)+max(Stim(:,1));
Sac		= [Sac;Sacic];
Stim	= [Stim;Stimic];

Sac			= firstsac(Sac);
% Check whether every saccade was detected
indx		= setdiff(1:129,Sac(:,1))

sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);

sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);

%% Double Sounds
dT = Stim2(:,8)-Stim1(:,8);
unique(dT)
X = [Stim1(:,11) Stim2(:,11) dT Stim1(:,[4 5]) Stim2(:,[4 5]) Sac(:,[8 9])];


%% Graphic Style
lvl			= flipud(unique(dT));
[o,p]		= size(lvl);
bzzspeakers = [109 112 116 130 131];
gwnspeakers = [209 212 216 230 231];
m			= size(bzzspeakers,2);
n			= size(gwnspeakers,2);

figure(99)
c		= colormap('jet');
indx	= round(linspace(1,64,o*2-1));
c		= c(indx,:);


for jj = 1:m
	for kk = 1:n
		for ii =1:o
% 			for ii = 2;
			spk1	= bzzspeakers(jj);
			spk2	= gwnspeakers(kk);
			dt		= lvl(ii);
			
			cmb			= (jj-1)*5+kk;
			selcmb		= cmb == [2 3 4 5 8 9 10 14 15 20];
			if any(selcmb)
				subplot(3,4,find(selcmb))
		
				%% Doubles
				selbzz		= X(:,1) == spk1 & X(:,2) == spk2 & X(:,3)==dt;
				sel			= selbzz;
				if sum(sel)
					h = plotellipse(Sac,sel,c(ii,:));
					
					selsingle = X(:,2) == 100 & X(:,4) == unique(X(sel,4)) & X(:,5) == unique(X(sel,5));
					if sum(selsingle)
					[~,x1,y1] = plotellipse(Sac,selsingle,'b','h');
					end
					title(sum(sel))
				end
				
				selgwn	= X(:,1) == spk2 & X(:,2) == spk1 & X(:,3)==dt;
				sel		= selgwn;
				if sum(sel)
					h = plotellipse(Sac,sel,c(6-ii,:));
					selsingle = X(:,2) == 100 & X(:,4) == unique(X(sel,4)) & X(:,5) == unique(X(sel,5));
					if sum(selsingle)
					[~,x2,y2] = plotellipse(Sac,selsingle,'r','h');
					plot([x1 x2],[y1 y2],'k-');
					dst =round(sqrt((x1-x2)^2+(y2-y1)^2));
					title(dst)
					end
				end
			end
			
		end
	end
end

for jj = 1:10
	subplot(3,4,jj)
% 		figure(jj)
	hold on
	axis square
	axis([-50 50 -50 50]);
% 		axis equal
	verline(0);
	horline(0);
	xlabel('Azimuth (deg)');
	ylabel('Elevation (deg)');
	box off
	set(gca,'Xtick',-50:25:50,'YTick',-50:25:50);
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
plot(A,E,'k.','Color',col);
h = plot(x,y,['k' mrk],'MarkerFaceColor',col,'MarkerSize',3);
h	= ellipse(x,y,.5*Seig(1),.5*Seig(2),a,col);
set(h,'FaceColor',col,'EdgeColor',col);


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

