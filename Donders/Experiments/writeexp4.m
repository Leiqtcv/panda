function writeexp4(expfile,datdir,theta,phi,id,int,ledon,sndon,dummy,nrdtrials)
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
expfile		= fcheckext(expfile,'.exp');
if nargin<9
	dummy	= [];
end
if nargin<10
	nrdtrials = 1;
end
fid         = fopen(expfile,'w');
nid         = size(theta,2);
nint        = size(theta,3);
ntrials     = size(theta,1);
dtrials		= rnduni(1,ntrials,nrdtrials); % The trial numbers which should contain a dummy movement
sel			= abs(diff(theta))<30;
indx		= find(logical([sel;0]));
dtrials     = unique(sort([dtrials;indx]));
nrdtrials   = size(dtrials,1);

%% Header of exp-file
ITI			= [0 0];
if ~isempty(dummy)
	Ntrls	= (ntrials*nid*nint)+nrdtrials;
elseif isempty(dummy)
	Ntrls	= ntrials*nid*nint;
end
Rep			= 1;
Rnd			= 0;
Mtr			= 'y';
writeheader(fid,datdir,ITI,Ntrls,Rep,Rnd,Mtr)

%% Body of exp-file
% Create a trial for
n = 0;
for i               = 1:ntrials		% each location
	for j           = 1:nid			% each sound
		for k       = 1:nint		% and each intensity
			n = n+1;
			writetrl(fid,i);
			if theta(i)==0
				writeled(fid,'LED',0,12,1,0,0,1,ledon(i,j,k)); % fixation LED
			else
				writeled(fid,'SKY',0,1,5,0,0,1,ledon(i,j,k)); % fixation LED
			end
			writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
			writeacq(fid,1,ledon(i,j,k));	% Data Acquisition immediately after fixation LED exinction
			writesnd(fid,'SND1',theta(i,j,k),phi(i,j,k),id(i,j,k),int(i,j,k),1,ledon(i,j,k)+sndon(i,j,k)); % Sound on
			if ~isempty(dummy)
				if ismember(n,dtrials)
					writetrl(fid,i);
					writeled(fid,'LED',dummy(i,j,k),12,0,0,0,0,0);
				end
			end
		end
	end
end
fclose(fid);

