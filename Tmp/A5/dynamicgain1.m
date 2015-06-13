        close all
        clear all
        % RG1, RG2, RGcomb, JR1, JR2, HH, RO, TH, MW, CK, BK, DM, LJ
     subject = 'MW';
     
        switch subject
            
            case 'RG1'
                figure(1)
                    pa_datadir JR-RG-2012-02-22
                    load JR-RG-2012-02-22-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
                
                figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
        
            case 'RG2'
                figure(1)
                    pa_datadir JR-RG-2012-03-07
                    load JR-RG-2012-03-07-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
                figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
        
            case 'RGcomb'
                figure(1)
                    pa_datadir JR-RG-2012-02-22
                    load JR-RG-2012-02-22-0001
                    SupSac1 = pa_supersac(Sac,Stim,2,1);
                    pa_datadir JR-RG-2012-03-07
                    load JR-RG-2012-03-07-0001
                    SupSac2 = pa_supersac(Sac,Stim,2,1);
                    SupSac = [SupSac1,SupSac2];
                    pa_plotloc(SupSac);
        
               figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
        
            case 'JR1'
                figure(1)
                    pa_datadir RG-JR-2012-02-28
                    load RG-JR-2012-02-28-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
               figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
        
                   
             case 'JR2'
                 figure(1)
                    pa_datadir RG-JR-2012-03-13
                    load RG-JR-2012-03-13-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
               figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
           
            
            case 'HH'
                figure(1)
                    pa_datadir RG-HH-2012-02-29
                    load RG-HH-2012-02-29-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
               figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
        
            case 'RO'
                figure(1)
                    pa_datadir RG-RO-2012-03-08
                    load RG-RO-2012-03-08-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
                figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')

        
            case 'TH'
                figure(1)
                    pa_datadir RG-TH-2012-03-09
                    load RG-TH-2012-03-09-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
                figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')

        
            case 'MW'
                figure(1)
                    pa_datadir RG-MW-2012-03-13
                    load RG-MW-2012-03-13-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
                 figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
                   
                   
                                figure(22)
                pa_datadir RG-MW-2012-03-15
                load RG-MW-2012-03-15-0001
                SupSaca = pa_supersac(Sac,Stim,2,1);
                pa_plotloc(SupSaca);
             figure(23)
                plot(SupSaca(:,23),SupSaca(:,24),'o')
                hold on
                plot(SupSaca(:,8),SupSaca(:,9),'ro')
        
            case 'CK'
                figure(1)
                    pa_datadir RG-CK-2012-03-13
                    load RG-CK-2012-03-13-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
                figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
        
         case 'BK'
                 figure(1)
                    pa_datadir RG-BK-2012-03-13
                    load RG-BK-2012-03-13-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
                 figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
        
         case 'MWcont'
             figure(1)
                pa_datadir RG-MW-2012-03-15
                load RG-MW-2012-03-15-0001
                SupSac = pa_supersac(Sac,Stim,2,1);
                pa_plotloc(SupSac);
             figure(2)
                plot(SupSac(:,23),SupSac(:,24),'o')
                hold on
                plot(SupSac(:,8),SupSac(:,9),'ro')
        
         case 'DM'
             figure(1)
                pa_datadir RG-DM-2012-03-15
                load RG-DM-2012-03-15-0001
                SupSac = pa_supersac(Sac,Stim,2,1);
                sel = SupSac(:,24)> 0 ;
                SSelst = SupSac(sel,24);
                SSelre = SupSac(sel,9);
                pa_loc(SSelst,SSelre)   
             figure(2)
                plot(SupSac(:,23),SupSac(:,24),'o')
                hold on
                plot(SupSac(:,8),SupSac(:,9),'ro')
                
                
                case 'LJ'
                 figure(1)
                    pa_datadir RG-LJ-2012-03-22
                    load RG-LJ-2012-03-22-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
                 figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')

        end       

