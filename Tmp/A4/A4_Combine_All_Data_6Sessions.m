function A4_Combine_All_Data_6Sessions
clear all
close all

%% PP: (RG), (MW), HH, RO, LJ, (JR)

subject = 'RG';

switch subject
    
    
case 'RG'

    %% combined 10 degree responses, in SS10
    pa_datadir RG-LJ-2011-12-14
    load RG-LJ-2011-12-14-0005
    SS10a = pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0003
    SS10b = pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2011-12-21
    load RG-LJ-2011-12-21-0002
    SS10c=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0007
    SS10d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2012-01-10
    load RG-LJ-2012-01-10-0003
    SS10e=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0007
    SS10f=pa_supersac(Sac,Stim,2,1);

    SS10    = [SS10a; SS10b; SS10c; SS10d; SS10e; SS10f];
    SSLJall = SS10;
    figure(1)
    pa_plotloc(SS10);
    
    save('SS10LJall', 'SSLJall')
 
    %% combined 30 degree responses, in SS30

    pa_datadir RG-LJ-2011-12-14
    load RG-LJ-2011-12-14-0001
    SS30a=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0006
    SS30b=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2011-12-21
    load RG-LJ-2011-12-21-0004
    SS30c=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0006
    SS30d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2012-01-10
    load RG-LJ-2012-01-10-0001
    SS30e=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0008
    SS30f=pa_supersac(Sac,Stim,2,1);
    
    SS30= [SS30a; SS30b; SS30c; SS30d; SS30e; SS30f];
    SSLJall=SS30;

    figure(2)
    pa_plotloc(SS30);
            
    save('SS30LJall', 'SSLJall')
            
            
    %% combined 50 degree responses, in SS50
   
    pa_datadir RG-LJ-2011-12-14
    load RG-LJ-2011-12-14-0002
    SS50a=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0004
    SS50b=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0007
    SS50c=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0008
    SS50d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2011-12-21
    load RG-LJ-2011-12-21-0001
    SS50e=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0003
    SS50f=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0005
    SS50g=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0008
    SS50h=pa_supersac(Sac,Stim,2,1);

    
    pa_datadir RG-LJ-2012-01-10
    load RG-LJ-2012-01-10-0002
    SS50i=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0004
    SS50j=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0005
    SS50k=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0006
    SS50l=pa_supersac(Sac,Stim,2,1);

    SS50= [SS50a; SS50b; SS50c; SS50d; SS50e; SS50f; SS50g; SS50h; SS50i; SS50j; SS50k; SS50l];
    SSLJall=SS50;
    figure(3)
    pa_plotloc(SS50);
    
        save('SS50LJall', 'SSLJall')
            save('Combined_DataLJall','SS10','SS30','SS50')
    
