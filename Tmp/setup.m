function tmp

close all
clear all
pa_datadir

%% Double-polar coordinates, start with iso-azimuth contours
AZ  = -90:15:90;
AZ  = AZ';
n  = 100; % number of elevations at AZ(ii)
EL  = NaN(length(AZ),n); % create lots of potential elevations
for ii = 1:length(AZ)
  mx = abs(round(abs(AZ(ii))-90));
  if mx>0
    y = linspace(-mx,mx,n);
  else
    y = zeros(1,n);
  end
  EL(ii,:) = y;
end
AZ    = repmat(AZ,1,n);
R    = 1;
 
%% Conversion
X       = R*sind(AZ); % Left-right
Y       = R*sind(EL); % Up-Down
signZ   = sign(cosd(AZ).*cosd(EL));
absZ    = abs(sqrt(R.^2-X.^2-Y.^2));
Z       = signZ .* absZ;
 
%% From the back to the front
% x,y,z scheme is rotated in Matlab, so we have to correct for this
X    = [X;fliplr(X)];
Y    = [Y;fliplr(Y)];
Z    = [Z;fliplr(-Z)];
AZ    = [AZ;fliplr(AZ)];
X    = X';
Y    = Y';
Z    = Z';
AZ    = AZ';
 
%% Graphics
for jj = [2 4 5 6]
  subplot(2,3,jj);
  hold on

  % let's give a color-gradient to azimuth
  uAZ = unique(AZ(:)); % unique azimuths
  nAZ = numel(uAZ); % number of unique azimuths
  col = gray(nAZ); % a grayscale colormap
  for ii = 1:nAZ
    sel = AZ==uAZ(ii);
    plot3(X(sel),Y(sel),Z(sel),'k-','LineWidth',1);
  end
end
 

%% Double-polar coordinates, now iso-elevation contours
EL  = -90:15:90;
EL  = EL';
AZ  = NaN(length(EL),n);
for ii = 1:length(EL)
  mx = abs(round(abs(EL(ii))-90));
  if mx>0
    y = linspace(-mx,mx,n);
  else
    y = zeros(1,n);
  end
  AZ(ii,:) = y;
end
EL    = repmat(EL,1,n);
R    = 1;
 
%% Conversion
X       = R*sind(AZ); % Left-right
Y       = R*sind(EL); % Up-Down
signZ   = sign(cosd(AZ).*cosd(EL));
absZ    = abs(sqrt(R.^2-X.^2-Y.^2));
Z       = signZ .* absZ;
 
%% From the back to the front
X    = [X;fliplr(X)];
Y    = [Y;fliplr(Y)];
Z    = [Z;fliplr(-Z)];
EL    = [EL;fliplr(EL)];
% x,y,z scheme is rotated in Matlab, so we have to correct for this
X    = X';
Y    = Y';
Z    = Z';
EL    = EL';
[X,Y,Z] = pa_pitch(X(:),Y(:),Z(:),90); % just some rotation, see PANDA toolbox
 
 
%% Graphics
for jj = [2 4 5 6]
subplot(2,3,jj);
hold on
uEL = unique(EL(:)); % unique azimuths
nEL = numel(uEL); % number of unique azimuths
col = gray(nEL); % a grayscale colormap
col = flipud(col);
for ii = 1:nEL
  sel = EL==uEL(ii);
  plot3(X(sel),Y(sel),Z(sel),'k-','LineWidth',1);
  view(3)
  xlabel('X (links-rechts)');
ylabel('Y (beneden-boven)');
zlabel('Z (achter-voor)');
axis square
end

end

% return
%% Actual



Nspeakers = 128;

az	= linspace(-90,90,13);
el	= linspace(-90,90,13);
[az,el] = meshgrid(az,el);
az	= az(:);
el	= el(:);
sel = abs(az)+abs(el)<=90 & el>-60;
az	= az(sel);
el	= el(sel);

% Back

