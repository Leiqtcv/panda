function t

clear all
close all

% cd('E:\DATA\Head Related Transfer Functions\SpkChar');
Fs		= 50000;
HiCut	= 20000;
LoCut	= 500;
Nyq		= Fs/2;


% hrtf		= pa_readhrtf('SpkChar2.hrtf');
% x			= squeeze(hrtf(1380:21000,:,1));
% nfft		= 2^(nextpow2(length(x)));
% % Take fft, padding with zeros so that length(fftx) is equal to nfft
% S			= fft(x,nfft);
% S			= abs(S);

%% Files
fname	=  'E:\MATLAB\PANDA\Donders\Setups\supplementary\fartspeakers-sweep-2013-02-12.hrtf';
fname = pa_fcheckexist(fname);

d		= fname;
grphFlag = true;
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
F	= NaN(nSnds,1);
A	= F;
F2	= F;
A2	= F;
col = summer(nSnds);
sweep = struct([]);

for ii = nSnds:-1:1
	x			= hrtf(ii).hrtf;
	[~,~,wave] = pa_sweep2spec(x,wav,1);
	sweep(ii).wave = wave;
	sweep(ii).location = Loc(ii);
	sweep(ii).amplitude = Amp(ii);
end
% keyboard
sel = ismember([sweep.amplitude],40:10:60);
mu		= mean([sweep(sel).wave],2);
mu		= mu-mean(mu);
nfft	= 2^(nextpow2(length(mu)));
S		= fft(mu,nfft);
S		= abs(S);
% S(S<0.3)=0.1;
% S		= S-mean(S);
% S		= S./std(S);
% S = S-20
n		= numel(S);
S		= S./n*2;
f		= (0:n-1)*Fs/nfft;

P = smooth(20*log10(S),6);
figure(1)
subplot(131)
semilogx(f,P,'k-','LineWidth',2);
set(gca,'XTick',pa_oct2bw(1000,-2:7),'XTickLabel',pa_oct2bw(1000,-2:7));
axis square;
box off
title('Power spectrum');
xlabel('Frequency (Hz)');
ylabel('Power (dB re V)');
xlim([250 20000]);
ylim([-80 -20])

%% Initialization
FIROrder = 850;
HannSize = FIROrder-1; %% size of hanning window
if ~rem(HannSize,2),    % Gotta be odd
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
xlabel('Time (ms)');
ylabel('Amplitude (au)');
axis square;
box off
xlim([-0.5 6]);
title('Impulse response');
pa_verline;
%%
nI			= length(Impulse);
[~, indx]	= max(Impulse);
AugImp		= [Impulse Impulse];
if indx<ceil(HannSize/2),
    indx		= indx + nI;
end
CutImp		= AugImp((indx-HalfHann):(indx+HalfHann));
CutImp		= CutImp.*HannWindow; % apply Hanning window
Spec		= fft(CutImp); % get complex spectrum
invSpec		= 1./Spec; % inverse spectrum
Mag			= abs(invSpec(1:(HalfHann+1))); % magnitude
RelFreq		= (0:HalfHann)/(HalfHann); % frequencies

indxLo			= find(RelFreq<LoCut/Nyq);
indxLo			= indxLo(end);
indxHi			= find(RelFreq>HiCut/Nyq);
indxHi			= indxHi(1);
t				= indxLo-(0:indxLo-1);
t				= t/indxLo;
Mag(1:indxLo) = Mag(indxLo);

Mag(1:indxLo)	= Mag(1:indxLo).*(1+cos(pi*t))/2;
t				= (indxHi:length(Mag)) - indxHi;
t				= t/max(t);
Mag(indxHi:end) = Mag(indxHi);
Mag(indxHi:end) = Mag(indxHi:end).*(1+cos(pi*t))/2;

Mag = Mag./max(Mag);
Freq = RelFreq*Fs/2;

b = fir2(FIROrder, RelFreq, Mag);

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

pa_datadir;
save('equalizer','b');

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
