%
%   Get Info Next Trial
%
function [newTime pos] = getNextTrialInfo(useBar, preTime)

% setup experiment

STIMREC= struct('stim',0,'start',[0 0],'stop',[0 0],'pos',[0 0],...
                'mode',0,'level',0,'index',0,...
                'event',0,'stat',0);

newTime= randi([500 1000],1,2);
pos(1) = randi([1 4],1,1);
pos(2) = randi([1 12],1,1);
nStims = 5;
stims(nStims) = STIMREC;
if useBar == 1
    stims(1).stim   = evalin('base','Globals.stimBar');
    stims(1).start  = [0 0];        %  1 start T = 0
    stims(1).stop   = [1 0];        %  3 stop after bar pressed
    stims(1).pos    = [0 0];        %  5 N.U.
    stims(1).mode   = 0;            %  7 flank
    stims(1).level  = 1             %  8 low->high
    stims(1).index  = 0;            %  9 bar is connected to bit 0
    stims(1).event  = 1;            % 10 ok throw event 1 else 99
    stims(1).stat   = 2;            % 11 initialize
else
    stims(1).stim   = evalin('base','Globals.stimLed');
    stims(1).start  = [0 0];        %  1 start T = 0
    stims(1).stop   = [0 10];       %  3 stop after bar pressed
    stims(1).pos    = [0 0];        %  5 N.U.
    stims(1).mode   = 0;            %  7 flank
    stims(1).level  = 1;            %  8 low->high
    stims(1).index  = 0;            %  9 bar is connected to bit 0
    stims(1).event  = 1;            % 10 ok throw event 1 else 99
    stims(1).stat   = 2;            % 11 initialize
end
% led - fix
stims(2).stim   = evalin('base','Globals.stimLed');
stims(2).start  = [1 0];            %  1 start after event 1
stims(2).stop   = [1 500];          %  3 led on for one second
stims(2).pos    = [0 0];            %  5 ring spoke
stims(2).mode   = 0;                %  7 N.U.
stims(2).level  = 7;                %  8 7, max intensity
stims(2).index  = 1;                %  9 0-green, 1-red
stims(2).event  = 2;                % 10 
stims(2).stat   = 2;                % 11 initialize
% led - target
stims(3).stim   = evalin('base','Globals.stimLed');
stims(3).start  = [2 0];            %  1 start after event 1
stims(3).stop   = [2 preTime(1)];   %  3 led on for 500-1000 mSec
stims(3).pos    = pos;              %  5 random position
stims(3).mode   = 0;                %  7 N.U.
stims(3).level  = 7;                %  8 7, max intensity
stims(3).index  = 0;                %  9 0-green, 1-red
stims(3).event  = 3;                % 10 
stims(3).stat   = 2;                % 11 initialize
% led - target-dim
stims(4).stim   = evalin('base','Globals.stimLed');
stims(4).start  = [3 0];            %  1 start after event 1
stims(4).stop   = [3 preTime(2)];   %  3 led dimming for 500-1000 mSec
stims(4).pos    = pos;              %  5 random position
stims(4).mode   = 0;                %  7 N.U.
stims(4).level  = 3;                %  8 3, dimmed intensity
stims(4).index  = 0;                %  9 0-green, 1-red
stims(4).event  = 4;                % 10 
stims(4).stat   = 2;                % 11 initialize
% Sound = record
stims(5).stim   = evalin('base','Globals.stimSnd');
stims(5).start  = [2 0];            %  1 start play
stims(5).stop   = [4 0];            %  3 duration
stims(5).pos    = pos;              %  5 speaker
stims(5).mode   = 0;                %  7 source = A
stims(5).level  = 1;                %  8 high active
stims(5).index  = 1;                %  9 RP2-trigger connected to bit 1
stims(5).event  = 0;                % 10 
stims(5).stat   = 2;                % 11 initialize

evalin('base',['nStims = ',num2str(nStims),';']);
for n=1:nStims
evalin('base',['curTrial(',num2str(n),', 1)=',num2str(stims(n).stim),';']);
evalin('base',['curTrial(',num2str(n),', 2)=',num2str(stims(n).start(1)),';']);
evalin('base',['curTrial(',num2str(n),', 3)=',num2str(stims(n).start(2)),';']);
evalin('base',['curTrial(',num2str(n),', 4)=',num2str(stims(n).stop(1)),';']);
evalin('base',['curTrial(',num2str(n),', 5)=',num2str(stims(n).stop(2)),';']);
evalin('base',['curTrial(',num2str(n),', 6)=',num2str(stims(n).pos(1)),';']);
evalin('base',['curTrial(',num2str(n),', 7)=',num2str(stims(n).pos(2)),';']);
evalin('base',['curTrial(',num2str(n),', 8)=',num2str(stims(n).mode),';']);
evalin('base',['curTrial(',num2str(n),', 9)=',num2str(stims(n).level),';']);
evalin('base',['curTrial(',num2str(n),',10)=',num2str(stims(n).index),';']);
evalin('base',['curTrial(',num2str(n),',11)=',num2str(stims(n).event),';']);
evalin('base',['curTrial(',num2str(n),',12)=',num2str(stims(n).stat),';']);
end
