%
% constructor of class AerMotor
%
function A = AerMotor()
    motor_globals;
    A.handle   =    -1;
    A.speed    = 10000;
    A.position =     0;       
    A.target   =     0;   
    A.error    =     0;  
    A.wait     =     0;
    A.busy     =     0;
    A = class(A, 'AerMotor');
end