close all
clear all

subject = 'RG1';

switch subject
    
    
    case 'MW'
       
        pa_datadir RG-MW-2012-03-13
        load RG-MW-2012-03-13-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        freq	= 0.01; 

    case 'RG1'
      
        pa_datadir JR-RG-2012-02-22
        load JR-RG-2012-02-22-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        freq	= 0.01; 

    case 'RG2'
  
        pa_datadir JR-RG-2012-03-08
        load JR-RG-2012-03-08-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        freq	= 0.005; 

    case 'JR'
    
        pa_datadir RG-JR-2012-02-28
        load RG-JR-2012-02-28-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        freq	= 0.01; 

    case 'RO'
     
         pa_datadir RG-RO-2012-03-08
         load RG-RO-2012-03-08-0001
         SupSac = pa_supersac(Sac,Stim,2,1);
         freq = 0.01;

%                 pa_datadir RG-MW-2012-03-13
%         load RG-MW-2012-03-13-0001
%         SupSac = pa_supersac(Sac,Stim,2,1);
% freq	= 0.01; % 1 cycle per 100 trials       
        
      
%         pa_datadir RG-MW-2012-03-21
%         load RG-MW-2012-03-21-0001
%         SupSaca = pa_supersac(Sac,Stim,2,1);
        
end
    
figure(1) %Stimulus Response Plot
pa_plotloc(SupSac);

figure(2) %Target Response Figure
plot(SupSac(:,23),SupSac(:,24),'o')
hold on
plot(SupSac(:,8),SupSac(:,9),'ro')



%% Mean response Control

        X = round(SupSac(:,24));
        Y = SupSac(:,9);
        uX = unique(X);
        n = numel(uX);
        mu = NaN(n,1);
        for ii = 1:n
            sel = X==uX(ii);
            mu(ii) = median(Y(sel));
        end
        figure(3)
        plot(X,Y,'k.');
        hold on
        plot(uX,mu,'ro','MarkerFaceColor','w');
        axis square;
        pa_unityline;


        X = SupSac(:,24);
        X = interp1(uX,mu,X);
        Y = SupSac(:,9);

        plot(X,Y,'b.');
        hold on

        axis square;
        pa_unityline;


        figure (35)
        
        X = SupSac(:,1);
        Y = SupSac(:,24);
        Y = interp1(uX,mu,Y);
        Z = SupSac(:,9);
        
        X = mod(X,1/(2*freq));
        Y = [Y;Y;Y];
        Z = [Z;Z;Z];
        mx = max(X);
        X = [X-mx;X;X+mx];
        whos X Y Z
        sigma = 5;
        XI = unique(X);
        [beta,se,xi] = rg_weightedregress(X,Y,Z,sigma,XI,'wfun','half');
        x = 1:mx;
        sd		= sin(2*pi*freq*x+0.5*pi).^2;
%         beta = beta;
        sd = (sd)*(max(beta)-min(beta))+min(beta);
        subplot(221)
        plot(x,sd,'r','LineWidth',2);
        hold on
        pa_errorpatch(xi,beta,se);
        xlim([1 mx])
        
        Xb = SupSac(:,1);
        Yb = SupSac(:,24);
        sigma = 5;
        XIb = unique(Xb);
        
        [mui,sei,xi] = rg_weightedmean(Xb,Yb,sigma,XIb,'nboot',10);
%        figure (356)
mui = mui/mx;
sei = sei/mx;
        pa_errorpatch(xi, mui, sei(:,1),'b');
        xlim([1 mx])
