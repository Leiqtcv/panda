function hoop = pa_motor_home(hoop)
% HOOP = PA_MOTOR_HOME
%
% Home hoop in FART setup
%
% Use:
%
% >> hoop = pa_motor_init;
% >> hoop = pa_motor_home(hoop);
% >> hoop = pa_motor_pos(hoop);
%
% See also PA_MOTOR_HOME, PA_MOTOR_POS, PA_MOTOR_INIT, PA_MOTOR_GLOBALS


% Dick Heeren/Tom/Denise
% 2012 Modified: Marc van Wanrooij

pa_motor_globals;
disp('Homing Hoop');
hoop = Aer_cmd(hoop, AerMoveHome);
busy = true;
while busy
    hoop = Aer_cmd(hoop, AerMoveTestDone);
    busy = get(hoop,'busy');
end
pause(.5);