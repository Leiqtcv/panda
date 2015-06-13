function A6_Analyse

%% SUPSAC_SL beinhaltet die Data von RG, PH, CK
% Jetzt probiere ich, diese Data zusammen zu analysieren

close all
clear all
clc

fnames = {'JR-RG-2012-04-06-0001';'RG-TH-2012-04-27-0001';'RG-JR-2012-04-26-0001';'RG-EZ-2012-04-20-0001';'RG-PH-2012-04-23-0001';'RG-CK-2012-04-23-0001';'RG-BK-2012-04-24-0001';'RG-LJ-2012-04-25-0001';'RG-EZ-2012-04-24-0001';'RG-LK-2012-04-26-0001'}; %Short Long
% fnames = {'JR-RG-2012-04-06-0002';'RG-TH-2012-04-13-0001';'RG-JR-2012-04-16-0001';'RG-PH-2012-04-17-0001';'RG-CK-2012-04-17-0001';'RG-EZ-2012-04-19-0001';'RG-PH-2012-04-19-0001';'RG-CK-2012-04-19-0001';'RG-BK-2012-04-25-0001';'RG-LJ-2012-04-24-0001';'RG-EZ-2012-04-26-0001';'RG-LK-2012-04-24-0001'}; % Long Short


% % fnames = {'JR-RG-2012-04-06-0001';'JR-RG-2012-04-06-0002';'RG-JR-2012-04-26-0001';'RG-JR-2012-04-16-0001';'RG-PH-2012-04-13-0001';'RG-PH-2012-04-17-0001';'RG-PH-2012-04-23-0001';'RG-PH-2012-04-19-0001';'RG-CK-2012-04-13-0001';'RG-CK-2012-04-17-0001';'RG-CK-2012-04-23-0001';'RG-CK-2012-04-19-0001'}; %Short Long
% % fnames = {'RG-TH-2012-04-27-0001';'RG-TH-2012-04-13-0001';'RG-EZ-2012-04-20-0001';'RG-EZ-2012-04-19-0001';'RG-BK-2012-04-24-0001';'RG-BK-2012-04-25-0001';'RG-LJ-2012-04-25-0001';'RG-LJ-2012-04-24-0001';'RG-EZ-2012-04-24-0001';'RG-EZ-2012-04-26-0001';'RG-LK-2012-04-26-0001';'RG-LK-2012-04-24-0001'}; %Short Long


% fnames = {'JR-RG-2012-04-06-0002';'RG-PH-2012-04-17-0001';'RG-PH-2012-04-19-0001';'RG-EZ-2012-04-19-0001';'RG-JR-2012-04-19-0001'}; % Long Short, selected
% fnames = {'JR-RG-2012-04-06-0001';'RG-PH-2012-04-13-0001';'RG-PH-2012-04-23-0001';'RG-LJ-2012-04-25-0001'}; %Short Long, selected
% fnames = {'JR-RG-2012-04-12-0001'}; %Short Long Short
% fnames = {'RG-CK-2012-04-17-0001'}; 
GAIN = NaN(length(fnames),500);
for jj= 1:length(fnames)
    fname = fnames{jj};
    pa_datadir(fname(1:end-5));
    load(fname); %load fnames(ii) = load('fnames(ii)');
    SupSac      = pa_supersac(Sac,Stim,2,1);
    
 
    
    %%
    X           = SupSac(:,1);
    Y           = SupSac(:,24);
    Z           = SupSac(:,9);
    sigma       = 10;

    setdiff(1:500,X)
    XI              = X;
    % [Gain(:,jj),se,xi]    = rg_weightedregress(X,Y,Z,5,XI,'wfun','gaussian');
    [Gain,se,xi]    = rg_weightedregress(X,Y,Z,sigma,XI,'wfun','gaussian');
    whos Gain se xi XI
    n       = size(X,1); % number of trials
    x = 1:10:n;

    
    figure(5)
    subplot(5,2,(jj))
    hold on
    pa_errorpatch(xi,Gain,se);
    plot(X,Y./45,'k-','Color',[.7 .7 .7]);
    hold on
    x = x(1:end-1);
    ylim([-0.2 3])
    whos GAIN Gain
    GAIN(jj,:) = Gain';
    pa_verline(250);
end

muG = mean(GAIN);
seG = std(GAIN)./sqrt(size(GAIN,1));
figure
pa_errorpatch(xi,muG,seG,'r');
ylim([0 2]);
pa_horline(1);
pa_verline(250);