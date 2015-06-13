function LFPcheckpreprocess(data)
% CHECKLFPVSSPIKE(DATA,CFG)
%
% Plot the spike and LFP traces trial by trial.
%
% See also READLFP
%
% 2010 Marc van Wanrooij

% %% LFP
% cfg.filename = fname;
% [data,cfg] = readlfp(cfg);
[~,c] = size(data);

% Remove 50 Hz
FSlfp   = 1000;
Llfp    = length(data(1).lfpfilt);
Tlfp    = (1:Llfp)/FSlfp*1000;

FSspike = 25000;
FSlfp = data(1).samplefrequency;
Lspike  = length(data(1).spiketrace);
Tspike  = (1:Lspike)/FSspike*1000;
indx = round((200:550)*FSlfp/1000);
figure
subplot(222)
lfp = [data.lfpfilt];
lfp = lfp(:);
lvl = std(lfp);
t   = (1:length(lfp))/1000*1000;
for i = 1:c
    LFP         = data(i).lfp;
    LFPfilt     = data(i).lfpfilt;
    LFPclean    = data(i).lfpclean;
    
    subplot(223)
    getpower(LFP,1000,1,'r');
    hold on
    getpower(LFPfilt,1000,1,'k');

    subplot(221)
    h1 =  plot(Tlfp,LFP,'r','LineWidth',1);
    hold on
    h2 = plot(Tlfp,LFPfilt,'k','LineWidth',2);
    xlabel('Time (ms)');
    ylabel('Amplitude (au)');
    legend([h1,h2],{'Recorded','Filtered'});
    horline(3*lvl);
    horline(-3*lvl);
    
    subplot(222)
    plot(t,lfp,'r');
    hold on
    plot(Tlfp+(i-1)*length(LFP),LFPfilt,'k','LineWidth',2);
    xlabel('Time (ms)');
    ylabel('Amplitude (au)');
    horline(3*lvl);
    horline(-3*lvl);
    
    legend([h1,h2],{'Recorded','Filtered'});
    
    subplot(224)
    plot(Tlfp(indx),LFPfilt(indx),'g','LineWidth',2);
    hold on
    xlabel('Time (ms)');
    ylabel('Amplitude (au)');
    plot(Tlfp(indx),LFPclean(indx),'b','LineWidth',2);
    xlabel('Time (ms)');
    ylabel('Amplitude (au)');
    horline(3*lvl);
    horline(-3*lvl);
    drawnow
%     pause(.01)
    clf
end
