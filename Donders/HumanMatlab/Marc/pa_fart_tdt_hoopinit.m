function hoop = pa_fart_tdt_hoopinit
% HOOP = PA_FART_TDT_HOOPINIT
%
% Initialization of hoop in FART setup
%
% Use:
%
% >> hoop = pa_fart_tdt_hoopinit;
% >> hoop = pa_fart_tdt_hoophome(hoop);
% >> hoop = pa_fart_tdt_hooppos(hoop);
%
% See also PA_FART_TDT_HOOPHOME, PA_FART_TDT_HOOPPOS, PA_FART_TDT_HOOPINIT, PA_FART_TDT_MOTORGLOBALS

% Dick Heeren/Tom/Denise
% 2012 Modified: Marc van Wanrooij

pa_fart_tdt_motor_globals;
disp('Initializing Hoop');
hoop = AerMotor();
hoop = Aer_cmd(hoop, AerInit, 150000);
pause(.1)

