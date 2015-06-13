function rip_results_figure_conditions_allsubjects

%% Clean
close all
clc

%% Load data
pa_datadir;
cd('Ripple');
subs	= [1 2 4 5 6 8 9 10 13 14 15 16 17 18 19 21];
nsubs	= numel(subs);
D = [];
PT = [];
for ii = 1:nsubs
	sub		= subs(ii);
	% [R,V,ND] = rip_audiomotor_getdata_condition(sub,'left','left');
	F = pooldata(sub,'right','right');
	F = pooldata(sub,'left','left');
	
	col		= gray(5);
	vel		= [F.velocity];
	md		= [F.md];
	period	= 1./vel;
	RT		= [F.lat];
	subplot(131)
	sel		= vel>0 & md==100;
	[mu,uperiod,sd] = timeplot(vel(sel),period(sel),RT(sel));
	
	b		= robustfit(uperiod,mu);
	beta	= b;
	
	RT		= RT-beta(1);
	figure
	[mu,uperiod,sd,d,xi,pt] = phaseplot(vel(sel),period(sel),RT(sel),'k',beta);
	
	D = [D; d];
	PT = [PT pt];
end
% keyboard
figure
subplot(121)
plot(xi,sum(D));
set(gca,'XTick',-5:5);
grid on
axis square;

subplot(122)
stp = 1./std(PT);
[N,x] = hist(PT,-5:.25:5);
N = N./sum(N);
[D,XI]	= ksdensity(PT,-5:.01:5);
D = D./sum(D);
% 	D		= D/max(D);
% 	pa_errorpatch(t,repmat(-ii+nperiod,size(a)),a,'r')
h = bar(x,N,1);set(h,'FaceColor',[.7 .7 .7]);
hold on
plot(XI,D,'k-','LineWidth',2);
axis square
xlim([-4 4]);
pa_verline([-3 -2 -1 0 1 2 3]+beta(2)/1000);
return
b
function [R,V,ND] = rip_audiomotor_getdata_condition(subject,ear,hand)
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
	react			= [Q.reactiontime];
	% 	if any(react>3100)
	% 		react = react/2;
	% 	end
	F(ii).react		= (react);
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



function h = cumplot (Latencies, LatTick, Style)

ILat = sort(-1./Latencies);
h=rplotcdf (ILat, Style);

set(gca, 'ytick', probit ([1 2 5 10:10:90 95 98 99]/100));
set(gca, 'YTickLabel', ...
	[' 1';' 2';' 5'; '10'; '20'; '30'; '40'; '50'; '60'; '70'; '80'; '90';'95';'98';'99']);
