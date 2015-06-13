function nirs_av_preprocessall
% NIRS_AV_PREPROCESSALL
%
% Preprocess all NIRS data for Luuk van de Rijt's AV experiments
%
% This entails, first:
% - read in oxy3 file (oxysoft2matlab.m)
% - determine scalp coupling index (pa_nirs_sci.m), if scalpFlag is set to
%	true (default: false), and save nirs-structure in mat-file
% - overview of SCI
%
% Then:
% - read in mat-file
% - resample to 10 Hz
% - mean detrend
% - remove heart beat (removeheartbeat.m)
% - bandpass filter
% - polynomial detrend
% - reference channel subtraction
%
% See also OXYSOFT2MATLAB, PA_NIRS_SCI, REMOVEHEARTBEAT, PA_NIRS_MATREAD
% NIRS_AV_REFCHANEFFECT, NIRS_AV_ALLGLMBETA, NIRS_AV_FIGURE1_HYPOTHESIS,
% NIRS_AV_FIGURE2_VIDEO, NIRS_AV_VIDEO_FIGURE3_PREPROCESS

%% Initialization
close all
matFlag		= false;
% matFlag = true;
scalpFlag	= false;
% scalpFlag = true;
checkFlag	= false;
% checkFlag = true;

%% Mat files
if matFlag, oxy2mat; end; % Convert oxy files
if scalpFlag, getsci; end % scalp coupling index
if checkFlag, docheck; end % check SCI


