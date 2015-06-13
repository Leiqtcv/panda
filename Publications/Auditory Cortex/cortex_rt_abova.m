function cortex_rt_abova
close all hidden

cd('E:\DATA\Test');

load cortexrt

%%
close all
rt = [RT1000.rt];
d = abs([RT1000.rd]);
v = [RT1000.rv];

ud = unique(d);
uv = unique(v);
[uv,ud] = meshgrid(uv,ud);

n = numel(uv);
RT = NaN(size(uv));
for ii = 1:n
	sel = d==ud(ii) & v==uv(ii) & rt>250;
	RT(ii) = nanmedian(rt(sel));
end
RT = RT-mean(RT(:));

uv = uv(1,:);
ud = ud(:,1);

subplot(222)
contourf(ud,uv,RT',50);
set(gca,'YTick',uv)
set(gca,'XTick',ud)
axis square;

colorbar
caxis([-30 30]);
shading flat;
xlabel('Density (cyc/oct)');
ylabel('Velocity (Hz)');
title('\tau > 250 ms');


rt = [RT1000.rt];
d = abs([RT1000.rd]);
v = [RT1000.rv];

ud = unique(d);
uv = unique(v);
[uv,ud] = meshgrid(uv,ud);

n = numel(uv);
RT = NaN(size(uv));
for ii = 1:n
	sel = d==ud(ii) & v==uv(ii) & rt<250;
	RT(ii) = nanmedian(rt(sel));
end
RT = RT-mean(RT(:));

uv = uv(1,:);
ud = ud(:,1);

subplot(221)
contourf(ud,uv,RT',50);
set(gca,'YTick',uv)
set(gca,'XTick',ud)
axis square;
colorbar
caxis([-30 30]);
shading flat;
xlabel('Density (cyc/oct)');
ylabel('Velocity (Hz)');
title('\tau < 250 ms');


rt	= [RTAM1000.rt];
v	= [RTAM1000.rv];

uv	= unique(v);

n	= numel(uv);
RT	= NaN(size(uv));
for ii = 1:n
	sel = v==uv(ii) & rt>250;
	RT(ii) = nanmedian(rt(sel));
end

uv = uv(1,:);

up = 1./uv;
subplot(212)
semilogx(uv,RT-mean(RT),'ro-','MarkerFaceColor','w');
hold on
set(gca,'XTick',uv,'XTickLabel',uv);



rt	= [RTAM1000.rt];
v	= [RTAM1000.rv];

uv	= unique(v);

n	= numel(uv);
RT	= NaN(size(uv));
for ii = 1:n
	sel = v==uv(ii) & rt<250;
	RT(ii) = nanmedian(rt(sel));
end

uv = uv(1,:);

up = 1./uv;
subplot(212)
semilogx(uv,RT-mean(RT),'ko-','MarkerFaceColor','w');
set(gca,'XTick',uv,'XTickLabel',uv);
xlabel('Modulation frequency (Hz)');
ylabel('Reaction time - mean (ms)');
% axis square;

legend('\tau > 250 ms','\tau < 250 ms');
title('AM');

return
%% Ripple 500
s = RT500;

keyboard
doanova(s);

%% AM 500
s = RTAM500;
doAManova(s);

%% Both
s1 = RTAM500;
s2 = RTAM1000;

doAManova2(s1,s2)

function doanova(s)
rt		= [s.rt];
vel		= [s.rv];
dens	= [s.rd];
cond	= [s.con];
monk	= [s.monk];



sel		= rt<8000 & rt>0;
y		= rt(sel);
g		= {vel(sel),abs(dens(sel)),monk(sel)};
m		= [[1 0 0];[0 1 0];[0 0 1];[1 1 0]];
[p,t,stats] = anovan(y,g,'random',3,'varnames',{'Velocity','Density','Monkey'},'model',m);

figure
multcompare(stats,'dimension',1);

figure
multcompare(stats,'dimension',2);

figure
multcompare(stats,'dimension',[1 2]);


function doAManova(s)
s
rt		= [s.rt];
vel		= [s.rv];
monk	= [s.monk];



sel		= rt<8000 & rt>0;
y		= rt(sel);
g		= {vel(sel),monk(sel)};
[p,t,stats] = anovan(y,g,'random',2,'varnames',{'Velocity','Monkey'},'model','linear');

figure
multcompare(stats,'dimension',1);


function doAManova2(s1,s2)
rt		= [s1.rt];
vel		= [s1.rv];
monk	= [s1.monk];
cond = zeros(size(monk));
rt		= [rt [s2.rt]];
vel		= [vel [s2.rv]];
monk	= [monk [s2.monk]];
cond = [cond ones(size(monk))];


sel		= rt<8000 & rt>0;
y		= rt(sel);
g		= {vel(sel),cond(sel),monk(sel)};
m		= [[1 0 0];[0 1 0];[0 0 1];[1 1 0]];
[p,t,stats] = anovan(y,g,'random',3,'varnames',{'Velocity','Predictability','Monkey'},'model',m);

figure
multcompare(stats,'dimension',[1 2]);