LatLabel=int2str(LatTick');

% xrange=[100 200 300 400 600 900];

set(gca, 'xtick', -1./LatTick);
set(gca, 'XTickLabel', LatLabel);

set(gca, 'xlim', sort(-1./[LatTick(1) LatTick(end)]));
set(gca, 'ylim', probit ([1 99]/100));

grid on;

%
% FUNCTION RPLOTCDF (X, STYLE)
%

function h=rplotcdf (X, Style)

if (nargin < 2), Style = 'y.'; end;

if isstruct(X)
	t=fieldnames(X);
	Xa=sort(getfield(X,char(t(1))));
	Xv=sort(getfield(X,char(t(2))));
	
	Cdfv = [1:length(Xv)]'/length(Xv);
	Cdfa = [1:length(Xa)]'/length(Xa);
	
	indexa=1;indexv=1;
	for i=1:(length(Xv)+length(Xa))-1
		if indexa<length(Xa)
			Xaindexa=Xa(indexa);
		else
			Xaindexa=Xv(end)+1;
		end
		if indexv<length(Xv)
			Xvindexv=Xv(indexv);
		else
			Xvindexv=Xa(end)+1;
		end
		Xav(i)=min(Xaindexa,Xvindexv);
		if Xav(i)==Xaindexa
			Cdfav(i)=Cdfa(indexa)+interpol(indexv-1,indexv,Xv,Cdfv,Xaindexa);
			indexa=indexa+1;
		else
			Cdfav(i)=Cdfv(indexv)+interpol(indexa-1,indexa,Xa,Cdfa,Xvindexv);
			indexv=indexv+1;
		end;
	end
	h=rplotpt (Xav, probit(Cdfav), Style);
else
	X = sort(X);
	Cdf = [1:length(X)]'/length(X);
	h=plotpt (X, probit(Cdf), Style);
end



function chi = probit (cdf)
% CHI = PROBIT(CDF)
%
% Probit (Inverse Gaussian) function
%

%
myerf       = 2*cdf - 1;
myerfinv    = sqrt(2)*erfinv(myerf);
chi         = myerfinv;


function F = pooldata(subject,ear,hand)

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

function [hpatch,hline] = pa_errorpatch(X,Y,E,col)
% PA_ERRORPATCH(X,Y,E)
%
% plots the graph of vector X vs. vector Y with error patch specified by
% the vector E.
%
% PA_ERRORPATCH(...,'ColorSpec') uses the color specified by the string
% 'ColorSpec'. The color is applied to the data line and error patch, with
% the error patch having an alpha value of 0.4.
%
% [HPATCH,HLINE] = PA_ERRORPATCH(...) returns a vector of patchseries and
% lineseries handles in HPATCH and HLINE, respectively.

% (c) 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
% Check whether
if size(X,1)>1
	X=X(:)';
	if size(X,1)>1
		error('X should be a row vector');
	end
end
if size(Y,1)>1
	Y   = Y(:)';
	if size(Y,1)>1
		error('Y should be a row vector');
	end
end
if size(E,1)>2
	E   = E(:)';
	if size(E,1)>2
		error('E should be a row vector or 2-row matrix');
	end
end
if length(Y)~=length(X)
	error('Y and X should be the same size');
end
if size(E,2)~=size(X,2)
	error('E and X should be the same size');
end
if nargin<4
	col = 'k';
end

%% remove nans
if size(E,1)>1
	sel		= isnan(X) | isnan(Y) | isnan(E(1,:)) | isnan(E(2,:));
	E		= E(:,~sel);
else
	sel		= isnan(X) | isnan(Y) | isnan(E);
	E		= E(~sel);
end
X		= X(~sel);
Y		= Y(~sel);

%% Create patch
x           = [X fliplr(X)];
if size(E,1)>1
	y           = [E(1,:) fliplr(E(2,:))];
else
	y           = [Y+E fliplr(Y-E)];
end
%% Graph
hpatch           = patch(x,y,[.7 .7 .7]);
set(hpatch,'EdgeColor','none');
hold on;


function [mu,uperiod,ci] = timeplot(vel,period,RT,col)

uvel	= unique(vel);
Fs		= 1000;
md		= 100;
durrip	= 3000;
durstat = 1000;
nTime   = round( (durrip/1000)*Fs ); % # Samples for Rippled Noise
time	= ((1:nTime)-1)/Fs; % Time (sec)
nTime   = round( (durstat/1000)*Fs ); % # Samples for Rippled Noise
b		= ones(1,nTime);

uperiod = unique(period);
nperiod = numel(uperiod);
mu		= NaN(nperiod,1);
ci		= NaN(nperiod,2);

for ii = 1:nperiod
	T			= 2*pi*(1./uperiod(ii))*time;
	a		= 1+md/100*sin(T);
	a = [b a];
	a = a*0.25;
	t	= (0:length(a)-1)/Fs*1000-1000;
	
	sel		= period==uperiod(ii);
	% 	rt = mod(RT(sel)/1000,uperiod(ii));
	rt		= RT(sel);
	[D,XI]	= ksdensity(rt,-100:25:1000);
	
	D		= D/max(D);
	% 	pa_errorpatch(t,repmat(-ii+nperiod,size(a)),a,'r')
	if nargin>3
		hold on
		plot(XI,D*0.8-ii+nperiod,'k-','LineWidth',1,'Color',col);
	end
	% 	pa_horline(-ii+nperiod,'k-')
	mu(ii) = median(rt);
	ci(ii,:) = prctile(rt,[25 75]);
	% 	plot([mu(ii) mu(ii)],[-ii+nperiod -ii+nperiod+0.8],'k-');
	% 	plot([ci(ii,1); ci(ii,1)]',[-ii+nperiod -ii+nperiod+0.8],'k-');
	% 	plot([ci(ii,2); ci(ii,2)]',[-ii+nperiod -ii+nperiod+0.8],'k-');
	% 	plot([ci(ii,1); ci(ii,2)]',[-ii+nperiod -ii+nperiod]+0.8,'k-');
	
	
end
if nargin>3
	plot(mu,(nperiod:-1:1)-0.2,'ko-','MarkerFaceColor','w','LineWidth',2,'Color',col)
	% plot(ci(:,1),(nperiod:-1:1)-0.2,'ks','MarkerFaceColor','w','LineWidth',2,'Color',col)
	ylim([0 nperiod]);
	xlim([-100 700]);
	axis square;
	pa_verline;
	% pa_horline;
	box off
	xlabel('Time (ms)');
	ylabel({'P(\tau)';'Sorted by modulation frequency'});
	set(gca,'YTick',1:nperiod-1,'YTickLabel',uvel(2:end))
end


function [mu,uperiod,ci,D,XI,PT] = phaseplot(vel,period,RT,col,beta)

uvel	= unique(vel);
Fs		= 1000;
md		= 100;
durrip	= 3000;
durstat = 1000;
nTime   = round( (durrip/1000)*Fs ); % # Samples for Rippled Noise
time	= ((1:nTime)-1)/Fs; % Time (sec)
nTime   = round( (durstat/1000)*Fs ); % # Samples for Rippled Noise
b		= ones(1,nTime);

uperiod = unique(period);
nperiod = numel(uperiod);
mu		= NaN(nperiod,1);
ci		= NaN(nperiod,2);
PT = [];
for ii = 1:nperiod
	T		= 2*pi*(1./uperiod(ii))*time;
	a		= 1+md/100*sin(T);
	a		= [b a];
	a		= a*0.25;
	t		= (0:length(a)-1)/Fs*1000-1000;
	
	sel		= period==uperiod(ii);
	% 	rt = mod(RT(sel)/1000,uperiod(ii));
	rt		= RT(sel);
	[D,XI]	= ksdensity(rt,-100:25:1000);
	
	D		= D/max(D);
	% 	pa_errorpatch(t,repmat(-ii+nperiod,size(a)),a,'r')
	if nargin>3
		subplot(121)
		hold on
		plot(XI,D*0.8-ii+nperiod,'k-','LineWidth',1,'Color',col);
	end
	% 	pa_horline(-ii+nperiod,'k-')
	mu(ii) = median(rt);
	ci(ii,:) = prctile(rt,[25 75]);
	% 	plot([mu(ii) mu(ii)],[-ii+nperiod -ii+nperiod+0.8],'k-');
	% 	plot([ci(ii,1); ci(ii,1)]',[-ii+nperiod -ii+nperiod+0.8],'k-');
	% 	plot([ci(ii,2); ci(ii,2)]',[-ii+nperiod -ii+nperiod+0.8],'k-');
	% 	plot([ci(ii,1); ci(ii,2)]',[-ii+nperiod -ii+nperiod]+0.8,'k-');
	
	uperiod(ii)
	rt = RT(sel)/1000
	rt = rt/uperiod(ii);
	
	PT = [PT rt];
	% 	rt		= RT(sel);
	% 	rt = rt
	[D,XI]	= ksdensity(rt,-5:.1:5);
	
	D		= D/max(D);
	% 	pa_errorpatch(t,repmat(-ii+nperiod,size(a)),a,'r')
	if nargin>3
		subplot(122)
		hold on
		plot(XI,D*0.8-ii+nperiod,'k-','LineWidth',1,'Color',col);
	end
	
end

%%
close all
if nargin>3
	subplot(121)
	plot(mu,(nperiod:-1:1)-0.2,'ko-','MarkerFaceColor','w','LineWidth',2,'Color',col)
	% plot(ci(:,1),(nperiod:-1:1)-0.2,'ks','MarkerFaceColor','w','LineWidth',2,'Color',col)
	ylim([0 nperiod]);
	xlim([-100 700]);
	axis square;
	pa_verline;
	% pa_horline;
	box off
	xlabel('Time (ms)');
	ylabel({'P(\tau)';'Sorted by modulation frequency'});
	set(gca,'YTick',1:nperiod-1,'YTickLabel',uvel(2:end))
	
	
	subplot(122)
	cla
	stp = 1./std(PT);
	[N,x] = hist(PT,-5:.01:5);
	N = N./sum(N);
	[D,XI]	= ksdensity(PT,-5:.01:5);
	D = D./sum(D);
	% 	D		= D/max(D);
	% 	pa_errorpatch(t,repmat(-ii+nperiod,size(a)),a,'r')
	h = bar(x,N,1);set(h,'FaceColor',[.7 .7 .7]);
	hold on
	plot(XI,D,'k-','LineWidth',2);
	axis square
	xlim([-4 4]);
	pa_verline([-3 -2 -1 0 1 2 3]+beta(2)/1000);
end
%%
% keyboard