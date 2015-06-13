function pa_gensweep_example
% Generate Schroeder Sweep
%

%% Initialization
Nsample  = 2^10; %1024 samples
Fstart  = 0; % Start-frequency Hz
Fs     = 50000; % sample-frequency
Fstop   = Fs; % Hz

%% Obtain single sweep
% Lowpeak generates a sweep of 2N samples for
% a magitude spectrum of N samples
N           = round(0.5*Nsample); % samples
% OK, now let's fill that magnitude spectrum
Magnitude   = zeros(1,N); % magnitude
nstart      = max(1,round(N*Fstart/Fs));
nstop       = min(N,round(N*Fstop/Fs));
Magnitude(nstart:nstop) = ones(1,(nstop-nstart+1));
x           = lowpeak(Magnitude); % Determine phase response with sub-function

%% Peak factor
pf = pa_peakfactor(x);

%% Graphics
close all
figure
t = (1:length(x))/Fs*1000;
subplot(223)
plot(t,x,'k-')
ylabel('Amplitude (au)');
xlabel('Time (ms)');
xlim([min(t) max(t)]);
str = ['Peak Factor = ' num2str(pf,3)];
h	= pa_text(0.5,0.9,str); set(h,'HorizontalAlignment','center'); % Set the text and center it.


%% Spectrogram Time-Frequency representation
subplot(224)
nfft		= 2^11; % number of fft points
window		= 2^4; % resolution
noverlap	= 2^2; % smoothing
spectrogram(x,window,noverlap,nfft,Fs,'yaxis');
set(gca,'Yscale','linear','YTick',(0:5:20)*1000,'YTickLabel',0:5:20);
caxis([-100 -60])
ylim([0 20000])
ylabel('Frequency (kHz)');


%% Determine spectrum, see also PA_GETPOWER
% Time vector of 1 second
% Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
nfft			= 2^(nextpow2(length(x)));
% Take fft, padding with zeros so that length(fftx) is equal to nfft
fftx			= fft(x,nfft);
% Calculate the numberof unique points
NumUniquePts	= ceil((nfft+1)/2);
% FFT is symmetric, throw away second half
fftx			= fftx(1:NumUniquePts);
% Take the magnitude of fft of x and scale the fft so that it is not a function of
% the length of x
mx				= abs(fftx)/length(x);
ph				= angle(fftx);
% Take the square of the magnitude of fft of x -> magnitude 2 power
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
mx		= 20*log10(mx); % Power (dB)
sel		= isinf(mx);
mx(sel) = min(mx(~sel));


%% Graphics of spectrum
subplot(221) % same as subplot(2,2,1)
plot(f,mx,'k-','LineWidth',2); % Power
set(gca,'XTick',(0:5:20)*1000,'XTickLabel',0:5:20);
title('Power Spectrum');
xlabel('Frequency (kHz)');
ylabel('Power (dB)');
xlim([0 25]*1000);

subplot(222)
plot(f,unwrap(ph),'k-','LineWidth',2); % Phase needs to be unwrapped to observe systematic changes
hold on
set(gca,'XTick',(0:5:20)*1000,'XTickLabel',0:5:20);
title('Phase Spectrum');
xlabel('Frequency (kHz)');
ylabel('Phase');

xlim([0 25]*1000);
for ii = 1:4
	subplot(2,2,ii)
	axis square;
	box off
	pa_text(0.1,0.9, char(96+ii));
end

%% Print
cd('C:\DATA'); % See also PA_DATADIR
print('-depsc','-painter',mfilename); % I try to avoid bitmaps, 
% so I can easily modify the figures later on in for example Illustrator
% For web-and Office-purposes, I later save images as PNG-files

function Signal = lowpeak(Magnitude)
%  FUNCTION X = LOWPEAK (M)
%
%  DESCRIPTION
%    Returns the time signal X with minimized peakfactor
%    given a frequency magnitude response M. The algorithm is
%    extracted from Schroeder et al (1970).
%
%  ARGUMENT
%    M  - frequency magnitude response containing the frequency
%         response in equidistant bins which correspond to frequency
%         0 to the Nyquist frequency (best to make the length of M
%         a power of 2). The algorithm calculates a frequency phase
%         response that together with M, yields a low-peak time signal.
%
%  RETURN VALUE
%    X  - Time signal with minimized peak factor
%
%  EXAMPLE
%    >> sweep = lowpeak (ones(1,512));
%
Nbin       = length(Magnitude);
TotalPower = sum(Magnitude.^2);
NormFactor = 1.0/TotalPower;
TwoPi      = 2*pi;
Phi        = 0.0;
Power      = 0.0;
Spectrum   = zeros (1, Nbin);
for j=1:Nbin
	Spectrum(j) = Magnitude(j) * exp (1i*Phi);
	Power		= Power + NormFactor*Magnitude(j).^2;
	Phi			= Phi - TwoPi*Power;
end;
Spectrum		= [Spectrum -conj([Spectrum(1) Spectrum((Nbin):-1:2)])];
Signal			= imag(ifft(Spectrum));

function pf = pa_peakfactor(y)
% PF = PEAKFACTOR(Y)
%
% Obtain peakfactor PF from signal Y

Amax = max(y); % minimum amplitude
Amin = min(y); % maximum amplitude
Arms = sqrt(mean(y.^2)); % or Arms = pa_rms(y), root-mean-square
pf  = (Amax-Amin)./(2*sqrt(2)*Arms);
