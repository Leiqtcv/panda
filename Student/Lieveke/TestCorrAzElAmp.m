close all
clear all
x = 1:3:29;
y = -70;
[X1,X2]=meshgrid(x,x);
X1 = X1(:);
X2 = X2(:);
l=length(X1);
X1 = repmat(X1,3,1);
X2 = repmat(X2,3,1);
Y1 = [repmat(-70,l,1);repmat(0,l,1);repmat(45,l,1)];
Y2 = [repmat(-70,l,1);repmat(0,l,1);repmat(45,l,1)];

[A1,E1]=fart2azel(Y1,X1);
[A2,E2]=fart2azel(Y2,X2);

dA = abs(A1-A2);
dE = abs(E1-E2);
dS = sqrt( (A1-A2).^2+(E1-E2).^2 );

subplot(221);
plot(dA,dE,'k.');
axis square
lsline;
r=corrcoef(dA,dE);
r = r(2)^2;
str = ['R^2 = ' num2str(r)];
title(str);
xlabel('\Delta Azimuth');
ylabel('\Delta Elevation');

subplot(222);
plot(dS,dA,'k.');
axis square
lsline;
r=corrcoef(dS,dA);
r = r(2)^2;
str = ['R^2 = ' num2str(r)];
title(str);
xlabel('\Delta Space');
ylabel('\Delta Azimuth');

subplot(223);
plot(dS,dE,'k.');
axis square
lsline;
r=corrcoef(dS,dE);
r = r(2)^2;
str = ['R^2 = ' num2str(r)];
title(str);
xlabel('\Delta Space');
ylabel('\Delta Elevation');

whos
