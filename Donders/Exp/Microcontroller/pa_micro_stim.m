function CMD = pa_micro_stim(stim)
% CMD = PA_MICRO_STIM(STIM)
% 
% Create a command CMD for the microcontroller in order to store stimulus
% STIM.
%
% STIM is a structure, that, depending on the modality of the stimulus,
% might contain the fields: 
%	- stim: modality 1-18 (see PA_MICRO_GLOBALS)
%	- index
%	- edge
%	- bitNo
%	- pos (2 entries)
%	- level
%	- start (2 entries)
%	- stop (2 entries)
%	- delay
%	- width
%	- event
%
% See also PA_MICRO_CMD, PA_MICRO_GLOBALS, PA_MICRO_STIMS, PA_MICRO_INIT

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com

pa_micro_globals;
%CMD = sprintf('$%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d',...
%              stim.stim,stim.index,stim.edge,stim.bitNo,stim.pos(1),...
%              stim.pos(2),stim.level,stim.start(1),stim.start(2),stim.stop(1),...
%              stim.stop(2),stim.delay,stim.width,stim.event);
switch (stim.stim) % modality of stimulus, varying from 1-18, see PA_MICRO_GLOBALS
    case stimBar % handle bar
        CMD = sprintf('$%d;%d;%d;%d;%d;%d;%d;%d;%d',...
              stim.stim,stim.mode,stim.edge,stim.bitNo,...
              stim.start(1),stim.start(2),...
              stim.stop(1),stim.stop(2),...
              stim.event);
    case {stimRec, stimRew, stimLas} % record, reward, laser = digital output
        CMD = sprintf('$%d;%d;%d;%d;%d;%d;%d',...
              stim.stim,stim.bitNo,...
              stim.start(1),stim.start(2),...
              stim.stop(1),stim.stop(2),...
              stim.event);
    case {stimSky,stimLed} % LED (hoop or wall-fixed)
        CMD = sprintf('$%d;%d;%d;%d;%d;%d;%d;%d;%d',...
              stim.stim,stim.pos(1),stim.pos(2),stim.level,...
              stim.start(1),stim.start(2),stim.stop(1),stim.stop(2),stim.event);
    case {stimSnd1,stimSnd2} % Sound
        CMD = sprintf('$%d;%d;%d;%d;%d;%d;%d',...
              stim.stim,stim.bitNo,stim.start(1),stim.start(2),...
              stim.stop(1),stim.stop(2),stim.event);
    case {stimFixWnd} % Fixation window
        CMD = sprintf('$%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d',...
              stim.stim,stim.index,stim.pos(1),stim.pos(2),stim.width(1),stim.width(2),...
              stim.start(1),stim.start(2),stim.stop(1),stim.stop(2),stim.delay,stim.event);
    case {stimSpeed} % ???
        CMD = sprintf('$%d;%d;%d;%d;%d;%d;%d;%d;%d;%d',...
              stim.stim,stim.mode,stim.pos(1),stim.pos(2),...
              stim.start(1),stim.start(2),stim.stop(1),stim.stop(2),stim.level,stim.event);
	otherwise % Uh-oh
        CMD = '';
end
        
