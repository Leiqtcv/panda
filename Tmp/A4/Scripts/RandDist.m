%% A4 Stimulus Preparation

close all
clear all

%Azimuth, AZI
Y=[-48:3:48];
m=round(32*rand(1,450)) + 1;
AZI = zeros(1,450);
AZI = Y(m);
AZI= AZI';
figure(1)
hist(AZI,[-48,-45,-42,-39,-36,-33,-30,-27,-24,-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48])
title ('Azimuth')

%Elevation, ELE
X=[-50:5:50];
n=round(20*rand(1,450)) + 1;
ELE = zeros(1,450);
ELE = X(n);
ELE=ELE';
figure (2)
hist(ELE,[-50,-45,-40,-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,45,50])
title ('Elevation')

%Shows Distribution 
figure(3)
plot(AZI,ELE,'o')
xlabel('Azimuth')
ylabel('Elevation')
title ('Distribution')
hold on
x1=-11;
x2=11;
y1=-11;
y2=-11;
plot([x1,x2],[y1,y2])
x1=-11;
x2=11;
y1=11;
y2=11;
plot([x1,x2],[y1,y2])
x1=-11;
x2=-11;
y1=-11;
y2=11;
plot([x1,x2],[y1,y2])
x1=11;
x2=11;
y1=11;
y2=-11;
plot([x1,x2],[y1,y2])

x1=-31;
x2=31;
y1=-31;
y2=-31;
plot([x1,x2],[y1,y2])
x1=-31;
x2=31;
y1=31;
y2=31;
plot([x1,x2],[y1,y2])
x1=-31;
x2=-31;
y1=-31;
y2=31;
plot([x1,x2],[y1,y2])
x1=31;
x2=31;
y1=31;
y2=-31;
plot([x1,x2],[y1,y2])
xlim([-53 53])
ylim([-53 53])
hold off
%Combining Azimuth and Elevation Values into one matrix, pair of values
%give coordinates for stimuli

D=[AZI,ELE];     %D gives the whole matrix, which contains all stimuli coordinates. The large range
                 %contains all these
            

% D=D(1:225,1:2)

% F=D(1:225,1:2);
% S=D(226:450,1:2);

%Large Range
Large=D;       %Large, stimuli for the large condition up to 50 degree
close all
figure(4)
subplot(221)
laz=Large(:,1);
lel=Large(:,2);
plot(laz,lel,'o')
subplot(224)
plot(laz,lel,'o')

%Medium Range

Medium=D;            
% sel = Medium <-10 | Medium>10;  %first selection, excludes 10degrees
% sel = sum(sel,2);
% sel=logical(sel);
% Medium=Medium(sel,:);

sel=Medium>-30 & Medium<30;  %second selection, excludes large range
sel=sum(sel,2);
c=find(sel==1);
sel(c)=0;
sel=logical(sel);
Medium=Medium(sel,:);       % Medium gives matrix for medium range

subplot(222)
maz=Medium(:,1);
mel=Medium(:,2);
plot(maz,mel,'o')
xlim([-50 50])
ylim([-50 50])


% Small Range

Small=D;             
sel = Small(:,1)>=-10 & Small(:,1)<=10 & Small(:,2)>=-10 & Small(:,2)<=10;
sel = sum(sel,2);
sel=logical(sel);
Small=Small(sel,:);        %All3 is matrix for the smallest range, 10 degree
saz=Small(:,1);
sel=Small(:,2);
subplot(223)
plot(saz,sel,'o')
xlim([-50 50])
ylim([-50 50])



subplot(224)
plot(laz,lel,'o')
hold on
plot(maz,mel,'ro')
plot(saz,sel,'go')
     plot([-90 0],[0 -90],'b-','LineWidth',2)
           plot([0 90],[-90 0],'b-','LineWidth',2)
           plot([0 90],[90 0],'b-','LineWidth',2)
           plot([-90 0],[0 90],'b-','LineWidth',2)
return
%% Stimuli 

