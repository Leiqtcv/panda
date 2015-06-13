function pp_resultsfigure4

% Subtract Bias (Offset, which can be different for various blocks/sessies
% This removes noise (artificial variation when data is combined, e.g. in
% one set you start from +10 and another time you start at +3, when
% combining sets, the responses will be distributed largely. But when the
% offset is 0 in both, the distribution of responses can be combined, no
% artificial variation.

%% Initialization
close all
clear all
clc

% pa_datadir('RG-MW-2011-12-02')
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
    
    ]; % 1 - 10 deg, 2 - 29 deg, 3 - 50 deg, 4 - 50 deg

% for
% nsets = length(fnames);
rng = [10 30 50];
% nrng = length(rng);
% Gain = NaN(nsets,nrng,2);
GainAz = NaN(3,1);
GainEl = GainAz;
GainElse = GainAz;
GainAzse = GainAz;
for ii = 1:3
    sel = conditions==ii;
    
    fname = fnames(sel);
    nfiles = length(fname);
    SS = [];
    for jj = 1:nfiles
        file = fname{jj};
        pa_datadir(['Prior\' file(1:end-5)]);
        load(file); %load fnames(ii) = load('fnames(ii)');
        SupSac      = pa_supersac(Sac,Stim,2,1);
        SS          = [SS;SupSac];
    end
    sel = abs(SS(:,23))<=10 & abs(SS(:,24))<=10;
    TarAz       = SS(sel,23);
    TarEl       = SS(sel,24);
    ResAz       = SS(sel,8);
    ResEl       = SS(sel,9);
    RT = SS(sel,5);

    %     pa_loc(TarAz,ResAz);
    sel = TarAz>0;
    b = regstats(ResAz(sel),TarAz(sel),'linear','beta');
    ResAz(sel) = ResAz(sel)-b.beta(1);
    sel = TarAz<0;
    b = regstats(ResAz(sel),TarAz(sel),'linear','beta');
    ResAz(sel) = ResAz(sel)-b.beta(1);
    
    b = regstats(ResAz,TarAz,'linear',{'beta','r','tstat'});
    GainAz(ii) = b.beta(2);
    GainAzse(ii) = b.tstat.se(2);
    
    b = regstats(ResEl,TarEl,'linear',{'beta','r','tstat'});
    GainEl(ii) = b.beta(2);
    GainElse(ii) = b.tstat.se(2);
end

subplot(121)
errorbar(rng,GainAz,GainAzse,'k.','LineWidth',2)
hold on
plot(rng,GainAz,'ko-','MarkerFaceColor','w','LineWidth',2)
axis([0 60 0 1.7]);
axis square;
box off
xlabel('Range (deg)');
ylabel('Azimuth gain');


subplot(122)
errorbar(rng,GainEl,GainElse,'k.','LineWidth',2)
hold on
plot(rng,GainEl,'ko-','MarkerFaceColor','w','LineWidth',2)
axis([0 60 0 1.7]);
axis square;
box off
xlabel('Range (deg)');
ylabel('Elevation gain');


