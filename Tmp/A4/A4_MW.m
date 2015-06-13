function A4_MW


close all
clear all

%3Ranges, ruw data, overzicht voor alle 6 Sessies
%Overview, Elevation, row: conditie (10, 30, 50, 50), kolom: sessie (1-6)
figure (1)
pa_datadir RG-MW-2011-12-02
load MW_3Ranges
subplot (4,6,1)
pa_plotloc(SupSac1, 'which', 'el')
subplot (4,6,2)
pa_plotloc(SupSac2, 'which', 'el')
subplot (4,6,7)
pa_plotloc(SupSac3, 'which', 'el')
subplot (4,6,8)
pa_plotloc(SupSac4, 'which', 'el')
subplot (4,6,13)
pa_plotloc(SupSac5, 'which', 'el')
subplot (4,6,14)
pa_plotloc(SupSac6, 'which', 'el')
subplot (4,6,19)
pa_plotloc(SupSac7, 'which', 'el')
subplot (4,6,20)
pa_plotloc(SupSac8, 'which', 'el')

pa_datadir RG-MW-2011-12-08
load MW2_3Ranges
subplot (4,6,3)
pa_plotloc(SupSac1, 'which', 'el')
subplot (4,6,9)
pa_plotloc(SupSac2, 'which', 'el')
subplot (4,6,15)
pa_plotloc(SupSac3, 'which', 'el')
subplot (4,6,21)
pa_plotloc(SupSac4, 'which', 'el')



pa_datadir RG-MW-2012-01-12
load MW3_3Ranges
subplot (4,6,4)
pa_plotloc(SupSac1, 'which', 'el')
subplot (4,6,5)
pa_plotloc(SupSac2, 'which', 'el')
subplot (4,6,10)
pa_plotloc(SupSac3, 'which', 'el')
subplot (4,6,11)
pa_plotloc(SupSac4, 'which', 'el')
subplot (4,6,16)
pa_plotloc(SupSac5, 'which', 'el')
subplot (4,6,17)
pa_plotloc(SupSac6, 'which', 'el')
subplot (4,6,22)
pa_plotloc(SupSac7, 'which', 'el')
subplot (4,6,23)
pa_plotloc(SupSac8, 'which', 'el')

pa_datadir RG-MW-2012-01-19
load MW4_3Ranges
subplot (4,6,6)
pa_plotloc(SupSac1, 'which', 'el')
subplot (4,6,12)
pa_plotloc(SupSac2, 'which', 'el')
subplot (4,6,18)
pa_plotloc(SupSac3, 'which', 'el')
subplot (4,6,24)
pa_plotloc(SupSac4, 'which', 'el')


figure (2)

%Overview, Azimuth, row: conditie (10, 30, 50, 50), kolom: sessie (1-6)

pa_datadir RG-MW-2011-12-02
load MW_3Ranges
subplot (4,6,1)
pa_plotloc(SupSac1, 'which', 'az')
subplot (4,6,2)
pa_plotloc(SupSac2, 'which', 'az')
subplot (4,6,7)
pa_plotloc(SupSac3, 'which', 'az')
subplot (4,6,8)
pa_plotloc(SupSac4, 'which', 'az')
subplot (4,6,13)
pa_plotloc(SupSac5, 'which', 'az')
subplot (4,6,14)
pa_plotloc(SupSac6, 'which', 'az')
subplot (4,6,19)
pa_plotloc(SupSac7, 'which', 'az')
subplot (4,6,20)
pa_plotloc(SupSac8, 'which', 'az')

pa_datadir RG-MW-2011-12-08
load MW2_3Ranges
subplot (4,6,3)
pa_plotloc(SupSac1, 'which', 'az')
subplot (4,6,9)
pa_plotloc(SupSac2, 'which', 'az')
subplot (4,6,15)
pa_plotloc(SupSac3, 'which', 'az')
subplot (4,6,21)
pa_plotloc(SupSac4, 'which', 'az')



