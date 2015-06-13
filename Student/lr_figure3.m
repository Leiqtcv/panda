function lr_figure3(fname)
%% Analysis
% for A,V, AV experiments by Luuk vd Rijt 13-11-2013
% with 4x1 channel (split), right (Tx1 and 2, Rx1) and left (Tx3 and 4, Rx2) recordings

close all;
% clear all;
clc
%% To Do
% Stim
% Oxy-Deoxy
% Left-Right

%% Load preprocessed data
% obtained with PA_NIRS_PREPROCESS
if nargin<1
% d = 'LR-1721';
d = '/Users/marcw/DATA/NIRS/Luuk/LR-1721';
cd(d);
fname = 'LR-1721-2013-11-21-';
end

CHAN = struct([]);
chanlabel = {'OHb Left';'OHb Right';'HHb Left';'HHb Right'};

mx = NaN(3*4,3); % by default, 3 files/blocks, 4 channels
k = 0;
col     = pa_statcolor(4,[],[],[],'def',1);

for fIdx = 1:3
    load([fname '000' num2str(fIdx) '.mat']); nirs = data;
	
	keyboard
    idx(1)		= find(strncmp(nirs.label,'Rx1a - Tx1 O2Hb',15));  % Oxy-hemoglobin channel 1
    idx(2)		= find(strncmp(nirs.label,'Rx1b - Tx2 O2Hb',15));  % Oxy-hemoglobin channel 2
    idx(3)		= find(strncmp(nirs.label,'Rx2a - Tx3 O2Hb',15));  % Oxy-hemoglobin channel 3
    idx(4)		= find(strncmp(nirs.label,'Rx2b - Tx4 O2Hb',15));  % Oxy-hemoglobin channel 4
    
    idx(5)		= find(strncmp(nirs.label,'Rx1a - Tx1 HHb',14));  % Oxy-hemoglobin channel 1
    idx(6)		= find(strncmp(nirs.label,'Rx1b - Tx2 HHb',14));  % Oxy-hemoglobin channel 2
    idx(7)		= find(strncmp(nirs.label,'Rx2a - Tx3 HHb',14));  % Oxy-hemoglobin channel 3
    idx(8)		= find(strncmp(nirs.label,'Rx2b - Tx4 HHb',14));  % Oxy-hemoglobin channel 4
    
    %% Ref vs Sig
    for chanIdx = 1:4
        chan	= nirs.processed;
		indx = idx(1+(chanIdx-1)*2);
        chanRef	= chan(indx,:);
        chanSig	= chan(idx(2+(chanIdx-1)*2),:);
        
        figure(1)
        subplot(221)
        plot(chanRef+fIdx,'k-')
        hold on
        plot(chanSig+fIdx,'r-','Color',col(chanIdx,:))
        axis square
        box off
        
        subplot(222)
        plot(chanRef,chanSig,'k.')
        axis square
        box off
        pa_unityline;

        
        %% Reference channel subtraction
        b		= regstats(chanSig,chanRef,'linear','r');
        chanSig = b.r; % Off to plot files without ref. chan. subtraction if convenient
        
        subplot(223)
%         plot(chanRef,'k-')
        hold on
        plot(chanSig+fIdx,'k-','Color',col(chanIdx,:))
        axis square
        box off
		whos chanSig
        %% Onsets Stimulus 1
        
        %% Stimulus 1
        blockAV			= getblock(nirs,chanSig,'AV');
        CHAN(chanIdx).block(fIdx).AV	= blockAV';
        
        blockA			= getblock(nirs,chanSig,'V'); % due to error V=A
        CHAN(chanIdx).block(fIdx).A	= blockA';
        
        blockV			= getblock(nirs,chanSig,'A'); % due to error V=A
        CHAN(chanIdx).block(fIdx).V	= blockV';
        
        k = k+1;
        mx(k,1) =  size(CHAN(chanIdx).block(fIdx).AV,1);
        mx(k,2) =  size(CHAN(chanIdx).block(fIdx).A,1);
        mx(k,3) =  size(CHAN(chanIdx).block(fIdx).V,1);
        
    end
end

mx = max(mx(:));
%% Check size
tmp = NaN(mx,4); % by default 4 events per stimulus sensmodality per block
for chanIdx = 1:4
    for fIdx = 1:3
        sz = size(CHAN(chanIdx).block(fIdx).AV,1);
        if sz<mx
            disp(['Event duration error: ' num2str(mx-sz) ' samples missing in AV'])
            a = tmp;
            a(1:sz,:) = CHAN(chanIdx).block(fIdx).AV;
            CHAN(chanIdx).block(fIdx).AV = a;
        end
        
        sz = size(CHAN(chanIdx).block(fIdx).A,1);
        if sz<mx
            disp(['Event duration error: ' num2str(mx-sz) ' samples missing in A'])
            a = tmp;
            a(1:sz,:) = CHAN(chanIdx).block(fIdx).A;
            CHAN(chanIdx).block(fIdx).A = a;
        end
        
        sz = size(CHAN(chanIdx).block(fIdx).V,1);
        if sz<mx
            disp(['Event duration error: ' num2str(mx-sz) ' samples missing in V'])
            a = tmp;
            a(1:sz,:) = CHAN(chanIdx).block(fIdx).V;
            CHAN(chanIdx).block(fIdx).V = a;
        end
    end
