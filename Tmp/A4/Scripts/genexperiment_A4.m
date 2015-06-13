function genexperiment_A4(nrgridpoints,nrloc,id,int,minled,maxled,expfile,datdir,minsnd,maxsnd)
% GENEXPERIMENT Generate exp-file with random locations and timings
%
% GENEXPERIMENT(NRGRID,NRLOC,ID,INT,MINLED,MAXLED,FNAME,DATDIR,MINSND,MAXSND)

%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
datdir              = 'DAT';


% %% Session 1
% Nrep	= 1; % short 10, long: 3
% load Stimuli_Matrices3
% Az = saz;
% El = sel;
% expfile = 'A4_1_10.exp';

% Nrep	= 1; % short 10, long: 3
% load Stimuli_Matrices3
% Az=M1az;
% El = M1el;
% expfile = 'A4_1_30.exp';
% 
% Nrep	= 1; % short 10, long: 3
% load Stimuli_Matrices3
% Az=L11az;
% El=L11el;
% expfile = 'A4_1_50_1.exp';
% 
% Nrep	= 1; % short 10, long: 3
% load Stimuli_Matrices3
% Az=L12az;
% El=L12el;
% expfile = 'A4_1_50_2.exp';
% 
% % Session 2

% Nrep	= 1; % short 10, long: 3
% load Stimuli_Matrices3
% Az = saz;
% El = sel;
% expfile = 'A4_2_10.exp';
% 
% Nrep	= 1; % short 10, long: 3
% load Stimuli_Matrices3
% Az=M2az;
% El = M2el;
% expfile = 'A4_2_30.exp';
% 
% Nrep	= 1; % short 10, long: 3
% load Stimuli_Matrices3
% Az=L21az;
% El=L21el;
% expfile = 'A4_2_50_1.exp';
% 
% Nrep	= 1; % short 10, long: 3
% load Stimuli_Matrices3
% Az=L22az;
% El=L22el;
% expfile = 'A4_2_50_2.exp';
% % 
% 
% % Session 3
% 
% Nrep	= 1; % short 10, long: 3
% load Stimuli_Matrices3
% Az = saz;
% El = sel;
% expfile = 'A4_3_10.exp';

% Nrep	= 1; % short 10, long: 3
% load Stimuli_Matrices3
% Az=M3az;
% El = M3el;
% expfile = 'A4_3_30.exp';
% 
% Nrep	= 1; % short 10, long: 3
% load Stimuli_Matrices3
% Az=L31az;
% El=L31el;
% expfile = 'A4_3_50_1.exp';
% 
Nrep	= 1; % short 10, long: 3
load Stimuli_Matrices3
Az=L32az;
El=L32el;
expfile = 'A4_3_50_2_test.exp';



[phi] = pa_azel2fartR(El);            %not used, messes up azimuth
                                            % coordinates, the coordinates 
                                            % are already in adequate ranges, 
                                            %no need to adjust them
                                            
                                            %Ja das haette ich gerne, das
                                            %Problem ist, dass die
                                            %Elevation coord. wohl
                                            %umgesetzt werden muessen. Da
                                            %muss ich mir noch was
                                            %ueberlegen...
                                        %Tadaa, ich hab eine eigene
                                        %pa_azel2fartR gemacht und hab
                                        %Azimuth rausgeworfen. Nur
                                        %elevation wird angepasst, azimuth
                                        %behaelt seine richtigen Werte
                                    
R = Az;
phi = phi';
R		= repmat(R,Nrep,1);
phi		= repmat(phi,Nrep,1);
% El = 
% close all
% plot(Az,El,'.')
% plotfart
% R = 0;
% rng = 2;
% phi = 12-rng:12+rng
% 
% [R,phi]=meshgrid(R,phi);
% R = R(:)';
% phi = phi(:)';
% [Az,El] = fart2azel(R,phi);

close all
plot(Az,El,'.')
% pa_plotfart;
xlim([-55 55])
ylim([-55 55])
%% Randomize
% Get random timings
minled = 100;
maxled = 300;
ledon                = pa_rndval(minled,maxled,size(R));

R					 = R(:);
phi                  = phi(:);
ledon                = ledon(:);

% Randomize
rnd                 = randperm(length(R));
R					= R(rnd);
phi                 = phi(rnd);
ledon               = ledon(rnd);

plot(1:length(R),phi)

% marc
writeexp(expfile,datdir,R,phi,ledon);
%% Show the exp-file in Wordpad
if ispc
	dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' expfile ' &']);
end

function [azimuth,elevation,dAz,dEl]=getgrid(nrgridpoints,lngsquare)
% GETGRID Generate grid-positions
%
% GETGRID(NRGRID,RANGE)
% Generate a grid of equidistant NRGRID*NRGID locations, with NRGID
% azimuths and NRGRID elevations. The total range of azimuths or elevations
% will be chosen from RANGE-2*DAZ/DEL deg (default: sqrt(2*90^2) -> DAZ and
% DEL will be -25.4558 deg).
%
% GETGRID is commonly used for GENEXPERIMENT, to create a square grid that
% is subsequently rotated by 45 deg to fit the double-polar coordinate
% system.
%
% Example
% To create a grid of 5 azimuth locations and 5 elevation
% locations, rotate the matrix to fit the double polar system, and plot
% these locations:
%   [azimuth, elevation] = getgrid(5);
%   [azimuth, elevation]= rotategrid(azimuth,elevation,45);
%   cla;
%   plotfart;
%   hold on;
%   h = plot(azimuth,elevation,'ko');
%   set(h,'MarkerFaceColor','w');
%   xlabel('Azimuth (deg)'); ylabel('Elevation (deg)');
%
% See also GENEXPERIMENT

% Author MW
% Copyright 2007

if nargin<2
	lngsquare       = sqrt(2*90^2);
end
dAz                 = lngsquare/nrgridpoints;   % deg
dEl                 = lngsquare/nrgridpoints;   % deg
az                  = -(lngsquare/2-dAz/2):dAz:(lngsquare/2-dAz/2);
el                  = -(lngsquare/2-dEl/2):dEl:(lngsquare/2-dEl/2);
[azimuth,elevation] = meshgrid(az,el);

function writeexp(expfile,datdir,theta,phi,ledon)
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
% theta=theta(1:25,1);

expfile		= pa_fcheckext(expfile,'.exp');
fid         = fopen(expfile,'w');
ntrials     = size(theta,1);

%% Header of exp-file
ITI			= [0 0];
Rep			= 1;
Rnd			= 1;
Mtr			= 'y';
writeheader(fid,datdir,ITI,ntrials,Rep,Rnd,Mtr)
theta = round(theta);
%% Body of exp-file
% Create a trial for
n = 0;
for i               = 1:ntrials		% each location
	n = n+1;
	writetrl(fid,i);
	writelas(fid,'LAS',8,0,0,1,ledon(i),0); % fixation LED
% 	writeled(fid,'LED',0,12,1,0,0,1,ledon(i)); % fixation LED
% 	
	writetrg(fid,1,2,0,0,1);	% Button trigger after LED has been fixated
	writeacq(fid,1,ledon(i));	% Data Acquisition immediately after fixation LED exinction
	writesnd(fid,'SND1',round(theta(i)),phi(i),pa_rndval(901,919,1),55,1,ledon(i)+200); % Sound on
	
end
fclose(fid);

