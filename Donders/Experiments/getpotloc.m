function [Xpot,Ypot] = getpotloc
% Generate all possible stimulus locations in the FART-setup
fixdist             = 8;
y                   = -90:0.5:90;
y                   = 2.5*round(y/2.5);
y                   = unique(y);
x                   = -90:0.1:90;
[Xpot,Ypot]         = meshgrid(x,y);
Xpot                = Xpot(:);
Ypot                = Ypot(:);
% Remove anything not humanly possible
sel                 = (abs(Xpot)+abs(Ypot))>90;
Xpot                = Xpot(~sel);
Ypot                = Ypot(~sel);
% Remove anything not FARTly possible
sel                 = Ypot>85 | Ypot<-57.5;
Xpot                = Xpot(~sel);
Ypot                = Ypot(~sel);
% Remove anything not compatible with fixation LED
theta               = pa_azel2fart(Xpot,Ypot);
sel                 = (theta>-fixdist & theta<fixdist) | theta>180-fixdist | theta<-180+fixdist;
Xpot                = Xpot(~sel);
Ypot                = Ypot(~sel);
