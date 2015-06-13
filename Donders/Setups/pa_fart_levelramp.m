function X = pa_fart_levelramp(X, N)
% PA_FART_LEVELRAMP(X)
%
% Adds 20 ms of zeros to start and end of a sound signal. This is required
% because of a peculiarity of the hoop/sound localization setup: the sound
% level is controlled by the second DA output of the RP2.1, and to prevent
% a strong onset pulse of the speaker, a smooth transient ramp is
% programmed.
%

% 2013 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

if nargin<2
	Fs		= 48828.125; % Freq (Hz)
	N	= round(20/1000*Fs); % 20 ms
end



X		= X(:);
Nzero	= zeros(N,1); %This will create a vector with N zeros
X		= [Nzero; X; Nzero]; %This pre- and ap-pends the zerovector to the signal

