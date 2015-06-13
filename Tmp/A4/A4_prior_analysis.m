function A4_prior_analysis

%1) rection time vs gain
%2) RT vs sigma
%3) gain vs sigma
%4) reaction time distribution

close all
clear all
for jj = 2
    switch jj
        case 1
            subject = 'LJ'
        case 2
            subject = 'HH'
    end
    
    switch subject
        case 'LJ'
            
            cd 'C:\DATA\RG-LJ-2012-01-10'
            
            load('Combined_DataLJall');
            for ii = 1:3
                switch ii
                    case 1
                        SS      = SS10;
                        col = 'r';
                    case 2
                        SS      = SS30;
                        col = 'g';
                    case 3
                        SS      = SS50;
                        col = 'b';
                end
                Ppred = std(SS(:,24));
                sel     = abs(SS(:,24))<12;
                X       = SS(sel,24);
                Y       = SS(sel,9);
                
                stats = regstats(Y,X,'linear',{'beta','r'});
                gain = stats.beta(2);
                sd = std(stats.r);
                
                plot(sd,gain,'ko','MarkerFaceColor',col,'Color',col);
                hold on
                xlabel('Standard deviation (deg)');
                ylabel('Gain');
                axis([0 30 0 1.5]);
%                 Gain = 1 - SD.^2/Prior.^2;
%                 1-Gain = SD.^2/Prior.^2;
%                 (1-Gain)/SD.^2 = 1/Prior.^2;
%                 SD.^2/(1-Gain) = Prior.^2;


                P = sqrt(sd^2/(1-gain));
                x = 0:30;
                G = pa_invparabolefun(P,x);
                plot(x,G,'k-','LineWidth',2,'Color',col);

                x = 0:1:30;
                G = pa_invparabolefun(Ppred,x);
                plot(x,G,'k:','LineWidth',2,'Color',col);
            end
            
        case 'HH'
            cd 'C:\DATA\Prior\RG-HH-2012-01-13'
            
            load('Combined_DataHHall');
            for ii = 1:3
                switch ii
                    case 1
                        SS      = SS10;
                        col = 'r';
                    case 2
                        SS      = SS30;
                        col = 'g';
                    case 3
                        SS      = SS50;
                        col = 'b';
                end
                Ppred = std(SS(:,24));
                sel     = abs(SS(:,24))<12;
                X       = SS(sel,24);
                Y       = SS(sel,9);
                
                stats = regstats(Y,X,'linear',{'beta','r'});
                gain = stats.beta(2);
                sd = std(stats.r);
                
                plot(sd,gain,'ko','MarkerFaceColor',col,'Color',col);
                hold on
                xlabel('Standard deviation (deg)');
                ylabel('Gain');
                axis([0 30 0 1.5]);
%                 Gain = 1 - SD.^2/Prior.^2;
%                 1-Gain = SD.^2/Prior.^2;
%                 (1-Gain)/SD.^2 = 1/Prior.^2;
%                 SD.^2/(1-Gain) = Prior.^2;


                P = sqrt(sd^2/(1-gain));
                x = 0:30;
                G = pa_invparabolefun(P,x);
                plot(x,G,'k-','LineWidth',2,'Color',col);

                x = 0:1:30;
                G = pa_invparabolefun(Ppred,x);
                plot(x,G,'k:','LineWidth',2,'Color',col);
             end
    end
end