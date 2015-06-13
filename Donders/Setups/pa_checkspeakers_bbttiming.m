function pa_checkspeakers_bbttiming

close all
clear all
%% Files
fname	=  'E:\MATLAB\PANDA\Donders\Setups\supplementary\timingcheck-2013-02-14-2.dat';
wavfile	=  'E:\MATLAB\PANDA\Donders\Setups\supplementary\snd088.wav';
[wav,Fs] = wavread(wavfile);
y = downsample(wav,round(Fs/1017));
% 	y = pa_highpass(y,80,1017/2,150);

dat = pa_loaddat(fname,8,5000);
[~,~,l] = pa_readcsv(fname);
sel = l(:,2)==1;

stimOnset = l(sel,8);

snd = squeeze(dat(:,:,4));
nSnd = size(snd,2);
sd = 4;
ON = NaN(size(stimOnset));
OFF = ON;
D = ON;
L = ON;
X = 0;
for ii = 1:nSnd
	x = snd(:,ii);
	x = x-mean(x);
	x = x./max(abs(x));
	x = pa_highpass(x,80,1017/2,150);
	
	[c,lags] = xcorr(x,y);
	[~,indx] = max(c);
	L(ii) = lags(indx);
%% 
	
	s = std(x);
	h = hilbert(x);
	h = abs(h);
	
	indx	= find(abs(x)>sd*s,1,'first');
	offset	= find(abs(x)>sd*s,1,'last');

	
	subplot(211)
	cla
	plot(x,'k-');
	hold on
	plot(h,'r-','LineWidth',2,'color','r');
	t = 1:length(y);
	plot(t+stimOnset(ii)*1017/1000,y,'b-');
% 	plot(3*[k.x],'b-','LineWidth',2);
	ylim([-1 1]);
	pa_verline([indx offset],'r--');
	pa_horline([-sd*s sd*s]);
	
	t = indx/1017*1000;
	offset = offset/1017*1000;
	delta = offset-t;
	title({['Onset = ' num2str(t) ' ms'];['Offset = ' num2str(offset) ' ms'];['\Delta = ' num2str(delta) ' ms']});
	drawnow
	
% 	subplot(212)
% 	cla
% 	[f,a,p] = pa_getpower(x,1017,'display','x');
% 	xt = pa_oct2bw(10,0:7);
% 	set(gca,'XTick',xt,'XTickLabel',xt)
% 	xlabel('Frequency (Hz)');
% 	xlim([10 500]);
% 	pa_verline([40 50]);
% 	pause
% 	pause(.1)

D(ii) = delta;
ON(ii) = t;
OFF(ii) = offset;

end
% keyboard

% figure
subplot(234)
plot(stimOnset,ON,'k-','Color',[.7 .7 .7]);
hold on
plot(stimOnset,ON,'ko','MarkerFaceColor','w','LineWidth',2);
% ylim([80 120]);
plot(stimOnset,L,'k-','Color','b','LineWidth',2);

xlabel('Stimulus onset (ms)');
ylabel('Recorded onset (ms)');
box off
axis square
pa_unityline;
axis([0 3000 0 3000]);
x = stimOnset;
y = ON;
% b = regstats(y,x);
% b = b.beta;
b = robustfit(x,y);
h = pa_regline(b,'r-');
set(h,'LineWidth',2)
str = ['y = ' num2str(b(2),2) ' x + ' num2str(b(1),2)];
title(str);
pa_horline([20 20+1.25/343*1000]);

subplot(236)
plot(stimOnset,ON-stimOnset,'k-','Color',[.7 .7 .7]);
hold on
plot(stimOnset,ON-stimOnset,'ko','MarkerFaceColor','w','LineWidth',2);

% ylim([80 120]);
xlabel('Stimulus onset (ms)');
ylabel('Recorded -stimulus onset (ms)');
box off
axis square
ylim([0 40]);
x = stimOnset;
y = ON-stimOnset;
% b = regstats(y,x);
% b = b.beta;
b = robustfit(x,y);
h = pa_regline(b,'r-');
set(h,'LineWidth',2)
str = ['y = ' num2str(b(2),2) ' x + ' num2str(b(1),2)];
title(str);
pa_horline([20 20+1.25/343*1000]);
xlim([0 3000])

subplot(235)
plot(stimOnset,D,'k-','Color',[.7 .7 .7]);
hold on
plot(stimOnset,D,'ko','MarkerFaceColor','w','LineWidth',2);
ylim([80 120]);
xlim([0 3000])
xlabel('Stimulus onset (ms)');
ylabel('Recorded duration (ms)');
box off
axis square

x = stimOnset;
y = D;
% b = regstats(y,x);
% b = b.beta;
b = robustfit(x,y);
h = pa_regline(b,'r-');
set(h,'LineWidth',2)
str = ['y = ' num2str(b(2),2) ' x + ' num2str(b(1),2)];
title(str);

pa_datadir;
print('-depsc',mfilename);

function s = kalmanf(s)

% set defaults for absent fields:
if ~isfield(s,'x'); s.x=nan*z; end
if ~isfield(s,'P'); s.P=nan; end
if ~isfield(s,'z'); error('Observation vector missing'); end
if ~isfield(s,'u'); s.u=0; end
if ~isfield(s,'A'); s.A=eye(length(x)); end
if ~isfield(s,'B'); s.B=0; end
if ~isfield(s,'Q'); s.Q=zeros(length(x)); end
if ~isfield(s,'R'); error('Observation covariance missing'); end
if ~isfield(s,'H'); s.H=eye(length(x)); end

if isnan(s.x)
   % initialize state estimate from first observation
   if diff(size(s.H))
      error('Observation matrix must be square and invertible for state autointialization.');
   end
   s.x = inv(s.H)*s.z;
   s.P = inv(s.H)*s.R*inv(s.H'); 
else
   
   % This is the code which implements the discrete Kalman filter:
   
   % Prediction for state vector and covariance:
   s.x = s.A*s.x + s.B*s.u;
   s.P = s.A * s.P * s.A' + s.Q;

   % Compute Kalman gain factor:
   K = s.P*s.H'*inv(s.H*s.P*s.H'+s.R);

   % Correction based on observation:
   s.x = s.x + K*(s.z-s.H*s.x);
   s.P = s.P - K*s.H*s.P;
   
end