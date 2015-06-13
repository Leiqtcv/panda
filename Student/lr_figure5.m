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
	d = 'C:\DATA\Studenten\Luuk\Raw data\LR-1721';
	d = '/Users/marcw/DATA/NIRS/Luuk/LR-1721';
	cd(d);
	fname = 'LR-1721-2013-11-21-';
end

CHAN = struct([]);
chanlabel = {'OHb Left';'OHb Right';'HHb Left';'HHb Right'};

mx = NaN(3*4,3); % by default, 3 files/blocks, 4 channels
k = 0;
col     = pa_statcolor(4,[],[],[],'def',1);
X = [];
Y =[];
col2     = pa_statcolor(3,[],[],[],'def',1);
col2 = col2([3 2 1],:);
wavdir = 'E:\MATLAB\PANDA\NIRS\Story (audio only)\';
chan = 1;
for fIdx = 1:3
	load([fname '000' num2str(fIdx) '.mat']);
	nirs = data;
	
	% 	keyboard
	%%
	% 	[hemo, X] = pa_nirs_hdr(nirs);
	
	fs		= nirs.fsample;
	fd		= nirs.fsdown;
	R		= nirs.processed(2,:);
	on		= ceil([nirs.event.sample]*fd/fs);
	off		= on(2:2:end);
	on		= on(1:2:end);
	stim	= {nirs.event.stim};
	ustim	= unique(stim);
	nstim	= numel(ustim);
	
	n = numel(R);
	HDR = NaN(3,n);
	clc
	
	for sIdx = 1:nstim
		sel		= strcmp(ustim(sIdx),stim(1:2:end)) | strcmp('AV',stim(1:2:end));
		% 		sel		= strcmp(ustim(sIdx),stim(1:2:end));
		son = stim(1:2:end);
		son(sel)
		ons		= on(sel);
		offs	= off(sel);
		N		= length(R);
		bl       = zeros(1, N);
		
		str = num2str(find(sel)','%03d');
		for ii	= 1:length(ons)
			bl(ons(ii):offs(ii)) = 1;
			
			% 			wavIdx = ii;
			% 			fname = [wavdir str(wavIdx,:) '.wav']
			% 			fname = pa_fcheckext(fname,'wav');
			% 			[snd,fs] = wavread(fname);
			%
			% 			n = length(snd);
			% 			t = (0:(n-1))/fs;
			% 			X = hilbert(snd(:,chan));
			% 			env = 1.7*smooth(abs(X),1000);
			%
			%
			% 			fd		= 10;
			% 			R		= fs/fd;
			% 			env		= decimate(env,R);
			% 			audhdr	= pa_nirs_hdrfunction(1,env);
			% 			indx	= ons(ii):offs(ii);
			% % 			whos audhdr indx
			% 			indx = indx(1:length(audhdr));
			% 			bl(indx) = audhdr;
		end
		hemo	= pa_nirs_hdrfunction(1,bl);
		
		
		HDR(sIdx,:) = hemo;
	end
	
	figure(2)
	clf
	t = 1:length(HDR);
	t = t/fd/60;
	for ii = 1:sIdx
		plot(t,HDR(ii,:)+ii*1.2,'-','Color',col2(ii,:),'LineWidth',2)
		hold on
	end
	legend(ustim);
	box off
	axis square
	set(gca,'TickDir','out','YTick',[]);
	xlabel('Time (min)');
	xlim([0 max(t)]);
	ylabel('X(t) = u(t) \otimes h(\tau) ')
	% 	if sIdx == nstim
	% 		pa_datadir;
	% 		print('-depsc','-painter',[mfilename 'hdr']);
	% 	end
	HDR = HDR';
	%%
	idx(1)		= find(strncmp(nirs.label,'Rx1a - Tx1 O2Hb',15));  % Oxy-hemoglobin channel 1
	idx(2)		= find(strncmp(nirs.label,'Rx1b - Tx2 O2Hb',15));  % Oxy-hemoglobin channel 2
	idx(3)		= find(strncmp(nirs.label,'Rx2a - Tx3 O2Hb',15));  % Oxy-hemoglobin channel 3
	idx(4)		= find(strncmp(nirs.label,'Rx2b - Tx4 O2Hb',15));  % Oxy-hemoglobin channel 4
	
	idx(5)		= find(strncmp(nirs.label,'Rx1a - Tx1 HHb',14));  % Oxy-hemoglobin channel 1
	idx(6)		= find(strncmp(nirs.label,'Rx1b - Tx2 HHb',14));  % Oxy-hemoglobin channel 2
	idx(7)		= find(strncmp(nirs.label,'Rx2a - Tx3 HHb',14));  % Oxy-hemoglobin channel 3
	idx(8)		= find(strncmp(nirs.label,'Rx2b - Tx4 HHb',14));  % Oxy-hemoglobin channel 4
	
	%% Ref vs Sig
	x = NaN(4,n,3);
	y = NaN(4,n);
	
	
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
		% 		chanSig = b.r; % Off to plot files without ref. chan. subtraction if convenient
		
		
		% 		HDR = HDR';
		% 		whos Y X chanSig HDR
		y(chanIdx,:) = chanSig;
		x(chanIdx,:,:) = HDR;
		
	end
	% 	keyboard
	X = [X x];
	Y = [Y y];
end
% keyboard
ustim = ustim([3 2 1]);
%%
for chanIdx = 1:4
	
	x = squeeze(X(chanIdx,:,:));
	y = Y(chanIdx,:);
	[b,dev,stat] = glmfit(x,y,'normal');
	
	figure(666+fIdx)
	subplot(2,4,chanIdx)
	errorbar(b,stat.se,'k.');
	hold on
	bar(b);
	title(chanlabel{chanIdx});
	set(gca,'XTick',2:4,'XTickLabel',ustim);
	subplot(2,4,chanIdx+4)
	yfit = glmval(b,x,'identity');
	
	plot(y,'k-')
	hold on
	plot(yfit,'r-')
	
	B(chanIdx,:) = b;
	S(chanIdx,:) = stat.se;
end
nirsglm.b = B;
nirsglm.se = S;
save([fname 'glm'],'nirsglm');
