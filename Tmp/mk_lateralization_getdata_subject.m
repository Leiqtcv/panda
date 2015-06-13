function [R,V,D,VD,ND] = mk_lateralization_getdata_subject(subname)
% Input:  subject of MK_HEMISPHERE_RIPPLEQUEST experiment
% Output: structures R,V,D en VD,ND 
%                     (rr = Right ear, Right hand, rl = Right ear,left hand, 
%                     ll = Left ear, Left hand, lr = Left ear, Right hand)
%                     .rr,.rl,.lr,.ll is again a structure with output from
%                     MK_LATERALIZATION_GETDATA_CONDITION
%                     VD.mu = mean rt all conditions, VD.se = stderror
%                     ND.tot = total not detected all conditions

d = 'C:\DATA\Ripple';
cd(d);

if nargin<1
	subname = 'sub1';
end

%% Get data for each condition
% rr
d = dir(['SessionCompleted_' subname '_right_right.mat']);
fnames = d.name;
[Rrr,Vrr,Drr,VDrr,NDrr] = mk_lateralization_getdata_condition(fnames);
R.rr = Rrr;
VD.rr = VDrr;
V.rr = Vrr;
D.rr = Drr;
ND.rr = NDrr;

%ll
d = dir(['SessionCompleted_' subname '_left_left.mat']);
fnames = d.name;
[Rll,Vll,Dll,VDll,NDll] = mk_lateralization_getdata_condition(fnames);
R.ll = Rll;
VD.ll = VDll;
V.ll = Vll;
D.ll = Dll;
ND.ll = NDll;

%lr
d = dir(['SessionCompleted_' subname '_left_right.mat']);
fnames = d.name;
[Rlr,Vlr,Dlr,VDlr,NDlr] = mk_lateralization_getdata_condition(fnames);
R.lr = Rlr;
VD.lr = VDlr;
V.lr = Vlr;
D.lr = Dlr;
ND.lr = NDlr;

%rl
d = dir(['SessionCompleted_' subname '_right_left.mat']);
fnames = d.name;
[Rrl,Vrl,Drl,VDrl,NDrl] = mk_lateralization_getdata_condition(fnames);
R.rl = Rrl;
VD.rl = VDrl;
V.rl = Vrl;
D.rl = Drl;
ND.rl = NDrl;

%overall mean rt and total not detected all conditions
VD.mu = nanmean([VD.rr.rt VD.rl.rt VD.lr.rt VD.ll.rt]);
VD.se = nanstd([VD.rr.rt VD.rl.rt VD.lr.rt VD.ll.rt])./sqrt(numel([VD.rr.rt VD.rl.rt VD.lr.rt VD.ll.rt]));
ND.tot = ND.rr.tot + ND.rl.tot + ND.lr.tot + ND.ll.tot;

%mean rt vs density per velocity
% D.d = D.rr.d;
% D.mu0 = nanmean([D.rr.mu0;D.rl.mu0;D.lr.mu0;D.ll.mu0]);
% D.ci0 = 1./sqrt(nansum([1./(D.rr.ci0).^2; 1./(D.rl.ci0).^2; 1./(D.lr.ci0).^2; 1./(D.ll.ci0).^2]));
% D.mulo = nanmean([D.rr.mulo;D.rl.mulo;D.lr.mulo;D.ll.mulo]);
% D.cilo = 1./sqrt(nansum([1./(D.rr.cilo).^2; 1./(D.rl.cilo).^2; 1./(D.lr.cilo).^2; 1./(D.ll.cilo).^2]));
% D.muhi = nanmean([D.rr.muhi;D.rl.muhi;D.lr.muhi;D.ll.muhi]);
% D.cihi = 1./sqrt(nansum([1./(D.rr.cihi).^2; 1./(D.rl.cihi).^2; 1./(D.lr.cihi).^2; 1./(D.ll.cihi).^2]));

