function DblSndsAnalysisAziEle(CleanFlag)

%% Initialization
if nargin<1
	CleanFlag = 1;
end

%% Beware, some cleaning
if CleanFlag
	close all
	clear all
	clc;
end

%% Targets
T1 = [0 30];
T2 = [30 0];

%% Monte Carlo simulation of responses
s1	= [2 4];
s2	= [4 2];
N	= 10^2;

R1	= [s1(1)*randn(N,1)+T1(1) s1(2)*randn(N,1)+T1(2)];
R2	= [s2(1)*randn(N,1)+T2(1) s2(2)*randn(N,1)+T2(2)];

%% Predictions
AVG = .5*R1+.5*R2;
w1	= (s2.^2)./(s1.^2+s2.^2);
w2	= (s1.^2)./(s1.^2+s2.^2);
BAY = repmat(w1,N,1).*R1+repmat(w2,N,1).*R2;
figure
graph(T1,T2,R1,R2,AVG,BAY)
subplot(2,2,2)
str = {'Bayesian Weighted Averaging';['w1_{az} = ' num2str(w1(1)) ', w1_{el} = ' num2str(w1(2))];['w2_{az} = ' num2str(w2(1)) ', w2_{el} = ' num2str(w2(2))]};
title(str)

w1 = rand(N,2);
% w1 = rand(N,1); w1 = [w1 w1];
whos w1 R1
AVG = w1.*R1+(1-w1).*R2;
graph3(T1,T2,R1,R2,AVG)
	
L = 0.15:0.3:0.85;
for i = 1:length(L);
	AVG = L(i)*R1+(1-L(i))*R2;
	graph2(T1,T2,R1,R2,AVG)
end


function graph(T1,T2,R1,R2,AVG,BAY)

subplot(2,2,1)
hold on
axis([-10 40 -10 40]);
axis square;
horline;
verline;

% Plo Targets
h = plot(T1,T2,'k:'); set(h,'Color',[.5 .5 .5],'LineWidth',2);
h = plot(T1(1),T1(2),'ks'); set(h,'MarkerFaceColor','r');
h = plot(T2(1),T2(2),'ks'); set(h,'MarkerFaceColor','b');

% Plot Responses
h = plot(R1(:,1),R1(:,2),'r.');

[x,y,a,Seig]	= getellips(R1(:,1),R1(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'r-');
[x,y,a,Seig]	= getellips(R2(:,1),R2(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'b-');
[x,y,a,Seig]	= getellips(AVG(:,1),AVG(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'k-');

h = plot(R2(:,1),R2(:,2),'b.');
h = plot(AVG(:,1),AVG(:,2),'k.');

box on
xlabel('Azimuth (deg)');
ylabel('Elevation (deg)');
title({'Level Weighted Averaging';'w1=w2=.5'});

%%


subplot(2,2,2)
hold on
axis([-10 40 -10 40]);
axis square;
horline;
verline;

% Plo Targets
h = plot(T1,T2,'k:'); set(h,'Color',[.5 .5 .5],'LineWidth',2);

% Plot Responses
h = plot(R1(:,1),R1(:,2),'r.');
h = plot(R2(:,1),R2(:,2),'b.');
h = plot(BAY(:,1),BAY(:,2),'k.');

[x,y,a,Seig]	= getellips(R1(:,1),R1(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'r-');
[x,y,a,Seig]	= getellips(R2(:,1),R2(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'b-');
[x,y,a,Seig]	= getellips(BAY(:,1),BAY(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'k-');

h = plot(T1(1),T1(2),'ks'); set(h,'MarkerFaceColor','r');
h = plot(T2(1),T2(2),'ks'); set(h,'MarkerFaceColor','b');

box on
xlabel('Azimuth (deg)');
ylabel('Elevation (deg)');
title('Bayesian Weighted Averaging');

function graph2(T1,T2,R1,R2,AVG,BAY)

subplot(2,2,3)
hold on
axis([-10 40 -10 40]);
axis square;
horline;
verline;

% Plo Targets
h = plot(T1,T2,'k:'); set(h,'Color',[.5 .5 .5],'LineWidth',2);

% Plot Responses
plot(R1(:,1),R1(:,2),'r.');
plot(R2(:,1),R2(:,2),'b.');
plot(AVG(:,1),AVG(:,2),'k.');

[x,y,a,Seig]	= getellips(R1(:,1),R1(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'r-');
[x,y,a,Seig]	= getellips(R2(:,1),R2(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'b-');
[x,y,a,Seig]	= getellips(AVG(:,1),AVG(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'k-');

h = plot(T1(1),T1(2),'ks'); set(h,'MarkerFaceColor','r');
h = plot(T2(1),T2(2),'ks'); set(h,'MarkerFaceColor','b');

box on
xlabel('Azimuth (deg)');
ylabel('Elevation (deg)');
title({'Level Weighted Averaging';'w1 = [.1:.2:.9], w2 = 1-w1'});

function graph3(T1,T2,R1,R2,AVG,BAY)

subplot(2,2,4)
hold on
axis([-10 40 -10 40]);
axis square;
horline;
verline;

% Plo Targets
h = plot(T1,T2,'k:'); set(h,'Color',[.5 .5 .5],'LineWidth',2);

% Plot Responses
plot(R1(:,1),R1(:,2),'r.');
plot(R2(:,1),R2(:,2),'b.');
plot(AVG(:,1),AVG(:,2),'k.');

[x,y,a,Seig]	= getellips(R1(:,1),R1(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'r-');
[x,y,a,Seig]	= getellips(R2(:,1),R2(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'b-');
[x,y,a,Seig]	= getellips(AVG(:,1),AVG(:,2));
h				= ellipse(x,y,2*Seig(1),2*Seig(2),a,'k-');

h = plot(T1(1),T1(2),'ks'); set(h,'MarkerFaceColor','r');
h = plot(T2(1),T2(2),'ks'); set(h,'MarkerFaceColor','b');

box on
xlabel('Azimuth (deg)');
ylabel('Elevation (deg)');
title({'Random Weights Weighted Averaging';'w1 = RAND, w2 = 1-w1'});
function [x,y,a,Seig] = getellips(A,E)
[Veig,Deig]		= eig(cov(A,E));
% Veig gives main axes
Aeig		= rad2deg(atan2(Veig(2),Veig(1)));
% diagonal Deig = variance in the 2 main axes
Seig		= sqrt(diag(Deig));
x			= mean(A);
y			= mean(E);
a			= Aeig;


function h=ellipse(Xo,Yo,L,S,Phi,Sty)

DTR = pi/180;
Phi = Phi*DTR;
wt  = [0:2:360].*DTR;
X   = Xo + L*cos(Phi)*cos(wt) - S*sin(Phi)*sin(wt);
Y   = Yo + L*sin(Phi)*cos(wt) + S*cos(Phi)*sin(wt);
h=plot(X,Y,Sty);
  
