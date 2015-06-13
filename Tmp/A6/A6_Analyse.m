function A6_Analyse

%% SUPSAC_SL beinhaltet die Data von RG, PH, CK
% Jetzt probiere ich, diese Data zusammen zu analysieren

close all
clear all
clc
% pa_datadir JR-RG-2012-04-06
% load JR-RG-2012-04-06-0001
% load JR-RG-2012-04-06-0002
% %
% pa_datadir JR-RG-2012-04-12
% load JR-RG-2012-04-12-0001
%
% pa_datadir RG-TH-2012-04-13
% load RG-TH-2012-04-13-0001
%
% pa_datadir RG-PH-2012-04-13
% load RG-PH-2012-04-13-0001
%
% pa_datadir RG-CK-2012-04-13
% load RG-CK-2012-04-13-0001
%
% pa_datadir RG-JR-2012-04-16
% load RG-JR-2012-04-16-0001

% pa_datadir RG-PH-2012-04-17
% load RG-PH-2012-04-17-0001

% pa_datadir RG-CK-2012-04-17
% load RG-CK-2012-04-17-0001

%
% SupSac = pa_supersac(Sac,Stim,2,1);
% whos SupSac
% load SUPSAC_SL
% SupSac = SupSacSL;
%
% SupSac(251:500,1) = 1:1:250;
% SupSac(501:750,1) = 1:1:250;
% SupSac(751:1000,1) = 251:1:500;
% SupSac(1001:1250,1) = 251:1:500;
% SupSac(1251:1500,1) = 251:1:500;
% whos SupSac
% SupSac(:,1)

% fnames = {'JR-RG-2012-04-06-0001';'RG-PH-2012-04-13-0001';'RG-CK-2012-04-13-0001'};
% fnames = {'JR-RG-2012-04-06-0002';'RG-TH-2012-04-13-0001';'RG-JR-2012-04-16-0001';'RG-PH-2012-04-17-0001';'RG-CK-2012-04-17-0001'};
% fnames = {'JR-RG-2012-04-12-0001'};
% fnames = {'JR-RG-2012-04-06-0002';...
%     'RG-TH-2012-04-13-0001';...
%     'RG-JR-2012-04-16-0001';...
%     'RG-PH-2012-04-17-0001';...
%     'RG-CK-2012-04-17-0001';...
%     'RG-PH-2012-04-19-0001';...
%     'RG-EZ-2012-04-19-0001';...
%     'RG-CK-2012-04-19-0001';...
%     'RG-JR-2012-04-19-0001'}; % Long Short
% fnames = {'RG-PH-2012-04-17-0001'};

fnames = {'JR-RG-2012-04-06-0001';'RG-JR-2012-04-26-0001';'RG-PH-2012-04-13-0001';'RG-PH-2012-04-23-0001';'RG-CK-2012-04-13-0001';'RG-CK-2012-04-23-0001';'RG-TH-2012-04-27-0001';'RG-EZ-2012-04-20-0001';'RG-BK-2012-04-24-0001';'RG-LJ-2012-04-25-0001';'RG-EZ-2012-04-24-0001';'RG-LK-2012-04-26-0001'}; %Short Long
% fnames = {'JR-RG-2012-04-06-0002';'RG-JR-2012-04-16-0001';'RG-PH-2012-04-17-0001';'RG-PH-2012-04-19-0001';'RG-CK-2012-04-17-0001';'RG-CK-2012-04-19-0001';'RG-TH-2012-04-13-0001';'RG-EZ-2012-04-19-0001';'RG-BK-2012-04-25-0001';'RG-LJ-2012-04-24-0001';'RG-EZ-2012-04-26-0001';'RG-LK-2012-04-24-0001'}; % Long Short

