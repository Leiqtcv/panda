function [R,V,D,VD,ND] = mk_lateralization_getdata_condition(fnames)
% Input:    filename of MK_HEMISPHERE_RIPPLEQUEST experiment
% Output:   structure R(x = trial number, rt = reaction time)
%           structure VD(v = unique velocity, d = unique density, 
%                        mu = mean rt, se = stderror, rt = all reaction times,
%                        smu = total mean rt, sse = stderror,)
%           structure D (d = density, mu = mean rt vs dens, se = stderror, 
%                        mu0 = mean rt vs dens vel=0, se0 = stderror, 
%                        mulo = mean rt vs dens vel=2,4,8, selo = stderror, 
%                        muhi = mean rt vs dens vel=16,32,64, sehi = stderror,
%                        smu0 = mean rt vel=0, sse0 = stderror, 
%                        smulo = mean rt vel=2,4,8, sselo = stderror, 
%                        smuhi = mean rt vel=16,32,64, ssehi = stderror)
%           structure V (v = velocity, mu = mean rt vs vel, se = stderror,
%                        mu0 = mean rt vs vel dens=0, se0 = stderror, 
%                        mu1 = mean rt vs vel dens=1, se1 = stderror, 
%                        mu2 = mean rt vs vel dens=2, se2 = stderror,
%                        mu4 = mean rt vs vel dens=4, se4 = stderror,
%                        smu0 = mean rt dens=0, sse0 = stderror, 
%                        smu1 = mean rt dens=1, sse1 = stderror, 
%                        smu2 = mean rt dens=2, sse2 = stderror,
%                        smu4 = mean rt dens=4, sse4 = stderror)
%           structure ND(v = velocity, d = density, ndt = not detected per
%                        ripple, tot = total not detected)

load(fnames);

velocity	= [Q.velocity];
density		= [Q.density];
lat			= [Q.lat]*1000; % ms

uvel		= unique(velocity);
nvel		= numel(uvel);
udens		= unique(density);
ndens		= numel(udens);

sel = lat>0;
lat = lat(sel);
velocity = velocity(sel);
density = density(sel);

N = NaN(nvel,ndens); % matrix total trials per ripple
for ii = 1:nvel
    for jj = 1:ndens
        sel2			= velocity == uvel(ii) & density == udens(ndens + 1 - jj);%select ripple vel dens combination
        N(ii,jj) = sum(sel2);
    end
end

%% Selection reaction time
sel			= lat>0 & lat<2900;
l           = lat(sel);
p           = prctile(l,[2.5 97.5]);
sel         = lat>p(1) & lat<p(2);
lat         = lat(sel);
velocity	= velocity(sel);
density		= density(sel);

%% Raw data
R.x         = 1:numel(lat);
R.rt        = lat;

%% Reaction time per ripple & Not detected per ripple
RT = NaN(nvel,ndens);
NotDet = NaN(nvel,ndens);
ciRT = RT;
vel = RT;
dens = RT;
for ii = 1:nvel
	for jj = 1:ndens
		sel2			= velocity == uvel(ii) & density == udens(ndens + 1 - jj); %select ripple vel dens combination
		RT(ii,jj)	= nanmean(lat(sel2)); %mean rt per ripple
        ciRT(ii,jj)	= nanstd(lat(sel2))./sqrt(sum(sel2)); %sterror per ripple
        if (uvel(ii) == 0 && udens(ndens + 1 - jj) == 0)
            RT(ii,jj) = NaN;
            ciRT(ii,jj) = NaN;
        end
        NotDet(ii,jj) = N(ii,jj)-sum(sel2);
        vel(ii,jj) = uvel(ii);
        dens(ii,jj) = udens(jj);
	end
end

%output per ripple
VD.v    = uvel;
VD.d    = udens;
VD.mu   = RT;
VD.se   = ciRT;

ND.v    = uvel;
ND.d    = udens;
ND.ndt  = NotDet;

