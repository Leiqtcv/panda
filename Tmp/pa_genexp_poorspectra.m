function pa_genexp_poorspectra
% PA_GENEXP_SPATIALPRIOR
%
% This will generate an EXP-file of a spatial prior learning
% experiment. EXP-files are used for the psychophysical experiments at the
% Biophysics Department of the Donders Institute for Brain, Cognition and
% Behavior of the Radboud University Nijmegen, the Netherlands.
% 
% See also the manual for the experimental set-ups at www.mbys.ru.nl/staff/m.vanwanrooij/neuralcode/manuals/audtoolbox.pdf.
% See also WRITESND, WRITELED, WRITETRG, etc

% (c) 2012 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
close all
clear all;

% Default input
minled      = 300;
maxled      = 800;
expfile     = 'poorspectra.exp';
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = true;

%% Stimulus locations

% only in elevation
nsounds		= 3; % #types of sound
el			= [-50:25:-25 25:25:75];
m			= numel(el);
az			= zeros(size(el));
[theta,phi] = pa_azel2fart(az,el);
theta		= round(theta);

nrepeat		= 8;                    
phi		= repmat(phi(:),nrepeat,nsounds);

%% Plot stimuli

figure(1);								% the first figure we have today
plot(az',el','.-','MarkerSize',18);  % The actual targets in a plot
hold on;								% we want to plot more
axis square;							% publication-quality
box off;								% publication-quality
set(gca,'TickDir','out','TickLength',[0.005 0.025],...
	'XTick',-90:30:90,'YTick',-90:30:90,...
	'FontSize',15,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('Azimuth (deg)','FontSize',15);		% always provide an label on the x-axis
ylabel('Elevation (deg)','FontSize',15);	% and on the y-axis
pa_plotfart;								% plot the edges of the stimulus space
axis([-90 90 -90 90]);						% set axis limits, this can be maximally between -90 and +90 deg
title('different bandwidth'); % Provide all necessary information

%% By default, sounds are presented at various intensities
int			= 65; % this is approximately 40, 50 and 60 dBA, 3 levels

%% Now define the IDs of the sounds we want to use
% snd			= [repmat(100,1,) repmat(200,1,m*nrepeat) repmat(300,1,m*nrepeat)];
snd = zeros(size(phi));


snd(:,1) = snd(:,1)+100+pa_rndval(0,99,size(snd(:,1))); % 100 = 500-5500
snd(:,2) = snd(:,2)+200+pa_rndval(0,99,size(snd(:,2))); % 200 = 500-4000+5500-8000
snd(:,3) = snd(:,3)+300+pa_rndval(0,99,size(snd(:,3))); % 300 = 500-20000

snd		= snd(:);
phi = phi(:);
theta = zeros(size(phi));
%% Get random timings
% Again, randomization is a good thing. When does the LED go off after
% button press, when does the sound go off after LED extinction?
ledon                = pa_rndval(minled,maxled,size(theta));
% Choose a value that hinders the subjects to enter in a default mode.
sndon                = pa_rndval(minsnd,maxsnd,size(theta)); 
% By default 200 ms, this gap is usually sufficient to reduce fixation inhibition of reaction times of saccades. 

%% Randomize
rnd                 = randperm(length(theta));

whos 
theta               = theta(rnd);
phi                 = phi(rnd);
ledon               = ledon(rnd);
sndon               = sndon(rnd);
int					= repmat(int,size(theta));
snd					= snd(rnd);

%% Save data somewhere
pa_datadir; % Change this to your default directory
writeexp(expfile,datdir,theta,phi,snd,int,ledon,sndon); 
% see below, these are helper functions to write an exp-file line by line / stimulus by stimulus

%% Show the exp-file in Wordpad
% for PCs
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end

function writeexp(expfile,datdir,theta,phi,snd,int,ledon,sndon)
% Save known trial-configurations in exp-file
%
%WRITEEXP WRITEEXP(FNAME,DATDIR,THETA,PHI,ID,INT,LEDON,SNDON)
%
% WRITEEXP(FNAME,THETA,PHI,ID,INT,LEDON,SNDON)
%
% Write exp-file with file-name FNAME.
%
%
% See also manual at neural-code.com
expfile		= pa_fcheckext(expfile,'.exp'); % check whether the extension exp is included


fid         = fopen(expfile,'w'); % this is the way to write date to a new file
ntrials     = numel(theta); % only 135 trials

%% Header of exp-file
ITI			= [0 0];  % useless, but required in header
Rep			= 1; % we have 0 repetitions, so insert 1...
Rnd			= 0; % we randomized ourselves already
Mtr			= 'n'; % the motor should be on
writeheader(fid,datdir,ITI,ntrials*Rep,Rep,Rnd,Mtr); % helper-function

%% Body of exp-file
% Create a trial
for ii = 1:ntrials		% each location
	writetrl(fid,ii);
	writeled(fid,'LED',0,12,5,0,0,1,ledon(ii)); % fixation LED
	
	writetrg(fid,1,2,0,0,1);    % Button trigger after LED has been fixated
	writeacq(fid,1,ledon(ii));	% Data Acquisition immediately after fixation LED exinction
	
	
	if phi(ii)==1
		writesnd(fid,'SND1',0,12,0,int(ii),1,ledon(ii)+sndon(ii)); % Sound on
		writesnd(fid,'SND2',0,phi(ii),snd(ii),int(ii),1,ledon(ii)+sndon(ii)); % Sound on
	else
		writesnd(fid,'SND1',0,1,0,int(ii),1,ledon(ii)+sndon(ii)); % Sound on
		writesnd(fid,'SND2',0,phi(ii),snd(ii),int(ii),1,ledon(ii)+sndon(ii)); % Sound on
	end
end
fclose(fid);

