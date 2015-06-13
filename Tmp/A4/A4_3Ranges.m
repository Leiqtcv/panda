%% A4_3Ranges

%Uebersicht findet sich wieder in A4_subject

%Step 1
%Plots the 3 conditions for each subjects 

% --> shows how well they did in general
% --> helps to figure out the order of conditions, which range in which file. 

%A4_3Ranges: Fourth audition experiment, headsaccades towards stimuli
%presented in 3 ranges

% For all three sessions a 4 blocks seperately

%% PP: RG, RG2, MW, MW2, MW3, HH, HH2, HH3, HH4, RO, RO2, RO3 LJ, LJ2, LJ3, LJ4, JR

close all
clear all
%Figure 1
subject = 'LJ'; 

switch subject
    
case 'RG'
        pa_datadir MW-RG-2011-12-08
     figure (1) %10
        load MW-RG-2011-12-08-0004
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load MW-RG-2011-12-08-0007
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load MW-RG-2011-12-08-0002
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load MW-RG-2011-12-08-0001
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load MW-RG-2011-12-08-0005
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load MW-RG-2011-12-08-0006
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load MW-RG-2011-12-08-0003
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load MW-RG-2011-12-08-0008
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);
        
        save ('RG_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');
        
        
case 'RG2'
        pa_datadir MW-RG-2012-01-12
     figure (1) %10
        load MW-RG-2012-01-12-0004
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load MW-RG-2012-01-12-0007
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load MW-RG-2012-01-12-0005
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load MW-RG-2012-01-12-0002
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load MW-RG-2012-01-12-0001
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load MW-RG-2012-01-12-0003
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load MW-RG-2012-01-12-0006
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load MW-RG-2012-01-12-0008
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);
        
        save ('RG2_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');
        

case 'MW'
            
        pa_datadir RG-MW-2011-12-02
     figure (1) %10
        load RG-MW-2011-12-02-0004
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load RG-MW-2011-12-02-0007
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load RG-MW-2011-12-02-0002
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load RG-MW-2011-12-02-0006
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load RG-MW-2011-12-02-0001
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load RG-MW-2011-12-02-0003
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load RG-MW-2011-12-02-0005
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load RG-MW-2011-12-02-0008
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);
        
save ('MW_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');
        
case 'MW2'
            
        pa_datadir RG-MW-2011-12-08
     figure (1) %10
        load RG-MW-2011-12-08-0003
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%30
        load RG-MW-2011-12-08-0001
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%50
        load RG-MW-2011-12-08-0002
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%50
        load RG-MW-2011-12-08-0004
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
    save ('MW2_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4');       

   
case 'MW3'
            
        pa_datadir RG-MW-2012-01-11
     figure (1) %10
        load RG-MW-2012-01-11-0003
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
        
     figure (2)%10
        pa_datadir RG-MW-2012-01-12
        load RG-MW-2012-01-12-0006
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        pa_datadir RG-MW-2012-01-11
        load RG-MW-2012-01-11-0001
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);
        
     figure (4)%30
        pa_datadir RG-MW-2012-01-12
        load RG-MW-2012-01-12-0008
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        pa_datadir RG-MW-2012-01-11
        load RG-MW-2012-01-11-0002
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        pa_datadir RG-MW-2012-01-11
        load RG-MW-2012-01-11-0004
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        pa_datadir RG-MW-2012-01-12
        load RG-MW-2012-01-12-0005
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        pa_datadir RG-MW-2012-01-12
        load RG-MW-2012-01-12-0007
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);
        
        save ('MW3_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');
        
    
case 'MW4'
            
        pa_datadir RG-MW-2012-01-19
     figure (1) %10
        load RG-MW-2012-01-19-0001
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%30
        load RG-MW-2012-01-19-0004
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%50
        load RG-MW-2012-01-19-0002
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%50
        load RG-MW-2012-01-19-0003
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
        save ('MW4_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4');
          
case 'HH'
        
     pa_datadir RG-HH-2011-11-24
     figure (1)
        load RG-HH-2011-11-24-0004
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)
        load RG-HH-2011-11-24-0002
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)
        load RG-HH-2011-11-24-0003
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)
        load RG-HH-2011-11-24-0001
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
       
        save ('HH_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4');
        
case 'HH2'
        pa_datadir RG-HH-2011-12-12
     figure (1) %10
        load RG-HH-2011-12-12-0001
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
        
     figure (2)%30
        load RG-HH-2011-12-12-0004
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);

        
     figure (3)%50
        load RG-HH-2011-12-12-0003
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);
       
     figure (4)%50
        load RG-HH-2011-12-12-0002
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
        save ('HH2_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4');
            
case 'HH3'
        pa_datadir RG-HH-2012-01-09
     figure (1) %10
        load RG-HH-2012-01-09-0003
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load RG-HH-2012-01-09-0007
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load RG-HH-2012-01-09-0001
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load RG-HH-2012-01-09-0008
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load RG-HH-2012-01-09-0002
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load RG-HH-2012-01-09-0004
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load RG-HH-2012-01-09-0006
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load RG-HH-2012-01-09-0005
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);
        
        save ('HH3_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');
        
        