el2 = linspace(90,120,3);
az2 = linspace(-90,90,13);
[az2,el2] = meshgrid(az2,el2);
az2 = az2(:);
el2 = el2(:);
sel = abs(az2)+abs(180-el2)<90;
az2 = az2(sel);
el2 = el2(sel);
az = [az; az2];
el = [el; el2];

az2 = linspace(90,120,3);
el2 = linspace(-90,90,13);
[az2,el2] = meshgrid(az2,el2);
az2 = az2(:);
el2 = el2(:);
sel = abs(180-az2)+abs(el2)<90;
az2 = az2(sel);
el2 = el2(sel);
az = [az; az2];
el = [el; el2];

az2 = linspace(-120,-90,3);
el2 = linspace(-90,90,13);
[az2,el2] = meshgrid(az2,el2);
az2 = az2(:);
el2 = el2(:);
sel = abs(180+az2)+abs(el2)<90;
az2 = az2(sel);
el2 = el2(sel);
az = [az; az2];
el = [el; el2];

% high-density
az2 = -50:5:50;
el2 =zeros(size(az2));
az2 = az2(:);
el2 = el2(:);
az = [az; az2];
el = [el; el2];

el2 = -50:5:50;
az2 = zeros(size(el2));
az2 = az2(:);
el2 = el2(:);
az = [az; az2];
el = [el; el2];

azel	= unique(round([az el]),'rows');
az		= round(azel(:,1));
el		= round(azel(:,2));

col = pa_statcolor(4,[],[],[],'def',6);
col1 = col(:,[3 2 1]);
col2 = pa_statcolor(4,[],[],[],'def',7);

%% Colorize
sel1 = ismember(az,round(-120:30:120)) & ismember(el,round(-120:30:120)); % b
sel2 = ismember(az,round(-105:30:120)) & ismember(el,round(-120:30:120)); % g
sel3 = ismember(az,round(-105:30:120)) & ismember(el,round(-105:30:120)) & ~ismember(el,75); % y
sel4 = ismember(az,round(-120:30:120)) & ismember(el,round(-105:30:120)); % c
sel5 = ismember(az,-40:15:45) & ismember(el,0) & ~ismember(az,round(-120:15:120)); % c
sel6 = (ismember(az,-50:15:50) | ismember(az,50)) & ismember(el,0) & ~ismember(az,round(-120:15:120)) ; % c
sel7 = (ismember(el,-40:15:45) | ismember(el,[-50 50])) & ismember(az,0) & ~ismember(el,round(-120:15:120)); % c
sel8 = ismember(el,-35:15:45) & ismember(az,0) & ~ismember(el,round(-120:15:120)); % c
sel9 = ismember(az,round(-105:30:120)) & ismember(el,75); % y

n1 = sum(sel1) + sum(sel9)
n2 = sum(sel2) + sum(sel7)
n3 = sum(sel3) + sum(sel5)  + sum(sel8)
n4 = sum(sel4) + sum(sel6)
% sel2 = ismember(az,round(-105:30:120)) ; % g
% sel3 = ismember(az,round(-105:30:120)) ; % y
% return
%%
N = numel(az);
d = Nspeakers-N;
n = numel(az)

subplot(231)
hold on
plot(az(sel1),el(sel1),'ko','MarkerFaceColor',col1(1,:),'MarkerSize',10);
plot(az(sel2),el(sel2),'ko','MarkerFaceColor',col1(2,:),'MarkerSize',10);
plot(az(sel3),el(sel3),'ko','MarkerFaceColor',col1(3,:),'MarkerSize',10);
plot(az(sel9),el(sel9),'ko','MarkerFaceColor',col1(1,:),'MarkerSize',10);
plot(az(sel4),el(sel4),'ko','MarkerFaceColor',col1(4,:),'MarkerSize',10);
plot(az(sel5),el(sel5),'ko','MarkerFaceColor',col2(1,:),'MarkerSize',10);
plot(az(sel6),el(sel6),'ko','MarkerFaceColor',col2(2,:),'MarkerSize',10);
plot(az(sel7),el(sel7),'ko','MarkerFaceColor',col2(3,:),'MarkerSize',10);
plot(az(sel8),el(sel8),'ko','MarkerFaceColor',col2(4,:),'MarkerSize',10);

