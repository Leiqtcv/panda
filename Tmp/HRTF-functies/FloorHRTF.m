% HRTF uitrekenen

% clear all
% close all
Fs=48828.125;

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

%this creates the minimum phase spectrum of the IPTF
% 
 [trl smpl]=size(hrtf(:,:,1));
 IPTF_l=sqrt(mean(abs(IPTF(:,:,1)).^2));
 IPTF_r=sqrt(mean(abs(IPTF(:,:,2)).^2));

% smoothen IPTF
 IPTF_s_l=c_smooth(1./IPTF_l, 64, 1);
 IPTF_s_r=c_smooth(1./IPTF_r, 64, 1);

% smoothen HRTF
c_ft_L=c_smooth((hrtf(:,:,1)),64);
c_ft_R=c_smooth((hrtf(:,:,2)),64);

% for i=[7 20 33 46 59 72 85 98 111 124 137 150 163]
%     plot(c_ft_L(i,:))
%     pause
% end


% 
% for i=1:trl
%     
%     dBlog_plot_duo(hrtf(i,1:512,1),c_ft_L(i,1:512))
%      %pause
%     hold on
% end

%Echte HRTF\
 ft_L=zeros(trl,smpl);
 ft_R=zeros(trl,smpl);
 
 for i=1:trl
     ft_L(i,:)=(c_ft_L(i,:)).*IPTF_s_l;
     ft_R(i,:)=(c_ft_R(i,:)).*IPTF_s_r;
 end

% pause
% 
% 
% % reshapen: 13 elevaties, 13 azimuth, 1024 samples
% % ft_L=reshape(c_ft_L,13,13,1024);
% % ft_R=reshape(c_ft_R,13,13,1024);
% 
% 
% close all
% % %contourplot
n=length(ft_L(:,:,1))/2-1;
az          =(-45:5:45)';
el          =(-45:5:45)';
Snd_Azi_Ele =[az el];
spectrum=ft_L(:,[2:n+1],1); %don't take freq=0 value[7 20 33 46 59 72 85 98 111 124 137 150 163]
log_spect=20*log10(abs(spectrum));
as=[1:1:n]*Fs/n/2;
contourf(as,Snd_Azi_Ele(:,2),log_spect(:,1:511,1),30)
hold on
xlim([2000 12000])
ylim([-30 30])
set(gca,'XScale','log');
set(gca,'YScale','linear');
set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
colormap bone;
caxis([-30 30])
colorbar
xlabel('kHz')
ylabel('Elevation (deg)')
zlabel('sigma')
title('JO: spectra as function of elevation, azimuth=0')
pause
% close all
% % 
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

for i=1:trl
    dBlog_plot_duo(ft_L(i,1:512),ft_R(i,1:512))
    hold on
end
% % pause
% % close all
% 
% 
ft_L_m=zeros(169,smpl);
 ft_R_m=zeros(169,smpl);
 
 for i=1:169
     for j=1:1024
     ft_L_m(i,j)=(c_ft_L(i,j))/c_ft_L(85,j);
     ft_R_m(i,j)=(c_ft_R(i,j))/c_ft_R(85,j);
     end
     end
% 
% 
% % HRTF's linkeroor in een plot, alle elevaties per azimuth
% 1:13 14:26 27:39 40:52 53:65 66:78 79:91 92:104 105:117 118:130 131:143
% 144:156 157:169
 k=0;
 y=0
 for k=6%0:2:12
    x=k+[1 14 27 40 53 66 79 92 105 118 131 144 157];
     
     i=0
for j=x
    i=i+1;
    y=y+1
    figure(1)
    %subplot(3,3,y)
n=length(ft_L_m(j,:,1))/2-1;
spectrum=ft_L_m(j,[2:n+1],1); %don't take freq=0 value
log_spect=20*log10(abs(spectrum));
as=[1:1:n]*Fs/n/2;
semilogx(as,log_spect,'color',[i*0.05 0 0],'LineWidth',0.5);
hold on


