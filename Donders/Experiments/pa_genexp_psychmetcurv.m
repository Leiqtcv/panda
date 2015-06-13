function pa_genexp_psychmetcurv
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
expfile     = 'audspacgen6.exp';
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = true;

%% Stimuli
% 30 deg
nrep		= 20;
test		= [15:5:25 35:5:45];
test		= repmat(test,1,nrep);
n			= numel(test);
az			= zeros(size(test));
standard1	= repmat(30,size(test));
[~,phitest1] = pa_azel2fart(az,test);
[theta1,phistandard1] = pa_azel2fart(az,standard1);
theta1 = round(theta1);

% -30
nrep		= 20;
test		= -[15:5:25 35:5:45];
test		= repmat(test,1,nrep);
n			= numel(test);
az			= zeros(size(test));
standard2	= repmat(-30,size(test));
[~,phitest2] = pa_azel2fart(az,test);
[theta2,phistandard2] = pa_azel2fart(az,standard2);
theta2 = round(theta2);

%% -30
nrep		= 20;
test		= [-15:5:-5 5:5:15];
test		= repmat(test,1,nrep);
n			= numel(test);
az			= zeros(size(test));
standard3	= zeros(size(test));
[~,phitest3] = pa_azel2fart(az,test);
[theta3,phistandard3] = pa_azel2fart(az,standard3);
theta3 = round(theta3);

%%
theta		= [theta1 theta2 theta3];
phitest		= [phitest1 phitest2 phitest3];
phistandard = [phistandard1 phistandard2 phistandard3];
n			= numel(theta);

%% Randomize
% Get random timings


% % Randomize
rnd                 = randperm(n);
theta               = theta(rnd);
phitest				= phitest(rnd);


pa_datadir
writeexp(expfile,datdir,theta,phitest,phistandard);
%% Show the exp-file in Wordpad
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end


function writeexp(expfile,datdir,theta,phitest,phistandard)
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
smp = round(48828.125*(100+50));
for ii               = 1:ntrials		% each location
	writetrl(fid,ii);
	writeled(fid,'LED',0,12,5,0,0,0,3000); % fixation LED
	
% 	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,0,0);	% Data Acquisition immediately after fixation LED exinction
	
	writesnd(fid,'SND2',theta(ii),phitest(ii),900+pa_rndval(1,99,1),40+pa_rndval(0,20,1),0,200); % Sound on
	writesnd(fid,'SND1',theta(ii),phistandard(ii),800+pa_rndval(1,99,1),40+pa_rndval(0,20,1),0,200); % Sound on
% 	writeled(fid,'SKY',spoke(ii),ring(ii),50,1,ledon(ii)+sndon(ii),1,ledon(ii)+sndon(ii)+150); % Sound on
end
fclose(fid);

