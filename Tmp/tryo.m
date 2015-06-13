%% Creating frequency bands, 0.2-14 kHz spaced 1/6 octave
F1			= 200;					%beginning frequency hz
Fsig		= 4000;					%signal frequency (Hz)
Nfreq		= 38;					%number of frequency bands
Nmask		= 16;					%number of tones in masker
freqband	= pa_oct2bw(F1,(0:Nfreq-1)*1/6);	%frequency band, 0.2-14 kHz spaced 1/6 octave
protband	= pa_oct2bw(Fsig,[-1/3 1/3]);		%create protected band (1/3 octave above/below Fsig)
sel			= freqband<protband(1) | freqband>protband(2);
freqband	= freqband(sel); 
Nfreq		= numel(freqband);			%Nfreq - protected band
indx		= randperm(Nfreq,Nmask);	%selecting (16) maskers from Nfreq
Fmask		= sort(freqband(indx));		%retrieving corresponding frequencies from indx (masker frequencies) [Hz]
