function [V,D,VD] = mk_getrt_sub(subname)
%Enter subject of lateralization ripple test
%Returns structues V,D en VD (rr = Right ear, Right hand, rl = Right ear,
%left hand, ll = Left ear, Left hand, lr = Left ear, Right hand)

%nested structure V.rr etc (x = unique velocity, mu = mean rt, ci = stderror)
%nested structure D.rr etc (x = density, mu = mean rt, ci = stderror)
%nested structure VD.rr etc (v = unique velocity, d= unique density, mu = mean rt, ci = stderror)

if nargin<1
	subname = 'sub1';
end
cd('E:\DATA\Studenten\Maarten');

%% Get data for each protocol
d = dir([subname '_right_right*.mat']);
fnames = {d.name};
[Vrr,Drr,VDrr] = mk_getrt_protocol(fnames);

d = dir([subname '_left_left*.mat']);
fnames = {d.name};
[Vll,Dll,VDll] = mk_getrt_protocol(fnames);

d = dir([subname '_left_right*.mat']);
fnames = {d.name};
[Vlr,Dlr,VDlr] = mk_getrt_protocol(fnames);

d = dir([subname '_right_left_*.mat']);
fnames = {d.name};
[Vrl,Drl,VDrl] = mk_getrt_protocol(fnames);

V.sub = subname;
V.rr = [Vrr];
V.ll = [Vll];
V.lr = [Vlr];
V.rl = [Vrl];
D.sub = subname;
D.rr = [Drr];
D.ll = [Dll];
D.lr = [Dlr];
D.rl = [Drl];
VD.sub = subname;
VD.rr = [VDrr];
VD.ll = [VDll];
VD.lr = [VDlr];
VD.rl = [VDrl];

function [V,D,VD] = mk_getrt_protocol(fnames)
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

velocity	= [P.velocity];
density		= [P.density];
lat			= [P.lat]*1000; % ms

%% Selection reaction time
sel			= lat>100 & lat<1500;
lat			= lat(sel);
velocity	= velocity(sel);
density		= density(sel);

%% Reaction time per ripple
uvel			= unique(velocity);
nvel			= numel(uvel);
udens			= unique(density);
ndens			= numel(udens);

RT = NaN(nvel,ndens);
ciRT = RT;
for ii = 1:nvel
	for jj = 1:ndens
		sel			= velocity == uvel(ii) & density == udens(jj); %select ripple vel dens combination
		RT(ii,jj)	= nanmean(lat(sel)); %mean rt per ripple
		ciRT(ii,jj)	= 1.96*nanstd(lat(sel))./sqrt(sum(sel)); %stdev per ripple
	end
end

%output per ripple
VD.v = uvel;
VD.d = udens;

VD.mu = RT;
VD.ci = ciRT;

%% Reaction time per density
muRT = NaN(ndens,1);
ciRT = muRT;
for jj = 1:ndens
	sel			= density == udens(jj); %select unique density
	muRT(jj)	= nanmean(lat(sel)); %mean per density
	n			= sum(sel);
	ciRT(jj)	= 1.96*nanstd(lat(sel))./sqrt(n); %stderror per density
end

%output per density
D.x = udens;
D.mu = muRT;
D.ci = ciRT;

%% Reaction time per velocity
muRT = NaN(nvel,1);
ciRT = muRT;
for jj = 1:nvel
% 	sel uvel&density==0)
	sel			= abs(velocity) == abs(uvel(jj)) & density<8 ;
	sel2 = uvel(jj)==0 & density==0;
	sel = sel&~sel2;
% 	[uvel(jj) sum(sel)]
	muRT(jj)	= nanmean(lat(sel));
	n			= sum(sel);
	ciRT(jj)	= 1.96*nanstd(lat(sel))./sqrt(n);
end

% make velocity positive
sel = uvel>=0;
uvel = uvel(sel);
muRT = muRT(sel);
ciRT = ciRT(sel);

%output per velocity
V.x = uvel;
V.mu = muRT;
V.ci = ciRT;
