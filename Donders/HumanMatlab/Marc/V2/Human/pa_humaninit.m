% PA_HUMANINIT
%
% Initializes FART hardware
%
% 1 Init Microcontroller
% 2 load NN into MicroCtrl
% 2 Init TDT: RA16_1 , RA16_2, RX6, RP2_1, RP2_2
% 3 Test led sky

% Dick Heeren / Tom van Grootel
% 2012 Modified: Marc van Wanrooij

fprintf('***************************');
fprintf('\tHuman Initialize\n');


%% Global variables
% which TDT elements are initialized
% [RA16_1,RA16_2,RX6,RP2_1,RP2_2]
FLAG_element = [1,0,0,1,1];
% load bunch of variables
pa_micro_globals;
pa_tdt_globals;
FLAG_firstrun = false;
% short names of TDT circuits
[d,sRA16_1circuit]	= fileparts(RA16_1circuit);
[d,sRA16_2circuit]	= fileparts(RA16_2circuit);
[d,sRX6circuit]		= fileparts(RX6circuit);
[d,sRP2_1circuit]	= fileparts(RP2_1circuit);
[d,sRP2_2circuit]	= fileparts(RP2_2circuit);

%% Init Micro
timeout		= 100;
[com msg]	= rs232(115200,timeout);
ok			= false;
if msg(1) == 0
	ok = true; 
end
fprintf('\t***************************');
fprintf('\t\tInit Micro\n');
if (~ok)
	error(sprintf('Initialize: error (%d)\n',msg(1))); %#ok<SPERR>
else
    fprintf('\t\tInitialize rs232: OK\n');
end

[info msg] = pa_micro_cmd(com, cmdInfo, '');
if (msg(1) == 0)
    fprintf('\t\tProgram name/version micro: %s\n',info);
else
	disp(['info [' info '] msg [' num2str(msg)  ']']);
	error('Reset micro controller and try again');
end
fprintf('\t***************************');
fprintf('\t\tInit Micro DONE\n');

fprintf('\t***************************');
fprintf('\t\tOpen IO bits monitor\n');
IObitsmonitor
fprintf('\t***************************');
fprintf('\t\tOpen IO bits monitor DONE\n');


%% Load NNetwork into microctrl
% HumanInit_uploadNN
%% Init TDT
%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\t***************************');
fprintf('\t\tInit TDT\n');

% open ActiveX window
FLAG_firstrun = true;
TDTmonitor
FLAG_firstrun = false;
HF = findobj('Tag','ActXWin');

% Status of TDT elements
if exist('RA16_1','var')==1
	if iscom(RA16_1)
		RA16_1Status = RA16_1.GetStatus;
	else
		RA16_1Status = 0;
	end
else
	RA16_1Status = 0;
end
if exist('RA16_2','var')==1
	if iscom(RA16_2)
		RA16_2Status = RA16_2.GetStatus;
	else
		RA16_2Status = 0;
	end
else
	RA16_2Status = 0;
end
if exist('RX6','var')==1
	if iscom(RX6)
		RX6Status = RX6.GetStatus;
	else
		RX6Status = 0;
	end
else
	RX6Status = 0;
end
if exist('RP2_1','var')==1
	if iscom(RP2_1)
		RP2_1Status = RP2_1.GetStatus;
	else
		RP2_1Status = 0;
	end
else
	RP2_1Status = 0;
end
if exist('RP2_2','var')==1
	if iscom(RP2_2)
		RP2_2Status = RP2_2.GetStatus;
	else
		RP2_2Status = 0;
	end
else
	RP2_2Status = 0;
end

% open ActiveX screens for TDT elements if not exist
figure(HF)
if ~any(bitget(RA16_1Status,[statTDTConnect statTDTLoad statTDTRun]))
	RA16_1 = actxcontrol('RPco.x',[341 81 20 20]);
end
if ~any(bitget(RA16_2Status,[statTDTConnect statTDTLoad statTDTRun]))
	RA16_2 = actxcontrol('RPco.x',[341 61 20 20]);
