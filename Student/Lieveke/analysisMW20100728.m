function tmp
close all
clear all
clc
%% Single Sounds


cd('C:\DATA\Double\DB-MW-2010-07-27');
fname			= 'DB-MW-2010-07-27-0001';

load(fname)

indx = setdiff(1:800,Sac(:,1));


sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);

sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);

sel				= Stim2(:,11)==100;
Stimsingle		= Stim1(sel,:);
Sacsingle		= Sac(sel,:);

speakers = [130 120; 131 120;131 108;130 108;130 131;108 120];

figure(99)
subplot(231)
for jj = 1:size(speakers,1)
	spk = speakers(jj,:);
subplot(2,3,jj)
[x1,y1,a1,Seig1] = plotellipse(Sacsingle,Stimsingle,spk(1));
hold on
[x2,y2,a2,Seig2] = plotellipse(Sacsingle,Stimsingle,spk(2));
plot([x1 x2],[y1 y2],'k-','LineWidth',1);
end



%%
cd('C:\DATA\Double\DB-MW-2010-07-28');
fname			= 'DB-MW-2010-07-28-0001';

load(fname)
Sac = firstsac(Sac);
indx = setdiff(1:750,Sac(:,1))


sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);
sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);


%% Double Sounds
sel				= Stim2(:,11)==100;
Stim1		= Stim1(~sel,:);
Stim2	= Stim2(~sel,:);
Sac		= Sac(~sel,:);

dT = Stim2(:,8)-Stim1(:,8);
cL2 = round(correctlevel(Stim2(:,11)));
cL1 = round(correctlevel(Stim1(:,11)));
dL = (Stim2(:,10)-cL1)-(Stim1(:,10)-cL1);
% hist(dL,-15:15)

X = [Stim1(:,11) Stim2(:,11) dT dL];
sel8	= X(:,1)==108 | X(:,2)==108;
sel20	= X(:,1)==120 | X(:,2)==120;
sel30	= X(:,1)==130 | X(:,2)==130;
sel31	= X(:,1)==131 | X(:,2)==131;

%%
figure(99)
c = colormap;
indx = round(linspace(1,64,5));
c = c(indx,:);
for ii = 1:6
	subplot(2,3,ii)
% plot(Sac(:,8),Sac(:,9),'k.','Color',[.7 .7 .7])
hold on
axis square
axis([-70 70 -70 70]);
verline(0);
horline(0);
xlabel('Azimuth (deg)');
ylabel('Elevation (deg)');
box on
end


lvl = [146 49 0];
figure(99)
for jj = 1:size(speakers,1)
	spk = speakers(jj,:);
subplot(2,3,jj)
for ii = 1:length(lvl)
	sel = (X(:,1) == spk(1) & X(:,2) == spk(2) & X(:,3)==lvl(ii));
	if sum(sel)
		h = plotellipsedouble(Sac,sel,c(ii,:));
		set(h,'FaceColor',c(ii,:),'EdgeColor',c(ii,:));
	end
	
	sel = (X(:,1) == spk(2) & X(:,2) == spk(1) & X(:,3)==lvl(ii));
	if sum(sel)
		h = plotellipsedouble(Sac,sel,c(6-ii,:));
		set(h,'FaceColor',c(6-ii,:),'EdgeColor',c(6-ii,:));
	end
end
end


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

% h = plot(A,E,'k.','Color',[.7 .7 1])
% hold on
h	= ellipse(x,y,2*Seig(1),2*Seig(2),a,col);
hold on

function [x,y,a,Seig] = plotellipse(Sac,Stim,speaker)
sel = Stim(:,11)==speaker;
A	= Sac(sel,8);
E	= Sac(sel,9);
[x,y,a,Seig] = getellips(A,E);

% plot(A,E,'r.','Color',[.7 .7 .7])
hold on
h	= ellipse(x,y,2*Seig(1),2*Seig(2),a,'k');
hold on
box on