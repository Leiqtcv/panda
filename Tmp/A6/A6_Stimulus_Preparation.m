%% Training Newbies Stimulus Preparation

close all
clear all

X=[-55:5:-5];
Y=[5:5:55];
X= [X,Y];
n=round(21*rand(1,250)) + 1;
ELE = zeros(1,250);
ELE = X(n);
ELEL=ELE';
figure (1)
hist(ELEL,[-50,-45,-40,-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,45,50])
title ('Elevation')
AZIL = ELEL;
AZIL(:,:) = 0 ;

L=[AZIL,ELEL]; 


X1=[-15:5:-5];
Y1=[5:5:15];
X1= [X1,Y1];
n1=round(5*rand(1,250)) + 1;
ELE1 = zeros(1,250);
ELE1 = X1(n1);
ELES=ELE1';
figure (2)
hist(ELES,[-50,-45,-40,-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,45,50])
title ('Elevation')
AZIS = ELES;
AZIS(:,:) = 0; 

S=[AZIS,ELES];


save('A6_Stimuli_Matrices1','L', 'S')