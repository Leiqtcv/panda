function hoop = pa_fart_tdt_hoophome(hoop)
% HOOP = PA_FART_TDT_HOOPHOME
%
% Home hoop in FART setup
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
disp('Homing Hoop');
hoop = Aer_cmd(hoop, AerMoveHome);
busy = true;
while busy
    hoop = Aer_cmd(hoop, AerMoveTestDone);
    busy = get(hoop,'busy');
end
pause(.5);