function A4_Combine_Data

%Step 2, after checking that data is okay, combine all data into
%three matrices containing all responses, SS10, SS30 and SS50.
%% RG, RG2, MW,MW2, MW3, HH, HH2, HH3, HH4, RO, RO2, RO3, LJ, LJ2, LJ3, JR

clear all
close all

subject = 'MW4';

switch subject
    
case 'RG'
        pa_datadir MW-RG-2011-12-08

        %% combined 10 degree responses, in SS10
        load MW-RG-2011-12-08-0004
        SS10a=pa_supersac(Sac,Stim,2,1);

        load MW-RG-2011-12-08-0007
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSRG=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10RG', 'SSRG')

        %% combined 30 degree responses, in SS30
        % 
        load MW-RG-2011-12-08-0002
        SS30a=pa_supersac(Sac,Stim,2,1);

        load MW-RG-2011-12-08-0001
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSRG=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30RG', 'SSRG')
        %% combined 50 degree responses, in SS50

        load MW-RG-2011-12-08-0005
        SS50a=pa_supersac(Sac,Stim,2,1);
        load MW-RG-2011-12-08-0006
        SS50b=pa_supersac(Sac,Stim,2,1);
        load MW-RG-2011-12-08-0003
        SS50c=pa_supersac(Sac,Stim,2,1);
        load MW-RG-2011-12-08-0008
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSRG=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50RG', 'SSRG')
                save('Combined_DataRG','SS10','SS30','SS50')


case 'RG2'
        pa_datadir MW-RG-2012-01-12

        %% combined 10 degree responses, in SS10
        load MW-RG-2012-01-12-0004
        SS10a=pa_supersac(Sac,Stim,2,1);

        load MW-RG-2012-01-12-0007
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSRG2=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10RG2', 'SSRG2')

        %% combined 30 degree responses, in SS30
        % 
        load MW-RG-2012-01-12-0005
        SS30a=pa_supersac(Sac,Stim,2,1);

        load MW-RG-2012-01-12-0002
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSRG2=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30RG2', 'SSRG2')
        %% combined 50 degree responses, in SS50

        load MW-RG-2012-01-12-0001
        SS50a=pa_supersac(Sac,Stim,2,1);
        load MW-RG-2012-01-12-0003
        SS50b=pa_supersac(Sac,Stim,2,1);
        load MW-RG-2012-01-12-0006
        SS50c=pa_supersac(Sac,Stim,2,1);
        load MW-RG-2012-01-12-0008
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSRG2=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50RG2', 'SSRG2')
                save('Combined_DataRG2','SS10','SS30','SS50')

            
            
case 'MW'
        pa_datadir RG-MW-2011-12-02

        %% combined 10 degree responses, in SS10
        load RG-MW-2011-12-02-0004
        SS10a=pa_supersac(Sac,Stim,2,1);

        load RG-MW-2011-12-02-0007
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSMW=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10MW', 'SSMW')

        %% combined 30 degree responses, in SS30
        % 
        load RG-MW-2011-12-02-0002
        SS30a=pa_supersac(Sac,Stim,2,1);

        load RG-MW-2011-12-02-0006
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSMW=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30MW', 'SSMW')
        %% combined 50 degree responses, in SS50

        load RG-MW-2011-12-02-0001
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-MW-2011-12-02-0003
        SS50b=pa_supersac(Sac,Stim,2,1);
        load RG-MW-2011-12-02-0005
        SS50c=pa_supersac(Sac,Stim,2,1);
        load RG-MW-2011-12-02-0008
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSMW=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50MW', 'SSMW')
            save('Combined_DataMW','SS10','SS30','SS50')
    
            