text(az(sel1),el(sel1),'1','HorizontalAlignment','center');
text(az(sel2),el(sel2),'2','HorizontalAlignment','center');
text(az(sel3),el(sel3),'3','HorizontalAlignment','center','Color','w');
text(az(sel9),el(sel9),'1','HorizontalAlignment','center');
text(az(sel4),el(sel4),'4','HorizontalAlignment','center','Color','w');
text(az(sel5),el(sel5),'3','HorizontalAlignment','center');
text(az(sel6),el(sel6),'4','HorizontalAlignment','center');
text(az(sel7),el(sel7),'2','HorizontalAlignment','center','Color','w');
text(az(sel8),el(sel8),'3','HorizontalAlignment','center','Color','w');

axis square;
box off
set(gca,'TickDir','out','Xtick',-120:30:120,'Ytick',-120:30:120);
axis([-130 130 -130 130]);
xlabel('Azimuth \circ');
ylabel('Elevation \circ');
title('Abstract coordinaten systeem');

[x,y,z] = pa_azel2cart(az,el);
[x,y,z] = pa_pitch(x(:),y(:),z(:),90); % just some rotation, see PANDA toolbox
y = -y;

subplot(232)
hold on
plot3(x(sel1),y(sel1),z(sel1),'ko','MarkerFaceColor',col1(1,:),'MarkerSize',10);
plot3(x(sel2),y(sel2),z(sel2),'ko','MarkerFaceColor',col1(2,:),'MarkerSize',10);
plot3(x(sel3),y(sel3),z(sel3),'ko','MarkerFaceColor',col1(3,:),'MarkerSize',10);
plot3(x(sel9),y(sel9),z(sel9),'ko','MarkerFaceColor',col1(1,:),'MarkerSize',10);
plot3(x(sel4),y(sel4),z(sel4),'ko','MarkerFaceColor',col1(4,:),'MarkerSize',10);
plot3(x(sel5),y(sel5),z(sel5),'ko','MarkerFaceColor',col2(1,:),'MarkerSize',10);
plot3(x(sel6),y(sel6),z(sel6),'ko','MarkerFaceColor',col2(2,:),'MarkerSize',10);
plot3(x(sel7),y(sel7),z(sel7),'ko','MarkerFaceColor',col2(3,:),'MarkerSize',10);
plot3(x(sel8),y(sel8),z(sel8),'ko','MarkerFaceColor',col2(4,:),'MarkerSize',10);

text(x(sel1),y(sel1),z(sel1),'1','HorizontalAlignment','center');
text(x(sel2),y(sel2),z(sel2),'2','HorizontalAlignment','center');
text(x(sel3),y(sel3),z(sel3),'3','HorizontalAlignment','center','Color','w');
text(x(sel9),y(sel9),z(sel9),'1','HorizontalAlignment','center','Color','w');
text(x(sel4),y(sel4),z(sel4),'4','HorizontalAlignment','center','Color','w');
text(x(sel7),y(sel7),z(sel7),'2','HorizontalAlignment','center');
text(x(sel8),y(sel8),z(sel8),'3','HorizontalAlignment','center');
text(x(sel5),y(sel5),z(sel5),'3','HorizontalAlignment','center');
text(x(sel6),y(sel6),z(sel6),'4','HorizontalAlignment','center');

axis square;
axis([-1.1 1.1 -1.1 1.1 -1.1 1.1]);
view(3);
xlabel('X (links-rechts)');
zlabel('Y (beneden-boven)');
ylabel('Z (achter-voor)');
set(gca,'TickDir','out','Xtick',-1:0.5:1,'Ytick',-1:0.5:1,'Ztick',-1:0.5:1);
% grid on

