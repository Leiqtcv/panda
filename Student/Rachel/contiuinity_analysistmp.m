close all
clear all

cd('E:\DATA\Test\Continuity');
fname1 = 'MW-MW-2014-07-17-0002';
fname2 = 'MW-MW-2014-07-17-0003';

cd('E:\DATA\Test\Continuity\MW-RG-2014-07-30');
fname1 = 'MW-RG-2014-07-30-0001';
fname2 = 'MW-RG-2014-07-30-0002';



load(fname1);
SupSac = pa_supersac(Sac,Stim,2,1);
id = pa_supersac(Sac,Stim,3,1);
id = id(:,30);
uid1 = unique(id);
nid1 = numel(uid1);
col = jet(nid1);
figure(1)
subplot(121)
for ii = 1:nid1
	sel = id==uid1(ii);
	x = SupSac(sel,24);
	y = SupSac(sel,9);
	plot(x,y,'ko','MarkerFaceColor',col(ii,:));
	hold on
	
	b(ii) = regstats(y,x,'linear','beta');
	G(ii) = b(ii).beta(2);
end
axis([-90 90 -90 90]);
axis square
set(gca,'TickDir','out');
box off

figure(2)
mx = max(G);
G = G./mx;
plot(0:0.25:1,G,'ko-','MarkerFaceColor','w','LineWidth',2);
hold on
xlim([-0.25 1.25]);
ylim([-0.1 1.1]);
axis square
set(gca,'TickDir','out');
box off

%%
load(fname2);
SupSac = pa_supersac(Sac,Stim,2,1);
id = pa_supersac(Sac,Stim,3,1);
id = id(:,30);
uid1 = unique(id);
nid1 = numel(uid1);
col = jet(nid1);
figure(1)
subplot(122)
for ii = 1:nid1
	sel = id==uid1(ii);
	x = SupSac(sel,24);
	y = SupSac(sel,9);
	plot(x,y,'ko','MarkerFaceColor',col(ii,:));
	hold on
	
	b(ii) = regstats(y,x,'linear','beta');
	G(ii) = b(ii).beta(2);
end
axis([-90 90 -90 90]);
axis square
set(gca,'TickDir','out');
box off

figure(2)
% mx = max(G);
G = G./mx;
plot(0:0.25:1,G,'ko-','MarkerFaceColor','w','LineWidth',2);
xlim([-0.25 1.25]);
ylim([-0.1 1.1]);
axis square
set(gca,'TickDir','out');
box off

xlabel('Decrease in Sound level of Noise');
ylabel('Target localization gain');

title('Spatial continuity?');

print('-depsc','-painter',mfilename);