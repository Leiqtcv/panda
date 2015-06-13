function pa_genexp_audmiddle
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
minled      = 300;
maxled      = 800;
snd			= 10;
expfile     = 'audmiddle_left.exp';
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = 0;
Nrep		= 5;
az			= -25:2.5:55;
az			= repmat(az,1,Nrep);
intval		= [ones(size(az)) repmat(2,size(az))];
az			= [az az];
el			= zeros(size(az));
[theta,phi] = pa_azel2fart(az,el);


%% Randomize
% Get random timings
ledon       = pa_rndval(minled,maxled,size(theta));
sndon       = pa_rndval(minsnd,maxsnd,size(theta));


% % Randomize
rnd         = randperm(length(theta));
theta       = theta(rnd);
intval      = intval(rnd);
phi         = phi(rnd);

snd			= repmat(snd,size(theta));
theta		= round(theta);

pa_datadir
writeexp(expfile,datdir,theta,phi,snd,intval);
% tmp(expfile,datdir,theta,phi,id,int,ledon,sndon,dummy,nrd);
%% Show the exp-file in Wordpad
if ispc && showexp
	dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end


function writeexp(expfile,datdir,theta,phi,snd,intval)
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
	writeled(fid,'SKY',0,1,5,0,0,0,1700); % fixation LED
	
	writeacq(fid,0,200);	% Data Acquisition immediately after fixation LED exinction
	
	writesnd(fid,'SND1',theta(ii),31,snd(ii),55,0,200); % Sound on
	writesnd(fid,'SND2',theta(ii),phi(ii),snd(ii),55,0,200+500); % Sound on
end
fclose(fid);

