clear all
close all
cd('C:\Documents and Settings\fbinkhor\My Documents\matlab\Data\HRTF\2008-09-17\spectras\')
files= dir('C:\Documents and Settings\fbinkhor\My Documents\matlab\Data\HRTF\2008-09-17\spectras\*.mat')
for i=1:length(files)
    load(files(i,:).name)
end
trl     =19;
nfft    =1024;
chnl    =2;
n_HRTF  =4;
Fs=48828.125;

sel=zeros(126,1);
for i=1:length(Azi_EleHRTF_0627)
    temp=(Azi_EleHRTF_0527(:,1)==Azi_EleHRTF_0627(i,1)).*(Azi_EleHRTF_0527(:,2)==Azi_EleHRTF_0627(i,2));
    sel=sel+temp;
end
sel_loc=logical(sel);

sel_n=whos('HRTF_0*');
names=char(sel_n(:,1).name);
HRTF=struct('info',{[trl nfft chnl n_HRTF]},'name',{names}, ...
    'spectra',{cell(4,1)},'Azi_Ele',{Azi_EleHRTF_0627(:,:)});

for i=1:3
    eval(['HRTF.spectra{i}=' HRTF.name(i,:) '(sel_loc,:,:)'])
end
HRTF.spectra{4}=HRTF_0627;


sel_n=whos('HRTF_0*');
names=char(sel_n(:,1).name);
HRTF_diff=struct('info',{[trl nfft chnl n_HRTF-1]},'name',{names(1:3,:)}, ...
    'spectra',{cell(4,1)},'Azi_Ele',{Azi_EleHRTF_0610(:,:)})
for i=1:3
    eval(['rms_l=sqrt(mean(abs(' names(i,:) '(:,:,1)).^2));'])
    eval(['rms_r=sqrt(mean(abs(' names(i,:) '(:,:,2)).^2));'])
    for k=1:126
        eval(['HRTF_diff.spectra{i}(k,:,1)=abs(' names(i,:) '(k,:,1))./rms_l;'])
        eval(['HRTF_diff.spectra{i}(k,:,2)=abs(' names(i,:) '(k,:,2))./rms_r;'])
    end
end
eval(['rms_l=sqrt(mean(abs(' names(4,:) '(:,:,1)).^2));'])
eval(['rms_r=sqrt(mean(abs(' names(4,:) '(:,:,2)).^2));'])
for k=1:25
        eval(['HRTF_diff.spectra{4}(k,:,1)=abs(' names(i,:) '(k,:,1))./rms_l;'])
        eval(['HRTF_diff.spectra{4}(k,:,2)=abs(' names(i,:) '(k,:,2))./rms_r;'])
end
    
sel_n=whos('IPTF_0*')
names=char(sel_n(:,1).name)
IPTF=struct('info',{[1 nfft chnl n_HRTF]},'name',{names}, ...
    'spectra',{[]},'Azi_Ele',{[0,0]})
for i=1:n_HRTF
    eval(['IPTF.spectra{i}=mean(' IPTF.name(i,:) ')'])
end

HRTFc=HRTF
for i=1:n_HRTF
    for k=1:trl
        s_l=c_smooth(abs(HRTF.spectra{i}(k,:,1))./abs(IPTF.spectra{i}(:,:,1)),64);
        s_r=c_smooth(abs(HRTF.spectra{i}(k,:,2))./abs(IPTF.spectra{i}(:,:,2)),64);
        
        HRTFc.spectra{i}(k,:,1)=s_l;
        HRTFc.spectra{i}(k,:,2)=s_r;
    end
end

sel_n=whos('IPTF_0*')
names=char(sel_n(:,1).name)
IPTF=struct('info',{[1 nfft chnl n_HRTF]},'name',{names}, ...
    'spectra',{[]},'Azi_Ele',{[0,0]})
for i=1:n_HRTF
    eval(['IPTF.spectra{i}=mean(' IPTF.name(i,:) ')'])
end

load('E:\Stage\Matlab\Characteristics\Headphone_spectra_1024.mat')
sel_n=whos('HRTF_0*');
names=char(sel_n(:,1).name);
HRTFc_all=HRTF_diff
for i=1:3
    eval(['templ=(abs(' names(i,:) '(:,:,1)));'])
    eval(['tempr=(abs(' names(i,:) '(:,:,2)));'])
    for k=1:126
        
        s_l=c_smooth(abs(templ(k,:))./abs(IPTF.spectra{i}(:,:,1)),64);
        s_r=c_smooth(abs(tempr(k,:))./abs(IPTF.spectra{i}(:,:,2)),64);
        
        HRTFc_all.spectra{i}(k,:,1)=s_l;
        HRTFc_all.spectra{i}(k,:,2)=s_r;
    end
end
sel_n=whos('HRTF_0*');
names=char(sel_n(:,1).name);

HRTFc_all1=HRTF_diff
for i=1:3
    eval(['templ=(abs(' names(i,:) '(:,:,1)));'])
    eval(['tempr=(abs(' names(i,:) '(:,:,2)));'])
    for k=1:126
        
        s_l=c_smooth(abs(templ(k,:))./abs(IPTF.spectra{i}(:,:,1)).*abs(Heaphone_spec_L),64);
        s_r=c_smooth(abs(tempr(k,:))./abs(IPTF.spectra{i}(:,:,2)).*abs(Heaphone_spec_R),64);
        
        HRTFc_all1.spectra{i}(k,:,1)=s_l;
        HRTFc_all1.spectra{i}(k,:,2)=s_r;
    end
end


%%
%Spectra as function of azimuth, IPTF corrected and DTF
%IPTF
subplot(4,1,1)
sel_azi     =HRTFc_all.Azi_Ele(:,2)==0 %set elevation=0!
sel_spect   =HRTFc_all.spectra{3}(sel_azi,:,:)
as=1:Fs/2/nfft*2:Fs/2

contourf(as,HRTFc_all.Azi_Ele(sel_azi,1),20*log10(sel_spect(:,1:512,1)),15)
xlim([2000 12000])
ylim([-30 30])
set(gca,'XScale','log');
set(gca,'YScale','linear');
set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
colorbar
colormap bone;
caxis([-30 30])
xlabel('kHz')
ylabel('Azimuth (deg)')
zlabel('sigma')
title('HPTF corrected spectra as function of azimuth')
%Diff
subplot(4,1,2)
sel_azi_d    =HRTF_diff.Azi_Ele(:,2)==0 %set elevation=0!
sel_spect_d  =c_smooth(HRTF_diff.spectra{3}(sel_azi_d,:,:),64)

contourf(as,HRTF_diff.Azi_Ele(sel_azi_d,1),20*log10(sel_spect_d(:,1:512,1)),15)
xlim([2000 12000])
ylim([-30 30])
set(gca,'XScale','log');
set(gca,'YScale','linear');
set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
colorbar
colormap bone;
caxis([-15 15])
xlabel('kHz')
ylabel('Azimuth (deg)')
zlabel('sigma')
title('DTF spectra as function of azimuth')

%Spectra as function of elevation, IPTF corrected and DTF
%IPTF
subplot(4,1,3)
sel_ele     =HRTFc_all.Azi_Ele(:,1)==0 %set azimuth=0!
sel_spect   =HRTFc_all.spectra{3}(sel_ele,:,:)

contourf(as,HRTFc_all.Azi_Ele(sel_ele,2),20*log10(sel_spect(:,1:512,1)),15)
xlim([2000 12000])
ylim([-30 30])
set(gca,'XScale','log');
set(gca,'YScale','linear');
set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
colorbar
colormap bone;
caxis([-30 30])
xlabel('kHz')
ylabel('Azimuth (deg)')
zlabel('sigma')
title('HPTF corrected spectra as function of elevation')

%DTF
subplot(4,1,4)
sel_ele     =HRTF_diff.Azi_Ele(:,1)==0 %set azimuth=0!
sel_spect   =c_smooth(HRTF_diff.spectra{3}(sel_ele,:,:),64)

contourf(as,HRTF_diff.Azi_Ele(sel_ele,2),20*log10(sel_spect(:,1:512,1)),15)
xlim([2000 12000])
ylim([-30 30])
set(gca,'XScale','log');
set(gca,'YScale','linear');
set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
colorbar
colormap bone;
caxis([-15 15])
xlabel('kHz')
ylabel('Azimuth (deg)')
zlabel('sigma')
title('DTF spectra as function of elevation')
tilefig

%%
  

%
HRTF_diff1=HRTF_diff;

HRTF_trl_avg=(zeros(n_HRTF,nfft,chnl));
sum_l       =0;
sum_r       =0;

sel=zeros(126,1);
for i=1:length(Azi_EleHRTF_0627)
    temp=(Azi_EleHRTF_0527(:,1)==Azi_EleHRTF_0627(i,1)).*(Azi_EleHRTF_0527(:,2)==Azi_EleHRTF_0627(i,2));
    sel=sel+temp;
end
sel_loc=logical(sel);
sel_n=whos('HRTF_0*');
names=char(sel_n(:,1).name);
for i=1:3
    eval(['HRTF_diff1.spectra{i}=' HRTF_diff.name(i,:) '(sel_loc,:,:)'])
end


for i=1:4
    s_l                 =c_smooth(HRTFc.spectra{i}(:,:,1),128).^2;
    HRTF_trl_avg(i,:,1) =sqrt(mean(s_l));
    sum_l               =sum_l+s_l;
    
    s_r                 =c_smooth(HRTFc.spectra{i}(:,:,2),128).^2;
    sum_r               =sum_r+s_r ;   
    HRTF_trl_avg(i,:,2) =sqrt(mean(s_r));
end
HRTF_sup_avg_l=sqrt(sum(sum_l)/n_HRTF/25);
HRTF_sup_avg_r=sqrt(sum(sum_r)/n_HRTF/25);


dBlog_plot(HRTF_trl_avg(:,1:512,1))
dBlog_plot_duo(HRTF_sup_avg_l(1:512),HRTF_sup_avg_r(1:512))


HRTFc1=HRTFc
for i=1:n_HRTF
    bias_l=HRTF_trl_avg(i,:,1)./HRTF_sup_avg_l;
    bias_r=HRTF_trl_avg(i,:,2)./HRTF_sup_avg_r;
%     dBlog_plot(bias_l(1:512),bias_r(1:512))
%     pause
%     close all
    for k=1:trl
        HRTFc1.spectra{i}(k,:,1)=abs(HRTFc.spectra{i}(k,:,1))./bias_l;
        HRTFc1.spectra{i}(k,:,2)=abs(HRTFc.spectra{i}(k,:,2))./bias_r;
    end
end
Spectra_viewer_cell(HRTFc1,64,[-30 30])

HRTFc2=HRTFc1
HRTFc2.spectra=cell(1)
for k=1:trl
    HRTF_temp=zeros(n_HRTF,nfft,chnl);
    for i=1:n_HRTF
        HRTF_temp(i,:,:)=HRTFc1.spectra{i}(k,:,:);
    end
    
    HRTFc2.spectra{1}(k,:,1)=std(20*log10(HRTF_temp(:,:,1)));
    HRTFc2.spectra{1}(k,:,2)=std(20*log10(HRTF_temp(:,:,2)));
end

%%
std_l=c_smooth(mean(HRTFc2.spectra{1}(:,:,1)),128)
std_r=c_smooth(mean(HRTFc2.spectra{1}(:,:,2)),128)
conf_l=c_smooth(std_l+1.9599*std(HRTFc2.spectra{1}(:,:,1)),128)
conf_r=c_smooth(std_r+1.9599*std(HRTFc2.spectra{1}(:,:,2)),128)
as=1:Fs/2/512:Fs/2
semilogx(as,std_l(1:512))
hold on;
semilogx(as,conf_l(1:512),':')
hold off
xlabel('Frequency (kHz)')
ylabel('Magnitude (dB)')
title('Left ear')
xlim([500 14000])
ylim([0 10])
set(gca,'XScale','log');
set(gca,'YScale','linear');
set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);

