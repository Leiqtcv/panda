function pa_genexp_pitchlocalization
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
snd			= 8;
expfile     = 'pitchgrating2.exp';
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = true;

%%

phi = 1:29;
az = [-30 -15 +15 +30];
el = -45:15:45;
[az,el] = meshgrid(az,el);
az = round(az(:));
el = round(el(:));
[theta,phi] = pa_azel2fart(az,el);
% theta = zeros(size(phi));

snd = 1:15;
[theta,~] = meshgrid(theta,snd);
[phi,snd] = meshgrid(phi,snd);
snd = snd(:);
phi = round(phi(:));
theta = round(theta(:));

snd
load('cal');
int = Y(snd);


%% Randomize
% Get random timings
ledon                = pa_rndval(minled,maxled,size(theta));
sndon                = pa_rndval(minsnd,maxsnd,size(theta));


% % Randomize
rnd                 = randperm(length(theta));
theta               = theta(rnd);
phi                 = phi(rnd);
ledon               = ledon(rnd);
sndon               = sndon(rnd);
int = int(rnd);
snd               = snd(rnd);

pa_datadir
writeexp(expfile,datdir,theta,phi,snd,ledon,sndon,int);
%% Show the exp-file in Wordpad
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end


function writeexp(expfile,datdir,theta,phi,snd,ledon,sndon,int)
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
	writeled(fid,'LED',0,12,5,0,0,1,ledon(ii)); % fixation LED
	
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,ledon(ii));	% Data Acquisition immediately after fixation LED exinction
	
	writesnd(fid,'SND1',theta(ii),phi(ii),snd(ii),int(ii),1,ledon(ii)+sndon(ii)); % Sound on
% 	writeled(fid,'SKY',spoke(ii),ring(ii),50,1,ledon(ii)+sndon(ii),1,ledon(ii)+sndon(ii)+150); % Sound on
end
fclose(fid);

