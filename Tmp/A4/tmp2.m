function tmp2

%Elevation
%Step 4 Gain
%Plot gain differences
% 10 degree responses in condition 10, 30 and 50
% 30 degree responses in condition 30 and 50

%% Initialization
close all
clear all

subject = 'MW';


fnames = {'';'';'',''}
sessienr = [1 1 1 1 2 2 ];
conditions = [1 2 3 4 2 1 ];
nsets = length(fnames);
rng = [10 30 50];
nrng = length(rng);
Gain= NaN(nsets,nrng,2);
for jj = 1:nsets
    load
    pa_supersac
    regstats(X,Y)
    Baz % az
    Gaz
    Bel % el
    Gel
    
    for jj = 1:nrng
        sel = <rng(jj)
    beta = regstats(X,Y-Baz)
    % bias = 0
    Gain(ii,jj,1)
    Gain(ii,jj,2)
    end
end


            pa_datadir RG-LJ-2011-12-14



        fnames   = {'SS10LJ'; 'SS30LJ'; 'SS50LJ'};
% end

h1 = plotgain(fnames,10);

h2 = plotgain(fnames(2:3),30);
set(h2,'Color',[.3 .3 .3]);


xlabel('Target range (deg)');
ylabel('Gain');
legend([h1;h2],'10 deg','30 deg','50 deg','Location','SE');
for ii = 1:length(fnames)
    for jj = 1:length(rng)
        subplot(2,2,ii)
        g(ii,jj,:) = getgain(fnames{ii},rng(jj))
    end
end

function g = getgain(fname,rng)

dname   = fname(1:end-5);
pa_datadir(dname);
load(fname);
sel     = abs(SupSac(:,24))<=rng & abs(SupSac(:,23))<=rng;
SupSac  = SupSac(sel,:);
y       = SupSac(:,9);
x       = SupSac(:,24);
stats   = regstats(y,x,'linear','all');
b       = stats.beta;
g(1)   = b(2);

y       = SupSac(:,8);
x       = SupSac(:,23);
stats   = regstats(y,x,'linear','all');
b       = stats.beta;
g(2)   = b(2);

