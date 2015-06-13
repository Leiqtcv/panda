%
% stims => trial
%
function stims2trial()
nStims   = evalin('base','nStims');
for n=1:nStims
   str = ['stims(',num2str(n),').stim'];
   type = evalin('base',str);
   switch type
      case (evalin('base','Globals.stimBit'))
          evalin('base','curTrial(5,5) = 55;');
      case (evalin('base','Globals.stimLed'))
          evalin('base','curTrial(6,6) = 66;');
    end
end

% STIMREC= struct('stim',0,'start',[0 0],'stop',[0 0],'pos',[0 0],...
%                 'mode',0,'edge',0,'level',0,'bitno',0,...
%                 'index',0,'event',0,'stat',0);