end
if ~any(bitget(RX6Status,[statTDTConnect statTDTLoad statTDTRun]))
	RX6    = actxcontrol('RPco.x',[341 41 20 20]);
end
if ~any(bitget(RP2_1Status,[statTDTConnect statTDTLoad statTDTRun]))
	RP2_1  = actxcontrol('RPco.x',[341 21 20 20]);
end
if ~any(bitget(RP2_2Status,[statTDTConnect statTDTLoad statTDTRun]))
	RP2_2  = actxcontrol('RPco.x',[341 1 20 20]);
end

fprintf('\t***************************');
fprintf('\t\tInit TDT DONE\n');

%% connect TDT via Gigabit
fprintf('\t***************************');
fprintf('\t\tConnect TDT\n');
% Note: statTDTConnect can be 0 as well 
% if medusa is not connected
if ~bitget(RA16_1Status,statTDTConnect) && FLAG_element(1) == 1
	E=RA16_1.ConnectRA16('GB',1);
	if E==0;
		error('Error: RA16_1 not connected');
	elseif E==1;
		fprintf('\t\tRA16_1 is connected\n');
	end
end
if ~bitget(RA16_2Status,statTDTConnect) && FLAG_element(2) == 1
	E=RA16_2.ConnectRA16('GB',2);
	if E==0;
		warning('Error: RA16_2 not connected');
	elseif E==1;
		fprintf('\t\tRA16_2 is connected\n');
	end
end
if ~bitget(RX6Status,statTDTConnect) && FLAG_element(3) == 1
	E=RX6.ConnectRX6('GB',1);
	if E==0;
		warning('Error: RX6 not connected');
	elseif E==1;
		fprintf('\t\tRX6 is connected\n');
	end
end
if ~bitget(RP2_1Status,statTDTConnect) && FLAG_element(4) == 1
	E=RP2_1.ConnectRP2('GB',1);
	if E==0;
		warning('Error: RP2_1 not connected');
	elseif E==1;
		fprintf('\t\tRP2_1 is connected\n');
	end
end
if ~bitget(RP2_2Status,statTDTConnect) && FLAG_element(5) == 1
	E=RP2_2.ConnectRP2('GB',2);
	if E==0;
		warning('Error: RP2_2 not connected');
	elseif E==1;
		fprintf('\t\tRP2_2 is connected\n');
	end
end
fprintf('\t***************************');
fprintf('\t\tConnect TDT DONE\n');

%% load TDT circuit
fprintf('\t***************************');
fprintf('\t\tload & run TDT\n');
if ~bitget(RA16_1Status,statTDTLoad) && FLAG_element(1) == 1
	E=RA16_1.LoadCOF(RA16_1circuit);
    if E==0;warning('RA16_1 circuit not loaded: is rco ok?');elseif E==1;fprintf('\t\tRA16_1 circuit is loaded\n');end
end
if ~bitget(RA16_2Status,statTDTLoad) && FLAG_element(2) == 1
	E=RA16_2.LoadCOF(RA16_2circuit); if E==0;warning('RA16_2 circuit not loaded: is rco ok?');elseif E==1;fprintf('\t\tRA16_2 circuit is loaded\n');end
end
if ~bitget(RX6Status,statTDTLoad) && FLAG_element(3) == 1
	E=RX6.LoadCOF(RX6circuit); if E==0;warning('RX6 circuit not loaded: is rco ok?');elseif E==1;fprintf('\t\tRX6 circuit is loaded\n');end
end
if ~bitget(RP2_1Status,statTDTLoad) && FLAG_element(4) == 1
	E=RP2_1.LoadCOF(RP2_1circuit); if E==0;warning('RP2_1 circuit not loaded: is rco ok?');elseif E==1;fprintf('\t\tRP2_1 circuit is loaded\n');end
