function genowlcontrolexp
close all
% Author MW
% Copyright 2007

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
showexp             = 1;

for ii = 1
	expfile = ['lossespeaker' num2str(ii) '.exp'];
	
	datdir				= 'DAT';
	int					= 54;
	minled              = 100;
	maxled              = 300;
	minsnd              = 100;
	maxsnd				= 100;
	
	
	Nrep				= 50;
	
	%% Sounds Control
	az		= 0;
	el		= [-40 -20 0 20 40];
	[az,el] = meshgrid(az,el);
	az		= az(:);
	el		= el(:);
	[t,p]	= azel2fart(az,el);
	T		= round(t);
	P		= round(p);
	
	int = 53:.5:57;
	T = meshgrid(T,int);
	[P,int] = meshgrid(P,int);
	
	T = T(:);
	P = P(:);
	int = round(int(:)*2)/2;
	marc
	
	writeexp4(expfile,datdir,T,P,int);
	%% Show the exp-file in Wordpad
	if ispc && showexp
		dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
	end
end
function writeexp4(expfile,datdir,T,P,int)
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
fid         = fopen(expfile,'w');
ntrials     = size(T,1);

%% Header of exp-file
ITI			= [0 0];
Ntrls		= ntrials;
Rep			= 1;
Rnd			= 0;
Mtr			= 'n';
writeheader(fid,datdir,ITI,Ntrls,Rep,Rnd,Mtr)

%% Body of exp-file
% Create a trial for
for i               = 1:ntrials		% each location
	writetrl(fid,i);
	writesnd(fid,'SND1',T(i),P(i),99,int(i),0,0); % Sound on
	writesnd(fid,'SND1',T(i),P(i),99,int(i),0,0); % Sound on
end

fclose(fid);

