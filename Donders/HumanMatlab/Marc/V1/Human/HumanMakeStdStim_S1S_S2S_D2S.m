%% events:
%
% 0: start bar
% (101: start bar release)
% 1: start fix
% 2: stop fix,
%    release but
% 3: fix off, 
%    start next target,
%    velocity trigger
% 4: start untriggered target
% 5: start triggered target
% 6: Acquisition

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
Bar1.start = [1 100]; %extra delay to prevent misfixations
Bar1.stop  = [101 0];
Bar1.bitNo = 5;
Bar1.mode  = 0;
Bar1.edge  = 0;
Bar1.event = 101;
Bar2 = STIMREC;
Bar2.stim  = stimBar;
Bar2.start = [101 0];
Bar2.stop  = [2 0];
Bar2.bitNo = 5;
Bar2.mode  = 0;
Bar2.edge  = 1;
Bar2.event = 2;


% Targets
% fixation
SkyFix = STIMREC;
SkyFix.stim  = stimSky;
SkyFix.pos   = [0 1]; % red
SkyFix.level = round(255*1/100);
SkyFix.start = [1 0];
SkyFix.stop  = [2 0];
SkyFix.event = 3;
% target nr 1
SkyTar1 = STIMREC;
SkyTar1.stim  = stimSky;
SkyTar1.pos   = [3 3];
SkyTar1.level = round(255*20/100);
SkyTar1.start = [3 200];
SkyTar1.stop  = [3 300];
SkyTar1.event = 5;
% target nr 2
SkyTar2 = STIMREC;
SkyTar2.stim  = stimSky;
SkyTar2.pos   = [3 4];
SkyTar2.level = round(255*20/100);
SkyTar2.start = [5 100]; % or 6
SkyTar2.stop  = [5 200]; % or 6
SkyTar2.event = 4;

% velocity trigger
Speed =  STIMREC;
Speed.stim = stimSpeed;
Speed.mode = 14;
Speed.pos = [0 0];
Speed.start = [3 250];
Speed.stop = [3 2000];
Speed.level = -15;
Speed.event = 6;

Vib         = STIMREC;
Vib.stim    = stimLas;
Vib.start   = [0 100];
Vib.stop    = [4 1000];
Vib.bitNo   = 8;

% Data acquisition
Rec = STIMREC;
Rec.stim  = stimRec;
Rec.start = [3 0];
Rec.stop = [4 1000]; % stop recording @ reward, NOTE: 'cAcqDur' must be longer
Rec.bitNo = 4; %RA16 start
