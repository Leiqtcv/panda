% Deze functie laadt ruwe HRTF-data in, verwijdert de eerste en laatste
% sweep, neemt een gemiddelde van de overgebleven sweeps en maakt hiervan
% een fft. Uiteindelijk heb je het complexe HRTF spectrum en de
% bijbehorende locaties (Snd_Azi_Ele) nodig voor verder processing. 


%You need to run the have the auditory toolbox to run the script
%Don't use the beta version voor readcsv because that one won't work with
%this function. Deze kan rare locaties opleveren (hoeft niet).  

%Input measured schroeder sweep
%Input stimulus sound file
%Choose number of blocks(=sweeps) per stimuli


%%

clear all
close all

Load_hrtf_Flag       =      1;	%1==user_select hrtf data; 0==default data file
Load_wav_Flag        =      1;  %1==user_select wav data; 0==default data file
Envelope_FLag        =      1;
Plot_blocks_Flag     =      0;
Plot_mean_Flag       =      0;
Plot_env_Flag        =      0;
Plot_Trls_Flag       =      0;  %1==plot collected trials; 0==don't plot
Mean_sweep_w_lag_Flag=      0;
listen_Data_Flag     =      1;
Plot_ILD_Flag        =      1;


%%
%--Loading needed datafiles--%

%Hrtf measurements
%cd('S:\Stage\Experimenten\HRTF-Meting')
if( Load_hrtf_Flag )
	[h_fname,h_pname] = uigetfile('*.hrtf','Select the HRTF-file');
else
	h_pname = 'F:\Stage\Experimenten\HRTF-Meting\ST\HRTF-2008-06-10\DAT\';
	h_fname = 'ST-ST-2008-06-10-0001.hrtf';
end

fid = fopen([h_pname h_fname]);
dat = fread(fid,'float','l');
fclose(fid);

