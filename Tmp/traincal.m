function varargout = traincal(varargin)
% Check fixation and train calibration networks
%
% TRAINCAL(FNAME)
%
%  TRAINCAL
%
%   Train backpropagation networks with the calibration data in file FNAME.
%
%   NOTE: a good calibrated network will produce a coherent calibration rose,
%   and has little errors with mu~0 and std<2.0.
%
%
%  See also CALIBRATE, ULTRADET
%
%  Author: Marcus
%  Date: 06-04-07


% Edit the above text to modify the response to help fixcheck

% Last Modified by GUIDE v2.5 23-Apr-2007 15:41:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @traincal_OpeningFcn, ...
    'gui_OutputFcn',  @traincal_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before traincal is made visible.
function traincal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to traincal (see VARARGIN)

% Choose default command line output for traincal
handles.output                      = hObject;

handles                             = Check_And_Load(handles, varargin{:});
handles                             = trainnet(handles);
home;
disp('NEW CALL');

handles                             = plotXYZvsAZEL(handles);
handles                             = plottrain(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes traincal wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% CHECK and LOAD
function handles                    = Check_And_Load(handles,varargin)
% remove some warnings
warning('off','MATLAB:plot:IgnoreImaginaryXYPart');

lv                                  = length(varargin);
if lv<1
    handles.fname                   = [];
    handles.fname                   = fcheckexist(handles.fname,'*.dat');
end
if length(varargin)==1
    handles.fname                   = varargin{1};
    handles.fname                   = fcheckext(handles.fname,'.dat');
    handles.fname                   = fcheckexist(handles.fname);
end

% Check for button-calibration
% Check for number of channels
%

% Trial, stimulus and channel information
handles.csvfile                     = fcheckext(handles.fname,'csv');
[expinfo,chaninfo,mLog]             = readcsv(handles.csvfile);
handles.Nsamples                    = chaninfo(1,6);
handles.Fsample                     = chaninfo(1,5);
handles.Ntrial                      = max(mLog(:,1));
handles.StimType                    = mLog(:,5);
handles.StimOnset                   = mLog(:,8);
handles.Stim                        = log2stim(mLog);
handles.NChan                       = expinfo(1,8);
DAT                                 = loaddat(handles.fname, handles.NChan, handles.Nsamples, handles.Ntrial);
% Traces
handles.hortrace                    = squeeze(DAT(:,:,1));
handles.vertrace                    = squeeze(DAT(:,:,2));
handles.fronttrace                  = squeeze(DAT(:,:,3));
% Average of traces
handles.H                           = mean(handles.hortrace);
handles.V                           = mean(handles.vertrace);
handles.F                           = mean(handles.fronttrace);
% Select Fixation LED (LED = type 0)
if any(handles.Stim(:,3) == 5)
    sel                                 = handles.Stim(:,3) == 5;
    handles.sky = 1;
else
    sel                                 = handles.Stim(:,3) == 0;
    handles.sky = 0;
end
handles.TarAz                       = handles.Stim(sel,4);
handles.TarEl                       = handles.Stim(sel,5);
% Network Properties
handles.NhiddenHor                  = 5;
set(handles.edit_nhidden_hor,'Value',handles.NhiddenHor);
handles.NhiddenVer                  = 5;
set(handles.edit_nhidden_ver,'Value',handles.NhiddenVer);
handles.netfname                       = fcheckext(handles.fname,'net');
set(handles.edit_netfname,'String',handles.netfname);
set(handles.popupmenu_algorithm,'Value',2);
index_algorithm                      = get(handles.popupmenu_algorithm,'Value');
switch index_algorithm
    case 1
        handles.netalgorithm        = 'trainlm';
    case 2
        handles.netalgorithm        = 'trainbr';
end
handles.FixRem                      = [];
handles.Fix                         = 1:length(handles.H);
handles.zoom                        = false;
zoom off;
handles.azimuthspoke                = 0;
handles.elevationspoke              = 0;

%%
% Obtain target locations and mean responses in vector style
C                                   = handles.Fix;
TarAz                               = handles.TarAz(C);
TarEl                               = handles.TarEl(C);
Az                                  = handles.H;
El                                  = handles.V;
Tar                                 = unique([round(TarAz) round(TarEl)],'rows');
Res                                 = ones(size(Tar));
for i                               = 1:length(Tar)
    sel                             = round(TarAz) == Tar(i,1) & round(TarEl) == Tar(i,2);
    Res(i,:)                        = [mean(Az(sel)) mean(El(sel))];
end
% create grids for each potential unique Target location
uEl                                 = unique(Tar(:,2));
nEl                                 = length(uEl);
lAz                                 = 1:nEl;
% obtain maximum number of azimuths for one elevation
for i                               = 1:nEl
    sel                             = Tar(:,2) == uEl(i);
    lAz(i)                          = length(Tar(sel,1));
end
% define NaN-grid based on maximum number of locations (Az*El)
mlAz                                = max(lAz);
AzGrid                              = NaN*ones(mlAz,nEl);
ElGrid                              = AzGrid;
% define response NaN-grid
AzRes                               = AzGrid;
ElRes                               = ElGrid;
% replace NaNs in Target Grids with actual locations
for i                               = 1:nEl
    sel                             = Tar(:,2) == uEl(i);
    Az                              = Tar(sel,1);
    lAz                             = length(Az);
    El                              = uEl(i)*ones(size(Az));
    indx                            = floor((mlAz+1)/2-(lAz-1)/2):((mlAz+1)/2+(lAz-1)/2);
    AzGrid(indx,i)                  = Az;
    ElGrid(indx,i)                  = El;
end
% replace NaNs in Response Grids with actual locations
for i                               = 1:size(AzGrid,1)
    for j                           = 1:size(AzGrid,2)
        if ~isnan(AzGrid(i,j))
            sel                         = Tar(:,1) == AzGrid(i,j) & Tar(:,2) == ElGrid(i,j) ;
            AzRes(i,j)                  = Res(sel,1);
            ElRes(i,j)                  = Res(sel,2);
        end
    end
end
handles.AzRes                       = AzRes;
handles.ElRes                       = ElRes;
handles.AzGrid                      = AzGrid;
handles.ElGrid                      = ElGrid;

uAz                                 = unique(AzGrid); uAz = uAz(~isnan(uAz));
str                                 = num2str(uAz);
set(handles.popupmenu_azimuth,'String',str);
set(handles.popupmenu_azimuth,'Value',round(length(uAz)/2));
uEl     = unique(ElGrid); uEl = uEl(~isnan(uEl));
str     = num2str(uEl);
set(handles.popupmenu_elevation,'String',str);
set(handles.popupmenu_elevation,'Value',round(length(uEl)/2));


%% Plot graphics
function handles                    = plotXYZvsAZEL(handles)

C                                   = handles.Fix;
FixAz                               = handles.H(C);
FixEl                               = handles.V(C);
TarAz                               = handles.TarAz(C);
TarEl                               = handles.TarEl(C);
curaz           = handles.azimuthspoke;
curel           = handles.elevationspoke;

%% XY AXES
axes(handles.axes_xy);
cla; hold on;
Inipar(1)                              = -90;
Inipar(2)                              = 1/((max(FixEl)-min(FixEl))/2);
Inipar(3)                              = mean(FixEl);
Inipar(4)                              = 0;
Vpar                                   = fitasin(FixEl,TarEl,Inipar);
CalV                                   = asinfun(FixEl,Vpar);
CalV                                   = CalV(:);

Inipar(1)                               = -90;
Inipar(2)                               = 1/((max(FixAz)-min(FixAz))/2);
Inipar(3)                               = mean(FixAz);
Inipar(4)                               = 0;
Hpar                                    = fitasin(FixAz,TarAz,Inipar);
CalH                                    = asinfun(FixAz,Hpar);
CalH                                    = CalH(:);

% Plot AZEL boundaries
h                                         = plot([-90 0],[0 90],...
    [0 90],[90 0],...
    [90 0],[0 -90],...
    [0 -90],[-90 0]);set(h,'LineWidth',2,'Color','k')
hold on
h                                          = plot([0 0],[-90 90],'k');set(h,'LineWidth',2,'Color',[0.7 0.7 0.7])
h                                          = plot([-90 90],[0 0],'k');set(h,'LineWidth',2,'Color',[0.7 0.7 0.7])
% Plot Target
if ~handles.sky
    h=plot(handles.AzGrid,handles.ElGrid,'ko-');set(h,'MarkerFaceColor','w','Color',[0.7 0.7 0.7],'MarkerEdgeColor',[0.7 0.7 0.7]);
    h=plot(handles.AzGrid',handles.ElGrid','ko-');set(h,'MarkerFaceColor','w','Color',[0.7 0.7 0.7],'MarkerEdgeColor',[0.7 0.7 0.7]);
else
    plotrose;
end
h = verline(handles.azimuthspoke,'r-');set(h,'LineWidth',2);
h = horline(handles.elevationspoke,'b-');set(h,'LineWidth',2);

h                                          = plot(TarAz,TarEl,'ko');set(h,'MarkerFaceColor','w');
plot(CalH,CalV,'k*');
box on; axis square;
xlabel('Azimuth (deg)');
ylabel('Elevation (deg)');
Az = [CalH TarAz]';
El = [CalV TarEl]';
plot(Az,El,'k-');
if handles.sky
    axis([-40 40 -40 40]);
else
    axis([-90 90 -90 90])
end

axes(handles.axes_theta);
cla; hold on;
sel             = handles.TarEl < curel+1 & handles.TarEl > curel-1;
PlotSortedAz    = sortrows([handles.TarAz(sel),handles.H(:,sel)'*1618,handles.F(:,sel)'*1618],[1 2 3]);
h               = plot(PlotSortedAz(:,1),PlotSortedAz(:,2),'bo-');  set(h,'MarkerFaceColor','w');
h               = plot(PlotSortedAz(:,1),PlotSortedAz(:,3),'md-');  set(h,'MarkerFaceColor','w');
sel             = (handles.TarEl < curel+1 & handles.TarEl > curel-1) & (handles.TarAz < curaz+1 & handles.TarAz > curaz-1);
if any(sel)
    CurAz = [handles.TarAz(sel) handles.H(:,sel)*1618 handles.F(:,sel)*1618];
    h = plot(CurAz(1),CurAz(2),'bo');  set(h,'MarkerFaceColor','b');
    verline(CurAz(1),'b-');
    h = plot(CurAz(1),CurAz(3),'md');  set(h,'MarkerFaceColor','m');
    h = plot(CurAz(1),CurAz(2),'bo');  set(h,'MarkerFaceColor','b');
end
xlabel('\alpha_T (deg)');
ylabel('H and F Field (V)');
box on;
xlim([-90 90]);

axes(handles.axes_phi);
cla; hold on;
sel             = handles.TarAz < curaz+1 & handles.TarAz > curaz-1;
PlotSortedEl = sortrows([handles.TarEl(sel),handles.V(:,sel)'*1618,handles.F(:,sel)'*1618],[1 2 3]);
h               = plot(PlotSortedEl(:,1),PlotSortedEl(:,2),'ro-');  set(h,'MarkerFaceColor','w');
h               = plot(PlotSortedEl(:,1),PlotSortedEl(:,3),'md-');  set(h,'MarkerFaceColor','w');
sel             = (handles.TarEl < curel+1 & handles.TarEl > curel-1) & (handles.TarAz < curaz+1 & handles.TarAz > curaz-1);
if any(sel)
    CurEl = [handles.TarEl(sel) handles.V(:,sel)*1618 handles.F(:,sel)*1618];
    h = plot(CurEl(1),CurEl(2),'ro');  set(h,'MarkerFaceColor','r');
    verline(CurEl(1),'r-');
    h = plot(CurEl(1),CurEl(3),'md');  set(h,'MarkerFaceColor','m');
    h = plot(CurEl(1),CurEl(2),'ro');  set(h,'MarkerFaceColor','r');
end
xlabel('\epsilon_T (deg)');
ylabel('V and F Field (V)');
set(gca,'YAxisLocation','right');
box on;
xlim([-90 90]);

axes(handles.axes_trace);
cla;
hold on;
box on;
sel             = handles.TarAz < curaz+1 & handles.TarAz > curaz-1 & handles.TarEl < curel+1 & handles.TarEl > curel-1;
if any(sel)
    plot(handles.hortrace(:,sel)*1618,'b-');
    plot(handles.vertrace(:,sel)*1618,'r-');
    plot(handles.fronttrace(:,sel)*1618,'m-');
    legend('H','V','F');
end
xlabel('Time');
ylabel('Voltage (V)');
set(gca,'XTick',0:200:800);
ylim([-10 10]);

%% NETWORK GRAPHICS
function handles    = plottrain(handles)
FixC                = handles.Fix;
ADpre               = [handles.H;handles.V;handles.F];

if exist('mapminmax','file')
    AD              = mapminmax('apply',ADpre,handles.hpsp);
    H               = sim(handles.hnet,AD);
    V               = sim(handles.vnet,AD);
    H               = mapminmax('reverse',H,handles.hpst);
    V               = mapminmax('reverse',V,handles.vpst);
    H               = H';
    V               = V';
    mfixa           = mean(H-handles.TarAz);
    stfa            = std(H-handles.TarAz);
    mfixe           = mean(V-handles.TarEl);
    stfe            = std(V-handles.TarEl);
elseif exist('premnmx','file')
    % Using obsolete Matlab 5 functions PREMNMX, TRAMNMX, POSTMNMX
    hscales         = [handles.hpsp.xmin(1) handles.hpsp.xmax(1) ];
    vscales         = [handles.hpsp.xmin(2) handles.hpsp.xmax(2) ];
    zscales         = [handles.hpsp.xmin(3) handles.hpsp.xmax(3) ];
    thscales        = [handles.hpst.xmin handles.hpst.xmax];
    tvscales        = [handles.vpst.xmin handles.vpst.xmax];
    ADh             = ADpre(1,:);
    ADv             = ADpre(2,:);
    ADz             = ADpre(3,:);
    ADh             = tramnmx(ADh,hscales(1),hscales(2));
    ADv             = tramnmx(ADv,vscales(1),vscales(2));
    ADz             = tramnmx(ADz,zscales(1),zscales(2));
    AD              = [ADh;ADv;ADz];
    % simulate
    H               = sim(handles.hnet,AD);
    V               = sim(handles.vnet,AD);
    % scale output
    H               = postmnmx(H,thscales(1),thscales(2))';
    V               = postmnmx(V,tvscales(1),tvscales(2))';
    mfixa           = mean(H-handles.TarAz);
    stfa            = std(H-handles.TarAz);
    mfixe           = mean(V-handles.TarEl);
    stfe            = std(V-handles.TarEl);
end

axes(handles.axes_net);
cla;
plot(handles.TarAz,H-handles.TarAz,'b.');
hold on;
plot(handles.TarEl,V-handles.TarEl,'r.');
lsline; axis square; horline(0,'k:');
xlabel('Input (deg)','FontSize',12); ylabel('Error (deg)','FontSize',12);
str = strvcat(sprintf('Mean \\alpha %0.2f +/- %0.2f',mfixa,stfa),sprintf('Mean \\epsilon %0.2f +/- %0.2f',mfixe,stfe));
title(str);
axis([-90 90 min([H-handles.TarAz;V-handles.TarEl]) max([H-handles.TarAz;V-handles.TarEl])]);

%% NET2
if exist('mapminmax','file');
    v       = AD(2,:);
    f       = AD(3,:);
    h       = AD(1,:);
    X       = linspace(-1,1,100);
    Y       = linspace(-1,1,100);
    [XI,YI] = meshgrid(X,Y);
    ZI      = griddata(h,v,f,XI,YI,'cubic'); % Z is interpolated from H and V
    % Simulate network
    [m,n]     = size(XI);
    H           = zeros(size(XI));
    V           = zeros(size(YI));
    for i       = 1:m
        H(i,:)  = sim(handles.hnet,[XI(i,:)' YI(i,:)' ZI(i,:)']');
        V(i,:)  = sim(handles.vnet,[XI(i,:)' YI(i,:)' ZI(i,:)']');
        H(i,:)  = mapminmax('reverse',H(i,:),handles.hpst);
        V(i,:)  = mapminmax('reverse',V(i,:),handles.vpst);
    end;
    % Conversion to AD numbers
    ADpost    = [XI(:)';YI(:)';ZI(:)'];
    ADpost    = mapminmax('reverse',ADpost,handles.hpsp);
    adh         = ADpost(1,:);
    adh         = reshape(adh,m,n);
    adv         = ADpost(2,:);
    adv         = reshape(adv,m,n);
    if handles.sky
        % Next values should be changed according to your own set-up
        c           = -40:1:40;
        ctheta      = [-40 -30:10:30 40];
        cphi        = -55+([4:4:29 29]-1)*5;
    else
        c           = -90:3:90;
        ctheta      = [-90 -80:20:80 90];
        cphi        = -55+([4:4:29 29]-1)*5;
    end
elseif exist('premnmx','file')
    v       = AD(2,:);
    f       = AD(3,:);
    h       = AD(1,:);
    X       = linspace(-1,1,100);
    Y       = linspace(-1,1,100);
    [XI,YI] = meshgrid(X,Y);
    ZI      = griddata(h,v,f,XI,YI,'cubic'); % Z is interpolated from H and V
    % Simulate network
    [m,n]     = size(XI);
    H           = zeros(size(XI));
    V           = zeros(size(YI));
    for i       = 1:m
        H(i,:)  = sim(handles.hnet,[XI(i,:)' YI(i,:)' ZI(i,:)']');
        V(i,:)  = sim(handles.vnet,[XI(i,:)' YI(i,:)' ZI(i,:)']');

        H(i,:)  = postmnmx(H(i,:),handles.hpst.xmin,handles.hpst.xmax);
        V(i,:)  = postmnmx(V(i,:),handles.vpst.xmin,handles.vpst.xmax);
    end;
    % Conversion to AD numbers
    ADpost    = [XI(:)';YI(:)';ZI(:)'];
    adh         = postmnmx(ADpost(1,:),handles.hpsp.xmin(1),handles.hpsp.xmax(1));
    adh         = reshape(adh,m,n);
    adv         = postmnmx(ADpost(2,:),handles.hpsp.xmin(2),handles.hpsp.xmax(2));
    adv         = reshape(adv,m,n);
    % Next values should be changed according to your own set-up
    c           = -90:3:90;
    ctheta      = -90:10:90;
    cphi        = -55+([1:4:29 29]-1)*5;
end

axes(handles.axes_net2);
cla;
% General iso-azimuth and iso-elevation contour-lines
contour(adh,adv,H,c);
hold on;
contour(adh,adv,V,c);
if handles.sky
    [c3,h3]     = contour (adh,adv,H,[0 0],'r-'); set(h3,'LineWidth',2);
    [c4,h4]     = contour (adh,adv,V,[0 0],'r-'); set(h4,'LineWidth',2);
else
    [c2,h2]     = contour (adh,adv,V,cphi,'b-'); set(h2,'LineWidth',2);
    [c2,h2]     = contour (adh,adv,H,ctheta,'b-'); set(h2,'LineWidth',2);
    [c2,h2]     = contour (adh,adv,V,[-90 -90],'b-'); set(h2,'LineWidth',4);
    [c2,h2]     = contour (adh,adv,V,[90 90],'b-'); set(h2,'LineWidth',4);
    [c2,h2]     = contour (adh,adv,H,[-90 -90],'b-'); set(h2,'LineWidth',4);
    [c2,h2]     = contour (adh,adv,H,[90 90],'b-'); set(h2,'LineWidth',4);
    [c3,h3]     = contour (adh,adv,H,[0 0],'r-'); set(h3,'LineWidth',2);
    [c4,h4]     = contour (adh,adv,V,[0 0],'r-'); set(h4,'LineWidth',2);
end
plot(handles.H(FixC),handles.V(FixC),'k.','MarkerSize', 15);
xlabel ('X');
ylabel ('Y');
axis square;

%% NET3
if exist('mapminmax','file')
    AD          = mapminmax('apply',ADpre,handles.hpsp);
    H           = sim(handles.hnet,AD);
    V           = sim(handles.vnet,AD);
    H           = mapminmax('reverse',H,handles.hpst);
    V           = mapminmax('reverse',V,handles.vpst);
    H           = H';
    V           = V';
elseif exist('premnmx','file')
    % Using obsolete Matlab 5 functions PREMNMX, TRAMNMX, POSTMNMX
    hscales = [handles.hpsp.xmin(1) handles.hpsp.xmax(1) ];
    vscales = [handles.hpsp.xmin(2) handles.hpsp.xmax(2) ];
    zscales = [handles.hpsp.xmin(3) handles.hpsp.xmax(3) ];
    thscales  = [handles.hpst.xmin handles.hpst.xmax];
    tvscales  = [handles.vpst.xmin handles.vpst.xmax];
    ADh = ADpre(1,:);
    ADv = ADpre(2,:);
    ADz = ADpre(3,:);
    ADh   = tramnmx(ADh,hscales(1),hscales(2));
    ADv   = tramnmx(ADv,vscales(1),vscales(2));
    ADz   = tramnmx(ADz,zscales(1),zscales(2));
    AD = [ADh;ADv;ADz];
    % simulate
    H = sim(handles.hnet,AD);
    V = sim(handles.vnet,AD);
    % scale output
    H = postmnmx(H,thscales(1),thscales(2))';
    V = postmnmx(V,tvscales(1),tvscales(2))';
end

axes(handles.axes_net3);
cla;
h           = plot([-90 0],[0 90],...
    [0 90],[90 0],...
    [90 0],[0 -90],...
    [0 -90],[-90 0]);set(h,'LineWidth',2,'Color','k')
hold on

% Plot Target
if ~handles.sky
    h=plot(handles.AzGrid,handles.ElGrid,'ko-');set(h,'MarkerFaceColor','w','Color',[0.7 0.7 0.7],'MarkerEdgeColor',[0.7 0.7 0.7]);
    h=plot(handles.AzGrid',handles.ElGrid','ko-');set(h,'MarkerFaceColor','w','Color',[0.7 0.7 0.7],'MarkerEdgeColor',[0.7 0.7 0.7]);
end
h           = plot([0 0],[-90 90],'k');set(h,'LineWidth',2)
plotrose;
h           = plot(handles.TarAz,handles.TarEl,'ko');set(h,'MarkerFaceColor','w');
plot(H,V,'k*');
Az          = [H handles.TarAz]';
El          = [V handles.TarEl]';
plot(Az,El,'k-');

box on; axis square;
if handles.sky
    axis([-35 35 -35 35]);
else
   axis([-90 90 -90 90]);
end
xlabel('Azimuth (deg)');
ylabel('Elevation (deg)');
set(gca,'YaxisLocation','right');


%% Train Calibration Network
function handles                = trainnet(handles)
handles                         = fithor(handles);
handles                         = fitver(handles);

%% TRAIN horizontal NETWORK
function handles            = fithor(handles)
% Input and target vectors
FixC                             = handles.Fix;
p(1,:)                           = handles.H(FixC);        % First row = horizontal response
p(2,:)                           = handles.V(FixC);        % Second row = vertical response
p(3,:)                           = handles.F(FixC);        % Second row = vertical response
t                                = handles.TarAz(FixC)';    % Horizontal target position

% Scale measurements between -1 and 1
if exist('mapminmax','file')
    %  By using Matlab 7 function MAPMINMAX
    [pn,PSp]                 = mapminmax(p);
    [tn,PST]                 = mapminmax(t);
elseif exist('premnmx','file')
    % by using obsolete MATLAB 5 function PREMNMX
    [pn,minp,maxp,tn,mint,maxt] = premnmx(p,t);
    PSp.name                 = 'mapminmax';
    PSp.xrows                = size(p,1);
    PSp.yrows                = size(p,1);
    PSp.xmax                 = maxp;
    PSp.xmin                 = minp;
    PSp.ymax                 = 1;
    PSp.ymin                 = -1;

    PST.name = 'mapminmax';
    PST.xrows = size(t,1);
    PST.yrows = size(t,1);
    PST.xmax = maxt;
    PST.xmin = mint;
    PST.ymax = 1;
    PST.ymin = -1;
end

% Initialize feedforward-network
% Default learning procedure for ff-networks is LM with BR
% this can be changed in handles.netalgorithm
net                         = newff(minmax(pn),[handles.NhiddenHor,1],{'tansig','purelin'},handles.netalgorithm);
net                         = init(net);

% Train network with (default) parameters
net.trainParam.epochs       = 500;
net.trainParam.goal         = 0.00001;
net.trainParam.min_grad     = 0.00001;
net.trainParam.show         = 50;

net                         = train(net,pn,tn);
handles.hnet                = net;
handles.hpsp                = PSp;
handles.hpst                = PST;

%% TRAIN vertical NETWORK
function handles            = fitver(handles)
% Input and target vectors
FixC                        = handles.Fix;
p(1,:)                      = handles.H(FixC);        % First row = horizontal response
p(2,:)                      = handles.V(FixC);        % Second row = vertical response
p(3,:)                       = handles.F(FixC);        % Second row = vertical response
t                            = handles.TarEl(FixC)';    % Horizontal target position

% Scale measurements between -1 and 1
if exist('mapminmax','file')
    %  By using Matlab 7 function MAPMINMAX
    [pn,PSp]                = mapminmax(p);
    [tn,PST]                = mapminmax(t);
elseif exist('premnmx','file')
    % by using obsolete MATLAB 5 function PREMNMX
    [pn,minp,maxp,tn,mint,maxt] = premnmx(p,t);
    PSp.name                 = 'mapminmax';
    PSp.xrows                = size(p,1);
    PSp.yrows                = size(p,1);
    PSp.xmax                 = maxp;
    PSp.xmin                  = minp;
    PSp.ymax                 = 1;
    PSp.ymin                  = -1;

    PST.name = 'mapminmax';
    PST.xrows = size(t,1);
    PST.yrows = size(t,1);
    PST.xmax = maxt;
    PST.xmin = mint;
    PST.ymax = 1;
    PST.ymin = -1;
end

% Initialize feedforward-network
net                         = newff(minmax(pn),[handles.NhiddenVer,1],{'tansig','purelin'},handles.netalgorithm);
net                         = init(net);

% Train network with (default) Levenberg-Maquard method
net.trainParam.epochs       = 500;
net.trainParam.goal         = 0.0001;
net.trainParam.min_grad     = 0.0001;
net.trainParam.show         = 50;


net                         = train(net,pn,tn); % Default learning procedure for ff-networks is LM
handles.vnet                = net;
handles.vpsp                = PSp;
handles.vpst                = PST;



%% --- Outputs from this function are returned to the command line.
function varargout = traincal_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_train.
function btn_train_Callback(hObject, eventdata, handles)
% hObject    handle to btn_train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes_net);cla;
axes(handles.axes_net2);cla;
axes(handles.axes_net3);cla;
handles = trainnet(handles);
plottrain(handles);



function edit_nhidden_hor_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nhidden_hor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nhidden_hor as text
%        str2double(get(hObject,'String')) returns contents of edit_nhidden_hor as a double
handles.NhiddenHor = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_nhidden_hor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nhidden_hor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nhidden_ver_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nhidden_ver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nhidden_ver as text
%        str2double(get(hObject,'String')) returns contents of edit_nhidden_ver as a double
handles.NhiddenVer = str2double(get(hObject,'String'));

% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_nhidden_ver_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nhidden_ver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu_algorithm.
function popupmenu_algorithm_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_algorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_algorithm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_algorithm
index_algorithm                      = get(handles.popupmenu_algorithm,'Value');
switch index_algorithm
    case 1
        handles.netalgorithm         = 'trainlm';
    case 2
        handles.netalgorithm         = 'trainbr';
end

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_algorithm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_algorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in btn_savenet.
function btn_savenet_Callback(hObject, eventdata, handles)
% hObject    handle to btn_savenet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hnet        = handles.hnet; %#ok<NASGU>
vnet        = handles.vnet; %#ok<NASGU>
ad_map      = handles.hpsp; %#ok<NASGU>
hortar_map     = handles.hpst; %#ok<NASGU>
vertar_map     = handles.vpst; %#ok<NASGU>
netfname    = handles.netfname;
save(netfname,'hnet','vnet','ad_map','vertar_map','hortar_map');

function edit_netfname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_netfname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_netfname as text
%        str2double(get(hObject,'String')) returns contents of edit_netfname as a double

handles.netfname = get(hObject,'String');
handles.netfname = fcheckext(handles.netfname,'.net');
set(handles.edit_netfname,'String',handles.netfname);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_netfname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_netfname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_browse.
function btn_browse_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function edit_nspeaker_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nspeaker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nspeaker as text
%        str2double(get(hObject,'String')) returns contents of edit_nspeaker as a double
handles.nspeaker = str2double(get(hObject,'String'));
handles.speakernr                  = repmat(1:handles.nspeaker:29,7,1);
for i = 1:7
    handles.speakernr(i,:)                  = handles.speakernr(i,:)+29*(i-1);
end
handles.speakernr = handles.speakernr(:);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_nspeaker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nspeaker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_savefix.
function btn_savefix_Callback(hObject, eventdata, handles)
% hObject    handle to btn_savefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function traincal_KeyPressFcn(hObject, eventdata, handles)
h       = get(handles.figure1);
a       = h.CurrentCharacter;

function traincal_BtnDownFcn(hObject, eventdata, handles)
h       = get(handles.axes_xy);
ax      = axis;
pnt     = h.CurrentPoint;
pnt     = pnt(1,[1 2]);
if pnt(1)< ax(2) && pnt(1) > ax(1) && pnt(2)< ax(4) && pnt(2) > ax(3)
    axes(handles.axes_xy)
    plot(pnt(1),pnt(2),'ro');
    [mndist,indx]       = min(hypot(handles.TarAz-pnt(1),handles.TarEl-pnt(2)));

    handles.FixRem      = [handles.FixRem;indx];
    handles.FixRem      = unique(handles.FixRem);
    indx                = 1:length(handles.H);
    handles.Fix         = setxor(indx,handles.FixRem);
    plotXYZvsAZEL(handles);
end


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btn_zoom.
function btn_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to btn_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes_xy);
if ~handles.zoom
    set(handles.btn_zoom,'String','Zoom off');
    zoom on;
    handles.zoom = true;
elseif handles.zoom
    set(handles.btn_zoom,'String','Zoom on');
    zoom off;
    handles.zoom = false;
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in popupmenu_azimuth.
function popupmenu_azimuth_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_azimuth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_azimuth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_azimuth
val             = get(handles.popupmenu_azimuth,'Value');
string_list     = get(handles.popupmenu_azimuth,'String');
selected_string = string_list(val,:);
handles.azimuthspoke = str2double(selected_string);
handles = plotXYZvsAZEL(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_azimuth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_azimuth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_elevation.
function popupmenu_elevation_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_elevation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_elevation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_elevation

val             = get(handles.popupmenu_elevation,'Value');
string_list     = get(handles.popupmenu_elevation,'String');
selected_string = string_list(val,:);
handles.elevationspoke = str2double(selected_string);
handles = plotXYZvsAZEL(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_elevation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_elevation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function plotrose
% PLOTROSE
%
% Draws visual target rose for Tommy-lab
%
% See also PLOTROSE2, PLOTROSE3
%
%   Marc van Wanrooij

% plot spaken 
for i=1:12,
  phi  = i*30;
  x(1) = 0;
  y(1) = 0;
  x(2) = 35*cos(phi*pi/180);
  y(2) = 35*sin(phi*pi/180);
  h=plot(x,y,'k-');set(h,'Color',[0.7 0.7 0.7]);
  if i==3 || i==6 ||i==9 || i==12
      plot(x,y,'r-','LineWidth',2)
  end
end;

% plot ringen 
phi = 0:360;
x   = cos(phi*pi/180);
y   = sin(phi*pi/180);
h=plot( 5*x, 5*y,'k-');set(h,'Color',[0.7 0.7 0.7]);
h=plot( 9.0554*x, 9.0554*y,'k-');set(h,'Color',[0.7 0.7 0.7]);
h=plot(14.0362*x,14.0362*y,'k-');set(h,'Color',[0.7 0.7 0.7]);
h=plot(19.9889*x,19.9889*y,'k-');set(h,'Color',[0.7 0.7 0.7]);
h=plot(26.9932*x,26.9932*y,'k-');set(h,'Color',[0.7 0.7 0.7]);
plot(34.9920*x,34.9920*y,'k-','LineWidth',2);

axis square
box on
