
clear all
close all
clc


%% KALMANF
% Define the system as a constant of 0 deg:
clear s
s.x = 0;
s.A = 1;
% Define the brain to measure the location itself:
s.H = 1;
% Define a measurement error / sensory noise (stdev) of 15 deg:
s.R = 5^2; % variance, hence stdev^2
% Do not define any system input (control) functions:
s.B = 0;
s.u = 0;
% Do not specify an initial state:
s.x = nan;
s.P = nan;
s.K = NaN;
% Generate random voltages and watch the filter operate.
tru=[]; % stimulus location
n = 500;
x = 1:n;
freq	= 0.005; % 1 cycle per 100 trials
sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
% sd		= ones(size(x));
% sd(1:n/2) = 5;
% sd(n/2+1:end) = 40;
for t=1:n
	s(end).Q = sd(t).^2; % Define a process noise (stdev) / prior's variance
  tru(end+1)	= 0+sd(t).*randn(1);
  s(end).z		= tru(end) + randn*sqrt(s(t).R); % create a measurement
  s(end+1)		= pa_kalman(s(end)); % perform a Kalman filter iteration
end
figure
ht=plot(tru,'k-','Color',[.7 .7 .7]);
hold on
grid on
% plot measurement data:
% hz=plot([s(1:end-1).z],'r.');
% plot a-posteriori state estimates:
hk=plot([s(2:end).x],'r-','Color',[1 .7 .7]);

v = [s.P];
G = [s.K];
m = [s(1:end-1).z];
t = tru;
k = [s(2:end).x];

% figure
% subplot(221)
% plot(t,m,'.');
% axis square;
% pa_unityline;
% 
% 
% subplot(222)
% plot(t-k,'.');
% axis square;
% xlim([1 400]);
% 
% subplot(223)
% % plot(t-m,'.');
% plot(G);
% xlim([1 400]);
% 
% subplot(224)
% plot(sqrt(v))
% xlim([1 400]);

% plot(sqrt(v),K);

figure(1)
X = 1:length(k);
Y = t;
Z = k;
[beta,se,xi] = pa_weightedregress(X,Y,Z,7,X,'wfun','gaussian');
hg = plot(xi,45*beta,'r-','LineWidth',2);
hold on
hkg = plot(X,45*G(2:end),'r:','LineWidth',2);
plot(X,-45*G(2:end),'r:','LineWidth',2);
plot(xi,45*sd./max(sd),'k-','LineWidth',1);
plot(xi,-45*sd./max(sd),'k-','LineWidth',1);
ylim([-80 80]);
legend([hk ht hg hkg],'Kalman response','stimulus location','weighted gain','kalman gain',0)
title('Sound localization')
xlabel('Trial');
ylabel('Stimulus/Response Location / Response/Kalman Gain');

% return
% %% Default Kalman filter
% A = [1   0   0,
%      1   0   0,
%      0   1   0];
% 
% B = [1
%      0
%      0];
% 
% C = [1 0 0];
% 
% D = 0;
% 
% Plant	= ss(A,[B B],C,0,-1,'inputname',{'u' 'w'},'outputname','y');
% Q		= 2.3; % A number greater than zero
% R		= 1; % A number greater than zero
% [kalmf,L,~,M,Z] = kalman(Plant,Q,R);
% kalmf = kalmf(1,:);
% 
% M   % innovation gain
% 
% % First, build a complete plant model with u,w,v as inputs and
% % y and yv as outputs:
% a = A;
% b = [B B 0*B];
% c = [C;C];
% d = [0 0 0;0 0 1];
% P = ss(a,b,c,d,-1,'inputname',{'u' 'w' 'v'},'outputname',{'y' 'yv'});
% 
% sys = parallel(P,kalmf,1,1,[],[]);
% 
% SimModel = feedback(sys,1,4,2,1);
% SimModel = SimModel([1 3],[1 2 3]);     % Delete yv form I/O
% 
% SimModel.inputname
% SimModel.outputname
% 
% t = (0:100)';
% u = sin(t/5);
% 
% % rng(10,'twister');
% w = sqrt(Q)*randn(length(t),1);
% v = sqrt(R)*randn(length(t),1);
% 
% figure
% clf;
% out = lsim(SimModel,[w,v,u]);
% 
% y = out(:,1);   % true response
% ye = out(:,2);  % filtered response
% yv = y + v;     % measured response
% 
% clf
% subplot(211), plot(t,y,'b',t,ye,'r--'),
% xlabel('No. of samples'), ylabel('Output')
% title('Kalman filter response')
% subplot(212), plot(t,y-yv,'g',t,y-ye,'r--'),
% xlabel('No. of samples'), ylabel('Error')
% 
% MeasErr = y-yv;
% MeasErrCov = sum(MeasErr.*MeasErr)/length(MeasErr);
% EstErr = y-ye;
% EstErrCov = sum(EstErr.*EstErr)/length(EstErr);
% 
% MeasErrCov
% EstErrCov
% 
% 
% %% Time-varying Kalman Filter Design
% sys		= ss(A,B,C,D,-1);
% 
% n = length(u);
% x = 1:n;
% freq	= 0.01; % 1 cycle per 100 trials
% sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
% sd = sd';
% whos w sd
% w = randn(size(w)).*sd;
% whos 
% y		= lsim(sys,u+w);	% w = process noise
% yv		= y + v;			% v = measurement noise
% 
% figure
% plot(y)
% hold on
% plot(yv,'r-');
% plot(u+w,'k-');
% 
% P		= B*Q*B';         % Initial error covariance
% x		= zeros(3,1);     % Initial condition on the state
% ye		= zeros(length(t),1);
% ycov	= zeros(length(t),1);
% errcov	= zeros(length(t),1);
% 
% for i=1:length(t)
%   % Measurement update
%   Mn = P*C'/(C*P*C'+R);
%   x = x + Mn*(yv(i)-C*x);  % x[n|n]
%   P = (eye(3)-Mn*C)*P;     % P[n|n]
% 
%   ye(i) = C*x;
%   errcov(i) = C*P*C';
% 
%   % Time update
%   x = A*x + B*u(i);        % x[n+1|n]
%   P = A*P*A' + B*Q*B';     % P[n+1|n]
% end
% 
% figure
% subplot(311), plot(t,y,'b',t,ye,'r--'),
% xlabel('No. of samples'), ylabel('Output')
% title('Response with time-varying Kalman filter')
% subplot(312), plot(t,y-yv,'g',t,y-ye,'r--'),
% xlabel('No. of samples'), ylabel('Error')
% 
% subplot(313)
% plot(t,errcov), ylabel('Error Covar'),
% 
% MeasErr = y-yv;
% MeasErrCov = sum(MeasErr.*MeasErr)/length(MeasErr);
% EstErr = y-ye;
% EstErrCov = sum(EstErr.*EstErr)/length(EstErr);
% 
% MeasErrCov
% EstErrCov
% M,Mn
% 
% %%