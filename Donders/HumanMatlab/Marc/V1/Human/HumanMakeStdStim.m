%% Standard stimuli
% Bar
% 0: hold bar up
% 1: press bar down
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
Bar1.start = [1 0];
Bar1.stop  = [2 0];
Bar1.bitNo = 5;
Bar1.mode  = 0;
Bar1.edge  = 0;
Bar1.event = 2;

% fix
% 1: attention while bar up
% 2: fixation while bar down
SkyFix1 = STIMREC;
SkyFix1.stim  = stimSky;
SkyFix1.pos   = [0 1];
SkyFix1.level = round(255*FixIntRed/100);
SkyFix1.start = [1 0];
SkyFix1.stop  = [2 0];
SkyFix1.event = 3;
SkyFix2 = STIMREC;
SkyFix2.stim  = stimSky;
SkyFix2.pos   = [0 2];
SkyFix2.level = round(255*FixIntGreen/100);
SkyFix2.start = [3 0];
SkyFix2.stop  = [3 1000];
SkyFix2.event = 100;

% Targets
% target nr I
Ntarmax = 10-1;
for I=1:Ntarmax
    SkyTar(I) = STIMREC;
    SkyTar(I).stim  = stimSky;
    SkyTar(I).pos   = [3 3];
    SkyTar(I).level = round(255*TarInt/100);
    SkyTar(I).start = [100+(I-1) 0];
    SkyTar(I).stop  = [200+(I-1) 0];
    SkyTar(I).event = 100+I;
end
% last target
SkyTarLast = STIMREC;
SkyTarLast.stim  = stimSky;
SkyTarLast.pos   = [3 3];
SkyTarLast.level = round(255*TarInt/100);
SkyTarLast.start = [100+(Ntarmax-1) 0];
SkyTarLast.stop  = [200+(Ntarmax-1) 0];
SkyTarLast.event = 999;

% Window
% window nr I
for I=1:Ntarmax
    Win(I) = STIMREC;
    Win(I).stim = stimFixWnd;
    Win(I).index = I;
    Win(I).width = [WinSize(1) WinSize(2)];
    Win(I).delay = WinDelay;
    Win(I).event = 200+(I-1);
    Win(I).start = [100+(I-1) 0];
    Win(I).stop  = [100+(I-1) 5000];
end
% last window
WinLast = STIMREC;
WinLast.stim = stimFixWnd;
WinLast.index = 0;
WinLast.width = [WinSize(1) WinSize(2)];
WinLast.delay = WinDelay;
WinLast.event = 4;
WinLast.start = [100+(Ntarmax-1) 0];
WinLast.stop  = [100+(Ntarmax-1) 5000];

% Reward
Rew = STIMREC;
Rew.stim  = stimRew;
Rew.start = [4 0];
Rew.stop = [4 RewDur];
Rew.bitNo = 3;


% Data acquisition
Rec = STIMREC;
Rec.stim  = stimRec;
Rec.start = [2 0];
Rec.stop = [4 0]; % stop recording @ reward, NOTE: 'cAcqDur' must be longer
Rec.bitNo = 4;