%no density 8
sel         = density ~= 8;
sel2        = dens ~= 8;
lat         = lat(sel);
NotDet      = NotDet(sel2)';
velocity	= velocity(sel);
density		= density(sel);

uvel		= unique(velocity);
nvel		= numel(uvel);
udens		= unique(density);
ndens		= numel(udens);

VD.rt = lat;

%% mean rt and not detected all combinations together
VD.smu = nanmean(lat);
VD.sse = std(lat)./sqrt(numel(lat));
ND.tot = nansum(nansum(NotDet)); %#ok<UDIM>

%% Reaction time per density for velocity 0, low(2,4,8), high(16,32,64)
muRT    = NaN(ndens,1);
muRT0   = muRT;
muRTlo  = muRT;
muRThi  = muRT;
ciRT    = muRT;
ciRT0   = muRT;
ciRTlo  = muRT;
ciRThi  = muRT;

for jj = 1:ndens
	sel         = density == udens(jj);
    muRT(jj)       = nanmean(lat(sel));
    n			= sum(sel);
    ciRT(jj)	= nanstd(lat(sel))./sqrt(n);
    sel			= density == udens(jj) & (abs(velocity) == 0); %select unique density
	muRT0(jj)	= nanmean(lat(sel));
	n			= sum(sel);
    ciRT0(jj)	= nanstd(lat(sel))./sqrt(n);
    if udens(jj) == 0
        muRT0(jj) = NaN;
        ciRT0(jj) = NaN;
    end
    sel			= density == udens(jj) & (abs(velocity) == 2 | abs(velocity) == 4 | abs(velocity) == 8); %select unique density
	muRTlo(jj)	= nanmean(lat(sel));
	n			= sum(sel);
	ciRTlo(jj)	= nanstd(lat(sel))./sqrt(n);
    sel			= density == udens(jj) & (abs(velocity) == 16 | abs(velocity) == 32 | abs(velocity) == 64); %select unique density
	muRThi(jj)  = nanmean(lat(sel));
	n			= sum(sel);
	ciRThi(jj)  = nanstd(lat(sel))./sqrt(n);
end

%output mean rt vs density per velocity
D.d = udens;
D.mu = muRT';
D.se = ciRT';
D.mu0 = muRT0';
D.se0 = ciRT0';
D.mulo = muRTlo';
D.selo = ciRTlo';
D.muhi = muRThi';
D.sehi = ciRThi';

%output total mean rt per velocity
sel = (abs(velocity) == 0 & density ~= 0);  %velocity =0
D.smu0 = nanmean(lat(sel));
D.sse0 = nanstd(lat(sel))./sqrt(numel(lat(sel)));

sel = (abs(velocity) == 2 | abs(velocity) == 4 | abs(velocity) == 8 ); %velocity = low
D.smulo = nanmean(lat(sel));
D.sselo = nanstd(lat(sel))./sqrt(numel(lat(sel)));

sel = (abs(velocity) == 16 | abs(velocity) == 32 | abs(velocity) == 64); %velocity = high
D.smuhi = nanmean(lat(sel));
D.ssehi = nanstd(lat(sel))./sqrt(numel(lat(sel)));

% output not detected
% sel1 = vel == 0;
% D.ndt0 = NotDet(sel1);
% 
% sel1 = vel == -2;
% sel2 = vel == 2;
% sel3 = vel == -4;
% sel4 = vel == 4;
% sel5 = vel == -8;
% sel6 = vel == 8;
% D.ndtlo = nanmean([NotDet(sel1);NotDet(sel2);NotDet(sel3);NotDet(sel4);NotDet(sel5);NotDet(sel6)]);
% D.ndtloci = nanstd([NotDet(sel1);NotDet(sel2);NotDet(sel3);NotDet(sel4);NotDet(sel5);NotDet(sel6)])./sqrt(numel([NotDet(sel1);NotDet(sel2);NotDet(sel3);NotDet(sel4);NotDet(sel5);NotDet(sel6)]));
% sel1 = vel == -16;
% sel2 = vel == 16;
% sel3 = vel == -32;
% sel4 = vel == 32;
% sel5 = vel == -64;
% sel6 = vel == 64;
% D.ndthi = nanmean([NotDet(sel1);NotDet(sel2);NotDet(sel3);NotDet(sel4);NotDet(sel5);NotDet(sel6)]);
% D.ndthici = nanstd([NotDet(sel1);NotDet(sel2);NotDet(sel3);NotDet(sel4);NotDet(sel5);NotDet(sel6)])./sqrt(numel([NotDet(sel1);NotDet(sel2);NotDet(sel3);NotDet(sel4);NotDet(sel5);NotDet(sel6)]));

