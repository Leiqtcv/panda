function pa_cortex_RTandFR
close all hidden
clear all

cd('E:\DATA\Test');

load AllInfo2

figure
D1 = plotrt2(RP500,[.5 .5 .5],40);
hold on
rt = [RP1000.rt];
sel = rt>225;
plotrt2(RP1000(sel),'b',0);
sel = rt<225;
D3 = plotrt2(RP1000(sel),'r',-40);

x = 0:0.4:2;
plot(x,D1(:,2)+D3(:,2),'k:','LineWidth',2);


% return
bFR1 = plotrt(RA500,[.5 .5 .5],40);
hold on
rt = [RA1000.rt];
sel = rt>225;
bFR2 = plotrt(RA1000(sel),'b',0);
sel = rt<225;
bFR3 = plotrt(RA1000(sel),'r',-40);

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

print('-depsc','-painter',mfilename);


function [mu,mux] = plotrt3(S,x,col,bias,mrk)
n = numel(S);
FR = NaN(n,701);
for ii = 1:n
	fr = S(ii).Fr;
	FR(ii,:) = fr;
end
rt	= [S.rt];
rv	= [S.rv];

sel = rt<1000;
rt = rt(sel);

FR = FR(sel',:);

muFR = nanmean(FR(:,100:600),2);

%%
hold on
nx = numel(x);
mux = NaN(nx,1);
mu = mux;
se = mux;
for ii = 2:nx-1
	sel = rt>x(ii-1)& rt<=x(ii+1);
	mux(ii) = median(rt(sel));
	mu(ii) = nanmean(muFR(sel));
	se(ii) = nanstd(muFR(sel))./sqrt(sum(sel));
end


plot(mux+bias,mu,'k-','Color',col,'LineWidth',2);
errorbar(mux+bias,mu,se,['k' mrk],'MarkerFaceColor',col,'LineWidth',2);


function D = plotrt2(S,clr,bias)
n = numel(S);
FR = NaN(n,701);
for ii = 1:n
	fr = S(ii).Fr;
	FR(ii,:) = fr;
end

rd	= abs([S.rd]);
rt	= [S.rt];
rv	= [S.rv];


sel = rt<1000;
rt = rt(sel);
rd = rd(sel);
rv = rv(sel);
FR = FR(sel',:);

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
	Dsd(ii)		= 1.96*std(nanmean(FR(sel,100:600)))./sqrt(sum(sel));
	D(ii,:)		= prctile(nanmean(FR(sel,100:600)),[25 50 75]);
end
% help ano
%%
% close all hidden
% f = nanmean(FR,2);
% whos f rd
% anovan(f,{rd,rt},'model','interaction')
% 
% %%
% keyboard
subplot(223)
mu = RT(1,2);
RT(:,2) = RT(:,2)-mu+bias;
plot(urd,RT(:,2),'k-','LineWidth',2,'Color',clr);
hold on
errorbar(urd,RT(:,2),RTsd,'ko','LineWidth',2,'MarkerFaceColor',clr);
xlim([-0.4 2.4]);
set(gca,'XTick',urd,'XTickLabel',urd);
text(urd(1),RT(1,2),num2str(round(mu)));
box off
axis square;
xlabel('Ripple density (cyc/oct)');
ylabel('reaction time (ms)');
pa_horline(bias,'k:');


subplot(224)
plot(urd,D(:,2),'k-','LineWidth',2,'Color',clr);
hold on
errorbar(urd,D(:,2),Dsd,'ko','LineWidth',2,'MarkerFaceColor',clr);
xlim([-0.4 2.4]);
% xlim([1 256*2]);
set(gca,'XTick',urd,'XTickLabel',urd);
box off
axis square;
xlabel('Ripple density (cyc/oct)');
ylabel('Firing rate (spikes/s)');
ylim([0 20]);
set(gca,'YTick',0:5:20);

function bFR = plotrt(S,clr,bias)
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
end



subplot(221)
mu = RT(end,2);
RT(:,2) = RT(:,2)-mu+bias;
x = 1./umf;
y = RT(:,2);
b = regstats(y,x);
y = b.beta(2).*x+b.beta(1);
plot(umf,y,'k-','Color',clr,'LineWidth',2);
hold on
errorbar(umf,RT(:,2),RTsd,'ko','MarkerFaceColor','w','LineWidth',1,'MarkerFaceColor',clr);
xlim([1 256*2]);
text(umf(end),RT(end,2),num2str(round(mu)));
set(gca,'XScale','log','XTick',umf,'XTickLabel',round(umf));
box off
axis square;
xlabel('Modulation frequency (Hz)');
ylabel('reaction time (ms)');
pa_horline(bias,'k:');


subplot(222)
x = 1./umf;
y = D(:,2);
b = regstats(y,x);
bFR = b; 
hold on

errorbar(umf,D(:,2),Dsd,'ko','MarkerFaceColor','w','LineWidth',1,'MarkerFaceColor',clr);
hold on
xlim([1 256*2]);
set(gca,'XScale','log','XTick',umf,'XTickLabel',round(umf));
box off
axis square;
xlabel('Modulation frequency (Hz)');
ylabel('Firing rate (spikes/s)');
ylim([0 20]);
set(gca,'YTick',0:5:20);