% fnames = {'JR-RG-2012-04-06-0001';'JR-RG-2012-04-06-0002';'RG-JR-2012-04-26-0001';'RG-JR-2012-04-16-0001';'RG-PH-2012-04-13-0001';'RG-PH-2012-04-17-0001';'RG-PH-2012-04-23-0001';'RG-PH-2012-04-19-0001';'RG-CK-2012-04-13-0001';'RG-CK-2012-04-17-0001';'RG-CK-2012-04-23-0001';'RG-CK-2012-04-19-0001'}; %Short Long
% fnames = {'RG-TH-2012-04-27-0001';'RG-TH-2012-04-13-0001';'RG-EZ-2012-04-20-0001';'RG-EZ-2012-04-19-0001';'RG-BK-2012-04-24-0001';'RG-BK-2012-04-25-0001';'RG-LJ-2012-04-25-0001';'RG-LJ-2012-04-24-0001';'RG-EZ-2012-04-24-0001';'RG-EZ-2012-04-26-0001';'RG-LK-2012-04-26-0001';'RG-LK-2012-04-24-0001'}; %Short Long
GAIN = NaN(length(fnames),500);
for jj= 1:length(fnames)
    fname = fnames{jj};
    pa_datadir(['Prior\' fname(1:end-5)]);
    load(fname); %load fnames(ii) = load('fnames(ii)');
    SupSac      = pa_supersac(Sac,Stim,2,1);
%     max(SupSac(:,24))
%     return
    
    figure(1)
    hold on
    sela = SupSac(:,1)<=length(SupSac)/2;
    % sela = SupSac(:,1)<= 250;
    SupSaca = SupSac(sela,:);
%     sel1 = SupSaca(:,24)>6 | SupSaca(:,24)<-6;
%     SupSaca = SupSaca(sel1,:);
subplot(3,4,jj)
    pa_plotloc(SupSaca);
%     pa_loc(SupSaca(:,24),SupSaca(:,9));

    x = -90:5:90;
    y = SupSaca(:,9);
    N = hist(y,x);
    N = N./max(N);
    N = N*90;
    N = N-90;
    figure(1);
%     plot(N,x,'r-','LineWidth',2);
    

    x = -90:5:90;
    y = SupSaca(:,24);
    N = hist(y,x);
    N = N./max(N);
    N = N*90;
    N = N-90;
    figure(1);
%     plot(x,N,'b-','LineWidth',2);

    %% K-means clustering
    opts = statset('Display','final');
X = SupSaca(:,9);
[idx,ctrs] = kmeans(X,2);
plot(SupSaca(idx==1,24),SupSaca(idx==1,9),'ko','MarkerFaceColor','r');
plot(SupSaca(idx==2,24),SupSaca(idx==2,9),'ko','MarkerFaceColor','b');
V = [idx];

SuSa = SupSac(1:250,:);
length(SuSa);
SuSa = [SuSa,V];




    for hh = 1:23
        f = (-60+(hh*5));
        k = find(SuSa(:,24)==f);
        Susa = SuSa(k,:);
        v = Susa(:,31)==1;
        w = Susa(:,31)==2;
        Husa = Susa(v,9);
        length(Husa);
        Wusa = Susa(w,9);
        length(Wusa);

        if length(Husa) == 0;
            O = mean(Wusa);
        elseif length(Wusa) == 0;
            O = mean(Husa);
        else
            O = (mean(Husa)*length(Husa)+mean(Wusa)*length(Wusa))/(length(Wusa)+length(Husa));
        end
%         O(hh)=O
        figure(2)
        subplot(3,4,jj)
        hold on
        plot(f,O,'o')
        pa_unityline
        axis([-90 90 -90 90])
        H(hh)=O;    %gewogen gemiddelde (Response)
%         T = T'
        I(hh)=f;    %Target locatie
%         F = F
    end
    H= H';
    I=I';
     
%     [b] = regress(H,I);
%     B1 = b


%     return
    figure(3)
    subplot(3,4,jj)
    hold on
    selb = SupSac(:,1)>(length(SupSac)/2);
    SupSacb = SupSac(selb,:);
%     sel1 = SupSacb(:,24)>6 | SupSacb(:,24)<-6
%     SupSacb = SupSacb(sel1,:);
    pa_plotloc(SupSacb);
     
    % figure(33)
    % selc = SupSac(:,1)>500 %length(SupSac);
    % SupSacc = SupSac(selc,:);
    % pa_plotloc(SupSacc);
    
        x = -90:5:90;
    y = SupSacb(:,9);
    N = hist(y,x);
    N = N./max(N);
    N = N*90;
    N = N-90;
    figure(3);
%     plot(N,x,'r-','LineWidth',2);
    

    x = -90:5:90;
    y = SupSacb(:,24);
    N = hist(y,x);
    N = N./max(N);
    N = N*90;
    N = N-90;
    figure(3);
%     plot(x,N,'b-','LineWidth',2);
    
    %% K-means clustering
    opts = statset('Display','final');
X = SupSacb(:,9);
[idx,ctrs] = kmeans(X,2);
plot(SupSacb(idx==1,24),SupSacb(idx==1,9),'ko','MarkerFaceColor','r');
plot(SupSacb(idx==2,24),SupSacb(idx==2,9),'ko','MarkerFaceColor','b');

SuSa = SupSac(251:500,:);
length(SuSa);
SuSa = [SuSa,V];

% return
 for hh = 1:23
        f = (-60+(hh*5));
        k = find(SuSa(:,24)==f);
        Susa = SuSa(k,:);
        v = Susa(:,31)==1;
        w = Susa(:,31)==2;
        Husa = Susa(v,9);
        length(Husa);
        Wusa = Susa(w,9);
        length(Wusa);

        if length(Husa) == 0;
            O = mean(Wusa);
        elseif length(Wusa) == 0;
            O = mean(Husa);
        else
            O = (mean(Husa)*length(Husa)+mean(Wusa)*length(Wusa))/(length(Wusa)+length(Husa));
        end
%         O(hh)=O
        figure(4)
        subplot(3,4,jj)
        hold on
        plot(f,O,'o');
        pa_unityline;
        axis([-90 90 -90 90]);
        T(hh)=O;    %gewogen gemiddelde (Response)
%         T = T'
        F(hh)=f;    %Target locatie
%         F = F
        %%%%%%%%%%% gewogen Gemiddelde berekenen van punten per locatie,
        %%%%%%%%%%% twee groepen (indx 1 of 2), per aantal wiegen en dan
        %%%%%%%%%%% gewogen gemiddelde. alle nieuwe gemiddeldes op en lijn.
%      end
    end
    T= T';
    F=F';
%     return
% [b] = regress(T,F);
% B2 = b
% r


   
    % Target-Response Overview
    figure (5)
    subplot(3,4,jj)
    hold on
%     sel = SupSac(:,24)>6 | SupSac(:,24)<-6;
%     SupSac = SupSac(sel,:);
    plot(SupSac(:,23),SupSac(:,24),'o')
    hold on
    plot(SupSac(:,8),SupSac(:,9),'ro')
    xlim ([-50 50])
    figure (6)
    subplot(3,4,jj)
    hold on
    x = 1:length(SupSac(:,1));
    y = SupSac(:,24)';
    z = SupSac(:,9)';
    
    plot(x,y)
    hold on
    plot(x,z,'r');
    

%     for hh = 1:23;
%         f = (-60+(hh*5));
% %         Susa = SupSac(251:500,24)==f;
%         Susa = SupSac(1:250,24)==f;
%         k = find(Susa);
%         Susa = Susa(k,:);
%         m = mean(Susa(:,9));
%         s = std(Susa(:,9));
%         figure(331)
%         errorbar(f,m,s,'o');
%         hold on;
%         pa_horline;
%         pa_verline;
%         axis ([-90 90 -90 90])
%     end

%     for hh = 1:11;
p_value1 = NaN(23,1);
        for hh = 1:23;
            try
%             if hh==1|hh==2|hh==3|hh==4|hh==5|hh==6|hh==7|hh==8|hh==9|hh==10|hh==11|hh==13|hh==14|hh==15|hh==16||hh==17|hh==18|hh==19|hh==20|hh==21|hh==22|hh==23;
        f = (-60+(hh*5));
        SuSa = SupSac(1:250,:);
        k = find(SuSa(:,24)==f);
        Susa = SuSa(k,:);
        Husa = Susa(:,9);
        l = length(Husa);
        [dip, p_value, xlow,xup]=pa_HartigansDipSignifTest(Husa,l);
        p_value1(hh) = p_value;
        TR = Susa(:,9);
        m = mean(Susa(:,9));
        s = std(Susa(:,9));
        figure(7)
        subplot(3,4,jj)
        errorbar(f,m,s,'o');
        hold on;
        pa_horline;
        pa_verline;
        pa_unityline;
        axis ([-90 90 -90 90])
        
%          figure(8)
% %         o = hh;
%         o = hh;
%         subplot(4,6,o)
%         hist(TR)
% %         figure(hh)
% %         hist(SuSa)
            end
    end
p_value2 = NaN(23,1);
    for hh = 1:23
        try
%         if hh== 9|hh==10|hh==11|hh==13|hh==14|hh==15;
%     for hh = 13:15;
        f = (-60+(hh*5));
        SuSa = SupSac(251:500,:);
        k = find(SuSa(:,24)==f);
        Susa = SuSa(k,:);
        Husa = Susa(:,9);
        l = length(Husa);
        [dip, p_value, xlow,xup]=pa_HartigansDipSignifTest(Husa,l);
        p_value2(hh) =p_value;
%         max(SuSa(:,9))
%         min(SuSa(:,9))
        TR = Susa(:,9);
        m = mean(Susa(:,9));
        s = std(Susa(:,9));
        figure(9)
        subplot(3,4,jj)
        errorbar(f,m,s,'o');
        hold on;
        pa_horline;
        pa_verline;
        pa_unityline;
        axis ([-90 90 -90 90])
%         figure(10)
%         o = hh-8;
% %         o = hh-12;
%         subplot(4,6,o)
%         hist(TR)
        end
        
    end
    
    p_value1
    p_value2
 
    if numel(SupSac(:,1))>length(SupSac);
        %% Gain
        sel1     = abs(SupSac(:,1))<=length(SupSac)/2;
        SupSac1  = SupSac(sel1,:);
        y       = SupSac1(:,9);
        x       = SupSac1(:,24);
        stats   = regstats(y,x,'linear','all');
        b       = stats.beta;
        B1   = b(2);
        se      = stats.tstat.se;
        SE1  = se(2);
        
        % B1
        % SE1
        
        sel2     = abs(SupSac(:,1))>length(SupSac)/2 & abs(SupSac(:,1)<=length(SupSac));
        SupSac2  = SupSac(sel2,:);
        y2       = SupSac2(:,9);
        x2       = SupSac2(:,24);
        stats2   = regstats(y2,x2,'linear','all');
        b2       = stats2.beta;
        B2   = b2(2);
        se2      = stats2.tstat.se;
        SE2  = se2(2);
        
        % B2
        % SE2
        
        sel3     = abs(SupSac(:,1))>length(SupSac);
        SupSac3  = SupSac(sel3,:);
        y3       = SupSac3(:,9);
        x3       = SupSac3(:,24);
        stats3   = regstats(y3,x3,'linear','all');
        b3       = stats3.beta;
        B3   = b3(2);
        se3      = stats3.tstat.se;
        SE3  = se3(2);
        
        % B3
        % SE3
    else
        sel1     = abs(SupSac(:,1))<=length(SupSac)/2;
        SupSac1  = SupSac(sel1,:);
        y       = SupSac1(:,9);
        x       = SupSac1(:,24);
        stats   = regstats(y,x,'linear','all');
        b       = stats.beta;
        B1   = b(2);
        se      = stats.tstat.se;
        SE1  = se(2);
        
        % B1
        % SE1
        
        sel2     = abs(SupSac(:,1))>length(SupSac)/2 & abs(SupSac(:,1)<=length(SupSac));
        SupSac2  = SupSac(sel2,:);
        y2       = SupSac2(:,9);
        x2       = SupSac2(:,24);
        stats2   = regstats(y2,x2,'linear','all');
        b2       = stats2.beta;
        B2   = b2(2);
        se2      = stats2.tstat.se;
        SE2  = se2(2);
        
        % B2
        % SE2
    end
%     
    %%
    X           = SupSac(:,1);
    Y           = SupSac(:,24);
    Z           = SupSac(:,9);
    sigma       = 10;
    % Gain   = getdynamics(X,Y,Z,sigma);
    title ('Elevation')
    
    % end
    
    
    % function Gain = getdynamics(X,Y,Z,sigma)
    
    XI              = X;
    % [Gain(:,jj),se,xi]    = rg_weightedregress(X,Y,Z,5,XI,'wfun','gaussian');
    [Gain,se,xi]    = pa_weightedregress(X,Y,Z,sigma,XI,'wfun','gaussian');
    n       = size(X,1); % number of trials
    x       = 1:n;
    x = 1:10:n;
    G = x(1:end-1);
    for ii = 1:length(x)-1;
        sel = X>x(ii)& X<x(ii+1);
        sum(sel);
        G(ii) = nanmean(Z(sel)./Y(sel));
        SD(ii) = nanstd(Z(sel)./Y(sel));
    end
    
    
    figure(11)
    hold on
    subplot(6,2,(jj))
    hold on
    % pa_errorpatch(xi,Gain(:,jj),se);
    
    pa_errorpatch(xi,Gain,se);
    plot(X,Y./45,'k-','Color',[.7 .7 .7]);
    hold on
    x = x(1:end-1);
    ylim([-0.2 3])
    % pa_errorpatch(x+5,G,SD,'r');
    % xlim([1 mx])
    whos GAIN Gain
    GAIN(jj,:) = Gain;
end

muG = mean(GAIN);
sdG = std(GAIN);
% figure
% pa_errorpatch(xi,muG,sdG,'r');