subplot(234)
% plot3(x,y,z,'ko','MarkerFaceColor','r');
hold on
plot3(x(sel1),y(sel1),z(sel1),'ko','MarkerFaceColor',col1(1,:),'MarkerSize',10);
plot3(x(sel2),y(sel2),z(sel2),'ko','MarkerFaceColor',col1(2,:),'MarkerSize',10);
plot3(x(sel3),y(sel3),z(sel3),'ko','MarkerFaceColor',col1(3,:),'MarkerSize',10);
plot3(x(sel9),y(sel9),z(sel9),'ko','MarkerFaceColor',col1(1,:),'MarkerSize',10);
plot3(x(sel4),y(sel4),z(sel4),'ko','MarkerFaceColor',col1(4,:),'MarkerSize',10);
plot3(x(sel5),y(sel5),z(sel5),'ko','MarkerFaceColor',col2(1,:),'MarkerSize',10);
plot3(x(sel6),y(sel6),z(sel6),'ko','MarkerFaceColor',col2(2,:),'MarkerSize',10);
plot3(x(sel7),y(sel7),z(sel7),'ko','MarkerFaceColor',col2(3,:),'MarkerSize',10);
plot3(x(sel8),y(sel8),z(sel8),'ko','MarkerFaceColor',col2(4,:),'MarkerSize',10);

text(x(sel1),y(sel1),z(sel1),'1','HorizontalAlignment','center');
text(x(sel2),y(sel2),z(sel2),'2','HorizontalAlignment','center');
text(x(sel3),y(sel3),z(sel3),'3','HorizontalAlignment','center','Color','w');
text(x(sel9),y(sel9),z(sel9),'1','HorizontalAlignment','center');
text(x(sel4),y(sel4),z(sel4),'4','HorizontalAlignment','center','Color','w');
text(x(sel7),y(sel7),z(sel7),'2','HorizontalAlignment','center','Color','w');
text(x(sel8),y(sel8),z(sel8),'3','HorizontalAlignment','center','Color','w');
text(x(sel5),y(sel5),z(sel5),'3','HorizontalAlignment','center');
text(x(sel6),y(sel6),z(sel6),'4','HorizontalAlignment','center');

axis square;
axis([-1.1 1.1 -1.1 1.1 -1.1 1.1]);
view(0,0);
xlabel('X (links-rechts)');
zlabel('Y (beneden-boven)');
ylabel('Z (achter-voor)');
set(gca,'TickDir','out','Xtick',-1:0.5:1,'Ytick',-1:0.5:1,'Ztick',-1:0.5:1);
% grid on
title('Vooraanzicht');


subplot(235)
hold on
plot3(x(sel1),y(sel1),z(sel1),'ko','MarkerFaceColor',col1(1,:),'MarkerSize',10);
plot3(x(sel2),y(sel2),z(sel2),'ko','MarkerFaceColor',col1(2,:),'MarkerSize',10);
plot3(x(sel3),y(sel3),z(sel3),'ko','MarkerFaceColor',col1(3,:),'MarkerSize',10);
plot3(x(sel9),y(sel9),z(sel9),'ko','MarkerFaceColor',col1(1,:),'MarkerSize',10);
plot3(x(sel4),y(sel4),z(sel4),'ko','MarkerFaceColor',col1(4,:),'MarkerSize',10);
plot3(x(sel5),y(sel5),z(sel5),'ko','MarkerFaceColor',col2(1,:),'MarkerSize',10);
plot3(x(sel6),y(sel6),z(sel6),'ko','MarkerFaceColor',col2(2,:),'MarkerSize',10);
plot3(x(sel7),y(sel7),z(sel7),'ko','MarkerFaceColor',col2(3,:),'MarkerSize',10);
plot3(x(sel8),y(sel8),z(sel8),'ko','MarkerFaceColor',col2(4,:),'MarkerSize',10);
text(x(sel1),y(sel1),z(sel1),'1','HorizontalAlignment','center');
text(x(sel2),y(sel2),z(sel2),'2','HorizontalAlignment','center');
text(x(sel3),y(sel3),z(sel3),'3','HorizontalAlignment','center','Color','w');
text(x(sel9),y(sel9),z(sel9),'1','HorizontalAlignment','center');
text(x(sel4),y(sel4),z(sel4),'4','HorizontalAlignment','center','Color','w');
text(x(sel7),y(sel7),z(sel7),'2','HorizontalAlignment','center','Color','w');
text(x(sel8),y(sel8),z(sel8),'3','HorizontalAlignment','center','Color','w');
text(x(sel5),y(sel5),z(sel5),'3','HorizontalAlignment','center');
text(x(sel6),y(sel6),z(sel6),'4','HorizontalAlignment','center');


