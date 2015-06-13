fname                       = [];
fname                       = fcheckexist(fname,'*.dat');
csvfile                     = fcheckext(fname,'csv');
[expinfo,chaninfo,mLog]     = readcsv(csvfile);
Nsamples                    = chaninfo(1,6);
Fsample                     = chaninfo(1,5);
Ntrial                      = max(mLog(:,1));
StimType                    = mLog(:,5);
StimOnset                   = mLog(:,8);
Stim                        = log2stim(mLog);
NChan                       = expinfo(1,8);
DAT                         = loaddat(fname, NChan, Nsamples,Ntrial);
% Traces
hortrace                    = squeeze(DAT(:,:,1));
vertrace                    = squeeze(DAT(:,:,2));
fronttrace                  = squeeze(DAT(:,:,3));
% Average of traces
H                           = mean(hortrace);
V                           = mean(vertrace);
F                           = mean(fronttrace);
% Select Fixation LED (LED = type 0)
sel                         = ismember(Stim(:,3),0:1);
TarAz                       = Stim(sel,4);
TarEl                       = Stim(sel,5);
Hx=1:length(H)
Vx=1:length(V)

Inipar(1)                              = -90;
Inipar(2)                              = 1/((max(Vx)-min(Vx))/2);
Inipar(3)                              = mean(Vx);
Inipar(4)                              = 0;
Vpar                                   = fitasin(V,TarEl,Inipar);
CalV                                   = asinfun(V,Vpar);
CalV                                   = CalV(:);

Inipar(1)                               = -90;
Inipar(2)                               = 1/((max(Hx)-min(Hx))/2);
Inipar(3)                               = mean(Hx);
Inipar(4)                               = 0;
Hpar                                    = fitasin(H,TarAz,Inipar);
CalH                                    = asinfun(H,Hpar);
CalH                                    = CalH(:);


