clear all
%%
FLAGplot = false;
FOV = 40; %field of view deg
% Sky led locations
LEDSKY_RING=[0,5,9,14,20,27,35,43];
LEDSKY_SPOKE=[60 30 0 330 300 : -30 : 90];
% resize
ALL_Rings = repmat(LEDSKY_RING,numel(LEDSKY_SPOKE),1);
ALL_Spkes = repmat(LEDSKY_SPOKE',1,numel(LEDSKY_RING));
%%
% target positions pool fixation
Rs = [0];
Ss = [0];
Rings = repmat(Rs',1,numel(Ss));
Spkes = repmat(Ss,numel(Rs),1);
RingsF = Rings(:);
SpkesF = Spkes(:);

% target positions pool Target 1
Rs = [0,5,9,14,20,27,35,43]; % at least 14 deg to generate enough speed
%Ss = [90 60 30 0 330 300 : -30 : 120];
Ss = [0:60:360];
Rings = repmat(Rs',1,numel(Ss));
Spkes = repmat(Ss,numel(Rs),1);
RingsT1 = Rings(:);
SpkesT1 = Spkes(:);

% target positions pool Target 2
Rs = [0,5,9,14,20,27,35,43];
%Ss = [90 60 30 0 330 300 : -30 : 120];
Ss = [30:60:360];
Rings = repmat(Rs',1,numel(Ss));
Spkes = repmat(Ss,numel(Rs),1);
RingsT2 = Rings(:);
SpkesT2 = Spkes(:);

%% plot
if FLAGplot
    figure; hold on
    h=polar(deg2rad(ALL_Spkes),ALL_Rings,'sb');
    set(h,'markeredgecolor','none','markerfacecolor',[0 1 0].*.8)
    polar(deg2rad(Spkes),Rings,'ok')
    for I0 = 1:size(RingsF,1)
        h0=polar(deg2rad(SpkesF(I0,1)),RingsF(I0,1),'.r');
        set(h0,'markersize',5,'linewidth',3)
        for I1 = 1:size(RingsT1,1)
            h1=polar(deg2rad(SpkesT1(I1,1)),RingsT1(I1,1),'or');
            set(h1,'markersize',15,'linewidth',3)
            for I2 = 1:size(RingsT2,1)
                h2=polar(deg2rad(SpkesT2(I2,1)),RingsT2(I2,1),'*r');
                set(h2,'markersize',15,'linewidth',3)
                drawnow
                delete(h2)
            end
            delete(h1)
        end
        delete(h0)
    end
    close
end
%%
if FLAGplot
    figure; hold on
    axis([-50 50 -50 50])
    h=polar(deg2rad(ALL_Spkes),ALL_Rings,'sb');
    set(h,'markeredgecolor','none','markerfacecolor',[0 1 0].*.8)
    polar(deg2rad(Spkes),Rings,'ok')
end
F = [];
T1 = [];
T2 = [];

for I_F = 1:size(RingsF,1)
    cRF = RingsF(I_F);
    cSF = SpkesF(I_F);
    [AEF] = rphiazel(cRF,cSF);
    for I_T1 = 1:size(RingsT1,1);
        cRT1 = RingsT1(I_T1);
        cST1 = SpkesT1(I_T1);
        [AET1] = rphiazel(cRT1,cST1);
        for I_T2 = 1:size(RingsT2,1)
            cRT2 = RingsT2(I_T2);
            cST2 = SpkesT2(I_T2);
            [AET2] = rphiazel(cRT2,cST2);
            
            %%
            cAE = AET1-AEF;
            distF_T1 = hypot(cAE(1),cAE(2));
            cAE = AET2-AEF;
            distF_T2 = hypot(cAE(1),cAE(2));
            cAE = AET2-AET1;
            distT1_T2 = hypot(cAE(1),cAE(2));
            
            sel = distF_T1 > 20 & distF_T1 < FOV & distT1_T2 > 1 & distF_T2 > 1;
            if sel == 1
                if FLAGplot
                    h0 = plot(AEF(1),AEF(2),'.r');
                    h1 = plot(AET1(1),AET1(2),'or');
                    h2 = plot(AET2(1),AET2(2),'*r');
                    set(h0,'markersize',5,'linewidth',3)
                    set(h1,'markersize',15,'linewidth',3)
                    set(h2,'markersize',15,'linewidth',3)
                    drawnow
                    delete(h0);
                    delete(h1);
                    delete(h2);
                end
                F = [F;[cRF cSF]];
                T1 = [T1;[cRT1 cST1]];
                T2 = [T2;[cRT2 cST2]];
            end
        end
    end
end
if FLAGplot
    close
end
%%
Ntrl = size(F,1);
IxRS_F = nan(Ntrl,2);
IxRS_T1 = nan(Ntrl,2);
IxRS_T2 = nan(Ntrl,2);
for I_tr = 1:Ntrl
    cR = F(I_tr,1);
    cS = F(I_tr,2);
    [d,cIxR]=min(abs(LEDSKY_RING - cR));
    cIxR = cIxR - 1;
    [d,cIxS]=min(abs(LEDSKY_SPOKE - cS));
    if cIxR == 0
        cIxR = 2;
        cIxS = 0;
    end
    IxRS_F(I_tr,:) = [cIxR cIxS];
    
    cR = T1(I_tr,1);
    cS = T1(I_tr,2);
    [d,cIxR]=min(abs(LEDSKY_RING - cR));
    cIxR = cIxR - 1;
    [d,cIxS]=min(abs(LEDSKY_SPOKE - cS));
    if cIxR == 0
        cIxR = 0;
        cIxS = 2;
    end
    IxRS_T1(I_tr,:) = [cIxR cIxS];
    
    cR = T2(I_tr,1);
    cS = T2(I_tr,2);
    [d,cIxR]=min(abs(LEDSKY_RING - cR));
    cIxR = cIxR - 1;
    [d,cIxS]=min(abs(LEDSKY_SPOKE - cS));
    if cIxR == 0
        cIxR = 0;
        cIxS = 2;
    end
    IxRS_T2(I_tr,:) = [cIxR cIxS];
end
%%
un = unique([IxRS_F,IxRS_T1,IxRS_T2],'rows');
IxRS_F = un(:,[1 2]);
IxRS_T1 = un(:,[3 4]);
IxRS_T2 = un(:,[5 6]);
Ntrl = size(IxRS_F,1);
if FLAGplot
    figure; hold on
    h=polar(deg2rad(ALL_Spkes),ALL_Rings,'sb');
    set(h,'markeredgecolor','none','markerfacecolor',[0 1 0].*.8)
    polar(deg2rad(Spkes),Rings,'ok')
    for I_tr = 1:Ntrl
        [A,E] = sky2azel(IxRS_F(I_tr,1),IxRS_F(I_tr,2));
        h0=plot(A,E,'.r');
        set(h0,'markersize',5,'linewidth',3)
        [A,E] = sky2azel(IxRS_T1(I_tr,1),IxRS_T1(I_tr,2));
        h1=plot(A,E,'or');
        set(h1,'markersize',15,'linewidth',3)
        [A,E] = sky2azel(IxRS_T2(I_tr,1),IxRS_T2(I_tr,2));
        h2=plot(A,E,'*r');
        set(h2,'markersize',15,'linewidth',3)
        drawnow
        delete(h2)
        delete(h1)
        delete(h0)
    end
    close
end
%%
Targets = zeros(Ntrl,21);
Targets(:,1) = ones(Ntrl,1)*3;
Targets(:,2:7) = [IxRS_F,IxRS_T1,IxRS_T2];

Targets = zeros(Ntrl,21);
Targets(:,1) = ones(Ntrl,1)*2;
Targets(:,2:5) = [IxRS_T1,IxRS_T2];

ListFile = 'D:\HumanMatlab\Tom\TrailList\Dynamic2step.mat'
save(ListFile,'Targets','-mat');
ListFile = 'D:\HumanMatlab\Tom\TrailList\Static2step.mat'
save(ListFile,'Targets','-mat');