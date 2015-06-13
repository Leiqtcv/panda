function N = getbw(F1,F2)
% N = GETBW(F1,F2)
%
% Determine the bandwidth of a narrowband sound in octaves
% N : bandwidth (octaves)
% F1: low frequency (Hz)
% F2: high frequency (Hz)
Y = F2/F1;
N = log2(Y);