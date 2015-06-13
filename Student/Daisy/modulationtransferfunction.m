function modulationtransferfunction
%% Clear
clear all
close all

%% Load  data
subplot(231)
getdata([5 6],'r');
getdata([3 4],'b');
getdata(8,'w');
ylim([200 1200]); 
title('Density = 0 cycles/oct');

subplot(234)
getdata(1,'r');
getdata(2,'b');
getdata(7,'w');
ylim([200 1200]); 
title('Density = 0 cycles/oct');

subplot(232)
h(1) = getdata3([5 6],'r');
h(2) = getdata3([3 4],'b');
h(3) = getdata3(8,'w');
ylim([200 1200]); 
title('Density > 0 cycles/oct');
legend(h,{'HA';'CI';'Bimodal'},'Location','SW');

subplot(235)
h(1) = getdata3(1,'r');
h(2) = getdata3(2,'b');
h(3) = getdata3(7,'w');
ylim([200 1200]); 
title('Density > 0 cycles/oct');
legend(h,{'Right';'Left';'Binaural'},'Location','NE');

subplot(233)
getdata2([5 6],'r');
getdata2([3 4],'b');
getdata2(8,'w');
ylim([200 1200]); 
xlim([0.125 16]);
title('|Velocity| > 0 cycles/s');

subplot(236)
getdata2(1,'r');
getdata2(2,'b');
getdata2(7,'w');
ylim([200 1200]); 
xlim([0.125 16]);
title('|Velocity| > 0 cycles/s');

pa_datadir
print('-depsc','-painter',mfilename);

function h = getdata(c,col)
cd('E:\DATA\Ripple\Daisy');
S = load('ripplevariables_basics');
cond = S.cond;
dens = S.dens;
vel = abs(S.vel);
rt = S.rt;
% unique(S.ds)
%% 
vel = abs(vel);
selrn	= cond == 1; % right normal-hearing
selln	= cond == 2; % left normal-hearing
selbn	= cond == 7; % binaural normal-hearing
seld	= dens  == 0; % pure amplitude modulations (density = 0 cycles/oct)
selv = vel>0;
sel3000 = rt<2000; 

selmn = ismember(cond,c);

sel		= selmn & seld & sel3000 & selv; % select all monaural normal-hearing & AM
rt		= rt(sel);
vel		= vel(sel); % pool negative & positive data for now

%% Determine mean and std reaction time for every velocity
uvel	= unique(vel);
nvel	= numel(uvel);
muRT = NaN(nvel,1);
sdRT = NaN(nvel,1);
for ii = 1:nvel
	sel = vel == uvel(ii);
	muRT(ii) = mean(rt(sel));
	sdRT(ii) = 1.96*std(rt(sel))./sqrt(sum(sel));
end

%% Linear regression: does reaction time linearly depend on period?
sel = uvel<100;
MP = 1./uvel(sel); % modulation period

y = muRT(sel)/1000; % (s)
x = MP;
b = regstats(y,x,'linear','beta');


