function SND = sumsounds(SND1,SND2,LD)
% SND = SUMSOUNDS(SND1,SND2,LD)
%
% Sum sounds SND1 and SND2, each weighted by the level difference LD to
% produce a compound SND. LD is positive when SND1 is louder than SND2.
%

% Marc van Wanrooij
% 2009

Mag = 10^((LD)/20);
SND = (Mag^.5)*SND1+SND2/(Mag^.5);