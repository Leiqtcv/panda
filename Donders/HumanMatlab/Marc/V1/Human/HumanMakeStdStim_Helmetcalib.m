%% Standard stimuli
% Bar
% 0: hold bar up
% 1: press bar down
% 2: release bar up
Bar0 = STIMREC;
Bar0.stim  = stimBar;
Bar0.start = [0 0]; 
Bar0.stop  = [1 0];
Bar0.bitNo = 5;
Bar0.mode  = 2;
Bar0.edge  = 1;
Bar0.event = 1;
Bar1 = STIMREC;
Bar1.stim  = stimBar;
Bar1.start = [1 500]; %extra delay to prevent misfixations
Bar1.stop  = [3 0];
Bar1.bitNo = 5;
Bar1.mode  = 0;
Bar1.edge  = 0;
Bar1.event = 3;
Bar2 = STIMREC;
Bar2.stim  = stimBar;
Bar2.start = [3 0];
Bar2.stop  = [2 0];
Bar2.bitNo = 5;
Bar2.mode  = 0;
Bar2.edge  = 1;
Bar2.event = 2;

% Targets
% target nr 1 left
LedTar11 = STIMREC;
LedTar11.stim  = stimLed;
LedTar11.pos   = [3 3];
LedTar11.level = round(255*20/100);
LedTar11.start = [1 0];
LedTar11.stop  = [2 100];
LedTar11.event = 999;
LedTar12 = STIMREC;
LedTar12.stim  = stimLed;
LedTar12.pos   = [3 3];
LedTar12.level = round(255*20/100);
LedTar12.start = [1 0];
LedTar12.stop  = [2 100];
LedTar12.event = 999;
% target nr 2 right
LedTar21 = STIMREC;
LedTar21.stim  = stimLed;
LedTar21.pos   = [3 3];
LedTar21.level = round(255*100/100);
LedTar21.start = [1 0];
LedTar21.stop  = [2 100];
LedTar21.event = 999;
LedTar22 = STIMREC;
LedTar22.stim  = stimLed;
LedTar22.pos   = [3 3];
LedTar22.level = round(255*100/100);
LedTar22.start = [1 0];
LedTar22.stop  = [2 100];
LedTar22.event = 999;


% Data acquisition
Rec = STIMREC;
Rec.stim  = stimRec;
Rec.start = [2 0];
Rec.stop = [2 100]; % stop recording @ reward, NOTE: 'cAcqDur' must be longer
Rec.bitNo = 4; %RA16 start
