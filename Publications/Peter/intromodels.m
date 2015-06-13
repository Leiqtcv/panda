function tmp
%% Clean
close all
clear all

x = 0:1/3:3;
fc = pa_oct2bw(1600,x);
f0 = 1600;
p = 25;
t = 6;
w = 0.002;
g = abs(fc-f0)/f0;
W = (1-w)*(1+p*g).*exp(-p*g)+w*(1+t*g).*exp(-t*g);

%% Cochlear
subplot(121)
semilogx(fc,W,'k:')
hold on

%% FcTs
p = 1.5;
t = 6;
w = 0.2;
g = abs(fc-f0)/f0;
W = (1-w)*(1+p*g).*exp(-p*g)+w*(1+t*g).*exp(-t*g);

semilogx(fc,W,'b-','LineWidth',2)
semilogx(fc,W,'k^','MarkerFaceColor','b','LineWidth',2)

%% FrTa
p = 5;
t = 6;
w = 0.2;
g = abs(fc-f0)/f0;
W = (1-w)*(1+p*g).*exp(-p*g)+w*(1+t*g).*exp(-t*g);

semilogx(fc,W,'r-','LineWidth',2)
semilogx(fc,W,'ks','MarkerFaceColor','r','LineWidth',2)

%% Temporal dominance
semilogx(fc,ones(size(fc)),'k-','LineWidth',2);

%%
box off
x = -3:1/3:3;
f = pa_oct2bw(1600,x);
f = round(f);
set(gca,'XTick',f,'XTickLabel',x,'TickDir','out','YTick',[0 1]);
xlim([f0 6400]);
ylim([-0.1 1.1])
axis square
xlabel('Protected band (oct)');
ylabel('Fusion (au)');
title('Coherence')




x = 0:1/3:3;
fc = pa_oct2bw(1600,x);
f0 = 1600;
p = 25;
t = 6;
w = 0.002;
g = abs(fc-f0)/f0;
W = (1-w)*(1+p*g).*exp(-p*g)+w*(1+t*g).*exp(-t*g);

%% Cochlear
subplot(122)
semilogx(fc,W,'k:')
hold on

%% FcTs
p = 1.5;
t = 6;
w = 0.2;
g = abs(fc-f0)/f0;
W = (1-w)*(1+p*g).*exp(-p*g)+w*(1+t*g).*exp(-t*g);

semilogx(fc,W,'r-','LineWidth',2)
semilogx(fc,W,'ks','MarkerFaceColor','r','LineWidth',2)

%% FrTa
p = 5;
t = 6;
w = 0.2;
g = abs(fc-f0)/f0;
W = (1-w)*(1+p*g).*exp(-p*g)+w*(1+t*g).*exp(-t*g);

semilogx(fc,W,'b-','LineWidth',2)
semilogx(fc,W,'k^','MarkerFaceColor','b','LineWidth',2)

%% Temporal dominance
semilogx(fc,ones(size(fc)),'k-','LineWidth',2);

%%
box off
x = -3:1/3:3;
f = pa_oct2bw(1600,x);
f = round(f);
set(gca,'XTick',f,'XTickLabel',x,'TickDir','out','YTick',[0 1]);
xlim([f0 6400]);
ylim([-0.1 1.1])
axis square
xlabel('Protected band (oct)');
ylabel('Fusion (au)');
title('Uncertainty')


pa_datadir
print('-depsc',mfilename);