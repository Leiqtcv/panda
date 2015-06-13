function tmp
close all
clear all
clc
%% Single Sounds


% fname1			= 'C:\DATA\Double\DB-MW-2010-07-27\DB-MW-2010-07-27-0001';
fname1 = 'C:\DATA\Double\MW-RM-2010-07-29\MW-RM-2010-07-29-0001';
fname2			= 'C:\DATA\Double\MW-RM-2010-08-06\MW-RM-2010-08-06-0002';
fname3			= 'C:\DATA\Double\MW-RM-2010-08-06\MW-RM-2010-08-06-0004';

[Sac,Stim]		= loadmat([fname1;fname2;fname3]);
sel				= ismember(Stim(:,3),2);
Stim1			= Stim(sel,:);
sel				= ismember(Stim(:,3),3);
Stim2			= Stim(sel,:);

sel				= Stim2(:,11)==100;
Stimsingle		= Stim1(sel,:);
Sacsingle		= Sac(sel,:);

% speakers		= [130 120; 131 120;131 108;130 108;131 130;120 108];
speakers		= [130 120; 131 120;130 108;131 108];

% Sacsingle(:,9) = Sacsingle(:,9)-20;
dat		= getdat(Sacsingle,Stimsingle);

Tar = Stimsingle(:,[4 5]);
uTar = unique(Tar,'rows');
[m,n] = size(uTar);
c		= colormap('hot');
indx	= round(linspace(8,56,m));
c		= c(indx,:);

for ii = 1:m
	sel		= Tar(:,1)==uTar(ii,1) & Tar(:,2)==uTar(ii,2);
	dat_spk	= dat(sel,:);
	subplot(122)
	h = draw_sp(1);set(h,'EdgeColor','k');
	h = plot_sp(dat_spk(:,[3:4]),'k.',5);set(h,'Color',c(ii,:));
% 	h = plot_sp(dat_spk(1,[1:2]),'kh',5);set(h,'Color','k','MarkerFaceColor',c(ii,:),'MarkerSize',10);
	[G, kappa, beta, q, ellz, ell, ln, iskent]=kent_sp(dat_spk(:,[3,4]));
% 	plot_sp(ln(1,:),'k.',15);
% 	line_sp([dat_spk(1,[1,2]); ln(1,:)],5,'m-');
	h = line_sp(ell,2,'k-',c(ii,:));set(h,'LineWidth',5,'Color',c(ii,:));
% 	line_sp(ln,2,'k-');
	axis square
	
end
subplot(221)
bubblegraph(dat(:,1),dat(:,3));
axis square
box off
set(gca,'XTick',-50:25:50,'YTick',-50:25:50);
set(gca,'XTickLabel',[],'YTickLabel',[]);

subplot(223)
bubblegraph(dat(:,2),dat(:,4));
axis square
box off
set(gca,'XTick',-50:25:50,'YTick',-50:25:50);
xlabel('Target (deg)');
ylabel('Response (deg)');
str = 'Listener MW';
text(50,-50,str,'HorizontalAlignment','right');

marc
print(mfilename,'-depsc2','-painter');




function dat = getdat(Sac,Stim)
[X,Y,Z]	= azel2cart(Stim(:,4),Stim(:,5));
[X,Y,Z] = pitch(X,Y,Z,90);
[X,Y,Z] = yaw(X,Y,Z,-90);
[T]		= cart2hp([X,Y,Z]);
[X,Y,Z]	= azel2cart(Sac(:,8),Sac(:,9));
[X,Y,Z] = pitch(X,Y,Z,90);
[X,Y,Z] = yaw(X,Y,Z,-90);
[R]		= cart2hp([X,Y,Z]);
dat		= [T R];
