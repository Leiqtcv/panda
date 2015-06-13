function nn_bayes1_MAP
home;
close all;

%% Generative model

% cd('E:\MATLAB');
pa_datadir;
load AVpar2
figure(1)
subplot(241)
A = Vision(1).SupSac(:,23);
E = Vision(1).SupSac(:,24);
for ii = 1:4
    a = Audiovisual(ii).SupSac(:,23);
    A = [A;a];
    
    e = Audiovisual(ii).SupSac(:,24);
    E = [E;e];
    
    a = Audition(ii).SupSac(:,23);
    A = [A;a];
    e = Audition(ii).SupSac(:,24);
    E = [E;e];
end
A = [A;E];
x	= -80:1:80;
mu	= mean(A);
sd	= std(A)
Y	= normpdf(x,mu,sd);
Y	= Y./max(Y);
pa_stairspatch(x,Y,'Color','k');
hold on
N	= hist(A,x);
N	= N./max(N);
sel = N>0;
% stem(x(sel),N(sel),'k-');
bar(x(sel),N(sel),'k')
axis square;
box off
xlabel('Target location');
ylabel('P');
xlim([-40 40]);

% return
box off
set(gca,'XTick',0,'YTick',[]);
axis square
axis([-70 70 0 1.1]); 
xlabel('S (deg)');
ylabel({'Probability'})
title({'Prior distribution over location';'P_e(S)'})
pa_horline(0.01,'k-');

s		= -70:70;
x		= -70:70;
sigma_p	= 12;
sigma_x	= 15;
S		= 25; % actual location
ps		= normpdf(s,0,sigma_p);
pxs		= normpdf(x,S,sigma_x);

subplot(245)
h = patch(x,pxs,'k');
hold on
alpha(h,0.3);
box off
set(gca,'XTick',[0 S],'YTick',[]);
set(gca,'XTickLabel',{'0';'S'});
axis square
axis([-70 70 0 0.05]); 
mx = nanmax(pxs);
plot(S+[0 0],[0 mx],'k--');
plot(S+[0 sigma_x],0.60655*[mx mx],'k-');
text(S+sigma_x/2,0.60655*mx,'\sigma_X','HorizontalAlignment','center','VerticalAlignment','top');
xlabel('Internal representation X (deg)');
ylabel({'Probability'})
title({'Noise distribution';'P(X|S)'})


%% Inference model
figure(1)
s		= -70:70;
x		= -70:70;
sigma_p	= 12;
sigma_s	= 15;
S		= 25; % actual location
ps		= normpdf(s,0,sigma_p);
pxs		= normpdf(s,S,sigma_s);

subplot(242)
h		= patch(s,ps,'k');
hold on
alpha(h,0.3);
box off
set(gca,'XTick',0,'YTick',[]);
axis square
axis([-70 70 0 0.05]); 
xlabel('Hypothesized location S (deg)');
ylabel({'Probability'})
title({'Internal prior';'P_i(S)'})
mx = max(ps);
plot([0 sigma_p],0.60655*[mx mx],'k-');
plot([0 0],[0 mx],'k--');
text(0+sigma_p/2,0.60655*mx,'\sigma_{P_i}','HorizontalAlignment','center','VerticalAlignment','top');
h = pa_horline(0.01,'k-');
set(h,'Color',[.5 .5 .5],'LineWidth',2);
text(0,1.1*mx,'Central','HorizontalAlignment','center');
text(40,0.013,'Uniform','HorizontalAlignment','center');

subplot(246)
h = patch(x,pxs,'k');
hold on
alpha(h,0.3);
box off
set(gca,'XTick',[0 S],'YTick',[]);
set(gca,'XTickLabel',{'0';'X'});
axis square
axis([-70 70 0 0.05]); 
mx = nanmax(pxs);
plot(S+[0 0],[0 mx],'k--');
plot(S+[0 sigma_x],0.60655*[mx mx],'k-');
text(S+sigma_x/2,0.60655*mx,'\sigma_S','HorizontalAlignment','center','VerticalAlignment','top');
xlabel('Hypothesized location S (deg)');
ylabel({'Probability'})
title({'Likelihood';'L(S)'})


