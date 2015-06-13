%==================================================================
%                               Savefiles
%==================================================================
%
% This handles the file names of the log and dat files
%
% This script can be called to create figure and to maintain it
%
%% if figure does not exist, create it 
HF = findobj('Tag','SaveFiles');
if isempty(HF)
    % basic props
    ChanColLabel = [
        0 0 0;
        1 0 0;
        .7 .7 0;
        1 1 1;
        0 1 0;
        0 0 1;
        .4 .4 .4;
        1 1 1
        ];

    % figure
    HF = figure('Tag','SaveFiles','name','Save Filenames','numbertitle','off','menubar','none');
	axis off
	axis ij
	
    % place UI's and create handles
	uicontrol(HF,'style','text','string','LogFile:','position',[10 10 50 20],'HorizontalAlignment','left');
	uicontrol(HF,'style','text','string','DatFile:','position',[10 30 50 20],'HorizontalAlignment','left');
	HuiLogDir   = uicontrol(HF,'tag','LogDir','style','text','string','Logdirectory','HorizontalAlignment','left','position',[70 10 150 20]);
	HuiDatDir   = uicontrol(HF,'tag','DatDir','style','text','string','Datdirectory','HorizontalAlignment','left','position',[70 30 150 20]);
	HuiLogFile  = uicontrol(HF,'tag','LogFile','style','edit','string','Logfilename','position',[230 10 150 20],'UserData','X:\path\Logfile.log');
	HuiDatFile  = uicontrol(HF,'tag','DatFile','style','edit','string','Datfilename','position',[230 30 150 20],'UserData','X:\path\Datfile.dat');
	uicontrol(HF,'style','pushbutton','string','browse ...','position',[390 10 100 20],'callback','browseLog;savefiles');
	uicontrol(HF,'style','pushbutton','string','browse ...','position',[390 30 100 20],'callback','browseDat;savefiles');
	HuiLogSize  = uicontrol(HF,'tag','LogSize','style','text','string','0KB','HorizontalAlignment','left','position',[500 10 50 20]);
	HuiDatSize  = uicontrol(HF,'tag','DatSize','style','text','string','0KB','HorizontalAlignment','left','position',[500 30 50 20]);
	uicontrol(HF,'style','text','string','Save Channels:','position',[10 70 140 20],'HorizontalAlignment','left');
	HuiCh = nan(1,8);
	for I_ch = 1:8
		HuiCh(I_ch) = uicontrol(HF,'tag',['SaveCh' num2str(I_ch)],'Style','togglebutton','pos',[160+(I_ch-1)*50 60 40 40],'string',['Ch' num2str(I_ch)],'ForegroundColor',ChanColLabel(I_ch,:),'FontWeight','bold');
		set(HuiCh(I_ch),'value',get(HuiCh(I_ch),'Max'))
    end
    
else
	% get UI handles
	HuiLogDir   = findobj('tag','LogDir');
	HuiDatDir   = findobj('tag','DatDir');
	HuiLogFile  = findobj('tag','LogFile');
	HuiDatFile  = findobj('tag','DatFile');
	HuiLogSize  = findobj('tag','LogSize');
	HuiDatSize  = findobj('tag','DatSize');
end

%% update info
DatFile = get(HuiDatFile,'UserData');
[DatDir,sDatFile,DatExt]=fileparts(DatFile);
set(HuiDatFile,'string',[sDatFile DatExt])
set(HuiDatDir,'string',[DatDir filesep])
if exist(DatFile,'file')==2
	set(HuiDatSize,'ForegroundColor',[0 0 0])
	D=dir(DatFile);
	Size = D.bytes;
	tSize = Size / 1024^0;
	SizeStr = 'B';
	if Size > 1024^1*10
		tSize = Size / 1024^1;
		SizeStr = 'KB';
	end
	if Size > 1024^2*10
		tSize = Size / 1024^2;
		SizeStr = 'MB';
	end
	if Size > 1024^3*1
		tSize = Size / 1024^3;
		SizeStr = 'GB';
	end
	SizeStr = [sprintf('%.1f',tSize) SizeStr];
	set(HuiDatSize,'String',SizeStr)
else
	set(HuiDatSize,'ForegroundColor',[1 0 0])
end

LogFile = get(HuiLogFile,'UserData');
[LogDir,sLogFile,LogExt]=fileparts(LogFile);
set(HuiLogFile,'string',[sLogFile LogExt])
set(HuiLogDir,'string',[LogDir filesep])
if exist(LogFile,'file')==2
	set(HuiLogSize,'ForegroundColor',[0 0 0])
	D=dir(LogFile);
	Size = D.bytes;
	tSize = Size / 1024^0;
	SizeStr = 'B';
	if Size > 1024^1*10
		tSize = Size / 1024^1;
		SizeStr = 'KB';
	end
	if Size > 1024^2*10
		tSize = Size / 1024^2;
		SizeStr = 'MB';
	end
	if Size > 1024^3*1
		tSize = Size / 1024^3;
		SizeStr = 'GB';
	end
	SizeStr = [sprintf('%.1f',tSize) SizeStr];
	set(HuiLogSize,'String',SizeStr)
else
	set(HuiLogSize,'ForegroundColor',[1 0 0])
end