%% Preprocessing
% Load mat files
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014'); %#ok<*UNRCH> % contains all relevant data files
d		= dir('0*.mat');
[m,~]	= size(d);
for ii	= 1:m
	fname	= d(ii).name;
	disp(fname)
	nirs	= pa_nirs_matread(fname); % read in mat file, and detect events/stimuli/btn from AD channels
	OD		= nirs.OD; % optical densities
	nChan	= size(OD,2); % number of OD channels
	
	Fs		= nirs.Fs;
	dC1		= OD;
	n		= ceil(10/Fs*size(OD,1));
	dC		= NaN(n,size(OD,2));
	t		= nirs.time;
	
	%% Preprocessing
	if checkFlag
		figure(3); clf
		figure(4); clf
	end
	nsub	= ceil(sqrt(nChan));
	for jj = 1:nChan
		%% resample
		nirs.fsdown = 10;
		if Fs>15
			a			= resample(dC1(:,jj),nirs.fsdown,Fs); %#ok<*SAGROW> % we resample the data: this is better than downsample because it deals with anti-aliasing, but there is a discussion about this, see also auditory mailing list
			dC(:,jj)	= a;
			t			= 1:length(dC);
			t			= t'/10;
		else
			dC(:,jj)	= dC1(:,jj);
		end
		
		%% remove onset and offset & breaks between blocks
		% breaks
		a				= [nirs.event.sample];
		b				= a(1:2:end);
		c				= a(2:2:end);
		dff				= b(2:end)-c(1:end-1);
		indx			= find(dff>1500);
		offbreak		= b(indx+1)/nirs.fsdown;
		onbreak			= c(indx)/nirs.fsdown;
		nbreak			= numel(onbreak);
		% on and offset
		selt			= t>a(1)/nirs.Fs-10 & t<a(end)/nirs.Fs+10; % within 10 s of on- or offset
		selbreak		= false;
		for brkIdx		= 1:nbreak
			selbreak	= t>onbreak(brkIdx)+10 & t<offbreak(brkIdx)-10 | selbreak;
		end
		selt			= selt&~selbreak; 		% both
		
		%% detrend DC
		dC(:,jj)	= detrend(dC(:,jj),'constant'); % normalize to temporal mean value
		
		if checkFlag
			plottime(dC,t,jj,selt,nsub);
			plotpower(dC,jj,selt,nsub); % power spectrum
		end
		%% Remove heartbeat
		a			= [dC(selt,jj) dC(selt,jj)];
		b			= removeheartbeat(a,0.1); % heartbeat
		b			= removeheartbeat(b,0.1,2); % respiration (0.2 Hz)
		b			= removeheartbeat(b,0.1,[0.05 .2]); % Mayer Wave[0.05 .2]
		dC(selt,jj) = b(:,1);
		
		if checkFlag
			plottime(dC,t,jj,selt,nsub);
			plotpower(dC,jj,selt,nsub); % power spectrum
		end
		%% filter
		flim		= [0.008 .1];
		dC(:,jj)	= pa_bandpass(dC(:,jj),flim,5); % we bandpass between 0.016 and 0.8 Hz to remove noise and cardiac component
		
		if checkFlag
			plottime(dC,t,jj,selt,nsub);
			plotpower(dC,jj,selt,nsub); % power spectrum
		end
		%% detrend polynomial
		x			= t(selt);
		x			= zscore(x);
		y			= dC(selt,jj);
		p			= polyfit(x,y,20);
		a			= y-polyval(p,x);
		dC(selt,jj)	= a; % detrend
		
		if checkFlag
			plottime(dC,t,jj,selt,nsub);
			plot(t(selt),polyval(p,x),'k');
			legend('detrend','heart','bandpass','+poly','-poly','Location','best');
			
			y			= dC;
			y(selt,jj)	= polyval(p,x);
			plotpower(dC,jj,selt,nsub); % power spectrum
			plotpower(y,jj,selt,nsub); % power spectrum
			legend('detrend','heart','bandpass','+poly','-poly','Location','best');
			pa_verline(flim,'r:');
			pa_verline(1/60,'r--');
			pa_verline([0.1 0.4 1]);
		end
	end
	nirs.preprOD	= dC;				% prepocessed optical densities
	nirs			= pa_mbll(nirs);	% concentration change
	dC				= nirs.dC;
	label			= nirs.dclabel;
	
	%% reference channel subtraction
	if any(strncmp(label,'Rx1a-Tx1 O2Hb',15))
		idx(1)		= find(strncmp(label,'Rx1a-Tx1 O2Hb',15));  % Oxy-hemoglobin channel 1
		idx(2)		= find(strncmp(label,'Rx1b-Tx2 O2Hb',15));  % Oxy-hemoglobin channel 2
		idx(3)		= find(strncmp(label,'Rx1a-Tx1 HHb',14));	% Deoxy-hemoglobin channel 1
		idx(4)		= find(strncmp(label,'Rx1b-Tx2 HHb',14));	% Deoxy-hemoglobin channel 2
	else
		idx(1)		= find(strncmp(label,'Rx1-Tx1 O2Hb',15));	% Oxy-hemoglobin channel 1
		idx(2)		= find(strncmp(label,'Rx1-Tx2 O2Hb',15));	% Oxy-hemoglobin channel 2
		idx(3)		= find(strncmp(label,'Rx1-Tx1 HHb',14));	% Deoxy-hemoglobin channel 1
		idx(4)		= find(strncmp(label,'Rx1-Tx2 HHb',14));	% Deoxy-hemoglobin channel 2
		idx(5)		= find(strncmp(label,'Rx2-Tx3 O2Hb',15));	% Oxy-hemoglobin channel 3
		idx(6)		= find(strncmp(label,'Rx2-Tx4 O2Hb',15));	% Oxy-hemoglobin channel 4
		idx(7)		= find(strncmp(label,'Rx2-Tx3 HHb',14));	% Deoxy-hemoglobin channel 3
		idx(8)		= find(strncmp(label,'Rx2-Tx4 HHb',14));	% Deoxy-hemoglobin channel 4
	end
	nchan		= round(nChan/2);
	k			= 0;
	signal		= NaN(size(dC,1),round(nChan/2));
	deepchan	= signal;
	shallowchan = signal;
	if checkFlag
		figure(5); clf
		figure(6); clf
		figure(7); clf
	end
	for chanIdx = 1:nchan
		k		= k+1;
		chan	= dC;
		chanRef	= chan(:,idx(1+(chanIdx-1)*2)); % shallow channel
		chanSig	= chan(:,idx(2+(chanIdx-1)*2)); % deep channel
		chanOri = chanSig;
		
		if checkFlag
			figure(5)
			subplot(2,nchan,chanIdx)
			plot(chanRef,'k.')
			hold on
			plot(chanSig,'r.')
			axis square
			box off
			title([chanIdx k (1+(chanIdx-1)*2)]);
			
			subplot(2,nchan,chanIdx+nchan)
			plot(chanRef,chanSig,'k.')
			axis square
			box off
			pa_unityline;
		end
		b				= regstats(chanSig(selt),chanRef(selt),'linear',{'beta','r'});
		brobust			= robustfit(chanRef(selt),chanSig(selt));
		b.r				= chanSig(selt)-(brobust(2)*chanRef(selt)+brobust(1));
		
		if checkFlag
			subplot(2,nchan,chanIdx+nchan)
			plot(chanRef(selt),chanSig(selt),'k.')
			axis square
			box off
			pa_unityline;
			pa_regline(b.beta);
			pa_regline(brobust,'r-');
		end
		
		chanSig(~selt)	= NaN;
		chanSig(selt)	= b.r;
		signal(:,k)		= chanSig;
		deepchan(:,k)	= chanOri;
		shallowchan(:,k)	= chanRef;
	
		if checkFlag
			figure(6)
			nsub	= ceil(sqrt(nchan));
			subplot(nsub,nsub,chanIdx);
			plot(t,signal(:,k)+1.5);
			hold on
			box off
			pa_horline;
			xlabel('time');
			ylabel('Z');
			
			HDR				= gethemo(nirs,signal(:,k));
			plot(t,sum(HDR),'k-');
			
			%% Block average
			mod			= {'V','A','AV'};
			for modIdx	= 1:3
				stim		= nirs.event.stim; % stimulus modality - CHECK HARDWARE WHETHER THIS IS CORRECT
				if numel(stim)<3
					stim = {nirs.event.stim};
				end
				if numel(unique(stim))<3
					mod = {'A';'A';'A'};
				end
				MU			= pa_nirs_blockavg(nirs,signal(:,k),mod{modIdx});
				MUori		= pa_nirs_blockavg(nirs,chanOri,mod{modIdx});
				x			= 1:length(MU);
				x			= x/10;
				figure(7)
				subplot(121)
				plot(x,nanmean(MUori))
				hold on
				box off
				axis square;
				
				subplot(122)
				plot(x,nanmean(MU))
				hold on
				box off
				axis square;
			end
		end
	end
	nirs.signal		= signal;
	nirs.deepchan	= deepchan;
	nirs.shallowchan	= shallowchan;
	if checkFlag
		bl			= zeros(size(x));
		sel			= x>10 & x<30;
		bl(sel)		= 1;
		hemo		= pa_nirs_hdrfunction(1,bl);
		subplot(121)
		plot(x,hemo,'k-','LineWidth',2);
		plot(x,-hemo,'k-','LineWidth',2);
		pa_verline(10);
		pa_verline(30);
		
		subplot(122)
		plot(x,hemo,'k-','LineWidth',2);
		plot(x,-hemo,'k-','LineWidth',2);
		pa_verline(10);
		pa_verline(30);
	end
	%% Save
	fname = pa_fcheckext(['nirs' d(ii).name],'.mat');
	save(fname,'nirs');
	drawnow
