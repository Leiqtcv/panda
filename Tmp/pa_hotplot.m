function pa_hotplot(SupSac)
% HOTPLOT(SUPSAC)
%   or
% HOTPLOT(MATFNAME)
%
% 'Hotplot' of responses
%
% See also PLOTLOC, PLOTGRID, SUPERSAC
%
% Marcus

%% Initialization
if nargin<1
    Sac     = [];
    Stim    = [];
    fname   =[];
    fname   = fcheckexist(fname,'.mat');
    load(fname);
    SupSac  = supersac(Sac,Stim);
close all;
else
    fname   =     inputname(1);
end
% sel = SupSac(:,30)==901;
% SupSac = SupSac(sel,:);
%% Obtaining Grid
% Obtain target locations and mean responses in vector style
Az              = SupSac(:,8);
El              = SupSac(:,9);
TarAz           = SupSac(:,23);
TarEl           = SupSac(:,24);

%%
center          = -90:5:90;
range           = 15;
lc          = length(center);
HOT         = NaN(lc,lc);
HOTTAR      = NaN(lc,lc);
for i       = 1:length(center)
    for j   = 1:length(center)
        sel = sqrt((Az-center(i)).^2+(El-center(j)).^2)<range;
%         sel = Az<center(i)+range & Az>center(i)-range & El<center(j)+range & El>center(j)-range;
        HOT(i,j) = sum(sel);
        sel = sqrt((TarAz-center(i)).^2+(TarEl-center(j)).^2)<range;
%         sel = TarAz<center(i)+range & TarAz>center(i)-range & TarEl<center(j)+range & TarEl>center(j)-range;
        HOTTAR(i,j) = sum(sel);
    end
end
HOTTAR(HOTTAR==0)=NaN;
sel         = abs(meshgrid(center,center))+abs(meshgrid(center,center)')>90;
HOT(sel)    = NaN;
HOTTAR(sel) = NaN;
% HOT         = HOT./HOTTAR;

HOT = HOT./nanmax(nanmax(HOT));
contourf(center,center,HOT',20);
xlabel('Azimuth (deg');
ylabel('Elevation (deg)');
[pathstr,name]=fileparts(fname);
title(name);
hold on
h                                         = plot([-90 0],[0 90],'k',...
    [0 90],[90 0],'r',...
    [90 0],[0 -90],'r',...
    [0 -90],[-90 0],'r');set(h,'LineWidth',2,'Color','k')
axis square;
caxis([0 1]);
shading flat;
colormap jet
colorbar
axis off;

% h=plot(TarAz,TarEl,'ko');set(h,'MarkerFaceColor','w');
