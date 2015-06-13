function mk_audiomotor_analysis
close all
clc

pa_datadir;
cd('Ripple');
subs = [1 2 4 5 6 8 9 10 13 14 15 16 17 18 19 21];
nsubs = numel(subs)
sub = subs(4);
[R,V,ND] = mk_audiomotor_getdata_condition(sub,'left','left');
% [R,V,ND] = mk_audiomotor_getdata_condition(sub,'right','right');

%% Plot effect of static duration
figure(1)
plot(R.dur,R.rt,'ko-')
set(gca, 'XTick',R.dur);
ylabel('Mean reaction Time (ms)','fontsize',16);
xlabel('Static Duration','fontsize',16);
title('Effect of static duration','fontsize',16);

%% Plot timecourse reaction time
figure(2)
subplot(211)
plot(R.x50,R.rt50,'k-');
% hold on
% plot(R.x50,smooth(R.rt50,50),'r-','LineWidth',2);
str = ['Modulationdepth = 50; RT = ' num2str(round(V.smu50)) ' \pm ' num2str(round(V.sse50)) ' ms'];
ylim([200 1200]);
ylabel('Reaction Time (ms)','fontsize',16);
xlabel('Trial number','fontsize',16);
title(str,'fontsize',16);
subplot(212)
plot(R.x100,R.rt100,'k-');
% hold on
% plot(R.x100,smooth(R.rt100,50),'r-','LineWidth',2);
str = ['Modulationdepth = 100; RT = ' num2str(round(V.smu100)) ' \pm ' num2str(round(V.sse100)) ' ms'];
ylim([200 1200]);
ylabel('Reaction Time (ms)','fontsize',16);
xlabel('Trial number','fontsize',16);
title(str,'fontsize',16);

%% Plot histogram of reaction time
figure(3)
subplot(121)
hist(R.rt50,0:10:10000);
axis square;
xlabel('Reaction time (ms)','fontsize',16);
ylabel('N','fontsize',16);
xlim([0 1000]);
title('Modulationdepth = 50','fontsize',16);
subplot(122)
hist(R.rt100,0:10:10000);
axis square;
xlabel('Reaction time (ms)','fontsize',16);
ylabel('N','fontsize',16);
xlim([0 1000]);
title('Modulationdepth = 100','fontsize',16);

%% Plot not detected
col = cool(4);

figure(4)
subplot(121)
plot(V.v, ND.ndt(1,:),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(1,:))
hold on
plot(V.v, ND.ntr(1,:),'ro')
% set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Not detected','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
axis square
title('Not Detected; Modulationdepth = 50;','fontsize',16);
subplot(122)
plot(V.v, ND.ndt(2,:),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(2,:))
hold on
plot(V.v, ND.ntr(2,:),'ro')
% set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Not detected','fontsize',16);
xlabel('Velocity (Hz)','fontsize',16);
axis square
title('Not Detected; Modulationdepth = 100','fontsize',16);

%% Plot mean rt
figure(5)
errorbar(abs(1./V.v(1:10)),V.mu(1,1:10),V.se(1,1:10),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(1,:));
hold on
errorbar(1./V.v(11:19),V.mu(1,11:19),V.se(1,11:19),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(2,:));
hold on
errorbar(abs(1./V.v(1:10)),V.mu(2,1:10),V.se(2,1:10),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(3,:));
hold on
errorbar(1./V.v(11:19),V.mu(2,11:19),V.se(2,11:19),'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(4,:));
% set(gca, 'XTick',[-64 -42.667 -21.333 0 21.333 42.667 64],'XTickLabel',[vel(1) vel(3) vel(5) vel(7) vel(9) vel(11) vel(13)],'fontsize',14);
ylabel('Reaction Time (ms)','fontsize',16);
xlabel('Modulation frequency (Hz)','fontsize',16);
legend({'md = 50, -', 'md = 50, +', 'md = 100, -', 'md = 100, +'},'Location','NW');
% axis square
% set(gca,'XScale','log');

vel = unique(abs(V.v));
uperiod = 1./vel;
[uperiod,indx] = sort(uperiod);
vel = vel(indx);
set(gca,'XTick',uperiod,'XTickLabel',vel);
ylim([0 1000]);