%% Graphics
x = 0.4:0.1:80; % velocity for line fit
x = 1./x; % period
ypred = b.beta(2).*x+b.beta(1); % predicted reaction time (s)
ypred = ypred*1000; % ms
% plot(1./x,ypred,'k-','LineWidth',2,'Color',[.7 .7 .7])
x = 0.5:0.1:64;
y = interp1(1./uvel,muRT,1./x,'cubic');
if strcmp(col','w')
plot(x,y,'k-','Color','k','LineWidth',2);
else
plot(x,y,'k-','Color',col,'LineWidth',2);
end
hold on
h = errorbar(uvel,muRT,sdRT,'ko','MarkerFaceColor',col,'LineWidth',2);
xlabel('|Velocity| (cycles/s)'); 
ylabel('Reaction time (ms)');
set(gca,'Xscale','log','XTick',uvel,'XTickLabel',uvel);
xlim([0.25 128]);
box off
axis square;

str = ['\tau = ' num2str(b.beta(2),2) 'T + ' num2str(b.beta(1),3)];
title(str)

function h = getdata3(c,col)
cd('E:\DATA\Ripple\Daisy');
S = load('ripplevariables_basics');
cond = S.cond;
dens = S.dens;
vel = abs(S.vel);
rt = S.rt;
% unique(S.ds)
%% 
vel = abs(vel);
selrn	= cond == 1; % right normal-hearing
selln	= cond == 2; % left normal-hearing
selbn	= cond == 7; % binaural normal-hearing
seld	= dens  > 0; % pure amplitude modulations (density = 0 cycles/oct)
selv = vel>0;
sel3000 = rt<2000; 

selmn = ismember(cond,c);

sel		= selmn & seld & sel3000 & selv; % select all monaural normal-hearing & AM
rt		= rt(sel);
vel		= vel(sel); % pool negative & positive data for now

%% Determine mean and std reaction time for every velocity
uvel	= unique(vel);
nvel	= numel(uvel);
muRT = NaN(nvel,1);
sdRT = NaN(nvel,1);
for ii = 1:nvel
	sel = vel == uvel(ii);
	muRT(ii) = mean(rt(sel));
	sdRT(ii) = 1.96*std(rt(sel))./sqrt(sum(sel));
end

%% Linear regression: does reaction time linearly depend on period?
sel = uvel<100;
MP = 1./uvel(sel); % modulation period

y = muRT(sel)/1000; % (s)
x = MP;
b = regstats(y,x,'linear','beta');


%% Graphics
x = 0.4:0.1:80; % velocity for line fit
x = 1./x; % period
ypred = b.beta(2).*x+b.beta(1); % predicted reaction time (s)
ypred = ypred*1000; % ms
% plot(1./x,ypred,'k-','LineWidth',2,'Color',[.7 .7 .7])
x = 0.5:0.1:64;
y = interp1(1./uvel,muRT,1./x,'cubic');
if strcmp(col','w')
plot(x,y,'k-','Color','k','LineWidth',2);
else
plot(x,y,'k-','Color',col,'LineWidth',2);
end
hold on
h = errorbar(uvel,muRT,sdRT,'ko','MarkerFaceColor',col,'LineWidth',2);
xlabel('|Velocity| (cycles/s)'); 
ylabel('Reaction time (ms)');
set(gca,'Xscale','log','XTick',uvel,'XTickLabel',uvel);
xlim([0.25 128]);
box off
axis square;

str = ['\tau = ' num2str(b.beta(2),2) 'T + ' num2str(b.beta(1),3)];
title(str)

function h = getdata2(c,col)
cd('E:\DATA\Ripple\Daisy');
S = load('ripplevariables_basics');
cond = S.cond;
dens = S.dens;
vel = abs(S.vel);
rt = S.rt;
% unique(S.ds)
%% 
vel = abs(vel);
selrn	= cond == 1; % right normal-hearing
selln	= cond == 2; % left normal-hearing
selbn	= cond == 7; % binaural normal-hearing
seld	= dens  > 0; % pure amplitude modulations (density = 0 cycles/oct)
% selv = ismember(vel,[1]);
selv = vel>-1;
sel3000 = rt<2000; 

selmn = ismember(cond,c);

sel		= selmn & seld & sel3000 & selv; % select all monaural normal-hearing & AM
rt		= rt(sel);
vel		= vel(sel); % pool negative & positive data for now
dens = dens(sel);
%% Determine mean and std reaction time for every velocity
udens	= unique(dens);
nvel	= numel(udens);
muRT = NaN(nvel,1);
sdRT = NaN(nvel,1);
for ii = 1:nvel
	sel = dens == udens(ii);
	muRT(ii) = mean(rt(sel));
	sdRT(ii) = 1.96*std(rt(sel))./sqrt(sum(sel));
end

%% Linear regression: does reaction time linearly depend on period?
sel = udens<100;
MP = udens(sel); % modulation period

y = muRT(sel)/1000; % (s)
x = MP;
b = regstats(y,x,'linear','beta');


%% Graphics
% x = 0.4:0.1:80; % velocity for line fit
% x = 1./x; % period
% ypred = b.beta(2).*x+b.beta(1); % predicted reaction time (s)
% ypred = ypred*1000; % ms
% % plot(1./x,ypred,'k-','LineWidth',2,'Color',[.7 .7 .7])
x = 0.25:0.1:8;
y = interp1(log2(udens),muRT,log2(x),'cubic');
if strcmp(col','w')
plot(x,y,'k-','Color','k','LineWidth',2);
else
plot(x,y,'k-','Color',col,'LineWidth',2);
end
hold on
h = errorbar(udens,muRT,sdRT,'ko','MarkerFaceColor',col,'LineWidth',2);
xlabel('Density (cycles/oct)');
ylabel('Reaction time (ms)');
set(gca,'Xscale','log','XTick',udens,'XTickLabel',udens);
% xlim([0.25 128]);
box off
axis square;

% str = ['\tau = ' num2str(b.beta(2),2) 'T + ' num2str(b.beta(1),3)];
% title(str)