case 'MW2'
        pa_datadir RG-MW-2011-12-08

        %% combined 10 degree responses, in SS10
        load RG-MW-2011-12-08-0003
        SS10a=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a];
        SSMW2=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10MW2', 'SSMW2')

        %% combined 30 degree responses, in SS30
        % 
        load RG-MW-2011-12-08-0001
        SS30a=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a];
        SSMW2=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30MW2', 'SSMW2')
        %% combined 50 degree responses, in SS50

        load RG-MW-2011-12-08-0002
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-MW-2011-12-08-0004
        SS50b=pa_supersac(Sac,Stim,2,1);



        SS50= [SS50a; SS50b];
        SSMW2=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50MW2', 'SSMW2')
            save('Combined_DataMW2','SS10','SS30','SS50')
            
case 'MW3'
       
        %% combined 10 degree responses, in SS10
        pa_datadir RG-MW-2012-01-11
        load RG-MW-2012-01-11-0003
        SS10a=pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-MW-2012-01-12
        load RG-MW-2012-01-12-0006
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSMW3=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10MW3', 'SSMW3')

        %% combined 30 degree responses, in SS30
        % 
        pa_datadir RG-MW-2012-01-11
        load RG-MW-2012-01-11-0001
        SS30a=pa_supersac(Sac,Stim,2,1);

        pa_datadir RG-MW-2012-01-12
        load RG-MW-2012-01-12-0008
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSMW3=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30MW3', 'SSMW3')
        %% combined 50 degree responses, in SS50

        pa_datadir RG-MW-2012-01-11
        load RG-MW-2012-01-11-0002
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-MW-2012-01-11-0004
        SS50b=pa_supersac(Sac,Stim,2,1);
        pa_datadir RG-MW-2012-01-12
        load RG-MW-2012-01-12-0005
        SS50c=pa_supersac(Sac,Stim,2,1);
        load RG-MW-2012-01-12-0007
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSMW3=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50MW3', 'SSMW3')
            save('Combined_DataMW3','SS10','SS30','SS50')
            
            
case 'MW4'
        pa_datadir RG-MW-2012-01-19

        %% combined 10 degree responses, in SS10
        load RG-MW-2012-01-19-0001
        SS10a=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a];
        SSMW4=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10MW4', 'SSMW4')

        %% combined 30 degree responses, in SS30
        % 
        load RG-MW-2012-01-19-0004
        SS30a=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a];
        SSMW4=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30MW4', 'SSMW4')
        %% combined 50 degree responses, in SS50

        load RG-MW-2012-01-19-0002
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-MW-2012-01-19-0003
        SS50b=pa_supersac(Sac,Stim,2,1);



        SS50= [SS50a; SS50b];
        SSMW4=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50MW4', 'SSMW4')
            save('Combined_DataMW4','SS10','SS30','SS50')            
            
case 'HH'
        pa_datadir RG-HH-2011-11-24

        %% combined 10 degree responses, in SS10
        load RG-HH-2011-11-24-0001
        SS10a=pa_supersac(Sac,Stim,2,1);

    %     load RG-HH-2011-12-12-0003
    %     SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a];
        SSHH=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10HH', 'SSHH')

        %% combined 30 degree responses, in SS30
        % 
        load RG-HH-2011-11-24-0004
        SS30a=pa_supersac(Sac,Stim,2,1);

    %     load RG-HH-2011-12-12-0007
    %     SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a];
        SSHH=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30HH', 'SSHH')
        %% combined 50 degree responses, in SS50

        load RG-HH-2011-11-24-0003
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-HH-2011-11-24-0002
        SS50b=pa_supersac(Sac,Stim,2,1);
    %     load RG-HH-2011-12-12-0006
    %     SS50c=pa_supersac(Sac,Stim,2,1);
    %     load RG-HH-2011-12-12-0008
    %     SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b];
        SSHH=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50HH', 'SSHH')
                save('Combined_DataHH','SS10','SS30','SS50')