%total mean rt per velocity
% D.smu0 = nanmean([D.rr.smu0 D.rl.smu0 D.lr.smu0 D.ll.smu0]);
% D.sci0 = 1./sqrt(nansum([1./(D.rr.sci0).^2; 1./(D.rl.sci0).^2; 1./(D.lr.sci0).^2; 1./(D.ll.sci0).^2]));
% D.smulo = nanmean([D.rr.smulo D.rl.smulo D.lr.smulo D.ll.smulo]);
% D.scilo = 1./sqrt(nansum([1./(D.rr.scilo).^2; 1./(D.rl.scilo).^2; 1./(D.lr.scilo).^2; 1./(D.ll.scilo).^2]));
% D.smuhi = nanmean([D.rr.smuhi D.rl.smuhi D.lr.smuhi D.ll.smuhi]);
% D.scihi = 1./sqrt(nansum([1./(D.rr.scihi).^2; 1./(D.rl.scihi).^2; 1./(D.lr.scihi).^2; 1./(D.ll.scihi).^2]));

% D.ndt0 = nanmean([D.rr.ndt0;D.lr.ndt0;D.rl.ndt0;D.ll.ndt0]);
% D.ndtlo = nanmean([D.rr.ndtlo;D.lr.ndtlo;D.rl.ndtlo;D.ll.ndtlo]);
% D.ndthi = nanmean([D.rr.ndthi;D.lr.ndthi;D.rl.ndthi;D.ll.ndthi]);

%mean rt vs velocity per density
% V.v = V.rr.v;
% V.mu0 = nanmean([V.rr.mu0;V.rl.mu0;V.lr.mu0;V.ll.mu0]);
% V.mu1 = nanmean([V.rr.mu1;V.rl.mu1;V.lr.mu1;V.ll.mu1]);
% V.mu2 = nanmean([V.rr.mu2;V.rl.mu2;V.lr.mu2;V.ll.mu2]);
% V.mu4 = nanmean([V.rr.mu4;V.rl.mu4;V.lr.mu4;V.ll.mu4]);
% V.ci0 = 1./sqrt(nansum([1./(V.rr.ci0).^2; 1./(V.rl.ci0).^2; 1./(V.lr.ci0).^2; 1./(V.ll.ci0).^2]));
% V.ci1 = 1./sqrt(nansum([1./(V.rr.ci1).^2; 1./(V.rl.ci1).^2; 1./(V.lr.ci1).^2; 1./(V.ll.ci1).^2]));
% V.ci2 = 1./sqrt(nansum([1./(V.rr.ci2).^2; 1./(V.rl.ci2).^2; 1./(V.lr.ci2).^2; 1./(V.ll.ci2).^2]));
% V.ci4 = 1./sqrt(nansum([1./(V.rr.ci4).^2; 1./(V.rl.ci4).^2; 1./(V.lr.ci4).^2; 1./(V.ll.ci4).^2]));

%total mean rt per density
% V.smu0 = nanmean([V.rr.smu0 V.rl.smu0 V.lr.smu0 V.ll.smu0]);
% V.sci0 = 1./sqrt(nansum([1./(V.rr.sci0).^2; 1./(V.rl.sci0).^2; 1./(V.lr.sci0).^2; 1./(V.ll.sci0).^2]));
% V.smu1 = nanmean([V.rr.smu1 V.rl.smu1 V.lr.smu1 V.ll.smu1]);
% V.sci1 = 1./sqrt(nansum([1./(V.rr.sci1).^2; 1./(V.rl.sci1).^2; 1./(V.lr.sci1).^2; 1./(V.ll.sci1).^2]));
% V.smu2 = nanmean([V.rr.smu2 V.rl.smu2 V.lr.smu2 V.ll.smu2]);
% V.sci2 = 1./sqrt(nansum([1./(V.rr.sci2).^2; 1./(V.rl.sci2).^2; 1./(V.lr.sci2).^2; 1./(V.ll.sci2).^2]));
% V.smu4 = nanmean([V.rr.smu4 V.rl.smu4 V.lr.smu4 V.ll.smu4]);
% V.sci4 = 1./sqrt(nansum([1./(V.rr.sci4).^2; 1./(V.rl.sci4).^2; 1./(V.lr.sci4).^2; 1./(V.ll.sci4).^2]));

% V.ndt0 = nanmean([V.rr.ndt0;V.lr.ndt0;V.rl.ndt0;V.ll.ndt0]);
% V.ndt1 = nanmean([V.rr.ndt1;V.lr.ndt1;V.rl.ndt1;V.ll.ndt1]);
% V.ndt2 = nanmean([V.rr.ndt2;V.lr.ndt2;V.rl.ndt2;V.ll.ndt2]);
% V.ndt4 = nanmean([V.rr.ndt4;V.lr.ndt4;V.rl.ndt4;V.ll.ndt4]);