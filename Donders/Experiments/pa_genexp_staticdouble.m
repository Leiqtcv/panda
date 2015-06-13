function pa_genexp_staticdouble
%
% This will generate an EXP-file of a spatial prior learning
% experiment. EXP-files are used for the psychophysical experiments at the
% Biophysics Department of the Donders Institute for Brain, Cognition and
% Behavior of the Radboud University Nijmegen, the Netherlands.
% 
% See also the manual for the experimental set-ups at www.mbys.ru.nl/staff/m.vanwanrooij/neuralcode/manuals/audtoolbox.pdf.
% See also WRITESND, WRITELED, WRITETRG, etc

% 2013 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
close all
clear all;

% Default input
minled      = 50;
maxled      = 150;
expfile     = 'staticdouble.exp';
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = true;

%% Create Stimuli

% Sound level (differences)
leveldiff	= -10:2:10;
levels		= round(55+[leveldiff/2; -leveldiff/2]);
% nlevels		= size(levels,2);

% head position, defined by fixation LED position
spokes			= [3 9]; % el = 0
rings			= 1:7;
[spokes,rings]	= meshgrid(spokes,rings);
spokes			= spokes(:);
rings			= rings(:);
% nhead			= numel(spokes);

% Combine
[spokes,L1]		= meshgrid(spokes,levels(1,:));
[rings,L2]		= meshgrid(rings,levels(2,:));
spokes			= spokes(:);
rings			= rings(:);
L1				= L1(:);
L2				= L2(:);

% Repeat
nrep			= 3; % number of repetitions
L1				= repmat(L1,nrep,1);
L2				= repmat(L2,nrep,1);
spokes			= repmat(spokes,nrep,1);
rings			= repmat(rings,nrep,1);
nstim			= numel(L1);

%% Randomize
% Get random timings
ledon                = pa_rndval(minled,maxled,nstim);
sndon                = pa_rndval(minsnd,maxsnd,nstim);

rnd                 = randperm(nstim); % random vector
L1					= L1(rnd);
L2					= L2(rnd);
spokes				= spokes(rnd);
rings				= rings(rnd);

%% Random sounds
snd                = round(pa_rndval(0,100,nstim)); % These need to be created: snd000 to snd100

pa_datadir
writeexp(expfile,datdir,spokes,rings,L1,L2,snd,ledon,sndon);
%% Show the exp-file in Wordpad
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end

function writeexp(expfile,datdir,spokes,rings,L1,L2,snd,ledon,sndon)

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
ntrials     = numel(L1);

%% Header of exp-file
ITI			= [0 0];
Rep			= 1;
Rnd			= 0;
Mtr			= 'n';
writeheader(fid,datdir,ITI,ntrials*Rep,Rep,Rnd,Mtr)

%% Body of exp-file
% Create a trial for
for ii               = 1:ntrials		% each location
	writetrl(fid,ii);
	writeled(fid,'SKY',spokes(ii),rings(ii),5,0,0,1,ledon(ii)); % fixation LED
	
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,ledon(ii));	% Data Acquisition immediately after fixation LED exinction
	
	writesnd(fid,'SND1',0,31,snd(ii),L1(ii),1,ledon(ii)+sndon(ii)); % Sound on
	writesnd(fid,'SND2',0,32,snd(ii),L2(ii),1,ledon(ii)+sndon(ii)); % Sound on
end
fclose(fid);

