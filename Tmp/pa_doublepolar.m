function pa_doublepolar
%% Initialization
close all
clear all
clc

%% Double-polar coordinates, start with iso-azimuth contours
AZ	= -90:15:90;
AZ	= AZ';
n	= 100; % number of elevations at AZ(ii)
EL	= NaN(length(AZ),n); % create lots of potential elevations
for ii = 1:length(AZ)
	mx = abs(round(abs(AZ(ii))-90));
	if mx>0
		y = linspace(-mx,mx,n);
	else
		y = zeros(1,n);
	end
	EL(ii,:) = y;
end
AZ		= repmat(AZ,1,n);
R		= 1;

%% Conversion
X       = R*sind(AZ); % Left-right
Y       = R*sind(EL); % Up-Down
signZ   = sign(cosd(AZ).*cosd(EL));
absZ    = abs(sqrt(R.^2-X.^2-Y.^2));
Z       = signZ .* absZ;

%% From the back to the front
% x,y,z scheme is rotated in Matlab, so we have to correct for this
X		= [X;fliplr(X)];
Y		= [Y;fliplr(Y)];
Z		= [Z;fliplr(-Z)];
AZ		= [AZ;fliplr(AZ)];
X		= X';
Y		= Y';
Z		= Z';
AZ		= AZ';

%% Graphics
for jj = [1 3 4]
	subplot(2,2,jj);
	plot3([-1 1],[0 0],[0 0],'b:','LineWidth',2);
	hold on
	plot3([-1 1],[0 0],[0 0],'bo','LineWidth',2,'MarkerFaceColor','b');
	% let's give a color-gradient to azimuth
	uAZ = unique(AZ(:)); % unique azimuths
	nAZ = numel(uAZ); % number of unique azimuths
	col = gray(nAZ); % a grayscale colormap
	for ii = 1:nAZ
		sel = AZ==uAZ(ii);
		plot3(X(sel),Y(sel),Z(sel),'k-','LineWidth',2,'Color',col(ii,:));
	end
	axis([-1 1 -1 1 -1 1]);
	axis square;
	axis off;
end


%% Double-polar coordinates, now iso-elevation contours
EL	= -90:15:90;
EL	= EL';
AZ	= NaN(length(EL),n);
for ii = 1:length(EL)
	mx = abs(round(abs(EL(ii))-90));
	if mx>0
		y = linspace(-mx,mx,n);
	else
		y = zeros(1,n);
	end
	AZ(ii,:) = y;
end
EL		= repmat(EL,1,n);
R		= 1;

%% Conversion
X       = R*sind(AZ); % Left-right
Y       = R*sind(EL); % Up-Down
signZ   = sign(cosd(AZ).*cosd(EL));
absZ    = abs(sqrt(R.^2-X.^2-Y.^2));
Z       = signZ .* absZ;

%% From the back to the front
X		= [X;fliplr(X)];
Y		= [Y;fliplr(Y)];
Z		= [Z;fliplr(-Z)];
EL		= [EL;fliplr(EL)];
% x,y,z scheme is rotated in Matlab, so we have to correct for this
X		= X';
Y		= Y';
Z		= Z';
EL		= EL';
[X,Y,Z] = pa_pitch(X(:),Y(:),Z(:),90); % just some rotation, see PANDA toolbox


%% Graphics
for jj = [2 3 4]
subplot(2,2,jj);
plot3([0 0],[0 0],[-1 1],'r:','LineWidth',2);
hold on
plot3([0 0],[0 0],[-1 1],'ro','LineWidth',2,'MarkerFaceColor','r');
% let's give a color-gradient to azimuth
uEL = unique(EL(:)); % unique azimuths
nEL = numel(uEL); % number of unique azimuths
col = gray(nEL); % a grayscale colormap
col = flipud(col);
for ii = 1:nEL
	sel = EL==uEL(ii);
	plot3(X(sel),Y(sel),Z(sel),'k-','LineWidth',2,'Color',col(ii,:));
end
axis([-1 1 -1 1 -1 1]);
axis square;
axis off;
end

subplot(2,2,4)
view(0,0);
axis([-1.01 1.01 -1.01 1.01 -1.01 1.01]);

%% Print
cd('C:\DATA'); % See also PA_DATADIR
print('-depsc','-painter',mfilename); % I try to avoid bitmaps, 
% so I can easily modify the figures later on in for example Illustrator
% For web-and Office-purposes, I later save images as PNG-files

function [X,Y,Z] = pa_pitch(X,Y,Z,Angle)
% [X,Y,Z] = PA_YAW(X,Y,Z,ROLL);
%
% Rotate YAW (deg) about the X-axis
%
% See also PA_YAW, PA_ROLL

% 2007 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
% Compensate for Coordinate Definition
[mx,nx] = size(X);
[my,ny] = size(Y);
[mz,nz] = size(Z);

% Compensate for Coordinate Definition in Matlab
x = X(:);
y = -Z(:);
z = Y(:);


Angle = deg2rad(Angle);

%% Define Roll Rotation Matrix for 3D
R = [1 0          0           0;...
    0  cos(Angle) -sin(Angle) 0;...
    0  sin(Angle) cos(Angle)  0;...
    0  0          0           1];

%% Define Data Matrix
M = [x y z ones(size(x))]';

%% Matrix Multiply
M = R*M;

%% Revert
M = M';
X = M(:,1);
Y = M(:,3);
Z = -M(:,2);

% Reshape
X = reshape(X,mx,nx);
Y = reshape(Y,my,ny);
Z = reshape(Z,mz,nz);