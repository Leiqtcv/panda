function gendouble2dexp
close all
% Author MW
% Copyright 2007

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
showexp             = 1;

expfile = 'double2d_3.exp';

datdir				= 'DAT';
int					= 54;
minled              = 100;
maxled              = 300;
minsnd              = 100;
maxsnd				= 100;
Nrep				= 30;

% Sounds Double
p		= [8 20 30 31]';
P1		= [];
P2		= [];
for ii = 1:length(p)-1
	p2tmp	= p(ii+1:end);
	p1tmp	= repmat(p(ii),size(p2tmp));
	P2		= [P2;p2tmp]; %#ok<*AGROW>
	P1		= [P1;p1tmp];
end
T		= zeros(size(P1));
% Replicate
T	= repmat(T,Nrep,1);
P1	= repmat(P1,Nrep,1);
P2	= repmat(P2,Nrep,1);
% Randomize
indx        = randperm(length(T));
T = T(indx);
P1 = P1(indx);
P2 = P2(indx);

%% Sounds Single
Psingle = p;
Tsingle = zeros(size(Psingle));
% Replicate
Tsingle	= repmat(Tsingle,Nrep,1);
Psingle	= repmat(Psingle,Nrep,1);
% Randomize
indx        = randperm(length(Tsingle));
Tsingle = Tsingle(indx);
Psingle = Psingle(indx);

%% Randomize
ledon                = rndval(minled,maxled,size(T));
sndon                = rndval(minsnd,maxsnd,size(T));

% Randomize

marc

writeexp4(expfile,datdir,T,P1,P2,Tsingle,Psingle);
%% Show the exp-file in Wordpad
if ispc && showexp
	dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end

function writeexp4(expfile,datdir,T,P1,P2,Tsingle,Psingle)
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
ntrialsdouble     = size(T,1);
ntrialssingle     = size(Tsingle,1);
minled = 100;
maxled = 300;
%% Header of exp-file
ITI			= [0 0];
Ntrls		= ntrialsdouble+ntrialssingle;
Rep			= 1;
Rnd			= 2;
Mtr			= 'n';

%%
fid				= fopen(expfile,'w');
writeheader(fid,datdir,ITI,Ntrls,Rep,Rnd,Mtr)

%% Body of exp-file
% Create a trial for
for i               = 1:ntrialsdouble		% each location
	ledon = rndval(minled,maxled,1);
	writetrl(fid,i);
	writeled(fid,'LED',0,12,1,0,0,1,ledon); % fixation LED
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,ledon);	% Data Acquisition immediately after fixation LED exinction
	
	int = getint(P1(i));
	writesnd(fid,'SND1',T(i),P1(i),100+P1(i),int,1,ledon+100); % Sound on
	
	int = getint(P2(i));
	writesnd(fid,'SND2',T(i),P2(i),100+P2(i),int,1,ledon+100); % Sound on
	
	fprintf(fid,'%s\n','INP1');
	fprintf(fid,'%s\n','INP2');
end

for i               = 1:ntrialssingle		% each location
	ledon = rndval(minled,maxled,1);
	writetrl(fid,i+ntrialsdouble);
	writeled(fid,'LED',0,12,1,0,0,1,ledon); % fixation LED
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,ledon);	% Data Acquisition immediately after fixation LED exinction
	
	int = getint(Psingle(i));
	writesnd(fid,'SND1',Tsingle(i),Psingle(i),100+Psingle(i),int,1,ledon+100); % Sound on
	writesnd(fid,'SND2',Tsingle(i),12,100,0,1,ledon+100); % Sound on
	fprintf(fid,'%s\n','INP1');
	fprintf(fid,'%s\n','INP2');
end
fclose(fid);

function int = getint(loc)
switch loc
	case 12
		int = 54;
	case 8
		int = 56.4450;
	case 20
		int = 53.9945;
	case 30
		int = 64.8689;
	case 31
		int = 61.4274;
end
int = round(int);

