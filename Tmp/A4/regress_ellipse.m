% function regress_ellipse
%% PP: RG, RG2, MW, MW2, HH, HH2, HHall, RO, RO2, RO3, ROall LJ, LJ2, LJ3, LJall
%% Initialization
close all
clear all


subject = 'HHall';

switch subject
    
case 'RG'
        pa_datadir MW-RG-2011-12-08
        %% 10 deg condition
        load('MW-RG-2011-12-08-0004');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('MW-RG-2011-12-08-0007');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        load('MW-RG-2011-12-08-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('MW-RG-2011-12-08-0001');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        load('MW-RG-2011-12-08-0005');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('MW-RG-2011-12-08-0006');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        load('MW-RG-2011-12-08-0003');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('MW-RG-2011-12-08-0008');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;    
        
        
case 'RG2'
            pa_datadir MW-RG-2012-01-11
        %% 10 deg condition
        load('RG-MW-2012-01-11-0003');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        pa_datadir RG-MW-2012-01-12
        load('RG-MW-2012-01-12-0006');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        pa_datadir RG-MW-2012-01-11
        load('RG-MW-2012-01-11-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        pa_datadir RG-MW-2012-01-12
        load('RG-MW-2012-01-12-0008');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        pa_datadir RG-MW-2012-01-11
        load('RG-MW-2012-01-11-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-MW-2012-01-11-0004');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        pa_datadir RG-MW-2012-01-12
        load('RG-MW-2012-01-12-0005');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-MW-2012-01-12-0007');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;
    
case 'MW'
        %% 10 deg condition
        pa_datadir RG-MW-2011-12-02
        load('RG-MW-2011-12-02-0004');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-MW-2011-12-02-0007');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        load('RG-MW-2011-12-02-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-MW-2011-12-02-0006');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        load('RG-MW-2011-12-02-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-MW-2011-12-02-0003');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        load('RG-MW-2011-12-02-0005');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-MW-2011-12-02-0008');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;
        return
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
        axis ([-40 40 -40 40])
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
        axis ([-40 40 -40 40])
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
        axis ([-40 40 -40 40])
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
        axis ([-40 40 -40 40])
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
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree combined')

        [MU,SD,A] = pa_ellipse(T,R);
        h = pa_ellipseplot(MU,SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        
        
case 'MW2'
            pa_datadir RG-MW-2012-01-11
        %% 10 deg condition
        load('RG-MW-2012-01-11-0003');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        pa_datadir RG-MW-2012-01-12
        load('RG-MW-2012-01-12-0006');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        pa_datadir RG-MW-2012-01-11
        load('RG-MW-2012-01-11-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        pa_datadir RG-MW-2012-01-12
        load('RG-MW-2012-01-12-0008');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        pa_datadir RG-MW-2012-01-11
        load('RG-MW-2012-01-11-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-MW-2012-01-11-0004');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        pa_datadir RG-MW-2012-01-12
        load('RG-MW-2012-01-12-0005');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-MW-2012-01-12-0007');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;


case 'HH'
        pa_datadir RG-HH-2011-12-12
        %% 10 deg condition
        load('RG-HH-2011-12-12-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        load('RG-HH-2011-12-12-0004');
        SupSac1  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        load('RG-HH-2011-12-12-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2011-12-12-0003');
        SupSac2  = pa_supersac(Sac,Stim,2,1);


        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;
        
        
case 'HH2'
            pa_datadir RG-HH-2012-01-09
        %% 10 deg condition
        load('RG-HH-2012-01-09-0003');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-09-0007');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        load('RG-HH-2012-01-09-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-09-0008');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        load('RG-HH-2012-01-09-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-09-0004');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-09-0005');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-09-0006');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        
case 'HHall'

        %% 10 deg condition
        pa_datadir RG-HH-2011-11-24
        load('RG-HH-2011-11-24-0004');
        SupSac1  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-HH-2011-12-12
        load('RG-HH-2011-12-12-0001');
        SupSac3  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-HH-2012-01-09
        load('RG-HH-2012-01-09-0003');
        SupSac5  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-09-0007');
        SupSac6  = pa_supersac(Sac,Stim,2,1);
        

        pa_datadir RG-HH-2012-01-13
        load('RG-HH-2012-01-13-0003');
        SupSac7  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-13-0006');
        SupSac8  = pa_supersac(Sac,Stim,2,1);


        SupSac  = [SupSac1;SupSac3;SupSac5;SupSac6;SupSac7;SupSac8];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;


        %% 30 deg condition
        pa_datadir RG-HH-2011-11-24
        load('RG-HH-2011-11-24-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-HH-2011-12-12
        load('RG-HH-2011-12-12-0004');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-HH-2012-01-09
        load('RG-HH-2012-01-09-0001');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-09-0008');
        SupSac4  = pa_supersac(Sac,Stim,2,1);
        
        pa_datadir RG-HH-2012-01-13
        load('RG-HH-2012-01-13-0001');
        SupSac5  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-13-0007');
        SupSac6  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4;SupSac5;SupSac6];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        pa_datadir RG-HH-2011-11-24
        load('RG-HH-2011-11-24-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2011-11-24-0003');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-HH-2011-12-12
        load('RG-HH-2011-12-12-0002');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2011-12-12-0003');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-HH-2012-01-09
        load('RG-HH-2012-01-09-0002');
        SupSac5  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-09-0004');
        SupSac6  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-09-0005');
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-09-0006');
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        
        pa_datadir RG-HH-2012-01-13
        load('RG-HH-2012-01-13-0002');
        SupSac9  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-13-0004');
        SupSac10  = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-13-0005');
        SupSac11 = pa_supersac(Sac,Stim,2,1);
        load('RG-HH-2012-01-13-0008');
        SupSac12 = pa_supersac(Sac,Stim,2,1);



        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4;SupSac5;SupSac6;SupSac7;SupSac8;SupSac9;SupSac10;SupSac11;SupSac12];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;
        
        
case 'RO'
                pa_datadir RG-RO-2011-12-12
        %% 10 deg condition
        pa_datadir RG-RO-2011-12-12
        load('RG-RO-2011-12-12-0005');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2011-12-12-0003');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        load('RG-RO-2011-12-12-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2011-12-12-0007');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        load('RG-RO-2011-12-12-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2011-12-12-0004');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2011-12-12-0006');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2011-12-12-0008');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;


case 'RO2'
            pa_datadir RG-RO-2012-01-11
        %% 10 deg condition
        load('RG-RO-2012-01-11-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-11-0007');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        load('RG-RO-2012-01-11-0004');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-11-0006');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        load('RG-RO-2012-01-11-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-11-0003');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-11-0005');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-11-0008');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;
            