case 'HH4'
        pa_datadir RG-HH-2012-01-13
     figure (1) %10
        load RG-HH-2012-01-13-0003
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load RG-HH-2012-01-13-0006
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load RG-HH-2012-01-13-0001
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load RG-HH-2012-01-13-0007
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load RG-HH-2012-01-13-0002
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load RG-HH-2012-01-13-0004
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load RG-HH-2012-01-13-0005
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load RG-HH-2012-01-13-0008
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);
        
        save ('HH4_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');
        
        
        
case 'RO'
        pa_datadir RG-RO-2011-12-12
     figure (1) %10
        load RG-RO-2011-12-12-0005
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load RG-RO-2011-12-12-0003
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load RG-RO-2011-12-12-0002
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load RG-RO-2011-12-12-0007
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load RG-RO-2011-12-12-0001
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load RG-RO-2011-12-12-0004
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load RG-RO-2011-12-12-0006
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load RG-RO-2011-12-12-0008
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);
        
        save ('RO_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');
        
case 'RO2'
        pa_datadir RG-RO-2012-01-11
     figure (1) %10
        load RG-RO-2012-01-11-0002
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load RG-RO-2012-01-11-0007
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load RG-RO-2012-01-11-0006
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load RG-RO-2012-01-11-0004
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load RG-RO-2012-01-11-0001
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load RG-RO-2012-01-11-0003
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load RG-RO-2012-01-11-0005
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load RG-RO-2012-01-11-0008
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);
        
        save ('RO2_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');
        
case 'RO3'
        pa_datadir RG-RO-2012-01-18
     figure (1) %10
        load RG-RO-2012-01-18-0003
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load RG-RO-2012-01-18-0006
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load RG-RO-2012-01-18-0001
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load RG-RO-2012-01-18-0008
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load RG-RO-2012-01-18-0002
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load RG-RO-2012-01-18-0004
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load RG-RO-2012-01-18-0005
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load RG-RO-2012-01-18-0007
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);
        
        save ('RO3_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');
        
case 'LJ'
        pa_datadir RG-LJ-2011-12-14
     figure (1) %10
        load RG-LJ-2011-12-14-0003
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load RG-LJ-2011-12-14-0005
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load RG-LJ-2011-12-14-0001
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load RG-LJ-2011-12-14-0006
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load RG-LJ-2011-12-14-0002
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load RG-LJ-2011-12-14-0004
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load RG-LJ-2011-12-14-0007
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load RG-LJ-2011-12-14-0008
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);
        
        
        save ('LJ_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');
        
case 'LJ2'
        pa_datadir RG-LJ-2011-12-21
     figure (1) %10
        load RG-LJ-2011-12-21-0002
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load RG-LJ-2011-12-21-0007
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load RG-LJ-2011-12-21-0006
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load RG-LJ-2011-12-21-0004
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load RG-LJ-2011-12-21-0001
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load RG-LJ-2011-12-21-0003
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load RG-LJ-2011-12-21-0005
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load RG-LJ-2011-12-21-0008
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);

         save ('LJ2_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');    
case 'LJ3'
        pa_datadir RG-LJ-2012-01-10
     figure (1) %10
        load RG-LJ-2012-01-10-0003
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load RG-LJ-2012-01-10-0007
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load RG-LJ-2012-01-10-0001
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load RG-LJ-2012-01-10-0008
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load RG-LJ-2012-01-10-0002
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load RG-LJ-2012-01-10-0004
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load RG-LJ-2012-01-10-0005
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load RG-LJ-2012-01-10-0006
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);      
        
        save ('LJ3_3Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8'); 
        
case 'LJ4'
        pa_datadir RG-LJ-2012-01-17
     figure (1) %10
        load RG-LJ-2012-01-17-0004
        SupSac = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac);
       
     figure (3)%30
        load RG-LJ-2012-01-17-0002
        SupSac = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac);
        
     figure (5)%50
        load RG-LJ-2012-01-17-0001
        SupSac = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac);
       
     figure (6)%50
        load RG-LJ-2012-01-17-0003
        SupSac = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac);
        
        
        
case 'JR'
        pa_datadir RG-JR-2012-01-13
     figure (1) %10
        load RG-JR-2012-01-13-0003
        SupSac1 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac1);
       
     figure (2)%10
        load RG-JR-2012-01-13-0006
        SupSac2 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac2);
        
     figure (3)%30
        load RG-JR-2012-01-13-0001
        SupSac3 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac3);

     figure (4)%30
        load RG-JR-2012-01-13-0007
        SupSac4 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac4);
        
     figure (5)%50
        load RG-JR-2012-01-13-0002
        SupSac5 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac5);
       
     figure (6)%50
        load RG-JR-2012-01-13-0004
        SupSac6 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac6);
        
     figure (7)%50
        load RG-JR-2012-01-13-0005
        SupSac7 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac7);

     figure (8)%50
        load RG-JR-2012-01-13-0008
        SupSac8 = pa_supersac(Sac,Stim,2,1);
        pa_plotloc(SupSac8);
        
        save ('JR_Ranges', 'SupSac1', 'SupSac2', 'SupSac3', 'SupSac4', 'SupSac5', 'SupSac6', 'SupSac7', 'SupSac8');
end
