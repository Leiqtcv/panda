function hoop = pa_motor_init
% HOOP = PA_MOTOR_INIT
%
% Initialization of hoop in sound localization setup
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
disp('Initializing Hoop');
hoop = AerMotor();
hoop = Aer_cmd(hoop, AerInit, 150000);
pause(.1);

