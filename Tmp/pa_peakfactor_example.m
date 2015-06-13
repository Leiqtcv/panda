function pa_peakfactor_example
% PA_PEAKFACTOR_EXAMPLE
%

% 2012 Marc van Wanrooij
% e-mail: marcvwanrooij@neural-code.com

%% Initialization
% Clear
close all
clear all
% Variables
x	= 0:0.01:10; % time samples
f	= .5; % Frequency 1 Hz

%% Cosine
y	= sin(2*pi*f*x); % wave form
subplot(2,3,1);
graphics(x,y); % Some graphics in an easy sub-function
title('Sine');

%% Square
y	= ones(size(x)); % high wave form
sel = rem(x,1/f)*f>=0.5; % select the latter half of the period (1/f)
y(sel) = -1; % low
subplot(2,3,2);
graphics(x,y); % Some graphics in an easy sub-function
title('Square');

%% Sawetooth
y = cumsum(y); % use the square wave to produce a sawtooth
y = y-1; y = y./max(y); y = 2*(y-0.5); % and normalize:
subplot(2,3,3);
graphics(x,y); % Some graphics in an easy sub-function
title('Sawtooth');

%% Pulse
y	= -ones(size(x)); % high wave form
y(100) = 1000;
subplot(2,3,4);
graphics(x,y); % Some graphics in an easy sub-function
title('Pulse');

%% Noise
y = 1/3*randn(size(x)); % See also PA_GENGWN
subplot(2,3,5);
graphics(x,y); % Some graphics in an easy sub-function
title('Gaussian noise');

%% Print
cd('C:\DATA'); % See also PA_DATADIR
print('-depsc','-painter',mfilename); % I try to avoid bitmaps, 
% so I can easily modify the figures later on in for example Illustrator
% For web-and Office-purposes, I later save images as PNG-files

function graphics(x,y)
% GRAPHICS(X,Y)
%
% Make some nice visual graphics

pf	= peakfactor(y); % determine the peak-factor with a sub-function
% Graphics
plot(x,y,'k-','LineWidth',2);
% labels
xlabel('Time');
ylabel('Amplitude');
% axis
ylim([-1.4 1.4]);
axis square;
box off;
% text
str = ['Peak Factor = ' num2str(pf,3)];
h	= pa_text(0.5,0.9,str); set(h,'HorizontalAlignment','center'); % Set the text and center it.
% Ticks
set(gca,'XTick',0:2:10);

function pf = peakfactor(y)
% PF = PEAKFACTOR(Y)
%
% Obtain peakfactor PF from signal Y

Amax = max(y); % minimum amplitude
Amin = min(y); % maximum amplitude
Arms = sqrt(mean(y.^2)); % or Arms = pa_rms(y), root-mean-square
pf  = (Amax-Amin)./(2*sqrt(2)*Arms);