axis square;
axis([-1.1 1.1 -1.1 1.1 -1.1 1.1]);
view(0,90);
xlabel('X (links-rechts)');
zlabel('Y (beneden-boven)');
ylabel('Z (achter-voor)');
set(gca,'TickDir','out','Xtick',-1:0.5:1,'Ytick',-1:0.5:1,'Ztick',-1:0.5:1);
% grid on
title('Bovenaanzicht');

subplot(236)
hold on
plot3(x(sel1),y(sel1),z(sel1),'ko','MarkerFaceColor',col1(1,:),'MarkerSize',10);
plot3(x(sel2),y(sel2),z(sel2),'ko','MarkerFaceColor',col1(2,:),'MarkerSize',10);
plot3(x(sel3),y(sel3),z(sel3),'ko','MarkerFaceColor',col1(3,:),'MarkerSize',10);
plot3(x(sel9),y(sel9),z(sel9),'ko','MarkerFaceColor',col1(1,:),'MarkerSize',10);
plot3(x(sel4),y(sel4),z(sel4),'ko','MarkerFaceColor',col1(4,:),'MarkerSize',10);
plot3(x(sel5),y(sel5),z(sel5),'ko','MarkerFaceColor',col2(1,:),'MarkerSize',10);
plot3(x(sel6),y(sel6),z(sel6),'ko','MarkerFaceColor',col2(2,:),'MarkerSize',10);
plot3(x(sel7),y(sel7),z(sel7),'ko','MarkerFaceColor',col2(3,:),'MarkerSize',10);
plot3(x(sel8),y(sel8),z(sel8),'ko','MarkerFaceColor',col2(4,:),'MarkerSize',10);

text(x(sel1),y(sel1),z(sel1),'1','HorizontalAlignment','center');
text(x(sel2),y(sel2),z(sel2),'2','HorizontalAlignment','center');
text(x(sel3),y(sel3),z(sel3),'3','HorizontalAlignment','center','Color','w');
text(x(sel9),y(sel9),z(sel9),'1','HorizontalAlignment','center');
text(x(sel4),y(sel4),z(sel4),'4','HorizontalAlignment','center','Color','w');
text(x(sel7),y(sel7),z(sel7),'2','HorizontalAlignment','center','Color','w');
text(x(sel8),y(sel8),z(sel8),'3','HorizontalAlignment','center','Color','w');
text(x(sel5),y(sel5),z(sel5),'3','HorizontalAlignment','center');
text(x(sel6),y(sel6),z(sel6),'4','HorizontalAlignment','center');


axis square;
axis([-1.1 1.1 -1.1 1.1 -1.1 1.1]);
view(90,0);
xlabel('X (links-rechts)');
zlabel('Y (beneden-boven)');
ylabel('Z (achter-voor)');
set(gca,'TickDir','out','Xtick',-1:0.5:1,'Ytick',-1:0.5:1,'Ztick',-1:0.5:1);
% grid on
title('Zijaanzicht');

%%



pa_datadir;
print('-dpng','-r300','setup2');
return
%% Sounds
% moving sounds
sel = ismember(el,0) & az>=-50 & az<=50;
sploc = az(sel)

close all
f = 1;
t = 0:0.001:20;
x = 50*sin(2*pi*f*t);

% x = -50:5:50; % deg
% v = 100; % deg/s
% t = x/v;
subplot(311)
plot(t,x,'k-');


