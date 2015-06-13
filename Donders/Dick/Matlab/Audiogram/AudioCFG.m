%
% configuratie record voor programma "Audiogram"
%
filename = 'Y:\dick\Audiogram\AudiogramCFG.mat';
%
config = struct();
% testfrequenties
%  config.freq = [1000 500 250 125 2000 3000 4000 6000 8000 16000];
config.freq = [1000 500 250 125 1000 2000 3000 4000 6000 8000 16000];
% duur van de toon in mSec
config.duration = 1000;
% verzwakking bij het voor het eerst aanbieden van een nieuwe frequentie
config.startAtten = 60;
% minimale vezwakking in dB, dit wordt bepaald door gebruikte speaker
config.minAtten = 10;
% Wordt de knop na het aanbieden van een toon ingedrukt, dan wordt
% de verzwakking verhoogd, in het andere geval verlaagd.
% Na n opeenvolgende Hoog/Laag veranderingen wordt de verzwakking gebruikt
% voor het audiogram.
config.numHL = 2;
% Om te voorkomen dat dit het resultaat is van het met een vast ritme
% indrukken van de knop, kan de ITI random worden gekozen.
% (500 + random) mSec
config.rndITI = 1000;
% save
save(filename,'config');