set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
set(gca,'FontName','Arial','FontSize',8,'LineWidth',0.5);
xaxis(1000,14000)
yaxis(-30,30)
title(['HRTF Left ear with Azimuth:' num2str(0)],'fontsize',8,'fontweight','bold')
xlabel('frequency (Hz)','fontsize',8,'fontweight','bold')
ylabel('magnitude [dB]','fontsize',8,'fontweight','bold')
pause
end
 end
% % 
% % % HRTF's rechteroor in een plot, alle elevaties per azimuth
k=0;
y=0;
i=0;
for k=6%0:2:12
    x=k+[1 14 27 40 53 66 79 92 105 118 131 144 157];
    i=0;
    
for j=x
    y=y+1;
    i=i+1;
   figure(2)
    %subplot(3,3,y)
n=length(ft_R_m(j,:,1))/2-1;
spectrum=ft_R_m(j,[2:n+1],1); %don't take freq=0 value
log_spect=20*log10(abs(spectrum));
as=[1:1:n]*Fs/n/2;
semilogx(as,log_spect,'color',[i*0.05 0 0],'LineWidth',0.5);
hold on

set(gca,'Xtick',[1 2 3 4 6 8 10 14]*1000,'XtickLabel',[1 2 3 4 6 8 10 14]);
set(gca,'FontName','Arial','FontSize',8,'LineWidth',0.5);
xaxis(1000,14000)
yaxis(-30,30)
title(['HRTF Right ear with Azimuth:' num2str(0)],'fontsize',8,'fontweight','bold')
xlabel('frequency (Hz)','fontsize',8,'fontweight','bold')
ylabel('magnitude [dB]','fontsize',8,'fontweight','bold')
pause
end
end
% pause
% 
% 
% %Naar minimum phase
% % Voor alle trials (1)
% mag_sfe_l=zeros(size(ft_L_m));
% mag_sfe_r=zeros(size(ft_R_m));
% 
% for i=1:trl
%     mag_sfe_l(i,:)=abs(ft_L_m(i,:));
%     mag_sfe_r(i,:)=abs(ft_R_m(i,:));
% end
% 
% mag_spec=zeros(trl,smpl,2);
% mag_spec(:,:,1)=mag_sfe_l;
% mag_spec(:,:,2)=mag_sfe_r;
% 
% [filt_imp,filt_spec]=mag_spec2min_phase(mag_spec,1024);
% uisave('filt_imp','filt_impJO')

% Alleen elevatie (2)


mag_sfe_l_2=zeros(size(ft_L_m(1:13,:)));
mag_sfe_r_2=zeros(size(ft_R_m(1:13,:)));

for i=1:13
    mag_sfe_l_2(i,:)=abs(ft_L_m(78+i,:));
    mag_sfe_r_2(i,:)=abs(ft_R_m(78+i,:));
end
 mag_sfe_l_2=zeros(size(ft_L_m(1:13,:)));
mag_sfe_r_2=zeros(size(ft_R_m(1:13,:)));
k=0;
for i=1:13
    k=k+1;
    mag_sfe_l_2(k,:)=abs(ft_L_m(i,:));
    mag_sfe_r_2(k,:)=abs(ft_R_m(i,:));
end

mag_spec_2=zeros(13,smpl,2);
mag_spec_2(:,:,1)=mag_sfe_l_2;
mag_spec_2(:,:,2)=mag_sfe_r_2;

[filt_imp_2,filt_spec_2]=mag_spec2min_phase(mag_spec_2,978);
uisave('filt_imp_2','filt_imp_2FB')

% Alleen azimuthfilter
mag_sfe_l_2=zeros(size(ft_L_m(1:13,:)));
mag_sfe_r_2=zeros(size(ft_R_m(1:13,:)));
k=0;
l=7;
for i=1:13
    k=k+1;
  
    mag_sfe_l_2(k,:)=abs(ft_L_m(l,:));
    mag_sfe_r_2(k,:)=abs(ft_R_m(l,:));
    l=l+13
end

mag_spec_2=zeros(13,smpl,2);
mag_spec_2(:,:,1)=mag_sfe_l_2;
mag_spec_2(:,:,2)=mag_sfe_r_2;

[filt_level,filt_spec_2]=mag_spec2min_phase(mag_spec_2,978);
uisave('filt_level','filt_levelFB')

