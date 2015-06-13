clear all
        pa_datadir JR-RG-2012-02-22
        load JR-RG-2012-02-22-0001
        
        SupSac = pa_supersac(Sac,Stim,2,1);

K=SupSac(:,23)<11 & SupSac(:,24)<11;
H10=find(K);
A=numel(H10)/400
% 
K=SupSac(:,23)>10 & SupSac(:,23)<31 | SupSac(:,24)>10 & SupSac(:,24)<31;
H30=find(K);
B=numel(H30)/400
% 
K=SupSac(:,23)>30 & SupSac(:,23)<101 | SupSac(:,24)>30  & SupSac(:,24)<101;
H70=find(K);
C=numel(H70)/400



% sel=SupSac(:,23) & SupSac(:,24);
% K= SupSac(sel);
% numel(K)

% 
% K=SupSac(:,23) & SupSac(:,24);
% numel(K)