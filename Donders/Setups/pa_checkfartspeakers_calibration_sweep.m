function pa_checkfartspeakers_calibration_sweep
% PA_CHECK_FARTSPEAKERS_CALIBRATION_SWEEP
%
% Determine sweep characteristics of the speakers. This is a check of the
% hoop/sound localization set-up at 12-02-2013
%

% 2013 Marc van Wanrooij
% Calibration performed by Rachel Gross-hardt

close all

%% Files
fname	=  'E:\MATLAB\PANDA\Donders\Setups\supplementary\fartspeakers-sweep18-2013-02-13.hrtf';
fname	=  'E:\MATLAB\PANDA\Donders\Setups\supplementary\fartspeakers-sweep-2013-02-12.hrtf';
fname = pa_fcheckexist(fname);

d		= fname;
grphFlag = true;
% wavfile	=  'E:\MATLAB\PANDA\Donders\Setups\supplementary\snd018.wav';
wavfile	=  'E:\MATLAB\PANDA\Donders\Setups\supplementary\snd015.wav';
wavfile = pa_fcheckexist(wavfile);

Freqs	= pa_oct2bw(1000,-1:1:8); % pure tones of these frequencies were presented.

%% Analysis
[hrtf,m] = pa_readhrtf(d); % read the data

wav		= wavread(wavfile);
sel		= m(:,2)==1; % STRANGE, SHOULD BE 2 ACCORDING TO PA_READCSV!
Snd		= m(sel,11);
nSnds	= length(Snd);
Loc		= m(sel,7);
uLoc	= unique(Loc);
nLoc	= numel(uLoc);
Amp		= m(sel,10);

%%
close all

col = summer(nSnds);
sweep = struct([]);
for ii = nSnds:-1:1
	x			= hrtf(ii).hrtf;
	[Spec,Freq,Tijd,WAV,SpecWav] = pa_sweep2spec(x,wav,1);
	
	M = 20*log10(abs(Spec)/length(Spec));
	sweep(ii).power = M;
	sweep(ii).frequency = Freq;
	sweep(ii).wave = Tijd;
	sweep(ii).location = Loc(ii);
	sweep(ii).amplitude = Amp(ii);
	sweep(ii).stimwave = WAV;
	
	figure(1)
	if grphFlag
		if ii == nSnds
			subplot(231)
			plot(wav(1024:1024*3),'Color',col(1,:));
			hold on
			
			
			xlabel('Time (samples)');
			ylabel('Amplitude (V)');
			title('2 Sweep-fragments of snd015-WAV-file');
			xlim([1 1024*2]);
			axis square;
			box off

			subplot(234)
			plot(WAV,'Color',col(1,:));
			hold on
			
			
			xlabel('Time (samples)');
			ylabel('Amplitude (V)');
			title('2 Sweep-fragments of snd015-WAV-file');
			xlim([1 1024*2]);
			axis square;
			box off
			

		end
		
		if ii ==  1
		subplot(133)
		m = abs(SpecWav);
		m = m./length(m);
		p = 20*log10(m);
		semilogx(Freq,p,'Color','k','LineWidth',4)
		hold on
		end
% 		return

		subplot(132)
		plot(Tijd,'Color',col(ii,:));
		hold on
		xlabel('Time (samples)');
		ylabel('Amplitude (V)');
		title('Average sweep recorded with B&K');
		xlim([1 numel(Tijd)]);
		ylim([-2 2]);
		axis square;
		box off
		
		subplot(133)
		semilogx(Freq,M,'Color',col(ii,:))
		hold on
		set(gca,'XTick',Freqs,'XTickLabel',round(Freqs));
		xlim([100 20000]);
		axis square
		box off
		xlabel('Frequency (Hz)');
		ylabel('Power (dB re V)');
		title('Power-spectrum');

		drawnow
	end
end
pa_datadir;
print('-depsc','-painter',[mfilename '1']);


