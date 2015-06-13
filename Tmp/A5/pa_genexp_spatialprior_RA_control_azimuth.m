function pa_genexp_spatialprior_RA_control_3_elevation
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
snd			= 8;
expfile     = ['spatialprior_A5_control_3_elevation.exp'];
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = 0;

%% Stimuli
n = 400;
x = 1:n;
freq	= 0.01; % 1 cycle per 100 trials
sdel		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
sdaz		= repmat(22.5,size(x));
az = NaN(size(sdaz));
el = az;
for ii = 1:n
	az(ii) = 0;
	el(ii) = 5*round(sdel(ii)*randn(1)/5);
	while abs(az(ii))+abs(el(ii))>90 || el(ii)<-55 || el(ii)>85 || abs(az(ii))>90
	az(ii) =0;
	el(ii) = 5*round(sdel(ii)*randn(1)/5);
	end
	
end
% el = 5*round(el/5);
% az = el;
% az(:,:)=0;
el = 5*round(el/5);
az = round(az);
subplot(311)
plot(x,az,'k-');
hold on
[hp,hl] = pa_errorpatch(x,zeros(size(x)),sdaz,'r');
delete(hl);
xlabel('Trial number');
ylabel('Azimuth');
ylim([-90 90])

subplot(312)
plot(x,el,'k-');
hold on
[hp,hl] = pa_errorpatch(x,zeros(size(x)),sdel,'r');
delete(hl);
xlabel('Trial number');
ylabel('Elevation');
ylim([-90 90])
pa_horline([-55, 85],'r--');

subplot(313)
plot(x,sqrt(el.^2+az.^2),'k-');
hold on
plot(x,sdel,'r-','LineWidth',2);
xlabel('Trial number');
ylabel('Elevation');
ylim([0 90])

%% Graphics
figure
pa_bubbleplot(az,el,40,5);
hold on
axis([-90 90 -90 90])
axis square;

[theta,phi] = pa_azel2fart(az,el);
theta
%% Randomize
% Get random timings
ledon                = pa_rndval(minled,maxled,size(theta));
sndon                = pa_rndval(minsnd,maxsnd,size(theta));


% % Randomize
% rnd                 = randperm(length(theta));
% theta               = theta(rnd);
% phi                 = phi(rnd);
% ledon               = ledon(rnd);
% sndon               = sndon(rnd);

snd				= repmat(snd,size(theta));
% snd               = snd(rnd);
% theta				= round(theta);

pa_datadir
writeexp(expfile,datdir,theta,phi,snd,ledon,sndon);
% tmp(expfile,datdir,theta,phi,id,int,ledon,sndon,dummy,nrd);
%% Show the exp-file in Wordpad
if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end


function writeexp(expfile,datdir,theta,phi,snd,ledon,sndon)
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
ntrials     = numel(theta)

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
% 	writeled(fid,'SKY',0,1,5,0,0,1,ledon(ii)); % fixation LED
	writelas(fid,'LAS',8,0,0,1,ledon(ii),0); % fixation LED
    
	writetrg(fid,1,2,0,0,1);		% Button trigger after LED has been fixated
	writeacq(fid,1,ledon(ii));	% Data Acquisition immediately after fixation LED exinction
	
	writesnd(fid,'SND1',round(theta(ii)),phi(ii),snd(ii),45,1,ledon(ii)+sndon(ii)); % Sound on
% 	writeled(fid,'SKY',spoke(ii),ring(ii),50,1,ledon(ii)+sndon(ii),1,ledon(ii)+sndon(ii)+150); % Sound on



end
fclose(fid);

