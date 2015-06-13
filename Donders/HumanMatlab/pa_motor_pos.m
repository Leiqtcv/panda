function hoop = pa_motor_pos(hoop,pos)
% HOOP = PA_MOTOR_POS(HOOP,POS)
%
% Position hoop in FART setup
%
% Use:
%
% >> hoop = pa_motor_init;
% >> hoop = pa_motor_home(hoop);
% >> hoop = pa_motor_pos(hoop,pos);
%
% See also PA_MOTOR_HOME, PA_MOTOR_POS, PA_MOTOR_INIT, PA_MOTOR_GLOBALS

% Dick Heeren/Tom/Denise
% 2012 Modified: Marc van Wanrooij
% if nargin<1
% 	pos = 0;
% end
pa_motor_globals;
str = ['move -> ' num2str(pos)];
disp(str);
hoop = Aer_cmd(hoop, AerMoveAbs,pos);
busy = 1;
while (busy == 1)
    hoop = Aer_cmd(hoop, AerMoveTestDone);
    busy = get(hoop,'busy');
end