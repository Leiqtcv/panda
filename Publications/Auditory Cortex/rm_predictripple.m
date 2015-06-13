function [Corr,Y] = rm_predictripple(strfFname,dname,varargin)

% PA_PREDICTVOCAL
%
% Assumptions: 0.25 octave, 2.5 octave bandwidth

%% Initialization
close all


close all;
clear all;
clc;
% PA_PREDICTVOCAL
%
% Assumptions: 0.25 octave, 2.5 octave bandwidth

%% Initialization
% cd('D:\all Data\Third paper\files for Boudewijn\selected for perediction');
% cd ('F:\all Data\Third paper\Third paper_Qselected\read cells');
cd('E:\DATA\Cortex\response prediction materials\read cells');
thorfiles = dir('thor*');
joefiles  = dir('joe*');

files     = [thorfiles' joefiles'];
msgid	  = 'stats:nlinfit:IllConditionedJacobian';

warning('off',msgid);

k         = 0;
dspFlag   = 1;
CORR      = [];
SCOR      = [];
NPSCOR    = [];
OCORR     = [];

for jj    = 199:length(files)
    disp(jj);
    close all;
    
    strfFname = files(jj).name;
    disp(strfFname)
    load(strfFname);
    age                     =  q25 > 0.387 || q50 > 0.376;
    if age
        k                   = k+1
        [Y,Corr,Scorr,npScorr,Ocorr]      = getdata(spikeP,dspFlag);
        CORR(k)           = max(Corr(:));
        SCOR(k)           = Scorr;
        NPSCOR(k)         = npScorr;
        OCORR(k)          = Ocorr;
    end
end
keyboard
save('predic-corr','CORR','SCOR','NPSCOR','OCORR');

%% plot DF vs. SCOR
cd ('F:\all Data\Third paper\Third paper_Qselected\read cells');
load('SF-BF');

plot(DF,SCOR,'ko');
axis([-0.1 1.3 -0.1 1.3]);
unityline;
axis square;
box off;
r  = corrcoef(DF,SCOR);
title(num2str(r(2)));
xlabel('DBF');
ylabel('correlation between predicted vs. real noise responses');

%% plot correlation histograms

cd ('F:\all Data\Third paper\Third paper_Qselected\read cells');
load('predic-corr');

% plot ripple correlations
close all;
figure;
subplot(221)
sel = ~isnan(CORR);
COR = CORR(sel);
stp = range(COR)/sqrt(length(COR));
x   = -1:stp:1;
h   = hist(COR,x);
bar(x,h,'k','stacked');
axis square;
box off;
axis([-1 1.1 0 36]);
pa_verline(nanmedian(COR));
pa_verline(0,'k-');
xlabel('correlation coefficient');
ylabel('number of cells');
title(['median=' num2str(nanmedian(COR))]);

% plot static correlation with onset peak

subplot(222)
stp = range(SCOR)/sqrt(length(SCOR));
x   = -1:stp:1;
h   = hist(SCOR,x);
bar(x,h,'k','stacked');
axis square;
box off;
axis([-1 1.1 0 36]);
pa_verline(nanmedian(SCOR));
pa_verline(0,'k-');
xlabel('correlation coefficient');
ylabel('number of cells');
title(['median=' num2str(nanmedian(SCOR))]);

% plot static correlation with onset peak

subplot(223)
stp = range(OCORR)/sqrt(length(OCORR));
x   = -1:stp:1;
h   = hist(OCORR,x);
bar(x,h,'k','stacked');
axis square;
box off;
axis([-1 1.1 0 36]);
pa_verline(nanmedian(OCORR));
pa_verline(0,'k-');
xlabel('correlation coefficient');
ylabel('number of cells');
title(['median=' num2str(nanmedian(OCORR))]);

subplot(224)
stp = range(NPSCOR)/sqrt(length(NPSCOR));
x   = -1:stp:1;
h   = hist(NPSCOR,x);
bar(x,h,'k','stacked');
axis square;
box off;
axis([-1 1.1 0 36]);
pa_verline(nanmedian(NPSCOR));
pa_verline(0,'k-');
xlabel('correlation coefficient');
ylabel('number of cells');
title(['median=' num2str(nanmedian(NPSCOR))]);

function [Y,Corr,Scorr,npScorr,Ocorr] = getdata(Spike,dspFlag)
dt = 12.5;
di = 1;
strf		= pa_spk_ripple2strf(Spike);
norm        = strf.norm(:);
strf		= strf.strf;

