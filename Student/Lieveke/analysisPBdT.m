function tmp
close all
clear all
clc

%% Single Sounds


marc

%% Load data
% cd('C:\DATA\Double\MW-PB-2010-07-31');
fname1			= 'C:\DATA\Double\MW-PB-2010-07-31\MW-PB-2010-07-31-0004';

[Sac,Stim]=loadmat([fname1]);
Sac = firstsac(Sac);
checkmissingtrials(Sac,Stim);

% First sound
sel				= ismember(Stim(:,3),2);
Stim1			= Stim(sel,:);
% Second sound
sel				= ismember(Stim(:,3),3);
Stim2			= Stim(sel,:);
% Check for null-sound 2
sel				= Stim2(:,11)==100;
% These are the single-speaker trials
Stimsingle		= Stim1(sel,:);
Sacsingle		= Sac(sel,:);

% Graph them
speakers = [130 120; 131 120;131 108;130 108;131 130;120 108];
figure(99)
subplot(231)
for jj = 1:size(speakers,1)
	spk = speakers(jj,:);
	subplot(2,3,jj)
	[x1,y1,a1,Seig1] = plotellipse(Sacsingle,Stimsingle,spk(1),'b');
	hold on
	[x2,y2,a2,Seig2] = plotellipse(Sacsingle,Stimsingle,spk(2),'r');
	plot([x1 x2],[y1 y2],'k-','LineWidth',1);
	plotmodel(Sacsingle,Stimsingle,spk(1),spk(2))

end



%% Double Sounds
fname1			= 'C:\DATA\Double\MW-PB-2010-07-31\MW-PB-2010-07-31-0002';
fname2			= 'C:\DATA\Double\MW-PB-2010-07-31\MW-PB-2010-07-31-0001';
fname3			= 'C:\DATA\Double\MW-PB-2010-07-31\MW-PB-2010-07-31-0003';
fname4			= 'C:\DATA\Double\MW-PB-2010-07-31\MW-PB-2010-07-31-0004';
[Sac,Stim]	= loadmat([fname1;fname2;fname3;fname4]);
Sac			= firstsac(Sac);
checkmissingtrials(Sac,Stim);

sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);
sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);

%% Double Sounds
sel				= Stim2(:,11)==100;
Stim1			= Stim1(~sel,:);
Stim2			= Stim2(~sel,:);
Sac				= Sac(~sel,:);

dT				= Stim2(:,8)-Stim1(:,8);

X				= [Stim1(:,11) Stim2(:,11) dT];
figure(99)
c = colormap('jet');
indx = round(linspace(1,64,7));
c = c(indx,:);
for ii = 1:6
	subplot(2,3,ii)
	hold on
	axis([-70 70 -70 70]);
	axis square
% 	axis equal
	xlabel('Azimuth (deg)');
	ylabel('Elevation (deg)');
	box on
	verline(0);
	horline(0);
end


lvl = flipud(unique(dT))
figure(99)
for jj = 1:size(speakers,1)
	spk = speakers(jj,:);
	subplot(2,3,jj)
	for ii = 1:length(lvl)
		% 		for ii = 1
% % 		disp('-------------------------------------------');
% % 		disp([spk lvl(ii)])
		sel = (X(:,1) == spk(1) & X(:,2) == spk(2) & round(X(:,3))==lvl(ii));
% 		sum(sel)
		if sum(sel)
			h = plotellipsedouble(Sac,sel,c(ii,:));
			set(h,'FaceColor',c(ii,:),'EdgeColor','none');
		end
		
		sel = (X(:,1) == spk(2) & X(:,2) == spk(1) & X(:,3)==lvl(ii));
% 		sum(sel)
		if sum(sel)
			h = plotellipsedouble(Sac,sel,c(7-ii+1,:));
			set(h,'FaceColor',c(7-ii+1,:),'EdgeColor','none');
		end
	end
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

function [x,y,a,Seig] = plotellipse(Sac,Stim,speaker,col)
sel = Stim(:,11)==speaker;
A	= Sac(sel,8);
E	= Sac(sel,9);
[x,y,a,Seig] = getellips(A,E);

% plot(A,E,'r.','Color',[.7 .7 .7])
hold on
h	= ellipse(x,y,Seig(1),Seig(2),a,col);
hold on
box on
alpha(h,1);
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
alpha(h,.5);
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

function indx = checkmissingtrials(Sac,Stim)
indx = setdiff(Stim(:,1),Sac(:,1));
sel = isnan(indx);
indx = indx(~sel);
if ~isempty(indx)
	disp('---------------------------')
	disp(['Missing in action: ' num2str(numel(indx)) ' trials']);
	disp(indx);
end

function [X,Y] = qrotate(X,Y,Phi)
X   = X*cos(Phi)*cos(wt) - S*sin(Phi)*sin(wt);
Y   = Y + L*sin(Phi)*cos(wt) + S*cos(Phi)*sin(wt);


function plotmodel(Sac,Stim,speaker1,speaker2)
% okay
sel = Stim(:,11)==speaker1;
A1	= Sac(sel,8);
E1	= Sac(sel,9);

sel = Stim(:,11)==speaker2;
A2	= Sac(sel,8);
E2	= Sac(sel,9);

[A1,A2] = meshgrid(A1,A2);
[E1,E2] = meshgrid(E1,E2);

A = (A1+A2)/2;
E = (E1+E2)/2;
A = A(:);
E = E(:);
[x,y,a,Seig] = getellips(A,E);

% plot(A,E,'k.','Color',[.7 .7 .7])
% hold on
h	= ellipse(x,y,Seig(1),Seig(2),a,'k');


