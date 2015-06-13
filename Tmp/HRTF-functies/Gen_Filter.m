%%Spatial Stimulus generator
% Data input:
% - The mean schroeder sweep with lag
% - mean IPTF minimum phase magnitude spectrum, doesn't realy has to be 
%   smoothed because it will be low-pass filtered.
clear all
close all
Fs=48828.125;
%% Flags
plot_magn_smoothing_Flag    = 1;
plot_IPTF_inv_spect_Flag    = 1;
plot_IPTF_filt_spect_Flag   = 1;
plot_freediff_field_Flag    = 1;
plot_mp_filter_Flag         = 1;
min_phase_imp_env_Flag      = 1;
plot_ILD_bands_Flag         = 1;
Load_data_Flag              = 1;

%% Data input

cd('C:\Documents and Settings\fbinkhor\My Documents\matlab\Data\HRTF')


	[h_fname,h_pname] = uigetfile('*.mat','Select the HRTF meansweeps');
    [i_fname,i_pname] = uigetfile('*.mat','Select the IPTF data');

%Run Mean_sweep to convert the collected data input,.
output_dir=h_pname;
cd(output_dir)

load([i_pname i_fname]);
load([h_pname h_fname]);

hrtf=hrtfDB;
IPTF=spmtf;
% 
% load ([h_pname 'HPL_spect_data.mat'])
% load ([h_pname 'HPR_spect_data.mat'])
load 'ITD_fit.mat'
% HP_L=sqrt(mean(HP_ft_L_rms.^2));
% HP_R=sqrt(mean(HP_ft_R_rms.^2));


%this creates the minimum phase spectrum of the IPTF, output lenght is 2048
%sample

[trl smpl]=size(hrtf(:,:,1));
IPTF_l=sqrt(mean(abs(IPTF(:,:,1)).^2));
%IPTF_l_1=sqrt(mean(abs(IPTF_1(:,:,1)).^2))
%dBlog_plot_duo(IPTF_l(1:512),IPTF_l_1(1:512))

IPTF_r=sqrt(mean(abs(IPTF(:,:,2)).^2));
%IPTF_r_1=sqrt(mean(abs(IPTF_1(:,:,2)).^2))
%dBlog_plot_duo(IPTF_r(1:512),IPTF_r_1(1:512))

IPTF_s_l=c_smooth(1./IPTF_l, 64, 1);
IPTF_s_r=c_smooth(1./IPTF_r, 64, 1);
% IPTF_s_l_1=c_smooth(1./IPTF_l_1, 32, 0)
% IPTF_s_r_1=c_smooth(1./IPTF_r_1, 32, 0)

c_ft_L=c_smooth((hrtf(:,:,1)),128);
c_ft_R=c_smooth((hrtf(:,:,2)),128);