% sm          = strf(:,1:4);
% nm          = sum(sm(:));%*0.0125*0.25;
% strf        = strf./nm;
%% Obtain firing rate during different periods
A	        = [Spike.spiketime];
A	        = A-300; % Remove the default 300 ms silent period
Dstat		= NaN(size(Spike));
Drand		= Dstat;
Velocity	= NaN(size(Spike));
Density		= Dstat;
MD			= Dstat;
for ii      = 1:length(Spike)
    Dstat(ii)		= Spike(ii).stimvalues(3);
    Drand(ii)		= Spike(ii).stimvalues(4);
    Velocity(ii)	= Spike(ii).stimvalues(5);
    Density(ii)		= Spike(ii).stimvalues(6);
    MD(ii)			= Spike(ii).stimvalues(7);
end
% A			= A-Dstat;
% Some rounding, or else Matlab will not recognize certain values correctly
% due to rounding precision
Velocity	= round(Velocity*1000)/1000;
Density		= round(Density*1000)/1000;
MD			= round(MD);

% And get unique values
uV			= unique(Velocity);
uD			= unique(Density);
uM			= unique(MD);

%% Get STRF
Corr	= squeeze(NaN([numel(uV) numel(uD) numel(uM)]));
q       = 0;
sFr     = [];
sSr     = [];

for ii = 1:numel(uV)
    %     for jj = 1:numel(uD)
    for kk = 1:numel(uM)
        q       = q + 1;
        uV(ii)
%         uD(jj)
        disp('------------');
        v       = uV(ii);
        selv	= Velocity==uV(ii);
        seld	= Density== 0;
        selm	= MD==uM(kk);
        sel		= selv & seld & selm;
        s		= Spike(sel);
        nrep	= sum(sel);
        tim		= [s.spiketime];
        x		= 0:(dt/di):2500;
        fr		= hist(tim,x)/(dt/di)*1000/nrep;
        qf      = norm(q);
        mfr     = mean(fr);
        
        Y       = pa_genripple(uV(ii),0,uM(kk),1000,500,'display',0);
        S		= rm_spk_predict(strf,Y,dt,'display',0,'interp',di,'abs',1);
        
        
        if mfr > 20 && qf > 0.4;
            sel     = x>=300 & x < 1800;
            Fr      = fr(sel);
            n       = length(S);
            Fr      = Fr(1:n);
            t       = (0:length(Fr)-1)*dt;
            sel     = t < 500;
            sFr(q,:) = Fr(sel);
            sSr(q,:) = S(sel);
            sel     = t > 500;
            r       = corrcoef(S(sel),Fr(sel));
            Corr(ii,kk) = r(2);
            if dspFlag
                figure(1000)
                X = t(sel);
                Y = Fr(sel);
                plot(X,Y,'k-','LineWidth',2);    
                hold on
                Y = S(sel);
                plot(X,Y,'r-','LineWidth',2);
                box off
                str = ['r = ' num2str(r(2),2)];
                title(str);
                keyboard
            end
            clf;
        else
            sel     = x>=300 & x < 1800;
            Fr      = fr(sel);
            n       = length(S);
            Fr      = Fr(1:n);
            t       = (0:length(Fr)-1)*dt;
            sel     = t < 500;
            sFr(q,:)= Fr(sel);
            sSr(q,:)= S(sel);
            Corr(ii,kk) = NaN;
        end
        
    end
    %     end
end

SFR  = nanmean(sFr);
SSR  = nanmean(sSr);
corr = corrcoef(SSR,SFR);
g    = corrcoef(SSR(7:40),SFR(7:40));
o    = corrcoef(SSR(1:7),SFR(1:7));

if corr > 0.7
    disp(corr)
    disp(g)
    close all;
    subplot(121)
    h1 = plot(SSR,'r-','LineWidth',2);
    hold on;
    h2 = plot(SFR*0.25,'k-','LineWidth',2);
    legend([h1,h2],'prediction','real response','location','NW');
    set(gca,'XTick',0:4:40,'XTicklabel',0:50:500,'TickDir','out');
    axis square
    box off
    subplot(122)
    h1 = plot(SSR(7:40),'r-','LineWidth',2);
    hold on;
    h2 = plot(SFR(7:40)*0.25,'k-','LineWidth',2);
    set(gca,'XTick',0:4:33,'XTicklabel',70:50:500,'TickDir','out');
    legend([h1,h2],'prediction','real response','location','NW');
    axis square
    box off
end

Scorr = corr(2);
npScorr = g(2);
Ocorr   = o(2);
clear fr S sFr sSr Fr
