function MTFgraphsvd
%% Clear
clear all
close all

%% Load  data

getdata([8 9]);
title('Binaural');


subplot(231)
getdata([5 6]);
title('Hearing aid');
subplot(232)
getdata([3 4]);
title('Cochlear implant');
subplot(233)
getdata([8 9]);
title('Bimodal');

subplot(234)
getdata(1);
title('Right ear');
subplot(235)
getdata(2);
title('Left ear');
subplot(236)
getdata(7);
title('Binaural');

pa_datadir;
print('-depsc','-painter',mfilename);

% figure
% 
% subplot(231)
% getdata(5);
% title('Right hearing aid');
% subplot(232)
% getdata(4);
% title('Left cochlear implant');
% subplot(233)
% getdata(8);
% title('Bimodal HA_R, CI_L');
% 
% subplot(234)
% getdata(6);
% title('Left hearing aid');
% subplot(235)
% getdata(3);
% title('Right cochlear implant');
% subplot(236)
% getdata(8);
% title('Bimodal HA_L, CI_R');
% 
% pa_datadir;
% print('-depsc','-painter',[mfilename '2']);
function h = getdata(c)
cd('E:\DATA\Ripple\Daisy');
S = load('ripplevariables_basics');
cond = S.cond;
dens = S.dens;
vel = abs(S.vel);
vel = S.vel;

rt = S.rt;
% unique(S.ds)
%% 
% vel = abs(vel);
sel2 = dens==0 & vel==0;
sel2 = ~sel2;
sel3000 = rt<1500 & rt>150; 
selmn = ismember(cond,c);

sel		= sel3000 & selmn  ; % select all monaural normal-hearing & AM
rt		= rt(sel);
vel		= vel(sel); % pool negative & positive data for now
dens	= dens(sel);
%% Determine mean and std reaction time for every velocity
uvel	= unique(vel);
nvel	= numel(uvel);
udens	= unique(dens);
ndens	= numel(udens);

muRT = NaN(nvel,ndens);
sdRT = NaN(nvel,ndens);
for ii = 1:nvel
	for jj = 1:ndens
		sel = vel == uvel(ii) & dens == udens(jj);
		muRT(ii,jj) = nanmean(1000./rt(sel));
		sdRT(ii,jj) = 1.96*std(1000./rt(sel))./sqrt(sum(sel));
	end
end
muRT(uvel==0,udens==0) = 0;
muRT(isnan(muRT)) = nanmax(muRT(:));

[U,S,V] = svd(muRT);

% subplot(131)
% x = 1:nvel;
% plot(x,-U(:,1),'ko-','MarkerFaceColor','w','LineWidth',2)
% set(gca,'XTick',x,'XTicklabel',uvel);
% axis square;
% xlim([0 nvel+1]);
% 
% subplot(132)
% x = 1:ndens;
% plot(x,-V(:,1),'ko-','MarkerFaceColor','w','LineWidth',2)
% set(gca,'XTick',x,'XTicklabel',udens);
% axis square;
% xlim([0 ndens+1]);
% 
% subplot(133)
% x = diag(S);
% x = 100*x/sum(x);
% stem(x,'k-','MarkerFaceColor','w')
% axis square;
% ylim([0 100]);
S1 = S(1,1);
S = zeros(size(S));
S(1,1) = S1;
muRT = U*S*V';
muRT(uvel==0,udens==0) = 0;

	%% Graphics
for ii = 1:nvel
	muRT(ii,:) = smooth(muRT(ii,:),3);
end
for ii = 1:ndens
	muRT(:,ii) = smooth(muRT(:,ii),3);
end

x = 1:nvel;
xi = 1:.1:nvel;
y = 1:ndens;
yi = 1:.1:ndens;
[x,y] = meshgrid(x,y);
x = x';
y = y';
[xi,yi] = meshgrid(xi,yi);
xi = xi';
yi = yi';
muRT = interp2(x',y',muRT',xi',yi'); muRT = muRT';
hold on

imagesc(muRT'-100);

hold on
contour(muRT',5-pa_oct2bw(1,0:.1:2),'k-');
% set(gca,'XScale','log','YScale','log')
set(gca,'XTick',(1:nvel)*size(muRT,1)/nvel-size(muRT,1)/nvel/2,'XTickLabel',uvel,'YTick',(1:ndens)*size(muRT,2)/ndens-size(muRT,2)/ndens/2,'YTickLabel',udens);
axis square;
caxis([0.8 3.8]-100)
axis([.5 size(muRT,1)+.5 .5 size(muRT,2)+.5]);
xlabel('Velocity (cycles/s)');
ylabel('Density (cycles/oct)');
colormap hsv
% colormap colorcube
% colormap prism