function mk_plotrt_withinsub(subname)
% Enter subject of lateralization ripple test
% Plot mean reaction time per velocity
% Plot mean reaction time per density
% Plot mean reaction per ripple for each protocol apart
close all
if nargin<1
	subname = 'sub1';
end

[V,D,VD] = mk_getrt_sub(subname);

%% Plot mean rt per density
col = gray(4);
figure;
subplot(321)
% 0.5 = density 0
D.rr.x(1) = 0.5;
D.rl.x(1) = 0.5;
D.lr.x(1) = 0.5;
D.ll.x(1) = 0.5;

errorbar(D.rr.x,D.rr.mu,D.rr.ci,'ko-','MarkerFaceColor',col(1,:));
hold on
errorbar(D.rl.x,D.rl.mu,D.rl.ci,'ko-','MarkerFaceColor',col(2,:));
errorbar(D.lr.x,D.lr.mu,D.lr.ci,'ko-','MarkerFaceColor',col(3,:));
errorbar(D.ll.x,D.ll.mu,D.ll.ci,'ko-','MarkerFaceColor',col(4,:));
set(gca,'XTick',D.rr.x,'XTickLabel',[0 D.rr.x(2:end)],'XScale','log');
xlabel('Density (cyc/oct)');
ylabel('Mean reaction time (ms)');
xlim([0.4 9]);
axis square;
title('mean rt per density')

%% Plot mean rt per velocity
subplot(322);

% 0.5 = velocity 0
V.rr.x = log2(V.rr.x);
V.rr.x(1) = 0.5;
V.ll.x = log2(V.ll.x);
V.ll.x(1) = 0.5;
V.rl.x = log2(V.rl.x);
V.rl.x(1) = 0.5;
V.lr.x = log2(V.lr.x);
V.lr.x(1) = 0.5;

errorbar(V.rr.x,V.rr.mu,V.rr.ci,'ko-','MarkerFaceColor',col(1,:));
hold on
errorbar(V.rl.x,V.rl.mu,V.rl.ci,'ko-','MarkerFaceColor',col(2,:));
errorbar(V.lr.x,V.lr.mu,V.lr.ci,'ko-','MarkerFaceColor',col(3,:));
errorbar(V.ll.x,V.ll.mu,V.ll.ci,'ko-','MarkerFaceColor',col(4,:));

set(gca,'XTick',V.rr.x,'XTickLabel',[0 2.^V.rr.x(2:end)]);
xlabel('Velocity (Hz)');
ylabel('Mean reaction time (ms)');
xlim([log2(1) log2(128)]);
axis square;
title('mean rt per velocity')
legend({'Right ear, right hand';'Right ear, left hand';'Left ear, right hand';'Left ear, left hand'});

%% Plot mean rt per ripple
subplot(323);
imagesc(VD.rr.d,VD.rr.v,VD.rr.mu);
set(gca,'YTick',VD.rr.v,'XTick',VD.rr.d);
%set(gca,'Yscale','log','Xscale','log');
axis square
colorbar
caxis([200 500])
title('Right ear, right hand')

subplot(324);
imagesc(VD.rl.d,VD.rl.v,VD.rl.mu);
set(gca,'YTick',VD.rl.v,'XTick',VD.rl.d);
%set(gca,'Yscale','log','Xscale','log');
axis square
colorbar
caxis([200 500])
title('Right ear, left hand')

subplot(325);
imagesc(VD.lr.d,VD.lr.v,VD.lr.mu);
set(gca,'YTick',VD.lr.v,'XTick',VD.lr.d);
%set(gca,'Yscale','log','Xscale','log');
axis square
colorbar
caxis([200 500])
title('Left ear, right hand')

subplot(326);
imagesc(VD.ll.d,VD.ll.v,VD.ll.mu);
set(gca,'YTick',VD.ll.v,'XTick',VD.ll.d);
%set(gca,'Yscale','log','Xscale','log');
axis square
colorbar
caxis([200 500])
title('Left ear, left hand')

% supertitle(subname)
end

