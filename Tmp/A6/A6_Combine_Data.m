%% Combine Data
% 1 = SL, 2 = LS
% a = RG, b = TH, c = PH, d = CK, e = JR
% 1 = 1:250, 2 = 251:500
pa_datadir JR-RG-2012-04-06
load JR-RG-2012-04-06-0001
SupSacRG1 = pa_supersac(Sac,Stim,2,1);
sel1 = SupSacRG1(:,1)<= length(SupSacRG1)/2;
SupSacRG1a1 = SupSacRG1(sel1,:);
sel2 = SupSacRG1(:,1)> length(SupSacRG1)/2;
SupSacRG1a2 = SupSacRG1(sel2,:);

% load JR-RG-2012-04-06-0002
% 
% 
% pa_datadir RG-TH-2012-04-13
% load RG-TH-2012-04-13-0001
% SupSac2b1 = pa_supersac(Sac,Stim,2,1);
% 
pa_datadir RG-PH-2012-04-13
load RG-PH-2012-04-13-0001
SupSacPH1 = pa_supersac(Sac,Stim,2,1);
sel1 = SupSacPH1(:,1)<= length(SupSacPH1)/2;
SupSacPH1c1 = SupSacPH1(sel1,:);
sel2 = SupSacPH1(:,1)> length(SupSacPH1)/2;
SupSacPH1c2 = SupSacPH1(sel2,:);
% 
pa_datadir RG-CK-2012-04-13
load RG-CK-2012-04-13-0001
SupSacCK = pa_supersac(Sac,Stim,2,1);
SupSacCK1 = pa_supersac(Sac,Stim,2,1);
sel1 = SupSacCK1(:,1)<= length(SupSacCK1)/2;
SupSacCK1d1 = SupSacCK1(sel1,:);
sel2 = SupSacCK1(:,1)> length(SupSacCK1)/2;
SupSacCK1d2 = SupSacCK1(sel2,:);
% 
% pa_datadir RG-JR-2012-04-16
% load RG-JR-2012-04-16-0001
% SupSac2e1 = pa_supersac(Sac,Stim,2,1);


SupSacSL = [SupSacRG1a1; SupSacPH1c1; SupSacCK1d1; SupSacRG1a2; SupSacPH1c2; SupSacCK1d2 ];
cd C:\DATA
save ('SUPSAC_SL', 'SupSacSL')