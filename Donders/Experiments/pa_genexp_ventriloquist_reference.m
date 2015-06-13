function pa_genexp_ventriloquist_reference
% PA_GENEXP_VENTRILOQUIST_AFTEREFFECT
%
% This will generate an EXP-file of a ventriloquist-aftereffect
% experiment. EXP-files are used for the psychophysical experiments at the
% Biophysics Department of the Donders Institute for Brain, Cognition and
% Behavior of the Radboud University Nijmegen, the Netherlands.
% 
% See also the manual for the experimental set-ups at www.mbys.ru.nl/staff/m.vanwanrooij/neuralcode/manuals/audtoolbox.pdf.

% (c) 2012 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
% Default input
minled      = 100;
maxled      = 200;
snd			= 999;
expfile     = 'ventriloquist.exp';
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = 1;

%% Stimuli
A			= [-40:10:-30 -20:5:20 30:10:40];
D			= -20:10:20;
E			= -20:10:20;
[A,D,E]		= ndgrid(A,D,E);
A			= A(:);
D			= D(:);
E			= E(:);

%% Repeat
nrepeats	= 2;
A			= repmat(A,nrepeats,1);
D			= repmat(D,nrepeats,1);
E			= repmat(E,nrepeats,1);

%% Randomize
rnd     = randperm(length(A));
A		= A(rnd);
D		= D(rnd);
E		= E(rnd);

%% 
sel		= abs(A+D)<=50;
A		= A(sel);
D		= D(sel);
E		= E(sel);

unique([A D E],'rows')
%% Shift sounds
az			= zeros(size(A));
[theta,phi] = pa_azel2fart(az,A);
[theta,vphi] = pa_azel2fart(az,A+D);
[theta,E] = pa_azel2fart(az,E);


%% Get random timings
ledon		= pa_rndval(minled,maxled,size(phi));
sndon		= pa_rndval(minsnd,maxsnd,size(phi));



%% Write exp-file
pa_datadir
writeexp(expfile,datdir,phi,vphi,E,ledon,sndon);

%% Show the exp-file in Wordpad
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end


function writeexp(expfile,datdir,phi,vphi,E,ledon,sndon)
expfile		= pa_fcheckext(expfile,'.exp');

fid         = fopen(expfile,'w');
ntrials     = size(phi,1);

%% Header of exp-file
ITI			= [0 0];
Rep			= 1;
Rnd			= 0;
Mtr			= 'n';
writeheader(fid,datdir,ITI,ntrials*Rep,Rep,Rnd,Mtr)

%% Body of exp-file
% Create a trial for
n = 0;
for ii               = 1:ntrials		% each location
	writetrl(fid,ii);
	
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writetrg(fid,1,2,1,0,2);		% Button trigger after LED has been fixated

	writeled(fid,'LED',0,12,50,0,0,1,0); % fixation LED
	writeled(fid,'LED',0,E(ii),50,1,200,2,ledon(ii)); % fixation LED
	
	writeacq(fid,2,ledon(ii));	% Data Acquisition immediately after fixation LED exinction
	
	writesnd(fid,'SND1',0,phi(ii),999,45,2,ledon(ii)+200); % Sound on
	writeled(fid,'LED',0,vphi(ii),150,2,ledon(ii)+220,2,ledon(ii)+370); % fixation LED

end
fclose(fid);

