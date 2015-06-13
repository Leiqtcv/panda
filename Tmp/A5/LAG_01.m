function LAG_01
close all
clear all

fnames = {'JR-RG-2012-02-22-0001';'JR-RG-2012-03-07-0001'; 'RG-JR-2012-02-28-0001'; 'RG-JR-2012-03-13-0001';...
    'RG-HH-2012-02-29-0001';'RG-RO-2012-03-08-0001'; 'RG-TH-2012-03-09-0001'; 'RG-MW-2012-03-13-0001'; 'RG-CK-2012-03-13-0001'; 'RG-BK-2012-03-13-0001';...
    'RG-DM-2012-03-15-0001'; 'RG-LJ-2012-03-22-0001'};    
nsets = length(fnames);

for ii = 1:nsets
    fname = fnames{ii};
            pa_datadir(['\Prior\' fname(1:end-5)]);
    load(fname); %load fnames(ii) = load('fnames(ii)');
    SupSac      = pa_supersac(Sac,Stim,2,1);
    


%% Elevation

%% Weighted regression
X           = SupSac(:,1);
Y           = SupSac(:,24);
Z           = SupSac(:,9);
sigma       = 5;
[Gain,Mu]   = getdynamics(X,Y,Z,sigma);

%%
sel = isnan(Mu) | isnan(Gain);
Mu      = Mu(~sel);
Gain    = Gain(~sel);

[C,lags] = xcorr(Mu,Gain,100,'coeff');
[ACm,lags] = xcorr(Mu,Mu,100,'coeff');
[ACg,lags] = xcorr(Gain,Gain,100,'coeff');

[mx,indx] = max(C);
Lagel(ii) = lags(indx)

%% Azimuth 

%% Weighted regression
X           = SupSac(:,1);
Y           = SupSac(:,23);
Z           = SupSac(:,8);
sigma       = 5;
[Gain,Mu]   = getdynamics(X,Y,Z,sigma);


%%
sel = isnan(Mu) | isnan(Gain);
Mu      = Mu(~sel);
Gain    = Gain(~sel);

[C,lags] = xcorr(Mu,Gain,100,'coeff');
[ACm,lags] = xcorr(Mu,Mu,100,'coeff');
[ACg,lags] = xcorr(Gain,Gain,100,'coeff');


[mx,indx] = max(C);

Lagaz(ii) = lags(indx)
end
figure
hist(Lagel)
figure
hist(Lagaz)

datdir              = 'DAT';

save ('Lags_01', 'Lagel','Lagel')

function [Gain,Mu] = getdynamics(X,Y,Z,sigma)

XI              = X;
[Gain,se,xi]    = pa_weightedregress(X,Y,Z,sigma*2,XI);
n       = 400; % 
x       = 1:n;
freq	= 0.01;
sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
sd      = sd/max(sd);

Yb              = abs(Y);
mx              = max(X);
[Mu,sei,xi]    = pa_weightedmean(X,Yb,sigma,XI,'nboot',10);
