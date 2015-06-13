%% Clean
close all
clear all



%% Hemodynamic impulse response
Fs      = 10;
dur     = 50; % sec
xh       = 0:(1/Fs):dur; % sec
a1		= [6 8 6]; % peak time 4.5 s after stim, shape
b1		= [1 0.9 1]; % scale
a2		= [16 16 16]; % peak time 4.5 s after stim, shape
b2		= [1 1 1]; % scale
c		= [1/6 1/6 1/6];
% delta	= 2; % 2s delay
beta	= [1 0.5 -0.1];
Nstim	= length(beta);
sigma	= 1;
H = NaN(Nstim,length(xh));
for idx = 1:Nstim
H(idx,:)       = (gampdf(xh,a1(idx),b1(idx))-c(idx)*gampdf(xh,a2(idx),b2(idx)));
end


%% Convolution with stimulus block
Fs      = 10;
dur     = 600; % sec
xx       = 0:(1/Fs):dur; % sec
N		= length(xx);
xx		= xx(1:N);
X		= zeros(N,3);

onset		= [20 70 110 160 200 230 290 360 400 450 510 550];
offset		= [40 90 130 180 220 250 310 380 420 470 530 570];
mod			= [1 2 2 3 1 1 3 2 3 1 3 2];
Xsingle  = [ones(max((offset-onset)*Fs),1); zeros(min((onset(2:end)-offset(1:end-1))*Fs),1)];
Nmod		= numel(unique(mod));
Nblocks		= numel(onset);
for ii = 1:Nblocks
	X(onset(ii)*Fs:offset(ii)*Fs,mod(ii)) = 1;
end
% X((20*Fs:40*Fs),1)			= 1;
% X((70*Fs:90*Fs),2)			= 1;
% X((110*Fs:130*Fs),2)		= 1;
% X((160*Fs:180*Fs),3)		= 1;
% X((200*Fs:220*Fs),1)		= 1;
% X((230*Fs:250*Fs),1)		= 1;
% X((290*Fs:310*Fs),3)		= 1;
% X((360*Fs:380*Fs),2)		= 1;
% X((400*Fs:420*Fs),3)		= 1;
% X((450*Fs:470*Fs),1)		= 1;
% X((510*Fs:530*Fs),3)		= 1;
% X((550*Fs:570*Fs),2)		= 1;

X(:,1) = X(:,1) + X(:,3);
X(:,2) = X(:,2) + X(:,3);

C = NaN(N,Nstim);
for idx = 1:Nstim
       tmp			= conv(X(:,idx),beta(idx)*H(idx,:));
	   C(1:N,idx)	= tmp(1:N);
end

C = sum(C,2);
%% Sinusoid noise
s = 1*sin(2*pi*0.1*xx)';
C = C + s;

%% Convolution size parameters
u = X;
v = H;
m = length(u);
n = length(v);

%% Graph
figure(666)
subplot(131)
plot(xh,H)
xlabel('Time (s)');
ylabel('\Delta [OHb] (\muM)');
axis square
box off

subplot(132)
plot(xx,X);
axis square
box off

subplot(133)
plot(xx,C);
axis square
box off

drawnow

%% Data
y					= C+sigma*randn(size(C));
Fs					= 10;
dur					= 600; % sec
dataStruct.y		= y';
dataStruct.T		= xh';
dataStruct.u		= Xsingle; % stimulus  block
dataStruct.Ntotal	= length(y);
dataStruct.Nstim	=  Nblocks; % Nstim
dataStruct.onset	=  round(onset*Fs); % samples
dataStruct.offset	=  round(offset*Fs); % samples
% dataStruct.onset	=  onset; % Nstim

dataStruct.m		= length(Xsingle);
dataStruct.n		= length(xh);
dataStruct.o		= dataStruct.m+dataStruct.n-1

%% Test
	% convolution of one stimulus block  u and hemodynamic response v
	w = NaN(dataStruct.o);
	for k = 1:dataStruct.o
		for j = max(1,k+1-dataStruct.n):min(k,dataStruct.m) 
            tmp(k,j) = dataStruct.u(j)*H(k-j+1);
		end
		w(k) = sum(tmp(k,max(1,k+1-dataStruct.n):min(k,dataStruct.m)));
	end    
% 	wn <- w[1:m]


figure
	plot(w)
%%
%% INTIALIZE THE CHAINS
nChains		= 3;
initsStruct = struct([]);
for ii = 1:nChains
	initsStruct(ii).sigma		= sigma(1);
	initsStruct(ii).a1			= a1(1);
	initsStruct(ii).b1			= b1(1);
	initsStruct(ii).a2			= a2(1);
	initsStruct(ii).b2			= b2(1);
	initsStruct(ii).beta		= beta(1);
