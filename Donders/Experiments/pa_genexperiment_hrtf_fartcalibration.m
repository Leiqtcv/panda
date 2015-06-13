function pa_genexperiment_hrtf_fartcalibration
% GENEXPERIMENT Generate exp-file with random locations and timings
%
% GENEXPERIMENT(NRGRID,NRLOC,ID,INT,MINLED,MAXLED,FNAME,DATDIR,MINSND,MAXSND)

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
datdir              = 'DAT';

pa_datadir;
expfile = 'fartsweepcalall18.exp';
snd = 18;
writeexp(expfile,datdir,snd);

%% Show the exp-file in Wordpad
if ispc
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end

function writeexp(expfile,datdir,snd)
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
ntrials     = size(snd,2);
int = 30:10:70;
% int = 50;
nInt = numel(int);

%% Header of exp-file
ITI			= [0 0];
Rep			= 1;
Rnd			= 0;
Mtr			= 'n';
speakers = 1:29;
nSpeakers = numel(speakers);
writeheader(fid,datdir,ITI,ntrials.*nInt*nSpeakers,Rep,Rnd,Mtr)


%% Body of exp-file
% Create a trial for
n = 0;
for ii               = 1:ntrials		% each location
	for jj = 1:nInt
		for kk = 1:nSpeakers
		n = n+1;
		writetrl(fid,n);
				writesnd(fid,'SND1',0,speakers(kk),snd(ii),int(jj),0,0)
% writesnd(fid,'SND1',0,12,snd(ii),int(jj),0,0)
		fprintf(fid,'%s\n','INP1');
		end

	end
end

fclose(fid);

