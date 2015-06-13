function [xOut] = HAtemporalsmearing(xIn, Fs2)

nFFT		= 256;   % Size of the FFT
hf			= 0.25;
Fs          = 16000;
fftStep = Fs/nFFT;
fr = fftStep:fftStep:fftStep*(nFFT/2); % f0(110) = 6875 Hz (Moore)

xIn = resample(xIn,Fs,Fs2);

%% define auditory filters

% healthy auditory filters:
pp = ones(1, nFFT/2);
ERB = ones(1, nFFT/2);
pNH = ones(nFFT/2, nFFT/2);
for ii = 1:length(fr)
    ERB(ii) = ERB(ii).*24.7 * (0.00437 * fr(ii) + 1);
    pp(ii) = (4 * fr(ii)) / ERB(ii);
    pNH(ii,:) = pNH(ii,:) * pp(ii);
end

% hearing impaired filters
bL = 6; % broadening factor lower end
bU = 3; % broadening factor upper end
pL = pp/bL;
pU = pp/bU;

% define filter for each frequency
g = zeros(nFFT/2, nFFT/2);
pHI = ones(nFFT/2, nFFT/2);
for ii = 1:length(fr)
    f0 = fr(ii);
    g(ii,:) = abs((fr - f0) ./ f0); % deviation from center frequency divided by center freq

    pHI(ii, 1:ii) = pHI(ii, 1:ii)*pL(ii);
    pHI(ii, ii+1:end) = pHI(ii, ii+1:end)*pU(ii);
end

WNH = (1+pNH.*g).*exp(-pNH.*g);
WHI = (1+pHI.*g).*exp(-pHI.*g);

% normalise by ERB
for ii = 1:length(fr)
    WNH(ii,:) = WNH(ii,:) ./ ERB(ii);
    WHI(ii,:) = WHI(ii,:) ./ ERB(ii);
end

Wsmeared = inv(WNH) * WHI; % smeared, inverse to correct for NH listeners
Wsmeared(110:end, :) = 0; % higher compoments are set to 0

%% ======== STFT
s = length(xIn);
w = nFFT;
f = nFFT;
h = nFFT*hf;
if rem(w, 2) == 0   % force window to be odd-len
  w = w + 1;
end

win = hanning(f/2)';

% pre-allocate output array
d1 = zeros((f/2), 1+fix((s-f)/h));
d2 = zeros((f/2), 1+fix((s-f)/h));
p2 = zeros((f/2), 1+fix((s-f)/h));
c = 1;

for b = 0:h:(s-f) % over time
  u = win.*xIn((b+1):(b+f/2));
  u = [zeros(1,length(win)/2) u zeros(1,length(win)/2)];
  t = fft(u);
  
  powert = t.*conj(t);
  phase = (angle(t(1:(f/2)))); % atan2(imag(t),real(t))
  p2(:,c) = phase;
  
  d1(:,c) = powert(1:(f/2))';
  d2(:,c) = Wsmeared*d1(:,c); % matrix multiplication, formula (4, Moore)
  
%   if (b == h*300)
%       figure(6)
%       plot(fr, d1(:,c)); hold all
%       plot(fr, d2(:,c))
%       legend('Original', 'Smeared')
%       xlabel('Frequency')
%       ylabel('Power')
%   end
  
%     fny = Fs/2;
%     co = 500 / fny;
%     [b1 a] = butter(3, co, 'low'); % order, cut-off
%     testd = filtfilt(b1, a, d1(:,c));
    
  c = c+1;
end;

d = sqrt(d2).*exp(i*(p2)); % add original phase back again, Euler's formula

% ======== Inverse STFT
s = size(d);
ftsize = nFFT;

cols = s(2);
xlen = ftsize + cols * (h);
xf = zeros(1,xlen);

for b = 0:h:(h*(cols-1)) % loop over time
  ft1 = d(:,1+b/h)'; % freq information lower half
  ft = [ft1, 0, fliplr(conj(ft1(2:end)))]; % freq information lower + upper half
  
