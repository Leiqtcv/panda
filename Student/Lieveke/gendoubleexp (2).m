function genowlcontrolexp
close all
% Author MW
% Copyright 2007

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
showexp             = 1;

for ii = 1
	expfile = ['double' num2str(ii) '.exp'];
	
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
	unique(p)
	T1		= round(t);
	P1		= round(p);
	T1		= repmat(T1,Nrep,1);
	P1		= repmat(P1,Nrep,1);
	
	az		= 0;
	el		= 0;
	[t,p]	= azel2fart(az,el);
	T2		= round(t);
	P2		= round(p);
	T2		= repmat(T2,Nrep,1);
	P2		= repmat(P2,Nrep,1);

	az		= 0;
	el		= [-40 -20 20 40];
	[az,el] = meshgrid(az,el);
	az		= az(:);
	el		= el(:);
	[t,p]	= azel2fart(az,el);
	T3		= round(t);
	P3		= round(p);
	T3		= repmat(T3,Nrep,1);
	P3		= repmat(P3,Nrep,1);

	T = [T1;T2;T3];
	P = [P1;P2;P3];
	S = [repmat(1,size(T1));repmat(2,size(T2));repmat(3,size(T3))];
	
	%% Randomize
	ledon                = rndval(minled,maxled,size(T));
	sndon                = rndval(minsnd,maxsnd,size(T));
	
	% Randomize
	rnd                 = randperm(length(T));
	T					= T(rnd);
	P					= P(rnd);
	S					= S(rnd);
	id					= repmat(101,size(T));
	int                 = repmat(int,size(T));
	ledon               = ledon(rnd);
	sndon               = sndon(rnd);
	
	marc
	
	writeexp4(expfile,datdir,T,P,S,id,int,ledon,sndon);
	%% Show the exp-file in Wordpad
	if ispc && showexp
		dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
	end
end
function writeexp4(expfile,datdir,T,P,S,id,int,ledon,sndon)
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
Ntrls	= ntrials;
Rep			= 1;
Rnd			= 2;
Mtr			= 'n';
writeheader(fid,datdir,ITI,Ntrls,Rep,Rnd,Mtr)

%% Body of exp-file
% Create a trial for
n = 0;
for i               = 1:ntrials		% each location
	n = n+1;
	writetrl(fid,i);
	if T(i)==0
		writeled(fid,'LED',0,12,1,0,0,1,ledon(i)); % fixation LED
	else
		writeled(fid,'SKY',0,2,10,0,0,1,ledon(i)); % fixation LED
	end
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,ledon(i));	% Data Acquisition immediately after fixation LED exinction
	if S(i)==1
	writesnd(fid,'SND1',T(i),P(i),id(i),int(i),1,ledon(i)+sndon(i)); % Sound on
	end
	if S(i)==2
	writesnd(fid,'SND2',T(i),P(i),id(i),int(i),1,ledon(i)+sndon(i)); % Sound on
	end
	if S(i)==3
	writesnd(fid,'SND1',T(i),P(i),id(i),int(i),1,ledon(i)+sndon(i)); % Sound on
	writesnd(fid,'SND2',T(i),P(i),id(i),int(i),1,ledon(i)+sndon(i)); % Sound on
	end
end

fclose(fid);

