function rip_results_figure_conditions_allsubjects_2

%% Clean
close all
clc

%% Load data
pa_datadir;
% subs	= [1 2 4 5 6 8 9 10 13 14 15 16 17 18 19 21];
subs	= [1 2 4 5 6 8 9 10 13 14 15 16 17 18 19 21];
% subs	= [13 19];

nsubs	= numel(subs);
D = [];
PT = [];
% SD = M;
col = jet(6);
mrkr = ['o';'<';'>';'s';'^';'v'];
for jj = 1:6
	M = NaN(nsubs,9);
	for ii = 1:nsubs
		sub		= subs(ii);
		% [R,V,ND] = rip_audiomotor_getdata_condition(sub,'left','left');
		switch jj
			case 1
				F = pooldata(sub,'right','right');
			case 2
				F = pooldata(sub,'right','left');
			case 3
				F = pooldata(sub,'left','right');
			case 4
				F = pooldata(sub,'left','left');
			case 5
				F = pooldata(sub,'both','left');
			case 6
				F = pooldata(sub,'both','right');
		end
		
		% 		col		= gray(5);
		vel		= [F.velocity];
		% 		vel(vel<0) = -vel(vel<0);
		% 		vel		= round(vel);
		
		md		= [F.md];
		period	= 1./vel;
		RT		= [F.lat];
		sel		= vel>0 & md==50;
		% 		sel		= vel>0 & ismember(md,[50 100]);
		[mu,uperiod] = timeplot(vel(sel),period(sel),RT(sel));
		if any(uperiod<0)
			uperiod = -uperiod;
			[uperiod,indx] = sort(uperiod);
			mu = mu(indx);
		end
		
		[mu,uperiod,sd] = timeplot(vel(sel),period(sel),RT(sel));
		if any(uperiod<0)
			uperiod = -uperiod;
			[uperiod,indx] = sort(uperiod);
			mu = mu(indx);
		end
		whos mu M
		M(ii,:)	= mu;
		% 	SD(ii,:)	= sd;
		% 	pause
	end
	
	%%
	[uvel,indx] = sort(1./uperiod);
	figure(666)
	mu = mean(M(:,indx));
	n = size(M,1);
	sd = std(M(:,indx))/sqrt(n);
% 	subplot(121)
	errorbar(uvel,mu,sd,['k' mrkr(jj) '-'],'MarkerFaceColor','w','Color',col(jj,:),'LineWidth',2);
	hold on
	% 	ylim([150 600]);
	axis square;
	set(gca,'XTick',uvel,'XScale','log','XTickLabel',uvel);
	xlim([0.25 256]);
	
% 	mu = median(M);
% 	n = size(M,1);
% 	sd = std(M)/sqrt(n);
% 	subplot(122)
% 	errorbar(uperiod,mu,sd,'ko-','MarkerFaceColor','w','Color',col(jj,:));
% 	hold on
% 	% 	ylim([150 600]);
% 	axis square;
% 	set(gca,'XTick',uperiod,'XTickLabel',uperiod,'XScale','log');
	
	
end


legend({'RR';'RL';'LR';'LL';'BL';'BR'});
xlabel('Modulation frequency (Hz)');
ylabel('Reaction time (ms)');

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
cd('E:\DATA\Ripple\Data Ripplegram Completed');

fnames = dir(dname);
nfiles = length(fnames);

F = struct([]);
for ii= 1:nfiles
	load(fnames(ii).name)
	F(ii).velocity	= [Q.velocity];
	react = [Q.reactiontime];
	% 	if any(react>3100)
	% 		react = react/2;
	% 	end
	
	react			= (react/1017) * 1000;
	if any(react>6000);
		react = react/2;
	end
	F(ii).react		= react;
	
	F(ii).durstat	= [Q.staticduration];
	F(ii).md		= [Q.modulationdepth];
	F(ii).lat		= F(ii).react - F(ii).durstat;
end

RT = [F.react];
ds = [F.durstat];
md = [F.md];
lat = [F.lat];
vel = [F.velocity];
%% Selection reaction time
sel			= lat>0 & lat<2900;
% F			= F(sel);
% l           = lat(sel);
% p           = prctile(l,[2.5 97.5]);
% sel         = lat>p(1) & lat<p(2);

F = [];
F.react = RT(sel);
F.durstat	= ds(sel);
F.md		= md(sel);
F.lat		= lat(sel);
F.velocity = vel(sel);
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
	mu(ii) = mean(rt);
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


%%
% keyboard