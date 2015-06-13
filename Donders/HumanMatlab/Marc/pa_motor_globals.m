% PA_MOTOR_GLOBALS
%
% Some 'global' (i.e. local) variables for hoop instructions in the FART
% setup.
%
% Used in:
%
% >> hoop = pa_hoopinit;
% >> hoop = pa_hoophome(hoop);
% >> hoop = pa_hooppos(hoop);
%
% See also PA_HOOPHOME, PA_HOOPPOS, PA_MOTORGLOBALS

% Dick Heeren/Tom/Denise
% 2012 Modified: Marc van Wanrooij
AerNoError       = 0;             
AerInit          = 1;       % -1
AerMoveHome      = 2;       % -2
AerMoveAbs       = 3;
AerMoveEnable    = 4;
AerMoveDisable   = 5;
AerMoveWaitDone  = 6;
AerMoveTestDone  = 7;
AerGetPosition   = 8;
AerShowInfo      = 9;
