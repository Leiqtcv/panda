function tmp
close all
clear all
clc
%% Single Sounds


cd('C:\DATA\Double\MW-RM-2010-08-06');
fname1			= 'C:\DATA\Double\MW-RM-2010-08-06\MW-RM-2010-08-06-0002';
fname2			= 'C:\DATA\Double\MW-RM-2010-08-06\MW-RM-2010-08-06-0004';
fname3			= 'C:\DATA\Double\MW-RM-2010-08-03\MW-RM-2010-08-03-0001';
fname4			= 'C:\DATA\Double\MW-RM-2010-08-03\MW-RM-2010-08-03-0002';

[Sac,Stim]	= loadmat([fname1;fname2;fname3;fname4]);
Sac			= firstsac(Sac);
indx = setdiff(1:315,Sac(:,1));

sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);

sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);

%% Double Sounds
dT = Stim2(:,8)-Stim1(:,8);
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
			spk1	= bzzspeakers(jj);
			spk2	= gwnspeakers(kk);
			dt		= lvl(ii);
			
			cmb = (jj-1)*5+kk;
			selcmb = cmb == [2 3 4 5 8 9 10 14 15 20];
			if any(selcmb)
				
				
				%% Doubles
				selbzz		= X(:,1) == spk1 & X(:,2) == spk2 & X(:,3)==dt;
				seldouble	= X(:,1) == spk1 & X(:,2) == spk2-100 & X(:,3)==dt;
				sel			= selbzz | seldouble;
				if sum(sel)
					Sac1 = Sac(sel,[8 9]);
					selsingle = X(:,2) == 100 & X(:,4) == unique(X(sel,4)) &X(:,5) == unique(X(sel,5));
					Sacsingle1 = Sac(selsingle,[8 9]);
				end
				
				selgwn	= X(:,1) == spk2 & X(:,2) == spk1 & X(:,3)==dt;
				seldouble = X(:,1) == spk2-100 & X(:,2) == spk1 & X(:,3)==dt;
				sel		= selgwn | seldouble;
				
				if sum(sel)
					Sac2  = Sac(sel,[8 9]);
					selsingle = X(:,2) == 100 & X(:,4) == unique(X(sel,4)) &X(:,5) == unique(X(sel,5));
					Sacsingle2 = Sac(selsingle,[8 9]);
					
					figure(1)
					subplot(2,5,find(selcmb))
					R2 = Sac2(:,2)./(mean(Sacsingle1(:,2))-mean(Sacsingle2(:,2)));
					R1 = Sac1(:,2)./(mean(Sacsingle1(:,2))-mean(Sacsingle2(:,2)));
					x = [-10:.1:10];
					N = hist(R2,x);
					N = smooth(N);
					N = N./sum(N);
					h =patch(x,N,c(6-ii,:));
					
					set(h,'FaceColor',c(6-ii,:),'EdgeColor',c(6-ii,:));
					alpha(h,.2);
					
					hold on
					N = hist(R1,x);
					N = smooth(N);
					N = N./sum(N);
					h =patch(x,N,c(ii,:));
					
					set(h,'FaceColor',c(ii,:),'EdgeColor',c(ii,:));
					alpha(h,.2);
					xlim([-2 2]);
					axis square
					
					figure(2)
					subplot(2,5,find(selcmb))
					R2 = Sac2(:,1)./(mean(Sacsingle1(:,1))-mean(Sacsingle2(:,1)));
					R1 = Sac1(:,1)./(mean(Sacsingle1(:,1))-mean(Sacsingle2(:,1)));
					N = hist(R2,x);
					N = smooth(N);
					N = N./sum(N);
					% 					plot(x,N,'k-','Color',c(6-ii,:));
					h =patch(x,N,c(6-ii,:));
					
					set(h,'FaceColor',c(6-ii,:),'EdgeColor',c(6-ii,:));
					alpha(h,.2);
					
					hold on
					N = hist(R1,x);
					N = smooth(N);
					N = N./sum(N);
					% 					plot(x,N,'k-','Color',c(ii,:));
					h =patch(x,N,c(ii,:));
					set(h,'FaceColor',c(ii,:),'EdgeColor',c(ii,:));
					alpha(h,.2);
					xlim([-2 2]);
					axis square
				end
			end
			
		end
	end
end

return
for jj = 1:10
	subplot(2,5,jj)
	% 	figure(jj)
	hold on
	axis square
	axis([-70 70 -70 70]);
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


function [h,x,y] = plotellipsedouble(Sac,sel,col,mrk)
if nargin<4
	mrk = 'o';
end
A	= Sac(sel,8);
E	= Sac(sel,9);
[x,y,a,Seig] = getellips(A,E);

% plot(A,E,'k.','Color',col);
h = plot(x,y,['k' mrk],'MarkerFaceColor',col);

hold on
h	= ellipse(x,y,Seig(1),Seig(2),a,col);
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