case 'HH2'
        pa_datadir RG-HH-2011-12-12

        %% combined 10 degree responses, in SS10
        load RG-HH-2011-12-12-0001
        SS10a=pa_supersac(Sac,Stim,2,1);

    %     load RG-HH-2011-12-12-0003
    %     SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a];
        SSHH2=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10HH2', 'SSHH2')

        %% combined 30 degree responses, in SS30
        % 
        load RG-HH-2011-12-12-0004
        SS30a=pa_supersac(Sac,Stim,2,1);

    %     load RG-HH-2011-12-12-0007
    %     SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a];
        SSHH2=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30HH2', 'SSHH2')
        %% combined 50 degree responses, in SS50

        load RG-HH-2011-12-12-0003
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-HH-2011-12-12-0002
        SS50b=pa_supersac(Sac,Stim,2,1);
    %     load RG-HH-2011-12-12-0006
    %     SS50c=pa_supersac(Sac,Stim,2,1);
    %     load RG-HH-2011-12-12-0008
    %     SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b];
        SSHH2=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50HH2', 'SSHH2')
                save('Combined_DataHH2','SS10','SS30','SS50')


case 'HH3'
        pa_datadir RG-HH-2012-01-09

        %% combined 10 degree responses, in SS10
        load RG-HH-2012-01-09-0003
        SS10a=pa_supersac(Sac,Stim,2,1);

        load RG-HH-2012-01-09-0007
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSHH3=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10HH3', 'SSHH3')

        %% combined 30 degree responses, in SS30
        % 
        load RG-HH-2012-01-09-0001
        SS30a=pa_supersac(Sac,Stim,2,1);

        load RG-HH-2012-01-09-0008
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSHH3=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30HH3', 'SSHH3')
        %% combined 50 degree responses, in SS50

        load RG-HH-2012-01-09-0002
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-HH-2012-01-09-0004
        SS50b=pa_supersac(Sac,Stim,2,1);
        load RG-HH-2012-01-09-0006
        SS50c=pa_supersac(Sac,Stim,2,1);
        load RG-HH-2012-01-09-0005
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSHH3=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50HH3', 'SSHH3')
                save('Combined_DataHH3','SS10','SS30','SS50')

            
case 'HH4'
        pa_datadir RG-HH-2012-01-13

        %% combined 10 degree responses, in SS10
        load RG-HH-2012-01-13-0003
        SS10a=pa_supersac(Sac,Stim,2,1);

        load RG-HH-2012-01-13-0006
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSHH4=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10HH4', 'SSHH4')

        %% combined 30 degree responses, in SS30
        % 
        load RG-HH-2012-01-13-0001
        SS30a=pa_supersac(Sac,Stim,2,1);

        load RG-HH-2012-01-13-0007
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSHH4=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30HH4', 'SSHH4')
        %% combined 50 degree responses, in SS50

        load RG-HH-2012-01-13-0002
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-HH-2012-01-13-0004
        SS50b=pa_supersac(Sac,Stim,2,1);
        load RG-HH-2012-01-13-0005
        SS50c=pa_supersac(Sac,Stim,2,1);
        load RG-HH-2012-01-13-0008
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSHH4=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50HH4', 'SSHH4')
                save('Combined_DataHH4','SS10','SS30','SS50')


            
           
case 'RO'
        pa_datadir RG-RO-2011-12-12

        %% combined 10 degree responses, in SS10
        load RG-RO-2011-12-12-0005
        SS10a=pa_supersac(Sac,Stim,2,1);

        load RG-RO-2011-12-12-0003
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSRO=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10RO', 'SSRO')

        %% combined 30 degree responses, in SS30
        % 
        load RG-RO-2011-12-12-0002
        SS30a=pa_supersac(Sac,Stim,2,1);

        load RG-RO-2011-12-12-0007
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSRO=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30RO', 'SSRO')
        %% combined 50 degree responses, in SS50

        load RG-RO-2011-12-12-0001
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-RO-2011-12-12-0004
        SS50b=pa_supersac(Sac,Stim,2,1);
        load RG-RO-2011-12-12-0006
        SS50c=pa_supersac(Sac,Stim,2,1);
        load RG-RO-2011-12-12-0008
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSRO=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50RO', 'SSRO')
                save('Combined_DataRO','SS10','SS30','SS50')


