        close all
        clear all
        
        
             subject = 'RG1'
     
        switch subject
            
            case 'RG1'
        pa_datadir JR-RG2-2012-02-22
        load JR-RG2-2012-02-22-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
        
            case 'RG2'
        pa_datadir JR-RG-2012-03-08
        load JR-RG-2012-03-08-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
                    pa_plotloc(SupSac);
        
            case 'RGcomb'
        pa_datadir JR-RG2-2012-02-22
        load JR-RG2-2012-02-22-0001
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        
        pa_datadir JR-RG-2012-03-08
        load JR-RG-2012-03-08-0001
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        
        SupSac = [SupSac1,SupSac2];
        
            case 'JR1'
        pa_datadir RG-JR2-2012-02-28
        load RG-JR2-2012-02-28-0001
        SupSac = pa_supersac(Sac,Stim,2,1);  
        
       
        
            case 'HH'
        pa_datadir RG-HH-2012-03-01
        load RG-HH-2012-03-01-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        
            case 'TH'
        pa_datadir RG-TH-2012-03-13
        load RG-TH-2012-03-13-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
                   
                   
                    case 'CK'
        pa_datadir RG-CK-2012-03-20
        load RG-CK-2012-03-20-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac);
        figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
        
            case 'DM'
        pa_datadir RG-DM-2012-03-16
        load RG-DM-2012-03-16-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
       figure (1) %Stimulus Response Plot, azimuth/elevation
       sel = SupSac(:,24)> 0 ;
       SSelst = SupSac(sel,24);
       SSelre = SupSac(sel,9);
       pa_loc(SSelst,SSelre)   
       
       figure(2)
       plot(SupSac(:,23),SupSac(:,24),'o')
       hold on
       plot(SupSac(:,8),SupSac(:,9),'ro')
       
       
                           case 'BK'
        pa_datadir RG-CK-2012-03-20
        load RG-CK-2012-03-20-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac);
        figure(2)
                   plot(SupSac(:,23),SupSac(:,24),'o')
                   hold on
                   plot(SupSac(:,8),SupSac(:,9),'ro')
        

        end
        
    

%             SupSac = pa_supersac(Sac,Stim,2,1);

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
freq	= 0.005; 
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
freq	= 0.005; 
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

        figure(666)
Average = mui;
%         [BETA,SE,XI] = PA_WEIGHTEDREGRESS(X,Y,Z,SIGMA,XI)

%  sel = SupSac(:,24)< -10 | SupSac(:,24)> 10 &  SupSac(:,23)> 10 |  SupSac(:,23)< -10
 sel = SupSac(:,24)> -100   
        
        
%         figure (1) %Stimulus Response Plot, azimuth/elevation
%        
% %             SupSac = pa_supersac(Sac,Stim,2,1);
%             pa_plotloc(SupSac);
%         figure(666)
% %         [BETA,SE,XI] = PA_WEIGHTEDREGRESS(X,Y,Z,SIGMA,XI)

%% Elevation
X = SupSac(sel,1);
Y = SupSac(sel,24);
Z = SupSac(sel,9);
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
% n = 400;
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

Gain = beta;
% el=SupSac(:,9);
% az=SupSac(:,8);
% plot(x,(el.^2+az.^2)/5000,'b-','LineWidth',1);

%% Azimuth
X = SupSac(sel,1);
Y = SupSac(sel,23);
Z = SupSac(sel,8);
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
% n = 400;
x = 1:mx;
sd		= sin(2*pi*freq*x+0.5*pi).^2;
sd = (sd)*(max(beta)-min(beta))+min(beta);
% sd      = sd/max(sd);

subplot(222)
plot(x,sd,'r','LineWidth',2);
hold on
pa_errorpatch(xi,beta,se);
xlim([1 mx])

subplot(224)
plot(sd,beta(x),'k.');
pa_unityline;
pa_revline;

%%
figure
whos Average Gain
plot(Average,Gain);
return
        
%         pa_datadir RG-JR2-2012-02-28
%         load RG-JR2-2012-02-28-0001
%         pa_datadir RG-HH-2012-03-01
%         load RG-HH-2012-03-01-0001

        SupSac = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac);

        figure(666)
