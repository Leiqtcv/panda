function tmp
close all
clear all
clc
%% Single Sounds


fname1			= 'C:\DATA\Double\DB-MW-2010-07-27\DB-MW-2010-07-27-0001';
[Sac,Stim]		= loadmat(fname1);
sel				= ismember(Stim(:,3),2);
Stim1			= Stim(sel,:);
sel				= ismember(Stim(:,3),3);
Stim2			= Stim(sel,:);

sel				= Stim2(:,11)==100;
Stimsingle		= Stim1(sel,:);
Sacsingle		= Sac(sel,:);

% speakers		= [130 120; 131 120;131 108;130 108;131 130;120 108];
speakers		= [130 120; 131 120;130 108;131 108];

figure(1)
% for jj = 1:size(speakers,1)
% 	spk = speakers(jj,:);
% 	subplot(2,2,jj)
[x1,y1,a1,Seig1] = plotellipse(Sacsingle,Stimsingle,130,'k');
hold on
[x2,y2,a1,Seig1] = plotellipse(Sacsingle,Stimsingle,120,'k');
[x3,y3,a2,Seig2] = plotellipse(Sacsingle,Stimsingle,131,'k');
[x4,y4,a2,Seig2] = plotellipse(Sacsingle,Stimsingle,108,'k');
plot([x1 x2],[y1 y2],'k-','LineWidth',1);
plot([x2 x3],[y2 y3],'k-','LineWidth',1);
plot([x3 x4],[y3 y4],'k-','LineWidth',1);
plot([x4 x1],[y4 y1],'k-','LineWidth',1);
% end




%%
fname1			= 'C:\DATA\Double\DB-MW-2010-07-27\DB-MW-2010-07-27-0001';
[Sac,Stim]		= loadmat(fname1);
Sac				= firstsac(Sac);


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


%%
c = colormap('summer');
indx = round(linspace(1,64,4));
c = c(indx,:);


lvl = flipud(unique(dT))

for jj = 1:size(speakers,1)
	spk = speakers(jj,:);
	% 	subplot(2,2,jj)
	for ii = 1:length(lvl)
		sel = (X(:,1) == spk(1) & X(:,2) == spk(2) & round(X(:,3))==lvl(ii));
		if sum(sel)
			h = plotellipsedouble(Sac,sel,c(jj,:));
			set(h,'FaceColor',c(jj,:),'EdgeColor',c(jj,:));
		end
		
		sel = (X(:,1) == spk(2) & X(:,2) == spk(1) & X(:,3)==lvl(ii));
		if sum(sel)
			h = plotellipsedouble(Sac,sel,c(jj,:));
			set(h,'FaceColor',c(jj,:),'EdgeColor',c(jj,:));
		end
	end
end

%% Graph
hold on
axis square
axis([-70 70 -70 70]);
verline(0);
horline(0);
xlabel('Azimuth (deg)');
ylabel('Elevation (deg)');
box off
set(gca,'XTick',-50:25:50,'YTick',-50:25:50);
str = 'Listener MW';
text(-50,-50,str,'HorizontalAlignment','left');

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
[At,Et] = rotategrid(A,E,-a);
sele = Et<(median(Et)+3*std(Et)) & Et>(median(Et)-1.5*std(Et));
sela = At<(median(At)+3*std(At)) & At>(median(At)-3*std(At));
sel = sele&sela;
A = A(sel);
E = E(sel);
[x,y,a,Seig] = getellips(A,E);

h = plot(A,E,'k.','Color',col);
hold on
h	= ellipse(x,y,2*Seig(1),2*Seig(2),a,col);
hold on
alpha(h,.4);

function [x,y,a,Seig] = plotellipse(Sac,Stim,speaker,col)
sel = Stim(:,11)==speaker;
A	= Sac(sel,8);
E	= Sac(sel,9);
[x,y,a,Seig] = getellips(A,E);
[At,Et] = rotategrid(A,E,-a);
sele = Et<(mean(Et)+3*std(Et)) & Et>(mean(Et)-3*std(Et));
sela = At<(mean(At)+3*std(At)) & At>(mean(At)-3*std(At));
sel = sele&sela;
A = A(sel);
E = E(sel);
[x,y,a,Seig] = getellips(A,E);

plot(A,E,'r.','Color',col)
hold on
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
