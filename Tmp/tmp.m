close all
X = -100:0.1:100;
Y1 = normpdf(X,0,10);Y1 = Y1./sum(Y1);
Y2 = normpdf(X,20,10);Y2 = Y2./sum(Y2);

Y = Y1.*Y2;
Y = Y./sum(Y);

plot(X,Y1);
hold on
plot(X-20,Y2);
plot(X-10,Y);


