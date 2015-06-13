function pa_genexp_spatialprior
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
expfile     = ['spatialprior.exp'];
datdir      = 'DAT';
minsnd      = 200;
maxsnd      = 200;

%% Some Flags
showexp     = 0;

%% Stimuli
n = 400;
x = 1:n;
freq	= 0.001; % 1 cycle per 100 trials
sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
sd = repmat(45,size(sd));


az = NaN(size(sd));
el = az;
for ii = 1:n
	az(ii) = 5*round(sd(ii)*randn(1)/5);
	el(ii) = 5*round(sd(ii)*randn(1)/5);
	while abs(az(ii))+abs(el(ii))>90 || el(ii)<-55 || el(ii)>85 || abs(az(ii))>90
	az(ii) = 5*round(sd(ii)*randn(1)/5);
	el(ii) = 5*round(sd(ii)*randn(1)/5);
	end
	
end
el = 5*round(el/5);
az = round(az);
subplot(311)
plot(x,az,'k-');
hold on
[hp,hl] = pa_errorpatch(x,zeros(size(x)),sd,'r');
delete(hl);
xlabel('Trial number');
ylabel('Azimuth');
ylim([-90 90])

subplot(312)
plot(x,el,'k-');
hold on
[hp,hl] = pa_errorpatch(x,zeros(size(x)),sd,'r');
delete(hl);
xlabel('Trial number');
ylabel('Elevation');
ylim([-90 90])
pa_horline([-55, 85],'r--');

subplot(313)
plot(x,sqrt(el.^2+az.^2),'k-');
hold on
plot(x,sd,'r-','LineWidth',2);
xlabel('Trial number');
ylabel('Elevation');
ylim([0 90])

x = -180:180;
likelihoodsd = 5;

figure
for ii = 1:length(el);
% 	for ii = 1:200
	target		= el(ii)+likelihoodsd*randn;
	likelihood	= normpdf(x,target,likelihoodsd);
	
	if ii == 1
		priormu = 0;
		priorsd = 45;

		prior		= normpdf(x,priormu,priorsd);
	else
		priormu		= posteriormu;
		priorsd		= posteriorsd;
		prior		= normpdf(x,priormu,priorsd);
		
	end
% 		posterior	= prior.*likelihood;
% 		posterior1	= posterior/sum(posterior);
	posteriorsd = sqrt(((priorsd^2)*(likelihoodsd^2))/((priorsd^2)+(likelihoodsd^2)));
	posteriormu = (priorsd^2)*target/(priorsd^2+likelihoodsd^2)+(likelihoodsd^2)*priormu/(priorsd^2+likelihoodsd^2);
	posterior	= normpdf(x,posteriormu,posteriorsd);
	gain(ii)	= 1-(likelihoodsd^2)/(priorsd^2);
	
% 		[priorsd likelihoodsd posteriorsd gain(ii)]

	P(ii) = priorsd;
	clf
	plot(x,likelihood,'r-','LineWidth',2);
	hold on
	plot(x,prior,'k-','LineWidth',2);
	plot(x,posterior,'b-','LineWidth',3);
% 		plot(x,posterior1,'m-','LineWidth',2);

	xlim([-70 70]);
	title(gain(ii));
% 		pause(.5)
	drawnow
end

figure;plot(P)
% keyboard