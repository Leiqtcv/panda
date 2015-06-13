function [R, ND] = mk_getextra_sub(subname)
%Enter subject of lateralization ripple test
%Returns structues R (rr = Right ear, Right hand, rl = Right ear,
%left hand, ll = Left ear, Left hand, lr = Left ear, Right hand)

%nested structure R.rr etc (x = number of trial, rt = reaction time, ndt = not detected total)
%nested structure ND.rr etc(v = unique velocity, d = unique density, 
%ndt = not detected ripples)

if nargin<1
	subname = 'sub1';
end
cd('E:\DATA\Studenten\Maarten');

%% Get data for each protocol
d = dir([subname '_right_right*.mat']);
fnames = {d.name};
[Vrr, NDrr] = mk_getextra_protocol(fnames);

d = dir([subname '_left_left*.mat']);
fnames = {d.name};
[Vll, NDll] = mk_getextra_protocol(fnames);

d = dir([subname '_left_right*.mat']);
fnames = {d.name};
[Vlr, NDlr] = mk_getextra_protocol(fnames);

d = dir([subname '_right_left_*.mat']);
fnames = {d.name};
[Vrl, NDrl] = mk_getextra_protocol(fnames);

R.sub = subname;
R.rr = [Vrr];
R.ll = [Vll];
R.lr = [Vlr];
R.rl = [Vrl];

ND.sub = subname;
ND.rr = [NDrr];
ND.ll = [NDll];
ND.lr = [NDlr];
ND.rl = [NDrl];

end

function [R, ND] = mk_getextra_protocol(fnames)
%Enter filenames of lateralization ripple test
%Returns structure V (x = unique velocity, mu = mean rt, ci = stderror)
%        structure D (x = density, mu = mean rt, ci = stderror)
%        structure VD (v = unique velocity, d= unique density, mu = mean rt, ci = stderror)

nfiles = numel(fnames); %datafiles per user per protocol
P = struct([]);

%load data & place together in structure
for ii = 1:nfiles
	fname = fnames{ii};
	load(fname);
	P(ii).lat		= [Q.lat];
	P(ii).velocity	= [Q.velocity];
	P(ii).density	= [Q.density];
end

%% Selection total not detected ripples
lat			= [P.lat]*1000; % ms
sel			= lat>2900 & lat<3100;
R.ndt	= numel(lat(sel));

%% Selection reaction time without not detected ripples
lat			= [P.lat]*1000; % ms
sel			= lat>100 & lat<1000;
R.rt		= lat(sel);
R.x = 1:numel(lat(sel));

%% Selection not detected per ripple
velocity	= [P.velocity];
density		= [P.density];
lat			= [P.lat]*1000;
sel1		= ~sel;

uvel			= unique(velocity);
nvel			= numel(uvel);
udens			= unique(density);
ndens			= numel(udens);

NotDet = NaN(nvel,ndens);
for ii = 1:nvel
	for jj = 1:ndens
		sel2			= velocity == uvel(ii) & density == udens(jj); %select ripple vel dens combination
        NotDet(ii,jj) = sum(sel1(sel2));
    end
end

ND.v = uvel;
ND.d = udens;
ND.ndt = NotDet;

end


