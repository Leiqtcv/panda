function Gain = A4_Gain_Matrix(subject)

% Subtract Bias (Offset, which can be different for various blocks/sessies
% This removes noise (artificial variation when data is combined, e.g. in
% one set you start from +10 and another time you start at +3, when
% combining sets, the responses will be distributed largely. But when the
% offset is 0 in both, the distribution of responses can be combined, no
% artificial variation.

%% Initialization
close all
clear all
% clc

if nargin<1
subject = 'RG'
end

switch subject
    
   

    case 'MW'
fnames = {'RG-MW-2011-12-02-0001';'RG-MW-2011-12-02-0002';'RG-MW-2011-12-02-0003';'RG-MW-2011-12-02-0004';...
'RG-MW-2011-12-02-0005';'RG-MW-2011-12-02-0006';'RG-MW-2011-12-02-0007';'RG-MW-2011-12-02-0008';...
    'RG-MW-2011-12-08-0001';'RG-MW-2011-12-08-0002';'RG-MW-2011-12-08-0003';'RG-MW-2011-12-08-0004';...
    'RG-MW-2012-01-11-0001';'RG-MW-2012-01-11-0002';'RG-MW-2012-01-11-0003';'RG-MW-2012-01-11-0004';...
    'RG-MW-2012-01-12-0005';'RG-MW-2012-01-12-0006';'RG-MW-2012-01-12-0007';'RG-MW-2012-01-12-0008';...
     'RG-MW-2012-01-19-0001';'RG-MW-2012-01-19-0002';'RG-MW-2012-01-19-0003';'RG-MW-2012-01-19-0004';...
    
};
sessienr = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 ];
conditions = [3 2 3 1,...
    3 2 1 3,...
    2 3 1 3,...
    2 3 1 3,...
    3 1 3 2,...
    1 3 3 2
    
    ];

    case  'LJ'
fnames = {    'RG-LJ-2011-12-14-0001';'RG-LJ-2011-12-14-0002';'RG-LJ-2011-12-14-0003';'RG-LJ-2011-12-14-0004';...
'RG-LJ-2011-12-14-0005';'RG-LJ-2011-12-14-0006';'RG-LJ-2011-12-14-0007';'RG-LJ-2011-12-14-0008';...
'RG-LJ-2011-12-21-0001';'RG-LJ-2011-12-21-0002';'RG-LJ-2011-12-21-0003';'RG-LJ-2011-12-21-0004';...
'RG-LJ-2011-12-21-0005';'RG-LJ-2011-12-21-0006';'RG-LJ-2011-12-21-0007';'RG-LJ-2011-12-21-0008';...
'RG-LJ-2012-01-10-0001';'RG-LJ-2012-01-10-0002';'RG-LJ-2012-01-10-0003';'RG-LJ-2012-01-10-0004';...
'RG-LJ-2012-01-10-0005';'RG-LJ-2012-01-10-0006';'RG-LJ-2012-01-10-0007';'RG-LJ-2012-01-10-0008';...
'RG-LJ-2012-01-17-0001';'RG-LJ-2012-01-17-0002';'RG-LJ-2012-01-17-0003';'RG-LJ-2012-01-17-0004';...
};
sessienr = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7];
conditions = [
    2 3 1 3,...
    1 2 3 3,...
    3 1 3 2 ...
    3 2 1 3 ...
    2 3 1 3 ...
    3 3 1 2 ...
    3 2 3 1 ...
    ];
% fnames = {'RG-LJ-2011-12-14-0005';'RG-LJ-2011-12-14-0006';'RG-LJ-2011-12-14-0007';'RG-LJ-2011-12-14-0008';}
% conditions = [1 2 3 3]

    case 'RO'
        fnames = {
    'RG-RO-2011-12-12-0001';'RG-RO-2011-12-12-0002';'RG-RO-2011-12-12-0003';'RG-RO-2011-12-12-0004';...
'RG-RO-2011-12-12-0005';'RG-RO-2011-12-12-0006';'RG-RO-2011-12-12-0007';'RG-RO-2011-12-12-0008';...
'RG-RO-2012-01-11-0001';'RG-RO-2012-01-11-0002';'RG-RO-2012-01-11-0003';'RG-RO-2012-01-11-0004';...
'RG-RO-2012-01-11-0005';'RG-RO-2012-01-11-0006';'RG-RO-2012-01-11-0007';'RG-RO-2012-01-11-0008';...
'RG-RO-2012-01-18-0001';'RG-RO-2012-01-18-0002';'RG-RO-2012-01-18-0003';'RG-RO-2012-01-18-0004';...
'RG-RO-2012-01-18-0005';'RG-RO-2012-01-18-0006';'RG-RO-2012-01-18-0007';'RG-RO-2012-01-18-0008';...
};
sessienr = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6];
conditions = [
    3 2 1 3,...
    1 3 2 3,...
    3 1 3 2 ...
    3 2 1 3 ...
    2 3 1 3 ...
    3 1 3 2 ...
    ];


    case 'HH'
        fnames = {
    'RG-HH-2011-11-24-0001';'RG-HH-2011-11-24-0002';'RG-HH-2011-11-24-0003';'RG-HH-2011-11-24-0004';...
'RG-HH-2011-12-12-0001';'RG-HH-2011-12-12-0002';'RG-HH-2011-12-12-0003';'RG-HH-2011-12-12-0004';...
'RG-HH-2012-01-09-0001';'RG-HH-2012-01-09-0002';'RG-HH-2012-01-09-0003';'RG-HH-2012-01-09-0004';...
'RG-HH-2012-01-09-0005';'RG-HH-2012-01-09-0006';'RG-HH-2012-01-09-0007';'RG-HH-2012-01-09-0008';...
'RG-HH-2012-01-13-0001';'RG-HH-2012-01-13-0002';'RG-HH-2012-01-13-0003';'RG-HH-2012-01-13-0004';...
'RG-HH-2012-01-13-0005';'RG-HH-2012-01-13-0006';'RG-HH-2012-01-13-0007';'RG-HH-2012-01-13-0008';...
};
sessienr = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6];
conditions = [
    3 2 3 1,...
    1 3 3 2,...
    2 3 1 3 ...
    3 3 1 2 ...
    2 3 1 3 ...
    3 1 2 3 ...
    ];


    case 'RG'
        fnames = {
    'MW-RG-2011-12-08-0001';'MW-RG-2011-12-08-0002';'MW-RG-2011-12-08-0003';'MW-RG-2011-12-08-0004';...
'MW-RG-2011-12-08-0005';'MW-RG-2011-12-08-0006';'MW-RG-2011-12-08-0007';'MW-RG-2011-12-08-0008';...
'MW-RG-2012-01-12-0001';'MW-RG-2012-01-12-0002';'MW-RG-2012-01-12-0003';'MW-RG-2012-01-12-0004';...
'MW-RG-2012-01-12-0005';'MW-RG-2012-01-12-0006';'MW-RG-2012-01-12-0007';'MW-RG-2012-01-12-0008';...

};
sessienr = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4];
conditions = [
    2 2 3 1,...
    3 3 1 3,...
    3 2 3 1 ...
    2 3 1 3 ...
    ];

