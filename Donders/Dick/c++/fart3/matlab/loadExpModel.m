function loadExpModel(hObject)
data = guidata(hObject);
%-----------------------------------------------------------------------
data.exp.BarBit    = 1;		% in
data.exp.RewardBit = 1;       % out
%-----------------------------------------------------------------------
data.exp.names(1,:)  = {'stimBar' 'barD'};    % bar down
data.exp.names(2,:)  = {'stimLed' 'fix'};	    % fixation led
data.exp.names(3,:)  = {'stimLed' 'tar'};     % target led
data.exp.names(4,:)  = {'stimLed' 'dim'};     % dim led (=target)
data.exp.names(5,:)  = {'stimbar' 'barL'};    % bar low
data.exp.names(6,:)  = {'stimbar' 'barU'};    % bar up
data.exp.names(7,:)  = {'stimRew' 'corr'};    % correct trial
data.exp.names(8,:)  = {'stimRew' 'press'};   % pressed
%-----------------------------------------------------------------------
%                       Ton     Toff  event
data.exp.timing(1,:) = [0   0   0   0 1];     % bar, press to start
data.exp.timing(2,:) = [1   0   1 400 2];     % fixate
data.exp.timing(3,:) = [2   0   2 400 3];     % target
data.exp.timing(4,:) = [3   0   3 400 0];     % dimming
data.exp.timing(5,:) = [1   0   3 100 0];     % bar, keeps pressed
data.exp.timing(6,:) = [3 100   3 400 4];     % bar, release
data.exp.timing(7,:) = [4   0   4 100 0];     % rew, correct trial
data.exp.timing(8,:) = [1   0   1  50 0];     % rew, start trial
%-----------------------------------------------------------------------
data.exp.params(1,:) = [1 1 0 0];             % bar:bit edge down
data.exp.params(2,:) = [0 0 1 7];             % fix:ring spoke color int
data.exp.params(3,:) = [3 3 0 7];             % tar:(green)
data.exp.params(4,:) = [3 3 0 5];             % dim:(green)
data.exp.params(5,:) = [1 0 0 0];             % bar:bit level low
data.exp.params(6,:) = [1 1 1 0];             % bar:bit edge up
data.exp.params(7,:) = [2 0 0 0];             % PIO-out:bit  
data.exp.params(8,:) = [2 0 0 0];             % PIO-out:bit 
%-----------------------------------------------------------------------
data.exp.results(1,:)= [0 0 0];		    % status, Ton, Toff
data.exp.results(2,:)= [0 0 0];		    % 	status 2 = init
data.exp.results(3,:)= [0 0 0];		    % 	status 1 = run
data.exp.results(4,:)= [0 0 0];		    % 	status 0 = ready
data.exp.results(5,:)= [0 0 0];		    % 	status 9 = error
data.exp.results(6,:)= [0 0 0];
data.exp.results(7,:)= [0 0 0];
data.exp.results(8,:)= [0 0 0];

guidata(hObject, data);
end
