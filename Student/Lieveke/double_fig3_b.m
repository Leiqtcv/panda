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
Sacsingle		= Sac(sel,:);


lat		= Sacsingle(:,5);
h		= plotcd(lat);
hold on
set(h(1),'LineStyle','-','Color','k','Marker','none','LineWidth',2);
grid off;

%% Double
fname1 = 'C:\DATA\Double\MW-RM-2010-07-29\MW-RM-2010-07-29-0001';
fname2			= 'C:\DATA\Double\MW-RM-2010-08-06\MW-RM-2010-08-06-0002';
fname3			= 'C:\DATA\Double\MW-RM-2010-08-06\MW-RM-2010-08-06-0004';

[Sac,Stim]		= loadmat([fname1;fname2;fname3]);
Sac				= firstsac(Sac);
sel		= ismember(Stim(:,3),2);
Stim1	= Stim(sel,:);
sel		= ismember(Stim(:,3),3);
Stim2	= Stim(sel,:);
sel				= Stim2(:,11)==100;
Sac				= Sac(~sel,:);

lat		= Sac(:,5);
h		= plotcd(lat);
set(h(1),'LineStyle','-','Color','r','Marker','none','LineWidth',2);
grid off;



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
