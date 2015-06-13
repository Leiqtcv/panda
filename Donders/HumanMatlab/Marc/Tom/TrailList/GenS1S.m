%%
FLAGplot = true;
% Sky led locations
LEDSKY_RING=[0,5,9,14,20,27,35,43];
LEDSKY_SPOKE=[60 30 0 330 300 : -30 : 90];
% resize
ALL_Rings = repmat(LEDSKY_RING,numel(LEDSKY_SPOKE),1);
ALL_Spkes = repmat(LEDSKY_SPOKE',1,numel(LEDSKY_RING));
%%
% target position
Rs = [5,9,14,20,27,35,43];
Ss = [90 60 30 0 330 300 : -30 : 120];
Rings = repmat(Rs',1,numel(Ss));
Spkes = repmat(Ss,numel(Rs),1);
Rings = Rings(:);
Spkes = Spkes(:);

%% plot
if FLAGplot
    figure; hold on
    h=polar(deg2rad(ALL_Spkes),ALL_Rings,'sb');
    set(h,'markeredgecolor','none','markerfacecolor',[0 1 0].*.8)
    polar(deg2rad(Spkes),Rings,'ok')
    for I = 1:size(Rings,1)
        h1=polar(deg2rad(Spkes(I,1)),Rings(I,1),'or');
        set(h1,'markersize',15,'linewidth',3)
        drawnow
        delete(h1)
    end
    close
end
%% nearest led
LS = repmat(LEDSKY_RING,numel(Rings),1);
Tar = repmat(Rings,1,numel(LEDSKY_RING));
Irings = nan(numel(Rings),1);
[m,i]=min(abs([LS-Tar]),[],2);
for I = 1:numel(Rings)
    Irings(I) = i(I);
end
LS = repmat(LEDSKY_SPOKE,numel(Spkes),1);
Tar = repmat(Spkes,1,numel(LEDSKY_SPOKE));
Ispkes = nan(numel(Spkes),1);
[m,i]=min(abs([LS-Tar]),[],2);
for I = 1:numel(Rings)
    Ispkes(I) = i(I);
end
%%
if FLAGplot
    figure; hold on
    h=polar(deg2rad(ALL_Spkes),ALL_Rings,'sb');
    set(h,'markeredgecolor','none','markerfacecolor',[0 1 0].*.8)
    polar(deg2rad(Spkes),Rings,'ok')
    for I = 1:size(Rings,1)
        h1=polar(deg2rad(LEDSKY_SPOKE(Ispkes(I,1))),LEDSKY_RING(Irings(I,1)),'or');
        set(h1,'markersize',15,'linewidth',3)
        drawnow
        delete(h1)
    end
    close
end
%% change order and remove repeats
[u,i]=unique([Irings Ispkes],'rows');
u = sortrows(u,[2 1]);
%%
if FLAGplot
    figure; hold on
    h=polar(deg2rad(ALL_Spkes),ALL_Rings,'sb');
    set(h,'markeredgecolor','none','markerfacecolor',[0 1 0].*.8)
    polar(deg2rad(Spkes),Rings,'ok')
    for I = 1:size(u,1)
        h1=polar(deg2rad(LEDSKY_SPOKE(u(I,2))),LEDSKY_RING(u(I,1)),'or');
        set(h1,'markersize',15,'linewidth',3)
        drawnow
        delete(h1)
    end
    close
end
%% fix central LED
Irings=u(:,1);
Ispkes=u(:,2);
IxRings     = [Irings];
IxSpokes    = [Ispkes];

% always use spoke 1 when center
IxRings     = IxRings - 1; % 0 is center
sel = IxRings == 0;
IxSpokes(sel) = 0;
IxRings(sel) = 2; %2: green 1: red
% remove duplicates
[u2,i]=unique([IxSpokes IxRings],'rows');
IxSpokes = IxSpokes(sort(i),:);
IxRings = IxRings(sort(i),:);
%%
if FLAGplot
    figure; hold on
    h=polar(deg2rad(ALL_Spkes),ALL_Rings,'sb');
    set(h,'markeredgecolor','none','markerfacecolor',[0 1 0].*.8)
    polar(deg2rad(Spkes),Rings,'ok')
    for I = 1:size(u2,1)
        [a,e] = sky2azel(IxRings(I,1),IxSpokes(I,1));
        h1=plot(a,e,'or');
        set(h1,'markersize',15,'linewidth',3)
        pause(.1)
        delete(h1)
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
fn = ['D:\HumanMatlab\Tom\TrailList\Static1step.mat'];
disp(fn)
save(fn,'Targets','-mat')
