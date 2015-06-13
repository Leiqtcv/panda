        close all
        clear all
        
        pa_datadir JR-RG-2012-02-23
        load JR-RG-2012-02-23-0001

%         pa_datadir RG-JR-2012-02-29
%         load RG-JR-2012-02-29-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac);
       

        figure(666)
%         [BETA,SE,XI] = PA_WEIGHTEDREGRESS(X,Y,Z,SIGMA,XI)
X = SupSac(:,1);
Y = SupSac(:,24);
Z = SupSac(:,9);
sigma = 5;
XI = X;
[beta,se,xi] = pa_weightedregress(X,Y,Z,sigma,XI);
n = 400;
x = 1:n;
freq	= 0.002; % 1 cycle per 100 trials
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
freq	= 0.002; % 1 cycle per 100 trials
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
        
        
        figure(2)%Ueberlagern 1-250
 
        x= SupSac(:,1)';
        
        sel= x>250 & x<401;
        x(sel)=1:150;

        plot(x)

        figure(3) %Results 1-125
        SupSac(:,1)=x;
        SS=SupSac;
        sel = abs(SS(:,1))<126;
        First       = SS(sel,:);
        pa_plotloc(First);
        
        
        figure(4)% Results 125-250
        SupSac(:,1)=x;
        SS=SupSac;
        sel = abs(SS(:,1))>125;
        Second       = SS(sel,:);
        pa_plotloc(Second);
     
        
        figure(5)% Selection for first and second half on 10 degree targets
        subplot(221)
        kel=abs(First(:,24))<=15 & abs(First(:,23))<=15;
        pa_loc(First(kel,24),First(kel,9));
        subplot(222)
        kel=abs(Second(:,24))<=15 & abs(Second(:,23))<=15;
        pa_loc(Second(kel,24),Second(kel,9));
        
        subplot(223)
        kel=abs(First(:,24))<=15 & abs(First(:,23))<=15;
        pa_loc(First(kel,23),First(kel,8));
        subplot(224)
        kel=abs(Second(:,24))<=15 & abs(Second(:,23))<=15;
        pa_loc(Second(kel,23),Second(kel,8));

        
        
 %% Finer Comparison, (first) 50-100 and (second) 150-200 part of one round (1-250)
            
        figure(6) % Results 50-100
            SupSac(:,1) = x;
            SS          =SupSac;
            sel         = abs(SS(:,1))>=50 & abs(SS(:,1))<=100;
            First       = SS(sel,:);
            pa_plotloc(First);
        
        
        figure(7)% Results 150-200
            SupSac(:,1) =x;
            SS          =SupSac;
            sel         = abs(SS(:,1))>=150 & abs(SS(:,1))<=200;
            Second      = SS(sel,:);
            pa_plotloc(Second);
            
            
        figure(8)% Selection for first and second half on 10 degree targets
            subplot(221)
            kel     = abs(First(:,24))<=15 & abs(First(:,23))<=15;
            pa_loc(First(kel,24),First(kel,9));
            subplot(222)
            kel     = abs(Second(:,24))<=15 & abs(Second(:,23))<=15;
            pa_loc(Second(kel,24),Second(kel,9));

            subplot(223)
            kel     = abs(First(:,24))<=15 & abs(First(:,23))<=15;
            pa_loc(First(kel,23),First(kel,8));
            subplot(224)
            kel     = abs(Second(:,24))<=15 & abs(Second(:,23))<=15;
            pa_loc(Second(kel,23),Second(kel,8));