figure;
semilogx(as,std_r(1:512))
hold on;
semilogx(as,conf_r(1:512),':')
hold off
xlabel('Frequency (kHz)')
ylabel('Magnitude (dB)')
title('Right ear')
xlim([500 14000])
ylim([0 10])
set(gca,'XScale','log');
set(gca,'YScale','linear');
set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);



sel_azi=Azi_EleHRTF_0627(:,2)==0
sel_ele=Azi_EleHRTF_0627(:,1)==0
z_data_azi=c_smooth(HRTFc2.spectra{1}(sel_azi,1:512,1),64)
z_data_ele=c_smooth(HRTFc2.spectra{1}(sel_ele,1:512,1),64)

figure;
contourf(as,Azi_EleHRTF_0627(sel_azi,1),z_data_azi,15)
xlim([2000 14000])
zlim([0 10])
set(gca,'XScale','log');
set(gca,'YScale','linear');
set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
colorbar
colormap bone;
caxis([0 8])
xlabel('Hz')
ylabel('Azimuth (deg)')
zlabel('sigma')
title('Standard deviation as function of azimuth')

figure;
contourf(as,Azi_EleHRTF_0627(sel_ele,2),z_data_ele,15)
xlim([2000 14000])
zlim([0 10])
set(gca,'XScale','log');
set(gca,'YScale','linear');
set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
colorbar
colormap bone;
caxis([0 8])
title('Standard deviation as function of elevation')
xlabel('Hz')
ylabel('Elevation (deg)')
zlabel('sigma')

%%
HRTF_m      =zeros(trl,nfft,chnl);
HRTF_m(:,:,1)=sqrt(sum_l/n_HRTF);
HRTF_m(:,:,2)=sqrt(sum_r/n_HRTF);

HRTF_mean=struct('info',{[trl nfft chnl 1]},'name',{'HRTF_mean'}, ...
    'spectra',{cell(1)},'Azi_Ele',{Azi_EleHRTF_0627(:,:)})
HRTF_mean.spectra{1}=HRTF_m;


smoothing=64
Spectra_viewer_cell(HRTF,smoothing)
Spectra_viewer_cell(HRTF_diff,smoothing,[-25 10])
Spectra_viewer_cell(HRTFc,smoothing)
Spectra_viewer_cell(HRTFc_all1,smoothing)
Spectra_viewer_cell(HRTF_mean,smoothing,[-30 30])
Spectra_viewer_cell(IPTF,smoothing)


hl = squeeze(hrir_l(1,:,:))';               % Normalize data [-1 1]
hr = squeeze(hrir_r(1,:,:))';
plot(hl(:,2))
ft=fft(hl(:,2))'
dBlog_plot(ft(2:100))