end
if ~bitget(RP2_2Status,statTDTLoad) && FLAG_element(5) == 1
	E=RP2_2.LoadCOF(RP2_2circuit); if E==0;warning('RP2_2 circuit not loaded: is rco ok?');elseif E==1;fprintf('\t\tRP2_2 circuit is loaded\n');end
end

%% run TDT circuit
if ~bitget(RA16_1Status,statTDTRun) && FLAG_element(1) == 1
	E=RA16_1.Run; if E==0;disp('Error: RA16_1 does not run');elseif E==1;fprintf('\t\tRA16_1 is running\n');end
end
if ~bitget(RA16_2Status,statTDTLoad) && FLAG_element(2) == 1
	E=RA16_2.Run; if E==0;disp('Error: RA16_2 does not run');elseif E==1;fprintf('\t\tRA16_2 is running\n');end
end
if ~bitget(RX6Status,statTDTLoad) && FLAG_element(3) == 1
	E=RX6.Run; if E==0;disp('Error: RX6 does not run');elseif E==1;fprintf('\t\tRX6 is running\n');end
end
if ~bitget(RP2_1Status,statTDTLoad) && FLAG_element(4) == 1
	E=RP2_1.Run; if E==0;disp('Error: RP2_1 does not run');elseif E==1;fprintf('\t\tRP2_1 is running\n');end
end
if ~bitget(RP2_2Status,statTDTLoad) && FLAG_element(5) == 1
	E=RP2_2.Run; if E==0;disp('Error: RP2_2 does not run');elseif E==1;fprintf('\t\tRP2_2 is running\n');end
end
fprintf('\t***************************');
fprintf('\t\tload & run TDT DONE\n');

%% TDT status
fprintf('\t***************************');
fprintf('\t\tupdate TDT monitor\n');
RA16_1Status = RA16_1.GetStatus;
RA16_2Status = RA16_2.GetStatus;
RX6Status = RX6.GetStatus;
RP2_1Status = RP2_1.GetStatus;
RP2_2Status = RP2_2.GetStatus;
TDTmonitor
fprintf('\t***************************');
fprintf('\t\tupdate TDT monitor DONE\n');













%% test leds
%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\t***************************');
fprintf('\t\tTest leds (optional)\n');

switch 0;%rand_num([1 5])
	case 0
		% no testing
	case 1
		for spoke = 1:12
			for onoff = [1 0]
				for ring = 1:7
					str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,onoff);
					micro_cmd(com,cmdStim,str);
				end
			end
		end
	case 2
		for ring = 1:7
			for onoff = [1 0]
				for spoke = 1:12
					str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,onoff);
					micro_cmd(com,cmdStim,str);
				end
			end
		end
	case 3
		for onoff = [1 0]
			for spoke = 1:12
				for ring = 1:7
					str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,onoff);
					micro_cmd(com,cmdStim,str);
				end
			end
		end
	case 4
		for onoff = [1 0]
			for ring = 1:7
				for spoke = 1:12
					str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,onoff);
					micro_cmd(com,cmdStim,str);
				end
			end
		end
	case 5
		for onoff = [1 0]
			for ring = 7:-1:1
				for spoke = 1:12
					str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,onoff);
					micro_cmd(com,cmdStim,str);
				end
			end
		end
	case 6
		for ring = 1:7
			for spoke = 1:12
				str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,0,1);
				micro_cmd(com,cmdStim,str);
			end
		end
		for i_int = 1:24;
			for spoke = 1:12
				for ring = 1
					cint = 20*(spoke-i_int);
					if cint > 255;
						cint =cint -255;
					end
					str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,cint,1);
					micro_cmd(com,cmdStim,str);
				end
			end
		end
		for ring = 1:7
			for spoke = 1:12
				str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,0,0);
				micro_cmd(com,cmdStim,str);
			end
		end
end
fprintf('\t***************************');
fprintf('\t\tTest leds (optional) DONE\n');

fprintf('***************************');
fprintf('\tHuman Initialize DONE\n');

