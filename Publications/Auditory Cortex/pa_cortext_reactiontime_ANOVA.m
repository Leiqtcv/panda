function pa_cortext_reactiontime_ANOVA
close all hidden

cd('E:\DATA\Test');

load cortexrt

%% Ripple 500
s = RT500;
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

