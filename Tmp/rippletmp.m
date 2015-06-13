
close all
clear all

cd('/Users/marcw/DATA/subject0');
d = dir('*.mat');
n = numel(d)
M = struct([]);
for ii = 1:n
	fname = d(ii).name
	
	load(fname)
	
	M = [M Q];
end

whos
lat = [M.latency]*1000;
V = [M.velocity];
D = [M.density];

uV = unique(V);
nV = numel(uV);
uD = unique(D);
nD = numel(uD);

md = NaN(nV,1);
sd = md;
for ii = 1:nV
	sel = V==uV(ii);
	md(ii)= 1./median(1000./lat(sel));
	sd(ii)= 1./std(1000./lat(sel))./sqrt(sum(sel));
	
end


subplot(221)
hist(lat,-1000:10:3000)
% xlim([0 500]);
axis square
box off
xlabel('Reaction time (ms)');
ylabel('N');
set(gca,'TickDir','out');

subplot(212)
plot(1./uV,1./md,'o-','MarkerFaceColor','w')
axis square
box off
set(gca,'XTick',sort(1./uV),'TickDir','out');
xlabel('Modulation period (s)');
ylabel('Promptness');

rt = lat;
rtinv = 1./rt;
subplot(222)
% raw data
x = -1./sort((rt)); % multiply by -1 to mirror abscissa
n = numel(rtinv); % number of data points
y = pa_probit((1:n)./n); % cumulative probability for every data point converted to probit scale
plot(x,y,'k.');
hold on

% quantiles
p		= [1 2 5 10:10:90 95 98 99]/100;
probit	= pa_probit(p);
q		= quantile(rt,p);
q		= -1./q;
xtick	= sort(-1./(150+[0 pa_oct2bw(50,-1:5)])); % some arbitrary xticks

plot(q,probit,'ko','Color','k','MarkerFaceColor','r','LineWidth',2);
hold on
set(gca,'XTick',xtick,'XTickLabel',-1./xtick);
xlim([min(xtick) max(xtick)]);
set(gca,'YTick',probit,'YTickLabel',p*100);
ylim([pa_probit(0.1/100) pa_probit(99.9/100)]);
axis square;
box off
xlabel('Reaction time (ms)');
ylabel('Cumulative probability');
title('Probit ordinate');
set(gca,'TickDir','out');


% print('-dpng','-r300',mfilename);

