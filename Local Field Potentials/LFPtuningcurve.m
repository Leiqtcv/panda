function [Tuning,uF] = LFPtuningcurve(data)
% LFPTUNINGCURVE(DATA)
%
% 2010 Marc van Wanrooij

%% Initialization
Fs          = data(1).samplefrequency;
% Tonset      = 300;
% Toffset     = 450;
indx    = round((100:650)/1000*Fs);

[~,c]   = size(data);
LFP     = NaN(c,length(data(1).lfp));
for i   = 1:c
    LFP(i,:)    = data(i).lfp;
    LFP(i,:)   = lowpassnoise(LFP(i,:),40,1000,100);
end

% F = NaN(size(data));
% L = NaN(size(data));
% for i       = 1:length(data)
%     F(i)    = data(i).stimulus.values(1);
%     L(i)    = data(i).stimulus.values(2);
% end
%% Get Stimulus Parameters Frequency and Sound Level
Freq    = NaN(size(data));
Level   = NaN(size(data));
for i           = 1:length(data)
    Freq(i)     = data(i).stimulus.values(1);
    Level(i)    = data(i).stimulus.values(2);
end
F        = Freq';
L       = Level';
L = ones(size(L));

uF      = unique(F);
nF      = numel(uF);
uL      = unique(L);
nL      = numel(uL);

figure;
% for j = 1:nL
%     sel     = ismember(L,uL(j));
%     LFP2     = LFP(~sel,:);
%     F2       = F(~sel);
    
    % Preallocation of average Power
    P       = NaN(nF,length(LFP));
    for i       = 1:nF
        sel     = F == uF(i,1);
        p       = nanmean(LFP(sel,:));
        P(i,:) = p;
    end
    
%     subplot(2,2,j)
    M = P(:,indx);
    t = indx/Fs*1000-300;
    nT = numel(t);
    
    pcolor(t,1:nF,M);
    hold on
    %     set(gca,'Yscale','log');
    set(gca,'Ytick',1:nF,'Yticklabel',num2str(uF/1000,2));
    title('Single-Tone Stimulus STRF');
%     mu = mean(M);
%     mu = mu-min(mu);
%     mu = mu/max(mu);
%     mu = mu*nF/2+1;
%     plot(t,mu,'w-','LineWidth',2);
    
%     mu = mean(M,2);
%     Tuning = mu;
%     
%     mu = mu-min(mu);
%     mu = mu/max(mu);
%     mu = mu*nT/3+1;
%     %     mu = smooth(mu);
%     plot(mu-100,1:nF,'k-','LineWidth',2);
    
    shading flat
    xlabel('Time re Stimulus Onset (ms)');
    ylabel('Tone Frequency (kHz)');
%     str = ['Average LFP (1-40 Hz, au), Level = ' num2str(uL(j)) 'dB'];
%     title(str);
    axis square;
% end
return
figure
for i = 1:4
    subplot(221)
    semilogx(uF,Tuning(i,:),'o-','Color',[1/i 1/i 1/i],'MarkerFaceColor',[1/i 1/i 1/i]);
    hold on
end
axis square
xlim([min(uF) max(uF)]);
set(gca,'XTick',uF(1:2:end),'XTickLabel',uF(1:2:end)/1000);

subplot(222)
contourf(uF,uL,Tuning)
axis square;
xlabel('Frequency (kHz)');
ylabel('Sound Level');
set(gca,'XScale','log');
axis square
colorbar
xlim([min(uF) max(uF)]);
set(gca,'XTick',uF(1:2:end),'XTickLabel',uF(1:2:end)/1000);

%% Let's do some interpolation, to make things smoother
FavgI			= uF;
Interpolfreq	= zeros(6*12+1, 1); % N octaves at 1/12th intervals
for k = 1:length(Interpolfreq)
    Interpolfreq(k) = FavgI(1)*2^((k-1)/12);
end

for i = 1:4
    C(i,:) = spline(uF, Tuning(i,:), Interpolfreq);
    cl = [i/4 i/4 i/4];
    subplot(223)
    semilogx(Interpolfreq,C(i,:),'Color',cl,'MarkerFaceColor',cl,'LineWidth',2);
    hold on
end
set(gca,'XTick',uF(1:2:end),'XTickLabel',uF(1:2:end)/1000);
xlim([min(uF) max(uF)]);
xlabel('Frequency (kHz)');
ylabel('Firing Rate (Hz)');

subplot(224)
contourf(Interpolfreq,10:20:70,C,30);
axis square
colorbar
xlabel('Frequency (kHz)');
ylabel('Sound Level');
set(gca,'XScale','log');
set(gca,'XTick',uF(1:2:end),'XTickLabel',uF(1:2:end)/1000);
xlim([min(uF) max(uF)]);
shading flat
