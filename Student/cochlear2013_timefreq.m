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
	d = 'E:\DATA\Studenten\Luuk\Raw data\LR-1721';
	% d = 'C:\DATA\Studenten\Luuk\Raw data\LR-1721';
	cd(d);
	fname = 'LR-1721-2013-11-21-';
end

CHAN = struct([]);
chanlabel = {'OHb Left';'OHb Right';'HHb Left';'HHb Right'};

mx = NaN(3*4,3); % by default, 3 files/blocks, 4 channels
k = 0;
col     = pa_statcolor(4,[],[],[],'def',1);
col = pa_statcolor(64,[],[],[],'def',8);

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
		chan	= nirs.trial;
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
		x = chanSig;
% 		x = x(10000:end);
		x = detrend(x);
		Fs = nirs.fsample;
		
		
		[M,Freq,t] = gettimefreq(x,Fs);
		t = t/1000;
		figure(2)
		subplot(221)
		plot(x)
		xlim([1 length(x)]);
		colorbar
		subplot(223)
		
		N = M;
		S = mean(M,2);
		N = bsxfun(@minus,M,S);
		imagesc(t,Freq,N)
		set(gca,'YDir','normal');
		colormap(col);
		caxis([-40 20])
		colorbar;
		
		subplot(224)
		plot(sum(M,2),Freq);
		
		%% Stimulus 1
		whos chanSig N
		
		blockAV			= getblock(nirs,N,t,'AV');
		
		%%
		figure(3)
		tAV = 1:size(blockAV,2);
		tAV = tAV/10;
		imagesc(tAV,Freq,blockAV)
		set(gca,'YDir','normal');
		colormap(col);
		colorbar;
		
		%%
		keyboard
		
		return
		
		
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
print('-depsc','-painter',mfilename);

function MU = getblock(nirs,chanSig,t,sensmod)
fs			= nirs.fsample;
fd			= nirs.fsdown;
onSample	= ceil([nirs.event.sample]*25/fs); % onset and offset of stimulus
offSample	= onSample(2:2:end); % offset
onSample	= onSample(1:2:end); % onset
stim		= {nirs.event.stim}; % stimulus sensmodality - CHECK HARDWARE WHETHER THIS IS CORRECT


selOn		= strcmp(stim,sensmod);
selOff		= selOn(2:2:end);
selOn		= selOn(1:2:end);
Aon			= onSample(selOn);
Aoff		= offSample(selOff);
nStim		= numel(Aon);
MU = 0;

for stmIdx = 1:nStim

	sel = t>(Aon(stmIdx)/fs-2.5) & t<(Aoff(stmIdx)/fs+2.5);
% 	idx				= Aon(stmIdx)-100:Aoff(stmIdx)+50; % extra 100 samples before and after
	sum(sel)
	
	tmp = chanSig(:,sel);
	tmp = tmp(:,1:120);
	MU				= tmp+MU;
end
MU = MU/nStim;
% MU = bsxfun(@minus,MU,mean(MU(:,1:100),2)); % remove the 100th sample, to set y-origin to stimulus onset



function [M,Freq,t] = gettimefreq(x,Fs)
% [M,F,T] = GETTIMEFREQ(X,FS)
%
% Get time-frequency representation of signal X sampled at FS Hz.
%
% 2009 Marc van Wanrooij

%% Default
x       = x(:);
fmax	= 100;
nfft    = 2^14;
wnd		= 2^7; % 256
wnd		= round(Fs*wnd/1000); % samples
n		= length(x);
step	= 10;
t		= (1:step:(n-wnd));
nt		= length(t);
Freq	= ((1:(nfft/2))-1)/nfft*Fs;
sel		= Freq<fmax;
Freq	= Freq(sel);
nFbin	= sum(sel);
nTbin	= nt;
M		= zeros(nFbin,nTbin);
w		= hanning(wnd+1);

%% Get Power
for i		= 1:nt
	indx	= t(i):t(i)+wnd;
	sig		= x(indx);
	sig		= w.*sig;
	[f,mx]	= getpower(sig,Fs,nfft);
	sel		= f<fmax;
	M(:,i)	= mx(sel);
end
t			= t/Fs+(wnd/2)/Fs;
t           = round(t*1000); % ms

function [f,mx]=getpower(x,Fs,nfft)
% [F,MX] = GETPOWER(X,FS,DISP)
%
% Get power spectrum MX of signal X, sampled at FS Hz.
% DISP - plot power spectrum
%


% Sampling frequency
if nargin<2
	Fs = 50000;
end
if nargin<3
	% Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
	nfft			= 2^(nextpow2(length(x)));
end

% Time vector of 1 second
% Take fft, padding with zeros so that length(fftx) is equal to nfft
fftx			= fft(x,nfft);
% Calculate the numberof unique points
NumUniquePts	= ceil((nfft+1)/2);
% FFT is symmetric, throw away second half
fftx			= fftx(1:NumUniquePts);
% Take the magnitude of fft of x and scale the fft so that it is not a function of
% the length of x
mx				= abs(fftx)/length(x);
% Take the square of the magnitude of fft of x.
mx				= mx.^2;

% Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.
% The DC component and Nyquist component, if it exists, are unique and should not
% be mulitplied by 2.
if rem(nfft, 2) % odd nfft excludes Nyquist point
	mx(2:end)	= mx(2:end)*2;
else
	mx(2:end -1) = mx(2:end -1)*2;
end
% This is an evenly spaced frequency vector with NumUniquePts points.
f		= (0:NumUniquePts-1)*Fs/nfft;


mx		= 20*log10(mx);
% sel		= isinf(mx);
% mx(sel) = min(mx(~sel));