%
% constructor of class zBus
%
% number: number of unit
function [module error] = ZBUS(nRacks)
    error  = 0;
    module = actxcontrol('ZBUS.x',[1 1 1 1]);
    connect = module.ConnectZBUS('GB');
    if (connect == 0) 
        error = -1;
    else
        for i=1:nRacks
            if (module.HardwareReset(i) ~= 0)
                error = -2;
            end
        end
        if (error == 0)
            for i=1:nRacks
                if (module.FlushIO(i) ~= 0)
                    error = -3;
                end
            end
        end
    end
end
