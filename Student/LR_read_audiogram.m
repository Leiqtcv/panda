%% Read audiogram from a directory

% First put them all in one structure
% Then seperate left and right thresholds

% 18-11-2013 by Luuk van de Rijt

%% Clean
close all;
clear all;
clc;

%% All files stored in audiogram_read
M_total = struct([]); % Pool everything in a structure

fnames = {'Audiogram_1701';'Audiogram_1702';'Audiogram_1704';...
    'Audiogram_1705';'Audiogram_1706';'Audiogram_1707';...
    'Audiogram_1709';'Audiogram_1710';...
    'Audiogram_1712';'Audiogram_1713';'Audiogram_1714';...
    'Audiogram_1715';'Audiogram_1716';'Audiogram_1717';...
    'Audiogram_1718';'Audiogram_1719';'Audiogram_1720'}; % all subjects files
nfiles      = numel(fnames); % How many files?
str = char(['Number of audiograms: ' num2str(nfiles)],'Is this correct?'); % Check for number of files
disp (str);
for ii = 1:length (fnames); 
    struct.(fnames{ii}) = ii;
    fname = fnames{ii}; 
    cd ('Z:\Student\Luuk van de Rijt\Data\Raw data\Audiograms')
    audio_data_LR = xlsread (fname);
    K = audio_data_LR(5:7,:);
    M_total(ii).data = K';
    M_total(ii).names = fname;
end

%% Take Left and Right seperately

a = [M_total.data];
L = a(:,2:3:end);
R = a(:,3:3:end);

Freq = audio_data_LR(5,:);

close all
figure(1)
subplot(221)
semilogx(Freq,L,'r-','MarkerFaceColor','w')
axis square
set(gca,'XScale','log','XTick',[1000 2000 4000 8000],'XTickLabel',[1 2 4 8]);
axis([400 12000 -10 70]);
xlabel('Frequency (kHz)','FontSize',10); ylabel('Thresholds - left (dB)','FontSize',10);
box on; grid on; hold on

subplot(222)
semilogx(Freq,R,'r-','MarkerFaceColor','w')
axis square
set(gca,'XScale','log','XTick',[1000 2000 4000 8000],'XTickLabel',[1 2 4 8]);
axis([400 12000 -10 70]);
xlabel('Frequency (kHz)','FontSize',10); ylabel('Thresholds - right (dB)','FontSize',10);
box on; grid on; hold on

subplot(223)
plot(L,R,'.')
xlabel('Thresholds - left (dB)','FontSize',10); ylabel('Thresholds - right (dB)','FontSize',10);
axis square
pa_unityline


%% Mean overall frequencies left and right seperately
% L_trans = L';
% R_trans = R';

L_mean = mean (L,2); % take mean over all frequencies
R_mean = mean (R,2); % take mean over all frequencies

subplot (221)
plot (Freq,L_mean,'r', 'LineWidth',3);

subplot (222)
plot (Freq,R_mean,'r', 'LineWidth',3);

%% Mean over 1 to 4 kHz left and right seperatley

L_speak = L(2:5,:); % Gives frequencies 1, 2, 3, and 4 kHz of the left
R_speak = R(2:5,:); % Gives frequencies 1, 2, 3, and 4 kHz of the right

L_speak_mean = mean (L_speak);
R_speak_mean = mean (R_speak);
Freq_speak = audio_data_LR(5,2:5);

subplot(224)
plot (L_speak_mean,R_speak_mean,'.')
axis square
pa_unityline
xlabel('Mean of frequencies of the left (dB)');
ylabel('Mean of frequencies of the right (dB)');
[h,p] = ttest (L_speak_mean,R_speak_mean);
str1 = char(['p-value ' num2str(p)]);
disp (str1);
text(20,2, str1);
