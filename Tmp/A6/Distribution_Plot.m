

%% Stimulus Distribution Plot

close all
clear all

fnames = {'JR-RG-2012-04-06-0001';'RG-TH-2012-04-27-0001';'RG-JR-2012-04-26-0001';'RG-PH-2012-04-13-0001';'RG-CK-2012-04-13-0001';'RG-EZ-2012-04-20-0001';'RG-PH-2012-04-23-0001';'RG-CK-2012-04-23-0001';'RG-BK-2012-04-24-0001';'RG-LJ-2012-04-25-0001';'RG-EZ-2012-04-24-0001';'RG-LK-2012-04-26-0001'}; %Short Long
% fnames = {'JR-RG-2012-04-06-0002';'RG-TH-2012-04-13-0001';'RG-JR-2012-04-16-0001';'RG-PH-2012-04-17-0001';'RG-CK-2012-04-17-0001';'RG-EZ-2012-04-19-0001';'RG-PH-2012-04-19-0001';'RG-CK-2012-04-19-0001';'RG-BK-2012-04-25-0001';'RG-LJ-2012-04-24-0001';'RG-EZ-2012-04-26-0001';'RG-LK-2012-04-24-0001'}; % Long Short

for ii= 1

    fname = fnames{ii};
    pa_datadir(fname(1:end-5));
    load(fname); %load fnames(ii) = load('fnames(ii)');

K = pa_supersac(Sac,Stim,2,1);
k = K(1:250,:);
m = K(251:500,:);
% figure
% hist(k,7)
% xlim([-60 60])
% % ylim([0 20])
% figure
% hist(m,23)
% ylim([0 70])
% 
% figure
% x = 1:500;
% L = K(:,24);
% plot(x,L)
% xlabel('Trial')
% ylabel('Stimulus Distribution(degree)')

figure(1)
% subplot(3,4,ii)
rg_plotloc(k);

figure(2)
% subplot(3,4,ii)
rg_plotloc(m);
end