%% Reaction time per velocity for density = 0,1,2,4 
uvel = uvel((round(nvel/2)):end);
nvel = numel(uvel);

muRT    = NaN(nvel,1);
muRT0   = muRT;
muRT1   = muRT;
muRT2   = muRT;
muRT4   = muRT;
ciRT    = muRT;
ciRT0   = muRT;
ciRT1   = muRT;
ciRT2   = muRT;
ciRT4   = muRT;

for jj = 1:nvel
	sel			= abs(velocity) == uvel(jj);
	muRT(jj)	= nanmean(lat(sel));
    n			= sum(sel);
	ciRT(jj)	= nanstd(lat(sel))./sqrt(n);
    sel			= abs(velocity) == uvel(jj) & density == 0;
	muRT0(jj)	= nanmean(lat(sel));
    n			= sum(sel);
	ciRT0(jj)	= nanstd(lat(sel))./sqrt(n);
    if uvel(jj) == 0
        muRT0(jj) = NaN;
        ciRT0(jj) = NaN;
    end
    sel         = abs(velocity) == uvel(jj) & density == 1;
    muRT1(jj)	= nanmean(lat(sel));
	n			= sum(sel);
	ciRT1(jj)	= nanstd(lat(sel))./sqrt(n);
    sel         = abs(velocity) == uvel(jj) & density == 2;
    muRT2(jj)	= nanmean(lat(sel));
	n			= sum(sel);
	ciRT2(jj)	= nanstd(lat(sel))./sqrt(n);
    sel         = abs(velocity) == uvel(jj) & density == 4;
    muRT4(jj)	= nanmean(lat(sel));
	n			= sum(sel);
	ciRT4(jj)	= nanstd(lat(sel))./sqrt(n);
end

%output mean rt vs velocity per density
V.v   = uvel;
V.mu  = muRT';   
V.mu0 = muRT0';
V.mu1 = muRT1';
V.mu2 = muRT2';
V.mu4 = muRT4';
V.se  = ciRT';
V.se0 = ciRT0';
V.se1 = ciRT1';
V.se2 = ciRT2';
V.se4 = ciRT4';

%output total mean rt per density
sel = density == 0 & velocity ~= 0; %total mean rt for density = 0
V.smu0 = nanmean(lat(sel));
V.sse0 = nanstd(lat(sel))./sqrt(numel(lat(sel)));

sel = density == 1; %total mean rt for density = 1
V.smu1 = nanmean(lat(sel));
V.sse1 = nanstd(lat(sel))./sqrt(numel(lat(sel)));

sel = density == 2; %total mean rt for density = 2
V.smu2 = nanmean(lat(sel));
V.sse2 = nanstd(lat(sel))./sqrt(numel(lat(sel)));

sel = density == 4; %total mean rt for density = 4
V.smu4 = nanmean(lat(sel));
V.sse4 = nanstd(lat(sel))./sqrt(numel(lat(sel)));

% output not detected
% sel = dens == 0;
% V.ndt0 = NotDet(sel);
% 
% sel = dens == 1;
% V.ndt1 = NotDet(sel);
% 
% sel = dens == 2;
% V.ndt2 = NotDet(sel);
% 
% sel = dens == 4;
% V.ndt4 = NotDet(sel);

