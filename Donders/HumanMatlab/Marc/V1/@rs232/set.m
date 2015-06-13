%
% set property object = set(object, propertyName, value)
%
function A = set(A,propertyName, value)

    switch propertyName
        case 'baudrate'
            A.baudrate = value;
        case 'timeout'
            A.timeout = value;
    end