case 'MW'

    %% combined 10 degree responses, in SS10
    pa_datadir RG-MW-2011-12-02
    load RG-MW-2011-12-02-0004
    SS10a = pa_supersac(Sac,Stim,2,1);
    load RG-MW-2011-12-02-0007
    SS10b = pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-MW-2011-12-08
    load RG-MW-2011-12-08-0003
    SS10c=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-MW-2012-01-11
    load RG-MW-2012-01-11-0003
    SS10d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-MW-2012-01-12
    load RG-MW-2012-01-12-0006
    SS10e=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-MW-2012-01-19
    load RG-MW-2012-01-19-0001
    SS10f=pa_supersac(Sac,Stim,2,1);
    
    

    SS10    = [SS10a; SS10b; SS10c; SS10d; SS10e; SS10f];
    SSMWall = SS10;
    figure(1)
    pa_plotloc(SS10);
    
    save('SS10MWall', 'SSMWall')
 
    %% combined 30 degree responses, in SS30

    pa_datadir RG-MW-2011-12-02
    load RG-MW-2011-12-02-0002
    SS30a=pa_supersac(Sac,Stim,2,1);
    load RG-MW-2011-12-02-0006
    SS30b=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-MW-2011-12-08
    load RG-MW-2011-12-08-0001
    SS30c=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-MW-2012-01-11
    load RG-MW-2012-01-11-0003
    SS30d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-MW-2012-01-12
    load RG-MW-2012-01-12-0006
    SS30e=pa_supersac(Sac,Stim,2,1);
    
     pa_datadir RG-MW-2012-01-19
    load RG-MW-2012-01-19-0004
    SS30f=pa_supersac(Sac,Stim,2,1);
    
    SS30= [SS30a; SS30b; SS30c; SS30d; SS30e; SS30f];
    SSMWall=SS30;

    figure(2)
    pa_plotloc(SS30);
            
    save('SS30MWall', 'SSMWall')
            
            
    %% combined 50 degree responses, in SS50
   
    pa_datadir RG-MW-2011-12-02
    load RG-MW-2011-12-02-0001
    SS50a=pa_supersac(Sac,Stim,2,1);
    load RG-MW-2011-12-02-0003
    SS50b=pa_supersac(Sac,Stim,2,1);
    load RG-MW-2011-12-02-0005
    SS50c=pa_supersac(Sac,Stim,2,1);
    load RG-MW-2011-12-02-0008
    SS50d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-MW-2011-12-08
    load RG-MW-2011-12-08-0002
    SS50e=pa_supersac(Sac,Stim,2,1);
    load RG-MW-2011-12-08-0004
    SS50f=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-MW-2012-01-11
    load RG-MW-2012-01-11-0002
    SS50g=pa_supersac(Sac,Stim,2,1);
    load RG-MW-2012-01-11-0004
    SS50h=pa_supersac(Sac,Stim,2,1);

    pa_datadir RG-MW-2012-01-12
    load RG-MW-2012-01-12-0005
    SS50i=pa_supersac(Sac,Stim,2,1);
    load RG-MW-2012-01-12-0007
    SS50j=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-MW-2012-01-19
    load RG-MW-2012-01-19-0002
    SS50k=pa_supersac(Sac,Stim,2,1);
    load RG-MW-2012-01-19-0003
    SS50l=pa_supersac(Sac,Stim,2,1);

    SS50= [SS50a; SS50b; SS50c; SS50d; SS50e; SS50f; SS50g; SS50h; SS50i; SS50j; SS50k; SS50l];
    SSMWall=SS50;
    figure(3)
    pa_plotloc(SS50);
    
    save('SS50MWall', 'SSMWall')
    
    save('Combined_DataMWall','SS10','SS30','SS50')

    
case 'HH'
    
    %% combined 10 degree responses, in SS10
    pa_datadir RG-HH-2011-11-24
    load RG-HH-2011-11-24-0004
    SS10a=pa_supersac(Sac,Stim,2,1);

    pa_datadir RG-HH-2011-12-12
    load RG-HH-2011-12-12-0001
    SS10b=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-HH-2012-01-09
    load RG-HH-2012-01-09-0003
    SS10c=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2012-01-09-0007
    SS10d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-HH-2012-01-13
    load RG-HH-2012-01-13-0003
    SS10e=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2012-01-13-0006
    SS10f=pa_supersac(Sac,Stim,2,1);

    SS10    = [SS10a; SS10b; SS10c; SS10d; SS10e; SS10f];
    SSHHall =  SS10;
    figure(1)
    pa_plotloc(SS10);
    
        save('SS10HHall', 'SSHHall')
        
        
    %% combined 30 degree responses, in SS30
    
    pa_datadir RG-HH-2011-11-24
    load RG-HH-2011-11-24-0002
    SS30a=pa_supersac(Sac,Stim,2,1);

    pa_datadir RG-HH-2011-12-12
    load RG-HH-2011-12-12-0004
    SS30b=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-HH-2012-01-09
    load RG-HH-2012-01-09-0001
    SS30c=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2012-01-09-0008
    SS30d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-HH-2012-01-13
    load RG-HH-2012-01-13-0001
    SS30e=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2012-01-13-0007
    SS30f=pa_supersac(Sac,Stim,2,1);
    
    SS30    = [SS30a; SS30b; SS30c; SS30d; SS30e; SS30f];
    SSHHall =  SS30;

    figure(2)
    pa_plotloc(SS30);
            save('SS30HHall', 'SSHHall')
            
            
    %% combined 50 degree responses, in SS50
    pa_datadir RG-HH-2011-11-24
    load RG-HH-2011-11-24-0001
    SS50a=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2011-11-24-0003
    SS50b=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-HH-2011-12-12
    load RG-HH-2011-12-12-0002
    SS50c=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2011-12-12-0003
    SS50d=pa_supersac(Sac,Stim,2,1);
        
    pa_datadir RG-HH-2012-01-09
    load RG-HH-2012-01-09-0002
    SS50e=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2012-01-09-0004
    SS50f=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2012-01-09-0005
    SS50g=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2012-01-09-0006
    SS50h=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-HH-2012-01-13
    load RG-HH-2012-01-13-0002
    SS50i=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2012-01-13-0004
    SS50j=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2012-01-13-0005
    SS50k=pa_supersac(Sac,Stim,2,1);
    load RG-HH-2012-01-13-0006
    SS50l=pa_supersac(Sac,Stim,2,1);

    SS50    = [SS50a; SS50b; SS50c; SS50d; SS50e; SS50f; SS50g; SS50h; SS50i; SS50j; SS50k; SS50l];
    SSHHall =  SS50;
    figure(3)
    pa_plotloc(SS50);
    
        save('SS50HHall', 'SSHHall')
            save('Combined_DataHHall','SS10','SS30','SS50')

            
