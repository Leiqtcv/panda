
function showExp(hObject)
    data = guidata(hObject);
    fprintf('*******************************\n');
    fprintf('Trial 123, correct 80.2 %%\n');
    fprintf('stim \tst  Ton Toff parameters\n');
    for i = 1:8
         fprintf('%s \t %d %4d %4d',...
                 char(data.exp.names(i,2)),...
                 data.exp.results(i,1),...
                 data.exp.results(i,2),...
                 data.exp.results(i,3));
         fprintf('   ');
         for n = 1:4
            fprintf('%2d',data.exp.params(i,n));
         end
         fprintf('\n');
    end
end