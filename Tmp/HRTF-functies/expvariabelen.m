
theta=[];
phi=[];
int=[];
ledon=[];
sndon=[];
id1=[];
id2=[]

for i=1:6
    x=round(100*random('beta',1,1));
    theta = [theta ; 0];
    phi=[phi ; 31];
    int=[int ; 50];
    ledon=[ledon ; 500+x];
    sndon=[sndon ; 100];
    id1=[id1 600+(i)];
id2=[id2 700+(i)];
i;
end
id=[id1;id2]';

writeexp_dubbel2('Op_Boog.exp','DAT',theta,phi,id,int,ledon,sndon)