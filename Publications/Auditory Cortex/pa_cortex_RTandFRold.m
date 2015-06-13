function pa_cortex_RTandFR
close all hidden
clear all

cd('E:\DATA\Test');

load AllInfo
whos 
D1 = plotrt2(RP500,'k','o');
hold on
rt = [RP1000.rt];
sel = rt>225;
D2 = plotrt2(RP1000(sel),'b','s');
sel = rt<225;
D3 = plotrt2(RP1000(sel),'r','d');
x = 0:0.4:2;
whos D1 x
h4 = plot(x,D1(:,2)+D3(:,2),'k:','LineWidth',2);


% return
bFR1 = plotrt(RA500,'k','o');
% return
hold on
rt = [RA1000.rt];
sel = rt>225;
bFR2 = plotrt(RA1000(sel),'b','s');
sel = rt<225;
bFR3 = plotrt(RA1000(sel),'r','d');

x = 2:256;
beta = bFR1.beta;
y1 = beta(2).*(1./x)+beta(1);
beta = bFR2.beta;
y2 = beta(2).*(1./x)+beta(1);
beta = bFR3.beta;
y3 = beta(2).*(1./x)+beta(1);

h1 = plot(x,y1,'k-','LineWidth',2);
h2 = plot(x,y2,'b-','LineWidth',2);
h3 = plot(x,y3,'r-','LineWidth',2);

h4 = plot(x,y1+y3,'k:','LineWidth',2);

legend([h1,h2,h3,h4],{'500','slow','fast','ADD(fast,500)'});
% getdat

for ii = 1:2
	subplot(2,2,(ii-1)*2+2)
	ylim([0 20]);
	
	subplot(2,2,ii)
	xlim([1 256*2]);
	
	subplot(2,2,ii+2)
	xlim([-0.4 2.4]);
end
print('-depsc','-painter',mfilename);

function D = plotrt2(S,clr,mrk)
n = numel(S);
FR = NaN(n,701);
for ii = 1:n
	fr = S(ii).Fr;
	FR(ii,:) = fr;
end

rd	= abs([S.rd]);
rt	= [S.rt];


sel = rt<1000;
rt = rt(sel);
rd = rd(sel);
FR = FR(sel',:);

% for ii = 1:n
% plot(FR(ii,:),'k-')
% drawnow
% title(rt(ii))
% end

%%
urd = unique(rd);
nmf = numel(urd);
RT	= NaN(nmf,3);
D = RT;
RTsd = NaN(nmf,1);
Dsd = RTsd;
for ii = 1:nmf
	sel			= rd == urd(ii);
	RT(ii,:)	= prctile(rt(sel),[25 50 75]);
	RTsd(ii)	= 1.96*std(rt(sel))./sqrt(sum(sel));
	Dsd(ii)		= 1.96*std(nanmean(FR(sel,:)))./sqrt(sum(sel));
	D(ii,:)		= prctile(nanmean(FR(sel,:)),[25 50 75]);
end

% errorbar(umf,RT(:,2),RT(:,2)-RT(:,1),RT(:,3)-RT(:,2),'ko-','MarkerFaceColor','w','LineWidth',1,'Color',clr);
subplot(223)
% RT(:,2) = RT(:,2)-RT(1,2);
hold on
errorbar(urd,RT(:,2),RTsd,[mrk '-'],'MarkerFaceColor','w','LineWidth',1,'Color',clr);
set(gca,'XTick',urd,'XTickLabel',urd);
box off
% h = pa_horline(min(RT(:,2)));
% set(h,'Color',clr)
axis square;

xlabel('Ripple density (cyc/oct)');
ylabel('reaction time (ms)');


subplot(224)
hold on
errorbar(urd,D(:,2),Dsd,[mrk '-'],'MarkerFaceColor','w','LineWidth',1,'Color',clr);
hold on
% plot(umf,D);
set(gca,'XTick',urd,'XTickLabel',urd);
box off
axis square;
xlabel('Ripple density (cyc/oct)');
ylabel('Firing rate (spikes/s)');

function bFR = plotrt(S,clr,mrk)
n = numel(S);
FR = NaN(n,701);
for ii = 1:n
	fr = S(ii).Fr;
	FR(ii,:) = fr;
end

mf	= [S.rv];
rt	= [S.rt];


sel = rt<1000;
rt = rt(sel);
mf = mf(sel);
whos FR sel
FR = FR(sel',:);

% for ii = 1:n
% plot(FR(ii,:),'k-')
% drawnow
% title(rt(ii))
% end

%%
umf = unique(mf);
nmf = numel(umf);
RT	= NaN(nmf,3);
D = RT;
RTsd = NaN(nmf,1);
Dsd = RTsd;
for ii = 1:nmf
	sel			= mf == umf(ii);
	RT(ii,:)	= prctile(rt(sel),[25 50 75]);
	RTsd(ii)	= 1.96*std(rt(sel))./sqrt(sum(sel));
	Dsd(ii)		= 1.96*std(mean(FR(sel,:)))./sqrt(sum(sel));
	D(ii,:)		= prctile(mean(FR(sel,:)),[25 50 75]);
% 	D(ii,2) = mean(mean(FR(sel,:)));
end

% errorbar(umf,RT(:,2),RT(:,2)-RT(:,1),RT(:,3)-RT(:,2),'ko-','MarkerFaceColor','w','LineWidth',1,'Color',clr);
subplot(221)
% RT(:,2) = RT(:,2)-RT(end,2);
x = 1./umf;
y = RT(:,2);
b = regstats(y,x);

y = b.beta(2).*x+b.beta(1);
plot(umf,y,'k-','Color',clr,'LineWidth',2);
hold on
errorbar(umf,RT(:,2),RTsd,mrk,'MarkerFaceColor','w','LineWidth',1,'Color',clr);
set(gca,'XScale','log','XTick',umf(1:2:end),'XTickLabel',round(umf(1:2:end)));
box off
axis square;

xlabel('Modulation frequency (Hz)');
ylabel('reaction time (ms)');


subplot(222)

x = 1./umf;
y = D(:,2);
b = regstats(y,x);
bFR = b;
y = b.beta(2).*x+b.beta(1);
% plot(umf,y,'k-','Color',clr,'LineWidth',2);
hold on

errorbar(umf,D(:,2),Dsd,mrk,'MarkerFaceColor','w','LineWidth',1,'Color',clr);
hold on
% plot(umf,D);
set(gca,'XScale','log','XTick',umf(1:2:end),'XTickLabel',round(umf(1:2:end)));
box off
axis square;
xlabel('Modulation frequency (Hz)');
ylabel('Firing rate (spikes/s)');

% h = pa_horline(min(RT(:,2)));
% set(h,'Color',clr)


