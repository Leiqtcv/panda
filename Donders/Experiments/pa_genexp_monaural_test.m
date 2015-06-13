function pa_genexp_monaural_test
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
% clear all;

% Default input
minled      = 300;
maxled      = 800;
expfile     = 'monauralstandard.exp';
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = true;


nloc	= 50;
az		= pa_rndval(-75,75,[nloc 1]);
sel		= abs(az)<10;

% nleft = sum(az<-10)
% nright = sum(az>10)
% diff = 
% sel2 = (abs(nleft-nright)-5)>0;
f		= any(sel);
while f
	
	n = sum(sel);
	az(sel) = pa_rndval(-75,75,[n 1]);
	sel = abs(az)<10;

% nleft = sum(az<-10);
% nright = sum(az>10);
% sel2 = (abs(nleft-nright)-5)>0;
f		= any(sel);
end

% nleft = sum(az<-10)
% nright = sum(az>10)
hist(az,-90:10:90);

% az = [-75:15:-15 15:15:75];
% az = az(:);
% az = repmat(az,5,1);

whos az


% transform to hoop coordinates
[theta,phi] = pa_azel2fart(az,zeros(size(az))); % theta = hoop azimuth, phi = speaker number, from 1-29 and 101-129, see also manual
theta		= round(theta(:));

%% By default, sounds are presented at various intensities
% out of laziness, every target in a grid has a different intensity,you
% might want to have a grid for every sound type AND level separately.
int			= 55; % this is approximately 40, 50 and 60 dBA, 3 levels
snd			= 200;

%% Get random timings
% Again, randomization is a good thing. When does the LED go off after
% button press, when does the sound go off after LED extinction?
ledon                = pa_rndval(minled,maxled,size(theta));
% Choose a value that hinders the subjects to enter in a default mode.
sndon                = pa_rndval(minsnd,maxsnd,size(theta));
% By default 200 ms, this gap is usually sufficient to reduce fixation inhibition of reaction times of saccades.

%% Randomize
whos phi theta int snd
rnd                 = randperm(length(theta));
theta               = theta(rnd);
phi                 = phi(rnd);
ledon               = ledon(rnd);
sndon               = sndon(rnd);
int					= repmat(int,size(theta));
snd					= snd + pa_rndval(0,99,size(theta));


%% Save data somewhere
pa_datadir; % Change this to your default directory
writeexp(expfile,datdir,theta,phi,snd,int,ledon,sndon);
% see below, these are helper functions to write an exp-file line by line / stimulus by stimulus

%% Show the exp-file in Wordpad
% for PCs
if ispc && showexp
	dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end

function writeexp(expfile,datdir,theta,phi,snd,int,ledon,sndon)
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
ntrials     = numel(theta); % only 135 trials

%% Header of exp-file
ITI			= [0 0];  % useless, but required in header
Rep			= 1; % we have 0 repetitions, so insert 1...
Rnd			= 0; % we randomized ourselves already
Mtr			= 'y'; % the motor should be on
writeheader(fid,datdir,ITI,ntrials*Rep,Rep,Rnd,Mtr); % helper-function

%% Body of exp-file
% Create a trial
for ii               = 1:ntrials		% each location
	writetrl(fid,ii);
	writeled(fid,'SKY',0,1,5,0,0,1,ledon(ii)); % fixation LED
	
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,ledon(ii));	% Data Acquisition immediately after fixation LED exinction
	
	if phi(ii)==1
		writesnd(fid,'SND1',theta(ii),12,0,int(ii),1,ledon(ii)+sndon(ii)); % Sound on
		writesnd(fid,'SND2',theta(ii),phi(ii),snd(ii),int(ii),1,ledon(ii)+sndon(ii)); % Sound on
	else
		writesnd(fid,'SND1',theta(ii),1,0,int(ii),1,ledon(ii)+sndon(ii)); % Sound on
		writesnd(fid,'SND2',theta(ii),phi(ii),snd(ii),int(ii),1,ledon(ii)+sndon(ii)); % Sound on
	end
end
fclose(fid);

