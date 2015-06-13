clear all
close all
clc

pa_datadir;
cd('Test');

%% Population
fname       = 'Bevolking.xls';
[N,T,R]     = xlsread(fname);
yrs_pop = N(1,:);
pop = N(2,:)/1000000;
plot(yrs_pop,pop,'.');



%% Religion
fname       = 'Kerkelijke_gezindte.xls';
[N,T,R]     = xlsread(fname);
yrs_god     = T(5:end,1);
yrs_god     = str2double(yrs_god);
christen    = nansum(N(:,2:5),2);
[yrs_god,IA,IB] = intersect(yrs_pop,yrs_god);
pop = pop(IA)';

katholiek	= N(IB,2).*pop;
protestant	= N(IB,3).*pop;
hervormd	= N(IB,4).*pop;
gereformeerd = N(IB,5).*pop;
atheist     = N(IB,1).*pop;
rel = N(IB,1:5);
% katholiek	= N(IB,2);
% protestant	= N(IB,3);
% hervormd	= N(IB,4);
% gereformeerd = N(IB,5);
% atheist     = N(IB,1);
figure
plot(yrs_god,rel,'-','LineWidth',2);
axis square;
box off
xlabel('Year');
ylabel('Percentage');

yrs = round(yrs_god/20)*20;
uyrs = unique(yrs);
nyrs = numel(uyrs);
labels = {'Atheist';'Catholic';'Protestant';'Reformed';'Calvinism'};

for ii = 1:nyrs
	sel = yrs==uyrs(ii);
	if sum(sel)>1
	x = nanmean(rel(sel,:))
	else
	x = rel(sel,:);
	end
	x(isnan(x))=0.1;
	subplot(3,2,ii)
	pie(x,labels);
	title(uyrs(ii))

end
pa_datadir;
print('-depsc','-painter','pies');
cd('Test');


%% Climate
fname       = 'Klimaatgegevens.xls';
[N,T,R]     = xlsread(fname);
yrs_weer    = T(6:end,1);
yrs_weer    = str2double(yrs_weer);

temp        = N(:,1);
neerslag    = N(:,11);

[yrs,IA,IB] = intersect(yrs_weer,yrs_god);

T       = temp(IA);
C		= christen(IB);
A		= atheist(IB);
sel		= ~isnan(T) & ~isnan(C) & ~isnan(A);
T		= T(sel);
C		= C(sel);
A		= A(sel);
% yrs = yrs(sel);
figure
% plot(yrs_weer,temp,'k.');
hold on
[avg,xavg] = pa_runavg(temp,20,yrs_weer);
% xavg = yrs_weer;
% avg = smooth(temp,20);
sel			= ~isnan(avg);
avg			= avg(sel);
xavg		= xavg(sel);
x			= xavg;
y			= avg;

plot(yrs_weer,temp,'ko','MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor',[.7 .7 .7]);
hold on
plot(x,y,'k-','LineWidth',3);
axis square;
xlabel('Years');
ylabel('Average yearly temperature (deg Celcius)');
box off
xlim([1900 2010]);
ylim([7.5 11.5]);
set(gca,'YTick',8:1:11);
pa_verline(1945);
% return

pa_datadir;
print('-depsc','-painter','climate');
cd('Test');
%%


V = interp1(xavg,avg,yrs_god);
figure
subplot(331)
plot(yrs_god,V,'k-','LineWidth',2);

subplot(332)
plot(yrs_god,atheist,'b-');

subplot(333)
plot(yrs_god,katholiek,'b-');

subplot(334)
plot(yrs_god,protestant,'b-');

subplot(335)
plot(yrs_god,hervormd,'b-');

subplot(336)
plot(yrs_god,gereformeerd,'b-');

%%
figure
selnan	= ~isnan(V);
y		= V(selnan);

x		= atheist(selnan);
subplot(221)
plot(x,y,'ko','MarkerFaceColor',[.7 .7 .7]);
axis square;
lsline;
pa_verline(median(x));
box off;

