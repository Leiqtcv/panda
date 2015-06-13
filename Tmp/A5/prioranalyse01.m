   function prioranalyse01
close all
clear all     
        % RG1, RG2, RGcomb, JR1, JR2, HH, RO, TH, MW, CK, BK, DM, LJ
     subject = 'LJ';
     
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
        
            case 'JR1'
                    pa_datadir RG-JR-2012-02-28
                    load RG-JR-2012-02-28-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
                           
            case 'JR2'
                    pa_datadir RG-JR-2012-03-13
                    load RG-JR-2012-03-13-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
           
            
            case 'HH'
                    pa_datadir RG-HH-2012-02-29
                    load RG-HH-2012-02-29-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);

       
            case 'RO'
                    pa_datadir RG-RO-2012-03-08
                    load RG-RO-2012-03-08-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
        
            case 'TH'
                    pa_datadir RG-TH-2012-03-09
                    load RG-TH-2012-03-09-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);

        
            case 'MW'
                    pa_datadir RG-MW-2012-03-13
                    load RG-MW-2012-03-13-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);                   
        
            case 'CK'
                    pa_datadir RG-CK-2012-03-13
                    load RG-CK-2012-03-13-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
        
            case 'BK'
                    pa_datadir RG-BK-2012-03-13
                    load RG-BK-2012-03-13-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);
       
            case 'MWcont'
                pa_datadir RG-MW-2012-03-15
                load RG-MW-2012-03-15-0001
                SupSac = pa_supersac(Sac,Stim,2,1);

        
            case 'DM'
                pa_datadir RG-DM-2012-03-15
                load RG-DM-2012-03-15-0001
                SupSac = pa_supersac(Sac,Stim,2,1);
                sel = SupSac(:,24)> 0 ;
                SSelst = SupSac(sel,24);
                SSelre = SupSac(sel,9);
                pa_loc(SSelst,SSelre)   
                
                
             case 'LJ'
                    pa_datadir RG-LJ-2012-03-22
                    load RG-LJ-2012-03-22-0001
                    SupSac = pa_supersac(Sac,Stim,2,1);


        end      
        
 % Stimulus-Response Plot
        figure 
        pa_plotloc(SupSac);
 % Target-Response Overview
        figure
        plot(SupSac(:,23),SupSac(:,24),'o')
        hold on
        plot(SupSac(:,8),SupSac(:,9),'ro')


%% Elevation

%% Weighted regression
X           = SupSac(:,1);
Y           = SupSac(:,24);
Z           = SupSac(:,9);
sigma       = 5;
[Gain,Mu]   = getdynamics(X,Y,Z,sigma);
% title ('Elevation')
return

figure
plot(Gain,Mu,'k.');
axis square;
% title ('Elevation')

%%
sel = isnan(Mu) | isnan(Gain);
Mu      = Mu(~sel);
Gain    = Gain(~sel);

[C,lags] = xcorr(Mu,Gain,100,'coeff');
[ACm,lags] = xcorr(Mu,Mu,100,'coeff');
[ACg,lags] = xcorr(Gain,Gain,100,'coeff');

figure

subplot(221);
plot(lags,ACm,'k.-');
pa_verline;
xlabel('Lag (# trials)');
ylabel('Cross-correlation');

subplot(222);
plot(lags,ACg,'k.-');
pa_verline;
xlabel('Lag (# trials)');
ylabel('Cross-correlation');

subplot(212)
[mx,indx] = max(C);
plot(lags,C,'k.-');
pa_verline;
pa_verline(lags(indx),'r--');
xlabel('Lag (# trials)');
ylabel('Cross-correlation');
title ('Elevation')
M = lags(indx)
%% Azimuth 

%% Weighted regression
X           = SupSac(:,1);
Y           = SupSac(:,23);
Z           = SupSac(:,8);
sigma       = 5;
[Gain,Mu]   = getdynamics(X,Y,Z,sigma);
title ('Azimuth')


figure 
plot(Gain,Mu,'k.');
axis square;
title ('Azimuth')
%%
sel = isnan(Mu) | isnan(Gain);
Mu      = Mu(~sel);
Gain    = Gain(~sel);

[C,lags] = xcorr(Mu,Gain,100,'coeff');
[ACm,lags] = xcorr(Mu,Mu,100,'coeff');
[ACg,lags] = xcorr(Gain,Gain,100,'coeff');

figure 
subplot(221);
plot(lags,ACm,'k.-');
pa_verline;
xlabel('Lag (# trials)');
ylabel('Cross-correlation');

subplot(222);
plot(lags,ACg,'k.-');
pa_verline;
xlabel('Lag (# trials)');
ylabel('Cross-correlation');

subplot(212)
[mx,indx] = max(C);
plot(lags,C,'k.-');
pa_verline;
pa_verline(lags(indx),'r--');
xlabel('Lag (# trials)');
ylabel('Cross-correlation');
title ('Azimuth')
K = lags(indx)


function [Gain,Mu] = getdynamics(X,Y,Z,sigma)

XI              = X;
[Gain,se,xi]    = rg_weightedregress(X,Y,Z,sigma*2,XI,'wfun','half');
n       = 400; % 
x       = 1:n;
freq	= 0.01;
sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
sd      = sd/max(sd);
freq2 = 0.005;
sd2		= 40*sin(2*pi*freq2*x+0.5*pi).^2+5;
sd2      = sd2/max(sd2);
freq3 = 0.002;
sd3		= 40*sin(2*pi*freq3*x+0.5*pi).^2+5;
sd3      = sd3/max(sd3);

Yb              = abs(Y);
mx              = max(X);
[Mu,sei,xi]    = rg_weightedmean(X,Yb,sigma,XI,'nboot',10);

figure
subplot(211)
plot(x,sd,'r','LineWidth',2);
hold on
pa_errorpatch(xi,Gain,se);
% plot(X,abs(Y)./45,'k-','Color',[.7 .7 .7]);
% pa_errorpatch(xi, Mu/20, sei(:,1)/100,'b');
xlim([1 mx])

% figure(6)
% title('Stimulus Location Distribution')
% subplot(311)
% plot(x,sd,'r','LineWidth',2);
% subplot(312)
% plot(x,sd2,'r','LineWidth',2);
% subplot(313)
% plot(x,sd3,'r','LineWidth',2);
% xlabel('Trial')
% ylabel('Trial')