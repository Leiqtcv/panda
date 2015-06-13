%
% constructor of class RA16
%
function [module error] = RA16(number,circuit)
    error  = 0;
    module = actxcontrol('RPco.x',[1 1 1 1]);
    connect = module.ConnectRA16('GB',number);
    if (connect) 
        module.reset;
        load = module.LoadCOF(circuit);
        if (load)
            module.Run();
            module.SetTagVal('Run',0);
        else
            error = -2;
        end
    else
        error = -1;
    end
end

