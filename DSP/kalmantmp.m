
% Define the system as a constant of 12 volts:
clear all
close all

s.x = 12;
s.A = 1;
% Define a process noise (stdev) of 2 volts as the car operates:
s.Q = 3^2; % variance, hence stdev^2
% Define the voltimeter to measure the voltage itself:
s.H = 1;
% Define a measurement error (stdev) of 2 volts:
s.R = 5^2; % variance, hence stdev^2
% Do not define any system input (control) functions:
s.B = 0;
s.u = 0;
% Do not specify an initial state:
s.x = nan;
s.P = nan;
% Generate random voltages and watch the filter operate.
tru = []; % truth voltage
n = 1000;
for t = 1:n
	if t<n/2
		tru(end+1)	= randn*2;
	else
		tru(end+1)	= randn*2+40;
	end
	s(end).z		= tru(end) + randn*s(end).R; % create a measurement
	s(end+1)		= kalmanf(s(end)); % perform a Kalman filter iteration
	s(end).Q		= ((t-1)*s(end-1).Q+tru(t).^2)/t;

end
figure
subplot(211)
hold on
grid on
% plot measurement data:
hz=plot([s(1:end-1).z],'r.');
% plot a-posteriori state estimates:
hk=plot([s(2:end).x],'b-');
ht=plot(tru,'g-');
legend([hz hk ht],'observations','Kalman output','true voltage',0)
title('Automobile Voltimeter Example')
hold off

subplot(212)
sd = sqrt([s.Q]);
plot(sd)
xlim([1 n])
return
MAP = [s(2:end).x];
subplot(234)
pa_loc(tru',MAP');
pa_unityline;
axis square;

tru1 = tru(1:n/2);
MAP1 = MAP(1:n/2);
sel = abs(tru1)<10;
subplot(235)
pa_loc(tru1(sel)',MAP1(sel)');
pa_unityline;
axis square;

tru2 = tru((n/2+1):end);
MAP2 = MAP((n/2+1):end);
sel = abs(tru1)<10;

subplot(236)
pa_loc(tru2(sel)',MAP2(sel)');
pa_unityline;
axis square;
return
%%
clear all
close all
fname = 'ML-DB-05-11-2011-0003.hv';
[H,V]                 = loadraw(fname, 2, 1500);
V = V(:,3);
Vel                   = gradient(V,1/1024);


figure
subplot(121)
plot(V);

subplot(122)
plot(Vel);


figure
[F,M] = pa_getpower(V,1017);
plot(F,pa_runavg(M,10))
xlim([0 200]);
% return
s.x = 12;
s.A = 1;
% Define a process noise (stdev) of 2 volts as the car operates:
s.Q = .1^2; % variance, hence stdev^2
% Define the voltimeter to measure the voltage itself:
s.H = 1;
% Define a measurement error (stdev) of 2 volts:

s.R = std(V)^2; % variance, hence stdev^2
% Do not define any system input (control) functions:
s.B = 0;
s.u = 0;
% Do not specify an initial state:
s.x = nan;
s.P = nan;
for ii = 1:length(Vel)
	s(end).z = V(ii);
	s(end+1)=kalmanf(s(end)); % perform a Kalman filter iteration
end
figure
subplot(311)
hold on
grid on
% plot measurement data:
% plot a-posteriori state estimates:
hk=plot([s(2:end).x],'b-');
ht=plot(V,'g-');
legend([hk ht],'Kalman output','true voltage',0)
hold off

fV = pa_runavg(V,20);
subplot(311)
hold on
grid on
plot(fV,'r-');

fVel = pa_runavg(Vel,20);
subplot(312)
hold on
grid on
plot(fVel,'r-');

% % fVel = gradient(Vel,1/1017);
fVel = gradient([s(2:end).x],1/1017);
whos Vel fVel
% fVel = [s(2:end).x];
subplot(312)
hold on
grid on
plot(fVel,'b-');
plot(Vel,'g');


subplot(313)
plot(Vel(:)-fVel(:),'-');


