function pa_genexperiment_cal
% GENEXPERIMENT Generate exp-file with random locations and timings
%
% GENEXPERIMENT(NRGRID,NRLOC,ID,INT,MINLED,MAXLED,FNAME,DATDIR,MINSND,MAXSND)

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
datdir              = 'DAT';


phi = 1:12; % X
r	= 1:7; % Y
[phi,r] = meshgrid(phi,r);
phi = phi(:);
r = r(:);
r = [1; r];
phi = [0; phi];

expfile = 'calsky_eyebrain.exp';
writeexp(expfile,datdir,r,phi);

%% Show the exp-file in Wordpad
if ispc
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end

function writeexp(expfile,datdir,r,phi)
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
ntrials     = size(r,1);

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
	writeled(fid,'SKY',phi(i),r(i),100,0,0,1,100); % fixation LED
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writelas(fid,'LAS',8,1,0,1,100,0); % fixation 
	
end

fclose(fid);

