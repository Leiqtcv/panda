function pa_genexp_default
% PA_GENEXP_SPATIALPRIOR
%
% This will generate an EXP-file of a spatial prior learning
% experiment. EXP-files are used for the psychophysical experiments at the
% Biophysics Department of the Donders Institute for Brain, Cognition and
% Behavior of the Radboud University Nijmegen, the Netherlands.
% 
% See also the manual for the experimental set-ups at www.mbys.ru.nl/staff/m.vanwanrooij/neuralcode/manuals/audtoolbox.pdf.
% See also WRITESND, WRITELED, WRITETRG, etc

% (c) 2012 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
close all
clear all;

snd = pa_gengwn(1700);
snd = pa_equalizer(snd);
snd = pa_ramp(snd);
snd = pa_fart_levelramp(snd);
snd = pa_writewav(snd,'snd001.wav');

return
% Default input
minled      = 300;
maxled      = 800;
snd			= 8;
expfile     = 'beersexp1.exp';
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = true;

%% Stimuli
%  2, 4, 6, 8, 10, 12, 14, 16, and 18°
az = [5 10 20 30 40];
el = zeros(size(az));

R	= 1:7;
S1	= repmat(3,size(R));
S2	= repmat(9,size(R));
S	= [S2 S1];
R	= [R R];
[az,el]=pa_sky2azel(R,S);
[theta,phi] = pa_azel2fart(az,el);
theta		= round(theta);
phi			= round(phi);

whos theta phi
theta = repmat(theta,1,100);
phi = repmat(phi,1,100);
whos theta phi
theta = sort(theta);

pa_datadir
writeexp(expfile,datdir,theta,phi);
%% Show the exp-file in Wordpad
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end


function writeexp(expfile,datdir,theta,phi)
% Save known trial-configurations in exp-file
%
%WRITEEXP WRITEEXP(FNAME,DATDIR,THETA,PHI,ID,INT,LEDON,SNDON)
%
% WRITEEXP(FNAME,THETA,PHI,ID,INT,LEDON,SNDON)
%
% Write exp-file with file-name FNAME.
%
%
% See also GENEXPERIMENT
%
% Author: Marcw
expfile		= pa_fcheckext(expfile,'.exp');


fid         = fopen(expfile,'w');
ntrials     = numel(theta);

%% Header of exp-file
ITI			= [0 0];
Rep			= 1;
Rnd			= 0;
Mtr			= 'y';
writeheader(fid,datdir,ITI,ntrials*Rep,Rep,Rnd,Mtr)

%% Body of exp-file
% Create a trial for
n = 0;
for ii               = 1:ntrials		% each location
	writetrl(fid,ii);
	writeled(fid,'SKY',0,1,5,0,0,0,2000); % fixation LED
	writeacq(fid,0,0);	% Data Acquisition immediately after fixation LED exinction
	writesnd(fid,'SND1',theta(ii),phi(ii),1,50,0,300); % Sound on
% 	writeled(fid,'SKY',spoke(ii),ring(ii),50,1,ledon(ii)+sndon(ii),1,ledon(ii)+sndon(ii)+150); % Sound on
end
fclose(fid);