case 'RO'

    %% combined 10 degree responses, in SS10
    pa_datadir RG-RO-2011-12-12
    load RG-RO-2011-12-12-0005
    SS10a = pa_supersac(Sac,Stim,2,1);
    load RG-RO-2011-12-12-0003
    SS10b = pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-RO-2012-01-11
    load RG-RO-2012-01-11-0002
    SS10c=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2012-01-11-0007
    SS10d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-RO-2012-01-18
    load RG-RO-2012-01-11-0003
    SS10e=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2012-01-11-0006
    SS10f=pa_supersac(Sac,Stim,2,1);

    SS10    = [SS10a; SS10b; SS10c; SS10d; SS10e; SS10f];
    SSROall = SS10;
    figure(1)
    pa_plotloc(SS10);
    
    save('SS10ROall', 'SSROall')
 
    %% combined 30 degree responses, in SS30

    pa_datadir RG-RO-2011-12-12
    load RG-RO-2011-12-12-0002
    SS30a=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2011-12-12-0007
    SS30b=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-RO-2012-01-11
    load RG-RO-2012-01-11-0004
    SS30c=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2012-01-11-0006
    SS30d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-RO-2012-01-18
    load RG-RO-2012-01-18-0001
    SS30e=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2012-01-18-0008
    SS30f=pa_supersac(Sac,Stim,2,1);
    
    SS30= [SS30a; SS30b; SS30c; SS30d; SS30e; SS30f];
    SSROall=SS30;

    figure(2)
    pa_plotloc(SS30);
            
    save('SS30ROall', 'SSROall')
            
            
    %% combined 50 degree responses, in SS50
   
    pa_datadir RG-RO-2011-12-12
    load RG-RO-2011-12-12-0001
    SS50a=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2011-12-12-0004
    SS50b=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2011-12-12-0006
    SS50c=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2011-12-12-0008
    SS50d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-RO-2012-01-11
    load RG-RO-2012-01-11-0001
    SS50e=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2012-01-11-0003
    SS50f=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2012-01-11-0005
    SS50g=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2012-01-11-0008
    SS50h=pa_supersac(Sac,Stim,2,1);

    
    pa_datadir RG-RO-2012-01-18
    load RG-RO-2012-01-18-0002
    SS50i=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2012-01-18-0004
    SS50j=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2012-01-18-0005
    SS50k=pa_supersac(Sac,Stim,2,1);
    load RG-RO-2012-01-18-0007
    SS50l=pa_supersac(Sac,Stim,2,1);

    SS50= [SS50a; SS50b; SS50c; SS50d; SS50e; SS50f; SS50g; SS50h; SS50i; SS50j; SS50k; SS50l];
    SSROall=SS50;
    figure(3)
    pa_plotloc(SS50);
    
        save('SS50ROall', 'SSROall')
            save('Combined_DataROall','SS10','SS30','SS50')
            
    
