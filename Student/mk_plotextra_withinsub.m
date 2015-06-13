function mk_plotextra_withinsub(subname)
% Enter subject of lateralization ripple test
% Plot 

if nargin<1
	subname = 'sub1';
end

[R, ND] = mk_getextra_sub(subname);

%% Plot timecourse reaction time
close all
figure;

subplot(221)
plot(R.rr.x,R.rr.rt,'k-');
hold on
plot(R.rr.x,smooth(R.rr.rt,50),'r-','LineWidth',2);
str = ['Right ear, right hand, RT = ' num2str(round(mean(R.rr.rt))) ' \pm ' num2str(round(1.96*std(R.rr.rt)./sqrt(numel(R.rr.rt)))) ' ms'];
title(str);

subplot(222)
plot(R.rl.x,R.rl.rt,'k-');
hold on
plot(R.rl.x,smooth(R.rl.rt,50),'r-','LineWidth',2);
str = ['Right ear, left hand, RT = ' num2str(round(mean(R.rl.rt))) ' \pm ' num2str(round(1.96*std(R.rl.rt)./sqrt(numel(R.rl.rt)))) ' ms'];
title(str);

subplot(223)
plot(R.lr.x,R.lr.rt,'k-');
hold on
plot(R.lr.x,smooth(R.lr.rt,50),'r-','LineWidth',2);
str = ['Left ear, right hand, RT = ' num2str(round(mean(R.lr.rt))) ' \pm ' num2str(round(1.96*std(R.lr.rt)./sqrt(numel(R.lr.rt)))) ' ms'];
title(str);

subplot(224)
plot(R.ll.x,R.ll.rt,'k-');
hold on
plot(R.ll.x,smooth(R.ll.rt,50),'r-','LineWidth',2);
str = ['Left ear, left hand, RT = ' num2str(round(mean(R.ll.rt))) ' \pm ' num2str(round(1.96*std(R.ll.rt)./sqrt(numel(R.ll.rt)))) ' ms'];
title(str);

title(subname)

%% Plot histogram of reaction time
figure;

subplot(221)
hist(R.rr.rt,0:10:10000);
axis square;
xlabel('Reaction time (ms)');
ylabel('N');
xlim([0 1000]);
str = ['Right ear, right hand, Not detected = ' num2str(R.rr.ndt)];
title(str);

subplot(222)
hist(R.rl.rt,0:10:10000);
axis square;
xlabel('Reaction time (ms)');
ylabel('N');
xlim([0 1000]);
str = ['Right ear, left hand, Not detected = ' num2str(R.rl.ndt)];
title(str);

subplot(223)
hist(R.lr.rt,0:10:10000);
axis square;
xlabel('Reaction time (ms)');
ylabel('N');
xlim([0 1000]);
str = ['Left ear, right hand, Not detected = ' num2str(R.lr.ndt)];
title(str);

subplot(224)
hist(R.ll.rt,0:10:10000);
axis square;
xlabel('Reaction time (ms)');
ylabel('N');
xlim([0 1000]);
str = ['Left ear, left hand, Not detected = ' num2str(R.ll.ndt)];
title(str);

title(subname)

%% Plot not detected per ripple
figure;

subplot(221);
imagesc(ND.rr.d,ND.rr.v,ND.rr.ndt);
set(gca,'YTick',ND.rr.v,'XTick',ND.rr.d);
%set(gca,'Yscale','log','Xscale','log');
axis square
colorbar
caxis([0 5])
str = ['Right ear, right hand, Not detected = ' num2str(R.rr.ndt)];
title(str);

subplot(222);
imagesc(ND.rl.d,ND.rl.v,ND.rl.ndt);
set(gca,'YTick',ND.rl.v,'XTick',ND.rl.d);
%set(gca,'Yscale','log','Xscale','log');
axis square
colorbar
caxis([0 5])
str = ['Right ear, left hand, Not detected = ' num2str(R.rl.ndt)];
title(str);

subplot(223);
imagesc(ND.lr.d,ND.lr.v,ND.lr.ndt);
set(gca,'YTick',ND.lr.v,'XTick',ND.lr.d);
%set(gca,'Yscale','log','Xscale','log');
axis square
colorbar
caxis([0 5])
str = ['Left ear, right hand, Not detected = ' num2str(R.lr.ndt)];
title(str);

subplot(224);
imagesc(ND.ll.d,ND.ll.v,ND.ll.ndt);
set(gca,'YTick',ND.ll.v,'XTick',ND.ll.d);
%set(gca,'Yscale','log','Xscale','log');
axis square
colorbar
caxis([0 5])
str = ['Left ear, left hand, Not detected = ' num2str(R.ll.ndt)];
title(str);

title(subname)

end