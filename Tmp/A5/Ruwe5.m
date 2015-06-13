        close all
        clear all
        
        
             subject = 'RGcomb'
     
        switch subject
            
            case 'RG1'
        pa_datadir JR-RG2-2012-02-22
        load JR-RG2-2012-02-22-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        
            case 'RG2'
        pa_datadir JR-RG-2012-03-08
        load JR-RG-2012-03-08-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        
            case 'RGcomb'
        pa_datadir JR-RG2-2012-02-22
        load JR-RG2-2012-02-22-0001
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        
        pa_datadir JR-RG-2012-03-08
        load JR-RG-2012-03-08-0001
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        
        SupSac = [SupSac1,SupSac2];
        

        end
        
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
freq	= 0.005; % 1 cycle per 100 trials
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

        