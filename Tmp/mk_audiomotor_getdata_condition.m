function [R,V,ND] = mk_audiomotor_getdata_condition(subject,ear,hand)
% Input:    filename of ripplegram experiment
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

if nargin<3
	hand = 'left';
end
if nargin<2
	ear = 'left';
end
if nargin<1
	subject = 111;
end

dname = ['RunCompleted_sub' num2str(subject) '_' ear 'ear_' hand 'hand*.mat'];
pa_datadir;
cd('Ripple');

fnames = dir(dname);
nfiles = length(fnames)

F = struct([]);
for ii= 1:nfiles
	load(fnames(ii).name)
	F(ii).velocity	= [Q.velocity];
	react = [Q.reactiontime];
% 	if any(react>3100)
% 		react = react/2;
% 	end
	F(ii).react		= (react/1017) * 1000;
	
	F(ii).durstat	= [Q.staticduration];
	F(ii).md		= [Q.modulationdepth];
	F(ii).lat		= F(ii).react - F(ii).durstat;
end

velocity	= [F(1:nfiles).velocity];
durstat     = [F(1:nfiles).durstat];
lat			= [F(1:nfiles).lat];
md			= [F(1:nfiles).md];

uvel		= unique(velocity);
nvel		= numel(uvel);
udepth      = unique(md);
ndepth      = numel(udepth);

% Durstat effect
udur = unique(durstat);
ndur = numel(udur);
rt   = NaN(1,ndur);

for ii = 1:ndur
		sel = durstat == udur(ii);
        rt(1,ii) = nanmean(lat(sel));
end

R.dur = udur;
R.rt  = rt;

%% Number of trials per ripple

sel			= lat>0;
lat			= lat(sel);
velocity	= velocity(sel);
md			= md(sel);

N = NaN(ndepth,nvel);
for ii = 1:ndepth
    for jj = 1:nvel
        sel			= md == udepth(ii) & velocity == uvel(jj);
        N(ii,jj) = sum(sel);
    end
end

ND.ntr = N;

%% Selection reaction time
sel			= lat>0 & lat<2900;
l           = lat(sel);
p           = prctile(l,[2.5 97.5]);
sel         = lat>p(1) & lat<p(2);
lat         = lat(sel);
velocity	= velocity(sel);
md			= md(sel);

sel         = md == 50;
lat50       = lat(sel);
sel         = md == 100;
lat100      = lat(sel);

%% Raw data
% md 50
R.x50       = 1:numel(lat50);
R.rt50      = lat50;
V.smu50     = nanmean(lat50);
V.sse50     = std(lat50)./sqrt(numel(lat50));

% md 100
R.x100      = 1:numel(lat100);
R.rt100     = lat100;
V.smu100    = nanmean(lat100);
V.sse100    = std(lat100)./sqrt(numel(lat100));

%% Reaction time per velocity & Not detected per velocity
V.v     = uvel;
ND.v    = uvel;

RT      = NaN(ndepth, nvel);
NotDet  = NaN(ndepth,nvel);
ciRT    = RT;
for ii = 1:ndepth
    for jj = 1:nvel
		sel			= md == udepth(ii) & velocity == uvel(jj);
		RT(ii,jj)   = nanmean(lat(sel));
        ciRT(ii,jj)	= nanstd(lat(sel))./sqrt(sum(sel));
        if (uvel(jj) == 0)
            RT(ii,jj) = NaN;
            ciRT(ii,jj) = NaN;
        end
        NotDet(ii,jj) = N(ii,jj)-sum(sel);
    end
end

V.mu        = RT;
V.se        = ciRT;
ND.ndt      = NotDet;
ND.tot50    = nansum(NotDet(1,:));
ND.tot100   = nansum(NotDet(2,:));