x		= katholiek(selnan);
subplot(222)
plot(x,y,'ko','MarkerFaceColor',[.7 .7 .7]);
axis square;
lsline;
pa_verline(median(x));
box off;

x		= gereformeerd(selnan);
subplot(223)
plot(x,y,'ko','MarkerFaceColor',[.7 .7 .7]);
axis square;
lsline;
pa_verline(median(x));
box off;

x		= hervormd(selnan);
subplot(224)
plot(x,y,'ko','MarkerFaceColor',[.7 .7 .7]);
axis square;
lsline;
pa_verline(median(x));
box off;

%%
figure
selnan	= ~isnan(V);
y		= V(selnan);


x		= atheist(selnan)./katholiek(selnan);
subplot(131)
plot(x,y,'ko','MarkerFaceColor',[.7 .7 .7]);
axis square;
lsline;
pa_verline(median(x));
box off;

x		= atheist(selnan)./gereformeerd(selnan);
subplot(132)
plot(x,y,'ko','MarkerFaceColor',[.7 .7 .7]);
axis square;
lsline;
pa_verline(median(x));
box off;

x		= atheist(selnan)./hervormd(selnan);
subplot(133)
plot(x,y,'ko','MarkerFaceColor',[.7 .7 .7]);
axis square;
lsline;
pa_verline(median(x));
box off;

%%
figure
subplot(122)
selnan	= ~isnan(V);
y		= V(selnan);
x = [atheist(selnan) hervormd(selnan)];

% x = [atheist(selnan)./katholiek(selnan) atheist(selnan)./hervormd(selnan) ];
% x = [ (atheist(selnan)+katholiek(selnan)+gereformeerd(selnan))./hervormd(selnan) atheist(selnan)./gereformeerd(selnan)];
% x = [katholiek(selnan)  (hervormd(selnan) )];
n = 0;
x = x(1:end-n,:);
y = y((n+1):end);
x = zscore(x);
y = zscore(y);
% whos x y
b = regstats(y,x,'linear','all');
pa_errorbar(b.beta(2:end),b.tstat.se(2:end),'xlabel',{'Atheist';'Catholic'});
axis square;
% ylim([-0.1 0.1]);
% xlim([0 3]);
ylabel('Temperature increase (deg per 1 billion inhabitants)');
box off

subplot(121)
plot(yrs_god,V,'k-','LineWidth',2);
hold on
y = b.beta(1)+b.beta(2).*x(:,1)+b.beta(3).*x(:,2);
yrs = yrs(selnan);
hold on
plot(yrs,y,'r-','LineWidth',2);
axis square;
ylabel('Temperature (deg)');
xlabel('Year');
box off

return
sigma   = 4;
xi      = 0:.5:60;

X       = C;
Y       = T;
[mu,ci,XI] = pa_weightedmean(X,Y,sigma,xi);
sel = ~isnan(mu);
mu = mu(sel);
ci = ci(sel,:);
XI = XI(sel);