function RGB = pa_statcolor(ncol,statmap,palette,Par,varargin)
% C = PA_STATCOLOR(NCOL,STATMAP,PALETTE)
%
% Choose a color palette for statistical graphs.
%
% Statistical map:
%	- Qualitative
%		for categories, nominal data. Default palettes include:
%			# Dynamic (d)	- 1
%			# Harmonic (h)	- 2 
%			# Cold (c)		- 3
%			# Warm (w)		- 4
%
%	- Sequential
%		for numerical information, for metric & ordinal data, when low
%		values are uninteresting and high values interesting. Default
%		palettes include:
%			# Luminance, l	- 5
%			# LumChrm, lc	- 6
%			# LumChrmH, lch - 7
%
%	- Diverging				- 8
%		for numerical information, for metric & ordinal data, when negative
%		(low) values and positive (high) values are interesting and a
%		neutral value (0) is insignificant. This map has no palette. 
%							
%
%
% Example usage:
% >> ColMap = pa_statcolor(64,'sequential','l',260);
% >> colormap(ColMap)
%
% This function is based on:
% Zeileis, Hornik, Murrel. Escaping RGBland: Selecting colors for
% statistical graphics. Computational Statistics and Data Analysis 53
% (2009) 3259?3270
% http://www.sciencedirect.com/science/article/pii/S0167947308005549 
%
% Note: has not been tested
%
% See also:
% http://research.stowers-institute.org/efg/R/Color/Chart/
% http://geography.uoregon.edu/datagraphics/color_scales.htm
% http://hclcolor.com/

% As per point 5 from
% http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html, a
% citation:
% Brewer, Cynthia A., 2013. http://www.ColorBrewer.org, accessed 29-07-2013

% 2013 Marc van Wanrooij
% e: marcvanwanrooij@neural-code.com

%% Check
if nargin<1
	ncol = 2^8;
	close all
end
if nargin<2
	% 	statmap = 'qualitative';
	statmap = 'sequential';
end
if nargin<3
	palette = 'luminancechroma';
end
if nargin<4
	% 	Par = [Lmin Lmax Cmin Cmax Hmin Hmax];
	Par = [100 0 100 20];
end
dispFlag = pa_keyval('disp',varargin);
if isempty(dispFlag)
	dispFlag = false;
end
def = pa_keyval('def',varargin);

%% Default values
switch def
	case 1
		statmap = 'qualitative';
		palette = 'dynamic';
		Par		= [];
	case 2
		statmap = 'qualitative';
		palette = 'harmonic';
		Par		= [];
	case 3
		statmap = 'qualitative';
		palette = 'cold';
		Par		= [];
	case 4
		statmap = 'qualitative';
		palette = 'warm';
		Par		= [];
	case 5
		statmap = 'sequential';
		palette = 'luminance';
		Par		= [];
	case 6
		statmap = 'sequential';
		palette = 'luminancechroma';
		Par		= [0 100 100 20]; % [Lmin Lmax Cmax H]
	case 7
		statmap = 'sequential';
		palette = 'luminancechromahue';
		Par = [0 100 100 100 30 90]; % [Lmin Lmax Cmin Cmax H1 H2] % Heat
	case 8
		statmap = 'diverging';
		palette = [];
		Par = [10 100 100 260 30]; % [Lmin Lmax Cmax H1 H2] 'Blue-White-Red'
		% 		Par = [40 100 90 140 320]; % [Lmin Lmax Cmax H1 H2] 'Green-White-Purple'
	case 9
		statmap = 'sequential';
		palette = 'luminancechromahue';
		Par = [70 70 70 70 0 360]; % [Lmin Lmax Cmin Cmax H1 H2] %Rainbow
	case 10
		statmap = 'divergingskew';
		palette = [];
		Par = [00 100 100 260 30]; % [Lmin Lmax Cmax H1 H2] 'Blue-White-Red'
end
statmap = lower(statmap);
palette = lower(palette);

