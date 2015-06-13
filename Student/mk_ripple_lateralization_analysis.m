function mv_ripple_lateralization_analysis(subname)

close all hidden;
% clear all;
if nargin<1
	subname = 'sub1';
end
cd('E:\DATA\Studenten\Maarten');

%% Right ear, right hand
d = dir([subname '_right_right*.mat']);
fnames = {d.name};
[Vrr,Drr,VDrr] = getrt(fnames);

d = dir([subname '_left_left*.mat']);
fnames = {d.name};
[Vll,Dll] = getrt(fnames);

d = dir([subname '_left_right*.mat']);
fnames = {d.name};
[Vlr,Dlr] = getrt(fnames);

d = dir([subname '_right_left*.mat']);
fnames = {d.name};
[Vrl,Drl] = getrt(fnames);

%% Graphics
col = gray(4);
figure;
subplot(121)
Drr.x(1) = 0.5;
Drl.x(1) = 0.5;
Dlr.x(1) = 0.5;
Dll.x(1) = 0.5;
errorbar(Drr.x,Drr.mu,Drr.ci,'ko-','MarkerFaceColor',col(1,:));
hold on
errorbar(Drl.x,Drl.mu,Drl.ci,'ko-','MarkerFaceColor',col(2,:));
errorbar(Dlr.x,Dlr.mu,Dlr.ci,'ko-','MarkerFaceColor',col(3,:));
errorbar(Dll.x,Dll.mu,Dll.ci,'ko-','MarkerFaceColor',col(4,:));
set(gca,'XTick',Drr.x,'XTickLabel',[0 Drr.x(2:end)],'XScale','log');
xlabel('Density (cyc/oct)');
ylabel('Mean reaction time (ms)');
xlim([0.4 9]);
axis square;

subplot(122);
Vrr.x = log2(Vrr.x);
Vrr.x(1) = 0.5;
Vll.x = log2(Vll.x);
Vll.x(1) = 0.5;
Vrl.x = log2(Vrl.x);
Vrl.x(1) = 0.5;
Vlr.x = log2(Vlr.x);
Vlr.x(1) = 0.5;

errorbar(Vrr.x,Vrr.mu,Vrr.ci,'ko-','MarkerFaceColor',col(1,:));
hold on
errorbar(Vrl.x,Vrl.mu,Vrl.ci,'ko-','MarkerFaceColor',col(2,:));
errorbar(Vlr.x,Vlr.mu,Vlr.ci,'ko-','MarkerFaceColor',col(3,:));
errorbar(Vll.x,Vll.mu,Vll.ci,'ko-','MarkerFaceColor',col(4,:));

set(gca,'XTick',Vrr.x,'XTickLabel',[0 2.^Vrr.x(2:end)]);
xlabel('Velocity (Hz)');
ylabel('Mean reaction time (ms)');
% xlim([0.9 9]);
xlim([log2(1) log2(128)]);
axis square;
legend({'Right ear, right hand';'Right ear, left hand';'Left ear, right hand';'Left ear, left hand'});

function [V,D,VD] = getrt(fnames)

nfiles = numel(fnames);
P = struct([]);
for ii = 1:nfiles
	fname = fnames{ii};
	load(fname);
	P(ii).lat		= Q.lat;
	P(ii).velocity	= Q.velocity;
	P(ii).density	= Q.density;
end

velocity	= [P.velocity];
density		= [P.density];
lat			= [P.lat]*1000; % ms

%% Selection: reaction time
sel			= lat>100 & lat<1500;
lat			= lat(sel);
velocity	= velocity(sel);
density		= density(sel);

% sel = lat>median(lat)-2*std(lat) & lat<median(lat)+2*std(lat);
% lat			= lat(sel);
% velocity	= velocity(sel);
% density		= density(sel);

% x = 1:numel(lat);
% plot(x,lat,'k-');
% hold on
% plot(x,smooth(lat,50),'r-','LineWidth',2);

% return
% %% graphics
% figure(666)
% subplot(221)
% hist(lat,0:10:10000);
% axis square;
% xlabel('Reaction time (ms)');
% ylabel('N');
% xlim([0 1000]);
% str = ['Right ear, right hand, RT = ' num2str(round(mean(lat))) ' \pm ' num2str(round(1.96*std(lat)./sqrt(numel(lat)))) ' ms'];
% title(str);

%% Reaction time per ripple
uvel			= unique(velocity);
nvel			= numel(uvel);
udens			= unique(density);
ndens			= numel(udens);

RT = NaN(nvel,ndens);
ciRT = RT;
for ii = 1:nvel
	for jj = 1:ndens
		sel			= velocity == uvel(ii) & density == udens(jj);
		RT(ii,jj)	= nanmean(lat(sel));
		ciRT(ii,jj)	= 1.96*nanstd(lat(sel))./sqrt(sum(sel));
	end
end
VD.v = uvel;
VD.d = udens;

VD.mu = RT;
VD.ci = ciRT;

% %%
% subplot(222)
% imagesc(udens,uvel,RT)
% set(gca,'YTick',uvel,'XTick',udens);
% % set(gca,'Yscale','log','Xscale','log');
% axis square
% colorbar
% caxis([200 500])


muRT = NaN(ndens,1);
ciRT = muRT;
for jj = 1:ndens
	sel			= density == udens(jj);
	muRT(jj)	= nanmean(lat(sel));
	n			= sum(sel);
	ciRT(jj)	= 1.96*nanstd(lat(sel))./sqrt(n);
end
D.x = udens;
D.mu = muRT;
D.ci = ciRT;

% subplot(223)
% errorbar(udens,muRT,ciRT,'ko-','MarkerFaceColor','w');
% set(gca,'XTick',udens,'XTickLabel',udens,'XScale','log');
% xlabel('Density (cyc/oct)');
% ylabel('Mean reaction time (ms)');
% xlim([0.9 9]);
% axis square;

muRT = NaN(nvel,1);
ciRT = muRT;
for jj = 1:nvel
	sel			= abs(velocity) == abs(uvel(jj));
	muRT(jj)	= nanmean(lat(sel));
	n			= sum(sel);
	ciRT(jj)	= 1.96*nanstd(lat(sel))./sqrt(n);
end
sel = uvel>=0;
uvel = uvel(sel);
muRT = muRT(sel);
ciRT = ciRT(sel);
% subplot(224)
% sgn = sign(uvel);
% x = sgn.*log2(abs(uvel));
% % x = uvel;
% errorbar(x,muRT,ciRT,'ko-','MarkerFaceColor','w');
% set(gca,'XTick',x,'XTickLabel',uvel);
% xlabel('Velocity (Hz)');
% ylabel('Mean reaction time (ms)');
% % xlim([0.9 9]);
% axis square;

V.x = uvel;
V.mu = muRT;
V.ci = ciRT;
