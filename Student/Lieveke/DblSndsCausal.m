function DblSndsCausal
close all
clear all
clc

%% Initialization
sa		= 11; % Sigma of auditory stimulus
pD		= 0.95;
A1      = -50:15:70;
A2      = -50:15:70;
[A1,A2] = meshgrid(A1,A2);
A1      = A1(:);
A2      = A2(:);
sel		= A1==A2;
A1		= A1(~sel);
A2		= A2(~sel);

if nargin<7
	Nrep = 10000; % Number of repetitions in Monte Carlo
end

%% Monte Carlo Generative Model
% Simulate Nrep number of trials per AV-condition
% Each trial yields an internal estimate of the auditory, xa, or visual
% stimulus, xv. These estimates are generated according to the generative
% model (see Koerding et al. 2007).

Ncond				= length(A1);        % Number of AV-conditions
x1					= NaN(Nrep,Ncond);  % Internal Representation of Visual Stimulus
x2					= x1;               % Internal Representation of Auditory Stimulus
S1					= x1;               % Actual A Stimulus per trial
S2					= x2;               % Actual V Stimulus per trial
for i				= 1:Ncond
	a1              = sa.*randn(Nrep,1)+A1(i);
	a2              = sa.*randn(Nrep,1)+A2(i);
	x1(1:Nrep,i)    = a1;
	x2(1:Nrep,i)    = a2;
	S1(1:Nrep,i)	= A1(i);
	S2(1:Nrep,i)	= A2(i);
end

%% Estimating the Probability of a common cause
% Likelihood of common cause; probability of xa and xv occurring given a
% common cause
px1Gc1				= (1/(2*pi*sa)) * exp (-.5 * x1.^2/sa^2);
px2Gc1				= (1/(2*pi*sa)) * exp (-.5 * x2.^2/sa^2);

% Likelihood of separate cause; probability of xa and xv occurring given a
% separate cause
px1x2Gc2			= (1/(2*pi*sa*sa)) * exp (-.5 * (x1.^2/sa^2 + x2.^2/sa^2));
% Inference following Bayes' rule:
pc2Gx1x2			= px1x2Gc2.*pD ./ (px1x2Gc2.*pD+px1Gc1.*((1-pD)/2)+px2Gc1.*((1-pD)/2));


R			= x1;
sel			= pc2Gx1x2>0.5;
R(~sel)		= 0.5*x1(~sel)+0.5*x2(~sel);

D = abs(A1-A2);
uD = unique(D);
x = -1:0.1:2;
for i = 1:length(uD)
	sel = D==uD(i);

	figure(1)
	subplot(3,3,i)
	N=hist(R(sel),x);
	N = N./sum(N);
	bar(x,N,1);
% 	xlim([-0.5 1.5]);
% 	ylim([0 0.2]);
	title(['\Delta Elevation: ' num2str(uD(i)) ' (deg)']);
	axis square

end


return
% 
% whos x1 x2 pc2Gx1x2
% figure(3)
% plot(pc2Gx1x2(:));
% axis square;
% hold on
% horline(0.5);
% 
% %% Optimally estimating the position
% est1Gc1 = (x1./sa^2)./(1/sa^2);
% est2Gc1 = (x2./sa^2)./(1/sa^2);
% est1Gc2 = (x1./sa^2+x2./sa^2)./(1/sa^2+1/sa^2);
% est2Gc2 = est1Gc2;
% 
% estV    = pc2Gx1x2.*est1Gc1+(1-pc2Gx1x2).*est1Gc2;
% estA    = pc2Gx1x2.*est2Gc1+(1-pc2Gx1x2).*est2Gc2;

D = abs(A1-A2);
uD = unique(D);
x = -1:0.1:2;
for i = 1:length(uD)
	sel = D==uD(i);
	T1 = A1(sel);
	T2 = A2(sel);
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
	bar(x,N,1);
	xlim([-0.5 1.5]);
	ylim([0 0.2]);
	title(['\Delta Elevation: ' num2str(uD(i)) ' (deg)']);
	axis square

	figure(2)
	subplot(3,3,i)
	N=hist(AVG,x);
	whos N
	N = N./sum(N);
	bar(x,N,1);
	xlim([-0.5 1.5]);
	ylim([0 0.2]);
	title(['\Delta Elevation: ' num2str(uD(i)) ' (deg)']);
	axis square
	% subplot(3,3,9)
	% plot(x,N);
	% hold on
	% axis square
end

