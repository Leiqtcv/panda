%
% get property: value = get(object, propertyName)
%
function value = get(A,propertyName)

    switch propertyName
        case 'connected'
            if (A.connected)
                value = 'true';
            else
                value = 'false';
            end
        case 'baudrate'
            value = A.baudrate;
        case 'timeout'
            value = A.timeout;
    end