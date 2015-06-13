function results_figure_conditions
close all
clc

pa_datadir;
cd('Ripple');
subs = [1 2 4 5 6 8 9 10 13 14 15 16 17 18 19 21];
nsubs = numel(subs)
sub = subs(7);
[R,V,ND] = mk_audiomotor_getdata_condition(sub,'left','left');
[R,V,ND] = mk_audiomotor_getdata_condition(sub,'right','right');

%% Plot effect of static duration
figure(1)
plot(R.dur,R.rt,'ko-')
set(gca, 'XTick',R.dur);
ylabel('Mean reaction Time (ms)','fontsize',16);
xlabel('Static Duration','fontsize',16);
title('Effect of static duration','fontsize',16);

%% Plot timecourse reaction time
figure(2)
subplot(211)
plot(R.x50,R.rt50,'k.');
% hold on
% plot(R.x50,smooth(R.rt50,50),'r-','LineWidth',2);
str = ['Modulationdepth = 50; RT = ' num2str(round(V.smu50)) ' \pm ' num2str(round(V.sse50)) ' ms'];
% ylim([200 1200]);
ylabel('Reaction Time (ms)','fontsize',16);
xlabel('Trial number','fontsize',16);
title(str,'fontsize',16);
subplot(212)
plot(R.x100,R.rt100,'k.');
% hold on
% plot(R.x100,smooth(R.rt100,50),'r-','LineWidth',2);
str = ['Modulationdepth = 100; RT = ' num2str(round(V.smu100)) ' \pm ' num2str(round(V.sse100)) ' ms'];
% ylim([200 1200]);
ylabel('Reaction Time (ms)','fontsize',16);
xlabel('Trial number','fontsize',16);
title(str,'fontsize',16);
return
%% Plot histogram of reaction time
figure(3)
subplot(121)
hist(R.rt50,0:10:10000);
axis square;
xlabel('Reaction time (ms)','fontsize',16);
ylabel('N','fontsize',16);
xlim([0 1000]);
title('Modulationdepth = 50','fontsize',16);
subplot(122)
hist(R.rt100,0:10:10000);
axis square;
xlabel('Reaction time (ms)','fontsize',16);
ylabel('N','fontsize',16);
xlim([0 1000]);
title('Modulationdepth = 100','fontsize',16);

%% Plot not detected
col = cool(4);

figure(4)
subplot(121)
plot(V.v, ND.ndt(1,:),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(1,:))
hold on
plot(V.v, ND.ntr(1,:),'ro')
% set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Not detected','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
axis square
title('Not Detected; Modulationdepth = 50;','fontsize',16);
subplot(122)
plot(V.v, ND.ndt(2,:),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(2,:))
hold on
plot(V.v, ND.ntr(2,:),'ro')
% set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Not detected','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
axis square
title('Not Detected; Modulationdepth = 100','fontsize',16);

%% Plot mean rt
figure(5)
errorbar(abs(1./V.v(1:10)),V.mu(1,1:10),V.se(1,1:10),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(1,:));
hold on
errorbar(1./V.v(11:19),V.mu(1,11:19),V.se(1,11:19),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(2,:));
hold on
errorbar(abs(1./V.v(1:10)),V.mu(2,1:10),V.se(2,1:10),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(3,:));
hold on
errorbar(1./V.v(11:19),V.mu(2,11:19),V.se(2,11:19),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(4,:));
% set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Reaction Time (ms)','fontsize',16);
xlabel('Modulation frequency (Hz)','fontsize',16);
legend({'md = 50, -', 'md = 50, +', 'md = 100, -', 'md = 100, +'},'Location','NW');
% axis square
% set(gca,'XScale','log');

vel = unique(abs(V.v));
uperiod = 1./vel;
[uperiod,indx] = sort(uperiod);
vel = vel(indx);
set(gca,'XTick',uperiod,'XTickLabel',vel);
ylim([0 1000]);

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