case 'RO3'
            pa_datadir RG-RO-2012-01-18
        %% 10 deg condition
        load('RG-RO-2012-01-18-0003');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-18-0006');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        load('RG-RO-2012-01-18-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-18-0008');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        load('RG-RO-2012-01-18-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-18-0004');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-18-0005');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-18-0007');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

case 'ROall'

        %% 10 deg condition
        pa_datadir RG-RO-2011-12-12
        load('RG-RO-2011-12-12-0003');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2011-12-12-0005');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-RO-2012-01-11
        load('RG-RO-2012-01-11-0002');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-11-0007');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-RO-2012-01-18
        load('RG-RO-2012-01-18-0003');
        SupSac5  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-18-0007');
        SupSac6  = pa_supersac(Sac,Stim,2,1);
      
        
        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4;SupSac5;SupSac6];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;


        %% 30 deg condition
        pa_datadir RG-RO-2011-12-12
        load('RG-RO-2011-12-12-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2011-12-12-0007');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-RO-2012-01-11
        load('RG-RO-2012-01-11-0004');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-11-0006');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-RO-2012-01-18
        load('RG-RO-2012-01-18-0001');
        SupSac5  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-18-0008');
        SupSac6  = pa_supersac(Sac,Stim,2,1);
        

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4;SupSac5;SupSac6];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        pa_datadir RG-RO-2011-12-12
        load('RG-RO-2011-12-12-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2011-12-12-0004');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2011-12-12-0006');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2011-12-12-0008');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-RO-2012-01-11
        load('RG-RO-2012-01-11-0001');
        SupSac5  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-11-0003');
        SupSac6  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-11-0005');
        SupSac7  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-11-0008');
        SupSac8  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-RO-2012-01-18
        load('RG-RO-2012-01-18-0002');
        SupSac9  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-18-0004');
        SupSac10  = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-18-0005');
        SupSac11 = pa_supersac(Sac,Stim,2,1);
        load('RG-RO-2012-01-18-0006');
        SupSac12 = pa_supersac(Sac,Stim,2,1);
        

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4;SupSac5;SupSac6;SupSac7;SupSac8;SupSac9;SupSac10;SupSac11;SupSac12];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;
        
        
        
case 'LJ'
                pa_datadir RG-LJ-2011-12-14
        %% 10 deg condition
        pa_datadir RG-LJ-2011-12-14
        load('RG-LJ-2011-12-14-0005');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-14-0003');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        load('RG-LJ-2011-12-14-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-14-0006');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        load('RG-LJ-2011-12-14-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-14-0004');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-14-0007');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-14-0008');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

case 'LJ2'
            pa_datadir RG-LJ-2011-12-21
        %% 10 deg condition
        load('RG-LJ-2011-12-21-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-21-0007');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        load('RG-LJ-2011-12-21-0004');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-21-0006');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        load('RG-LJ-2011-12-21-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-21-0003');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-21-0005');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-21-0008');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;


        


case 'LJ3'
            pa_datadir RG-LJ-2012-01-10
        %% 10 deg condition
        load('RG-LJ-2012-01-10-0003');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2012-01-10-0007');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 30 deg condition
        load('RG-LJ-2012-01-10-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2012-01-10-0008');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        SupSac  = [SupSac1;SupSac2];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        load('RG-LJ-2012-01-10-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2012-01-10-0004');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2012-01-10-0005');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2012-01-10-0006');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

