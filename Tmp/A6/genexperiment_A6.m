function genexperiment_A6(nrgridpoints,nrloc,id,int,minled,maxled,expfile,datdir,minsnd,maxsnd)
% GENEXPERIMENT Generate exp-file with random locations and timings
%
% GENEXPERIMENT(NRGRID,NRLOC,ID,INT,MINLED,MAXLED,FNAME,DATDIR,MINSND,MAXSND)
close all
clear all
%% Initialization
home;
disp('>> GENERATING EXPERIMENT <<');
datdir              = 'DAT';



Nrep	= 1; % short 10, long: 3
load A6_Stimuli_Matrices
AzL=L(:,1);
ElL=L(:,2);

% AzS=S(:,1);
% ElS=S(:,2);
expfile = 'A6_SLj.exp';



[phi] = pa_azel2fartR(ElL);            %not used, messes up azimuth
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
                                    
R = AzL;
phi = phi';
R		= repmat(R,Nrep,1);
phi		= repmat(phi,Nrep,1);


close all
plot(AzL,ElL,'.')
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



%% Second Part

Nrep	= 1; % short 10, long: 3
load A6_Stimuli_Matrices

AzS=S(:,1);
ElS=S(:,2);
% expfile = 'A6_LS.exp';



[phi1] = pa_azel2fartR(ElS);            %not used, messes up azimuth
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
                                    
R1 = AzS;
phi1 = phi1';
R1		= repmat(R1,Nrep,1);
phi1		= repmat(phi1,Nrep,1);

close all
plot(AzL,ElL,'.')
xlim([-65 65])
ylim([-65 65])

%% Randomize
% Get random timings
minled = 100;
maxled = 300;
ledon1                = pa_rndval(minled,maxled,size(R));

R1					 = R1(:);
phi1                  = phi1(:);
ledon1                = ledon1(:);

% Randomize
rnd1                 = randperm(length(R1));
R1					= R1(rnd);
phi1                 = phi1(rnd);
ledon1               = ledon1(rnd);


%%Together
% Large to Small (Change Name accordingly!!)
% R = [R;R1];
% phi = [phi;phi1];
% ledon = [ledon;ledon1];

% %Small to Large (Change Name accordingly!!)
R = [R1;R];
phi = [phi1;phi];
ledon = [ledon1;ledon];

whos R phi
figure
plot (1:length(phi),phi)


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
Rnd			= 0;
Mtr			= 'n';
writeheader(fid,datdir,ITI,ntrials,Rep,Rnd,Mtr)
theta = round(theta);
%% Body of exp-file
% Create a trial for
n = 0;
for i               = 1:ntrials		% each location
	n = n+1;
	writetrl(fid,i);
% 	writelas(fid,'LAS',8,0,0,1,ledon(i),0); % fixation LED
	writeled(fid,'LED',0,12,1,0,0,1,ledon(i)); % fixation LED
% 	
	writetrg(fid,1,2,0,0,1);	% Button trigger after LED has been fixated
	writeacq(fid,1,ledon(i));	% Data Acquisition immediately after fixation LED exinction
	writesnd(fid,'SND1',round(theta(i)),phi(i),pa_rndval(901,919,1),55,1,ledon(i)+200); % Sound on
	
end
fclose(fid);