end


function [f,mx,ph,h] = pa_getpower(x,Fs,varargin)
% [F,A,PH] = PA_GETPOWER(X,FS)
%
% Get power A and phase PH spectrum of signal X, sampled at FS Hz.
%
% PA_GETPOWER(...,'PARAM1',val1,'PARAM2',val2) specifies optional
% name/value pairs. Parameters are:
%	'display'	- display graph. Choices are:
%					0	- no graph (default)
%					>0	- graph
%	'color'	- specify colour of graph. Colour choices are the same as for
%	PLOT (default: k - black).


% 2011  Modified from Mathworks Support:
% http://www.mathworks.com/support/tech-notes/1700/1702.html
% by: Marc van Wanrooij

%% Initialization
if nargin<2
	Fs = 10;
end
% Optional display arguments
disp         = pa_keyval('display',varargin);
if isempty(disp)
	disp	= 0;
end


%%
% Time vector of 1 second
% Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
nfft = pa_keyval('nfft',varargin);
if isempty(nfft)
	mintime		= 1/0.025*1000;
	minsamples	= ceil(mintime/1000*Fs);
	nfft		= 2^nextpow2(minsamples);
end

nblocks		= floor(length(x)/nfft);
for ii = 1:nblocks
	indx = (1:nfft)+(ii-1)*nfft;
	% Take fft, padding with zeros so that length(fftx) is equal to nfft
	fftx			= fft(x(indx),nfft);
	% Calculate the numberof unique points
	NumUniquePts	= ceil((nfft+1)/2);
	% FFT is symmetric, throw away second half
	fftx			= fftx(1:NumUniquePts);
	% Take the magnitude of fft of x and scale the fft so that it is not a function of
	% the length of x
	mx				= abs(fftx)/length(x);
	ph				= angle(fftx);
	
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
	
	% Take the square of the magnitude of fft of x -> magnitude 2 power
	% mx				= mx.^2;
	mx		= 20*log10(mx);
	sel		= isinf(mx);
	mx(sel) = min(mx(~sel));
	
	MX(ii,:) = mx;
end
mx = nanmean(MX);

%% Display option
if disp
	% 		h = semilogx(f,mx);
	% 		set(h,'Color',[.7 .7 .7]);
	
	h = semilogx(f,mx);
	hold on
	% 		ax = axis;
	% 		xax = ax([1 2]);
	%
	set(gca,'XTick',[0.05 1 2 3 4 6 8 10 14]*1000);
	set(gca,'XTickLabel',[0.05 1 2 3 4 6 8 10 14]);
	title('Power Spectrum');
	xlabel('Frequency (kHz)');
	ylabel('Power (dB)');
	% 	xlim([50 20000]);
	
end

function plotpower(dC,jj,selt,nsub)
%% Power spectrum
figure(4)
subplot(nsub,nsub,jj);
x = dC(selt,jj);
pa_getpower(x,10,'display',true);
hold on
xlim([0.01 10]);
set(gca,'XTick',[0.01 0.1 1 10],'XTickLabel',[0.01 0.1 1 10],'TickDir','out')
box off

