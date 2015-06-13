function [sndSimHA2] = HAsimulation(snd, sndSimCI, fs, disp)

fny = fs/2;
co = 500 / fny;

[b a] = butter(4, co, 'low'); % order, cut-off
%freqz(b, a, 2^10, fs);

%sndHA = filter(b, a, snd);
sndHA = filtfilt(b, a, snd);

% 2: scale <=500Hz HA rms to <=500Hz CI rms
% fr = 2000;
% sndSimHA500 = my_fft(sndHA, 44100, fr);
% sndSimCI500 = my_fft(sndSimCI, 44100, fr);
% sndSimHA2      = sndHA * rms(sndSimCI500) / rms(sndSimHA500);
% sndSimHA500b = my_fft(sndSimHA2, 44100, fr);
% [rms(sndSimHA500b) rms(sndSimCI500)]
% rms(sndSimHA2)
sndSimHA2 = sndHA;


% FFT
if (disp == 1)
    pt = 2^nextpow2(length(snd));   % for fastest fft, zeropadding to next power of 2
    fftxSym = fft(snd, pt);         % result is completely symmetric (both real and imaginar parts)
    nfft = length(fftxSym);
    NumUniquePtsSym = ceil((nfft)); 
    NumUniquePts = ceil((nfft)/2);
    fftx = fftxSym(1:NumUniquePts); % take first half to filter
    freqSym = (0:NumUniquePtsSym-1)*fs/nfft; 
    freq = (0:NumUniquePts-1)*fs/nfft;
    % FFT
    pt = 2^nextpow2(length(sndHA));   % for fastest fft, zeropadding to next power of 2
    fftxSym = fft(sndHA, pt);         % result is completely symmetric (both real and imaginar parts)
    nfft = length(fftxSym);
    NumUniquePtsSym = ceil((nfft)); 
    NumUniquePts = ceil((nfft)/2);
    fftxHA = fftxSym(1:NumUniquePts); % take first half to filter
    freqSym = (0:NumUniquePtsSym-1)*fs/nfft; 
    freqHA = (0:NumUniquePts-1)*fs/nfft;

%     figure(2)
%     plot(freq, fftx); hold all
%     plot(freqHA, fftxHA)
end

