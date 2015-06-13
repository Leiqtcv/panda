function gendouble_2D_dT_setting5_exp
close all
% Author MW
% Copyright 2007

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
showexp             = 1;

expfile = 'double_dt_2d_setting5.exp';
Fs          = 48828.125;

datdir				= 'DAT';
int					= 54;
minled              = 100;
maxled              = 300;
minsnd              = 100;
maxsnd				= 100;
Nrep				= 5;
dT					= [-2 0 2]; % ms
dT					= round(dT*Fs/1000); %samples

%% Round I
A		= [-45 -22 10 45];
[A,dT] = meshgrid(A,dT);
A		= A(:);
E		= repmat(30,size(A));
dT		= dT(:);

[T,P]	= azel2fart(A,E);
T1		= T;
P1		= P;
dT1		= dT;

%% graphics
uAE = unique([A E],'rows');
for ii = 1:length(uAE)
plot([-22 uAE(ii,1)],[-14 uAE(ii,2)],'ko-');
hold on
end
axis([-90 90 -90 90]);
axis square
horline;
verline;


%% Round II
A		= [-45 -10 13 45];
[A,dT]	= meshgrid(A,dT);
A		= A(:);
E		= repmat(-40,size(A));
dT		= dT(:);

[T,P]	= azel2fart(A,E);

%% graphics
uAE = unique([A E],'rows');
for ii = 1:length(uAE)
plot([13 uAE(ii,1)],[23 uAE(ii,2)],'ko-');
hold on
end
axis([-90 90 -90 90]);
axis square
horline;
verline;

%% Merge
T	= [T1; T];
P	= [P1; P];
dT	= [dT1; dT];
T		= round(T);

%% Singles
Asingle1		= [-45 -22 10 45];
Asingle1		= Asingle1(:);
Esingle1		= repmat(30,size(Asingle1));

Asingle2		= [-45 -10 13 45];
Asingle2		= Asingle2(:);
Esingle2		= repmat(-40,size(Asingle2));

Asingle = [Asingle1;Asingle2];
Esingle = [Esingle1;Esingle2];

[Tsingle,Psingle]	= azel2fart(Asingle,Esingle);
Tsingle		= round(Tsingle);

%% Replicate
P		= repmat(P,Nrep,1);
T		= repmat(T,Nrep,1);
dT		= repmat(dT,Nrep,1);

Psingle		= repmat(Psingle,Nrep,1);
Tsingle		= repmat(Tsingle,Nrep,1);

%% Randomize
indx        = randperm(length(T));
T			= T(indx);
P			= P(indx);
dT			= dT(indx);

indx        = randperm(length(Tsingle));
Tsingle			= Tsingle(indx);
Psingle			= Psingle(indx);

%% Write
marc
writeexp4(expfile,datdir,T,P,dT,Tsingle,Psingle);
%% Show the exp-file in Wordpad
if ispc && showexp
	dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end

function writeexp4(expfile,datdir,T,P,dT,Tsingle,Psingle)
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
ntrials     = size(T,1);
ntrials2     = size(Tsingle,1);

minled		= 100;
maxled		= 300;
%% Header of exp-file
ITI			= [0 0];
Ntrls		= ntrials+ntrials2;
Rep			= 1;
Rnd			= 2;
Mtr			= 'y';

%%
fid				= fopen(expfile,'w');
writeheader(fid,datdir,ITI,Ntrls,Rep,Rnd,Mtr)

%% Body of exp-file
% Create a trial for
for i               = 1:ntrials		% each location
	ledon = rndval(minled,maxled,1);
	writetrl(fid,i);
	writeled(fid,'SKY',0,2,1,0,0,1,ledon); % fixation LED
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,ledon);	% Data Acquisition immediately after fixation LED exinction
	
	if dT(i)>=0
		int = getint(P(i));
		writesnd(fid,'SND1',T(i),30,116,int,1,ledon+100); % Sound on
		
		writesnd2(fid,'SND2',T(i),P(i),116,int,1,ledon+100,dT(i)); % Sound on
	else
		int = getint(P(i));
		writesnd2(fid,'SND2',T(i),30,116,int,1,ledon+100,-dT(i)); % Sound on
		
		writesnd(fid,'SND1',T(i),P(i),116,int,1,ledon+100); % Sound on
	end
% 	fprintf(fid,'%s\n','INP1');
% 	fprintf(fid,'%s\n','INP2');
end

for i               = 1:ntrials2		% each location
	ledon = rndval(minled,maxled,1);
	writetrl(fid,i);
	writeled(fid,'SKY',0,2,1,0,0,1,ledon); % fixation LED
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,ledon);	% Data Acquisition immediately after fixation LED exinction
	
	int = getint(Psingle(i));
	writesnd(fid,'SND1',Tsingle(i),Psingle(i),100+Psingle(i),int,1,ledon+100); % Sound on
% 	writesnd(fid,'SND2',Tsingle(i),29,100,0,1,ledon+100); % Sound on
	
% 	fprintf(fid,'%s\n','INP1');
% 	fprintf(fid,'%s\n','INP2');
end
fclose(fid);

function int = getint(loc)
switch loc
	case 9
		int = 54.0760;
	case 12
		int = 54.2294;
	case 16
		int = 54.0064;
	case 18
		int = 54.0064;
	case 30
		int = 55.6629;
	case 31
		int = 60.1519;
	otherwise
		int = 60;
end

function writesnd2(fid,SND,X,Y,ID,Int,EventOn,Onset,Offset)
% WRITESND(FID,SND,X,Y,ID,INT,EVENTON,ONSET)
%
% Write a SND-stimulus line in an exp-file with file identifier FID.
%
% SND		- 'SND1' or 'SND2'
% X			- SND theta angle
% Y			- SND phi number (1-29 and 101-129)
% ID		- Sound ID/attribute (000-999)
% INT		- SND Intensity (0-100)
% EVENTON	- The Event that triggers the onset of the SND (0 - start of
% trial)
% ONSET		- The Time after the On Event (msec)
%
% See also GENEXPERIMENT, FOPEN, and the documentation of the Auditory
% Toolbox
fprintf(fid,'%s\t%d\t%d\t%d\t%.1f\t%d\t%d\t%d\n',SND,X,Y,ID,Int,EventOn,Onset,Offset);
