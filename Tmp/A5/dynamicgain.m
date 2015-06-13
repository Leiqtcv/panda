        close all
        clear all
     subject = 'JR'
     
        switch subject
            
            case 'RG1'
        pa_datadir JR-RG-2012-02-22
        load JR-RG-2012-02-22-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        
            case 'RG2'
        pa_datadir JR-RG-2012-03-07
        load JR-RG-2012-03-07-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        
            case 'RGcomb'
        pa_datadir JR-RG-2012-02-22
        load JR-RG-2012-02-22-0001
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        
        pa_datadir JR-RG-2012-03-07
        load JR-RG-2012-03-07-0001
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        
        SupSac = [SupSac1,SupSac2];
        
            case 'JR'
        pa_datadir(['\Prior\RG-JR-2012-02-28']);
        load RG-JR-2012-02-28-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        
            case 'HH'
        pa_datadir RG-HH-2012-02-29
        load RG-HH-2012-02-29-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        
            case 'RO'
        pa_datadir RG-RO-2012-03-08
        load RG-RO-2012-03-08-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        
        end       


        figure (1) %Stimulus Response Plot, azimuth/elevation
       
%             SupSac = pa_supersac(Sac,Stim,2,1);
            pa_plotloc(SupSac);
        figure(666)
%         [BETA,SE,XI] = PA_WEIGHTEDREGRESS(X,Y,Z,SIGMA,XI)

%% Elevation
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
sigma = 10;
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
% el=SupSac(:,9);
% az=SupSac(:,8);
% plot(x,(el.^2+az.^2)/5000,'b-','LineWidth',1);

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
return


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
freq	= 0.01; % 1 cycle per 100 trials
sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
sd = sd/max(sd);
plot(x,sd,'r','LineWidth',2);
hold on
pa_errorpatch(xi,beta,se);

el=SupSac(:,23);
az=SupSac(:,8);
plot(x,(el.^2+az.^2)/5000,'b-','LineWidth',1);


return
        figure(2)%Ueberlagern 1-50, 51-100 usw
        
            x= SupSac(:,1)'; % 1:400

            sel     = x>50 & x<101;
            x(sel)  = 1:50;
            sel     = x>100 & x<151;
            x(sel)  = 1:50;
            sel     = x>150 & x<201;
            x(sel)  = 1:50;
            sel     = x>200 & x<251;
            x(sel)  = 1:50;
            sel     = x>250 & x<301;
            x(sel)  = 1:50;
            sel     = x>300 & x<351;
            x(sel)  = 1:50;
            sel     = x>350 & x<401;
            x(sel)  = 1:50;
            plot(x)

   %% Rough Comparison first and second part of one round (1-50)
            
        figure(3) % Results 1-25
            SupSac(:,1) = x;
            SS          =SupSac;
            sel         = abs(SS(:,1))<26;
            First       = SS(sel,:);
            pa_plotloc(First);
        
        
        figure(4)% Results 26-50
            SupSac(:,1) =x;
            SS          =SupSac;
            sel         = abs(SS(:,1))>25;
            Second      = SS(sel,:);
            pa_plotloc(Second);
        
        figure(5)% Selection for first and second half on 10 degree targets
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
            
    %% Finer Comparison, (first) 10-25 and (second) 30-40 part of one round (1-50)
            
        figure(6) % Results 10-25
            SupSac(:,1) = x;
            SS          =SupSac;
            sel         = abs(SS(:,1))>=5 & abs(SS(:,1))<=20;
            First       = SS(sel,:);
            pa_plotloc(First);
        
        
        figure(7)% Results 30-40
            SupSac(:,1) =x;
            SS          =SupSac;
            sel         = abs(SS(:,1))>=30 & abs(SS(:,1))<=45;
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
