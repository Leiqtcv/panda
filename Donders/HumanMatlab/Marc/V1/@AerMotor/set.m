%
% set property object = set(object, propertyName, value)
%
function A = set(A,propertyName, value)

    switch propertyName
        case 'handle'
            A.handle = value;
        case 'speed'
            A.speed = value;
        case 'position'
            A.position = value;
        case 'target'
            A.target = value;
        case 'error'
            A.error = value;
        case 'wait'
            A.wait = value;
        case 'busy'
            A.busy = value;
    end