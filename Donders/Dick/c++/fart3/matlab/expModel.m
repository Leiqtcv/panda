function getExpModel(hObject)
data = guidata(hObject);
    
data.exp.names(1,:)  = {'stimBar' 'barDown'};
data.exp.names(2,:)  = {'stimLed' 'fix'};
data.exp.names(3,:)  = {'stimLed' 'tar'};
data.exp.names(4,:)  = {'stimLed' 'dim'};
data.exp.names(5,:)  = {'stimbar' 'barHigh'};
data.exp.names(6,:)  = {'stimbar' 'barUp'};
data.exp.names(7,:)  = {'stimRew' 'Correct'};
data.exp.names(8,:)  = {'stimRew' 'Pressed'};

data.exp.timing(1,:) = [0   0   0   0 1];	    % Ton Toff event
data.exp.timing(2,:) = [1   0   1 400 2];
data.exp.timing(3,:) = [2   0   2 400 3];
data.exp.timing(4,:) = [3   0   3 400 0];
data.exp.timing(5,:) = [1   0   3 100 0];
data.exp.timing(6,:) = [3 100   3 400 4];
data.exp.timing(7,:) = [4   0   4 100 0];
data.exp.timing(8,:) = [1   0   1  50 0];

data.exp.param(1,:)  = [1 1 1 0]; % bit edge up
data.exp.param(2,:)  = [0 0 1 7]; % fix x y red intensity
data.exp.param(3,:)  = [3 3 1 7]; % tar
data.exp.param(4,:)  = [3 3 1 5]; % dim
data.exp.param(5,:)  = [1 0 1 0]; % bit level high
data.exp.param(6,:)  = [1 1 0 0]; % bit edge down
data.exp.param(7,:)  = [2 0 0 0]; % bit time, reward for release 
data.exp.param(8,:)  = [2 0 0 0]; % bit time, reward for press

data.exp.result(1,:) = [0 0 0];   % state Ton Toff
data.exp.result(2,:) = [0 0 0];   %		state = 2, not started
data.exp.result(3,:) = [0 0 0];   %               1, running
data.exp.result(4,:) = [0 0 0];   %               0, ready
data.exp.result(5,:) = [0 0 0];   %              -1, error
data.exp.result(6,:) = [0 0 0];
data.exp.result(7,:) = [0 0 0];
data.exp.result(8,:) = [0 0 0];

guidata(hObject, data);
end