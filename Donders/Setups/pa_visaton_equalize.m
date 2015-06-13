function pa_visaton_equalize
% PA_VISATON_EQUALIZE
%
% Determine equalizing filter for the Visaton SC5.9 mspeakers in the hoop
% setup.
% Data is stored in 'visaton_equalizer.mat'. The measurements are stored in
% PANDA: PANDA\Donders\Setups\supplementary.
%
% See also FIR2, PA_READHRTF, PA_SWEEP2SPEC

% 2013 Marc van Wanrooij
% Modified from m-file obtained from Peter Bremen / John Middlebrooks

close all

%% Initialization
Fs		= 50000;
HiCut	= 20000;
LoCut	= 500;
Nyq		= Fs/2;
FIROrder	= 850;
% FIROrder	= 340;

%% Files
fname	=  'E:\MATLAB\PANDA\Donders\Setups\supplementary\fartspeakers-sweep-2013-02-12.hrtf';
fname	= pa_fcheckexist(fname);
d		= fname;

wavfile	= 'E:\MATLAB\PANDA\Donders\Setups\supplementary\snd015.wav';
wavfile = pa_fcheckexist(wavfile);


%% Read data, and determine speaker location and intensity
[hrtf,m] = pa_readhrtf(d); % read the data
wav		= wavread(wavfile); % read the stimulus sound
sel		= m(:,2)==1; % STRANGE, SHOULD BE 2 ACCORDING TO PA_READCSV!
Snd		= m(sel,11);
nSnds	= length(Snd);
Loc		= m(sel,7); % Speaker number (1-29 and 101-129)
Amp		= m(sel,10); % Sound intensity (in exp-file)

%% Spectrum
sweep	= struct([]); % a structure to store the data
for ii = 1:nSnds
	x					= hrtf(ii).hrtf;
	[~,~,wave]			= pa_sweep2spec(x,wav,1); % determine the average time-trace for one sweep
	sweep(ii).wave		= wave;
	sweep(ii).location	= Loc(ii);
	sweep(ii).amplitude = Amp(ii);
end
sel		= ismember([sweep.amplitude],40:10:60); % only determine avg spectrum from mid-level intensities
mu		= mean([sweep(sel).wave],2); % average over all speakers and intensities
mu		= mu-mean(mu); % fft looks nicer if DC is removed
nfft	= 2^(nextpow2(length(mu))); % fft only works on power2-length datasets
S		= fft(mu,nfft); % Yes, fourier transform in the digital age
S		= abs(S); % we are only interested in the magnitude
n		= numel(S);
S		= S./n*2;
f		= (0:n-1)*Fs/nfft; % Frequency (Hz)

%% Graphics
P		= smooth(20*log10(S),6); % determine Power (dB re V), and smooth for graphical purposes
figure(1)
subplot(131)
semilogx(f,P,'k-','LineWidth',2);
hold on
set(gca,'XTick',pa_oct2bw(1000,-2:7),'XTickLabel',pa_oct2bw(1000,-2:7));
axis square;
box off
title('Power spectrum');
xlabel('Frequency (Hz)');
ylabel('Power (dB re V)');
xlim([100 25000]);
ylim([-80 -20])

%% Initialization
HannSize	= FIROrder-1; % size of hanning window
if ~rem(HannSize,2),   % needs to be odd
    HannSize = HannSize-1;
end
HalfHann	= floor(HannSize/2);
HannWindow	= hanning(HannSize)';

%% Impulse
Impulse		= real(ifft(S)); % impulse response
nImp		= numel(Impulse);
t			= (1:nImp)./Fs*1000;

figure(1)
subplot(132)
indx = 1:nImp/2;
plot(t(indx),Impulse(indx),'k-','LineWidth',2)
hold on
xlabel('Time (ms)');
ylabel('Amplitude (au)');
axis square;
box off
xlim([-0.2 1]);
title('Impulse response');
pa_verline;