% cd([h_pname([1:length(h_pname)-4]) 'SND\'])
cd(h_pname)

%Loading used stimulus wavefile
if( Load_wav_Flag )
	[w_fname,w_pname] = uigetfile('*.wav','Select the WAV-file');
else
    w_pname = 'F:\Stage\Experimenten\HRTF-Meting\ST\HRTF-2008-06-10\SND\';
    w_fname='Snd101.wav';
end
[Stim,Fs,bits] = wavread([w_pname w_fname]);
Stim_length = size(Stim,1);

Fs=48828.125;


%--datafile readout--%

%Get the target info to calculate the nbr of trls
[expinfo,chaninfo,cLog] = readcsv([h_pname h_fname]);
%Select sound locations by looking for snd name%
Snd_X_Y                 = cLog(cLog(:,5) == 2,6:7);
Snd_lvl(:,1)			= cLog(cLog(:,5) == 2,10);
Snd_Lvl(:,2)   		    = cLog(cLog(:,5) == 3,10);
[Azi,Ele]               = fart2azel(Snd_X_Y(:,1),Snd_X_Y(:,2)) ;
Snd_Azi_Ele             =[Azi,Ele] ;

%Numer of trials in dat file
%data aquisition program adds 100 samples after the stimulus.
dat_ntrl    = expinfo(4)*expinfo(3);
dat_nchan   = 2;
dat_unit    = Stim_length+100;	

%Reshape the data: 
%assuming that: channel_1 = left and channel_2 = right 
Data            = reshape(dat,dat_unit,dat_nchan,dat_ntrl);
% Data            = reshape(dat,length(dat)/dat_nchan/dat_ntrl,dat_nchan,dat_ntrl);

%remove the 977 samples of zero at beginning of stimulus 
%(deze zijn ingebouwd zodat de ramp van het data aquisitie programma kan blijven) 
Stim_length_ns      = [1:Stim_length]; 
Data_Left           = squeeze(Data(Stim_length_ns,1,:))';
Data_Right          = squeeze(Data(Stim_length_ns,2,:))';

%Sorting data, clustering same elevations
pos_Ele             =[-90:1:90]';
Ele_mem             =ismember(pos_Ele,Snd_Azi_Ele(:,2));
Elevs               =pos_Ele(Ele_mem);

Data_Left_s         =zeros(size(Data_Left));
Data_Right_s        =zeros(size(Data_Right));
Snd_Azi_Ele_s       =zeros(size(Snd_Azi_Ele));

ind_e=0;
indx=0;
for i=Elevs'
    sel                     =Snd_Azi_Ele(:,2)==i;
    n_sel                   =sum(sel);
    ind_b                   =ind_e+1;
    ind_e                   =ind_b+n_sel-1;
    indx                    =[ind_b:ind_e];
    Snd_Azi_Ele_s(indx,:)   =Snd_Azi_Ele(sel,:);
    Data_Left_s(indx,:)     =Data_Left(sel,:);
    Data_Right_s(indx,:)    =Data_Right(sel,:);
end

Data_Left   = Data_Left_s;
Data_Right  = Data_Right_s;
Snd_Azi_Ele = Snd_Azi_Ele_s;    


% Possibility to plot collected raw data; left and right channel
% Hierin zie je dat het linker kanaal net iets eerder begint dan het
% rechter, bij een locatie links en dat het rechter signaal dan ook een
% kleinere amplitude heeft.
wav=zeros(length(Data_Left),2);
if (Plot_Trls_Flag)
	figure(1);
    t = 0:1/(Fs-1):size(Data_Right,2)/Fs;
	for i=1:size(Data_Right,1)
		clf
		hold on
		plot(t*10^3,Data_Left(i,[1:length(t)])*10^3,'k-')
		plot(t*10^3,Data_Right(i,[1:length(t)])*10^3,'r--')
		xlabel('time [msec]')
		ylabel('amplitude [mV]')
		xlim([0 t(end)*10^3])
		title(['Azi: ' num2str(Snd_Azi_Ele(i,1)) ' deg, Ele: ' num2str(Snd_Azi_Ele(i,2)) ' deg'])
		legend('Left','Right')
        box on
        if (listen_Data_Flag)
        wav(:,1)=Data_Left(i,[1:Stim_length]);
        wav(:,2)=Data_Right(i,[1:Stim_length]);
        sound(wav,Fs)
        end
		reply = 's'%input(['\n' 'Press enter to continue.' ...
            %'\n' 'Input s to break!' ...
            %'\n' '\\'], 's');
        if reply == 's'
            close all
            break;
        end
        
    end
    close all
end
%%
%--Data processing--% 
% Number of Schroeder-sweeps used = NBlock (default 18), discarding first and
% last Schroeder-sweep. Dit omdat er een ramp om het geluid heen zit (de
% amplitude loopt geleidelijk op). Als dit niet het geval is, hoor je een
% klik. 
% In de laatste experimenten hebben we een sweep train gebruikt, van 40 sweeps. Dus hier
% kies je "t". De eerste en laatste moeten we verwijderen, vanwege de ramp,
% dus NBlock hieronder wordt 38.
NFFT	= 1024;
nBegin  = ceil(20/1000*Fs);		% 20 ms silence before stimulus starts (is 977 samples, zie boven)
N_trials= dat_ntrl;
stim_t  = 'nothing_yet';
while stim_t=='nothing_yet'
    stim_t = 't'  %input(['\n' 'Choose "t" if used stimulus was a sweep train or noise.' ...
        %'Choose "l" if it was one long sweep' '\n' '\\'], 's');
    if stim_t=='t'
        NBlock  = 18;%(Stim_length-977-4000)/NFFT - 2;  %Calculation of number of blocks in stimulus
    elseif stim_t=='l'
        NBlock  =1;
        NFFT=Stim_length-977-100;
    else
       stim_t  = 'nothing_yet';
    end
end

% speeding up the script by already creating empty vectors
HRTF_ITD=zeros(N_trials,2*NFFT,2);
Lag_Right=zeros(1,N_trials);
Lag_Left=zeros(1,N_trials);
ITD_RL=zeros(1,N_trials);
L_norm=zeros(N_trials,NFFT);
R_norm=zeros(N_trials,NFFT);
Ft_blocks_L=zeros(NFFT,NBlock,N_trials);
Ft_blocks_R=zeros(NFFT,NBlock,N_trials);

%Filter for cross correlation --> ITD
% cutoff       help tilefig   = 4000; %Hz
% 
% max_freq        = Fs/2;
% c_off           = round(cutoff/max_freq*NFFT);
% f               = 0:1/(NFFT-1):1; 
% m               = zeros(1,NFFT);
% m(1,1:c_off)    = ones(1,c_off);
% b               = fir2(1024,f,(m));

% Low-pass and high pass filter for the stimulus
[B,A]   = butter(9,500/(Fs/2),'high');
[B1,A1] = butter(15,20000/(Fs/2));
% sweep=gensweep(1024, 400, 42000, Fs, 1, 1, 0)/10;
% sweep_rev=ifft(conj(fft(sweep)))


for i   = 1:N_trials;
    %-- Correlation Simulus and left and rightear measurements
    % Right ear
    % Deze regel kan ook highpass en lowpass worden, weet niet goed wat het
    % verschil is.
    trial_R             = filtfilt(B,A,filtfilt(B1,A1,Data_Right(i,1:end)));
    [cr_r,lag_r]        = xcorr(trial_R ,Stim,330,'coeff');  %maximum correlation= 330 samples
	[mr,ir]             = max(cr_r);
	Lag_Right(i)        = lag_r(ir);    %lag given in samples
	     
	% Left ear
    % Deze regel kan ook highpass en lowpass worden, weet niet goed wat het
    % verschil is.
	trial_L            = filtfilt(B,A,filtfilt(B1,A1,Data_Left(i,1:end)));
    [cr_l,lag_l]       = xcorr(trial_L,Stim,330,'coeff'); %maximum correlation= 330 samples
	[mr,il]            = max(cr_l);
	Lag_Left(i)        = lag_l(il);    %lag given in samples
    
     %-- Also checking correlation between left an right signal.
%     trial_Rf            = filter(b,1,trial_R(1,[1:3*NFFT]));
%     trial_Lf            = filter(b,1,trial_L(1,[1:3*NFFT]));
    [cs,ls]             = xcorr(trial_R,trial_L,50,'coeff');
    [ms,is]             = max(cs);
    ITD_RL(i)           = ls(is);
  
    
    %-- lags will become the onset for selecting the 
    %response blocks from the trial
   
    if stim_t~='l'
        nOnset_Left     = nBegin+ NFFT + Lag_Left(i);
        nOnset_Right    = nBegin+ NFFT + Lag_Right(i);
    else
        nOnset_Left=0;
        nOnset_Right=0;
    end
    
    idx_l           = nOnset_Left + (1:(NFFT*NBlock));
 	idx_r           = nOnset_Right + (1:(NFFT*NBlock));
    
    % Dit is dus data zonder lags van één bepaalde locatie
    L               = reshape(trial_L(idx_l), NFFT, NBlock);
    R               = reshape(trial_R(idx_r), NFFT, NBlock);
    
    
    if(Plot_blocks_Flag)
        t_size=max([length(L) length(R)]);
        t_l = 0:1/(Fs-1):length(L)/Fs;
        t_r = 0:1/(Fs-1):length(R)/Fs;
        figure(5);
		plot(t_l*10^3,L*10^3);
        xlabel('time [msec]');
		ylabel('amplitude [mV]');
		%xlim([0 t_size*10^3]);
		title(['Left channel, ' num2str(NBlock) ' Blocks; Azi: ' ...
            num2str(Snd_Azi_Ele(i,1)) ' deg, Ele: ' ...
            num2str(Snd_Azi_Ele(i,2)) ' deg']);
		
        figure(6);
        plot(t_r*10^3,R*10^3);
        xlabel('time [msec]');
		ylabel('amplitude [mV]');
		%xlim([0 t_size*10^3]);
		title(['Right channel,' num2str(NBlock) ' Blocks; Azi: ' ...
            num2str(Snd_Azi_Ele(i,1)) ' deg, Ele: ' ...
            num2str(Snd_Azi_Ele(i,2)) ' deg']);
        if (Plot_env_Flag == 0) && (Plot_mean_Flag == 0)
            tilefig;
            reply = input(['\n' 'Press enter to continue.' ...
            '\n' 'Input s to break!' ...
            '\n' '\\'], 's');
            if reply == 's' 
                Plot_blocks_Flag=0;
            end
            
            close all;
        end
        
    end
    
       
    %mean over blocks in a trial, DC correction
    L_sweeps_mean           = mean(L,2)';
    L_trial_mean            = mean(L_sweeps_mean);
    L_norm(i,:)             = L_sweeps_mean-L_trial_mean; % DC correction: gem op nul stellen
    
    R_sweeps_mean           = mean(R,2)';
    R_trial_mean            = mean(R_sweeps_mean);
    R_norm(i,:)             = R_sweeps_mean-R_trial_mean;
    
    %Sort of envelope to make start and end of HRTF measuremtents go to
    %zero. Envelope has a rise of sin^2 and fall of cos^2
    if(Envelope_FLag)
        points=NFFT;
        k=50;           %rise
        m=NFFT-50;          %start fall
        m1=NFFT;        %end fall
        y=zeros(1,points);
        y(1:m)=ones(1,m);
        y1=ones(1,points);
        y(m:m1)=cos(0.5*pi*[0:(m1-m)]/(m1-m)).^2;
        y1(1:k+1)=sin(0.5*pi*[0:k]/k).^2;
        env=y.*y1;      %envelope
    else
        env=ones(1,NFFT);
    end
    
    if(Plot_env_Flag)
        t_size=max([length(L) length(R)]);
        t_l = 0:1/(Fs-1):length(L)/Fs;
        t_r = 0:1/(Fs-1):length(R)/Fs;
        figure(1);
		plot(t_l*10^3,L_norm(i,:)*10^3,t_l*10^3,zeros(1,NFFT),t_l*10^3,env*10^3);
        xlabel('time [msec]');
		ylabel('amplitude [mV]');
		%xlim([0 t_size*10^3]);
		title(['Left channel, mean + envelope; Azi: ' ...
            num2str(Snd_Azi_Ele(i,1)) ' deg, Ele: ' ...
            num2str(Snd_Azi_Ele(i,2)) ' deg']);
		figure(2);
        plot(t_r*10^3,R_norm(i,:)*10^3,t_r*10^3,zeros(1,NFFT),t_r*10^3,env*10^3);
        xlabel('time [msec]');
		ylabel('amplitude [mV]');
		%xlim([0 t_size*10^3]);
		title(['Right channel,mean + envelope; Azi: ' ...
            num2str(Snd_Azi_Ele(i,1)) ' deg, Ele: ' ...
            num2str(Snd_Azi_Ele(i,2)) ' deg']);
        if (Plot_mean_Flag == 0)
            tilefig;
            reply = input(['\n' 'Press enter to continue.' ...
            '\n' 'Input s to break!' ...
            '\n' '\\'], 's');
            if reply == 's' 
                Plot_env_Flag=0;
                Plot_blocks_Flag=0;
            end
          
            close all;
        end
    end
    % Envelop erover
    L_norm(i,:)=L_norm(i,:).*env;
    R_norm(i,:)=R_norm(i,:).*env;
    
    if(Plot_mean_Flag)
        t_size=max([length(L) length(R)]);
        t_l = 0:1/(Fs-1):length(L)/Fs;
        t_r = 0:1/(Fs-1):length(R)/Fs;
        figure(3);
		plot(t_l*10^3,L_norm(i,:)*10^3,t_l*10^3,zeros(1,NFFT));
        xlabel('time [msec]');
		ylabel('amplitude [mV]');
		%xlim([0 t_size*10^3]);
		title(['Left HRTF impulse response; Azi: ' ...
            num2str(Snd_Azi_Ele(i,1)) ' deg, Ele: ' ...
            num2str(Snd_Azi_Ele(i,2)) ' deg']);
		figure(4);
        plot(t_r*10^3,R_norm(i,:)*10^3,t_r*10^3,zeros(1,NFFT));
        xlabel('time [msec]');
		ylabel('amplitude [mV]');
		%xlim([0 t_size*10^3]);
		title(['Right HRTF impulse response; Azi: ' ...
            num2str(Snd_Azi_Ele(i,1)) ' deg, Ele: ' ...
            num2str(Snd_Azi_Ele(i,2)) ' deg']);
        
        tilefig;
        reply = input(['\n' 'Press enter to continue.' ...
        '\n' 'Input s to break!' ...
        '\n' '\\'], 's');
        
        if reply == 's' 
            Plot_env_Flag=0;
            Plot_blocks_Flag=0;
            Plot_mean_Flag=0;
        end
        
        close all;
        
    end
    
    % Frequentie spectrum van de data per blok
    for k=1:NBlock
    Ft_blocks_L(:,k,i)=fft(L(:,k));
    Ft_blocks_R(:,k,i)=fft(R(:,k));
    end
end



% Spectra berekenen, weet niet waarom ft_rms en ft beide zijn berekend. 
ft_rms=zeros(N_trials,NFFT,2);
ft    =zeros(N_trials,NFFT,2);
for i=1:N_trials
     ft_rms(i,:,1)   =sqrt(mean((Ft_blocks_L(:,:,i).^2),2)');
     ft_rms(i,:,2)   =sqrt(mean((Ft_blocks_R(:,:,i).^2),2)');
     ft(i,:,1)       =fft(L_norm(i,:));
     ft(i,:,2)       =fft(R_norm(i,:));
  %   figure
  %   dBlog_plot_duo(ft(i,1:512,1),ft_rms(i,1:512,1),0)
%      tilefig;
%      pause
%      close all
end

% Even snel de spectra bekijken, met een niet goede smoothing functie
% smooth. Dus dit niet gebruiken voor het synthetiseren van geluiden!
% figure
% for j = 1:N_trials
% n=length(ft(j,:,1))/2-1;
% spectrum=ft(j,[2:n+1],1); %don't take freq=0 value
% log_spect=20*log10(abs(spectrum));
% as=[1:1:n]*Fs/n/2;
% semilogx(as,smooth(log_spect,10),'color',[j*0.05 0 0],'LineWidth',2);
% hold on
% end
% set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
% set(gca,'FontName','Arial','FontSize',14,'LineWidth',2);
% xaxis(1000,14000)
% yaxis(-40,40)
% title('Magnitude','fontsize',18,'fontweight','bold')
% xlabel('frequency (Hz)','fontsize',18,'fontweight','bold')
% ylabel('magnitude [dB]','fontsize',18,'fontweight','bold')


%ILD plot for azi=0
if (Plot_ILD_Flag)
    figure;
    NFFT=1024
    c_band  =[500;1000;2000;4000;6300;8000;10000;12500];
    f_band  =[447 562; 891 1120; 1780 2240; 3550 4470; 5620 7080; 7080 8910; ...
    8910 11200;11200 14100];
    band    =round(f_band/(Fs/2)*floor(NFFT/2));
    sel     = (Snd_Azi_Ele(:,2)==0);

    for i=1:8
        level_l     = mean(abs(ft(sel,band(i,1):band(i,2),1)),2);
        level_r     = mean(abs(ft(sel,band(i,1):band(i,2),2)),2);
%     level_l_1   = mean(abs(ft_L(sel,band(i,1):band(i,2))),2);
%     level_r_1   = mean(abs(ft_Rb(sel,band(i,1):band(i,2))),2);
        ILD         = 20*log10(level_r)-20*log10(level_l);
%     ILD_1       = 20*log10(level_r_1)-20*log10(level_l_1);
        subplot(2,4,i)
        plot(Snd_Azi_Ele(sel,1),ILD,'o')
%    plot(Snd_Azi_Ele(sel,1),ILD,Snd_Azi_Ele(sel,1),ILD_1,'r','LineWidth',2)
        grid on
 %  legend('ori.', 'bal.')
        title({['ILD for 1/3-oct band at ' ...
            num2str(c_band(i)/1000) ' kHz']; ['(Ele=0 deg)']})
        xlabel('Azimuth (deg)')
        ylabel('ILD (dB)')
%         axis([min(Snd_Azi_Ele(sel,1)) max(Snd_Azi_Ele(sel,1)) ...
%        -15 +15])
    end
end


% Dus uiteindelijk is HRTF een complex spectrum. 
HRTF = ft; % of IPTF = ft; Als je de koptelefoondata uitgewerkt hebt. 


% Data opslaan
name = 'hrtfFB2'%input(['\n' 'Input desired variable name for spectrum:' '\n' ...
        %    '\\'], 's');
eval([name '=ft;'])
eval(['Azi_Ele' name '=Snd_Azi_Ele;'])
% plot(mean(Mean_sweep_r(:,:)))
cd(h_pname(1:length(h_pname))) 
uisave({name,['Azi_Ele' name]},[name '_spectra']) ;
uisave({'ITD_RL','Snd_Azi_Ele'},[name]) ;

%cd('C:\Documents and Settings\fbinkhor\My Documents\matlab\Data\HRTF\2008-09-15\') 

%uisave({'Snd_Azi_Ele','ITD_RL', 'Lag_Left','Lag_Right', ...
%    'L_sweeps_mean', 'R_sweeps_mean'},'Mean_sweep') ;


