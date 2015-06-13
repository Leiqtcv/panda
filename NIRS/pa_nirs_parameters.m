function pa_nirs_parameters(fnames)
%% Analysis
% for A,V, AV experiments by Luuk vd Rijt 13-11-2013
% with 4x1 channel (split), right (Tx1 and 2, Rx1) and left (Tx3 and 4, Rx2) recordings

%% To Do
% Stim
% Oxy-Deoxy
% Left-Right

if numel(fnames)==1
	fnames = fnames{1};
	CHAN = struct([]);
	chanlabel = {'OHb Left';'OHb Right';'HHb Left';'HHb Right'};
	
	mx = NaN(3*4,3); % by default, 3 files/blocks, 4 channels
	k = 0;
	nirs = load(fnames); 
	
	idx(1)		= find(strncmp(nirs.label,'Rx1a - Tx1 O2Hb',15));  % Oxy-hemoglobin channel 1
	idx(2)		= find(strncmp(nirs.label,'Rx1b - Tx2 O2Hb',15));  % Oxy-hemoglobin channel 2
	
	idx(3)		= find(strncmp(nirs.label,'Rx1a - Tx1 HHb',14));  % Oxy-hemoglobin channel 1
	idx(4)		= find(strncmp(nirs.label,'Rx1b - Tx2 HHb',14));  % Oxy-hemoglobin channel 2
	
	%% Ref vs Sig
	for chanIdx = 1:2
		chan	= nirs.dC;
		chanRef	= chan(idx(1+(chanIdx-1)*2),:);
		chanSig	= chan(idx(2+(chanIdx-1)*2),:);
		
		figure(1)
		subplot(121)
		plot(chanRef,'k-')
		hold on
		plot(chanSig,'r-')
		axis square
		box off
		
		subplot(122)
		plot(chanRef,chanSig,'k.')
		axis square
		box off
		pa_unityline;
		
		
		%% Reference channel subtraction
		b		= regstats(chanSig,chanRef,'linear','r');
		chanSig = b.r;
		
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
	
	
	
elseif numel(fnames)==3
	
	
	
	CHAN = struct([]);
	chanlabel = {'OHb Left';'OHb Right';'HHb Left';'HHb Right'};
	
	mx = NaN(3*4,3); % by default, 3 files/blocks, 4 channels
	k = 0;
	for fIdx = 1:3
		load([fname '000' num2str(fIdx) '.mat']); nirs = data;
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
			chanRef	= chan(idx(1+(chanIdx-1)*2),:);
			chanSig	= chan(idx(2+(chanIdx-1)*2),:);
			
			figure(1)
			subplot(121)
			plot(chanRef,'k-')
			hold on
			plot(chanSig,'r-')
			axis square
			box off
			
			subplot(122)
			plot(chanRef,chanSig,'k.')
			axis square
			box off
			pa_unityline;
			
			
			%% Reference channel subtraction
			b		= regstats(chanSig,chanRef,'linear','r');
			chanSig = b.r;
			
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
	tmp = NaN(mx,4); % by default 4 events per stimulus modality per block
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
	mod     = {'V','AV','A'};
	% col = ['r';'b';'g'];
	col     = pa_statcolor(3,[],[],[],'def',1);
	param   = struct([]);
	for jj = 1:4
		h = NaN(3,1);
		for ii = 1:3
			block				= [CHAN(jj).block.(char(mod(ii)))]'; % Dynamic field names!!
			fd					= nirs.fsdown;
			mu					= nanmean(block);
			sd					= nanstd(block);
			t					= (1:length(mu))/fd;
			n					= size(block,1);
			param(ii).chan(jj).mu		= mu;
			param(ii).chan(jj).sd		= sd;
			param(ii).chan(jj).se		= sd./sqrt(n);
			param(ii).chan(jj).time		= t;
			[param(ii).chan(jj).max,param(ii).chan(jj).maxt]	= max(mu);
			param(ii).chan(jj).maxt		= param(ii).chan(jj).maxt/fd-10; % remove first 10 ms = 100 samples before stimulus onset
			param(ii).chan(jj).modality	= mod{ii};
			
			figure(666)
			subplot(2,2,jj)
			hold on
			h(ii) = pa_errorpatch(param(ii).chan(jj).time,param(ii).chan(jj).mu,param(ii).chan(jj).se,col(ii,:));
		end
		xlim([min(t) max(t)]);
		ylim([-0.2 0.4]);
		box off
		axis square
		set(gca,'TickDir','out');
		pa_verline(10,'k:');
		pa_verline(30,'k:');
		pa_horline(0,'k:');
		xlabel('Time (s)');
		ylabel('OHb'); % What is the correct label/unit
		legend(h,mod,'Location','NW');
		title(chanlabel{jj});
		% figure;
		% plot(t,block','k-','Color',[.7 .7 .7])
	end
	
	%% Save
	save([fname 'param'],'param');
	
	%%
end

function MU = getblock(nirs,chanSig,mod)
fs			= nirs.fsample;
fd			= nirs.fsdown;
onSample	= ceil([nirs.event.sample]*fd/fs); % onset and offset of stimulus
offSample	= onSample(2:2:end); % offset
onSample	= onSample(1:2:end); % onset
stim		= {nirs.event.stim}; % stimulus modality - CHECK HARDWARE WHETHER THIS IS CORRECT


selOn		= strcmp(stim,mod);
selOff		= selOn(2:2:end);
selOn		= selOn(1:2:end);
Aon			= onSample(selOn);
Aoff		= offSample(selOff);
mx			= min((Aoff - Aon)+1)+200;
nStim		= numel(Aon);
MU = NaN(nStim,mx);
for stmIdx = 1:nStim
	idx				= Aon(stmIdx)-100:Aoff(stmIdx)+100; % extra 100 samples before and after
	idx				= idx(1:mx);
	MU(stmIdx,:)	= chanSig(idx);
end
MU = bsxfun(@minus,MU,MU(:,100)); % remove the 100th sample, to set y-origin to stimulus onset