function plottime(dC,t,jj,selt,nsub)
figure(3)
subplot(nsub,nsub,jj);
plot(t(selt),dC(selt,jj));
hold on
set(gca,'TickDir','out');
xlabel('time (s)');
ylabel('nirs (au)');
box off

function HDR = gethemo(nirs,S)
fs		= nirs.Fs;
fd		= nirs.fsdown;
R		= S(:,1);
on		= ceil([nirs.event.sample]*fd/fs);
off		= on(2:2:end);
on		= on(1:2:end);
stim		= nirs.event.stim; % stimulus modality - CHECK HARDWARE WHETHER THIS IS CORRECT
if numel(stim)<3
	stim = {nirs.event.stim};
end
ustim	= unique(stim);
nstim	= numel(ustim);
n		= numel(R);
HDR		= NaN(3,n);
for sIdx = 1:nstim
	sel		= strcmp(ustim(sIdx),stim(1:2:end)) | strcmp('AV',stim(1:2:end));
	ons		= on(sel);
	offs	= off(sel);
	N		= length(R);
	bl      = zeros(1, N);
	for kk	= 1:length(ons)
		bl(ons(kk):offs(kk)) = 1;
	end
	hemo		= pa_nirs_hdrfunction(1,bl);
	HDR(sIdx,:) = hemo';
end

function getsci
% Load mat files
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014'); %#ok<*UNRCH> % contains all relevant data files
d		= dir('0*.mat');
[m,~]	= size(d);
for ii	= 1:m
	fname	= d(ii).name;
	nirs = pa_nirs_matread(fname); % read in mat file, and detect events/stimuli/btn from AD channels
	nirs = pa_nirs_sci(nirs,'disp',false);
	drawnow
	
	fname = pa_fcheckext(fname,'mat');
	save(fname,'nirs')
end

function docheck

%% Overview SCI
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014'); %#ok<*UNRCH> % contains all relevant data files
d		= dir('0*.mat');

[m,~]	= size(d);
SCI = [];
F = [];
nsci = NaN(m,1);
for ii	= 1:m
	% 		for ii = 39
	fname		= d(ii).name;
	disp(fname)
	nirs		= pa_nirs_matread(fname); % read in mat file, and detect events/stimuli/btn from AD channels
	sci			= nirs.sci;
	nsci(ii)	= numel(sci);
	SCI			= [SCI;sci]; %#ok<*AGROW>
	F			= [F;repmat(str2num(fname(1:3)),nsci(ii),1)];
end

s1 = sprintf('Median SC = %0.2g',median(SCI));
s2 = sprintf('%d out of %d channels have an SCI <0.8',sum(SCI<=0.9),numel(SCI));
s3 = sprintf('From %d files',m);
disp(s3)
disp(s1)
disp(s2)

%% Check
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014');

d		= dir('0*.oxy3');
l		= char({d.name}');
prel	= l(:,1:3);
ul		= unique(prel,'rows');
n		= size(ul,1);
np		= size(prel,1);

K		= NaN(n,1);
for ii = 1:n
	k = 0;
	for jj	= 1:np
		t	= strfind(prel(jj,:),ul(ii,:));
		if ~isempty(t)
			k = k+1;
		end
	end
	K(ii)	= k;
end

nside	= (str2num(ul)<38 & str2num(ul)>15)+1; %#ok<*ST2NM>
nchan	= sum(K.*nside*2)-4;% Ref vs Sig & number sides-missing 31
disp(nchan)

a			= str2num(prel);
a(69) = []; % find(a==31); %missing

% disp([a nsci]);

% First 16 subjects were measured on one side, also 5 CI (measured by
% Hai-Yin and Louise_
% the other 21 subjects were measured on both sides (by Luuk)
% one oxy3 file (31-002) cannot be read, and has no mat file
% 3, 11, 12, 16, 26-3, 33-3 only have xls files
sum(nsci)
nchromo = 2;
nchan  = (21*2+16*1 +5*1)*nchromo;
disp(nchan)

nmissingoxy = 4; % all missing have 1 hemisphere recorded
nsubj = (21*2+16*1+5*1)-(nmissingoxy*1);
disp(nsubj)

function oxy2mat
% Load mat files
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014'); %#ok<*UNRCH> % contains all relevant data files
d		= dir('0*.oxy3');
[m,~]	= size(d);
k		= 0;
missingfile = cell(1);
for ii	= 1:m
	clf
	fname	= d(ii).name;
	try % bad programming, figure out problems later
		nirs	= oxysoft2matlab(fname,'rawOD',[]);
		fname	= pa_fcheckext(fname,'mat');
		save(fname,'nirs');
	catch
		k=k+1;
		missingfile{k} = fname;
	end
end