function pa_genexp_ventriloquist_aftereffect_control


%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');

% Default input
minled      = 300;
maxled      = 800;
snd			= 1:8;
expfile     = 'baseline_aftereffect_low.exp';

datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp                         = 1;
close all

ring		= [7 5 3 2 4 6];
spoke		= [3*ones(1,3) 9*ones(1,3)];

[ring,~]	= meshgrid(ring,snd);
[spoke,snd] = meshgrid(spoke,snd);
ring		= ring(:);
snd			= snd(:);
spoke		= spoke(:);


[az,el] = pa_sky2azel(ring,spoke);
az		= az-7;

%% Graphics
close all
plot(az,el,'ks');
hold on
axis([-90 90 -90 90])
pa_verline([-5 0 5]);
axis square;
% return
% keyboard

[theta,phi] = pa_azel2fart(az,el);

%% Randomize
% Get random timings
ledon                = pa_rndval(minled,maxled,size(theta));
sndon                = pa_rndval(minsnd,maxsnd,size(theta));


% Randomize
rnd                 = randperm(length(theta));
theta               = theta(rnd);
phi                 = phi(rnd);
snd                 = snd(rnd);
ledon               = ledon(rnd);
sndon               = sndon(rnd);
theta				= round(theta);
pa_datadir
writeexp4(expfile,datdir,theta,phi,snd,ledon,sndon);
% tmp(expfile,datdir,theta,phi,id,int,ledon,sndon,dummy,nrd);
%% Show the exp-file in Wordpad
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end


function writeexp4(expfile,datdir,theta,phi,snd,ledon,sndon)
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
Rep			= 3;
Rnd			= 1;
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

