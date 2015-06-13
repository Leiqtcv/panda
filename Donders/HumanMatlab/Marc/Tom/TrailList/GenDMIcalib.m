%%
FLAGplot = true;
% Sky led locations
LEDSKY_RING=[0,5,9,14,20,27,35,43];
LEDSKY_SPOKE=[60 30 0 330 300 : -30 : 90];
% resize
ALL_Rings = repmat(LEDSKY_RING,numel(LEDSKY_SPOKE),1);
ALL_Spkes = repmat(LEDSKY_SPOKE',1,numel(LEDSKY_RING));
%%
% head positions
Hs_Rs = [0 9 20 35];
Hs_Ss = [90 60 30 0 330 300 : -30 : 120];
% eye in head positions
Eh_Rs = [-30:15:30];
Eh_Ss = Hs_Ss;
% resize
H_Rings = repmat(Hs_Rs',1,numel(Hs_Ss));
H_Spkes = repmat(Hs_Ss,numel(Hs_Rs),1);
% make vector
H_Rings = H_Rings(:);
H_Spkes = H_Spkes(:);
% resize
H_Rings = repmat(H_Rings',numel(Eh_Rs),1);
H_Spkes = repmat(H_Spkes',numel(Eh_Rs),1);
% eye in space positions
Eh_Rings = repmat(Eh_Rs',1,numel(Hs_Ss)*numel(Hs_Rs));
E_Rings = H_Rings+Eh_Rings;
E_Spkes = H_Spkes;
% make vector
H_Rings = H_Rings(:);
H_Spkes = H_Spkes(:);
E_Rings = E_Rings(:);
E_Spkes = E_Spkes(:);

sel = E_Rings < 0;
E_Spkes(sel)=E_Spkes(sel)+180;
E_Rings(sel)=E_Rings(sel)*-1;
sel = E_Spkes >= 360;
E_Spkes(sel)=E_Spkes(sel)-360;

%% plot
if FLAGplot
    figure; hold on
    h=polar(deg2rad(ALL_Spkes),ALL_Rings,'sb');
    set(h,'markeredgecolor','none','markerfacecolor',[0 1 0].*.8)
    polar(deg2rad(H_Spkes),H_Rings,'ok')
    polar(deg2rad(E_Spkes),E_Rings,'*k')
    for I_hs = 1:size(H_Rings,1)
        h1=polar(deg2rad(H_Spkes(I_hs,1)),H_Rings(I_hs,1),'or');
        h2=polar(deg2rad(E_Spkes(I_hs,1)),E_Rings(I_hs,1),'*r');
        set(h1,'markersize',15,'linewidth',3)
        set(h2,'markersize',15,'linewidth',3)
        drawnow
        delete(h1)
        delete(h2)
    end
    close
end
%%
LS = repmat(LEDSKY_RING,numel(H_Rings),1);
Tar = repmat(H_Rings,1,numel(LEDSKY_RING));
H_Irings = nan(numel(H_Rings),1);
for I = 1:numel(H_Rings)
    H_Irings(I) = find(Tar(I,:)==LS(I,:));
end
LS = repmat(LEDSKY_SPOKE,numel(H_Spkes),1);
Tar = repmat(H_Spkes,1,numel(LEDSKY_SPOKE));
H_Ispkes = nan(numel(H_Spkes),1);
for I = 1:numel(H_Spkes)
    H_Ispkes(I) = find(Tar(I,:)==LS(I,:));
end
LS = repmat(LEDSKY_RING,numel(E_Rings),1);
Tar = repmat(E_Rings,1,numel(LEDSKY_RING));
E_Irings = nan(numel(E_Rings),1);
[m,i]=min(abs([LS-Tar]),[],2);
for I = 1:numel(E_Rings)
    E_Irings(I) = i(I);
end
LS = repmat(LEDSKY_SPOKE,numel(E_Spkes),1);
Tar = repmat(E_Spkes,1,numel(LEDSKY_SPOKE));
E_Ispkes = nan(numel(E_Spkes),1);
[m,i]=min(abs([LS-Tar]),[],2);
for I = 1:numel(E_Rings)
    E_Ispkes(I) = i(I);
end
%%
if FLAGplot
    figure; hold on
    h=polar(deg2rad(ALL_Spkes),ALL_Rings,'sb');
    set(h,'markeredgecolor','none','markerfacecolor',[0 1 0].*.8)
    polar(deg2rad(H_Spkes),H_Rings,'ok')
    polar(deg2rad(E_Spkes),E_Rings,'*k')
    for I_hs = 1:size(H_Rings,1)
        h1=polar(deg2rad(LEDSKY_SPOKE(H_Ispkes(I_hs,1))),LEDSKY_RING(H_Irings(I_hs,1)),'or');
        h2=polar(deg2rad(LEDSKY_SPOKE(E_Ispkes(I_hs,1))),LEDSKY_RING(E_Irings(I_hs,1)),'*r');
        h3=polar(deg2rad(E_Spkes(I_hs,1)),E_Rings(I_hs,1),'*b');
        set(h1,'markersize',15,'linewidth',3)
        set(h2,'markersize',15,'linewidth',3)
        set(h3,'markersize',10,'linewidth',2)
        drawnow
        delete(h1)
        delete(h2)
        delete(h3)
    end
    close
end
%% change order and remove repeats
[u,i]=unique([H_Irings H_Ispkes E_Irings E_Ispkes abs(-H_Irings + E_Irings) E_Irings],'rows');
sel = u(:,2)~=u(:,4);
u(sel,6)=u(sel,6)*-1;
u = sortrows(u,[2 1 6]);
%%
if FLAGplot
    figure; hold on
    h=polar(deg2rad(ALL_Spkes),ALL_Rings,'sb');
    set(h,'markeredgecolor','none','markerfacecolor',[0 1 0].*.8)
    polar(deg2rad(H_Spkes),H_Rings,'ok')
    for I_hs = 1:size(u,1)
        h1=polar(deg2rad(LEDSKY_SPOKE(u(I_hs,2))),LEDSKY_RING(u(I_hs,1)),'or');
        h2=polar(deg2rad(LEDSKY_SPOKE(u(I_hs,4))),LEDSKY_RING(u(I_hs,3)),'*r');
        set(h1,'markersize',15,'linewidth',3)
        set(h2,'markersize',15,'linewidth',3)
        drawnow
        delete(h1)
        delete(h2)
    end
    close
end
%%
H_Irings=u(:,1);
H_Ispkes=u(:,2);
E_Irings=u(:,3);
E_Ispkes=u(:,4);

IxRings     = [H_Irings E_Irings];
IxSpokes    = [H_Ispkes E_Ispkes];

% fix central LED, always use spoke 1
IxRings     = IxRings - 1; % 0 is center
sel = IxRings == 0;
IxSpokes(sel) = 0;
IxRings(sel) = 2; %2: green 1: red

[u2,i]=unique([IxSpokes IxRings],'rows');
IxSpokes = IxSpokes(sort(i),:);
IxRings = IxRings(sort(i),:);
%%
if FLAGplot
    figure; hold on
    h=polar(deg2rad(ALL_Spkes),ALL_Rings,'sb');
    set(h,'markeredgecolor','none','markerfacecolor',[0 1 0].*.8)
    polar(deg2rad(H_Spkes),H_Rings,'ok')
    for I_hs = 1:size(u2,1)
        [Ha,He] = sky2azel(IxRings(I_hs,1),IxSpokes(I_hs,1));
        [Ea,Ee] = sky2azel(IxRings(I_hs,2),IxSpokes(I_hs,2));
        h1=plot(Ha,He,'or');
        h2=plot(Ea,Ee,'*r');
        set(h1,'markersize',15,'linewidth',3)
        set(h2,'markersize',15,'linewidth',3)
        pause(.1)
        delete(h1)
        delete(h2)
    end
    close
end
%% create Mtx
Ntar = size(IxRings,2);
Ntrl = size(IxRings,1);
IxRingSpokes = nan(Ntrl,Ntar*2);
IxRingSpokes(:,1:2:end)=IxRings;
IxRingSpokes(:,2:2:end)=IxSpokes;
Targets = [ones(Ntrl,1)*Ntar IxRingSpokes , zeros(Ntrl,21-(Ntar*2+1))];

% save
fn = ['D:\HumanMatlab\Tom\TrailList\DMIcalibration.mat'];
disp(fn)
save(fn,'Targets','-mat')
