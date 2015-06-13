function [AZ,EL] = calib(AD1,AD2,AD3,S)
% Calibrate raw HVF-data traces contained in one matrix
%
% [AZ EL] = CALIB(AD,S)
%
% Calibrate the 3 raw data traces in AD (horizontal H, vertical V, frontal F). 
% S is either the NET file containing the neural network structure or the
% structure itself.
%
% Optionally, you can supply the various traces separately:
% [AZ EL] = CALIB(H,V,F,S)
%
%   See also CALIBRATE
%
% Author: MW

%% Initialization
if nargin<3
    S           = AD2;
    AD          = AD1;
    [M,N]       = size(AD);
    M           = 1;
else
    [M,N]       = size(AD1);
    AD          = [AD1(:) AD2(:) AD3(:)]';
end
if ischar(S)
    S           = fcheckexist(S,'.net');
    S           = load(S,'-mat');
end


%% NETWORK
if exist('mapminmax','file')
    % Using Matlab 7 function MAPMINMAX
    % Apply processor settings to AD-values
    AD          = mapminmax('apply',AD,S.ad_map);
    % Simulate network with AD-inputs
    H           = sim(S.hnet,AD);
    V           = sim(S.vnet,AD);
    % And reverse engineer normalized units to deg
    AZ          = mapminmax('reverse',H,S.hortar_map);
    EL          = mapminmax('reverse',V,S.vertar_map);
elseif exist('premnmx','file')
    % Using obsolete Matlab 5 functions PREMNMX, TRAMNMX, POSTMNMX
    hscales     = [S.ad_map.xmin(1) S.ad_map.xmax(1) ];
    vscales     = [S.ad_map.xmin(2) S.ad_map.xmax(2) ];
    zscales     = [S.ad_map.xmin(3) S.ad_map.xmax(3) ];
    thscales    = [S.hortar_map.xmin S.hortar_map.xmax];
    tvscales    = [S.vertar_map.xmin S.vertar_map.xmax];
    ADh         = AD(1,:);
    ADv         = AD(2,:);
    ADz         = AD(3,:);
    ADh         = tramnmx(ADh,hscales(1),hscales(2));
    ADv         = tramnmx(ADv,vscales(1),vscales(2));
    ADz         = tramnmx(ADz,zscales(1),zscales(2));
    AD          = [ADh;ADv;ADz];
    % simulate
    H           = sim(S.hnet,AD);
    V           = sim(S.vnet,AD);
    % scale output
    AZ          = postmnmx(H,thscales(1),thscales(2));
    EL          = postmnmx(V,tvscales(1),tvscales(2));
end

%% Reshape back
AZ              = reshape(AZ,M,N);
EL              = reshape(EL,M,N);


