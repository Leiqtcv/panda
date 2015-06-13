function pa_genexp_aubert
% PA_GENEXP_AUBERT
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
expfile     = ['aubert.exp'];
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = 0;


theta		= 90;
phi			= [129 28];
[theta,phi] = meshgrid(theta,phi);
theta		= theta(:);
phi			= phi(:);
[az,el] = pa_fart2azel(theta,phi)

dint = -7:7;
nint = length(dint);
loc = linspace(az(1),az(2),nint);

loc/dint
gain = 14/17.5;
bias = -7+gain*7.5
% -7.5 -7
% 10	7
az = -7.5:1.25:7.5;
% dint = 
whos az
plot(dint,loc);
axis square;
pa_unityline;
pa_verline;
pa_horline([0 bias])
return
%% Randomize
% Get random timings
ledon                = pa_rndval(minled,maxled,size(theta));
sndon                = pa_rndval(minsnd,maxsnd,size(theta));


% % Randomize
% rnd                 = randperm(length(theta));
% theta               = theta(rnd);
% phi                 = phi(rnd);
% ledon               = ledon(rnd);
% sndon               = sndon(rnd);

snd				= repmat(snd,size(theta));
% snd               = snd(rnd);
% theta				= round(theta);

pa_datadir
writeexp(expfile,datdir,theta,phi,snd,ledon,sndon);
% tmp(expfile,datdir,theta,phi,id,int,ledon,sndon,dummy,nrd);
%% Show the exp-file in Wordpad
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end


function writeexp(expfile,datdir,theta,phi,snd,ledon,sndon)
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
ntrials     = numel(theta)

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
	writeled(fid,'SKY',0,1,5,0,0,1,ledon(ii)); % fixation LED
	
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,ledon(ii));	% Data Acquisition immediately after fixation LED exinction
	
	writesnd(fid,'SND1',theta(ii),phi(ii),snd(ii),35,1,ledon(ii)+sndon(ii)); % Sound on
% 	writeled(fid,'SKY',spoke(ii),ring(ii),50,1,ledon(ii)+sndon(ii),1,ledon(ii)+sndon(ii)+150); % Sound on
end
fclose(fid);

