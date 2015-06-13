%==================================================================
%                               Monitor TDT
%==================================================================
%
% This monitors TDT components
%
% This script can be called to create figure and to maintain it
%

%% variables
tdt_globals
[d,sRA16_1circuit] = fileparts(RA16_1circuit);
[d,sRA16_2circuit] = fileparts(RA16_2circuit);
[d,sRX6circuit] = fileparts(RX6circuit);
[d,sRP2_1circuit] = fileparts(RP2_1circuit);
[d,sRP2_2circuit] = fileparts(RP2_2circuit);


%% window
HF = findobj('Tag','ActXWin');
if isempty(HF)
	
    % figure
	HF = figure('Tag','ActXWin','name','ActXWin for TDT','numbertitle','off','menubar','none');
	
    % radio button handles & positions
	pos = [[0:2]'*20 ones(3,1) ones(3,1)*20 ones(3,1)*20];
	HuiRA16_1 = nan(1,3);
	HuiRA16_2 = nan(1,3);
	HuiRX6 = nan(1,3);
	HuiRP2_1 = nan(1,3);
	HuiRP2_2 = nan(1,3);
	for I_bit = [statTDTConnect statTDTLoad statTDTRun]
		HuiRA16_1(I_bit) = uicontrol('Tag',['RA16_1Stat' num2str(I_bit)],'position',pos(I_bit,:)+[1 81 0 0],'style','radiobutton','enable','off');
		HuiRA16_2(I_bit) = uicontrol('Tag',['RA16_2Stat' num2str(I_bit)],'position',pos(I_bit,:)+[1 61 0 0],'style','radiobutton','enable','off');
		HuiRX6(I_bit)    = uicontrol('Tag',['RX6Stat' num2str(I_bit)],'position',pos(I_bit,:)+[1 41 0 0],'style','radiobutton','enable','off');
		HuiRP2_1(I_bit)  = uicontrol('Tag',['RP2_1Stat' num2str(I_bit)],'position',pos(I_bit,:)+[1 21 0 0],'style','radiobutton','enable','off');
		HuiRP2_2(I_bit)  = uicontrol('Tag',['RP2_2Stat' num2str(I_bit)],'position',pos(I_bit,:)+[1 1 0 0],'style','radiobutton','enable','off');
    end
    
    % labels
	str=[{'Cn'};{'Ld'};{'Rn'}];
	for I_bit = [statTDTConnect statTDTLoad statTDTRun]
		uicontrol('position',pos(I_bit,:)+[1 101 0 0],'style','text','enable','on','string',str(I_bit));
	end
	uicontrol('position',[61 81 80 20],'style','text','enable','inactive','string','RA16_1');
	uicontrol('position',[61 61 80 20],'style','text','enable','inactive','string','RA16_2');
	uicontrol('position',[61 41 80 20],'style','text','enable','inactive','string','RX6');
	uicontrol('position',[61 21 80 20],'style','text','enable','inactive','string','RP2_1');
	uicontrol('position',[61 1 80 20],'style','text','enable','inactive','string','RP2_2');
	uicontrol('position',[141 81 200 20],'style','edit','enable','inactive','string',sRA16_1circuit);
	uicontrol('position',[141 61 200 20],'style','edit','enable','inactive','string',sRA16_2circuit);
	uicontrol('position',[141 41 200 20],'style','edit','enable','inactive','string',sRX6circuit);
	uicontrol('position',[141 21 200 20],'style','edit','enable','inactive','string',sRP2_1circuit);
	uicontrol('position',[141 1 200 20],'style','edit','enable','inactive','string',sRP2_2circuit);
else
    
    % radio button handles
	HuiRA16_1 = nan(1,3);
	HuiRA16_2 = nan(1,3);
	HuiRX6 = nan(1,3);
	HuiRP2_1 = nan(1,3);
	HuiRP2_2 = nan(1,3);
	for I_bit = [statTDTConnect statTDTLoad statTDTRun]
		HuiRA16_1(I_bit) = findobj('Tag',['RA16_1Stat' num2str(I_bit)]);
		HuiRA16_2(I_bit) = findobj('Tag',['RA16_2Stat' num2str(I_bit)]);
		HuiRX6(I_bit)    = findobj('Tag',['RX6Stat' num2str(I_bit)]);
		HuiRP2_1(I_bit)  = findobj('Tag',['RP2_1Stat' num2str(I_bit)]);
		HuiRP2_2(I_bit)  = findobj('Tag',['RP2_2Stat' num2str(I_bit)]);
	end
end

%% handle to RA16_1 is required
if exist('RA16_1','var')~=1  && FLAG_firstrun == false
	warning('TDT not initialized, call [HumanInit]')
end
%% Status of TDT elements
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

%% set radio buttons according to status
for I_bit = [statTDTConnect statTDTLoad statTDTRun]
	set(HuiRA16_1(I_bit),'value',bitget(RA16_1Status,I_bit),'enable','inactive');
	set(HuiRA16_2(I_bit),'value',bitget(RA16_2Status,I_bit),'enable','inactive');
	set(HuiRX6(I_bit),'value',bitget(RX6Status,I_bit),'enable','inactive');
	set(HuiRP2_1(I_bit),'value',bitget(RP2_1Status,I_bit),'enable','inactive');
	set(HuiRP2_2(I_bit),'value',bitget(RP2_2Status,I_bit),'enable','inactive');
    if bitget(RA16_1Status,I_bit) == 0 && FLAG_firstrun == false
        warning('RA16_1 Status not ok')
    end
end
drawnow