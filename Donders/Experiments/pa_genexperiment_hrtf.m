function pa_genexperiment_hrtf
% GENEXPERIMENT Generate exp-file with random locations and timings
%
% GENEXPERIMENT(NRGRID,NRLOC,ID,INT,MINLED,MAXLED,FNAME,DATDIR,MINSND,MAXSND)

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
datdir              = 'DAT';

pa_datadir;
expfile = 'hrtf.exp';
loc = 1:29;
writeexp(expfile,datdir,loc);

%% Show the exp-file in Wordpad
if ispc
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end

function writeexp(expfile,datdir,loc)
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
ntrials     = size(loc,2);
int			= 50;
nInt		= numel(int);

%% Header of exp-file
ITI			= [0 0];
Rep			= 3;
Rnd			= 0;
Mtr			= 'n';
writeheader(fid,datdir,ITI,ntrials.*nInt*3,Rep,Rnd,Mtr)

%% Body of exp-file
% Create a trial for
n = 0;
for ii               = 1:ntrials		% each location
		n = n+1;
		writetrl(fid,n);
		writeacq(fid,0,0);	% Data Acquisition immediately after fixation LED exinction
		writesnd(fid,'SND1',0,loc(ii),999,50,0,0);
		fprintf(fid,'%s\n','INP1');
end

fclose(fid);

