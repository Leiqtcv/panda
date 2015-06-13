function DblSndskoerding
close all
clear all
clc

%% Initialization
sa = 11.5; % Auditory
sv = 11.2; % Visual
sp = 20; % Common source
pc = 0.95;
V      = -50:15:70;
A      = -50:15:70;
[V,A] = meshgrid(V,A);
V      = V(:);
A      = A(:);
sel = A==V;
A = A(~sel);
V = V(~sel);

if nargin<7
	Nrep = 100000; % Number of repetitions in Monte Carlo
end
%% Monte Carlo Generative Model
% Simulate Nrep number of trials per AV-condition
% Each trial yields an internal estimate of the auditory, xa, or visual
% stimulus, xv. These estimates are generated according to the generative
% model (see Koerding et al. 2007).

Ncond   = length(V);        % Number of AV-conditions
xv      = NaN(Nrep,Ncond);  % Internal Representation of Visual Stimulus
xa      = xv;               % Internal Representation of Auditory Stimulus
Aall    = xv;               % Actual A Stimulus per trial
Vall    = xv;               % Actual V Stimulus per trial
for i = 1:Ncond
	v               = sv.*randn(Nrep,1)+V(i);
	a               = sa.*randn(Nrep,1)+A(i);
	xv(1:Nrep,i)    = v;
	xa(1:Nrep,i)    = a;
	Vall(1:Nrep,i)  = V(i);
	Aall(1:Nrep,i)  = A(i);
end

%% Estimating the Probability of a common cause
% Likelihood of common cause; probability of xa and xv occurring given a
% common cause
pxvxaGc1 = (1./(2*pi*sqrt(sv^2*sa^2+sv^2*sp^2+sa^2*sp^2))) * exp( -((xv-xa).^2*sp^2+xv.^2*sa^2+xa.^2*sv^2)./(2.*(sv^2*sa^2+sv^2*sp^2+sa^2*sp^2)) );
% Likelihood of separate cause; probability of xa and xv occurring given a
% separate cause
pxvxaGc2 = 1./(2*pi*sqrt((sv^2+sp^2)*(sa^2*sp^2))) * exp( -0.5 .*(xv.^2./(sv^2+sp^2) + xa.^2./(sa^2+sp^2) ) );
% Inference following Bayes' rule:
pc1Gxvxa = pxvxaGc1.*pc ./ (pxvxaGc1.*pc+pxvxaGc2.*(1-pc));

%% Optimally estimating the position
estVGc2 = (xv./sv^2)./(1/sv^2+1/sp^2);
estAGc2 = (xa./sa^2)./(1/sa^2+1/sp^2);
estVGc1 = (xv./sv^2+xa./sa^2)./(1/sv^2+1/sp^2+1/sa^2);
estAGc1 = estVGc1;

estV    = pc1Gxvxa.*estVGc1+(1-pc1Gxvxa).*estVGc2;
estA    = pc1Gxvxa.*estAGc1+(1-pc1Gxvxa).*estAGc2;

D = abs(A-V);
uD = unique(D);
x = -1:0.01:2;
for i = 1:length(uD)
	sel = D==uD(i);
	T1 = V(sel);
	T2 = A(sel);
	R1 = estV(:,sel);
	R2 = estA(:,sel);
	AVG = 0.5*R1+0.5*R2;
	T1 = repmat(T1',size(R1,1),1);
	T2 = repmat(T2',size(R1,1),1);
	AVG = (AVG-T1)./(T2-T1);
	AVG = AVG(:);

	R1 = (R1-T1)./(T2-T1);
	R2 = (R2-T1)./(T2-T1);
	est = [R1;R2];
	est = est(:);
	
	figure(1)
	subplot(3,3,i)
	N=hist(est,x);
	N = N./sum(N);
	h=	plot(x,N);set(h,'LineWidth',2,'Color','g');
	hold on
	xlim([-0.5 1.5]);
% 	ylim([0 0.4]);
	title(['\Delta Elevation: ' num2str(uD(i)) ' (deg)']);
	axis square

	subplot(3,3,i)
	N=hist(AVG,x);
	N = N./sum(N);
	h=	plot(x,N);set(h,'LineWidth',2,'Color',[.5 .5 .5]);
	xlim([-0.5 1.5]);
% 	ylim([0 0.4]);
	title(['\Delta Elevation: ' num2str(uD(i)) ' (deg)']);
	axis square
	% subplot(3,3,9)
	% plot(x,N);
	% hold on
	% axis square
end