case 'LJ'

    %% combined 10 degree responses, in SS10
    pa_datadir RG-LJ-2011-12-14
    load RG-LJ-2011-12-14-0005
    SS10a = pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0003
    SS10b = pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2011-12-21
    load RG-LJ-2011-12-21-0002
    SS10c=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0007
    SS10d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2012-01-10
    load RG-LJ-2012-01-10-0003
    SS10e=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0007
    SS10f=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2012-01-17
    load RG-LJ-2012-01-17-0004
    SS10g=pa_supersac(Sac,Stim,2,1);

    

    SS10    = [SS10a; SS10b; SS10c; SS10d; SS10e; SS10f; SS10g];
    SSLJall = SS10;
    figure(1)
    pa_plotloc(SS10);
    
    save('SS10LJall', 'SSLJall')
 
    %% combined 30 degree responses, in SS30

    pa_datadir RG-LJ-2011-12-14
    load RG-LJ-2011-12-14-0001
    SS30a=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0006
    SS30b=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2011-12-21
    load RG-LJ-2011-12-21-0004
    SS30c=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0006
    SS30d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2012-01-10
    load RG-LJ-2012-01-10-0001
    SS30e=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0008
    SS30f=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2012-01-17
    load RG-LJ-2012-01-17-0002
    SS30g=pa_supersac(Sac,Stim,2,1);
    
    SS30= [SS30a; SS30b; SS30c; SS30d; SS30e; SS30f; SS30g];
    SSLJall=SS30;

    figure(2)
    pa_plotloc(SS30);
            
    save('SS30LJall', 'SSLJall')
            
            
    %% combined 50 degree responses, in SS50
   
    pa_datadir RG-LJ-2011-12-14
    load RG-LJ-2011-12-14-0002
    SS50a=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0004
    SS50b=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0007
    SS50c=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0008
    SS50d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2011-12-21
    load RG-LJ-2011-12-21-0001
    SS50e=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0003
    SS50f=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0005
    SS50g=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0008
    SS50h=pa_supersac(Sac,Stim,2,1);

    
    pa_datadir RG-LJ-2012-01-10
    load RG-LJ-2012-01-10-0002
    SS50i=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0004
    SS50j=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0005
    SS50k=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0006
    SS50l=pa_supersac(Sac,Stim,2,1);
    
    
    pa_datadir RG-LJ-2012-01-17
    load RG-LJ-2012-01-17-0001
    SS50m=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-17-0003
    SS50n=pa_supersac(Sac,Stim,2,1);

    SS50= [SS50a; SS50b; SS50c; SS50d; SS50e; SS50f; SS50g; SS50h; SS50i; SS50j; SS50k; SS50l; SS50m; SS50n];
    SSLJall=SS50;
    figure(3)
    pa_plotloc(SS50);
    
        save('SS50LJall', 'SSLJall')
            save('Combined_DataLJall','SS10','SS30','SS50')

            
            

            
case 'JR'

    %% combined 10 degree responses, in SS10
    pa_datadir RG-LJ-2011-12-14
    load RG-LJ-2011-12-14-0005
    SS10a = pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0003
    SS10b = pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2011-12-21
    load RG-LJ-2011-12-21-0002
    SS10c=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0007
    SS10d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2012-01-10
    load RG-LJ-2012-01-10-0003
    SS10e=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0007
    SS10f=pa_supersac(Sac,Stim,2,1);

    SS10    = [SS10a; SS10b; SS10c; SS10d; SS10e; SS10f];
    SSLJall = SS10;
    figure(1)
    pa_plotloc(SS10);
    
    save('SS10LJall', 'SSLJall')
 
    %% combined 30 degree responses, in SS30

    pa_datadir RG-LJ-2011-12-14
    load RG-LJ-2011-12-14-0001
    SS30a=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0006
    SS30b=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2011-12-21
    load RG-LJ-2011-12-21-0004
    SS30c=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0006
    SS30d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2012-01-10
    load RG-LJ-2012-01-10-0001
    SS30e=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0008
    SS30f=pa_supersac(Sac,Stim,2,1);
    
    SS30= [SS30a; SS30b; SS30c; SS30d; SS30e; SS30f];
    SSLJall=SS30;

    figure(2)
    pa_plotloc(SS30);
            
    save('SS30LJall', 'SSLJall')
            
            
    %% combined 50 degree responses, in SS50
   
    pa_datadir RG-LJ-2011-12-14
    load RG-LJ-2011-12-14-0002
    SS50a=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0004
    SS50b=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0007
    SS50c=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-14-0008
    SS50d=pa_supersac(Sac,Stim,2,1);
    
    pa_datadir RG-LJ-2011-12-21
    load RG-LJ-2011-12-21-0001
    SS50e=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0003
    SS50f=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0005
    SS50g=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2011-12-21-0008
    SS50h=pa_supersac(Sac,Stim,2,1);

    
    pa_datadir RG-LJ-2012-01-10
    load RG-LJ-2012-01-10-0002
    SS50i=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0004
    SS50j=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0005
    SS50k=pa_supersac(Sac,Stim,2,1);
    load RG-LJ-2012-01-10-0006
    SS50l=pa_supersac(Sac,Stim,2,1);

    SS50= [SS50a; SS50b; SS50c; SS50d; SS50e; SS50f; SS50g; SS50h; SS50i; SS50j; SS50k; SS50l];
    SSLJall=SS50;
    figure(3)
    pa_plotloc(SS50);
    
        save('SS50LJall', 'SSLJall')
            save('Combined_DataLJall','SS10','SS30','SS50')

            
            
end