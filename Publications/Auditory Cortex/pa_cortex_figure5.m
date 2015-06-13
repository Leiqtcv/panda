function pa_cortex_RTandFR
close all hidden
clear all

cd('E:\DATA\Test');

load AllInfo2

x = -200:100:800;
subplot(222);
plotrt3(RP500,x,[.5 .5 .5],0,'s');
hold on
plotrt3(RP1000,x,[1 0 0],0,'d');
axis square
box off
xlabel('Reaction time (ms)');
ylabel('Firing rate difference (spikes/s)')
set(gca,'XTick',-400:200:800);
ylim([-5 25]);
xlim([-400 800])
pa_horline(0,'k-');
pa_verline(0,'k-');
pa_text(0.1,0.9,'B');


x = -200:100:800;
subplot(224);
plotrt3(RA500,x,[.5 .5 .5],0,'s');
hold on
plotrt3(RA1000,x,[1 0 0],0,'d');
axis square
box off
xlabel('Reaction time (ms)');
ylabel('Firing rate difference (spikes/s)')
set(gca,'XTick',-400:200:800);
ylim([-5 25]);
xlim([-400 800])
pa_horline(0,'k-');
pa_verline(0,'k-');
pa_text(0.1,0.9,'D');

%% ripple 500
S = RP500;
n = numel(S);
FR = NaN(n,2400);
for ii = 1:n
	fr = S(ii).FrO;
	FR(ii,:) = fr;
end
x	= (1:2400)-300;
mu	= nanmean(FR);
n	= size(FR,1);
sd	= 1.96*nanstd(FR)./sqrt(n);
sel = x>400 & x<1500;
x	= x(sel);
mu	= mu(sel);
sd	= sd(sel);

subplot(221)
plot(x(1:100:end),mu(1:100:end),'k-','Color',[.5 .5 .5],'LineWidth',2);
hold on
errorbar(x(1:100:end),mu(1:100:end),sd(1:100:end),'ks','MarkerFaceColor',[.5 .5 .5],'LineWidth',2);
rt = [S.rt];
x = 0:50:2000;
N = hist(rt+500,x);
N = 10*N./sum(N);
h = bar(x,N,1);
set(h,'FaceColor',[.5 .5 .5]);
% N = 13*cumsum(N./sum(N))+4;
% plot(x,N,'k-','Color',[.5 .5 .5]);
% return
%% ripple 1000
S = RP1000;
n = numel(S);
FR = NaN(n,1001);
for ii = 1:n
	fr = S(ii).FrO;
	FR(ii,:) = fr;
end

x	= (1:1000)-300+900;
mu	= nanmean(FR);
n = size(FR,1);
sd	= 1.96*nanstd(FR)./sqrt(n);
sel = x>400 & x<1500;
x	= x(sel);
mu	= mu(sel);
sd	= sd(sel);

subplot(221)
plot(x(1:100:end),mu(1:100:end),'k-','Color','r','LineWidth',2);
hold on
errorbar(x(1:100:end),mu(1:100:end),sd(1:100:end),'kd','MarkerFaceColor','r','LineWidth',2);
rt = [S.rt];
x = 0:50:2000;
N = hist(rt+1000,x);
N = 10*N./sum(N);
h = bar(x,-N,1);
set(h,'FaceColor','r');
% N = 13*cumsum(N./sum(N))+4;
% plot(x,N,'k-','Color',[.5 .5 .5]);
axis square
xlim([400 1600]);
ylim([-5 25]);
pa_horline(0,'k-');
pa_verline(500,'k-');
pa_verline(1000,'r-');
pa_text(0.1,0.9,'A');
xlabel('Time re sound onset (ms)');
ylabel('Firing rate difference (spikes/s)');
box off
set(gca,'XTick',500:100:1500);

%% AM 500
S = RA500;
n = numel(S);
FR = NaN(n,1900);
for ii = 1:n
	fr = S(ii).FrO;
	FR(ii,:) = fr;
end
% rv = [S.rv];
% sel = rv>8;
% FR = FR(sel,:);

x	= (1:1900)-300;
mu	= nanmean(FR);
n = size(FR,1);
sd	= 1.96*nanstd(FR)./sqrt(n);
sel = x>400 & x<1500;
x	= x(sel);
mu	= mu(sel);
sd	= sd(sel);

subplot(223)
plot(x(1:100:end),mu(1:100:end),'k-','Color',[.5 .5 .5],'LineWidth',2);
hold on
errorbar(x(1:100:end),mu(1:100:end),sd(1:100:end),'ks','MarkerFaceColor',[.5 .5 .5],'LineWidth',2);

rt = [S.rt];
x = 0:50:2000;
N = hist(rt+500,x);
N = 10*N./sum(N);
h = bar(x,N,1);
set(h,'FaceColor',[.5 .5 .5]);

%% ripple 1000
S = RA1000;
n = numel(S);
FR = NaN(n,1001);
for ii = 1:n
	fr = S(ii).FrO;
	FR(ii,:) = fr;
end

x	= (1:1000)-300+900;
mu	= nanmean(FR);
n = size(FR,1);
sd	= 1.96*nanstd(FR)./sqrt(n);
sel = x>400 & x<1500;
x	= x(sel);
mu	= mu(sel);
sd	= sd(sel);

subplot(223)
plot(x(1:100:end),mu(1:100:end),'k-','Color','r','LineWidth',2);
hold on
errorbar(x(1:100:end),mu(1:100:end),sd(1:100:end),'kd','MarkerFaceColor','r','LineWidth',2);

rt = [S.rt];
x = 0:50:2000;
N = hist(rt+1000,x);
N = 10*N./sum(N);
h = bar(x,-N,1);
set(h,'FaceColor','r');

axis square
xlim([400 1600]);
ylim([-5 25]);
pa_horline(0,'k-');
pa_verline(500,'k-');
pa_verline(1000,'r-');
pa_text(0.1,0.9,'C');
xlabel('Time re sound onset (ms)');
ylabel('Firing rate difference (spikes/s)');
box off


print('-depsc','-painter','figure7rt');

return
%%
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



