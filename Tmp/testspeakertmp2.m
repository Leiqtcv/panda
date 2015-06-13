function testspeakertmp2

close all
% clear all

cd('/Users/marcw/DATA/tmp/testspeaker');

Fs = 48828.125;
% x = acoustic
% -0001 = speaker
% -0002 = TDT

for ii = 1:2
	close all
	if ii ==1
		[~,~,l] = pa_readcsv('testspeaker-2014-11-21');
		sel		= l(:,5)==2;
		l		= l(sel,:);
		hrtf	= pa_readhrtf('testspeaker-2014-11-21');
	elseif ii==2
		[~,~,l] = pa_readcsv('testspeaker-2014-11-21-0001');
		sel		= l(:,5)==2;
		l		= l(sel,:);
		hrtf	= pa_readhrtf('testspeaker-2014-11-21-0001');
	end
	
	M = NaN(14,7);
	Mag1 = M;
	Mag2 = M;
	snd = unique(l(:,11));
	sel = ismember(snd,[100 200 300 400]);
	snd = snd(~sel);
	nsnd = numel(snd);
	int = unique(l(:,10));
	nint = numel(int);
	for jj = 1:nsnd
		for kk = 1:nint
			
			sndname = ['snd' num2str(snd(jj),'%03i') '.wav'];
			[y,fs]	= audioread(sndname);
			y		= zscore(y);
			sel		= l(:,10)==int(kk) & l(:,11) == snd(jj);
			if sum(sel)
				a		= squeeze(hrtf(:,1,sel));
				y		= y(9500:15000);
				
				a = pa_highpass(a,500,Fs/2,100);
				a = pa_lowpass(a,20000,Fs/2,100);
				b			= a(9500:15000);
				
				r			= rms(b);
				M(jj,kk) = rms(r);
				
				% 		b = zscore(b);
				
				figure(1)
				clf
				subplot(121)
				plot(y-1,'k-');
				hold on
				axis square
				box off
				plot(b+1,'r-');
				str = ['Sound = ' num2str(jj)];
				title(str);
				% 		figure(2)
				subplot(122)
				pa_getpower(y,fs,'display',1);
				hold on
				axis square
				box off
				[freq,mag] = pa_getpower(b,Fs,'display',1,'Color','r');
				str = ['Level = ' num2str(kk)];
				title(str);
				pa_verline(pa_oct2bw(snd(jj)*1000,0:3));
				drawnow
	print('-depsc','-painters',['wavespec-meas' num2str(ii) '-int' num2str(kk) '-freq' num2str(jj)]);
				[~,indx1] = min(abs(freq-snd(jj)*1000));
				Mag1(jj,kk) = mag(indx1);
				[~,indx2] = min(abs(freq-snd(jj)*1000*1.5));
				Mag2(jj,kk) = mag(indx2);
			end
			% 		pause
		end
	end
	
	%%
	dB = log10(M);
	
	ylm = [min([Mag1(:); Mag2(:)]) max([Mag1(:); Mag2(:)])];
	
	dB = Mag1;
	figure(2)
% 	subplot(131)
	plot(int,dB','o-','MarkerFaceColor','w');
	xlabel('Exp intensity (au)');
	ylabel('Magnitude 1st harmonic/fundamental (dB)');
	ylim(ylm);
	set(gca,'XTick',20:10:80);
	
	axis square
	box off
	set(gca,'TickDir','out');
% 	legend(num2str(snd),'Location','NW');
	dB = Mag2;
% 	figure(2)
% 	subplot(132)
% 	plot(int,dB','o-','MarkerFaceColor','w');
% 	xlabel('Exp intensity (au)');
% 	ylabel('Magnitude 2nd harmonic (dB)');
% 	axis square
% 	box off
% 	set(gca,'TickDir','out');
% 	ylim(ylm);
% 	set(gca,'XTick',20:10:80);
% 	
% 	dB = Mag2-Mag1;
% 	figure(2)
% 	subplot(133)
% 	plot(int,dB','o-','MarkerFaceColor','w');
% 	xlabel('Exp intensity (au)');
% 	ylabel('Difference magnitude (dB)');
% 	axis square
% 	box off
% 	set(gca,'TickDir','out');
% 	ylim([-60,0]);
% 	set(gca,'XTick',20:10:80);
% 	
	print('-depsc','-painters',[mfilename num2str(ii)]);
end
%%
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
	Fs = 50000;
end
% Optional display arguments
disp         = pa_keyval('display',varargin);
if isempty(disp)
	disp	= 0;
end
orient         = pa_keyval('orientation',varargin);
if isempty(orient)
	orient	= 'x'; % Freq = x-axis
else
	disp = 1;
end
col         = pa_keyval('color',varargin);
if isempty(col)
	col = 'k';
end

%%
% Time vector of 1 second
% Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
nfft = pa_keyval('nfft',varargin);
if isempty(nfft)
	nfft			= 2^(nextpow2(length(x)));
end
mintime		= 2/500*1000;
minsamples	= ceil(mintime/1000*Fs);
nfft		= 2^nextpow2(minsamples);
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
	set(h,'Color',col);
	% 		ax = axis;
	% 		xax = ax([1 2]);
	%
	set(gca,'XTick',[0.05 1 2 3 4 6 8 10 14]*1000);
	set(gca,'XTickLabel',[0.05 1 2 3 4 6 8 10 14]);
	title('Power Spectrum');
	xlabel('Frequency (kHz)');
	ylabel('Power (dB)');
	xlim([50 20000]);
	
end