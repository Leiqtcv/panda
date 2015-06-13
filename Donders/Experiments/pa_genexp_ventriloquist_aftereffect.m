function pa_genexp_ventriloquist_aftereffect
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
minled      = 300;
maxled      = 800;
snd			= 8;
expfile     = ['Train' num2str(snd) 'low.exp'];
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = 0;

%% Stimuli
ring		= [7 5 3 2 4 6];
spoke		= [3*ones(1,3) 9*ones(1,3)];
[ring,~]	= meshgrid(ring,snd);
[spoke,snd] = meshgrid(spoke,snd);
ring		= ring(:);
snd			= snd(:);
spoke		= spoke(:);
[az,el]		= pa_sky2azel(ring,spoke);


%% Graphics
close all
plot(az,el,'rd');
hold on
plot(az-7,el,'ks');
legend('Vision','Audition');
axis([-90 90 -90 90])
pa_verline([-5 0 5]);
axis square;

%% Shift sounds
az			= az-7;
[theta,phi] = pa_azel2fart(az,el);

%% Randomize
% Get random timings
ledon		= pa_rndval(minled,maxled,size(theta));
sndon		= pa_rndval(minsnd,maxsnd,size(theta));
nrepeats	= 45;
THETA	= [];
PHI		= [];
SND		= [];
SPOKE	= [];
RING	= [];
LEDON	= [];
SNDON	= [];
for ii = 1:nrepeats
	% Randomize
	rnd                 = randperm(length(theta));
	
	% Repeats of training trials
	THETA               = [THETA;theta(rnd)]; %#ok<*AGROW>
	PHI                 = [PHI;phi(rnd)];
	SND                 = [SND;snd(rnd)];
	SPOKE               = [SPOKE;spoke(rnd)];
	RING                = [RING;ring(rnd)];
	LEDON               = [LEDON;ledon(rnd)];
	SNDON               = [SNDON;sndon(rnd)];
	

	if mod(ii,5)==0
	% Test trials
	THETA               = [THETA;theta(rnd)]; %#ok<*AGROW>
	PHI                 = [PHI;phi(rnd)];
	SND                 = [SND;snd(rnd)];
	SPOKE               = [SPOKE;spoke(rnd)];
	RING                = [RING;NaN(size(ring))];
	LEDON               = [LEDON;NaN(size(ring))];
	SNDON               = [SNDON;sndon(rnd)];	
	end
	
	
% 	pause(.2);
end
sel = isnan(RING);
	figure(2)
	trls				= 1:numel(THETA);
% 	plot(trls,THETA,'k-');
	hold on
	plot(trls(sel),THETA(sel),'ko','MarkerFaceColor',[.7 .7 .7],'Color',[.7 .7 .7]);
	plot(trls(~sel),THETA(~sel),'ko','MarkerFaceColor','k');
	
% Round
THETA				= round(THETA);

%% Write exp-file
pa_datadir
writeexp(expfile,datdir,THETA,PHI,SND,LEDON,SNDON,SPOKE,RING);

%% Show the exp-file in Wordpad
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end


function writeexp(expfile,datdir,theta,phi,snd,ledon,sndon,spoke,ring)
expfile		= pa_fcheckext(expfile,'.exp');

fid         = fopen(expfile,'w');
ntrials     = size(theta,1);

%% Header of exp-file
ITI			= [0 0];
Rep			= 1;
Rnd			= 0;
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
	if ~isnan(ring(ii))
	writeled(fid,'SKY',spoke(ii),ring(ii),50,1,ledon(ii)+sndon(ii)+20,1,ledon(ii)+sndon(ii)+170); % Sound on
	end
end
fclose(fid);

