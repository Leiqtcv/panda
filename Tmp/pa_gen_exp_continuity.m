function tmp

%% Clean

close all
clear all

%% Noise
gwn = pa_gengwn(3);
gwn = pa_ramp(gwn);

%% Burst/target
brst	= pa_gengwn(0.02);

%% Some parameters
Fs		= 48828.125;
t		= 1.5; % onset of burst
s		= round(t*Fs);
n		= length(brst);
Nbits = 16; % TDT maximal bit depth for WAVs

%% Make sure burst is the same shape as in noise
gwn(s+1:s+n) = brst;
snd		= repmat(gwn,1,5);
brst	= pa_ramp(brst);
for ii = 1:4
	snd(s+1:s+n,1+ii) = gwn(s+1:s+n)-ii*0.25*brst; % with varying amplitudes
end

tar				= zeros(size(gwn));
tar(s+1:s+n)	= brst;
tar				= pa_fart_levelramp(tar);

ruis			= NaN(length(tar),5);
for ii = 1:5
	ruis(:,ii) = pa_fart_levelramp(snd(:,ii));
end

%% Prevent clipping
tar = tar/5;
ruis = ruis/5;


%% Graph
subplot(311)
plot(ruis(:,1))

subplot(312)
plot(tar)

subplot(313)
plot(ruis(:,2)-ruis(:,1))


%% Save wav-files
pa_datadir
	fname = ['snd000.wav'];
	wavwrite(tar,Fs,Nbits,fname);
for ii = 1:5
	fname = ['snd00' num2str(ii) '.wav'];
	wavwrite(ruis(:,ii),Fs,Nbits,fname);
end

%% Gen exp
az = 0;
el = [-50:10:-10 10:10:50];
[az,el] = meshgrid(az,el);
az = az(:);
el = el(:);

[theta,phi] = pa_azel2fart(az,el);
theta		= round(theta);

id = 1:5;
[theta,~] = meshgrid(theta,id);
[phi,id] = meshgrid(phi,id);
theta = theta(:);
id = id(:);
phi = phi(:);
whos theta id phi

rnd                 = randperm(length(theta));

theta = theta(rnd);
phi = phi(rnd);
id = id(rnd);

pa_datadir
expfile = 'spatcontill.exp';
datdir      = 'DAT';

writeexp(expfile,datdir,theta,phi,id);
%% Show the exp-file in Wordpad
% if ispc && showexp
    dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
% end


function writeexp(expfile,datdir,theta,phi,snd)
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
ntrials     = numel(theta);

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
	writeled(fid,'LED',0,12,5,0,0,1,1300); % fixation LED
	
	writetrg(fid,1,2,0,0,1);	% Button trigger after LED has been fixated
	writeacq(fid,1,0);	% Data Acquisition immediately after fixation LED exinction
	
	writesnd(fid,'SND1',0,phi(ii),0,70,1,0); % Sound on
	writesnd(fid,'SND2',0,12,snd(ii),70,1,0); % Sound on
end
fclose(fid);


