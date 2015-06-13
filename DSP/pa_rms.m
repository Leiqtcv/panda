function RMS = pa_rms(X)
% Determine RMS-value of signal X
%
% RMS = root-mean-square;
%

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com
RMS = sqrt(mean(X.^2));
