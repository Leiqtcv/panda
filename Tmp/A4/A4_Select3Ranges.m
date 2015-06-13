function A4_Select3Ranges

%Step 3. Selection
%1) All 10 degree responses in condition 10, 30 and 50
%2) All 30 degree responses in condition 30 and 50
% For subjects RG,
% Eight figures: 1. range 10, selected in conditions 10, 30, 50 elevation
%                  (sel in el)
%                2. range 10, selected in conditions 10, 30, 50 elevation
%                  (sel in el and az)
%                3. range 10, selected in conditions 10, 30, 50 azimuth 
%                  (sel in az)
%              4. range 10, selected in conditions 10, 30, 50 azimuth 
%                  (sel in el and az)
%              3. range 30, selected in conditions 30, 50 elevation
%              4. range 30, selected in conditions 30, 50 azimuth
% PP: RG, RG2, MW, MW2, MW3, HH, HH2, HH3, HH4, RO, RO2, LJ, LJ2, LJ3, LJ4, LJall, JR


clear all
close all

subject = 'LJ';

switch subject

    
case 'RG'
        pa_datadir('MW-RG-2011-12-08');
     figure(666)
        subplot(221)
        load Combined_DataRG
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataRG
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataRG
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
case 'RG2'

        pa_datadir('MW-RG-2012-01-12');
        figure(666)
        subplot(221)
        
        load Combined_DataRG2
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
%% Elevation
     
        figure (1) %10 Selection, Elevation, 10 degree, in 10 block
        load Combined_DataRG2
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
        figure (2) %10 Selection, Elevation, sel in 24&23,%10 degree, in 10 block
        load Combined_DataRG2
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

%% Azimuth
        figure (3) %10 degree selection 
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        figure (4)% 10 degree selection in 23 & 24
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
        figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
        figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
       
            
    
case 'MW'
        pa_datadir('RG-MW-2011-12-02');
     figure(666)
        subplot(221)
        load Combined_DataMW
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
        
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataMW
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataMW
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
case 'MW2'
        pa_datadir('RG-MW-2011-12-08');
     figure(666)
        subplot(221)
        load Combined_DataMW2
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
        
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataMW2
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataMW2
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        
case 'MW3'
        pa_datadir('RG-MW-2012-01-11');
     figure(666)
        subplot(221)
        load Combined_DataMW3
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
        
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataMW3
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataMW3
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        
case 'MW4'
        pa_datadir('RG-MW-2012-01-19');
     figure(666)
        subplot(221)
        load Combined_DataMW4
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
        
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataMW4
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataMW4
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));        
        
case 'HH'
        % Figure 666, shows response behavior and actual stimuli
        % distribution
        
        pa_datadir('RG-HH-2011-11-24');
        figure(666)
        subplot(221)
        load RG-HH-2011-11-24-0004
        SupSac = pa_supersac(Sac,Stim,2,1);
        plot(SupSac(:,23),SupSac(:,24),'ro')
        hold on
        plot(SupSac(:,8),SupSac(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        load RG-HH-2011-11-24-0002
        SupSac = pa_supersac(Sac,Stim,2,1);
        plot(SupSac(:,23),SupSac(:,24),'ro')
        hold on
        plot(SupSac(:,8),SupSac(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        load RG-HH-2011-11-24-0003
        SupSac = pa_supersac(Sac,Stim,2,1);
        plot(SupSac(:,23),SupSac(:,24),'ro')
        hold on
        plot(SupSac(:,8),SupSac(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        
        subplot(224)
        load RG-HH-2011-11-24-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        plot(SupSac(:,23),SupSac(:,24),'ro')
        hold on
        plot(SupSac(:,8),SupSac(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        
        
case 'HH2'
        pa_datadir('RG-HH-2011-12-12');
     figure(666)
        subplot(221)
        load Combined_DataHH
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataHH
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataHH
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
case 'HH3'
        pa_datadir('RG-HH-2012-01-09');
     figure(666)
        subplot(221)
        load Combined_DataHH3
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataHH3
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataHH3
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
 
        
case 'HH4'
        pa_datadir('RG-HH-2012-01-13');
     figure(666)
        subplot(221)
        load Combined_DataHH4
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataHH4
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataHH4
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        
        
case 'RO'
        pa_datadir('RG-RO-2011-12-12');
     figure(666)
        subplot(221)
        load Combined_DataRO
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataRO
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataRO
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        
case 'RO2'
        pa_datadir('RG-RO-2012-01-11');
     figure(666)
        subplot(221)
        load Combined_DataRO2
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataRO2
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataRO2
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
                
case 'RO3'
        pa_datadir('RG-RO-2012-01-18');
     figure(666)
        subplot(221)
        load Combined_DataRO3
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataRO3
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataRO3
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        
case 'LJ'
        pa_datadir('RG-LJ-2011-12-14');
        figure(666)
        subplot(221)
        load Combined_DataLJ
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataLJ
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataLJ
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        
case 'LJ2'
        pa_datadir('RG-LJ-2011-12-21');
     figure(666)
        subplot(221)
        load Combined_DataLJ2
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataLJ2
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataLJ2
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
           
case 'LJ3'
        pa_datadir('RG-LJ-2012-01-10');
     figure(666)
        subplot(221)
        load Combined_DataLJ3
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataLJ3
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataLJ3
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));  
        
case 'LJ4'
        pa_datadir('RG-LJ-2012-01-17');
     figure(666)
        subplot(221)
        load Combined_DataLJ4
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataLJ4
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataLJ4
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));       
        
        
case 'LJall'
        pa_datadir('RG-LJ-2012-01-10');
        figure(666)
        subplot(221)
        load Combined_DataLJall
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataLJall
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataLJall
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        
                
case 'JR'
        pa_datadir('RG-JR-2012-01-13');
     figure(666)
        subplot(221)
        load Combined_DataJR
        
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(222)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(223)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        %%%%%%
     
     figure (1) %10 Selection, Elevation
        %10 degree, in 10 block
        load Combined_DataJR
        subplot(221)
        pa_loc(SS10(:,24),SS10(:,9));

        
        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
       
        
     figure (2) %10 Selection, Elevation, sel in 24&23
        %10 degree, in 10 block
        load Combined_DataJR
        subplot(221)
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));

        subplot(222)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        subplot(223)
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        

% %%%%        Figure 3 Azimuth
     figure (3) %10 degree selection 
        
        subplot(221)
        sel = abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (4)% 10 degree selection in 23 & 24
        
        subplot(221)
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        
        
        subplot(222)
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
       
        
        subplot(223)
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));

        
%%%%%%%%%%        
        %
        % 30, in 30 and 50
        %
        % Figure 3 Elevation
        
     figure (5)
        
        subplot(222)
        sel = abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
     figure (6)  %% sel in 24 and 23
       
        subplot(222)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        
        
        subplot(223)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        
       % Figure 4 Azimuth
     figure (7)
        
        subplot(222)
        pa_loc(SS30(:,23),SS30(:,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
     figure (8) %selection in 23 and 24
        subplot(222)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        
        
        subplot(223)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
end