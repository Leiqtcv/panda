%% Clean
close all
clear all

dspflag = false;

%% Files & Directories
% Change to your own liking
cd('/Users/marcw/DATA/Student/Marleen/DATA')
d			= dir('MH-PB*.dat');
% d			= dir('MH-RM*.dat');
% d			= dir('MH-RG*.dat');
% d			= dir('MH-MF*.dat');
% d			= dir('MH-MH*.dat');
% d			= dir('MH-NB*.dat');

% d			= dir('*.dat');

fnames		= {d.name};

nfiles		= numel(fnames);
PER			= [];
DT			= [];
RTSND		= [];
RTLED		= [];
INT			= [];
for fIdx = 1:nfiles
	fname = fnames{fIdx};
	
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
	attr		= attr(selsnd); % sound attributes
	
	ntrial		= max(l(:,1));
	ledint		= NaN(ntrial,1);
	ledonset	= ledint;
	lonset		= ledint;
	for ii	= 1:ntrial
		nsky = sum(l(:,1)==ii & selsky);
		if nsky==3
			sel				= l(:,2)==7 & l(:,1)==ii ;
			ledint(ii)		= l(sel,10);
			ledonset(ii)	= l(sel,8); % intensity change onset	elseif nsky==3
			sel				= l(:,2)==6 & l(:,1)==ii ;
			lonset(ii)		= l(sel,8);
		elseif nsky==2
			sel				= l(:,2)==6  &l(:,1)==ii;
			ledint(ii)		= l(sel,10);
			ledonset(ii)	= l(sel,8); % intensity change onset	elseif nsky==3
			lonset(ii)		= l(sel,8);
		end
	end
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
	sndonset			= 400+100*rem(sndonset,100)+150; % (ms)
	sel					= attr==0;
	sndonset(sel)		= NaN;
	
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
	per(attr==0) = 0;
	
	
	%% Delay
	dt		= sndonset-ledonset;
	sel		= ledonset==0;
	dt(sel) = NaN;
	dt		= round(dt/5)*5;
	
	% return
	%% Reaction time
	rtsnd		= BTN/1017*1000-sndonset;
	rtled		= BTN/1017*1000-ledonset;
	rt			= rtsnd;
	
	% 	mu			= NaN(nper,nint);
	% 	sd			= mu;
	% 	whos per ledint
	% 	for ii = 1:nper
	% 		for jj = 1:nint
	% 			sel			= per==uper(ii) & ledint'==uint(jj) & dt'==150;
	% 			N(ii,jj)	= sum(sel);
	% 			mu(ii,jj)	= 1./nanmean(1./rt(sel));
	% 			sd(ii,jj)	= 1./nanstd(1./rt(sel))/sqrt(sum(sel))/2; % SE/2
	% 		end
	% 	end
	%
	% 	subplot(221)
	% 	imagesc(1:5,1:5,mu)
	% 	axis square;colorbar;
	% 	caxis([100 800]);
	% 	set(gca,'XTick',1:5,'XTickLabel',uper,'YTick',1:5,'YTickLabel',uint,'Ydir','normal');
	%
	% 	subplot(222)
	% 	plot(uper,nanmean(mu,2),'o-');
	% 	axis square
	% 	box off
	% 	ylim([100 700]);
	% 	xlim([0 600]);
	% 	set(gca,'XTick',uper);
	%
	% 	subplot(223)
	% 	plot(uint(1:nint),nanmean(mu),'o-');
	% 	axis square
	% 	box off
	% 	ylim([100 700]);
	% 	xlim([0 100]);
	%
	% 	drawnow
	
	PER		= [PER; per'];
	DT		= [DT; dt];
	RTSND	= [RTSND; rtsnd];
	RTLED	= [RTLED; rtled];
	INT		= [INT; ledint];
	
	matname = pa_fcheckext(fname,'.mat')
% 	save(matname,PER,DT,RTSND,RTLED,INT);
end


%%
%% Everything
close all
PER(isnan(PER))		= 0;
uper				= unique(PER);
nper				= numel(uper);
uint				= unique(INT);
nint				= numel(uint);
RT					= RTSND;
udt = unique(DT);
ndt = numel(udt);

sel					= isnan(RTSND);
RT(sel)				= RTLED(sel);

mu					= NaN(nper,nint,ndt);
sd					= mu;
N					= mu;
for ii = 1:nper
	for jj = 1:nint
		for kk = 1:ndt
			if uper(ii)==0
			sel			= PER==uper(ii) & INT==uint(jj) & isnan(DT);
			elseif uint(jj)==100
			sel			= PER==uper(ii) & INT==uint(jj) & isnan(DT);
			else
			sel			= PER==uper(ii) & INT==uint(jj) & DT==udt(kk);
			end
			N(ii,jj,kk)	= sum(sel);
			if uper(ii)==0
				mu(ii,jj,kk)	= nanmean(RT(sel)-(udt(kk)));
			else
				mu(ii,jj,kk)	= nanmean(RT(sel));
			end
			sd(ii,jj,kk)	= nanstd(RT(sel))/sqrt(sum(sel))/2; % SE/2
		end
	end
end

idx = 3;
mu	= squeeze(mu(:,:,idx));
sd	= squeeze(sd(:,:,idx));
N	= squeeze(N(:,:,idx));




h = errorbar(repmat(uper,1,nint),mu,sd,'o-');
axis square
box off
ylim([-100 700]);
xlim([-100 600]);
set(gca,'XTick',round(uper));
legend(h,num2str(uint));

