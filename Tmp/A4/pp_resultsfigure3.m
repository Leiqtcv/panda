function pp_resultsfigure3

% Subtract Bias (Offset, which can be different for various blocks/sessies
% This removes noise (artificial variation when data is combined, e.g. in
% one set you start from +10 and another time you start at +3, when
% combining sets, the responses will be distributed largely. But when the
% offset is 0 in both, the distribution of responses can be combined, no
% artificial variation.

%% Initialization
% close all
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
figure(2)    
RT = SS(sel,5);
    subplot(2,3,ii);
%     pa_loc(TarAz,ResAz);
sel = TarAz>0;
b = regstats(ResAz(sel),TarAz(sel),'linear','beta');
ResAz(sel) = ResAz(sel)-b.beta(1);
sel = TarAz<0;
b = regstats(ResAz(sel),TarAz(sel),'linear','beta');
ResAz(sel) = ResAz(sel)-b.beta(1);

b = regstats(ResAz,TarAz,'linear',{'beta','r'});
pa_bubbleplot(TarAz,ResAz-b.beta(1),20,5);
axis([-30 30 -30 30]);
pa_unityline;
str = ['\alpha_R = ' num2str(b.beta(2),2) '\alpha_T, N = ' num2str(numel(TarAz)) ', \Sigma = ' num2str(std(b.r),2) ', RT = ' num2str(median(RT),3)];
title(str)
pa_verline([-15 15],'r-');
plot([-15 15],b.beta(2)*[-15 15],'r-','LineWidth',2);
box off

subplot(2,3,ii+3);
%     pa_loc(TarEl,ResEl);
b = regstats(ResEl,TarEl,'linear',{'beta','r'});
pa_bubbleplot(TarEl,ResEl-b.beta(1),20,5);
axis([-30 30 -30 30]);
pa_unityline;
str = ['\epsilon_R = ' num2str(b.beta(2),2) '\epsilon_T, N = ' num2str(numel(TarAz)) ', \Sigma = ' num2str(std(b.r),2) ', RT = ' num2str(median(RT),3)];
title(str)
pa_verline([-15 15],'r-');
plot([-15 15],b.beta(2)*[-15 15],'r-','LineWidth',2);
box off

end