%         [BETA,SE,XI] = PA_WEIGHTEDREGRESS(X,Y,Z,SIGMA,XI)
X = SupSac(:,1);
Y = SupSac(:,24);
Z = SupSac(:,9);
sigma =5;
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

el=SupSac(:,24);
az=SupSac(:,9);
plot(x,(el.^2+az.^2)/5000,'b-','LineWidth',1);



        figure(777)
%         [BETA,SE,XI] = PA_WEIGHTEDREGRESS(X,Y,Z,SIGMA,XI)
X = SupSac(:,1);
Y = SupSac(:,23);
Z = SupSac(:,8);
sigma = 5;
XI = X;
[beta,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);
n = 400;
x = 1:n;
freq	= 0.005; % 1 cycle per 100 trials
sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
sd = sd/max(sd);
plot(x,sd,'r','LineWidth',2);
hold on
pa_errorpatch(xi,beta,se);

el=SupSac(:,23);
az=SupSac(:,8);
plot(x,(el.^2+az.^2)/5000,'b-','LineWidth',1);
return
        
%           hier anderes x selecteren
        
        
        figure(2)%Ueberlagern 1-100, 101-200 usw
        
        x= SupSac(:,1)';
        
        sel= x>100 & x<201;
        x(sel)=1:100;
        
        sel= x>200 & x<301;
        x(sel)=1:100;
        
        sel= x>300 & x<401;
        x(sel)=1:100;
        

        plot(x)

        figure(3) %Results 1-50
        SupSac(:,1)=x;
        SS=SupSac;
        sel = abs(SS(:,1))<51;
%         sel = SupSac(:,1)<26;
%         SS=SupSac(sel,1);
        First       = SS(sel,:);
        pa_plotloc(First);
        
        
        figure(4)% Results 51-
        SupSac(:,1)=x;
        SS=SupSac;
        sel = abs(SS(:,1))>50;
%         sel = SupSac(:,1)<26;
%         SS=SupSac(sel,1);
        Second       = SS(sel,:);
        pa_plotloc(Second);
     
        
        figure(5)% Selectioon for first and second half on 10 degree targets
        subplot(221)
        kel=abs(First(:,24))<=100 & abs(First(:,23))<=100;
        pa_loc(First(kel,24),First(kel,9));
        subplot(222)
        kel=abs(Second(:,24))<=100 & abs(Second(:,23))<=100;
        pa_loc(Second(kel,24),Second(kel,9));
        
        subplot(223)
        kel=abs(First(:,24))<=100 & abs(First(:,23))<=100;
        pa_loc(First(kel,23),First(kel,8));
        subplot(224)
        kel=abs(Second(:,24))<=100 & abs(Second(:,23))<=100;
        pa_loc(Second(kel,23),Second(kel,8));
%                 sel = abs(SupSac(:,24))<=12;
%         pa_loc(SupSac(sel,24),SupSac(sel,9));


%% Finer Comparison, (first) 20-40 and (second) 60-80 part of one round (1-100)
            
        figure(6) % Results 20-40
            SupSac(:,1) = x;
            SS          =SupSac;
            sel         = abs(SS(:,1))>=20 & abs(SS(:,1))<=40;
            First       = SS(sel,:);
            pa_plotloc(First);
        
        
        figure(7)% Results 60-80
            SupSac(:,1) =x;
            SS          =SupSac;
            sel         = abs(SS(:,1))>=60 & abs(SS(:,1))<=80;
            Second      = SS(sel,:);
            pa_plotloc(Second);
            
            
        figure(8)% Selection for first and second half on 10 degree targets
            subplot(221)
            kel     = abs(First(:,24))<=100 & abs(First(:,23))<=100;
            pa_loc(First(kel,24),First(kel,9));
            subplot(222)
            kel     = abs(Second(:,24))<=100 & abs(Second(:,23))<=100;
            pa_loc(Second(kel,24),Second(kel,9));

            subplot(223)
            kel     = abs(First(:,24))<=100 & abs(First(:,23))<=100;
            pa_loc(First(kel,23),First(kel,8));
            subplot(224)
            kel     = abs(Second(:,24))<=100 & abs(Second(:,23))<=100;
            pa_loc(Second(kel,23),Second(kel,8));

        