end

%% Some useful parameters
sensmod     = {'V','A','AV'};
% col = ['r';'b';'g'];
col1     = pa_statcolor(3,[],[],[],'def',1);
col1 = col1([1 3 2],:);
col2     = pa_statcolor(3,[],[],[],'def',2);
col2 = col2([1 3 2],:);
param   = struct([]);
for jj = 1:4
    h = NaN(3,1);
    for ii = 1:3
        block				= [CHAN(jj).block.(char(sensmod(ii)))]'; % Dynamic field names!!
        fd					= nirs.fsdown;
        mu					= nanmean(block);
        sd					= nanstd(block);
        t					= (1:length(mu))/fd;
        n					= size(block,1);
        param(ii).chan(jj).mu		= mu;
        param(ii).chan(jj).sd		= sd;
        param(ii).chan(jj).se		= sd./sqrt(n);
        param(ii).chan(jj).time		= t;
        [param(ii).chan(jj).max,indx]	= max(mu);
        param(ii).chan(jj).sdatmax  = sd(indx);
        param(ii).chan(jj).snr      = max(mu)/sd(indx);
        param(ii).chan(jj).maxt		= indx/fd-10; % remove first 10 ms = 100 samples before stimulus onset
        param(ii).chan(jj).sensmodality	= sensmod{ii};
        figure(666)
		sb = mod(jj,2)+1;
		if sb==1
			col = col1;
		else
			col = col2;
			end
        subplot(1,2,sb)
        hold on
		mn = ((jj>2)-0.5)*0.3;
        h(ii) = pa_errorpatch(param(ii).chan(jj).time+(ii-1)*45,param(ii).chan(jj).mu-mn,param(ii).chan(jj).se,col(ii,:));
		
		if mn<0
		t = (ii-1)*45;
		x = [t+10 t+10 t+30 t+30];
		y = [-mn 0.5 0.5 -mn];
		h = patch(x,y,col(ii,:));
		alpha(h,0.2);
		else
		t = (ii-1)*45;
		x = [t+10 t+10 t+30 t+30];
		y = [-0.5 -mn -mn -0.5];
		h = patch(x,y,col(ii,:));
		alpha(h,0.2);
		end
		xlim([-10 140]);

		pa_horline(mn,'k-');
    end
    ylim([-0.5 0.5]);
    box off
    axis square
    set(gca,'TickDir','out','XTick',[10 30 55 75 100 120],'XTickLabel',[0 20 0 20 0 20],...
		'YTick',[-0.45 -0.35 -0.25 -0.15 0.15 0.25 0.35 0.45],'YTickLabel',...
		[-0.3 -0.2 -0.1 0 0 0.1 0.2 0.3]);
%     pa_verline(10,'k:');
%     pa_verline(30,'k:');
%     pa_horline(0,'k:');
    xlabel('Time (s)');
    ylabel('Relative O_2Hb HHb concentration (\muM)'); % What is the correct label/unit
%     legend(h,sensmod,'Location','NW');
    title(chanlabel{jj});
    % figure;
    % plot(t,block','k-','Color',[.7 .7 .7])
end

%% Save
save([fname 'param'],'param');

%%
pa_datadir;
print('-depsc','-painters',mfilename);

function MU = getblock(nirs,chanSig,sensmod)
fs			= nirs.fsample;
fd			= nirs.fsdown;
onSample	= ceil([nirs.event.sample]*fd/fs); % onset and offset of stimulus
offSample	= onSample(2:2:end); % offset
onSample	= onSample(1:2:end); % onset
stim		= {nirs.event.stim}; % stimulus sensmodality - CHECK HARDWARE WHETHER THIS IS CORRECT


selOn		= strcmp(stim,sensmod);
selOff		= selOn(2:2:end);
selOn		= selOn(1:2:end);
Aon			= onSample(selOn);
Aoff		= offSample(selOff);
mx			= min((Aoff - Aon)+1)+150;
nStim		= numel(Aon);
MU = NaN(nStim,mx);
for stmIdx = 1:nStim
    idx				= Aon(stmIdx)-100:Aoff(stmIdx)+50; % extra 100 samples before and after
    idx				= idx(1:mx);
    MU(stmIdx,:)	= chanSig(idx);
end
MU = bsxfun(@minus,MU,mean(MU(:,1:100),2)); % remove the 100th sample, to set y-origin to stimulus onset

