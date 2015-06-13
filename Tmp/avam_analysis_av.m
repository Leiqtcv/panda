%% Clean
close all
clear all

dspflag = false;

%% Files & Directories
% Change to your own liking
cd('/Users/marcw/DATA/Student/Marleen/DATA')
fname = 'MH-RG-2015-01-09-0005';
fname = 'RG-MH-2015-01-14-0002';

% cd('/Users/marcw/DATA/Student/Marleen/DATA')
% fname = 'RG-MH-2015-01-09-0003';
% cd('/Users/marcw/DATA/Student/Marleen')
% fname = 'RG-MH-2015-01-08-0003';

%% Load data & stimulus info
[e,c,l]		= pa_readcsv(fname); % stimulus
nchan		= e(:,8); % number of data acquisition channels (usuallly 8)
nsample		= c(1,6); % number of samples acquired per trial (usually at 1017 Hz)
dat			= pa_loaddat(fname,nchan,nsample); % data (10-3 V)

%% Create vectors
btn			= squeeze(dat(:,:,4)); % button channel
trialn		= l(:,1);
mod			= l(:,5); % modality of stimulus
attr		= l(:,11); % sound attribute, reminder:


%% Selection for sound, task and led
selsnd		= mod==3; % SND2, see also PA_READCSV
selsky		= mod==1; % SKY, see also PA_READCSV
% trialn		= trialn(selsnd);
attr		= attr(selsnd); % sound attributes
sel			= l(:,2)==1; % first stimulus is SKY-task-LED (actually, selsky is now a superfluous selection vector)
task		= l(sel,7); % 1 = red, aud, 2 = green, vis???
sel			= l(:,2)==7;
ledint		= l(sel,11);
ledonset	= l(sel,8); % intensity change onset

sel			= l(:,2)==6; % acq
lonset		= l(sel,8);
ledonset	= ledonset-lonset;

%% Get button press time
ntrials		= size(btn,2);
BTN			= NaN(ntrials,1);
for ii		= 1:ntrials
	d		= 1000*[0;diff(btn(:,ii))]; % difference/velocity/gradient (V)
	sel		= d>2*std(d); % anything greater than 2*std is considered as button press
	idx		= find(sel,1','first'); % only take the first
	BTN(ii) = idx; % assemble in vector (sample number)
	
	if dspflag
		%% Plot button channel and button difference
		t		= 1:length(d);
		ax(1)	= subplot(312);
		plot(t,d)
		hold on
		plot(t(sel),d(sel),'ro-');
		pa_horline(2*std(d));
		pa_verline(t(idx));
		hold off
		
		ax(2) = subplot(311);
		plot(t,btn(:,ii))
		pa_verline(t(idx));
		drawnow
		
		%% Also plot sound
		sndfile		= ['/Users/marcw/DATA/Student/Marleen/snd' num2str(attr(ii),'%03i') '.wav'];
		[snd,fs]	= audioread(sndfile);
		tsnd		= 1:length(snd);
		tsnd		= tsnd/fs*1000;	ax(3) = subplot(313);
		plot(tsnd,snd);
		
		%% Let's plot now
		linkaxes(ax,'x');
		drawnow
	end
end

%% Sound modulation onset
% Dynamic onset: 500:100:1500 % so 11 IDs
% sndxx1 = 500
% sndxx2 = 600
sndonset			= attr;
idx					= rem(sndonset,100);
sndonset			= 400+100*rem(sndonset,100)+20; % (ms)

%% Modulation period of sound
% Periods of the sounds: 15   136   258   379   500 ms
% snd0xx = 15
% snd1xx = 136
% snd2xx = 258
% snd3xx = 379
% snd5xx = 500
per			= round((attr-rem(attr,100))/100); % 0 1 2 3 5
per			= per+1; % 1 2 3 4 6
per(per==6) = 5; % 1 2 3 4 5
uper		= linspace(15,500,5); % 15...500
per			= uper(per);


% return
%% Reaction time
rt			= BTN/1017*1000-sndonset;

mu			= NaN(size(uper));
sd			= mu;
for ii = 1:numel(uper)
	sel		= per==uper(ii) & rt'>100;
	mu(ii)	= 1./mean(1./rt(sel));
	sd(ii)	= 1./std(1./rt(sel))/sqrt(sum(sel))/2; % SE/2
end


%%
close all
subplot(121)
hist(rt,-400:100:2000);
axis square
subplot(122)
errorbar(uper/1000,mu,sd,'k.');
hold on
plot(uper/1000,mu,'ko','MarkerFaceColor','w');
set(gca,'xtick',round(uper)/1000);
xlim([-0.1 0.6])
axis square
lsline
box off

x = per;
y = rt;
b = regstats(y,x,'linear','all');

b.beta
str = ['RT = ' num2str(b.beta(2),'%0.2f') '+' num2str(round(b.beta(1)))];
title(str)