case 'RO2'
        pa_datadir RG-RO-2012-01-11

        %% combined 10 degree responses, in SS10
        load RG-RO-2012-01-11-0002
        SS10a=pa_supersac(Sac,Stim,2,1);

        load RG-RO-2012-01-11-0007
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSRO2=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10RO2', 'SSRO2')

        %% combined 30 degree responses, in SS30
        % 
        load RG-RO-2012-01-11-0004
        SS30a=pa_supersac(Sac,Stim,2,1);

        load RG-RO-2012-01-11-0006
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSRO2=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30RO2', 'SSRO2')
        %% combined 50 degree responses, in SS50

        load RG-RO-2012-01-11-0001
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-RO-2012-01-11-0003
        SS50b=pa_supersac(Sac,Stim,2,1);
        load RG-RO-2012-01-11-0005
        SS50c=pa_supersac(Sac,Stim,2,1);
        load RG-RO-2012-01-11-0008
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSRO2=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50RO2', 'SSRO2')
                save('Combined_DataRO2','SS10','SS30','SS50')

case 'RO3'
        pa_datadir RG-RO-2012-01-18

        %% combined 10 degree responses, in SS10
        load RG-RO-2012-01-18-0003
        SS10a=pa_supersac(Sac,Stim,2,1);

        load RG-RO-2012-01-18-0006
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSRO3=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10RO3', 'SSRO3')

        %% combined 30 degree responses, in SS30
        % 
        load RG-RO-2012-01-18-0001
        SS30a=pa_supersac(Sac,Stim,2,1);

        load RG-RO-2012-01-18-0008
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSRO3=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30RO3', 'SSRO3')
        %% combined 50 degree responses, in SS50

        load RG-RO-2012-01-18-0002
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-RO-2012-01-18-0004
        SS50b=pa_supersac(Sac,Stim,2,1);
        load RG-RO-2012-01-18-0005
        SS50c=pa_supersac(Sac,Stim,2,1);
        load RG-RO-2012-01-18-0007
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSRO3=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50RO3', 'SSRO3')
                save('Combined_DataRO3','SS10','SS30','SS50')


case 'LJ'
        pa_datadir RG-LJ-2011-12-14

        %% combined 10 degree responses, in SS10
        load RG-LJ-2011-12-14-0005
        SS10a=pa_supersac(Sac,Stim,2,1);

        load RG-LJ-2011-12-14-0003
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSLJ=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10LJ', 'SSLJ')

        %% combined 30 degree responses, in SS30
        % 
        load RG-LJ-2011-12-14-0001
        SS30a=pa_supersac(Sac,Stim,2,1);

        load RG-LJ-2011-12-14-0006
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSLJ=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30LJ', 'SSLJ')
        %% combined 50 degree responses, in SS50

        load RG-LJ-2011-12-14-0002
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-LJ-2011-12-14-0004
        SS50b=pa_supersac(Sac,Stim,2,1);
        load RG-LJ-2011-12-14-0007
        SS50c=pa_supersac(Sac,Stim,2,1);
        load RG-LJ-2011-12-14-0008
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSLJ=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50LJ', 'SSLJ')
                save('Combined_DataLJ','SS10','SS30','SS50')

            
case 'LJ2'
        pa_datadir RG-LJ-2011-12-21

        %% combined 10 degree responses, in SS10
        load RG-LJ-2011-12-21-0002
        SS10a=pa_supersac(Sac,Stim,2,1);

        load RG-LJ-2011-12-21-0007
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSLJ2=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10LJ2', 'SSLJ2')

        %% combined 30 degree responses, in SS30
        % 
        load RG-LJ-2011-12-21-0004
        SS30a=pa_supersac(Sac,Stim,2,1);

        load RG-LJ-2011-12-21-0006
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSLJ2=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30LJ2', 'SSLJ2')
        %% combined 50 degree responses, in SS50

        load RG-LJ-2011-12-21-0001
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-LJ-2011-12-21-0003
        SS50b=pa_supersac(Sac,Stim,2,1);
        load RG-LJ-2011-12-21-0005
        SS50c=pa_supersac(Sac,Stim,2,1);
        load RG-LJ-2011-12-21-0008
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSLJ2=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50LJ2', 'SSLJ2')
                save('Combined_DataLJ2','SS10','SS30','SS50')


   
            
            
            