end


nsets = length(fnames);
Bias = NaN(nsets,2);
for ii = 1:nsets
    fname = fnames{ii};
    pa_datadir(['Prior\' fname(1:end-5)]);
    load(fname); %load fnames(ii) = load('fnames(ii)');
    SupSac      = pa_supersac(Sac,Stim,2,1);
    
    
    Yel       = SupSac(:,9);
    Xel       = SupSac(:,24);
    Yaz       = SupSac(:,8);
    Xaz       = SupSac(:,23);
    
    statsaz = regstats(Yaz,Xaz,'linear',{'beta'});
    statsel = regstats(Yel,Xel,'linear',{'beta'});
    
    Bias(ii,1) = statsaz.beta(1);
    Bias(ii,2) = statsel.beta(1);
    
end

%% Pool data
Gain = NaN(3,3,2);
for kk = 1:3
% kk = 3;
sel         = conditions == kk;
condfnames  = fnames(sel);
nsets       = length(condfnames);
condbias    = Bias(sel,:);
SS      = [];
for ii = 1:nsets
    fname = condfnames{ii};
    pa_datadir(['Prior\' fname(1:end-5)]);
    load(fname); %load fnames(ii) = load('fnames(ii)');
    SupSac      = pa_supersac(Sac,Stim,2,1);
    
    SS = [SS;SupSac];
end

rng     = [11 31 51];
nrng    = length(rng);
%     for jj = 1:nrng
% sel =
for jj = 1:nrng
    sel     = abs(SS(:,24))<rng(jj) & abs(SS(:,23))<rng(jj); % should hold for both!
%     sel     = abs(SS(:,24))<=rng(jj) ; % should hold for both!
    Yel       = SS(sel,9)-condbias(ii,2);
    Xel       = SS(sel,24);
    Yaz       = SS(sel,8)-condbias(ii,1);
    Xaz       = SS(sel,23);
    
    statsaz = regstats(Yaz,Xaz,'linear',{'beta'});
    statsel = regstats(Yel,Xel,'linear',{'beta'});
    
    Gain(kk,jj,1) = statsaz.beta(2);
    Gain(kk,jj,2) = statsel.beta(2);
    
%     seaz              = statsaz.tstat.se;
%     seel              = statsel.tstat.se;
%     
%     SE(kk,jj,1)     = seaz(1);
%     SE(kk,jj,2)     = seel(1);
    
    

    figure(kk)
    subplot(2,3,jj)
    pa_loc(Xaz,Yaz);

    subplot(2,3,jj+3)
    pa_loc(Xel,Yel);
    
%     h = errorbar(width,B,SE,'ko-');
%     hold on
%     set(h,'MarkerFaceColor','w','LineWidth',2);


end
end

Gain
return
%% plot gain here


h1 = plotgain(fnames,10);

h2 = plotgain(fnames(2:3),30);
set(h2,'Color',[.3 .3 .3]);


xlabel('Target range (deg)');
ylabel('Gain');
legend([h1;h2],'10 deg','30 deg','50 deg','Location','SE');


function h = plotgain(fnames,rng)

ncond   = size(fnames,1);
width   = 1:length(fnames);
B       = NaN(ncond,1);
SE      = NaN(ncond,1);
for ii = 1:ncond
    fname   = fnames{ii};
%     pa_datadir RG-LJ-2012-01-17
    load(fname); % Load file
%     fname= str2double(fname);
    SupSac  = SSLJall;
    width(ii) = max(SupSac(:,24));
    sel     = abs(SupSac(:,24))<=rng;
    SupSac  = SupSac(sel,:);
    y       = SupSac(:,9);
    x       = SupSac(:,24);
    stats   = regstats(y,x,'linear','all');
    b       = stats.beta;
    B(ii)   = b(2);
    se      = stats.tstat.se;
    SE(ii)  = se(2);
end

subplot(224)
% 
h = errorbar(width,B,SE,'ko-');
hold on
set(h,'MarkerFaceColor','w','LineWidth',2);
hold on
% ylim([0.5 1.5])
saveas (h, 'GainLJall', 'fig')