
% ITD's bepalen

clear all
close all

Load_hrtf_Flag       =      1;	%1==user_select hrtf data; 0==default data file
Load_wav_Flag        =      1;

% Data Loaden
if( Load_hrtf_Flag )
	[h_fname,h_pname] = uigetfile('*.hrtf','Select the HRTF-file');
else
	h_pname = 'C:\Documents and Settings\fbinkhor\My Documents\matlab\Data\HRTF\DAT\';
	h_fname = 'FB-FB-2008-09-17-0001.hrtf';
end

fid = fopen([h_pname h_fname]);
dat = fread(fid,'float','l');
fclose(fid);

cd(h_pname)

%Loading used stimulus wavefile
if( Load_wav_Flag )
	[w_fname,w_pname] = uigetfile('*.wav','Select the WAV-file');
else
    w_pname = 'C:\Documents and Settings\fbinkhor\My Documents\matlab\Data\HRTF\';
    w_fname='Snd301.wav';
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
pos_Ele             =[0]';
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

NFFT	= 1024;
nBegin  = ceil(20/1000*Fs);		% 20 ms silence before stimulus starts (is 977 samples, zie boven)
N_trials= dat_ntrl;
NBlock  =1;
NFFT=Stim_length-977-100

% speeding up the script by already creating empty vectors
HRTF_ITD=zeros(37,2*NFFT,2);
Lag_Right=zeros(1,37);
Lag_Left=zeros(1,37);
ITD_RL=zeros(1,37);
L_norm=zeros(37,NFFT);
R_norm=zeros(37,NFFT);
Ft_blocks_L=zeros(NFFT,NBlock,37);
Ft_blocks_R=zeros(NFFT,NBlock,37);


% Low-pass and high pass filter for the stimulus
[B,A]   = butter(9,500/(Fs/2),'high');
[B1,A1] = butter(15,20000/(Fs/2));

for i   = 1:37%N_trials;
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
end

% Plot ITD
figure(1);
as=Snd_Azi_Ele(1:37,1);
ITD_time=ITD_RL/Fs*1000;
z = (as-mean(as))/std(as);
pz = polyfit(z,ITD_time',1);
c=as./z;
ITD_fitPB=[pz(1)/c(1) pz(2)];
uisave('ITD_fitPB','ITD_fitPB')

plot_ITD(ITD_RL,Snd_Azi_Ele(1:37,:))