function gensound_poorspectra
% gensound_poorspectra
%
% This will generate sound spectra we use for the following study
% "Localizing spectrally poor acoustic signals.

%% Create sounds
%% BB
close all
for ii = 0:99
    dur		= 0.15;
		snd	= pa_gengwn(dur);

			subplot(211);
	plot(snd)
	if ii ==1
		subplot(212)
		pa_getpower(snd,50000,'display',1);
		drawnow
% 				xlim([1000 10000])
% 		return
	end
%     snd		= pa_gengwn (dur,10,500,20000);
	snd		= pa_equalizer(snd);
	snd		= pa_ramp(snd);
	snd		= pa_fart_levelramp(snd);
	

    str		= num2str(ii+300,'%03i');
    fname   = ['snd' str '.wav'];
    pa_writewav(snd,fname);
end

%% "Poor" spectra
close all
for ii = 0:99
    dur		= 0.15;
%     snd		= pa_gengwn (dur,10,500,5500);
	snd	= pa_gengwn(dur);
snd = pa_lowpass(snd,5500);
	
	snd		= pa_equalizer(snd);
	snd		= pa_ramp(snd);
	snd		= pa_fart_levelramp(snd);
	
	subplot(211);
	plot(snd)
	if ii ==1
		subplot(212)
		pa_getpower(snd,48828.125,'display',1);
		drawnow
		% 		xlim([1000 10000])
% 		return
	end
    str		= num2str(ii+100,'%03i');
    fname   = ['snd' str '.wav'];
    pa_writewav(snd,fname);
end

%% Notch
close all
for ii = 0:99

    dur		= 0.15;
% 	pa_gengwn(Dur, order, Fc, Fn, Fh, varargin)
    snd1	= pa_gengwn(dur);
    snd2	= pa_gengwn(dur);
	
	snd1 = pa_lowpass(snd1,4000);
	snd2 = pa_highpass(snd2,5500);
	
			subplot(311)
plot(snd1);

			subplot(312)
plot(snd2);
	snd		= snd1+snd2;
	if ii ==1
		subplot(313)
		pa_getpower(snd,48828.125,'display',1);
		drawnow
% 		xlim([1000 10000])
% 		return
	end
	snd		= pa_equalizer(snd);
	snd		= pa_ramp(snd);
	snd		= pa_fart_levelramp(snd);
	

	
    str		= num2str(ii+200,'%03i');
    fname   = ['snd' str '.wav'];
    pa_writewav(snd,fname);
end
