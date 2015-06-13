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
% target nr 1 Head
SkyTar1 = STIMREC;
SkyTar1.stim  = stimSky;
SkyTar1.pos   = [3 3];
SkyTar1.level = round(255*20/100);
SkyTar1.start = [1 0];
SkyTar1.stop  = [2 100];
SkyTar1.event = 999;
% target nr 2 Eye
SkyTar2 = STIMREC;
SkyTar2.stim  = stimSky;
SkyTar2.pos   = [3 3];
SkyTar2.level = round(255*100/100);
SkyTar2.start = [1 300];
SkyTar2.stop  = [2 100];
SkyTar2.event = 999;


% laser
Las = STIMREC;
Las.stim  = stimLas;
Las.start = [0 0];
Las.stop  = [2 100];
Las.bitNo = 8;


% Data acquisition
Rec = STIMREC;
Rec.stim  = stimRec;
Rec.start = [2 0];
Rec.stop = [2 100]; % stop recording @ reward, NOTE: 'cAcqDur' must be longer
Rec.bitNo = 4; %RA16 start
