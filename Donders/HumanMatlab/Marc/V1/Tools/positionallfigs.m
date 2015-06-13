%% load stored locations
if exist('D:\HumanMatlab\V1\windowpositions.mat','file')==2
	WinPos = load('D:\HumanMatlab\V1\windowpositions.mat','-mat');
else
	WinPos = [];
end

%% check locations
CurField = 'WPConsole';
DefPos = [1113 480 560 420];
if isfield(WinPos,CurField)
	CurPos = eval(['WinPos.' CurField]);
	if isempty(CurPos);
		CurPos = DefPos;
	end
else
	CurPos = DefPos;
end
eval([CurField ' = CurPos;']);

CurField = 'WPUserInterface';
DefPos = [523 480 560 420];
if isfield(WinPos,CurField)
	CurPos = eval(['WinPos.' CurField]);
	if isempty(CurPos);
		CurPos = DefPos;
	end
else
	CurPos = DefPos;
end
eval([CurField ' = CurPos;']);

CurField = 'WPTargets';
DefPos = [10 480 400 400];
if isfield(WinPos,CurField)
	CurPos = eval(['WinPos.' CurField]);
	if isempty(CurPos);
		CurPos = DefPos;
	end
else
	CurPos = DefPos;
end
eval([CurField ' = CurPos;']);

CurField = 'WPBitMonitor';
DefPos = [1352 138 260 180];
if isfield(WinPos,CurField)
	CurPos = eval(['WinPos.' CurField]);
	if isempty(CurPos);
		CurPos = DefPos;
	end
else
	CurPos = DefPos;
end
eval([CurField ' = CurPos;']);

CurField = 'WPActXWin';
DefPos = [1252 32 360 80];
if isfield(WinPos,CurField)
	CurPos = eval(['WinPos.' CurField]);
	if isempty(CurPos);
		CurPos = DefPos;
	end
else
	CurPos = DefPos;
end
eval([CurField ' = CurPos;']);


CurField = 'WPSaveFiles';
DefPos = [1052 345 560 110];
if isfield(WinPos,CurField)
	CurPos = eval(['WinPos.' CurField]);
	if isempty(CurPos);
		CurPos = DefPos;
	end
else
	CurPos = DefPos;
end
eval([CurField ' = CurPos;']);

CurField = 'WPRA16Scope';
ScreenRect = get(0,'MonitorPositions');
if size(ScreenRect,1) == 2
	tScreenRect = ScreenRect(1,:);
	tScreenRect(3) = ScreenRect(1,3)-ScreenRect(2,3);
	ScreenRect = tScreenRect;
else
	ScreenRect = get(0,'ScreenSize');
end
ScreenRect(1) = ScreenRect(1) + 10;
ScreenRect(2) = ScreenRect(2) + 35;
ScreenRect(3) = ScreenRect(3) - 20;
ScreenRect(4) = ScreenRect(4) - 80;
DefPos = ScreenRect;
if isfield(WinPos,CurField)
	CurPos = eval(['WinPos.' CurField]);
	if isempty(CurPos);
		CurPos = DefPos;
	end
else
	CurPos = DefPos;
end
eval([CurField ' = CurPos;']);


%% apply positions to figures
CurField = 'WPBitMonitor';
HF = findobj('Tag',CurField(3:end));if ~isempty(HF);set(HF,'position',eval(CurField));end
CurField = 'WPActXWin';
HF = findobj('Tag',CurField(3:end));if ~isempty(HF);set(HF,'position',eval(CurField));end
CurField = 'WPSaveFiles';
HF = findobj('Tag',CurField(3:end));if ~isempty(HF);set(HF,'position',eval(CurField));end
CurField = 'WPRA16Scope';
HF = findobj('Tag',CurField(3:end));if ~isempty(HF);set(HF,'position',eval(CurField));end
CurField = 'WPUserInterface';
HF = findobj('Tag',CurField(3:end));if ~isempty(HF);set(HF,'position',eval(CurField));end
CurField = 'WPConsole';
HF = findobj('Tag',CurField(3:end));if ~isempty(HF);set(HF,'position',eval(CurField));end
