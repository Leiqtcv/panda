%
% constructor of class RP2
%
% number: number of unit
function [module error] = RP2(number,circuit)
    error  = 0;
    module = actxcontrol('RPco.x',[1 1 1 1]);
    connect = module.ConnectRP2('GB',number);
    if (connect) 
        module.reset;
        load = module.LoadCOF(circuit);
        if (load)
            module.Run();
        else
            error = -2;
        end
    else
        error = -1;
    end
end