figure(666)
subplot(121)
hold on
ci(:,1) = 8.5;
pa_errorpatch(XI',mu',ci','r');
hold on
xlabel('% Rooms-Katholiek');
ylabel('Gemiddelde jaartemperatuur (graden Celsius)');
axis square;
box off
axis([min(XI) max(XI) 8.5 11])

X       = A;
Y       = T;
[mu,ci,XI] = pa_weightedmean(X,Y,sigma,xi);
sel = ~isnan(mu);
mu = mu(sel);
ci = ci(sel,:);
XI = XI(sel);
ci(:,1) = 8.5;

figure(666)
subplot(122)
% plot(A,T,'b.','LineWidth',1);
hold on
pa_errorpatch(XI',mu',ci','b');
hold on
xlabel('% Atheist');
ylabel('Gemiddelde jaartemperatuur (graden Celsius)');
axis square;
box off
axis([min(XI) max(XI) 8.5 11])

pa_datadir
print('-depsc','-painter','hellonearth');
cd('Test')

%%
fname = 'Klimaatgegevens.xls';
[N,T] = xlsread(fname);

yrs			= T(6:end,1);
yrs			= str2double(yrs);
temp		= N(:,1);
tempwinter	= N(:,2);
tempzomer	= N(:,3);
neerslag	= N(:,11);

figure

sigma   = 5;
xi      = nanmin(yrs):nanmax(yrs);
X		= yrs;

Y			= neerslag;
[mu,ci,XI]	= pa_weightedmean(X,Y,sigma,xi);
sel = ~isnan(mu);
mu = mu(sel);
XI = XI(sel);
ci = ci(sel,:);
ci(:,1) = 700;
ci(:,2) = smooth(ci(:,2));
pa_errorpatch(XI',mu',ci','b');
hold on
xlim([nanmin(XI) nanmax(XI)]);
ylim([700 1100]);
box off
pa_datadir
print('-depsc','-painter','flood');
cd('Test')

%%
figure
hold on
box off
axis square;

sigma   = 10;
xi      = nanmin(yrs):nanmax(yrs);
X			= yrs;

Y			= tempzomer;
[mu,ci,XI]	= pa_weightedmean(X,Y,sigma,xi);
md			= nanmean(mu(:));
mu			= mu-md+2;
ci			= ci-md+2;
pa_errorpatch(XI',mu',ci','r');

Y			= tempwinter;
[mu,ci,XI]	= pa_weightedmean(X,Y,sigma,xi);
md			= nanmean(mu(:));
mu			= mu-md-2;
ci			= ci-md-2;
pa_errorpatch(XI',mu',ci','b');

Y			= temp;
[mu,ci,XI]	= pa_weightedmean(X,Y,sigma,xi);
md			= nanmean(mu(:));
mu			= mu-md;
ci			= ci-md;
pa_errorpatch(XI',mu',ci','g');

pa_horline(2,'r--');
pa_horline(-2,'b--');
pa_horline(0,'g--');

xlim([nanmin(XI) nanmax(XI)]);
%%
X       = yrs;
Y       = tempwinter;
[mu,ci,XI] = pa_weightedmean(X,Y,sigma,xi);
pa_errorpatch(XI',mu',1.96*ci','b');
hold on

X       = yrs;
Y       = temp;
[mu,ci,XI] = pa_weightedmean(X,Y,sigma,xi);
pa_errorpatch(XI',mu',1.96*ci','g');
hold on
% plot(X,Y,'ro','MarkerFaceColor','w');
xlim([1800 2012]);
axis square;
set(gca,'XTick',[1900:10:2010]);
% pa_verline([1917 1921 1940 1945]);
xlabel('Jaartal');
ylabel('Gemiddelde jaartemperatuur (graden Celsius)');
pa_horline(16,'r-');
pa_horline(9,'g-');
pa_horline(2,'b-');
pa_verline(1920);


figure
subplot(121)
X       = yrs;
Y       = neerslag;
[mu,ci,XI] = pa_weightedmean(X,Y,sigma,xi);
pa_errorpatch(XI',mu',1.96*ci','g');
hold on
% plot(X,Y,'ro','MarkerFaceColor','w');
xlim([1900 2012]);
axis square;
set(gca,'XTick',[1900:10:2010]);
% pa_verline([1917 1921 1940 1945]);
xlabel('Jaartal');
ylabel('Gemiddelde jaartemperatuur (graden Celsius)');


subplot(122)
boxplot(Y);
axis square
% pa_horline(16,'r-');
% pa_horline(9,'g-');
% pa_horline(2,'b-');
% pa_verline(1920);

%%
% clear all
fname = 'Kerkelijke_gezindte.xls';
[N,T,R] = xlsread(fname);

yrs = T(5:end,1);
yrs = str2double(yrs);

atheist = N(:,7);

figure
plot(yrs,atheist,'ko-','LineWidth',2,'MarkerFaceColor','w');
whos