% D is the matrix with all stimuli that will be tested. We have 450
% stimuli. roughly 30 in the small, 150 in the medium and 450 in the large range.
%In order to test them all, the whole experiment is divided into 3
%sessions. Session one will contain the first 150 stimuli, session two
%151-300 and session 3 301-450. Each Session contains 4 Conditions: 1)
%Small range with roughly 30 (not divided by three, cause we want more stimuli here) stimuli, 
% medium range with roughly 50 stimuli and range
% large1 with 75 and range large2 with another 75 stimuli. 

% When the small range is tested once in each session and the medium
% range once, we receive 90 stimuli for small, 150 for medium and 2*225 for
% large, after testing all three sessions, per subject. This would make
% approximately 690 responses. If each trial takes 5 seconds it would take
% 3450 seconds, which are 58 minutes. As we have three session it
% would take about twenty minutes for completing one session. Plus
% preparation time, and breaks in between, not more than 30 minutes I
% guess, for each session.

%Summary
% 3 Sessions with each 4 conditions
% 3*(1xSmall(3xstimuli), 1xMedium, 2xLarge(first and second
% portion))
%Task: Get the right data for the matrices for all 4 conditions and three
%sessions
%

%Session 1

S1=Small;    %30 stimuli
M1=Medium(1:50,1:2);
L11=Large(1:75,1:2);
L12=Large(76:150,1:2);

%Session 2
S2=Small;
M2=Medium(51:100,1:2);
L21=Large(151:225,1:2);
L22=Large(226:300,1:2);

% Session 3
S3=Small;
M3=Medium(101:length(Medium),1:2);
L31=Large(301:375, 1:2);
L32=Large(376:450,1:2);

%Check

figure (5)
subplot(221)
plot(AZI,ELE,'o')
hold on

subplot(222)
plot(AZI,ELE,'o')
hold on
plot(saz,sel,'ko')

subplot(223)

plot(AZI,ELE,'o')
hold on
plot(saz,sel,'ko')

M1az=M1(:,1);
M1el=M1(:,2);
plot(M1az,M1el,'go')

M2az=M2(:,1);
M2el=M2(:,2);
plot(M2az,M2el,'go')

M3az=M3(:,1);
M3el=M3(:,2);
plot(M3az,M3el,'go')

subplot (224)

plot(AZI,ELE,'o')
hold on
plot(saz,sel,'ko')

M1az=M1(:,1);
M1el=M1(:,2);
plot(M1az,M1el,'go')

M2az=M2(:,1);
M2el=M2(:,2);
plot(M2az,M2el,'go')

M3az=M3(:,1);
M3el=M3(:,2);
plot(M3az,M3el,'go')

L11az=L11(:,1);
L11el=L11(:,2);
plot(L11az,L11el,'ro')

L21az=L21(:,1);
L21el=L21(:,2);
plot(L21az,L21el,'ro')

L31az=L31(:,1);
L31el=L31(:,2);
plot(L31az,L31el,'ro')


L12az=L12(:,1);
L12el=L12(:,2);
plot(L12az,L12el,'ro')

L22az=L22(:,1);
L22el=L22(:,2);
plot(L22az,L22el,'ro')

L32az=L32(:,1);
L32el=L32(:,2);
plot(L32az,L32el,'ro')


%% Final Stimuli-Matrices for the Experiment:

%Session 1
%Small Range Stimuli =S1
%Medium Range Stimuli=M1
%Large Range Stimuli 1/2= L11
%Large Range Stimuli 2/2= L12

%Session 2
%Small Range Stimuli =S2
%Medium Range Stimuli=M2
%Large Range Stimuli 1/2= L21
%Large Range Stimuli 2/2= L22

%Session 3
%Small Range Stimuli =S3
%Medium Range Stimuli=M3
%Large Range Stimuli 1/2= L31
%Large Range Stimuli 2/2= L32

save('Stimuli_Matrices4','S1', 'saz', 'sel','S2','S3','M1', 'M1az', 'M1el', 'M2az', 'M2el', 'M3az','M3el','M2','M3','L11','L11az','L11el','L12','L12az','L12el','L21','L21az','L21el','L22', 'L22az','L22el', 'L31','L31az','L31el', 'L32','L32az','L32el')