pa_datadir RG-MW-2012-01-12
load MW3_3Ranges
subplot (4,6,4)
pa_plotloc(SupSac1, 'which', 'az')
subplot (4,6,5)
pa_plotloc(SupSac2, 'which', 'az')
subplot (4,6,10)
pa_plotloc(SupSac3, 'which', 'az')
subplot (4,6,11)
pa_plotloc(SupSac4, 'which', 'az')
subplot (4,6,16)
pa_plotloc(SupSac5, 'which', 'az')
subplot (4,6,17)
pa_plotloc(SupSac6, 'which', 'az')
subplot (4,6,22)
pa_plotloc(SupSac7, 'which', 'az')
subplot (4,6,23)
pa_plotloc(SupSac8, 'which', 'az')

pa_datadir RG-MW-2012-01-19
load MW4_3Ranges
subplot (4,6,6)
pa_plotloc(SupSac1, 'which', 'az')
subplot (4,6,12)
pa_plotloc(SupSac2, 'which', 'az')
subplot (4,6,18)
pa_plotloc(SupSac3, 'which', 'az')
subplot (4,6,24)
pa_plotloc(SupSac4, 'which', 'az')

% Overzicht Kijkgedrag
figure (3)

        pa_datadir('RG-MW-2011-12-02');
        load Combined_DataMW
        subplot(431)
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(432)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(433)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      
        
        pa_datadir('RG-MW-2011-12-08');
        load Combined_DataMW2
        subplot(434)
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(435)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(436)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        
        
        pa_datadir('RG-MW-2012-01-12');
        load Combined_DataMW3
        subplot(437)
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(438)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(439)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        
        pa_datadir('RG-MW-2012-01-19');
        load Combined_DataMW4
        subplot(4,3,10)
        plot(SS10(:,23),SS10(:,24),'ro')
        hold on
        plot(SS10(:,8),SS10(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
      

        subplot(4,3, 11)
        plot(SS30(:,23),SS30(:,24),'ro')
        hold on
        plot(SS30(:,8),SS30(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);

        subplot(4, 3, 12)
        plot(SS50(:,23),SS50(:,24),'ro')
        hold on
        plot(SS50(:,8),SS50(:,9),'k.')
        axis square;
        axis([-90 90 -90 90]);
        
     
 % Selection Overview
 %Elevation
 figure (4) 
        %10 Selection, Elevation, sel in 24&23
        
        pa_datadir RG-MW-2011-12-02
        load Combined_DataMW
        subplot(631)
        %10 degree, in 10 block
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));
        subplot(632)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        subplot(633)
        %10 degree, in 50 block
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        %30 degree, in 30 block
        subplot(635)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        %30 degree, in 50 block
        subplot(636)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        pa_datadir RG-MW-2011-12-08
        load Combined_DataMW2
        subplot(637)
        %10 degree, in 10 block
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));
        subplot(638)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        subplot(639)
        %10 degree, in 50 block
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        %30 degree, in 30 block
        subplot(6,3,11)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        %30 degree, in 50 block
        subplot(6,3,12)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
figure(5)
        pa_datadir RG-MW-2012-01-12
        load Combined_DataMW3
        subplot(6,3,1)
        %10 degree, in 10 block
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));
        subplot(6,3,2)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        subplot(6,3,3)
        %10 degree, in 50 block
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        %30 degree, in 30 block
        subplot(6,3,5)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        %30 degree, in 50 block
        subplot(6,3,6)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        
        pa_datadir RG-MW-2012-01-19
        load Combined_DataMW4
        subplot(6,3,7)
        %10 degree, in 10 block
        sel = abs(SS10(:,24))<=11 & abs(SS10(:,23))<=11;
        pa_loc(SS10(sel,24),SS10(sel,9));
        subplot(6,3,8)
        %10 degree, in 30 block
        sel = abs(SS30(:,24))<=11 & abs(SS30(:,23))<=11;
        pa_loc(SS30(sel,24),SS30(sel,9));
        subplot(6,3,9)
        %10 degree, in 50 block
        sel = abs(SS50(:,24))<=11 & abs(SS50(:,23))<=11;
        pa_loc(SS50(sel,24),SS50(sel,9));
        
        %30 degree, in 30 block
        subplot(6,3,11)
        sel = abs(SS30(:,24))<=31 & abs(SS30(:,23))<=31;
        pa_loc(SS30(sel,24),SS30(sel,9));
        %30 degree, in 50 block
        subplot(6,3,12)
        sel = abs(SS50(:,24))<=31 & abs(SS50(:,23))<=31;
        pa_loc(SS50(sel,24),SS50(sel,9));

