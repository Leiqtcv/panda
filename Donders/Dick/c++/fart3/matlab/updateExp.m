
function updateExp(hObject)
    data = guidata(hObject);

    data.exp.timing(2,4) = data.save11.Fixation;
    data.exp.timing(3,4) = data.save11.TargetFixed + data.save11.Random;
    data.exp.timing(4,4) = data.save11.TargetChanged;
    data.exp.timing(7,4) = data.save11.RewardDuration * data.save15.PressFactor;
    data.exp.timing(8,4) = data.save11.RewardDuration; 

    data.exp.params(2,3) = data.save12.FixRed;     % fix -       color, intensity
    data.exp.params(2,4) = data.save12.FixIntens;
    data.exp.params(3,1) = data.save12.TarRing;    % tar - X, Y, color, intensity
    data.exp.params(3,2) = data.save12.TarSpoke; 
    data.exp.params(3,3) = data.save12.TarRed;   
    data.exp.params(3,4) = data.save12.TarIntens;
    data.exp.params(4,4) = data.save12.TarChanged; % dim -              intensity
    
    guidata(hObject, data);
end