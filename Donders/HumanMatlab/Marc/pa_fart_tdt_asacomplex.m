% PA_ASACOMPLEX
%
% FART Experiment

% 2012 Marc van Wanrooij

%% Cleaning up
close all
clear all
clc

%% File IO Dialog
f					= figure(100);
date				= datestr(now,'yyyy-mm-dd');
prompt				= {'Date:','Experimenter:','Subject','Experiment number'};
dlg_title			= 'ASA Complex';
num_lines			= 1;
def					= {date,'MW','XX','0001'};
options.Resize		= 'on';
options.WindowStyle = 'normal';
x					= inputdlg(prompt,dlg_title,num_lines,def,options);
DatFile				= ['D:\HumanMatlab\Marc\DAT\' char(x(2,:)) '-' char(x(3,:)) '-' char(x(1,:)) '-' char(x(4,:)) '.dat'];
MatFile				= ['D:\HumanMatlab\Marc\DAT\' char(x(2,:)) '-' char(x(3,:)) '-' char(x(1,:)) '-' char(x(4,:)) '.mat'];

pause(3);

%% Initalize TDT circuits
RP2_1circuit	= 'D:\HumanV1\Marc\RCO&RPX\MicroMarc2_rp2.rco';
RP2_2circuit	= 'D:\HumanV1\Marc\RCO&RPX\MicroMarc2_rp2.rco';
RA16_1circuit	= 'D:\HumanV1\Marc\RCO&RPX\Marc_8Channels_ra16_1.rco';
pa_fart_tdt_humaninit; % Initialize TDT & microcontroller
H				= findobj('Tag','ActXWin');
figure(H)
zBus			= actxcontrol('zBus.x',[341 101 20 20]); % trigger zBus

%% Initialize HOOP
hoopFlag = false;
if hoopFlag
	hoop = pa_fart_tdt_hoopinit;
	hoop = pa_fart_tdt_hoophome(hoop);
end

%% Sound
wavfile		= 'D:\HumanV1\Denise\SND\SAV\snd001.wav'; % obsolete
snd			= stimSnd1; % obsolete
lvl			= 65; % sound level (dB)
level		= 0.4 + 0.008*lvl; % sound level
sgndB		= 80; % dB
rand('twister', sum(100*clock)); % seed
% ntrials		= 5;
% loc			= round(20*rand(ntrials,1)); % Masker locations azimuth (deg)
% loc			= [0 10 15 20 40 80]; % Masker locations azimuth (deg)
loc			= 0; % Masker locations azimuth (deg)
nloc		= numel(loc); % number of Masker locations
speaker		= 12; % sound elevation
hoopled		= 12;
stimtype	= 4;

%% Response and data acquistion
BtnChnL		= 2;
BtnChnR		= 1;
nsamples	= 5000;
RA16_1.SetTagVal('Samples',nsamples);

%% Experiment
R			= struct([]); % Responses
P			= struct([]); % stimulus parameters
CNT			= 0;
for ii = 1:nloc
	nswitch		= 0;
	cnt			= 0;
	correctinarow = 0;
	while nswitch<11
		cnt = cnt+1;
		CNT = CNT+1;
		if hoopFlag
			hoop = pa_fart_tdt_hooppos(hoop,az(1));
		end

		%% Generate signal
		sgnlvl	= 10^((sgndB-lvl)/20); %
		[SM,S,M,Fs,par] = pa_genasacomplex(stimtype,sgnlvl);
		[t1,t2,M] = pa_genasacomplex(stimtype,sgnlvl);
		val		= pa_rndval(1,2,1); % randomly allocate signal to interval 1 or 2

		%% Start trial by showing LED
		str		= sprintf('%d;%d;%d;%d;%d',stimLed,0,hoopled,255,1);
		micro_cmd(com,cmdStim,str);
		str		= sprintf('%d;%d;%d;%d;%d',stimSky,0,1,255,1);
		micro_cmd(com,cmdStim,str);

		%% Play sound 1
		switch val
			case 1
				snd1		= SM;
				snd2		= M;
			case 2
				snd1		= M;
				snd2		= SM;
		end
		snd = S;
		pa_fart_tdt_playsound(snd,RP2_1,zBus,com,level,speaker,stimSnd1,cmdSpeaker)

		%% start Acq
		zBus.zBusTrigB(0,1,4);

		snd = snd1;
		pa_fart_tdt_playsound(snd,RP2_1,zBus,com,level,speaker,stimSnd1,cmdSpeaker)

		%% Play sound 2
		snd			= snd2;
		pa_fart_tdt_playsound(snd,RP2_1,zBus,com,level,speaker,stimSnd1,cmdSpeaker)

		% Continue Acq
		wait = 1;
		while wait == 1
			wait = RA16_1.ReadTagV('Active',0,1);
		end
		% stop data acquisition
		zBus.zBusTrigB(0,2,4);

		%% End trial by extinguishing LED
		str = sprintf('%d;%d;%d;%d;%d',stimLed,0,hoopled,0,0);
		micro_cmd(com,cmdStim,str);
		str = sprintf('%d;%d;%d;%d;%d',stimSky,0,1,0,0);
		micro_cmd(com,cmdStim,str);

		%% Save data
		[DAT,Nsample,Nchan,Fs] = pa_fart_tdt_readdata(DatFile,RA16_1);

		%% Get data for online analysis
		[Btn1,Btn2,dBtn1,dBtn2,resp,rt] = pa_fart_tdt_getresponse(DAT,BtnChnL,BtnChnR);

		%% Stimulus parameters in structure P
		P(CNT).par			= par;
		P(CNT).signallevel	= sgndB;
		P(CNT).interval		= val;
		P(CNT).maskloc		= loc(ii);
		
		%% Response parameters in strcuture R
		R(CNT).response		= resp;
		R(CNT).reactiontime = rt;
		R(CNT).button1		= Btn1;
		R(CNT).button2		= Btn2;

		%% Did subject choose correct interval?
		if resp==val
			R(CNT).correct	= 1;
			correctinarow	= correctinarow+1;
		else
			R(CNT).correct	= 0;
			correctinarow	= 0;
			sgndB = sgndB+1*5; % 1 up
		end
		if correctinarow == 3
			sgndB = sgndB-1*5; % 3 down
			correctinarow = 0;
		end
		
				%% Safety-check: prevent very loud sounds
		if sgndB>85
			sgndB = 85;
		end
		c		= [R(:).correct];

		%% Determine number of switches
		nswitch = sum(diff(c(~isnan(c)))~=0);
		if cnt==200 % end if there are too many trials
			nswitch = 11;
		end
		save(MatFile,'R','P');

		
		%% Graphics
		t		= (1:Nsample)/Fs*1000; % time (ms)
		figure(100);
		subplot(221);
		hold off
		plot(t,DAT(:,1).*1618,'k');
		hold on
		plot(t,DAT(:,2).*1618,'r')
		ylim([-10,10])
		title('Button')
		legend('Left','Right')
		axis square;


		subplot(222);
		% 	pa_plotspec(SM,Fs);
		hold off
		plot(dBtn1,'k');
		hold on
		plot(dBtn2 ,'r')
		ylim([-5,5])
% 		pa_horline(2,'b--');
		title('Diff Button')
		legend('Interval 1','Interval 2')
		axis square;

		subplot(223)
		plot(cnt,resp,'r*','MarkerFaceColor','w');
		hold on
		plot(cnt,val,'ko');
		xlabel('Trial Number');
		ylabel('Interval');
		legend('Response','Actual');
		ylim([0 3]);
		subplot(223)
		plot(cnt,correctinarow,'bs','MarkerFaceColor','w');

		subplot(224)
		plot(cnt,sgndB,'ko','MarkerFaceColor','w');
		hold on
		xlabel('Trial Number');
		ylabel('Signal level (dB)');
		
	end
end
close(com);
% close all;

