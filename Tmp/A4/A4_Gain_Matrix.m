function A4_Gain_Matrix

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
fnames = {'RG-MW-2011-12-02-0001';'RG-MW-2011-12-02-0002';'RG-MW-2011-12-02-0003';'RG-MW-2011-12-02-0004'};
sessienr = [1 1 1 1 ];
conditions = [3 2 4 1];
nsets = length(fnames);
rng = [10 30 50];
nrng = length(rng);
Gain = NaN(nsets,nrng,2);
for ii = conditions
    fname = fnames{ii};
    pa_datadir(['Prior\' fname(1:end-5)]);
    load(fname); %load fnames(ii) = load('fnames(ii)');
    SupSac      = pa_supersac(Sac,Stim,2,1);
    
    for jj = 1:nrng
        sel     = abs(SupSac(:,24))<rng(jj) & abs(SupSac(:,23))<rng(jj); % should hold for both!
        
        Yel       = SupSac(sel,9);
        Xel       = SupSac(sel,24);
        Yaz       = SupSac(sel,8);
        Xaz       = SupSac(sel,23);
        
        
        statsaz = regstats(Yaz,Xaz,'linear',{'beta'});
        statsel = regstats(Yel,Xel,'linear',{'beta'});
        
        
        
        Baz = statsaz.beta(1);
        Bel = statsel.beta(1);
        
        figure
        plot(Xaz,Yaz,'k.');
        hold on
        plot(Xaz,Yaz-Baz,'r.');
        %corrected data in red
        pa_unityline;
        pa_verline(0);
        pa_horline(0);
        
        statsaz = regstats(Yaz-Baz,Xaz,'linear',{'beta'});
        statsel = regstats(Yel-Bel,Xel,'linear',{'beta'});
        statsaz.beta(1)
        % bias = 0
        %     Gain(ii,jj,1)
        Gain(ii, jj,1) = statsaz.beta(2);
        Gain(ii,jj,2) = statsel.beta(2);
        [ii jj sum(sel)]
        str = ['Set: ' num2str(ii) ', Rng: ' num2str(rng(jj)) ', # res: ' num2str(sum(sel))];
        title(str)
    end
end


whos Gain
sel = sessienr==1;
g = squeeze(Gain(sel,:,1));
%  save ('Test', 'Gain')
%
% plot(rng,g)
%             pa_datadir RG-LJ-2011-12-14
%
%
%
%         fnames   = {'SS10LJ'; 'SS30LJ'; 'SS50LJ'};
% % end
%
% h1 = plotgain(fnames,10);
%
% h2 = plotgain(fnames(2:3),30);
% set(h2,'Color',[.3 .3 .3]);
%
%
% xlabel('Target range (deg)');
% ylabel('Gain');
% legend([h1;h2],'10 deg','30 deg','50 deg','Location','SE');
% for ii = 1:length(fnames)
%     for jj = 1:length(rng)
%         subplot(2,2,ii)
%         g(ii,jj,:) = getgain(fnames{ii},rng(jj))
%     end
% end
%
% function g = getgain(fname,rng)
%
% dname   = fname(1:end-5);
% pa_datadir(dname);
% load(fname);
% sel     = abs(SupSac(:,24))<=rng & abs(SupSac(:,23))<=rng;
% SupSac  = SupSac(sel,:);
% y       = SupSac(:,9);
% x       = SupSac(:,24);
% stats   = regstats(y,x,'linear','all');
% b       = stats.beta;
% g(1)   = b(2);
%
% y       = SupSac(:,8);
% x       = SupSac(:,23);
% stats   = regstats(y,x,'linear','all');
% b       = stats.beta;
% g(2)   = b(2);

