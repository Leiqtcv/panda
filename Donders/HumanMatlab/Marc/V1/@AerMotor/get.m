%
% get property: value = get(object, propertyName)
%
function value = get(A,propertyName)

    switch propertyName
        case 'handle'
            value = A.handle;
        case 'speed'
            value = A.speed;
        case 'position'
            value = A.position;
        case 'target'
            value = A.target;
        case 'error'
            value = A.error;
        case 'wait'
            value = A.wait;
        case 'busy'
            value = A.busy;
    end