% function hoop = pa_fart_tdt_hooppos(hoop,pos)
% HOOP = PA_FART_TDT_HOOPPOS
%
% Position hoop in FART setup
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