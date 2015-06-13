function hrf = pa_hrfunction(beta,X)
% Y = PA_NIRS_HDRFUNCTION(BETA,X)
%
% f(t) = ((t-o)/d)^(p-1)(exp(-(t-0)/d)/d(p-1)!))^(p-1)
% function gam = GammaFcn(k,t)
close all

N = 200;
X = zeros(N,1);
X(1) = 1;
Fs      = 10;
gain    = 1;
shift   = 2; % 2 sec response delay
A		= 4.30; % peak time 4.5 s after stim
B		= .75;
N       = length(X); % samples
dur     = 20; % sec

%%
x       = 0:(1/Fs):dur; % sec
x       = x - shift;
y       = gampdf(x,A,B);
Y       = conv(X,y);
Y       = Y(1:N);
Y       = gain.*Y/max(Y); % Amplitude

t = (1:N)/Fs;

plot(t,Y)
return
%% Initialization
width = 10;
kappa = 10;
tau = 1;
nHRF = 3;

boxcar = neuralBox(width,kappa,tau,nHRF)
plot(boxcar)
return
%%
to			= beta(1);%-sigmaR;
wid			= beta(2);
C			= beta(3);

dt			= mean(diff(t));
t(end+1)	= t(end)+dt;

gam			= (max(t-to,0).^C) .* (exp( -( max(t-to,0)/wid ).^2 ));
boxcar		= neuralBox(beta(8),beta(6),beta(7),length(t));
gam			= conv(gam,boxcar);
gam			= gam(1:length(t));
gam			= gam./max(gam);
sel			= isnan(gam);
gam(sel)	= 0;
gam2		= diff(gam);
gam(end)	= [];
gam			= beta(4)*gam+beta(5)*gam2;


%% Initilization

Fs      = 10;
gain    = beta(1);
shift   = 0; % 2 sec response delay
A		= 4.30; % peak time 4.5 s after stim
B		= .75;
N       = length(X); % samples
dur     = 20; % sec

%%
x       = 0:(1/Fs):dur; % sec
x       = x - shift;
y       = gampdf(x,A,B);
Y       = conv(X,y);
Y       = Y(1:N);
Y       = gain.*Y/max(Y); % Amplitude
% Y       = nirs_bandpass(Y);

%% plot example Hemodynamic response function
% plot(0:(1/Fs):dur,y, 'k', 'linewidth', 2.5); axis square
% set(gca,'YTickLabel', []);
% set(gca,'YTick', []);
% xlim([0 20])
% ylabel('Concentration (A.U.)')
% xlabel('Time (s)')
% print('-painters','-depsc', 'HRF')
% text(ax(2)*.8, ax(4)*.8, ['R = ' num2str(stats.oxy{end}.Rsq)])

% on = [1507 2033 2488 2993 3468 4043 4548 5083 5558 6102 5697 7153]);
% X        = zeros(1, N);
% for ii = 1:length(on)
%     X(on(ii):on(ii)+dur) = 1;
% end
% X = [X zeros(1,25)];
% plot(X, 'color', [.75 .75 .75], 'linewidth', 2)

function boxcar = neuralBox(width,kappa,tau,nHRF)

tau=kappa*(1+tau);  %enforces that kappa/tau <1
stim=zeros(nHRF,1);
stim(1:5)=1;

% 
% %Ref Buxton2004
I(1)=0;
for idx=1:length(stim)
    N(idx)=stim(idx)-I(idx);
    dI_dt = (kappa*N(idx)-I(idx))/tau;
    I(idx+1)=I(idx)+dI_dt;
end

boxcar=ones(ceil(width),1);
boxcar(1:floor(width))=1;
boxcar(floor(width)+1:ceil(width))=width-floor(width);

I=conv(I,boxcar);

I=I./max(I);
boxcar=I;