function A4_Gain3Ranges2_CombinedHHall

%Step 4 Gain
%Plot gain differences
% 10 degree responses in condition 10, 30 and 50
% 30 degree responses in condition 30 and 50

close all
clear all
            pa_datadir RG-HH-2012-01-13



        fnames   = {'SS10HHall'; 'SS30HHall'; 'SS50HHall'};
% end

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
    load(fname); % Load file
    SupSac  = SSHHall;
    width(ii) = max(SupSac(:,23));
    sel     = abs(SupSac(:,23))<=rng;
    SupSac  = SupSac(sel,:);
    y       = SupSac(:,8);
    x       = SupSac(:,23);
    stats   = regstats(y,x,'linear','all');
    b       = stats.beta;
    B(ii)   = b(2);
    se      = stats.tstat.se;
    SE(ii)  = se(2);
end


% 
h = errorbar(width,B,SE,'ko-');
hold on
set(h,'MarkerFaceColor','w','LineWidth',2);
hold on
% ylim([0.5 1.5])