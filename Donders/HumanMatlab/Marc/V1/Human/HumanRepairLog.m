function HumanRepairLog(LogFile)
%%
BupFile = [LogFile(1:end-3) 'log.bup'];
c=0;
OK=false;
while OK == false
    if exist(BupFile,'file')==2
        c=c+1;
        if c>1
            BupFile = [BupFile(1:end-1) num2str(c)];
        else
            BupFile = [BupFile num2str(c)];
        end
    else
        OK = true;
    end
end
%%
ws      = load(LogFile,'-mat');
copyfile(LogFile,BupFile)
str     = char(fieldnames(ws));
NLog    = max(str2num(str(:,4:end)));
if any(ismember(str,'LOG','rows'))
    LOG     = ws.LOG;
else
    LOG     = ws.LOG0001;
end
for I = 1:NLog
    CurName = ['ws.LOG' sprintf('%04.0f',I)];
    CurLOG  = eval(CurName);
    LOG     = [LOG;CurLOG];
end
%%
save(LogFile,'LOG','-mat')