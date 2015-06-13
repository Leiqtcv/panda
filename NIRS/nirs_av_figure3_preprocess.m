function nirs_av_figure3_preprocess
close all


%% Preprocessing
% Load mat files
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014'); %#ok<*UNRCH> % contains all relevant data files
d		= dir('0*.mat');

for ii	= 19
	% 		for ii = 39
	fname	= d(ii).name;
	disp(fname)
	nirs	= pa_nirs_matread(fname); % read in mat file, and detect events/stimuli/btn from AD channels
	OD		= nirs.OD; % optical densities
	
	Fs		= nirs.Fs;
	dC1		= OD;
	n		= ceil(10/Fs*size(OD,1));
	dC		= NaN(n,size(OD,2));
	t		= nirs.time;
	
	%% Preprocessing
	figure(1); clf
	for jj = 4
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
		
		%% remove onset and offset
		a				= [nirs.event.sample];
		selt			= t>a(1)/nirs.Fs-10 & t<a(end)/nirs.Fs+10; % within 10 s of on- or offset
		
		%% detrend DC
		dC(:,jj)	= detrend(dC(:,jj),'constant'); % normalize to temporal mean value
		
		plottime(dC,t,jj,selt,0);
		plotpower(dC,jj,selt); % power spectrum
		
		%% Remove heartbeat
		a			= [dC(selt,jj) dC(selt,jj)];
		b			= removeheartbeat(a,0.1); % heartbeat
		b			= removeheartbeat(b,0.1,2); % respiration (0.2 Hz)
		b			= removeheartbeat(b,0.1,[0.05 .2]); % Mayer Wave[0.05 .2]
		dC(selt,jj) = b(:,1);
		
		plottime(dC,t,jj,selt,.01);
		plotpower(dC,jj,selt); % power spectrum
		%% Zero
		% 		dC(~selt,jj) = NaN;
		
		%% filter
		flim		= [0.008 .1];
		dC(selt,jj)	= pa_bandpass(dC(selt,jj),flim,5); % we bandpass between 0.016 and 0.8 Hz to remove noise and cardiac component
		
		plottime(dC,t,jj,selt,.02);
		plotpower(dC,jj,selt); % power spectrum
		
		%% detrend polynomial
		x			= t(selt);
		x			= zscore(x);
		y			= dC(selt,jj);
		p			= polyfit(x,y,20);
		a			= y-polyval(p,x);
		dC(selt,jj)	= a; % detrend
		
		plottime(dC,t,jj,selt,.03);
		plot(t(selt),polyval(p,x)+.02,'k');
		% 		legend('detrend','heart','bandpass','+poly','-poly','Location','best');
		if jj==4
			text(780,0,'Raw');
			text(780,0.01,{'heart/respiration/mayer';'removed'});
			text(780,0.02,{'bandpassed';'[0.016-0.1 Hz]'});
			text(780,0.03,{'polynomial (20-deg)';'detrended'});
		end
		
		plotpower(dC,jj,selt); % power spectrum
		HDR = gethemo(nirs,dC);
		HDR = pa_zscore(nansum(HDR))/300;
		disp(HDR)
		HDR = repmat(HDR,4,1)';
% 		plotpower(HDR,4,selt); % power spectrum

% 		legend('raw','heart/respiration/mayer','bandpassed','polynomial detrended','Stimulus','Location','best');
				legend('raw','heart/respiration/mayer','bandpassed','polynomial detrended','Location','best');

		subplot(121)

% 		plot(t,-0.01*nansum(HDR)+0.035,'k-');
		
		on		= ceil([nirs.event.sample]*nirs.fsdown/nirs.Fs);
		off		= on(2:2:end);
		on		= on(1:2:end);
		nirs.event.stim
		for kk = 1:numel(on)
			x = [on(kk) off(kk)]/10;
			y = [0 0];
			e = [0.05 0.05];
			pa_errorpatch(x,y,e);
		end
	end
	
	
end
figure(1)
subplot(121)
box off
h = pa_text(0.1,0.9,'A');
set(h,'FontSize',15,'FontWeight','bold');

subplot(122)
h = pa_text(0.001,0.9,'B');
set(h,'FontSize',15,'FontWeight','bold');

pa_datadir
print('-depsc','-painters',mfilename);

function [f,mx,ph,h]=pa_getpower(x,Fs,varargin)
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
	
	MX(ii,:) = mx; %#ok<AGROW>
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

function plotpower(dC,jj,selt)
%% Power spectrum
if jj ==4
	
	figure(1)
	subplot(122)
	% subplot(nsub,nsub,jj);
	x = dC(selt,jj);
	pa_getpower(x,10,'display',true);
	hold on
	xlim([0.01 10]);
	set(gca,'XTick',[0.01 0.1 1 10],'XTickLabel',[0.01 0.1 1 10],'TickDir','out')
	set(gca,'TickDir','out','TickLength',[0.005 0.025],...
		'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
	xlabel('Frequency (Hz)','FontSize',12);
	ylabel('Power (dB[V])','FontSize',12);
	title([]);
	axis square;
		box off

end
function plottime(dC,t,jj,selt,nsub)
if jj ==4
	
	figure(1)
	subplot(121)
	% subplot(nsub,nsub,jj);
	plot(t(selt),dC(selt,jj)+nsub);
	hold on
	xlabel('time (s)','FontSize',12);
	ylabel('Amplitude (V)','FontSize',12);
	box off
	xlim([0 1000]);
	ylim([-0.01 0.04]);
	set(gca,'TickDir','out','TickLength',[0.005 0.025],...
		'XTick',0:100:1000,'YTick',0:0.01:0.03,...
		'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
	% 	'XTick',-90:30:90,'YTick',-90:30:90,...
	axis square;
	pa_horline(0:0.01:0.03);
	title('Deep channel, Rx1-Tx2 (35 mm) @ 765 nm, subject 13, block 2 (A-only)','FontSize',12);
end

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



