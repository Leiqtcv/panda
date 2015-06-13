%==================================================================
%                               Save TDT
%==================================================================
%
% This saves data put in RAM buffer of TDT
%
% This script can be called to create figure and to maintain it
%
tic
%% channels
HuiCh = nan(1,8);
FLAG_SaveChns = nan(1,8);
for I_ch = 1:8
	HuiCh(I_ch) =  findobj('tag',['SaveCh' num2str(I_ch)]);
	FLAG_SaveChns(I_ch) = get(HuiCh(I_ch),'value') == get(HuiCh(I_ch),'max');
end
NsaveCh = sum(FLAG_SaveChns);
IxsChanWrite = find(FLAG_SaveChns);

%% files
savefiles

HuiLogFile = findobj('tag','LogFile');
HuiDatFile = findobj('tag','DatFile');
if isempty(HuiLogFile) || isempty(HuiDatFile)
	error('Filenames are unknown, call [savefiles] first')
else
	DatFile = get(HuiDatFile,'UserData');
	if strcmpi(DatFile,'X:\path\Datfile.dat')
		HFwarnD = figure('name','!!!!!','numbertitle','off','menubar','none','position',[970 320 120 150]);
		uicontrol('position',[10 40 100 100],'style','text','string',[{'Data and log files are not set!'};{''};{'Please select one and press OK to continue'}],'horizontalalign','left')
		uicontrol('style','pushbutton','position',[40 10 40 20],'string','OK','callback','close(HFwarnD);saveTDT;uiresume(HFwarnD)')
		uiwait(HFwarnD)
	elseif exist(DatFile,'file')~=2
		DAT = cell(1,NsaveCh);
		saveDAT = cell2mat(DAT);
		FID = fopen(DatFile,'w'); % create file
		cnt = fwrite(FID,saveDAT,'double');
		fclose(FID);
	else
		savefiles
	end
	
	LogFile = get(HuiLogFile,'UserData');
	if strcmpi(LogFile,'X:\path\Logfile.log')
		HFwarnL = figure('name','!!!!!','numbertitle','off','menubar','none','position',[970 320 120 150]);
		uicontrol('position',[10 40 100 100],'style','text','string',[{'Data and log files are not set!'};{''};{'Please select one and press OK to continue'}],'horizontalalign','left')
		uicontrol('style','pushbutton','position',[40 10 40 20],'string','OK','callback','close(HFwarnL);saveTDT;uiresume(HFwarnL)')
		uiwait(HFwarnL)
	elseif exist(LogFile,'file')~=2
		if exist('LOG','var')~=1
			LOG = LOGREC;
		end
		save(LogFile,'LOG','-mat')
        LOGcount=0;
	else
		savefiles
	end
end

%% data
Nsample = RA16_1.ReadTagV('NPtsRead',0,1);
FsampRCO = RA16_1.ReadTagV('Freq',0,1);
CurDAT = cell(1,NsaveCh);
c=0;
for I_ch = IxsChanWrite
	c=c+1;
	CurDAT(c) = {RA16_1.ReadTagVEX(['Data_' num2str(I_ch)], 0, Nsample, 'F32', 'F64', 1)};
end
NsampWrite = numel(cell2mat(CurDAT));

%% save
saveDAT = cell2mat(CurDAT);
FID = fopen(DatFile,'a'); % update == append
cnt = fwrite(FID,saveDAT,'double');
if exist('LOG','var')==1
	CurLOG=LOG;
	CurLOG.IxsChanWrite = IxsChanWrite;
	CurLOG.Nchan = numel(IxsChanWrite);
	CurLOG.NsampWrite = NsampWrite;
	CurLOG.NsampWritePerChan = NsampWrite/numel(IxsChanWrite);
	CurLOG.Fsamp = FsampRCO;

    LOGcount = LOGcount+1;
    CurLogName = ['LOG' sprintf('%04.0f',LOGcount)];
    eval([CurLogName '=CurLOG;'])
    save(LogFile,CurLogName,'-mat','-append');

    LOG = LOGREC; % reset
else
	disp('no log')
end
fclose(FID);
savefiles
%%
Savedur=toc;
