%%% Deze functie berekent de ILD op basis van opgenomen ruis bursts van 20
%%% ms. 
%%%
%%% Kies bovenaan of je een bepaalde HRTF data set wilt laden,of een
%%% bepaalde wav. Anders neemt hij een standaard set en wav. Deze moet je
%%% dan wel op je computer hebben staan. 
%%%
%%% Kies ook de stimulus lengte en het aantal punten FFT dat je wil gaan
%%% nemen. 
%%

clear all
close all

Load_hrtf_Flag       =      1;	%1==user_select hrtf data; 0==default data file
Load_wav_Flag        =      1;  %1==user_select wav data; 0==default data file
%% Parameters
stim_length = 976; % 976 als stim is 20ms noise
Fs=48828.125;
NFFT	= 978;
subject = 'JT';

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
Stim2 = Stim(977:end);
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

%remove the 977 samples of zero at beginning of stimulus
%(deze zijn ingebouwd zodat de ramp van het data aquisitie programma kan blijven)
Stim_length_ns      = 977:Stim_length;
Data_Left           = squeeze(Data(Stim_length_ns,1,:))';
Data_Right          = squeeze(Data(Stim_length_ns,2,:))';

% figure;plot(Data_Left')

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

%--Data processing--%
N_trials= dat_ntrl;
NBlock  =1;


% speeding up the script by already creating empty vectors
Lag_Right=zeros(1,N_trials);
Lag_Left=zeros(1,N_trials);
ITD_RL=zeros(1,N_trials);
L_norm=zeros(N_trials,stim_length);
R_norm=zeros(N_trials,stim_length);

% Coeffienten voor low- en highpassfilter
[B,A]   = butter(9,500/(Fs/2),'high');
[B1,A1] = butter(15,20000/(Fs/2));


for i   = 1:N_trials;
    %-- Correlation Simulus and left and rightear measurements
    % Right ear
    %     trial_R             = filtfilt(B,A,filtfilt(B1,A1,Data_Right(i,1:end)));
    trial_R             = highpass(Data_Right(i,1:end),500/(.5*Fs),100);
    trial_R             = lowpass(trial_R,20000/(.5*Fs),100);
    [cr_r,lag_r]        = xcorr(trial_R ,Stim2,330,'coeff');  %maximum correlation= 330 samples
    [mr,ir]             = max(cr_r);
    Lag_Right(i)        = lag_r(ir);    %lag given in samples

    % Left ear
    %     trial_L             = filtfilt(B,A,filtfilt(B1,A1,Data_Left(i,1:end)));
    trial_L             = highpass(Data_Left(i,1:end),500/(.5*Fs),100);
    trial_L             = lowpass(trial_L,20000/(.5*Fs),100);
    [cr_l,lag_l]       = xcorr(trial_L,Stim2,330,'coeff'); %maximum correlation= 330 samples
    [mr,il]            = max(cr_l);
    Lag_Left(i)        = lag_l(il);    %lag given in samples

    % % %     XX = abs(fft(trial_L,NFFT));
    % % %     XXX = abs(fft(trial_R,NFFT));
    % % %     dBlog_plot_duo(XX(2:513),XXX(2:513))
    %-- Also checking correlation between left an right signal.
    [cs,ls]             = xcorr(trial_R,trial_L,50,'coeff');
    [ms,is]             = max(cs);
    ITD_RL(i)           = ls(is);


    %-- lags will become the onset for selecting the
    %response blocks from the trial

    nOnset_Left     = Lag_Left(i);
    nOnset_Right    = Lag_Right(i);

    idx_l           = nOnset_Left + (1:(stim_length));
    idx_r           = nOnset_Right + (1:(stim_length));

    % Dit is dus data zonder lags van één bepaalde locatie
    L               = trial_L(idx_l);
    R               =  trial_R(idx_r);

% figure;hold on;plot(trial_L,'r');plot(L);plot(Stim(977:end),'g')


    %mean over blocks in a trial, DC correction
    L_mean           = mean(L);
    L_norm(i,:)      = L-L_mean; % DC correction: gem op nul stellen

    R_mean           = mean(R);
    R_norm(i,:)      = R-R_mean;

    %         figure;plot(L_norm(i,:))

    % Envelope
    points=stim_length;
    k=50;           %rise
    m=stim_length-50;          %start fall
    m1=stim_length;        %end fall
    y=zeros(1,points);
    y(1:m)=ones(1,m);
    y1=ones(1,points);
    y(m:m1)=cos(0.5*pi*[0:(m1-m)]/(m1-m)).^2;
    y1(1:k+1)=sin(0.5*pi*[0:k]/k).^2;
    env=y.*y1;      %envelope
    L_norm(i,:)=L_norm(i,:).*env;
    R_norm(i,:)=R_norm(i,:).*env;

end

ft    =zeros(N_trials,NFFT,2);
for i=1:1:N_trials
    ft(i,:,1)       =fft(L_norm(i,:),NFFT);
    ft(i,:,2)       =fft(R_norm(i,:),NFFT);
    %     dBlog_plot_duo(ft(i,1:512,1),ft(i,1:512,2))
end

ft_azi=zeros(13,NFFT,2);
k=0;
for i=79:91
    k=k+1;
ft_azi(k,:,1)=ft(i,:,1);
ft_azi(k,:,2)=ft(i,:,2);
end


%% ILDfactor gemiddeld over alle frequenties

% ILD in verschillende banden bekijken
% c_band  =[500;1000;2000;4000;6300;8000;10000;12500];
% f_band  =[447 562; 891 1120; 1780 2240; 3550 4470; 5620 7080; 7080 8910; ...
%     8910 11200;11200 14100];
% band    =round(f_band/(Fs/2)*floor(NFFT/2));
% figure(1)
% for i=1:length(c_band)
%     level_l     = mean(abs(ft(:,band(i,1):band(i,2),1)),2);
%     level_r     = mean(abs(ft(:,band(i,1):band(i,2),2)),2);
%     ILD         = 20*log10(level_r)-20*log10(level_l);
%     subplot(2,4,i)
%     plot(Snd_Azi_Ele(:,1),ILD,'o')
%     grid on
%     title({['ILD for 1/3-oct band at ' ...
%         num2str(c_band(i)/1000) ' kHz']; ['(Ele=0 deg)']})
%     xlabel('Azimuth (deg)')
%     ylabel('ILD (dB)')
%     %         axis([min(Snd_Azi_Ele(:,1)) max(Snd_Azi_Ele(:,1)) ...
%     %        -15 +15])
% end

% Spectrum middelste HRTF middelen:
n = NFFT/2-1;
middel_l=c_smooth(abs(ft_azi(7,:,1)),64);
middel_r=c_smooth(abs(ft_azi(7,:,2)),64);
spectrum_m_l=middel_l(2:n+1);
spectrum_m_r=middel_r(2:n+1);

ILD=zeros(13,NFFT);
ILD_factor=zeros(7,NFFT,2);
k=0;
for i=[1 3 5 7 8 11 13]
    k=k+1;
    %     figure(2)
    level_l     = abs(ft_azi(i,:,1));
    level_r     = abs(ft_azi(i,:,2));

    %smoothen
    level_l=c_smooth((level_l),64);
    level_r=c_smooth((level_r),64);

    %     dBlog_plot_duo(level_l(1:NFFT/2),level_r(1:NFFT/2))

    spectrum_l=level_l(2:n+1); %don't take freq=0 value
    spectrum_r=level_r(2:n+1); %don't take freq=0 value
    log_spect_l=20*log10(spectrum_l);
    log_spect_r=20*log10(spectrum_r);
    as=[1:1:n]*Fs/n/2;
    log_middel_l=20*log10(middel_l(2:n+1));
    log_middel_r=20*log10(middel_r(2:n+1));
    figure(1)
    subplot(2,4,k)
    semilogx(as,log_spect_l,'b','LineWidth',2);    hold on
    semilogx(as,log_spect_r,'r','LineWidth',2);
    %semilogx(as,log_middel_l,'k--','LineWidth',2);
    %semilogx(as,log_middel_r,'k','LineWidth',2);
    set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
    %set(gca,'FontName','Arial','FontSize',14,'LineWidth',2);
    xaxis(1000,14000)
    yaxis(-40,40)
    title('Level Left ear (blue) and Right ear (red)')
    xlabel('frequency (Hz)')
    ylabel('magnitude [dB]')

%     for j=1:NFFT
%         factor_l(j)=level_l(j)/middel_l(j);
%         factor_r(j)=level_r(j)/middel_r(j);
%     end
        factor_l=level_l./middel_l;
        factor_r=level_r./middel_r;

    ILD_factor(k,:,1)=factor_l;
    ILD_factor(k,:,2)=factor_r;
figure(2)
subplot(2,4,k)
    semilogx(as,factor_l(2:n+1),'b','LineWidth',1);  hold on
    semilogx(as,factor_r(2:n+1),'r','LineWidth',1);
    set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
    % set(gca,'FontName','Arial','FontSize',14,'LineWidth',2);
    xaxis(1000,14000)
         yaxis(-5,5)
    title('Filter Left ear (blue) and Right ear (red)')
    xlabel('frequency (Hz)')
    ylabel('magnitude [dB]')
    
end

% Magnitude spectrum to minimum phase
mag_sfe_l=zeros(size(ILD_factor(:,:,1)));
mag_sfe_r=zeros(size(ILD_factor(:,:,2)));

for i=1:7
    mag_sfe_l(i,:)=c_smooth(abs(ILD_factor(i,:,1)),64,0);
    mag_sfe_r(i,:)=c_smooth(abs(ILD_factor(i,:,2)),64,0);
end

mag_spec=zeros(7,NFFT,2);
mag_spec(:,:,1)=mag_sfe_l;
mag_spec(:,:,2)=mag_sfe_r;

[filt_level,filt_spec]=mag_spec2min_phase(mag_spec,NFFT);
eval(['uisave(''filt_level'',''filt_level' subject ''')']);
