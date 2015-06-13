close all 
clear all

% pa_datadir RG-MW-2011-12-02
% load RG-MW-2011-12-02-0008
% 
% SupSac  = pa_supersac(Sac,Stim,2,1);
% K=SupSac(:,12);
% L=SupSac(:,25);
% 
% M=K-L;
% 
% figure (1)
% subplot(221)
% plot(M, 'o')
% % 
% subplot (222)
% theta   = pa_deg2rad(SupSac(:,13));
% rho     = SupSac(:,12);
% subplot(222)
% polar(theta,rho,'k.');
% % 
% 
% figure(2)
% 
% theta1   = pa_deg2rad(SupSac(:,26));
% rho1     = SupSac(:,25);
% % polar(theta1,rho1,'k.');
% subplot(221)
% polar(theta,rho,'k.');
% hold on
% polar(theta1,rho1,'r.');
% 
% subplot(222)
% R=rho1-rho;
% T=theta1-theta;
% polar(T,R,'g.');
% 
% figure(4)
% plot(T,R,'g.');
% axis ([-6 6 -30 30])
% line([0 0],[-30 30],'Color','k')
% line([-6 6],[0 0],'Color','k')
% title ('50 degree')
% 
% pa_datadir RG-MW-2011-12-02
% load RG-MW-2011-12-02-0004
% 
% SupSac  = pa_supersac(Sac,Stim,2,1);
% A=SupSac(:,12);
% B=SupSac(:,25);
% figure(2)
% C=A-B;
% subplot(223)
% plot(C, 'o')
% 
% xlim([0 80])
% 
% subplot (224)
% theta   = pa_deg2rad(SupSac(:,13));
% rho     = SupSac(:,12);
% polar(theta,rho,'k.');
% 
% figure (2)
% % subplot (231)
% % theta   = pa_deg2rad(SupSac(:,13));
% % rho     = SupSac(:,12);
% % polar(theta,rho,'k.');
% % subplot(232)
% theta1   = pa_deg2rad(SupSac(:,26));
% rho1     = SupSac(:,25);
% % polar(theta1,rho1,'k.');
% subplot(223)
% polar(theta,rho,'k.');
% hold on
% polar(theta1,rho1,'r.');
% 
% subplot(224)
% R=rho1-rho;
% T=theta1-theta;
% polar(T,R,'g.');
% 
% figure(3)
% 
% plot(T,R,'g.');
% axis ([-6 6 -30 30])
% line([0 0],[-30 30],'Color','k')
% line([-6 6],[0 0],'Color','k')
% title ('10 degree')





% % % % % % % % % 
pa_datadir RG-MW-2011-12-02
figure (12)
load RG-MW-2011-12-02-0004
SupSac  = pa_supersac(Sac,Stim,2,1);
theta   = (SupSac(:,8));
rho     = SupSac(:,9);

theta1   = (SupSac(:,23));
rho1     = SupSac(:,24);

R=rho1-rho;
T=theta1-theta;

plot(T,R,'g.');
axis ([-90 90 -90 90])
line([0 0],[-90 90],'Color','k')
line([-90 90],[0 0],'Color','k')
title ('10 degree')

    [MU,SD,A] = pa_ellipse(T,R);
    h = pa_ellipseplot(MU,SD,A);
    set(h,'EdgeColor','none','FaceColor','g');

figure (13)

load RG-MW-2011-12-02-0002
SupSac  = pa_supersac(Sac,Stim,2,1);
theta   = (SupSac(:,8));
rho     = SupSac(:,9);

theta1   =(SupSac(:,23));
rho1     = SupSac(:,24);

R=rho1-rho;
T=theta1-theta;

plot(T,R,'g.');
axis ([-90 90 -90 90])
line([0 0],[-90 90],'Color','k')
line([-90 90],[0 0],'Color','k')
title ('30 degree')

    [MU,SD,A] = pa_ellipse(T,R);
    h = pa_ellipseplot(MU,SD,A);
    set(h,'EdgeColor','none','FaceColor','g');

figure (14)
load RG-MW-2011-12-02-0008
SupSac  = pa_supersac(Sac,Stim,2,1);
theta   = (SupSac(:,8));
rho     = SupSac(:,9);

theta1   = (SupSac(:,23));
rho1     = SupSac(:,24);

R=rho1-rho;
T=theta1-theta;

plot(T,R,'g.');
axis ([-90 90 -90 90])
line([0 0],[-90 90],'Color','k')
line([-90 90],[0 0],'Color','k')
title ('50 degree')

    [MU,SD,A] = pa_ellipse(T,R);
    h = pa_ellipseplot(MU,SD,A);
    set(h,'EdgeColor','none','FaceColor','g');
    
    
figure (15)
clear all
load SS10M
SupSac  = SSM;
theta   = (SupSac(:,8));
rho     = SupSac(:,9);

theta1   = (SupSac(:,23));
rho1     = SupSac(:,24);

R=rho1-rho;
T=theta1-theta;

plot(T,R,'g.');
axis ([-90 90 -90 90])
line([0 0],[-90 90],'Color','k')
line([-90 90],[0 0],'Color','k')
title ('10 degree combined')

    [MU,SD,A] = pa_ellipse(T,R);
    h = pa_ellipseplot(MU,SD,A);
    set(h,'EdgeColor','none','FaceColor','g');
    
figure (16)
clear all
load SS30M
SupSac  = SSM;
theta   = (SupSac(:,8));
rho     = SupSac(:,9);

theta1   = (SupSac(:,23));
rho1     = SupSac(:,24);

R=rho1-rho;
T=theta1-theta;

plot(T,R,'g.');
axis ([-90 90 -90 90])
line([0 0],[-90 90],'Color','k')
line([-90 90],[0 0],'Color','k')
title ('30 degree combined')

    [MU,SD,A] = pa_ellipse(T,R);
    h = pa_ellipseplot(MU,SD,A);
    set(h,'EdgeColor','none','FaceColor','g');
    
    
    
figure (17)
clear all
load SS50M
SupSac  = SSM;
theta   = (SupSac(:,8));
rho     = SupSac(:,9);

theta1   = (SupSac(:,23));
rho1     = SupSac(:,24);

R=rho1-rho;
T=theta1-theta;

plot(T,R,'g.');
axis ([-90 90 -90 90])
line([0 0],[-90 90],'Color','k')
line([-90 90],[0 0],'Color','k')
title ('50 degree combined')

    [MU,SD,A] = pa_ellipse(T,R);
    h = pa_ellipseplot(MU,SD,A);
    set(h,'EdgeColor','none','FaceColor','g');