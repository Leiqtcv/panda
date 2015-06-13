LOG = LOGREC;
tic;
save('D:\HumanMatlab\Tom\DAT\temp.log','LOG','-mat');
t=toc;
disp(['save: ' num2str(t)])
ts = nan(600,1);
for I = 1:600
    CurLOG = LOGREC;
    tic;
    prev = load(LogFile,'-mat');
    LOG=[prev.LOG;CurLOG];
    save(LogFile,'LOG','-mat')
    LOG = LOGREC; % reset
    t=toc;
    disp(['save: ' num2str(t)])
    ts(I)=t;
end
%%
LOG = LOGREC;
tic;
save('D:\HumanMatlab\Tom\DAT\temp.log','LOG','-mat');
t=toc;
disp(['save: ' num2str(t)])
ts = nan(600,1);
for I = 1:1000
    CurLOG = LOGREC;
    CurLOG.Trial = I;
    CurLOG.TarPos = {rand(rand_num([2 10]),2)};
    CurLOG.Status = {rand(rand_num([2 10]),2)>1};
    CurName = ['LOG' sprintf('%04.0f',I)];
    eval([CurName '=CurLOG;'])
    disp([CurName '=CurLOG;'])
    tic;
    save('D:\HumanMatlab\Tom\DAT\temp.log',CurName,'-mat','-append');
    t=toc;
    disp(['save: ' num2str(t)])
    ts(I)=t;
end
%%
close all
figure
plot(ts,'.')
%%
tic;
ws=load('D:\HumanMatlab\Tom\DAT\temp.log','-mat');
t=toc;
disp(['load: ' num2str(t)])

%%
ws=load('D:\HumanMatlab\Tom\DAT\temp.log','-mat');
str=char(fieldnames(ws));
NLog = max(str2num(str(:,[4:end])));
LOG = ws.LOG;
for I = 1:NLog
    CurName = ['LOG' sprintf('%04.0f',I)];
    CurLOG = eval(CurName);
    LOG = [LOG;CurLOG];
end

