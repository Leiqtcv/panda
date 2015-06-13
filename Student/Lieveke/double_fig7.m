function tmp
close all
clear all
clc
%% Single Sounds

dname = 'E:\DATA\Studenten\Lieveke\Data\';
cd([dname 'MW-RM-2010-08-06']);
fname1			= '\MW-RM-2010-08-06\MW-RM-2010-08-06-0002';
fname2			= '\MW-RM-2010-08-06\MW-RM-2010-08-06-0004';
fname3			= '\MW-RM-2010-08-03\MW-RM-2010-08-03-0001';
fname4			= '\MW-RM-2010-08-03\MW-RM-2010-08-03-0002';

[Sac,Stim]	= loadmat([fname1;fname2;fname3;fname4]);
Sac			= firstsac(Sac);
% Check whether every saccade was detected
% indx		= setdiff(1:315,Sac(:,1));

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
		% 		for ii =1:o
		spk1	= bzzspeakers(jj);
		spk2	= gwnspeakers(kk);
		% 			dt		= lvl(ii);
		
		cmb = (jj-1)*5+kk;
		selcmb = cmb == [2 3 4 5 8 9 10 14 15 20];
		if any(selcmb)
			subplot(4,4,find(selcmb))
			
			
			%% Doubles
			selbzz		= X(:,1) == spk1 & X(:,2) == spk2;
			seldouble1	= X(:,1) == spk1 & X(:,2) == spk2-100;
			selgwn		= X(:,1) == spk2 & X(:,2) == spk1;
			seldouble2	= X(:,1) == spk2-100 & X(:,2) == spk1;
			sel		= selbzz | seldouble1 | selgwn | seldouble2;
			if sum(sel)
				h = plotellipse(Sac,sel,'g');
				
				sel1		= selbzz | seldouble1;
				selsingle = X(:,2) == 100 & X(:,4) == unique(X(sel1,4)) & X(:,5) == unique(X(sel1,5));
				if sum(selsingle)
					[~,x1,y1] = plotellipse(Sac,selsingle,'b','h');
				end
				
				sel2		= selgwn | seldouble2;				
				selsingle = X(:,2) == 100 & X(:,4) == unique(X(sel2,4)) & X(:,5) == unique(X(sel2,5));
				if sum(selsingle)
					[~,x2,y2] = plotellipse(Sac,selsingle,'r','h');
					
					plot([x1 x2],[y1 y2],'k-');
					dst =round(sqrt((x1-x2)^2+(y2-y1)^2));
					[x1 x2 y1 y2 dst]
					title(dst)
				end
			end
			
		end
	end
end

for jj = 1:10
	subplot(4,4,jj)
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

rm_setting1
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
h = plot(x,y,['k' mrk],'MarkerFaceColor',col,'MarkerSize',1);
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

function rm_setting1
%% Single Sounds


cd('C:\DATA\Double\MW-RM-2010-07-29');
fname			= 'MW-RM-2010-07-29-0001';

load(fname)

indx = setdiff(1:420,Sac(:,1));


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
	sel = Stimsingle(:,11)==spk(1);
	
	subplot(4,4,jj+10)
	[~,x1,y1] = plotellipse(Sacsingle,sel,'b','h');
	hold on
	sel = Stimsingle(:,11)==spk(2);
	[~,x2,y2] = plotellipse(Sacsingle,sel,'r','h');
	plot([x1 x2],[y1 y2],'k-','LineWidth',1);
	dst = sqrt( (x1-x2)^2+(y1-y2)^2);
	title(dst)
end



%%
cd('C:\DATA\Double\MW-RM-2010-07-30');
fname1			= 'C:\DATA\Double\MW-RM-2010-07-29\MW-RM-2010-07-29-0001';
fname3			= 'C:\DATA\Double\MW-RM-2010-07-30\MW-RM-2010-07-30-0002';

[Sac,Stim]=loadmat([fname1;fname3]);
Sac = firstsac(Sac);
indx = setdiff(1:420,Sac(:,1));


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
figure(99)
c = colormap('jet');
indx = round(linspace(1,64,5));
c = c(indx,:);
for ii = 1:6
	subplot(4,4,ii+10)
	% plot(Sac(:,8),Sac(:,9),'k.','Color',[.7 .7 .7])
	hold on
	axis square
	axis equal
	axis([-70 70 -70 70]);
	verline(0);
	horline(0);
	xlabel('Azimuth (deg)');
	ylabel('Elevation (deg)');
	box off
	set(gca,'XTick',-50:25:50,'YTick',-50:25:50);
end


% lvl = [0 24 49 98];
lvl = [98 24 0];
figure(99)
for jj = 1:size(speakers,1)
	spk = speakers(jj,:);
	subplot(4,4,jj+10)
	for ii = 1:length(lvl)
		% 		for ii = 1
		disp('-------------------------------------------');
		disp([spk lvl(ii)])
		sel = (X(:,1) == spk(1) & X(:,2) == spk(2) & round(X(:,3))==lvl(ii));
		sum(sel)
		if sum(sel)
			h = plotellipse(Sac,sel,c(ii,:));
		end
		
		sel = (X(:,1) == spk(2) & X(:,2) == spk(1) & X(:,3)==lvl(ii));
		sum(sel)
		if sum(sel)
			h = plotellipse(Sac,sel,c(5-ii+1,:));
		end
	end
end