function B =rm_spkA_strfshiftmax(strf,kshift)
% [B,SHIFT] = PA_SPK_STRFSHIFTMAX(STRF)
%
% Shift the peak in the STRF to a central frequency.
%
%  Assumptions: 
% - STRF with 2.5 octave spectral width
% - 10 frequencies
%
% See also PA_SPK_RIPPLE2STRF, PA_SPK_PREDICT

% 2012 Marc van Wanrooij 
% e-mail: marcvanwanrooij@neural-code.com
% Original by: John van Opstal

% r			= rms(strf,2);
% [~,indx]	= maxpair(r);

B			= pa_spk_shiftmatc(strf,kshift);

