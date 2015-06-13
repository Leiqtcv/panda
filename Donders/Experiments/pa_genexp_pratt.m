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

% Default input
minled      = 300;
maxled      = 800;
expfile     = 'default.exp';
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = true;

%% Stimulus locations
% We will first create a number of random positions where the sounds will
% be played. Here, this will be done smartly with PA_RNDGRDLOC.
% PA_RNDGRIDLOC will divide the frontal hemisphere in N (4) regions, and
% draw K (3) number of targets in every region, such that the average
% location of those K targets is the centre of the region. This provides a
% nice way to  balance the need for randomization and the desire to present
% fixed repetitions of the stimuli.
[azbb,elbb] = pa_rndgrdloc(4,3); % Locations for broad-band sounds
% For a default sound localization experiment, we also want to present
% high-pass (HP, ILD/spectral cues) and low-pass (LP, ITD) sounds
[azhp,elhp] = pa_rndgrdloc(4,3); % HP locations
[azlp,ellp] = pa_rndgrdloc(4,3); % LP locations
% Note that you can provide any target location you want, and you do not
% necessarily have to use pa_rndgrdloc. In fact, you could even hard-code
% the target-locations, e.g.:
% azbb = -80:20:80; % present sound at azimuths ranging between -80 tp +80
% deg in steps of 20 deg
% elbb = -80:20:80; % do the same for elevation
% [azbb,elbb] = meshgrid(azbb,elbb); % and do this for all possible
% combinations of az and el
% You also may not want to present different sound types, or different
% locations for various types.

el = -50:20:50;
az = zeros(size(el));

% transform to hoop coordinates
[theta,phi] = pa_azel2fart(az,el); % theta = hoop azimuth, phi = speaker number, from 1-29 and 101-129, see also manual
theta		= round(theta);

%% By default, sounds are presented at various intensities
int			= [45 50 55 60 65]; % this is approximately 40, 50 and 60 dBA, 3 levels

%% Now define the IDs of the sounds we want to use.
% 3 4 5 6 7 8
sndid = [4 5 6 7 8];
% num2str(sndid

[phi,int,sndid] = ndgrid(phi,int,sndid);
phi = phi(:);
int = int(:);
snd = sndid(:);
theta = zeros(size(phi));
% Note, for the advanced: this is specifically for the hoop-setup with the
% HumanV1-interface. If you use Matlab and ActiveX components, and program
% RPvsdEx yourself, you can probably do the filtering within TDT's RP2.
% P.S. there are no calibration files yet; sound generation can be done
% according to:
% - http://www.neural-code.com/index.php/tutorials/stimulus/sound/52-acoustic-stimulus
% - http://www.neural-code.com/index.php/laboratory/31-setups/77-hoop-speakers

%% Get random timings
% Again, randomization is a good thing. When does the LED go off after
% button press, when does the sound go off after LED extinction?
ledon                = pa_rndval(minled,maxled,size(theta));
% Choose a value that hinders the subjects to enter in a default mode.
sndon                = pa_rndval(minsnd,maxsnd,size(theta)); 
% By default 200 ms, this gap is usually sufficient to reduce fixation inhibition of reaction times of saccades. 

%% Randomize
rnd                 = randperm(length(theta));
theta               = theta(rnd);
phi                 = phi(rnd);
ledon               = ledon(rnd);
sndon               = sndon(rnd);
int					= int(rnd);
snd					= snd(rnd);



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
unique(snd)

%% Body of exp-file
% Create a trial
for ii               = 1:ntrials		% each location
	writetrl(fid,ii);
	writeled(fid,'SKY',0,1,5,0,0,1,ledon(ii)); % fixation LED
	
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,ledon(ii));	% Data Acquisition immediately after fixation LED exinction
	
	if phi(ii)==1
	writesnd(fid,'SND1',theta(ii),12,snd(ii),int(ii),1,ledon(ii)+sndon(ii)); % Sound on
	writesnd(fid,'SND2',theta(ii),phi(ii),snd(ii),int(ii),1,ledon(ii)+sndon(ii)); % Sound on
	else
	writesnd(fid,'SND1',theta(ii),1,snd(ii),int(ii),1,ledon(ii)+sndon(ii)); % Sound on
	writesnd(fid,'SND2',theta(ii),phi(ii),snd(ii),int(ii),1,ledon(ii)+sndon(ii)); % Sound on
	end
% 	writeinp(fid,1); % Sound on
% 	writeinp(fid,2); % Sound on

		
end
fclose(fid);

