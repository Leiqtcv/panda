function pa_genexperiment_cal
% GENEXPERIMENT Generate exp-file with random locations and timings
%
% GENEXPERIMENT(NRGRID,NRLOC,ID,INT,MINLED,MAXLED,FNAME,DATDIR,MINSND,MAXSND)

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
datdir              = 'DAT';

Az			= round(-90:30:90);
El			= round(-40:20:40);
[Az,El]		= meshgrid(Az,El);
Az			= Az(:);
El			= El(:);

% Remove anything not humanly possible
sel                 = (abs(Az)+abs(El))<=90;
Az                = Az(sel);
El                = El(sel);
% Remove anything not FARTly possible
sel                 = El>85 | El<-57.5;
Az                = Az(~sel);
El                = El(~sel);

plot(Az,El,'k.')
pa_plotfart;

%% Randomize
% Get random timings
[theta,phi] = pa_azel2fart(Az,El);
theta = round(theta);
pa_datadir;
expfile = 'calsmall.exp';
writeexp(expfile,datdir,theta,phi);

%% Show the exp-file in Wordpad
if ispc
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
ntrials     = size(theta,1);

%% Header of exp-file
ITI			= [0 0];
Rep			= 1;
Rnd			= 0;
Mtr			= 'y';
writeheader(fid,datdir,ITI,ntrials,Rep,Rnd,Mtr)

%% Body of exp-file
% Create a trial for
n = 0;
for i               = 1:ntrials		% each location
	n = n+1;
	writetrl(fid,i);
	writeled(fid,'LED',theta(i),phi(i),1,0,0,1,100); % fixation LED
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
end

fclose(fid);