switch statmap
	case 'qualitative'
		switch palette
			case {'d','dynamic'}
				H		= linspace(30,300,ncol);
			case {'h','harmonic'}
				H		= linspace(60,240,ncol);
			case {'c','cold'}
				H		= linspace(270,150,ncol);
			case {'w','warm'}
				H		= linspace(90,-30,ncol);
		end
		C		= repmat(70,1,ncol);
		L		= repmat(70,1,ncol);
		LCH		= [L;C;H]';
		
		
	case 'sequential'
		switch palette
			case {'l','luminance'}
				l		= linspace(0,2,ncol);
				H		= repmat(300,1,ncol);
				C		= zeros(1,ncol);
				L		= 90-l*30;
				LCH		= [L;C;H]';
				
			case {'lc','luminancechroma'}
				l		= linspace(0,1,ncol);
				p		= 1;
				fl		= l.^p;
				Cmax	= Par(3);
				Lmax	= Par(2);
				Lmin	= Par(1);
				H		= Par(4);
				H		= repmat(H,1,ncol);
				C		= zeros(1,ncol)+fl*Cmax;
				L		= Lmax-fl*(Lmax-Lmin);
				LCH		= [L;C;H]';
				
			case {'lch','luminancechromahue'}
				l		= linspace(0,1,ncol);
				p		= 1;
				fl		= l.^p;
				Cmax	= Par(4);
				Cmin	= Par(3);
				Lmax	= Par(2);
				Lmin	= Par(1);
				H1		= Par(5);
				H2		= Par(6);
				H		= H2-l*(H2-H1);
				C		= Cmax-fl*(Cmax-Cmin);
				L		= Lmax-fl*(Lmax-Lmin);
				LCH		= [L;C;H]';
				
		end
	case 'diverging'
		nhalf	= ceil(ncol/2);
		l		= linspace(0,1,nhalf);
		p		= 1;
		fl		= l.^p;
		Cmax	= Par(3);
		Lmax	= Par(2);
		Lmin	= Par(1);
		H1		= Par(4);
		H2		= Par(5);
		
		H1		= repmat(H1,1,nhalf);
		H2		= repmat(H2,1,nhalf);
		C		= zeros(1,ncol/2)+fl*Cmax;
		L		= Lmax-fl*(Lmax-Lmin);
		LCH1	= flipud([L;C;H1]');
		LCH2	= [L;C;H2]';
		LCH		= [LCH1; LCH2];

	case 'divergingskew'
		nthird	= ceil(ncol/3);
		l1		= linspace(0,1,nthird);
		l2		= linspace(0,1,ncol-nthird);
		p		= 1;
		fl1		= l1.^p;
		fl2		= l2.^p;
		Cmax	= Par(3);
		Lmax	= Par(2);
		Lmin	= Par(1);
		H1		= Par(4);
		H2		= Par(5);
		
		H1		= repmat(H1,1,nthird);
		H2		= repmat(H2,1,ncol-nthird);
		C1		= zeros(1,nthird)+fl1*Cmax;
		C2		= zeros(1,ncol-nthird)+fl2*Cmax;
		L1		= Lmax-fl1*(Lmax-Lmin);
		L2		= Lmax-fl2*(Lmax-Lmin);
		LCH1	= flipud([L1;C1;H1]');
		LCH2	= [L2;C2;H2]';
		LCH		= [LCH1; LCH2];
				
end
RGB		= pa_LCH2RGB(LCH);

if dispFlag
plotcolmap(RGB)
end

function plotcolmap(RGB)
% PLOTCOLMAP(RGB)
% Plot the colors on a scale
% ncol	= size(RGB,1);
% for ii	= 1:ncol
% 	plot(ii,1,'ks','MarkerFaceColor',RGB(ii,:),'MarkerSize',15,'MarkerEdgeColor','k');
% 	hold on
% end
% xlim([0 ncol+1]);
% ylim([0 2])
% axis off

[m,n] = size(RGB);
RGB		= reshape(RGB,1,m,n);
image(RGB)
axis off;