case 'LJall'

        %% 10 deg condition
        pa_datadir RG-LJ-2011-12-14
        load('RG-LJ-2011-12-14-0003');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-14-0005');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-LJ-2011-12-21
        load('RG-LJ-2011-12-21-0002');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-21-0007');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-LJ-2012-01-10
        load('RG-LJ-2012-01-10-0003');
        SupSac5  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2012-01-10-0007');
        SupSac6  = pa_supersac(Sac,Stim,2,1);
        
        pa_datadir RG-LJ-2012-01-17
        load('RG-LJ-2012-01-17-0004');
        SupSac7  = pa_supersac(Sac,Stim,2,1);


        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4;SupSac5;SupSac6; SupSac7];
        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(231)
        plot(res_az,res_el,'g.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('10 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','g');
        axis square;

        subplot(234)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'g.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'g-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;


        %% 30 deg condition
        pa_datadir RG-LJ-2011-12-14
        load('RG-LJ-2011-12-14-0001');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-14-0006');
        SupSac2  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-LJ-2011-12-21
        load('RG-LJ-2011-12-21-0004');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-21-0006');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-LJ-2012-01-10
        load('RG-LJ-2012-01-10-0001');
        SupSac5  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2012-01-10-0008');
        SupSac6  = pa_supersac(Sac,Stim,2,1);
        
        pa_datadir RG-LJ-2012-01-17
        load('RG-LJ-2012-01-17-0002');
        SupSac7  = pa_supersac(Sac,Stim,2,1);

        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4;SupSac5;SupSac6;SupSac7];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(232);
        plot(res_az,res_el,'r.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('30 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','r');
        axis square;

        subplot(235)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'r.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'r-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

        %% 50 deg condition
        pa_datadir RG-LJ-2011-12-14
        load('RG-LJ-2011-12-14-0002');
        SupSac1  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-14-0004');
        SupSac2  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-14-0007');
        SupSac3  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-14-0008');
        SupSac4  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-LJ-2011-12-21
        load('RG-LJ-2011-12-21-0001');
        SupSac5  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-21-0003');
        SupSac6  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-21-0005');
        SupSac7  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2011-12-21-0008');
        SupSac8  = pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-LJ-2012-01-10
        load('RG-LJ-2012-01-10-0002');
        SupSac9  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2012-01-10-0004');
        SupSac10  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2012-01-10-0005');
        SupSac11 = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2012-01-10-0006');
        SupSac12 = pa_supersac(Sac,Stim,2,1);
        
        pa_datadir RG-LJ-2012-01-17
        load('RG-LJ-2012-01-17-0001');
        SupSac13  = pa_supersac(Sac,Stim,2,1);
        load('RG-LJ-2012-01-17-0003');
        SupSac14  = pa_supersac(Sac,Stim,2,1);


        SupSac  = [SupSac1;SupSac2;SupSac3;SupSac4;SupSac5;SupSac6;SupSac7;SupSac8;SupSac9;SupSac10;SupSac11;SupSac12;SupSac13;SupSac14];
        sel     = abs(SupSac(:,23))<11 & abs(SupSac(:,24))<11;
        SupSac  = SupSac(sel,:);

        Taz     = SupSac(:,23);   % target azimuth (deg)
        Raz     = SupSac(:,8);    % response azimuth (deg)
        Tel     = SupSac(:,24);   % target elevation (deg)
        Rel     = SupSac(:,9);    % response elevation (deg)

        %% Regression
        stats       = regstats(Raz,Taz,'linear',{'beta','r'});
        res_az      = stats.r; % localization residual errors (deg);
        beta_az     = stats.beta;

        stats       = regstats(Rel,Tel,'linear',{'beta','r'});
        res_el      = stats.r; % localization residual errors (deg);
        beta_el     = stats.beta;

        [MU,SD,A]   = pa_ellipse(res_az,res_el);

        %% Graphics
        figure (12)
        subplot(233);
        plot(res_az,res_el,'b.');
        axis ([-40 40 -40 40])
        line([0 0],[-90 90],'Color','k')
        line([-90 90],[0 0],'Color','k')
        title ('50 degree')
        h = pa_ellipseplot(MU,2*SD,A);
        set(h,'EdgeColor','none','FaceColor','b');
        axis square;
        xlabel('Azimuth residual (deg)');
        ylabel('elevation residual (deg)');

        subplot(236)
        plot(Taz,Raz,'k.');
        hold on
        plot(Tel,Rel,'b.');
        x = [-40 40];
        y = beta_az(2)*x+beta_az(1);
        plot(x,y,'k-','LineWidth',2);
        y = beta_el(2)*x+beta_el(1);
        plot(x,y,'b-','LineWidth',2);
        axis ([-40 40 -40 40])
        title ('10 degree')
        axis square;
        pa_unityline;

end