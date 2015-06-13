function rip_check_data_mw
close all
clc

pa_datadir;
cd('C:\DATA\Ripple Reaction Time\Data Ripplegram Completed');
subs	= [1 2 4 5 6 8 9 10 13 14 15 16 17 18 19 21];
nsubs	= numel(subs);
hands	= {'left';'right'};
nhand	= numel(hands);
ears	= {'left';'right';'both'};
near	= numel(ears);

N = 0;
Subject = struct([]);
for ii = 1:nsubs
	sub = subs(ii);
	for jj = 1:nhand
		hand = hands{jj};
		for kk = 1:near
			N = N+1;
			ear = ears{kk};
			[F,nfiles] = getdata(sub,ear,hand);
			
			
			
			Subject(ii).hand(jj).ear(kk).velocity = [F.velocity];
			Subject(ii).hand(jj).ear(kk).reactiontime = [F.lat];
			Subject(ii).hand(jj).ear(kk).md = [F.md];
			
			figure(1)
			subplot(221);
			cla
			subplot(2,2,2);
			cla
			subplot(2,2,3);
			cla
			
			[ntrials,ntrialsearly] = seldata(F,nfiles);
			earlydiscrepancy = ntrials-76-ntrialsearly;
			C{N,1}=sub;
			C{N,2}=ear;
			C{N,3}=hand;
			C{N,4}=nfiles;
			ntrials = num2str(ntrials');
			C{N,5}=ntrials;
			ntrialsearly = num2str(ntrialsearly');
			C{N,6}=ntrialsearly;
			earlydiscrepancy = num2str(earlydiscrepancy');
			C{N,7}=earlydiscrepancy;
			
		end
	end
	
	% % 	[F,nfiles] = mk_audiomotor_getdata_condition(sub,'right','right');
	% 	[F,nfiles] = mk_audiomotor_getdata_condition(sub,'left','left');
	%
	% 	RT = [F.lat];
	% 	t = 1:length(RT);
	% 	%% Plot timecourse reaction time
	% 	plot(t,RT,'k.');
	% 	% hold on
	% 	% plot(R.x50,smooth(R.rt50,50),'r-','LineWidth',2);
	% 	% ylim([200 1200]);
	% 	ylabel('Reaction Time (ms)','fontsize',16);
	% 	xlabel('Trial number','fontsize',16);
	% 	title(nfiles)
	%
	% 	pause
end
pa_datadir;
xlswrite('tst',C);
save('rippledata','Subject');


function [F,nfiles] = getdata(subject,ear,hand)
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
disp(dname);
pa_datadir;
cd('C:\DATA\Ripple Reaction Time\Data Ripplegram Completed');

fnames = dir(dname);
nfiles = length(fnames);

F = struct([]);
for ii= 1:nfiles
	load(fnames(ii).name)
	F(ii).velocity	= [Q.velocity];
	react			= [Q.reactiontime];
	% 	if any(react>3100)
	% 		react = react/2;
	% 	end
	react			= (react/1017) * 1000;
	if any(react>6000);
		react = react/2;
	end
	F(ii).react		= react;
% 	F(
	F(ii).durstat	= [Q.staticduration];
	F(ii).md		= [Q.modulationdepth];
	react			= F(ii).react - F(ii).durstat;
	F(ii).lat		= react;
% 	F(ii).lat		= [Q.latency]*1000;

end

function	[ntrials,ntrialsearly] = seldata(F,nfiles)

ntrials = NaN(nfiles,1);
ntrialsearly = NaN(nfiles,1);
for ii = 1:nfiles
	lat			= [F(ii).lat];
	rt			= [F(ii).react];
	
	
	ntrials(ii) = length(lat);
	ntrialsearly(ii) = sum(lat<0);
	subplot(221)
	t = (1:length(lat))+nansum(ntrials);
	plot(t,lat,'k.');
	hold on
	ylim([-1000 4000]);
	xlabel('Trial');
	ylabel('Reaction time (ms)');
	pa_verline(cumsum(ntrials),'r-');
	pa_horline;
	
	
	% axis square;
	subplot(222)
	t = (1:length(rt))+nansum(ntrials);
	plot(t,rt,'k.');
	hold on
	ylim([-1000 8000]);
	xlabel('Trial');
	ylabel('Reaction time (ms)');
	pa_verline(cumsum(ntrials),'r-');
	pa_horline;
	
end

%% negative
vel			= [F.velocity];
lat			= [F.lat];

sel				= vel==0;
negative		= lat(sel);
sel				= negative>2900;
truenegative	= negative(sel);
n				= numel(negative);
nmisses			= numel(truenegative);
title([n nmisses nmisses/n*100])
falserate = 1-(nmisses/n);

%% Positive
sel				= vel~=0;
positive		= lat(sel);
sel				= positive>0 & positive<1000;
truepositive	= positive(sel);
n				= numel(positive);
nhits			= numel(truepositive);
subplot(221)
title([n nhits nhits/n*100])
hitrate = nhits/n;

%% dprime
% d' = Z(hit rate) - Z(false alarm rate)
% dprime =  norminv(hitrate)- norminv(falserate);

dprime = pa_dprime(hitrate,falserate,nhits,nmisses);
title([hitrate falserate dprime])


%% Density
xi = -1000:10:4000;
[D,XI] = ksdensity(lat,xi);
D = D./sum(D);
[N,xi] = hist(lat,xi);
N = N./sum(N);

subplot(223)

bar(xi,N,1,'FaceColor',[.7 .7 .7],'EdgeColor','none');
hold on
plot(XI,D,'k-');
xlim([-1000 4000]);
