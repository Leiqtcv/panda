function pp_resultsfigure1

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
        SS = [SS;SupSac];
    end
    TarAz       = SS(:,8);
    TarEl       = SS(:,9);
    TarAz = TarAz - mean(TarAz);
    TarEl = TarEl - mean(TarEl);
    
    [R,Phi] = pa_azel2pol(TarAz,TarEl);
    [X,Y,Z] = pa_azel2pol(TarAz,TarEl);
    
    subplot(2,3,ii)
    pa_bubbleplot(TarAz,TarEl,7,7)
    drawnow
    pause(1)
    %     return
    %     plot(TarAz,TarEl,'k.','MarkerFaceColor','w');
    hold on
    switch ii
        case 1
            % 10 deg square
            plot([-11 11],[11 11],'r-','LineWidth',2)
            plot([-11 11],[-11 -11],'r-','LineWidth',2)
            plot([11 11],[-11 11],'r-','LineWidth',2)
            plot([-11 -11],[-11 11],'r-','LineWidth',2)
        case 2
            %29 deg square
            plot([-29 29],[29 29],'g-','LineWidth',2)
            plot([-29 29],[-29 -29],'g-','LineWidth',2)
            plot([29 29],[-29 29],'g-','LineWidth',2)
            plot([-29 -29],[-29 29],'g-','LineWidth',2)
        case 3
            %50 deg square
            plot([-51 51],[51 51],'b-','LineWidth',2)
            plot([-51 51],[-51 -51],'b-','LineWidth',2)
            plot([51 51],[-51 51],'b-','LineWidth',2)
            plot([-51 -51],[-51 51],'b-','LineWidth',2)
    end
    
    %     plot([-90 0],[0 -90],'b-','LineWidth',2)
    %     plot([0 90],[-90 0],'b-','LineWidth',2)
    %     plot([0 90],[90 0],'b-','LineWidth',2)
    %     plot([-90 0],[0 90],'b-','LineWidth',2)
    

    axis([-90 90 -90 90]);
    axis square;
    axis equal
    xlabel('Target azimuth (deg)');
    ylabel('Target elevation (deg)');
    %     str = 'Ran
    
    title(rng(ii))
    
    subplot(2,3,ii+3)
    Phi = pa_deg2rad(Phi);
    polar(Phi,R,'k.');
    hold on
    
end
axis equal
