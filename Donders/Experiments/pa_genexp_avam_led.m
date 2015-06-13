function pa_genexp_avam_led
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
expfile     = 'avam_led.exp';
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
int		= [ 40 80];
nrep	= 1;
int		= repmat(int,[1 nrep]);
nstim	= numel(int);
onset	= 500+100*pa_rndval(0,10,[1 nstim]);

rnd = randperm(nstim);
int = int(rnd);
%% Save data somewhere
pa_datadir; % Change this to your default directory
writeexp(expfile,datdir,onset,int); 
% see below, these are helper functions to write an exp-file line by line / stimulus by stimulus

%% Show the exp-file in Wordpad
% for PCs
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end

function writeexp(expfile,datdir,onset,int)
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
ntrials     = numel(onset); % only 135 trials

%% Header of exp-file
ITI			= [0 0];  % useless, but required in header
Rep			= 1; % we have 0 repetitions, so insert 1...
Rnd			= 0; % we randomized ourselves already
Mtr			= 'y'; % the motor should be on
writeheader(fid,datdir,ITI,ntrials*Rep,Rep,Rnd,Mtr); % helper-function

%% Body of exp-file
% Create a trial
N = round(48828.125*(100+50)/1000);

N = round(N/48828.125*1000);
for ii               = 1:ntrials		% each location
	writetrl(fid,ii);
	writeled(fid,'SKY',0,1,100,0,0,1,0); % fixation LED GREEN
	
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,0);	% Data Acquisition immediately after fixation LED exinction
	writesnd(fid,'SND2',-5,12,0,55,1,100); % Sound on
	writesnd(fid,'SND1',-5,1,0,55,1,100); % Sound on
	
	writeled(fid,'SKY',0,2,100,1,100,1,100+onset(ii)); % fixation LED
	writeled(fid,'SKY',0,2,int(ii),1,100+onset(ii)+N+1,1,3100); % fixation LED
	
		
end
fclose(fid);