a	= sigma_p^2/(sigma_p^2+sigma_s^2);
ssp = sqrt((sigma_p^2*sigma_s^2)/(sigma_p^2+sigma_s^2));
pxo = normpdf(s,a*S,ssp);
subplot(247)
h = patch(x,pxo,'k');
hold on
alpha(h,0.3);
box off
set(gca,'XTick',[0 S],'YTick',[]);
set(gca,'XTickLabel',{'0';'X'});
axis square
axis([-70 70 0 0.05]);
mx = nanmax(pxo);
plot(a*S+[0 0],[0 mx],'k--');
plot(a*S+[0 ssp],0.60655*[mx mx],'k-');
text(a*S+ssp/2,0.60655*mx,'\sigma_{P,L}','HorizontalAlignment','center','VerticalAlignment','top');
xlabel('Hypothesized location S (deg)');
ylabel({'Probability'})
title({'Posterior';'P(S|X)'})

pa_datadir
print('-depsc','-painter',[mfilename '1']);


figure(2)
%% Optimal
x			= 0:600;
sl = 1-cdf('Normal',x,280,40);
sl = sl*25;
sl = sl+5;

%% Dynamic likelihood
subplot(241)
h=plot(x,sl,'k');set(h,'LineWidth',2);
hold on
axis([220 380 0 30]);
box off
% set(gca,'XTick',[],'YTick',[]);
xlabel('Processing time');
ylabel({'Likelihood';'standard deviation'});
axis square;

% return

%% Posterior


sp		= 15;
Sp		= sp^2;
S		= (Sp*sl.^2)./(Sp+sl.^2);
gain	= 1-S/Sp;
sdmap	= sqrt(S);
% gain	= Sp./(Sp+S.^2);
% sdmap	= sqrt( S.^2 ./ (1+S.^2/Sp).^2 );


subplot(243)
plot(x,gain,'k-','LineWidth',2);
hold on
ylim([0 1.2]);
xlim([220 380])
box off
% set(gca,'XTick',[],'YTick',[]);
axis square
xlabel('Reaction time');
ylabel('Response gain');
pa_horline(0,'k--');
pa_horline(1,'k--');

subplot(244)
plot(x,sdmap,'k-','LineWidth',2);
hold on
ylim([0 15]);
xlim([220 380])
box off
% set(gca,'XTick',[],'YTick',[]);
axis square
xlabel('Reaction time');
ylabel('Response standard deviation');

subplot(247)
sel = x>220 & x<380;

plot(sdmap(sel),gain(sel),'k-','LineWidth',2);
hold on
ylim([0 1.2]);
xlim([0 15])
box off
set(gca,'XTick',[],'YTick',[]);
axis square
ylabel('Response gain');
xlabel('Response standard deviation');
pa_horline(0,'k--');
pa_horline(1,'k--');
return
subplot(247)
S		= 0:0.1:2*sp^2;
gain	= Sp./(Sp+S.^2);
sdmap	= sqrt( S.^2 ./ (1+S.^2/Sp).^2 );
plot(sdmap,gain,'k-','LineWidth',2,'Color',[.7 .7 .7]);
hold on
ylim([0 1.2]);
xlim([0 15])
box off
set(gca,'XTick',[],'YTick',[]);
axis square
xlabel('Response gain');
ylabel('Response standard deviation');
pa_horline(0,'k--');
pa_horline(1,'k--');

% plot(sopv,av,'k-','LineWidth',2);
sopv = 0:.1:15;
g = 1-sopv.^2/sp^2;

plot(sopv,g,'k-','LineWidth',2);
hold on
ylim([0 1.2]);
xlim([0 15])
box off
set(gca,'XTick',[],'YTick',[]);
axis square
xlabel('Response gain');
ylabel('Response standard deviation');
pa_horline(0,'k--');
pa_horline(1,'k--');


marc
print('-depsc','-painters',mfilename);