%%
nsmooth = 6;
ampsel = 60;
figure(2)
col = summer(nLoc+10);

M = NaN(size([sweep(1).power],1),nLoc);
for ii = 1:nLoc
	sel = [sweep.location]==uLoc(ii) & [sweep.amplitude]==ampsel;
	if sum(sel)
	f = sweep(sel).frequency;
	m = smooth(mean([sweep(sel).power],2),nsmooth);
	subplot(211)
	semilogx(f,m,'Color',col(ii,:))
	
	hold on
	set(gca,'XTick',Freqs,'XTickLabel',round(Freqs));
	xlim([250 20000]);
	ylim([-80 -20])
	box off
	M(:,ii) = m;
	end
end
xlabel('Frequency (Hz)');
ylabel('Power (dB re V)');
title(['Power-spectrum at exp-amplitude: ' num2str(ampsel)]);

%%
sel = [sweep.amplitude]==60;
f = sweep(sel).frequency;
m = smooth(mean([sweep(sel).power],2),nsmooth);
semilogx(f,m,'Color','k','LineWidth',2)

subplot(212)
contourf(f,uLoc,M',-70:2:-35)
caxis([-65 -35]);
xlim([250 20000]);
set(gca,'XScale','log');
set(gca,'XTick',Freqs,'XTickLabel',round(Freqs),'YDir','normal','YTick',2:2:29,'YTickLabel',5*(2:2:29)-60);
xlabel('Frequency (Hz)');
ylabel('Speaker location (deg)');

pa_datadir;
print('-depsc','-painter',[mfilename '2']);

keyboard
%%

figure
plot(uLoc,mean(M),'ko-','MarkerFaceColor','w')
axis square
box off
set(gca,'TickDir','out','XTick',1:29,'YTick',[-52 -50 -48 -46]);
grid on
%% Exp-Power curve for speaker 12
sel = [sweep.location]==12;
f	= sweep(sel).frequency;
m	= [sweep(sel).power];
a	= [sweep(sel).amplitude];
figure(3)
m(~isfinite(m)) = NaN;
errorbar(a,nanmean(m),nanstd(m),'ko-','MarkerFaceColor','w','Linewidth',2);
axis square;
box off
xlabel('Exp-file intensity (au)');
ylabel('Power (dB re V)');
axis([10 90 -90 -30])

pa_datadir;
print('-depsc','-painter',[mfilename '3']);



function [dat,mlog,exp,chan] = pa_readhrtf(hrtffile)
% HRTF = PA_READHRTF(HRTFFILE)
%
% Read hrtf-file and extract Time Series data in HRTF
% HRTF is a (k x m x n)-matrix, where
%   k = number of samples
%   m = number of trials/locations
%   n = number of microphones/channels
%
% See also READCSV, READDAT

% Copyright 2008
% Marc van Wanrooij

%% Initialization
% Check Inputs
if nargin <1
	hrtffile        = '';
end
% Check Files
hrtffile            = pa_fcheckext(hrtffile,'.hrtf');
hrtffile            = pa_fcheckexist(hrtffile,'.hrtf');
csvfile             = pa_fcheckext(hrtffile,'.csv');

%% Read CSV-file
[exp,chan,mlog]     = pa_readcsv(csvfile);
sel                 = ismember(mlog(:,5),6); % 6 and 7 are Inp1 and Inp2
ntrials				= sum(sel);
nsample				= mlog(sel,9);

%% Read HRTF-file
fid             = fopen(hrtffile,'r');
if ispc
	hrtf         = fread(fid,inf,'float');
else %MAC
	hrtf         = fread(fid,inf,'float','l');
end
% And close
fclose(fid);

dat = struct([]);
cnt = 0;
for ii = 1:ntrials
	indx			= (1:nsample(ii))+cnt;
	cnt				= cnt+nsample(ii);
	dat(ii).hrtf	= hrtf(indx);
end



function [Spec,Freq,Tijd,WAV,SpecWav] = pa_sweep2spec(Sweep,Wav,chan,NFFT,NSweep,Fs,GraphFlag)
% [SPEC,FREQ,TIME] = SWEEP2SPEC(SWEEP,WAV,CHAN,NFFT,NSWEEP,CHAN)
%
% See also READHRTF, GENSWEEP


%% Initialization
if nargin<3
	chan = 1;
end
if nargin<4
	NFFT    = 1024;
end
if nargin<5
	NSweep = 18;
end
if nargin<6
	Fs     = 48828.125;
end
if nargin<7
	GraphFlag = 0;
end

nloc	= size(Sweep,3);
nchan	= size(Sweep,2);

%% FFT & Reshaping
nBegin  = ceil(20/1000*Fs);
Tijd    = NaN(NFFT,nloc);
Spec    = Tijd;
L       = NaN(1,nloc);

% for each location i
for i = 1:nloc
	if nchan>1
		d           = squeeze(Sweep(:,chan,i)); % obtain the measured Sweep data from channel chan
	else
		d           = squeeze(Sweep(:,i)); % obtain the measured Sweep data from channel chan
	end
	d           = d(101:end); % Remove the first 100 samples, somehow HumanV1 adds 100 extra samples
	% Rough Alignment Method 1
	if length(d)==length(Wav)
		[c,lags]    = xcorr(d,Wav,'coeff');
	else
		[c,lags]    = xcorr(d,Wav,'none');
	end
	[~,indx]    = max(abs(c));
	lag         = lags(indx);
	
	if GraphFlag
		td = 0:length(d)-1; td = 1000*(td-lag)/Fs;
		tw = 0:length(Wav)-1; tw = 1000*tw/Fs;
		figure(600)
		clf
		subplot(211)
		plot(tw,Wav,'r-');
		hold on
		plot(td,d,'k-');
		xlim([0 max(td)]);
		ylim([-3 3]);
		subplot(212)
		plot(lags,c,'k-');
		xlim([min(lags) max(lags)]);

		drawnow
		pause;
		
	end
	L(i)        = lag;	
end
if GraphFlag
	L = L(L<250);
	%% Check whether lags are correct
	mnL = min(L);
	mxL = max(L);
	stp = std(L)./sqrt(numel(L));
	x = unique(round(min(L):stp:max(L)));
	figure(601)
	N = hist(L,x);
	[~,indx] = max(N);
	bar(x,N,1);
	verline(round(median(L)));
	verline(x(indx));
end
lag = median(L);
% Aligmnent Method 2
% If Sweep is too weak, the time delay might be judged incorrectly
% Correct for this:
if lag>250 || lag<1
	lag     = 210;
end
for i = 1:nloc
	if nchan>1
		d           = squeeze(Sweep(:,chan,i)); % obtain the measured Sweep data from channel chan
	else
		d           = squeeze(Sweep(:,i)); % obtain the measured Sweep data from channel chan
	end
	d           = d(101:end); % Remove the first 100 samples, somehow HumanV1 adds 100 extra samples
	nOnset      = lag+nBegin;
	indx        = nOnset + NFFT + (1:(NFFT*NSweep));
	data        = d(indx);
	wavdata		= Wav(indx);
	data        = reshape(data, NFFT, NSweep);
	wavdata     = reshape(wavdata, NFFT, NSweep);
	meandata    = mean(data,2)';
	meandata    = meandata - mean(meandata);
	Tijd(:,i)   = meandata;
	nfft        = 2^(nextpow2(length(meandata)));
	X           = fft(meandata,nfft);
	Spec(:,i)   = X;
	meandata	= mean(wavdata,2)';
	WAV(:,i)	= meandata;
	X           = fft(meandata,nfft);
	SpecWav(:,i) = X;
	
end
% NumUniquePts	= ceil((NFFT+1)/2);
% Spec			= Spec(1:NumUniquePts,:);
Freq			= (0:(NFFT-1))*Fs/NFFT;