%   if (b == h*200)
%       figure(60)
%       plot(fr, ft1); hold all
%       legend('Smeared')
%       xlabel('Frequency')
%       ylabel('Power')
%   end
  
  px = real(ifft(ft));
  xf((b+1):(b+ftsize)) = xf((b+1):(b+ftsize))+px; % scale back to same original component ?
end;

xOut    = xf(1:length(xIn));
xOut    = xOut * rms(xIn) / rms(xOut);
xOut    = resample(xOut, Fs2, Fs);
size(xOut)
%%

% snd = xIn;
% pt = 2^nextpow2(length(snd));   % for fastest fft, zeropadding to next power of 2
%     fftxSym = fft(snd, pt);         % result is completely symmetric (both real and imaginar parts)
%     nfft = length(fftxSym);
%     NumUniquePtsSym = ceil((nfft)); 
%     NumUniquePts = ceil((nfft)/2);
%     fftx = fftxSym(1:NumUniquePts); % take first half to filter
%     freqSym = (0:NumUniquePtsSym-1)*Fs/nfft; 
%     freq = (0:NumUniquePts-1)*Fs/nfft;
%     
%     figure(2)
%     subplot(2,1,1)
%     plot(freq, fftx); hold all
% fftxIn = fftx;
%     
% snd = xOut;
% Fs = Fs2;
% % fny = Fs/2;
% % co = 500 / fny;
% % [b a] = butter(3, co, 'low'); % order, cut-off
% % snd = filtfilt(b, a, snd);
% pt = 2^nextpow2(length(snd));   % for fastest fft, zeropadding to next power of 2
%     fftxSym = fft(snd, pt);         % result is completely symmetric (both real and imaginar parts)
%     nfft = length(fftxSym);
%     NumUniquePtsSym = ceil((nfft)); 
%     NumUniquePts = ceil((nfft)/2);
%     fftx = fftxSym(1:NumUniquePts); % take first half to filter
%     freqSym = (0:NumUniquePtsSym-1)*Fs/nfft; 
%     freq2 = (0:NumUniquePts-1)*Fs/nfft;
%     
%     figure(2)
%     subplot(2,1,2)
%     %plot(freq, fftxIn); hold all
%     plot(freq2, fftx); hold all
%     
%     
% %%   
% figure(4)
% subplot(2,1,1)
% nFreq	= 128;
% FreqNr	= 0:1:nFreq-1;
% % F0		= 2^(2*log2(250));
% F0		= pa_oct2bw(250,0);
% df		= 1/20;
% Freq	= F0 * 2.^(FreqNr*df);
% snd = xIn;
% nsamples	= length(snd);
% t			= nsamples/Fs*1000;
% dt			= 5;
% nseg		= t/dt;
% segsamples	= round(nsamples/nseg); % 12.5 ms * 50 kHz = 625 samples
% noverlap	= round(0.7*segsamples); % 1/3 overlap
% window		= segsamples+noverlap; % window size
% nfft		= 10000;
% spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');
% cax = caxis;
% caxis([0.7*cax(1) 1.1*cax(2)])
% ylim([min(Freq) max(Freq)])
% set(gca,'YTick',[0.5 1 2 4 8 16]*1000);
% set(gca,'YTickLabel',[0.5 1 2 4 8 16]);
% set(gca,'YScale','log');
% drawnow
% 
% subplot(2,1,2)
% snd = xOut; Fs = Fs2;
% nsamples	= length(snd);
% t			= nsamples/Fs*1000;
% dt			= 5;
% nseg		= t/dt;
% segsamples	= round(nsamples/nseg); % 12.5 ms * 50 kHz = 625 samples
% noverlap	= round(0.7*segsamples); % 1/3 overlap
% window		= segsamples+noverlap; % window size
% nfft		= 10000;
% spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');
% cax = caxis;
% caxis([0.7*cax(1) 1.1*cax(2)])
% ylim([min(Freq) max(Freq)])
% set(gca,'YTick',[0.5 1 2 4 8 16]*1000);
% set(gca,'YTickLabel',[0.5 1 2 4 8 16]);
% set(gca,'YScale','log');
% drawnow
%     