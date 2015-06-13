function [B,G1,G2,G3] = anovaregression(subnames)
if nargin<1
    subnames = {'sub1' 'sub2' 'sub4' 'sub6' 'sub8' 'sub12' 'sub13' 'sub14'};
end
close all hidden
cd('E:\DATA\Ripple\Maarten')
S       = struct([]);
nSub    = length(subnames);
B = NaN(1,32);
G = NaN(1,32);
G3 = NaN(1,32);

for ii=1:nSub
    subname = subnames{ii};
    S(ii).sub = subname;
    S(ii).vtc = getdatasubject(subname);
end

stat = struct([]);
cond = {'ReRh','ReLh','LeRh','LeLh'};
mf = zeros(6,13);

for ii=1:6
    mf(ii,:) = 2^ii;
end

for ii=1:nSub  
    for jj = 1:4
	
	sel		= strcmpi(cond,cond(jj));
	rt		= squeeze(S(ii).vtc(sel,:,:));
% 	mu		= nanmean(rt,2);
% 	u		= repmat(nanmean(rt),size(rt,1),1);
% 	sd		= 1.96*nanstd(rt-u,[],2)./size(rt,2);
    
    
    T		= 1./mf(:);
    y		= rt(:);
    x		= T(:);

    b = regstats(y(:),x(:),'linear','all');
    B((ii-1)*4+jj) = b.beta(2);
    G((ii-1)*4+jj) = jj; %condition variabele
    G3((ii-1)*4+jj) = ii; %subject variabele
    
    end
end

E = [2 2 1 1];
G1 = repmat(E,1,8);
H = [2 1 2 1];
G2 = repmat(H,1,8);

[p,table,stats,terms] = anovan(B,{G1 G2 G3},'model',[1 0 0;0 1 0;0 0 1;1 1 0],'random',3,'varnames',{'ear';'hand';'subject'});

figure(2)
c1 = multcompare(stats,'dimension',[1 2])

function [vtc] = getdatasubject(subname)

if nargin<1
    subname = 'sub1';
end

vtc = NaN(4,6,13);

d = dir(['SessionCompleted_' subname '_right_right.mat']);
fnames = d.name;
[vtc(1,:,:)] = getdatacondition(fnames);

d = dir(['SessionCompleted_' subname '_right_left.mat']);
fnames = d.name;
[vtc(2,:,:)] = getdatacondition(fnames);

d = dir(['SessionCompleted_' subname '_left_right.mat']);
fnames = d.name;
[vtc(3,:,:)] = getdatacondition(fnames);

d = dir(['SessionCompleted_' subname '_left_left.mat']);
fnames = d.name;
[vtc(4,:,:)] = getdatacondition(fnames);

function [vt] = getdatacondition(fnames)
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

sel			= density == 0;
lat = lat(sel);
velocity	= velocity(sel);

vt = NaN(6,13);

sel = abs(velocity) == 2;
vt(1,1:sum(sel)) = lat(sel);
sel = abs(velocity) == 4;
vt(2,1:sum(sel)) = lat(sel);
sel = abs(velocity) == 8;
vt(3,1:sum(sel)) = lat(sel);
sel = abs(velocity) == 16;
vt(4,1:sum(sel)) = lat(sel);
sel = abs(velocity) == 32;
vt(5,1:sum(sel)) = lat(sel);
sel = abs(velocity) == 64;
vt(6,1:sum(sel)) = lat(sel);