% sel = SupSac(:,24)< -10 | SupSac(:,24)> 10 &  SupSac(:,23)> 10 |  SupSac(:,23)< -10
%    sel = SupSac(:,24)> -100;
%         [BETA,SE,XI] = PA_WEIGHTEDREGRESS(X,Y,Z,SIGMA,XI)
 figure(3)
%% Elevation
subplot(221)
X = SupSac(:,1);
Y = SupSac(:,24);
Z = SupSac(:,9);

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
subplot(221)
plot(x,sd,'r','LineWidth',2);
hold on
pa_errorpatch(xi,beta,se);
xlim([1 mx])

subplot(223)
plot(sd,beta(x),'k.');
pa_unityline;
pa_revline;


% % Elevation
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



% %% Elevation
% 
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
% % betaa = beta
% subplot(222)
% plot(x,sd,'r','LineWidth',2);
% hold on
% pa_errorpatch(xi,(beta-betaa),se);
% xlim([1 mx])

% subplot(223)
% plot(sd,beta(x),'k.');
% pa_unityline;
% pa_revline;

% figure(666)
% subplot(222)
% plot(sd,(beta(x)/betaa(x)),'k');

%% Azimuth
subplot (222)
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



% %% Correction for different gains due to other effects than prior
% 
% % regstats, beta, selectie
% 
% rng = [ 15 35 55 75];
% for ii=1:numel(rng)
%     if ii==1
%         sel     = SupSac(:,23)<=rng(ii);
%     else
%         sel       = SupSac(:,23)<=rng(ii) & SupSac(:,23)>rng(ii-1);
%     end
%         Yaz       = SupSac(sel,8);
%         Xaz       = SupSac(sel,23);
%         statsaz = regstats(Yaz,Xaz,'linear',{'beta'});
%         
%         Gainaz(ii) = statsaz.beta(2);
%        
% end
% 
% % for jj = numel(rng)
% %         if jj==1
% %         sel     = SupSac(:,23)<=rng(jj);
% %     else
% %         sel       = SupSac(:,23)<=rng(jj) & SupSac(:,23)>rng(jj-1);
% %         end
% % % sel = SupSac(:,23)<rng(1)
% % SupSac(sel,8) = SupSac(sel,8)/mean(Gainaz);
% % end
% 
% 
%     
%     %% Azimuth
% X = SupSac(:,1);
% Y = SupSac(:,23);
% Z = SupSac(:,8);
% 
% % for jj=1:numel(rng)
% % sel(jj) = SupSac(:,23)<12;
% % Z(jj) = (SupSac(sel,8)/Gainaz(1,1));
% % end
% 
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
% [beta,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);
% % n = 400;
% x = 1:mx;
% sd		= sin(2*pi*freq*x+0.5*pi).^2;
% sd = (sd)*(max(beta)-min(beta))+min(beta);
% % sd      = sd/max(sd);
% beta = beta*mean(Gainaz)
% 
% subplot(222)
% plot(x,sd,'g','LineWidth',2);
% hold on
% pa_errorpatch(xi,beta,se,'b');
% xlim([1 mx])
% 
% subplot(224)
% plot(sd,beta(x),'k.');
% pa_unityline;
% pa_revline;
% % end
% 

        figure(5)
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
plot(X,abs(Y)./45,'k-','Color',[.7 .7 .7]);


 Xb = SupSac(:,1);
        Yb = abs(SupSac(:,23));
        sigma = 5;
        XIb = unique(Xb);
        mx = max(Xb);
        [mui,sei,xi] = rg_weightedmean(Xb,Yb,sigma,XIb,'nboot',10);