%% Inverse magnitude spectrum
% first we apply a Hann window to the impulse response
nI			= length(Impulse);
[~, indx]	= max(Impulse);
AugImp		= [Impulse Impulse];
if indx<ceil(HannSize/2),
    indx		= indx + nI;
end
CutImp		= AugImp((indx-HalfHann):(indx+HalfHann));
CutImp		= CutImp.*HannWindow; % apply Hann window, this smoothes the frequency response
Spec		= fft(CutImp); % get complex spectrum
invSpec		= 1./Spec; % inverse spectrum
Mag			= abs(invSpec(1:(HalfHann+1))); % magnitude
RelFreq		= (0:HalfHann)/(HalfHann); % Relative frequencies (0-1)

%% Remove the low and high-frequencies
indxLo			= find(RelFreq<LoCut/Nyq);
indxLo			= indxLo(end);
indxHi			= find(RelFreq>HiCut/Nyq);
indxHi			= indxHi(1);
t				= indxLo-(0:indxLo-1);
t				= t/indxLo;
Mag(1:indxLo)	= Mag(indxLo);

Mag(1:indxLo)	= Mag(1:indxLo).*(1+cos(pi*t))/2;
t				= (indxHi:length(Mag)) - indxHi;
t				= t/max(t);
Mag(indxHi:end) = Mag(indxHi);
Mag(indxHi:end) = Mag(indxHi:end).*(1+cos(pi*t))/2;

Mag				= Mag./max(Mag); % normalization
Mag				= sqrt(Mag); % we apply filtfilt so we need the square of the magnitude
Freq			= RelFreq*Fs/2; % actual frequencies

%% THE FILTER
b				= fir2(FIROrder, RelFreq, Mag); % this can be used with FILTFILT
% b = 10*b/sum(abs(b)); % normalize by sum of abs FIRBuff 
%   and multiply by 10 to get reasonable gain

figure(1)
subplot(133)
[h,w] = freqz(b,1,FIROrder);
semilogx(Freq,Mag,'k-','LineWidth',2)
hold on
semilogx(w/pi*Fs/2,abs(h),'r-','LineWidth',2)
legend('Ideal','fir2 Designed')
title('Comparison of Frequency Response Magnitudes')
set(gca,'XTick',pa_oct2bw(1000,-2:7),'XTickLabel',pa_oct2bw(1000,-2:7));
xlim([100 25000]);
ylabel('Magnitude');
xlabel('Frequency (Hz)');
axis square
box off

%% Save
pa_datadir;
datfile = fname; %#ok<NASGU>
save('visaton_equalizer','b','datfile','wavfile','FIROrder'); % store the filter

%% Equalize
FIROrder	= 340;
b				= fir2(FIROrder, RelFreq, Mag); % this can be used with FILTFILT

if length(mu)>3*FIROrder
mu      = filtfilt(b, 1, mu);
S		= fft(mu,nfft); % Yes, fourier transform in the digital age
S		= abs(S); % we are only interested in the magnitude
n		= numel(S);
S		= S./n*2;
f		= (0:n-1)*Fs/nfft; % Frequency (Hz)
P		= smooth(20*log10(S),6); % determine Power (dB re V), and smooth for graphical purposes
figure(1)
subplot(131)
semilogx(f,P,'r-','LineWidth',2);

legend('Actual','Filtered');

Impulse		= real(ifft(S)); % impulse response
nImp		= numel(Impulse);
t			= (1:nImp)./Fs*1000;

figure(1)
subplot(132)
indx = 1:nImp/2;
plot(t(indx),Impulse(indx),'r-','LineWidth',2)
end
print('-depsc','-painter',mfilename);


function [dat,mlog,exp,chan] = pa_readhrtf(hrtffile)
% HRTF = PA_READHRTF(HRTFFILE)
%
% This version of pa_readhrtf works with different-length trials

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