end

%% RUN THE CHAINS
parameters		= {'b1','a1','b2','a2','c','sigma','beta','wn'}; % The parameter(s) to be monitored.
burnInSteps		= 100;		% Number of steps to 'burn-in' the samplers.
numSavedSteps	= 100;		% Total number of steps in chains to save.
thinSteps		= 1;		% Number of steps to 'thin' (1=keep every step).
nIter			= ceil((numSavedSteps*thinSteps )/nChains); % Steps per chain.
doparallel		= 1; % do not use parallelization
if doparallel
	isOpen = matlabpool('size') > 0;
	if ~isOpen
		matlabpool open
	end
end
fprintf( 'Running JAGS...\n' );
% [samples, stats, structArray] = matjags( ...
% 	tic
model = 'model_hemocanon_glm.txt';
[samples,stats,structArray] = pa_matjags(...
	dataStruct,...                     % Observed data
	fullfile(pwd, model), ...			% File that contains model definition
	initsStruct,...                    % Initial values for latent variables
	'doparallel',doparallel, ...      % Parallelization flag
	'nchains',nChains,...              % Number of MCMC chains
	'nburnin',burnInSteps,...          % Number of burnin steps
	'nsamples',nIter,...				% Number of samples to extract
	'thin',thinSteps,...              % Thinning parameter
	'monitorparams',parameters, ...    % List of latent variables to monitor
	'savejagsoutput',1,...          % Save command line output produced by JAGS?
	'verbosity',0,...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
	'cleanup',0);                    % clean up of temporary files?


%%
b1		= samples.b1;
a1		= samples.a1;
b2		= samples.b2;
a2		= samples.a2;
c		= samples.c;
sigma	= samples.sigma;
beta	= samples.beta;
pred	= samples.wn; % posterior predictive

[m,n,o] = size(pred);
pred	= reshape(pred,m*n,o);

figure(1)
subplot(231)
plot(b1');

subplot(232)
plot(a1');

subplot(233)
plot(sigma');

subplot(234)
plot(b2');

subplot(235)
plot(a2');

subplot(236)
plot(c');

%%
b1		= b1(:);
a1		= a1(:);
b2		= b2(:);
a2		= a2(:);
c		= c(:);
sigma	= sigma(:);
beta	= beta(:);

figure(2)
subplot(231)
plotPost(b1,'showMode',true);
xlabel('b1');

subplot(232)
plotPost(a1,'showMode',true);
xlabel('a1');

subplot(233)
plotPost(sigma,'showMode',true);
xlabel('sigma');

subplot(234)
plotPost(b2,'showMode',true);
xlabel('b2');

subplot(235)
plotPost(a2,'showMode',true);
xlabel('a2');

subplot(236)
plotPost(beta);
xlabel('beta');


% %%
% figure(3)
% subplot(221)
% plot(a1,b1,'k.');
% axis square
% box off
% set(gca,'TickDir','out');
% xlim([0.8*min(a1) 1.2*max(a1)]);
% ylim([0.8*min(b1) 1.2*max(b1)]);
% 
% subplot(222)
% plot(a1,beta,'k.');
% axis square
% box off
% set(gca,'TickDir','out');
% xlim([0.8*min(a1) 1.2*max(a1)]);
% ylim([0.8*min(beta) 1.2*max(beta)]);
% 
% subplot(223)
% plot(b1,beta,'k.');
% axis square
% box off
% set(gca,'TickDir','out');
% xlim([0.8*min(b1) 1.2*max(b1)]);
% ylim([0.8*min(beta) 1.2*max(beta)]);
% 
% subplot(224)
% plot(a1,sigma,'k.');
% axis square
% box off
% set(gca,'TickDir','out');
% xlim([0.8*min(a1) 1.2*max(a1)]);
% ylim([0.8*min(sigma) 1.2*max(sigma)]);
%%
x       = 0:(1/Fs):dur; % sec
figure(4)
plot(x,y,'k-','LineWidth',2)

hold on
for idx = 1:numSavedSteps
	hpred   = beta(idx)*(gampdf(x,a1(idx),b1(idx))-c(idx)*gampdf(x,a2(idx),b2(idx)));
	ypred       = conv(X,hpred);
	ypred       = ypred(1:N);
	plot(x,ypred,'k-','Color',[.7 .7 .7]);
end
axis square
box off
set(gca,'TickDir','out');