c_ft_L1=hsmooth(hrtf(:,:,1)',8)';
c_ft_R1=hsmooth(hrtf(:,:,2)',8)';
IPTF_l1=hsmooth(1./IPTF_l,8);
IPTF_r1=hsmooth(1./IPTF_r,8);
dBlog_plot_duo(1./IPTF_l1,1./IPTF_l(1:512))

for i=1:trl
    
    dBlog_plot_duo(hrtf(i,1:512,1),c_ft_L1(i,1:512))
     %pause
    close all
end
c_ft_R=c_smooth((hrtf(:,:,2)),64);





ft_L=zeros(trl,smpl);
ft_R=zeros(trl,smpl);

for i=1:trl
    ft_L(i,:)=(c_ft_L(i,:)).*IPTF_s_l;
    ft_R(i,:)=(c_ft_R(i,:)).*IPTF_s_r;
end
ft_L=c_smooth(ft_L,64);
ft_R=c_smooth(ft_R,64);
corr=sqrt(mean(ft_R.^2)./mean(ft_L.^2));
%Spectra_viewer(ft_L,ft_R,Azi_EleHRTF)
%dBlog_plot(corr([1:512]))
ft_Rb=ft_R;
ft_Lb=ft_L;
for i=1:trl
    ft_R(i,:)=ft_Rb(i,:)./sqrt(corr);  
    ft_L(i,:)=ft_Lb(i,:).*sqrt(corr);
end



dBlog_plot_duo(ft_L(13,1:512),ft_R(13,1:512))
dBlog_plot_duo(ft_L(13,1:512),ft_Rb(13,1:512))

mag_spec=zeros(1,1024,2)
mag_spec(:,:,1)=ft_L(13,:);
mag_spec(:,:,2)=ft_R(13,:);

[filt_imp,filt_spec]=mag_spec2min_phase(mag_spec,1024)
plot(filt_imp(:,:,1))
uisave({'filt_imp'},'filt_bal')
% mag_sfe_l=zeros(size(filt_imp_l));
% mag_sfe_r=zeros(size(filt_imp_l));
% for i=1:trl
%     mag_sfe_l(i,:)=c_smooth(abs(fft(filt_imp_l(i,:))),128,0);
%     mag_sfe_r(i,:)=c_smooth(abs(fft(filt_imp_r(i,:))),128,0);
% end
    
%Band 
figure;
NFFT=1024
c_band  =[500;1000;2000;4000;6300;8000;10000;12500];
f_band  =[447 562; 891 1120; 1780 2240; 3550 4470; 5620 7080; 7080 8910; ...
    8910 11200;11200 14100];
band    =round(f_band/(Fs/2)*floor(NFFT/2));
%Snd_Azi_Ele definieren
az=zeros(trl,1);
el=(-45:5:45)';
Snd_Azi_Ele=[az el]

sel     = (Snd_Azi_Ele(:,2)==0);

for i=1:8
    level_l     = mean(abs(hrtf(sel,band(i,1):band(i,2),1)),2);
    level_r     = mean(abs(hrtf(sel,band(i,1):band(i,2),2)),2);
    level_l_1   = mean(abs(ft_L(sel,band(i,1):band(i,2))),2);
    level_r_1   = mean(abs(ft_R(sel,band(i,1):band(i,2))),2);
    ILD         = 20*log10(level_r)-20*log10(level_l);
    ILD_1       = 20*log10(level_r_1)-20*log10(level_l_1);
    subplot(2,4,i)
    %plot(Snd_Azi_Ele(sel,1),ILD)
   plot(Snd_Azi_Ele(sel,1),ILD,Snd_Azi_Ele(sel,1),ILD_1,'r','LineWidth',2)
   grid on
   legend('ori.', 'bal.')
   title({['ILD for 1/3-oct band at ' ...
       num2str(c_band(i)/1000) ' kHz']; ['(Ele=0 deg)']})
   xlabel('Azimuth (deg)')
   ylabel('ILD (dB)')
 %  axis([min(Snd_Azi_Ele(sel,1)) max(Snd_Azi_Ele(sel,1)) ...
  %     -15 +15])
        
end
rel=zeros(size(ft_L))
for i=1:trl
    rel(i,:)=ft_L(i,:)./ft_L(trl,:);
end
    

mag_sfe_l=zeros(size(ft_L));
mag_sfe_r=zeros(size(ft_R));

for i=1:trl
    mag_sfe_l(i,:)=c_smooth(abs(ft_L(i,:)),64,0);
    mag_sfe_r(i,:)=c_smooth(abs(ft_R(i,:)),64,0);
end

mag_soct_l=oct_smooth(ft_L,10);
mag_soct_r=oct_smooth(ft_R,10);
%Spectra_viewer(mag_sfe_l,mag_sfe_r,Snd_Azi_Ele)

%sel=[13 33 63 93 113 123 126]
dBlog_plot(mag_sfe_l(sel,1:512))
axis([200 16000 -25 25])


for i=1:6
    level_l     = mean(abs(mag_sfe_l(sel,band(i,1):band(i,2))),2);
    level_r     = mean(abs(mag_sfe_r(sel,band(i,1):band(i,2))),2);
    level_l_1   = mean(abs(mag_soct_l(sel,band(i,1):band(i,2))),2);
    level_r_1   = mean(abs(mag_soct_r(sel,band(i,1):band(i,2))),2);
    ILD         = 20*log10(level_r)-20*log10(level_l);
    ILD_1       = 20*log10(level_r_1)-20*log10(level_l_1);
    subplot(2,3,i)
   plot(Snd_Azi_Ele(sel,1),ILD,Snd_Azi_Ele(sel,1),ILD_1,'r','LineWidth',2)
   grid on
   legend('cepstral','oct')
   title({['ILD for frequency bands: ' num2str(f_band(i,1)) '-' ...
       num2str(f_band(i,2)) ' Hz']; ['(Ele=0 deg)']})
   xlabel('Azimuth (deg)')
   ylabel('ILD (dB)')
  % axis([min(Snd_Azi_Ele(sel,1)) max(Snd_Azi_Ele(sel,1)) ...
   %    -15 +15])
        
end

mag_spec=zeros(trl,smpl,2);
mag_spec(:,:,1)=mag_sfe_l;
mag_spec(:,:,2)=mag_sfe_r;
[filt_imp,filt_spec]=mag_spec2min_phase(mag_spec,1024)
%Spectra_viewer_Imp(filt_imp(:,:,1),filt_imp(:,:,2),Snd_Azi_Ele)

% for i=1:trl
%     hold on;plot(filt_imp_l(i,:));plot(filt_imp_r(i,:),'g');hold off
%     pause 
%     clf
% end

n_length    = 10000;
noise       = gengwn(n_length,400,800,12000,25000); 
%noise       = stimulus(50,n_length/Fs*1000,Fs)
n_length=length(noise)
volume      =1;
silence     =977;
NFFT        =1024;

imp_length  =silence+NFFT+50;
wav_length  =n_length+silence+50   
wav_matrix  =zeros(trl,n_length,2);
d_onset=zeros(1,trl);
for i=1:trl
    wav         =zeros(n_length,2);
    imp         =zeros(imp_length,2);
    %envelope
    points=n_length;
    k=100;           %rise
    m=n_length-50;          %start fall
    m1=n_length;        %end fall
    y=zeros(1,points);
    y(1:m)=ones(1,m);
    y1=ones(1,points);
    y(m:m1)=cos(0.5*pi*[0:(m1-m)]/(m1-m)).^2;
    y1(1:k+1)=sin(0.5*pi*[0:k]/k).^2;
    env=y.*y1;      %envelope

    d_onset(i)=round(Snd_Azi_Ele(i,1)*ITD_fit(1));
 
    d_onset_v=[1:NFFT]+ abs(d_onset(i));
    if d_onset(i) >= 0  
        imp(silence+[1:NFFT],1)=filt_imp(i,:,1)' ;
        imp(silence+d_onset_v,2)=filt_imp(i,:,2)';
        
    else
        imp(silence+[1:NFFT],2)=filt_imp(i,:,2)';
        imp(silence+d_onset_v,1)=filt_imp(i,:,1)';
        
    end

     wav_l        = env.*filter((imp(:,1)),1,noise);
%       ff_n_l        = conv((filt_imp_l(i,:)),noise);  
    %ff_n_r        = env.*filter((filt_imp_r(i,:)),1,noise);
%       sel           = (Snd_Azi_Ele(:,1)==-Snd_Azi_Ele(i,1)).*...
%                          (Snd_Azi_Ele(:,2)==Snd_Azi_Ele(i,2));
%       sel           =logical(sel);
     wav_r        = env.*filter((imp(:,2)),1,noise);
%       ff_n_r        = conv((filt_imp_r(i,:)),noise);  

    wav(:,1)=wav_l;
    wav(:,2)=wav_r;
   
    wav=volume*wav/max(max(wav));
    %sound(wav,Fs)
    wav_matrix(i,[1:n_length],:)=wav;
    
    [cr_r,lag_r]        = xcorr(wav([1:end],2) ,wav([1:end],1),12,'coeff');
    [mr,ir]             = max(cr_r);
    Lags(i)             = lag_r(ir); 
end  
plot(d_onset)
plot(Lags)

trails=100
Trail_List=round(ceil(25*rand(1,trails)));
%Trail_List=[7 119 8 118 9 117 14 113 15 112 7 119 8 118 9 117 14 113 15 112];
Trail_List=[1:25]
%Trail_List=[13 33 63 93 113 123 126 13 33 63 93 113 123 126 13 33 63 93 113 123 126]
Trail_Azi_Ele=zeros(trails,2)
output_dir='C:\Documents and Settings\fbinkhor\My Documents\matlab\Data\HRTF\'

wav=zeros(length(wav_matrix),2);
wav_l=zeros(length(wav_matrix),1);
wav_r=zeros(length(wav_matrix),1);
figure;
for i=1:trails
    
    sel=Trail_List(i);
    clf
    hold on;
    plot(Snd_Azi_Ele(:,1),Snd_Azi_Ele(:,2),'*')
    plot(Snd_Azi_Ele(sel,1),Snd_Azi_Ele(sel,2),'or')
    hold off
    sel
    wav_l=wav_matrix(sel,:,1)';
    wav_r=wav_matrix(sel,:,2)';
    wav(:,1)=wav_matrix(sel,:,1)';
    wav(:,2)=wav_matrix(sel,:,2)';
    sound(wav,Fs)
    Trail_Azi_Ele (i,:)= Snd_Azi_Ele(sel,:)
    
    
    n_Snd_l=num2str(600+i);
    n_Snd_r=num2str(700+i);
%      wavwrite(wav_l,Fs,16,[output_dir 'Snd' n_Snd_l '.wav']) ;
%      wavwrite(wav_r,Fs,16,[output_dir 'Snd' n_Snd_r '.wav']) ;
    pause
end
