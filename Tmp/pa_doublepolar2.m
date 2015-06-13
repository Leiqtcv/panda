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
plot(AZ,EL,'.');

%% Graphics
for jj = [1 3]
	subplot(1,3,jj);
	% let's give a color-gradient to azimuth
	uAZ = unique(AZ(:)); % unique azimuths
	nAZ = numel(uAZ); % number of unique azimuths
	col = cool(nAZ); % a cool colormap
	for ii = 1:nAZ
		sel = AZ==uAZ(ii);
		plot(AZ(sel),EL(sel),'k-','LineWidth',2,'Color',col(ii,:));
		hold on
	end
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



%% Graphics
for jj = [2 3]
	subplot(1,3,jj);
	hold on
	uEL = unique(EL(:)); 
	nEL = numel(uEL); 
	col = hot(nEL); % a hot colormap
	col = flipud(col);
	for ii = 1:nEL
		sel = EL==uEL(ii);
		plot(AZ(sel),EL(sel),'k-','LineWidth',2,'Color',col(ii,:));
	end
end

for ii = 1:3
	subplot(1,3,ii)
h = plot([-90 -0],[0 90],'k-',...
    [0 90],[90 0],'k-',...
    [0 90],[-90 0],'k-',...
    [-90 0],[0 -90],'k-');
set(h,'LineWidth',2,'Color','k');
	axis([-90 90 -90 90]);
	axis square;
	box off
	set(gca,'XTick',-60:30:60,'YTick',-60:30:60);
	xlabel('Azimuth (deg)');
	ylabel('Elevation (deg)');
end

%% Print
cd('C:\DATA'); % See also PA_DATADIR
print('-depsc','-painter',mfilename); % I try to avoid bitmaps, 
% so I can easily modify the figures later on in for example Illustrator
% For web-and Office-purposes, I later save images as PNG-files