%Azimuth        
figure (6) 
        %10 Selection, Azimuth, sel in 24&23
        
        pa_datadir RG-MW-2011-12-02
        load Combined_DataMW
        subplot(631)
        %10 degree, in 10 block
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        subplot(632)
        %10 degree, in 30 block
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        subplot(633)
        %10 degree, in 50 block
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        %30 degree, in 30 block
        subplot(635)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        %30 degree, in 50 block
        subplot(636)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        
        pa_datadir RG-LJ-2011-12-08
        load Combined_DataMW2
        subplot(637)
        %10 degree, in 10 block
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        subplot(638)
        %10 degree, in 30 block
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        subplot(639)
        %10 degree, in 50 block
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8)); 
        %30 degree, in 30 block
        subplot(6,3,11)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8)); 
        %30 degree, in 50 block
        subplot(6,3,12)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
figure(7)
        pa_datadir RG-MW-2012-01-12
        load Combined_DataMW3
        subplot(6,3,1)
        %10 degree, in 10 block
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        subplot(6,3,2)
        %10 degree, in 30 block
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        subplot(6,3,3)
        %10 degree, in 50 block
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        %30 degree, in 30 block
        subplot(6,3,5)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        %30 degree, in 50 block
        subplot(6,3,6)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        
        pa_datadir RG-MW-2012-01-19
        load Combined_DataMW4
        subplot(6,3,7)
        %10 degree, in 10 block
        sel = abs(SS10(:,23))<=11 & abs(SS10(:,24))<=11;
        pa_loc(SS10(sel,23),SS10(sel,8));
        subplot(6,3,8)
        %10 degree, in 30 block
        sel = abs(SS30(:,23))<=11 & abs(SS30(:,24))<=11;
        pa_loc(SS30(sel,23),SS30(sel,8));
        subplot(6,3,9)
        %10 degree, in 50 block
        sel = abs(SS50(:,23))<=11 & abs(SS50(:,24))<=11;
        pa_loc(SS50(sel,23),SS50(sel,8));
        %30 degree, in 30 block
        subplot(6,3,11)
        sel = abs(SS30(:,23))<=31 & abs(SS30(:,24))<=31;
        pa_loc(SS30(sel,23),SS30(sel,8));
        %30 degree, in 50 block
        subplot(6,3,12)
        sel = abs(SS50(:,23))<=31 & abs(SS50(:,24))<=31;
        pa_loc(SS50(sel,23),SS50(sel,8));
        
        
%         
% figure (6)
%      pa_datadir RG-LJ-2011-12-14
%      subplot(221)
%      h = GainLJ ; 
% %      hold on
% %        subplot(222)
% %      pa_datadir RG-LJ-2011-12-21
% %      h = GainLJ2 ; 
% % %      h = errorbar(width,B,SE,'ko-');
% % % hold on
% % set(h,'MarkerFaceColor','w','LineWidth',2);
% % [path, name] = fileparts(mfilename('fullpath'));
% % figname = fullfile(path, [name '.fig']);
% % if (exist(figname,'file')), open(figname), else open([name '.fig']), end
% % if nargout > 0, h = gcf; end
% 
% %Ellipse, RT