case 'LJ3'
        pa_datadir RG-LJ-2012-01-10

        %% combined 10 degree responses, in SS10
        load RG-LJ-2012-01-10-0003
        SS10a=pa_supersac(Sac,Stim,2,1);

        load RG-LJ-2012-01-10-0007
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSLJ3=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10LJ3', 'SSLJ3')

        %% combined 30 degree responses, in SS30
        % 
        load RG-LJ-2012-01-10-0001
        SS30a=pa_supersac(Sac,Stim,2,1);

        load RG-LJ-2012-01-10-0008
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSLJ3=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30LJ3', 'SSLJ3')
        %% combined 50 degree responses, in SS50

        load RG-LJ-2012-01-10-0002
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-LJ-2012-01-10-0004
        SS50b=pa_supersac(Sac,Stim,2,1);
        load RG-LJ-2012-01-10-0005
        SS50c=pa_supersac(Sac,Stim,2,1);
        load RG-LJ-2012-01-10-0006
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSLJ3=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50LJ3', 'SSLJ3')
                save('Combined_DataLJ3','SS10','SS30','SS50')

            
case 'LJ4'
        pa_datadir RG-LJ-2012-01-17

        %% combined 10 degree responses, in SS10
        load RG-LJ-2012-01-17-0004
        SS10a=pa_supersac(Sac,Stim,2,1);
        
        SS10= [SS10a];
        SSLJ4=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10LJ4', 'SSLJ4')

        %% combined 30 degree responses, in SS30
        % 
        load RG-LJ-2012-01-17-0002
        SS30a=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a];
        SSLJ4=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30LJ4', 'SSLJ4')
                
        %% combined 50 degree responses, in SS50

        load RG-LJ-2012-01-17-0001
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-LJ-2012-01-17-0003
        SS50b=pa_supersac(Sac,Stim,2,1);

        SS50= [SS50a; SS50b];
        SSLJ4=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50LJ4', 'SSLJ4')
                save('Combined_DataLJ4','SS10','SS30','SS50')            
 
            
     
case 'JR'
        pa_datadir RG-JR-2012-01-13

        %% combined 10 degree responses, in SS10
        load RG-JR-2012-01-13-0003
        SS10a=pa_supersac(Sac,Stim,2,1);

        load RG-JR-2012-01-13-0006
        SS10b=pa_supersac(Sac,Stim,2,1);

        SS10= [SS10a; SS10b];
        SSJR=SS10;
        figure(1)
        pa_plotloc(SS10);

            save('SS10JR', 'SSJR')

        %% combined 30 degree responses, in SS30
        % 
        load RG-JR-2012-01-13-0001
        SS30a=pa_supersac(Sac,Stim,2,1);

        load RG-JR-2012-01-13-0007
        SS30b=pa_supersac(Sac,Stim,2,1);

        SS30= [SS30a; SS30b];
        SSJR=SS30;

        figure(2)
        pa_plotloc(SS30);
                save('SS30JR', 'SSJR')
        %% combined 50 degree responses, in SS50

        load RG-JR-2012-01-13-0002
        SS50a=pa_supersac(Sac,Stim,2,1);
        load RG-JR-2012-01-13-0004
        SS50b=pa_supersac(Sac,Stim,2,1);
        load RG-JR-2012-01-13-0005
        SS50c=pa_supersac(Sac,Stim,2,1);
        load RG-JR-2012-01-13-0008
        SS50d=pa_supersac(Sac,Stim,2,1);


        SS50= [SS50a; SS50b; SS50c; SS50d];
        SSJR=SS50;
        figure(3)
        pa_plotloc(SS50);

            save('SS50JR', 'SSJR')
                save('Combined_DataJR','SS10','SS30','SS50')
end


%% 3 matrices with all date:
% SS10, contains all 10 degree responses
% SS30 contains all 30 degree responses
% SS50 contains all 50 degree responses

%Nest step, selection on these, see A4_Select_3Ranges