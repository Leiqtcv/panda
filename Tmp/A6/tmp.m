% PA_BOSE_QC2_CALIBRATION2
%
% Determine calibration parameters of the Bose Quiet Comfort 2 headphones.
%
% See also AUDIOGRAM, PA_PLOT_BOSE_QC2_CALIBRATION

% 2013 Marc van Wanrooij
% Calibration performed by Michiel Dirkx, Maarten van de Kraan

close all
clear all
%% Files
fname	=  'E:\MATLAB\PANDA\Donders\Setups\supplementary\timingcheck-2013-02-14-2.dat';

dat = pa_loaddat(fname,8,5000);
[e,c,l] = pa_readcsv(fname);
sel = l(:,2)==1;

stimOnset = l(sel,8);

snd = squeeze(dat(:,:,4));
nSnd = size(snd,2);
sd = 3.5;
ON = NaN(size(stimOnset));
OFF = ON;
D = ON;
X = 0;
for ii = 1:nSnd
	x = snd(:,ii);
	x = x-mean(x);
	x = x./max(abs(x));
	s = std(x);
	h = hilbert(x);
	h = abs(h);
	h = smooth(h,50);
	
	indx	= find(abs(x)>sd*s,1,'first');
	offset	= find(abs(x)>sd*s,1,'last');

	
	subplot(211)
	cla
	plot(x,'k-');
	hold on
	plot(h,'r-','LineWidth',2,'color','r');
	ylim([-1 1]);
	pa_verline([indx offset],'r--');
	pa_horline([-sd*s sd*s]);
	
	t = indx/1017*1000;
	offset = offset/1017*1000;
	delta = offset-t;
	title({['Onset = ' num2str(t) ' ms'];['Offset = ' num2str(offset) ' ms'];['\Delta = ' num2str(delta) ' ms']});
	drawnow
	
	subplot(212)
	cla
	[f,a,p] = pa_getpower(x,1017,'display','x');
	xt = pa_oct2bw(10,0:7);
	set(gca,'XTick',xt,'XTickLabel',xt)
	xlabel('Frequency (Hz)');
	xlim([10 500]);
	pa_verline([40 50]);
% 	pause
% 	pause(.1)

D(ii) = delta;
ON(ii) = t;
OFF(ii) = offset;

end
% keyboard

figure
subplot(221)
plot(stimOnset,ON,'k-','Color',[.7 .7 .7]);
hold on
plot(stimOnset,ON,'ko','MarkerFaceColor','w','LineWidth',2);
% ylim([80 120]);
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

subplot(223)
plot(stimOnset,ON-stimOnset,'k-','Color',[.7 .7 .7]);
hold on
plot(stimOnset,ON-stimOnset,'ko','MarkerFaceColor','w','LineWidth',2);
% ylim([80 120]);
xlabel('Stimulus onset (ms)');
ylabel('Recorded onset (ms)');
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

subplot(222)
plot(stimOnset,D,'k-','Color',[.7 .7 .7]);
hold on
plot(stimOnset,D,'ko','MarkerFaceColor','w','LineWidth',2);
ylim([80 120]);
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
