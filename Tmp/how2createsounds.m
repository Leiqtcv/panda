function how2createsounds


%% Generate sound
% pa_gensweep - Schroeder sweep
% pa_gengwn - Gaussian white noise from random time trace
% pa_gengwnflat - Gaussian white noise from random phase spectrum
% pa_gentone - Pure tone
% pa_genripple - generate ripple

%% Filter
% pa_highpass
% pa_lowpass
% pa_equalizer

%% Ramp
% pa_ramp

%% 20 ms level ramp
% pa_levelramp
% % Envelope to remove click
% if NEnvelope>0
%     stm       = pa_envelope(stm, NEnvelope);
% end
% %Reshape
% stm             = stm(:)';

%% save
% pa_writewav

%% Save
% if strcmpi(sv,'y');
% 	wavfname = ['V' num2str(vel) 'D' num2str(dens) '.wav'];
% 	pa_writewav(snd,wavfname);
% end