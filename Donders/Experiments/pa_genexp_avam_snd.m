function pa_genexp_avam_snd
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

% Default input

expfile     = 'avam_snd.exp';
datdir      = 'DAT';


%% Some Flags
showexp     = true;

% theta	= -5; % deg, hoop location
% phi		= 12; % speaker number
% int		= 45; % this is approximately 40 dBA, 3 levels

%% Now define the IDs of the sounds we want to use.
% Periods of the sounds: 15   136   258   379   500 ms
% snd0xx = 15
% snd1xx = 136
% snd2xx = 258
% snd3xx = 379
% snd5xx = 500 
% Dynamic onset: 500:100:1500 % so 11 IDs
% sndxx1 = 500
% sndxx2 = 600
% etc
% sndx11 = 1500 ms
% This will be made in pa_gensnd_avam
% snd000 = static only

%% 
snd		= [1:3 5];
nrep	= 1;

snd		= 100*repmat(snd,1,nrep);
nsnd	= numel(snd);
sndon	= pa_rndval(1,11,[1 nsnd]);
snd		= snd+sndon;
rnd                 = randperm(nsnd);
snd = snd(rnd);

%% Save data somewhere
pa_datadir; % Change this to your default directory
writeexp(expfile,datdir,snd); 
% see below, these are helper functions to write an exp-file line by line / stimulus by stimulus

%% Show the exp-file in Wordpad
% for PCs
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end

function writeexp(expfile,datdir,snd)
% Save known trial-configurations in exp-file
%
%WRITEEXP WRITEEXP(FNAME,DATDIR,THETA,PHI,ID,INT,LEDON,SNDON)
%
% WRITEEXP(FNAME,THETA,PHI,ID,INT,LEDON,SNDON)
%
% Write exp-file with file-name FNAME.
%
%
% See also manual at neural-code.com
expfile		= pa_fcheckext(expfile,'.exp'); % check whether the extension exp is included


fid         = fopen(expfile,'w'); % this is the way to write date to a new file
ntrials     = numel(snd); % only 135 trials

%% Header of exp-file
ITI			= [0 0];  % useless, but required in header
Rep			= 1; % we have 0 repetitions, so insert 1...
Rnd			= 0; % we randomized ourselves already
Mtr			= 'y'; % the motor should be on
writeheader(fid,datdir,ITI,ntrials*Rep,Rep,Rnd,Mtr); % helper-function
unique(snd)

%% Body of exp-file
% Create a trial
for ii               = 1:ntrials		% each location
	writetrl(fid,ii);
	writeled(fid,'SKY',0,1,100,0,0,1,0); % fixation LED
	
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,0);	% Data Acquisition immediately after fixation LED exinction
	writesnd(fid,'SND2',-5,12,snd(ii),55,1,100); % Sound on
	writesnd(fid,'SND1',-5,1,snd(ii),55,1,100); % Sound on

	writeled(fid,'SKY',0,2,100,1,100,1,3100); % fixation LED
	

end
fclose(fid);

