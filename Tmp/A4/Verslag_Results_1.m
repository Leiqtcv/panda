close all
clear all
clc

fnames = {'RG-MW-2011-12-02-0001';'RG-MW-2011-12-02-0002';'RG-MW-2011-12-02-0003';'RG-MW-2011-12-02-0004';...
    'RG-MW-2011-12-02-0005';'RG-MW-2011-12-02-0006';'RG-MW-2011-12-02-0007';'RG-MW-2011-12-02-0008';...
    'RG-MW-2011-12-08-0001';'RG-MW-2011-12-08-0002';'RG-MW-2011-12-08-0003';'RG-MW-2011-12-08-0004';...
    'RG-MW-2012-01-11-0001';'RG-MW-2012-01-11-0002';'RG-MW-2012-01-11-0003';'RG-MW-2012-01-11-0004';...
    'RG-MW-2012-01-12-0005';'RG-MW-2012-01-12-0006';'RG-MW-2012-01-12-0007';'RG-MW-2012-01-12-0008';...
    'RG-MW-2012-01-19-0001';'RG-MW-2012-01-19-0002';'RG-MW-2012-01-19-0003';'RG-MW-2012-01-19-0004';...
    };
conditions = [3 2 3 1,...
    3 2 1 3,...
    2 3 1 3,...
    2 3 1 3,...
    3 1 3 2,...
    1 3 3 2]; % 1 - 10 deg, 2 - 29 deg, 3 - 50 deg, 4 - 50 deg

for ii = 1:3
    sel = conditions==ii;
    
    fname = fnames(sel);
    nfiles = length(fname);
    SS = [];
    for jj = 1:nfiles
        file = fname{jj};
        pa_datadir(file(1:end-5));
        load(file); %load fnames(ii) = load('fnames(ii)');
        SupSac      = pa_supersac(Sac,Stim,2,1);
        SS          = [SS;SupSac]; %#ok<AGROW>
    end
    
   
    for hh = 1:21
       
        f = (-50+(hh*5));
        k = find(SS(:,24)==f);
        Susa = SS(k,:);
        Husa = Susa(:,9);
        l = length(Husa);
        TR = Susa(:,9);
        m = mean(Susa(:,9));
        s = std(Susa(:,9));
        figure(9)
        subplot(1,3,ii)
        errorbar(f,m,s,'o');
        hold on;
        pa_horline;
        pa_verline;
        pa_unityline;
        axis ([-55 55 -55 55])
        axis square
    end
     
    for kk = 1:5
       
        p = (-15+(kk*5));
        k = find(SS(:,24)==p);
        Susa = SS(k,:);
        Husa = Susa(:,9);
        l = length(Husa);
        TR = Susa(:,9);
        m = mean(Susa(:,9));
        s = std(Susa(:,9));
        figure(9)
        subplot(1,3,ii)
        errorbar(p,m,s,'ro');
        hold on;
        pa_horline;
        pa_verline;
        pa_unityline;
        axis ([-55 55 -55 55])
        axis square
        mt(ii,kk) = m
        pt(ii,kk) = p
    end
    
    sel = SS(:,24)<11 & SS(:,24)>-11;
    n = SS(sel,24);
    e= SS(sel,9);
%     g= mt(2,:);
%     l= mt(3,:);
    
    p= pt(1,:);
    b = regstats(e,n,'linear',{'beta','r'}); 
    subplot(1,3,ii);
    str = ['\epsilon_R = ' num2str(b.beta(2),2)];
    title(str)
    
end
%     e= mt(1,:);
% %     g= mt(2,:);
% %     l= mt(3,:);
%     
%     p= pt(1,:);
%     b = regstats(e,p,'linear',{'beta','r'}); 
%     subplot(1,3,ii);
%     plot([-15 15],b.beta(2)*[-15 15],'r-','LineWidth',2);
%     str = ['\epsilon_R = ' num2str(b.beta(2),2)];
%     title(str)
    
    
%     plot([-15 15],(b.beta*2)*[-15 15],'r-','LineWidth',2);
    
    %      for l = 1:3
%     b(l,:) = regstats(mt(l,:),pt(l,:),'linear',{'beta','r'}); 
%      end
return
%         if f > -11 && f < 11; 
%             
%             sel = SS(:,24)>-11 & SS(:,24)<11;
%             TarEl       = SS(sel,24);
%             ResEl       = SS(sel,9);
% 
% 
% gain(ii) = b.beta(2);
% subplot(1,3,ii)
% str = ['\epsilon_R = ' num2str(gain(ii),2)];
% plot([-15 15],gain(ii)*[-15 15],'r-','LineWidth',2);
% % plot(TarEl,ResEl,'o');
% % axis([-30 30 -30 30]);
% % pa_unityline;
% 
% % title(str)
% % pa_verline([-15 15],'r-');
% 
% % box off  
%             
%         end
% %         end
%     end
%         
%  end
%     
%     end