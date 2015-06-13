function pa_fart_tdt_audcenter
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
dlg_title			= 'Auditory center';
num_lines			= 1;
def					= {date,'MW','XX','0001'};
options.Resize		= 'on';
options.WindowStyle = 'normal';
x					= inputdlg(prompt,dlg_title,num_lines,def,options);
DatFile				= ['D:\HumanMatlab\Marc\DAT\' char(x(2,:)) '-' char(x(3,:)) '-' char(x(1,:)) '-' char(x(4,:)) '.dat'];
MatFile				= ['D:\HumanMatlab\Marc\DAT\' char(x(2,:)) '-' char(x(3,:)) '-' char(x(1,:)) '-' char(x(4,:)) '.mat'];

% pause(3);

%% Initalize TDT circuits
RP2_1circuit	= 'D:\HumanV1\Marc\RCO&RPX\MicroMarc2_rp2.rco';
RP2_2circuit	= 'D:\HumanV1\Marc\RCO&RPX\MicroMarc2_rp2.rco';
RA16_1circuit	= 'D:\HumanV1\Marc\RCO&RPX\Marc_8Channels_ra16_1.rco';
pa_fart_tdt_humaninit; % Initialize TDT & microcontroller
H				= findobj('Tag','ActXWin');
figure(H)
zBus			= actxcontrol('zBus.x',[341 101 20 20]); % trigger zBus

%% Initialize HOOP
hoopFlag = true;
if hoopFlag
	hoop = pa_fart_tdt_hoopinit;
	hoop = pa_fart_tdt_hoophome(hoop);
end

%% Sound
lvl			= 55; % sound level (dB)
rand('twister', sum(100*clock)); % seed
% ntrials		= 5;
% loc			= round(20*rand(ntrials,1)); % Masker locations azimuth (deg)
% loc			= [0 10 15 20 40 80]; % Masker locations azimuth (deg)
loc			= -60; % Masker locations azimuth (deg)
nloc		= numel(loc); % number of Masker locations
hoopled		= 12;


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
	cnt			= 195;
	leftinarow = 0;
	while nswitch<11
		cnt = cnt+1;
		CNT = CNT+1;
% 		if hoopFlag
			pos = loc;
			pa_fart_tdt_hooppos
% 		end

		%% Generate signal
		snd1	= pa_gengwn;
		snd2	= pa_gengwn;
		level1		= 0.4 + 0.008*(lvl+pa_rndval(-5,5,1)); % sound level
		level2		= 0.4 + 0.008*(lvl+pa_rndval(-5,5,1)); % sound level

		val		= pa_rndval(1,2,1); % randomly allocate signal to interval 1 or 2

		%% Start trial by showing LED
		str		= sprintf('%d;%d;%d;%d;%d',stimLed,0,hoopled,255,1);
		micro_cmd(com,cmdStim,str);
		str		= sprintf('%d;%d;%d;%d;%d',stimSky,0,1,255,1);
		micro_cmd(com,cmdStim,str);

		%% Play sound 1
% 		switch val
% 			case 1
				speaker1		= 30;
				speaker2		= 12;
% 			case 2
% 				speaker1		= 30;
% 				speaker2		= 12;
% 		end
		pa_fart_tdt_playsound(snd1,RP2_1,zBus,com,level1,speaker1,stimSnd1,cmdSpeaker)

		%% start Acq
		zBus.zBusTrigB(0,1,4);

		snd = snd1;
		pa_fart_tdt_playsound(snd2,RP2_1,zBus,com,level2,speaker2,stimSnd1,cmdSpeaker)


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
		P(CNT).level1		= level1;
		P(CNT).level2		= level2;
		P(CNT).interval		= val;
		P(CNT).hooploc		= loc(ii);
		
		%% Response parameters in strcuture R
		R(CNT).response		= resp;
		R(CNT).reactiontime = rt;
		R(CNT).button1		= Btn1;
		R(CNT).button2		= Btn2;

		%% Did subject choose left or right?
		if resp==1
			R(CNT).left	= 1;
			leftinarow	= leftinarow+1;
		elseif resp==2
			R(CNT).left	= 0;
			leftinarow	= 0;
			loc = loc-2;
		end
		if leftinarow == 3
			loc = loc+2; % 3 down
			leftinarow = 0;
		end
% 		
% 				%% Safety-check: prevent very loud sounds
		if loc<-80
			loc = -80;
		elseif loc>80
			loc = 80;
		end
% 		c		= [R(:).correct];
% 
% 		%% Determine number of switches
% 		nswitch = sum(diff(c(~isnan(c)))~=0);
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
		hold off
		plot(dBtn1,'k');
		hold on
		plot(dBtn2 ,'r')
		ylim([-5,5])
% 		horline(2,'b--');
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
		plot(cnt,leftinarow,'bs','MarkerFaceColor','w');

		subplot(224)
		plot(cnt,loc,'ko','MarkerFaceColor','w');
		hold on
		xlabel('Trial Number');
		ylabel('Signal level (dB)');
% 		
	end
end
close(com);
% close all;


function [Btn1,Btn2,dBtn1,dBtn2,resp,rt] = pa_fart_tdt_getresponse(DAT,BtnChnL,BtnChnR)

Btn1		= DAT(:,BtnChnL)*1618;
Btn2		= DAT(:,BtnChnR)*1618;
dBtn1		= diff(Btn1);
dBtn2		= diff(Btn2);

ind_answL	= find(dBtn1 > 2);
ind_answR	= find(dBtn2 > 2);

if ismember(max([ind_answL ind_answR]),ind_answL)
    disp('Left')
    resp = 1;
    rt = max([ind_answL ind_answR]); % reactiontime (samples)
elseif ismember(max([ind_answL ind_answR]),ind_answR)
    disp('Right')
    resp = 2;
    rt = max([ind_answL ind_answR]); % reactiontime (samples)
else 
	disp('Uh-Oh');
    resp = NaN;
    rt = NaN;
end