%         
%         
%         figure
%         
% X = SupSac(:,1);
% Y = SupSac(:,24);
% Z = SupSac(:,9);
% sigma = 5;
% XI = X;
% [beta,se,xi] = rg_weightedregress(X,Y,Z,sigma,XI);
% n = 400;
% x = 1:n;
% freq	= 0.01; % 1 cycle per 100 trials
% sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
% sd = sd/max(sd);
% plot(x,sd,'r','LineWidth',2);
% hold on
% pa_errorpatch(xi,beta,se);
% plot(X,abs(Y)./45,'k-','Color',[.7 .7 .7]);
% 
% hold on
%         [mui,sei,XI] = para_weightedmean(Xb,Yb,sigma,XIb);
% %        figure (356)
% mui = mui
% sei = sei
%         pa_errorpatch(xi, mui, sei(:,1,'b');
%         xlim([1 mx])



%         subplot(212)
% figure
% X = SupSac(:,1);
% Y = SupSac(:,24);
% Z = SupSac(:,9);
% sigma = 5;
% XI = X;
% [beta,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);
% n = 400;
% x = 1:n;
% % freq	= 0.01; % 1 cycle per 100 trials
% sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
% sd = sd/max(sd);
% plot(x,sd,'r','LineWidth',2);
% hold on
% pa_errorpatch(xi,beta,se);

        return
        
        figure(4)
        
        %% Elevation
        X = SupSac(:,1);
        Y = SupSac(:,24);
        Y = interp1(uX,mu,Y);
        Z = SupSac(:,9);

        Xb = SupSac(:,1);
        Yb = SupSac(:,24);
        Yb = interp1(uX,mu,Yb);
        Zb = SupSac(:,24);



        X = mod(X,1/(2*freq));
        Y = [Y;Y;Y];
        Z = [Z;Z;Z];
        mx = max(X);
        X = [X-mx;X;X+mx];
        whos X Y Z
        sigma = 5;
        XI = unique(X);
        [beta,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);
        x = 1:mx;
        sd		= sin(2*pi*freq*x+0.5*pi).^2;
        beta = beta;
        sd = (sd)*(max(beta)-min(beta))+min(beta);
        subplot(221)
        plot(x,sd,'r','LineWidth',2);
        hold on
        pa_errorpatch(xi,beta,se);
        xlim([1 mx])

        Xb = mod(Xb,1/(2*freq));
        Yb = [Yb;Yb;Yb];
        Zb = [Zb;Zb;Zb];
        mxb = max(Xb);
        Xb = [Xb-mxb;Xb;Xb+mxb];
        whos Xb Yb Zb
        sigmab = 5;
        XIb = unique(Xb);
        [betab,seb,xib] = rg_weightedregress(Xb,Yb,Zb,sigmab,XIb, 'wfun', 'half');
        xb = 1:mxb;
        sdb		= sin(2*pi*freq*xb+0.5*pi).^2;
        sdb = (sdb)*(max(betab)-min(betab))+min(betab);
        subplot(221)
        % plot(xb,sdb,'r','LineWidth',2);
        hold on
        pa_errorpatch(xib,betab,seb,'b');
        xlim([1 mxb])


        subplot(222)
        plot(sd,beta(x),'k.');
        pa_unityline;
        pa_revline;


        subplot(212)
        X = SupSac(:,1);
        Y = SupSac(:,24);
        Z = SupSac(:,9);
        sigma = 5;
        XI = X

        Xb = SupSac(:,1);
        Yb = SupSac(:,23);
        Zb = SupSac(:,24);
        sigmab = 5;
        XIb = Xb;

        [beta,se,xi] = rg_weightedregress(X,Y,Z,sigma,XI,'wfun','half');
        n = 400;
        x = 1:n;
        % freq	= 0.01; % 1 cycle per 100 trials
        sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
        sd = sd/max(sd);
        plot(x,sd,'r','LineWidth',2);
        hold on
        % beta = beta-1;
        % beta = beta./max(beta);
        pa_errorpatch(xi,beta,se);
        % pa_errorpatch(xi-5,beta,se);
        plot(X,Y./45,'k-','Color',[.7 .7 .7]);

        [betab,seb,xib] = rg_weightedregress(Xb,Yb,Zb,sigmab,XIb,'wfun','half');
        n = 400;
        x = 1:n;
        % freq	= 0.01; % 1 cycle per 100 trials
        sdb		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
        sdb = sdb/max(sdb);
        plot(x,sdb,'r','LineWidth',2);
        hold on
        % beta = beta-1;
        % beta = beta./max(beta);
        pa_errorpatch(xib,betab,seb,'b');
        % pa_errorpatch(xi-5,beta,se);
        % plot(Xb,Yb./45,'b-','Color',[.7 .7 .7]);


        figure(5)
        %% Elevation
        X = SupSac(:,1);
        Y = SupSac(:,24);
        Y = interp1(uX,mu,Y);
        Z = SupSac(:,9);

        Xb = SupSac(:,1);
        Yb = SupSac(:,24);
        Yb = interp1(uX,mu,Yb);
        Zb = SupSac(:,24);



        X = mod(X,1/(2*freq));
        Y = [Y;Y;Y];
        Z = [Z;Z;Z];
        mx = max(X);
        X = [X-mx;X;X+mx];
        whos X Y Z
        sigma = 5;
        XI = unique(X);
        [beta,se,xi] = rg_weightedregress(X,Y,Z,sigma,XI,'wfun', 'boxcarhalf');
        x = 1:mx;
        sd		= sin(2*pi*freq*x+0.5*pi).^2;
        beta = beta;
        sd = (sd)*(max(beta(:,2))-min(beta(:,2)))+min(beta(:,2));
        subplot(221)
        plot(x,sd,'r','LineWidth',2);
        hold on
        pa_errorpatch(xi,beta(:,2),se(:,2));
        xlim([1 mx])

        Xb = mod(Xb,1/(2*freq));
        Yb = [Yb;Yb;Yb];
        Zb = [Zb;Zb;Zb];
        mxb = max(Xb);
        Xb = [Xb-mxb;Xb;Xb+mxb];
        whos Xb Yb Zb
        sigmab = 5;
        XIb = unique(Xb);
        [betab,seb,xib] = rg_weightedregress(Xb,Yb,Zb,sigmab,XIb, 'wfun', 'boxcarhalf');
        xb = 1:mxb;
        sdb		= sin(2*pi*freq*xb+0.5*pi).^2;
        sdb = (sdb)*(max(betab(:,2))-min(betab(:,2)))+min(betab(:,2));
        subplot(221)
        % plot(xb,sdb,'r','LineWidth',2);
        hold on
        pa_errorpatch(xib,betab(:,2),seb(:,2),'b');
        xlim([1 mxb])


        subplot(222)
        plot(sd,beta(x),'k.');
        pa_unityline;
        pa_revline;


        subplot(212)
        X = SupSac(:,1);
        Y = SupSac(:,24);
        Z = SupSac(:,9);
        sigma = 5;
        XI = X

        Xb = SupSac(:,1);
        Yb = SupSac(:,23);
        Zb = SupSac(:,24);
        sigmab = 5;
        XIb = Xb;

        [beta,se,xi] = rg_weightedregress(X,Y,Z,sigma,XI,'wfun','boxcarhalf');
        n = 400;
        x = 1:n;
        % freq	= 0.01; % 1 cycle per 100 trials
        sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
        sd = sd/max(sd);
        plot(x,sd,'r','LineWidth',2);
        hold on
        % beta = beta-1;
        % beta = beta./max(beta);
        pa_errorpatch(xi,beta(:,2),se(:,2));
        % pa_errorpatch(xi-5,beta,se);
        plot(X,Y./45,'k-','Color',[.7 .7 .7]);

        [betab,seb,xib] = rg_weightedregress(Xb,Yb,Zb,sigmab,XIb,'wfun','boxcarhalf');
        n = 400;
        x = 1:n;
        % freq	= 0.01; % 1 cycle per 100 trials
        sdb		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
        sdb = sdb/max(sdb);
        plot(x,sdb,'r','LineWidth',2);
        hold on
        % beta = beta-1;
        % beta = beta./max(beta);
        pa_errorpatch(xib,betab(:,2),seb(:,2),'b');
        % pa_errorpatch(xi-5,beta,se);
        % plot(Xb,Yb./45,'b-','Color',[.7 .7 .7]);


        figure(6)
        %% Elevation
        X = SupSac(:,1);
        Y = SupSac(:,24);
        Y = interp1(uX,mu,Y);
        Z = SupSac(:,9);

        Xb = SupSac(:,1);
        Yb = SupSac(:,24);
        Yb = interp1(uX,mu,Yb);
        Zb = SupSac(:,24);



        X = mod(X,1/(2*freq));
        Y = [Y;Y;Y];
        Z = [Z;Z;Z];
        mx = max(X);
        X = [X-mx;X;X+mx];
        whos X Y Z
        sigma = 5;
        XI = unique(X);
        [beta,se,xi] = rg_weightedregress(X,Y,Z,sigma,XI,'wfun', 'boxcarhalf');
        x = 1:mx;
        sd		= sin(2*pi*freq*x+0.5*pi).^2;
        beta = beta;
        sd = (sd)*(max(beta(:,1))-min(beta(:,1)))+min(beta(:,1));
        subplot(221)
        plot(x,sd,'r','LineWidth',2);
        hold on
        pa_errorpatch(xi,beta(:,1),se(:,1));
        xlim([1 mx])

        Xb = mod(Xb,1/(2*freq));
        Yb = [Yb;Yb;Yb];
        Zb = [Zb;Zb;Zb];
        mxb = max(Xb);
        Xb = [Xb-mxb;Xb;Xb+mxb];
        whos Xb Yb Zb
        sigmab = 5;
        XIb = unique(Xb);
        [betab,seb,xib] = rg_weightedregress(Xb,Yb,Zb,sigmab,XIb, 'wfun', 'boxcarhalf');
        xb = 1:mxb;
        sdb		= sin(2*pi*freq*xb+0.5*pi).^2;
        sdb = (sdb)*(max(betab(:,1))-min(betab(:,1)))+min(betab(:,1));
        subplot(221)
        % plot(xb,sdb,'r','LineWidth',2);
        hold on
        pa_errorpatch(xib,betab(:,1),seb(:,1),'b');
        xlim([1 mxb])


        subplot(222)
        plot(sd,beta(x),'k.');
        pa_unityline;
        pa_revline;


        subplot(212)
        X = SupSac(:,1);
        Y = SupSac(:,24);
        Z = SupSac(:,9);
        sigma = 5;
        XI = X

        Xb = SupSac(:,1);
        Yb = SupSac(:,23);
        Zb = SupSac(:,24);
        sigmab = 5;
        XIb = Xb;

        [beta,se,xi] = rg_weightedregress(X,Y,Z,sigma,XI,'wfun','boxcarhalf');
        n = 400;
        x = 1:n;
        % freq	= 0.01; % 1 cycle per 100 trials
        sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
        sd = sd/max(sd);
        plot(x,sd,'r','LineWidth',2);
        hold on
        % beta = beta-1;
        % beta = beta./max(beta);
        pa_errorpatch(xi,beta(:,1),se(:,1));
        % pa_errorpatch(xi-5,beta,se);
        plot(X,Y./45,'k-','Color',[.7 .7 .7]);

        [betab,seb,xib] = rg_weightedregress(Xb,Yb,Zb,sigmab,XIb,'wfun','boxcarhalf');
        n = 400;
        x = 1:n;
        % freq	= 0.01; % 1 cycle per 100 trials
        sdb		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
        sdb = sdb/max(sdb);
        plot(x,sdb,'r','LineWidth',2);
        hold on
        % beta = beta-1;
        % beta = beta./max(beta);
        pa_errorpatch(xib,betab(:,1),seb(:,1),'b');
        % pa_errorpatch(xi-5,beta,se);
        % plot(Xb,Yb./45,'b-','Color',[.7 .7 .7]);


        
        
        



        return









%% Azimuth
X = SupSac(:,1);
Y = SupSac(:,23);
Z = SupSac(:,8);
freq	= 0.01; % 1 cycle per 100 trials

X = mod(X,1/(2*freq));
Y = [Y;Y;Y];
Z = [Z;Z;Z];
mx = max(X);
X = [X-mx;X;X+mx];
whos X Y Z
sigma = 5;
XI = unique(X);
[beta,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);

x = 1:mx;
sd		= sin(2*pi*freq*x+0.5*pi).^2;
sd = (sd)*(max(beta)-min(beta))+min(beta);


subplot(222)
plot(x,sd,'r','LineWidth',2);
hold on
pa_errorpatch(xi,beta,se);
xlim([1 mx])

subplot(224)
plot(sd,beta(x),'k.');
pa_unityline;
pa_revline;

%% Gain
figure(4)
X = SupSac(:,24);
Y = SupSac(:,24);
Z = SupSac(:,9);
sel = X<0;

X(sel) = -X(sel);
Y(sel) = -Y(sel);
Z(sel) = -Z(sel);

XI = linspace(min(X),max(X),100);
beta = pa_weightedregress(X,Y,Z,20,XI,'wfun','boxcar');

subplot(211)
plot(XI,beta(:,2),'k.-','LineWidth',2)
xlabel('stimulus degree')
ylabel('gain')
ylim([0 2])
pa_horline(1);

subplot(212)
plot(XI,beta(:,1),'k.-','LineWidth',2)
xlabel('stimulus degree')
ylabel('bias')
% ylim([0 2])
pa_horline(0);

XI = linspace(min(X),max(X),100);
beta = pa_weightedregress(X,Y,Z,5,XI,'wfun','gaussian');
subplot(211)
hold on
plot(XI,beta,'r-','LineWidth',2)
xlabel('stimulus degree')
ylabel('gain')
ylim([0 2])
pa_horline(1);

figure(5)
X = SupSaca(:,24);
Y = SupSaca(:,24);
Z = SupSaca(:,9);
sel = X<0;

X(sel) = -X(sel);
Y(sel) = -Y(sel);
Z(sel) = -Z(sel);

XI = linspace(min(X),max(X),100);
beta = pa_weightedregress(X,Y,Z,20,XI,'wfun','boxcar');

subplot(211)
plot(XI,beta(:,2),'k.-','LineWidth',2)
xlabel('stimulus degree')
ylabel('gain')
ylim([0 2])
pa_horline(1);

subplot(212)
plot(XI,beta(:,1),'k.-','LineWidth',2)
xlabel('stimulus degree')
ylabel('bias')
% ylim([0 2])
pa_horline(0);

XI = linspace(min(X),max(X),100);
beta = pa_weightedregress(X,Y,Z,5,XI,'wfun','gaussian');
subplot(211)
hold on
plot(XI,beta,'r-','LineWidth',2)
xlabel('stimulus degree')
ylabel('gain')
ylim([0 2])
pa_horline(1);
title('control__exp')



% %% Elevation
% X = SupSaca(:,1);
% Y = SupSaca(:,24);
% Z = SupSaca(:,9);
%
% freq	= 0.01; % 1 cycle per 100 trials
%
% X = mod(X,1/(2*freq));
% Y = [Y;Y;Y];
% Z = [Z;Z;Z];
% mx = max(X);
% X = [X-mx;X;X+mx];
% whos X Y Z
% sigma = 5;
% XI = unique(X);
% [betaa,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);
% x = 1:mx;
% sd		= sin(2*pi*freq*x+0.5*pi).^2;
% sd = (sd)*(max(betaa)-min(betaa))+min(betaa);
% subplot(222)
% plot(x,sd,'r','LineWidth',2);
% hold on
% beta = beta';
% betaa = betaa';
% for i=1:length(beta)
%     b(i)= beta(:,i)/betaa(:,i);
%     b=b'
% end
%
% pa_errorpatch(xi,b,se);
% xlim([1 mx])
%
% subplot(224)
% plot(sd,b(x),'k.');
% pa_unityline;
% pa_revline;



figure(6)
%         [BETA,SE,XI] = PA_WEIGHTEDREGRESS(X,Y,Z,SIGMA,XI)
subplot(211)
X = SupSac(:,1);
Y = SupSac(:,23);
Z = SupSac(:,8);
sigma = 5;
XI = X;
[beta,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);
n = 400;
x = 1:n;
freq	= 0.01; % 1 cycle per 100 trials
sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
sd = sd/max(sd);
plot(x,sd,'r','LineWidth',2);
hold on
pa_errorpatch(xi,beta,se);

subplot(212)
X = SupSac(:,1);
Y = SupSac(:,24);
Z = SupSac(:,9);
sigma = 5;
XI = X;
[beta,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);
n = 400;
x = 1:n;
freq	= 0.01; % 1 cycle per 100 trials
sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
sd = sd/max(sd);
plot(x,sd,'r','LineWidth',2);
hold on
pa_errorpatch(xi,beta,se);