%        figure (356)
mui = mui/20+1;
sei = sei/mx;
        pa_errorpatch(xi, mui, sei(:,1),'b');
        xlim([1 mx])

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
plot(X,abs(Y)./45,'k-','Color',[.7 .7 .7]);

        Xb = SupSac(:,1);
        Yb = abs(SupSac(:,24));
        sigma = 5;
        XIb = unique(Xb);
        mx = max(Xb);
        [mui,sei,xi] = rg_weightedmean(Xb,Yb,sigma,XIb,'nboot',10);
%        figure (356)
mui = mui/20+1;
sei = sei/mx;
        pa_errorpatch(xi, mui, sei(:,1),'b');
        xlim([1 mx])

 
% return
%         figure(2)%Ueberlagern 1-50, 51-100 usw
%         
%             x= SupSac(:,1)'; % 1:400
% 
%             sel     = x>50 & x<101;
%             x(sel)  = 1:50;
%             sel     = x>100 & x<151;
%             x(sel)  = 1:50;
%             sel     = x>150 & x<201;
%             x(sel)  = 1:50;
%             sel     = x>200 & x<251;
%             x(sel)  = 1:50;
%             sel     = x>250 & x<301;
%             x(sel)  = 1:50;
%             sel     = x>300 & x<351;
%             x(sel)  = 1:50;
%             sel     = x>350 & x<401;
%             x(sel)  = 1:50;
%             plot(x)
% 
%    %% Rough Comparison first and second part of one round (1-50)
%             
%         figure(3) % Results 1-25
%             SupSac(:,1) = x;
%             SS          =SupSac;
%             sel         = abs(SS(:,1))<26;
%             First       = SS(sel,:);
%             pa_plotloc(First);
%         
%         
%         figure(4)% Results 26-50
%             SupSac(:,1) =x;
%             SS          =SupSac;
%             sel         = abs(SS(:,1))>25;
%             Second      = SS(sel,:);
%             pa_plotloc(Second);
%         
%         figure(5)% Selection for first and second half on 10 degree targets
%             subplot(221)
%             kel     = abs(First(:,24))<=100 & abs(First(:,23))<=100;
%             pa_loc(First(kel,24),First(kel,9));
%             subplot(222)
%             kel     = abs(Second(:,24))<=100 & abs(Second(:,23))<=100;
%             pa_loc(Second(kel,24),Second(kel,9));
% 
%             subplot(223)
%             kel     = abs(First(:,24))<=100 & abs(First(:,23))<=100;
%             pa_loc(First(kel,23),First(kel,8));
%             subplot(224)
%             kel     = abs(Second(:,24))<=100 & abs(Second(:,23))<=100;
%             pa_loc(Second(kel,23),Second(kel,8));
%             
%     %% Finer Comparison, (first) 10-25 and (second) 30-40 part of one round (1-50)
%             
%         figure(6) % Results 10-25
%             SupSac(:,1) = x;
%             SS          =SupSac;
%             sel         = abs(SS(:,1))>=5 & abs(SS(:,1))<=20;
%             First       = SS(sel,:);
%             pa_plotloc(First);
%         
%         
%         figure(7)% Results 30-40
%             SupSac(:,1) =x;
%             SS          =SupSac;
%             sel         = abs(SS(:,1))>=30 & abs(SS(:,1))<=45;
%             Second      = SS(sel,:);
%             pa_plotloc(Second);
%             
%             
%         figure(8)% Selection for first and second half on 10 degree targets
%             subplot(221)
%             kel     = abs(First(:,24))<=100 & abs(First(:,23))<=100;
%             pa_loc(First(kel,24),First(kel,9));
%             subplot(222)
%             kel     = abs(Second(:,24))<=100 & abs(Second(:,23))<=100;
%             pa_loc(Second(kel,24),Second(kel,9));
% 
%             subplot(223)
%             kel     = abs(First(:,24))<=100 & abs(First(:,23))<=100;
%             pa_loc(First(kel,23),First(kel,8));
%             subplot(224)
%             kel     = abs(Second(:,24))<=100 & abs(Second(:,23))<=100;
%             pa_loc(Second(kel,23),Second(kel,8));
